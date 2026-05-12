import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/gig_category_cache.dart";
import "package:uy_dosh/base/config/gemini_config.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_offer_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_request_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/keyboard_dismiss_scope.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_ai_enhance_button.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/photo_item.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/form_dirty_field_outline.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/unsaved_changes_dialog.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

const int _gigMinDurationStepMinutes = 5;
const int _gigMinDurationFloorMinutes = 5;
const int _gigMinDurationCeilingMinutes = 1440;
const int _gigMinDurationFallbackMinutes = 60;

/// Snaps saved/API values onto the spinner grid and applies sane bounds.
int _snapGigMinDurationMinutes(int? rawMinutes) {
  if (rawMinutes == null || rawMinutes <= 0) {
    return _gigMinDurationFallbackMinutes;
  }
  final stepped = (rawMinutes / _gigMinDurationStepMinutes).round() *
      _gigMinDurationStepMinutes;
  return stepped.clamp(
      _gigMinDurationFloorMinutes, _gigMinDurationCeilingMinutes);
}

bool _shouldRebuildGigPostRequestUI(
  GigPostRequestState previous,
  GigPostRequestState current,
) {
  if (previous.runtimeType != current.runtimeType) return true;
  if (previous is GigPostRequestIdle && current is GigPostRequestIdle) {
    return !identical(previous.categories, current.categories);
  }
  return true;
}

bool _shouldRebuildGigPostOfferUI(
  GigPostOfferState previous,
  GigPostOfferState current,
) {
  if (previous.runtimeType != current.runtimeType) return true;
  if (previous is GigPostOfferIdle && current is GigPostOfferIdle) {
    return !identical(previous.categories, current.categories);
  }
  return true;
}

Photo _photoFromGigOfferPhoto(GigOfferPhoto p) {
  return Photo(
    id: p.id,
    photoUrl: p.photoUrl,
    photoOrder: p.photoOrder,
    isPrimary: p.isPrimary,
    createdAt: "1970-01-01T00:00:00.000Z",
  );
}

/// Two flavors of "publish something to the gig hub":
///
/// * [task] — the user *needs* a service; they describe a job and a budget,
///   and providers bid on it. Backed by [GigPostRequestBloc] →
///   `POST /gigs/requests`.
/// * [service] — the user *provides* a service; they list price + category,
///   and clients book them. Backed by [GigPostOfferBloc] →
///   `POST /gigs/offers`.
enum GigPublishMode { task, service }

/// Single screen that subsumes the legacy `PostGigRequestScreen` /
/// `PostGigOfferScreen` pair. A segmented toggle at the top swaps the
/// flavor; common fields (category / title / description / remote) stay
/// stable across modes so the user doesn't have to re-enter shared inputs
/// when they realize they meant "task" instead of "service" (or vice
/// versa). Submit dispatches to whichever bloc matches the current mode.
class PublishGigScreen extends StatefulWidget {
  const PublishGigScreen({
    super.key,
    this.initialMode = GigPublishMode.task,
    this.editingOffer,
    this.editingRequest,
  });

  final GigPublishMode initialMode;

  /// When non-null, the screen runs in "edit service" mode: the
  /// task/service toggle is hidden, all service fields are prefilled from
  /// the offer, the submit button reads "Save", and submission dispatches
  /// [SubmitGigOfferEdit] (PATCH /gigs/offers/:id) followed by any photo
  /// add/reorder work.
  final GigOffer? editingOffer;

  /// When non-null, the screen runs in "edit task" mode: same as [editingOffer]
  /// but for a client's open [GigRequest] — [SubmitGigRequestEdit] → PATCH
  /// `/gigs/requests/:id`.
  final GigRequest? editingRequest;

  @override
  State<PublishGigScreen> createState() => _PublishGigScreenState();
}

class _PublishGigScreenState extends State<PublishGigScreen> {
  // Field length caps — mirror the create/edit listing screens so users get
  // consistent limits across all forms in the app.
  static const int _titleMaxLength = 50;
  static const int _titleCounterVisibleAt = 40;
  static const int _descriptionMaxLength = 1000;
  static const int _descriptionCounterVisibleAt = 700;

  /// Description grows from 4 → 7 lines when the user taps the chevron in the
  /// counter toolbar. Mirrors the create/edit listing screens so users get the
  /// same affordance everywhere the app collects long-form copy.
  static const int _descriptionBaseLines = 4;
  static const int _descriptionExpandedExtraLines = 3;
  bool _isDescriptionExpanded = false;

  // Shared form scaffolding. Re-validating with the same key across modes
  // is fine because the conditionally-mounted fields drop out of the form
  // tree when their mode is inactive.
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Task-only.
  final _budgetController = TextEditingController();
  final _addressController = TextEditingController();
  GigRequestBudgetType _budgetType = GigRequestBudgetType.fixed;

  // Service-only.
  final _priceController = TextEditingController();
  GigPricingType _pricingType = GigPricingType.fixed;

  /// Used when [GigPricingType.hourly] is selected ([_snapGigMinDurationMinutes]
  /// aligns edit-mode values with five-minute slots).
  int _minDurationMinutes = _gigMinDurationFallbackMinutes;

  GigCategory? _selectedCategory;
  bool _isRemote = false;
  bool _showCategoryError = false;
  bool _showTitleError = false;
  bool _showAmountError = false;
  late GigPublishMode _mode;

  /// Local file paths the user picked through [PhotoUploader] for the
  /// service flavor. Tasks deliberately skip photos for v1 (per product
  /// decision); we still keep the list state-bound so a user who toggles
  /// service → task → service doesn't lose their picks.
  List<String> _selectedPhotos = const <String>[];

  /// Index into [_selectedPhotos] for the user-marked cover image. `null`
  /// means "no explicit choice" — the bloc/server fall back to slot 0.
  int? _primaryPhotoIndex;

  /// Edit-offer only: server-backed gallery rows for [PhotoUploader].
  List<Photo> _existingOfferPhotos = [];

  /// Edit-offer only: combined existing + new tiles (includes drag order).
  List<PhotoItem> _orderedOfferPhotos = [];

  bool _photoOrderDirty = false;
  final Set<int> _deletingOfferPhotoIds = {};
  final Set<int> _makingOfferPhotoPrimaryIds = {};

  /// When true, [Navigator.pop] after a successful submit is allowed despite a
  /// dirty form (same pattern as [EditListingScreen] / [EditProfileScreen]).
  bool _allowPopWithoutConfirm = false;

  /// Mirrors [_isFormDirty] after each form [setState] so text-field listeners
  /// can skip rebuilding while the form stays dirty (see [_onFormTextChangedForChrome]).
  late bool _lastFormDirtyChrome;

  GigPublishMode _baselineMode = GigPublishMode.task;
  String _baselineTitle = "";
  String _baselineDescription = "";
  int? _baselineCategoryId;
  GigRequestBudgetType _baselineBudgetType = GigRequestBudgetType.fixed;
  String _baselineBudgetText = "";
  String _baselineAddressText = "";
  GigPricingType _baselinePricingType = GigPricingType.fixed;
  String _baselinePriceText = "";
  int _baselineMinDurationMinutes = _gigMinDurationFallbackMinutes;
  bool _baselineRemote = false;
  String _baselineCurrency = "UZS";
  bool _baselineDescriptionExpanded = false;
  List<String> _baselineSelectedPhotos = const <String>[];
  int? _baselinePrimaryPhotoIndex;
  String _baselineOfferPhotosFingerprint = "";

  /// ISO-4217-ish code shown as the prefix on the budget/price input. Shared
  /// between task and service modes so a user who flips back and forth keeps
  /// their currency choice. Backend default is also "UZS", so the empty
  /// state matches what the API would record on its own.
  String _currency = "UZS";
  static const List<String> _supportedCurrencies = ["UZS", "USD"];

  bool get _isEditingOffer => widget.editingOffer != null;

  bool get _isEditingRequest => widget.editingRequest != null;

  @override
  void initState() {
    super.initState();
    assert(
      widget.editingOffer == null || widget.editingRequest == null,
      "editingOffer and editingRequest are mutually exclusive",
    );
    _mode = widget.editingOffer != null
        ? GigPublishMode.service
        : widget.editingRequest != null
            ? GigPublishMode.task
            : widget.initialMode;

    final offer = widget.editingOffer;
    final editingReq = widget.editingRequest;
    if (offer != null) {
      // Prefer the embedded category from the API response; fall back to
      // the local cache lookup so the picker still shows the correct chip
      // when the response omitted the subobject.
      _selectedCategory =
          offer.category ?? GigCategoryCache.getById(offer.categoryId);
      _titleController.text = offer.title;
      // Prefill only from the Russian field — the create flow only writes
      // `description_ru`, so the round trip stays consistent. The other
      // locale columns (uz/en) are left untouched on save.
      _descriptionController.text = offer.descriptionRu ?? "";
      _pricingType = offer.pricingType;
      _priceController.text = IntFormatUtils.withDotThousands(offer.price);
      _minDurationMinutes =
          _snapGigMinDurationMinutes(offer.minDurationMinutes);
      _isRemote = offer.isRemote;
      _currency = offer.currencyCode;
      _existingOfferPhotos = [
        for (final p in offer.photos) _photoFromGigOfferPhoto(p),
      ];
      _rebuildOfferOrderedPhotos();
    } else if (editingReq != null) {
      _selectedCategory = editingReq.category ??
          GigCategoryCache.getById(editingReq.categoryId);
      _titleController.text = editingReq.title;
      _descriptionController.text = editingReq.descriptionRu ?? "";
      _budgetType = editingReq.budgetType;
      _budgetController.text = editingReq.budgetAmount != null
          ? IntFormatUtils.withDotThousands(editingReq.budgetAmount!)
          : "";
      _addressController.text = editingReq.addressText ?? "";
      _isRemote = editingReq.isRemote;
      _currency = editingReq.currencyCode;
    }
    _captureBaseline();
    _lastFormDirtyChrome = _isFormDirty();
    // [PopScope.canPop] is evaluated when this widget rebuilds. Plain
    // [TextEditingController] edits do not rebuild the parent — same fix as
    // [EditListingScreen], but only schedule a rebuild when dirty toggles so
    // we don't repaint the whole form on every keystroke.
    _titleController.addListener(_onFormTextChangedForChrome);
    _descriptionController.addListener(_onFormTextChangedForChrome);
    _budgetController.addListener(_onFormTextChangedForChrome);
    _addressController.addListener(_onFormTextChangedForChrome);
    _priceController.addListener(_onFormTextChangedForChrome);
  }

  void _snapshotFormChrome() {
    _lastFormDirtyChrome = _isFormDirty();
  }

  void _mutateForm(VoidCallback fn) {
    setState(fn);
    _snapshotFormChrome();
  }

  void _onFormTextChangedForChrome() {
    if (!mounted) return;
    final dirty = _isFormDirty();
    if (dirty == _lastFormDirtyChrome) return;
    _lastFormDirtyChrome = dirty;
    setState(() {});
  }

  void _captureBaseline() {
    _baselineMode = _mode;
    _baselineTitle = _titleController.text;
    _baselineDescription = _descriptionController.text;
    _baselineCategoryId = _selectedCategory?.id;
    _baselineBudgetType = _budgetType;
    _baselineBudgetText = _budgetController.text;
    _baselineAddressText = _addressController.text;
    _baselinePricingType = _pricingType;
    _baselinePriceText = _priceController.text;
    _baselineMinDurationMinutes = _minDurationMinutes;
    _baselineRemote = _isRemote;
    _baselineCurrency = _currency;
    _baselineDescriptionExpanded = _isDescriptionExpanded;
    _baselineSelectedPhotos = List<String>.from(_selectedPhotos);
    _baselinePrimaryPhotoIndex = _primaryPhotoIndex;
    _baselineOfferPhotosFingerprint =
        _isEditingOffer ? _offerPhotosFingerprint(_orderedOfferPhotos) : "";
  }

  String _offerPhotosFingerprint(List<PhotoItem> items) {
    final parts = <String>[];
    for (final item in items) {
      if (item is ExistingPhotoItem) {
        parts.add("e:${item.photo.id}");
      } else if (item is NewPhotoItem) {
        parts.add("n:${item.path}");
      }
    }
    return parts.join("|");
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _isFormDirty() {
    if (_mode != _baselineMode) return true;
    if (_titleController.text != _baselineTitle) return true;
    if (_descriptionController.text != _baselineDescription) return true;
    if (_selectedCategory?.id != _baselineCategoryId) return true;
    if (_isRemote != _baselineRemote) return true;
    if (_currency != _baselineCurrency) return true;
    if (_isDescriptionExpanded != _baselineDescriptionExpanded) return true;

    if (_mode == GigPublishMode.task) {
      if (_budgetType != _baselineBudgetType) return true;
      if (_budgetController.text != _baselineBudgetText) return true;
      if (_addressController.text != _baselineAddressText) return true;
    } else {
      if (_pricingType != _baselinePricingType) return true;
      if (_priceController.text != _baselinePriceText) return true;
      if (_minDurationMinutes != _baselineMinDurationMinutes) return true;
      if (_isEditingOffer) {
        if (_offerPhotosFingerprint(_orderedOfferPhotos) !=
            _baselineOfferPhotosFingerprint) {
          return true;
        }
      } else {
        if (!_listsEqual(_selectedPhotos, _baselineSelectedPhotos)) return true;
        if (_primaryPhotoIndex != _baselinePrimaryPhotoIndex) return true;
      }
    }
    return false;
  }

  List<String> _computeChangedGigFieldLabels() {
    final changed = <String>[];

    void addLabel(String key, {required String fallback}) {
      var label = L10n.get(key, fallback: fallback).trim();
      label = label.replaceAll(RegExp(r":\s*$"), "").trim();
      changed.add(label.isEmpty ? fallback : label);
    }

    if (_mode != _baselineMode) {
      addLabel("gigs_publish_screen_title", fallback: "Publication");
    }
    if (_selectedCategory?.id != _baselineCategoryId) {
      addLabel("gigs_post_request_field_category", fallback: "Category");
    }
    if (_titleController.text != _baselineTitle) {
      addLabel("gigs_post_request_field_title", fallback: "Title");
    }
    if (_descriptionController.text != _baselineDescription) {
      addLabel("gigs_post_request_field_description", fallback: "Description");
    }
    if (_isRemote != _baselineRemote) {
      addLabel("gigs_post_request_field_remote", fallback: "Remote");
    }

    if (_mode == GigPublishMode.task) {
      if (_budgetType != _baselineBudgetType) {
        addLabel(
          "gigs_post_request_field_budget_type",
          fallback: "Budget type",
        );
      }
      if (_budgetController.text != _baselineBudgetText ||
          _currency != _baselineCurrency) {
        addLabel("gigs_post_request_field_amount", fallback: "Budget");
      }
      if (_addressController.text != _baselineAddressText) {
        addLabel("gigs_post_request_field_address", fallback: "Address");
      }
    } else {
      if (_pricingType != _baselinePricingType) {
        addLabel(
          "gigs_post_offer_field_pricing_type",
          fallback: "Pricing type",
        );
      }
      if (_priceController.text != _baselinePriceText ||
          _currency != _baselineCurrency) {
        addLabel("gigs_post_offer_field_price", fallback: "Price");
      }
      if (_minDurationMinutes != _baselineMinDurationMinutes) {
        addLabel(
          "gigs_post_offer_field_min_duration",
          fallback: "Minimum duration",
        );
      }
      if (_isEditingOffer) {
        if (_offerPhotosFingerprint(_orderedOfferPhotos) !=
            _baselineOfferPhotosFingerprint) {
          addLabel("listing_photos_label", fallback: "Photos");
        }
      } else {
        if (!_listsEqual(_selectedPhotos, _baselineSelectedPhotos) ||
            _primaryPhotoIndex != _baselinePrimaryPhotoIndex) {
          addLabel("listing_photos_label", fallback: "Photos");
        }
      }
    }

    return changed;
  }

  Future<void> _onPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;
    final leave = await UnsavedChangesDialog.show(
      context,
      changedFieldLabels: _computeChangedGigFieldLabels(),
    );
    if (!mounted || !leave) return;
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormTextChangedForChrome);
    _descriptionController.removeListener(_onFormTextChangedForChrome);
    _budgetController.removeListener(_onFormTextChangedForChrome);
    _addressController.removeListener(_onFormTextChangedForChrome);
    _priceController.removeListener(_onFormTextChangedForChrome);
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _setMode(GigPublishMode next) {
    if (_isEditingOffer || _isEditingRequest) {
      return;
    }
    if (next == _mode) return;
    _mutateForm(() {
      _mode = next;
      // A category selected for one flavor is meaningful for the other
      // (same [GigCategoryCache] source), so we keep it. We do clear the
      // category-missing error indicator though; it'll be re-set on next
      // submit if still missing.
      _showCategoryError = false;
      // Mode swap may move the relevant amount field (budget ↔ price), so
      // drop any stale error indicator until the user re-submits.
      _showAmountError = false;
    });
  }

  bool _isAmountMissing() {
    final String text;
    if (_mode == GigPublishMode.task) {
      if (_budgetType == GigRequestBudgetType.open) return false;
      text = _budgetController.text.trim();
    } else {
      text = _priceController.text.trim();
    }
    if (text.isEmpty) return true;
    final n = IntFormatUtils.parseAmountInput(text);
    return n == null || n <= 0;
  }

  void _submit() {
    final titleMissing = _titleController.text.trim().isEmpty;
    final categoryMissing = _selectedCategory == null;
    final amountMissing = _isAmountMissing();

    if (titleMissing != _showTitleError ||
        categoryMissing != _showCategoryError ||
        amountMissing != _showAmountError) {
      _mutateForm(() {
        _showTitleError = titleMissing;
        _showCategoryError = categoryMissing;
        _showAmountError = amountMissing;
      });
    }
    if (titleMissing || categoryMissing || amountMissing) return;

    final desc = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    if (_mode == GigPublishMode.task) {
      final budget =
          IntFormatUtils.parseAmountInput(_budgetController.text.trim());
      final addr = _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim();
      final editingTask = widget.editingRequest;
      if (editingTask != null) {
        context.read<GigPostRequestBloc>().add(
              SubmitGigRequestEdit(
                requestId: editingTask.id,
                categoryId: _selectedCategory!.id,
                title: _titleController.text.trim(),
                budgetType: _budgetType,
                budgetAmount: budget,
                currencyCode: _currency,
                descriptionRu: desc,
                addressText: addr,
                isRemote: _isRemote,
              ),
            );
      } else {
        context.read<GigPostRequestBloc>().add(
              SubmitGigRequest(
                categoryId: _selectedCategory!.id,
                title: _titleController.text.trim(),
                budgetType: _budgetType,
                budgetAmount: budget,
                currencyCode: _currency,
                descriptionRu: desc,
                addressText: addr,
                isRemote: _isRemote,
              ),
            );
      }
    } else {
      final price =
          IntFormatUtils.parseAmountInput(_priceController.text.trim());
      if (price == null) return;
      final editing = widget.editingOffer;
      if (editing != null) {
        final slots = <GigOfferEditPhotoSlot>[
          for (final item in _orderedOfferPhotos)
            if (item is ExistingPhotoItem)
              GigOfferEditPhotoExisting(item.photo.id)
            else if (item is NewPhotoItem)
              GigOfferEditPhotoNew(item.path),
        ];
        context.read<GigPostOfferBloc>().add(
              SubmitGigOfferEdit(
                offerId: editing.id,
                categoryId: _selectedCategory!.id,
                title: _titleController.text.trim(),
                pricingType: _pricingType,
                price: price,
                currencyCode: _currency,
                descriptionRu: desc,
                minDurationMinutes: _pricingType == GigPricingType.hourly
                    ? _minDurationMinutes
                    : null,
                isRemote: _isRemote,
                photoSlots: slots,
                photoOrderDirty: _photoOrderDirty,
              ),
            );
      } else {
        context.read<GigPostOfferBloc>().add(
              SubmitGigOffer(
                categoryId: _selectedCategory!.id,
                title: _titleController.text.trim(),
                pricingType: _pricingType,
                price: price,
                currencyCode: _currency,
                descriptionRu: desc,
                // Min-duration only meaningful for hourly pricing — drop it
                // otherwise so we don't ship a misleading value to the API.
                minDurationMinutes: _pricingType == GigPricingType.hourly
                    ? _minDurationMinutes
                    : null,
                isRemote: _isRemote,
                photoPaths: List<String>.unmodifiable(_selectedPhotos),
                primaryPhotoIndex: _primaryPhotoIndex,
              ),
            );
      }
    }
  }

  /// Pulsing save in the app bar while submitting, matching [EditListingScreen].
  Widget _buildEditGigAppBarTrailingAction(
    ThemeData theme, {
    required bool submitting,
  }) {
    final foregroundColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

    if (submitting) {
      return IconButton(
        onPressed: null,
        icon: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
        tooltip: L10n.get("save_changes"),
      );
    }

    return _PulsingSaveButton(
      onPressed: () {
        HapticFeedbackUtils.impact();
        _submit();
      },
      tooltip: L10n.get("save_changes"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    return PopScope(
      canPop: _allowPopWithoutConfirm || !_isFormDirty(),
      onPopInvokedWithResult: _onPopInvoked,
      child: BlocBuilder<GigPostRequestBloc, GigPostRequestState>(
        buildWhen: _shouldRebuildGigPostRequestUI,
        builder: (context, requestState) {
          return BlocBuilder<GigPostOfferBloc, GigPostOfferState>(
            buildWhen: _shouldRebuildGigPostOfferUI,
            builder: (context, offerState) {
              final theme = Theme.of(context);

              // Both blocs are seeded from the same [GigCategoryCache], so
              // the picker can read either one — but we still pull from
              // whichever matches the current mode in case future cache
              // semantics diverge per-flavor (e.g. service-only categories).
              final List<GigCategory> categories;
              if (_mode == GigPublishMode.task) {
                final idle =
                    requestState is GigPostRequestIdle ? requestState : null;
                categories = idle?.categories ?? const <GigCategory>[];
              } else {
                final idle = offerState is GigPostOfferIdle ? offerState : null;
                categories = idle?.categories ?? const <GigCategory>[];
              }

              final submitting = (_mode == GigPublishMode.task &&
                      requestState is GigPostRequestSubmitting) ||
                  (_mode == GigPublishMode.service &&
                      offerState is GigPostOfferSubmitting);

              final isEditMode = _isEditingOffer || _isEditingRequest;
              final showAppBarSave =
                  isEditMode && (submitting || _isFormDirty());

              Color? dirtyOutline(bool fieldChanged) =>
                  isEditMode && fieldChanged
                      ? formDirtyFieldOutlineColor(context)
                      : null;

              final submitLabel = isEditMode
                  ? L10n.get("gigs_edit_offer_submit")
                  : (_mode == GigPublishMode.task
                      ? L10n.get("gigs_post_request_submit")
                      : L10n.get("gigs_post_offer_submit"));
              const submitTextStyle = TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              );

              return Scaffold(
                appBar: AppBar(
                  leading: ThreeDAppBarIconButton.backLeading(
                    context,
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                  title: Text(
                    _isEditingOffer
                        ? L10n.get("gigs_edit_offer_title")
                        : _isEditingRequest
                            ? L10n.get("gigs_edit_request_title")
                            : L10n.get("gigs_publish_screen_title"),
                  ),
                  actions: [
                    if (showAppBarSave)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: _buildEditGigAppBarTrailingAction(
                          theme,
                          submitting: submitting,
                        ),
                      ),
                  ],
                ),
                // Two listeners — one per bloc — handle the success/error toasts.
                body: KeyboardDismissScope(
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<GigPostRequestBloc, GigPostRequestState>(
                        listener: (context, state) {
                          if (state is GigPostRequestSuccess) {
                            ToastTheme.showSuccess(
                              context,
                              message: L10n.get(
                                "gigs_post_request_success_toast",
                              ),
                            );
                            _allowPopWithoutConfirm = true;
                            Navigator.of(context).pop();
                          } else if (state is GigRequestEditSuccess) {
                            ToastTheme.showSuccess(
                              context,
                              message: L10n.get(
                                "gigs_edit_request_success_toast",
                              ),
                            );
                            _allowPopWithoutConfirm = true;
                            Navigator.of(context)
                                .pop<GigRequest>(state.updated);
                          } else if (state is GigPostRequestError) {
                            ToastTheme.showError(
                              context,
                              message: state.message,
                            );
                          }
                        },
                      ),
                      BlocListener<GigPostOfferBloc, GigPostOfferState>(
                        listener: (context, state) {
                          if (state is GigPostOfferSuccess) {
                            ToastTheme.showSuccess(
                              context,
                              message:
                                  L10n.get("gigs_post_offer_success_toast"),
                            );
                            _allowPopWithoutConfirm = true;
                            Navigator.of(context).pop();
                          } else if (state is GigOfferEditSuccess) {
                            ToastTheme.showSuccess(
                              context,
                              message:
                                  L10n.get("gigs_edit_offer_success_toast"),
                            );
                            _allowPopWithoutConfirm = true;
                            Navigator.of(context).pop<GigOffer>(state.updated);
                          } else if (state is GigPostOfferError) {
                            ToastTheme.showError(
                              context,
                              message: state.message,
                            );
                          }
                        },
                      ),
                    ],
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        keyboardDismissBehavior:
                            KeyboardDismissScope.scrollBehavior,
                        children: [
                          if (!_isEditingOffer && !_isEditingRequest) ...[
                            _PublishModeToggle(
                              value: _mode,
                              onChanged: _setMode,
                            ),
                            const SizedBox(height: 22),
                          ],
                          _FieldLabel(
                            L10n.get("gigs_post_request_field_category"),
                          ),
                          _CategoryPlate(
                            categories: categories,
                            selected: _selectedCategory,
                            language: language,
                            showError: _showCategoryError,
                            dirtyOutlineColor: dirtyOutline(
                              _selectedCategory?.id != _baselineCategoryId,
                            ),
                            onChanged: (c) {
                              _mutateForm(() {
                                _selectedCategory = c;
                                if (c != null) _showCategoryError = false;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _FieldLabel(
                            L10n.get("gigs_post_request_field_title"),
                          ),
                          _PlateField(
                            showErrorBorder: _showTitleError,
                            dirtyOutlineColor: dirtyOutline(
                              _titleController.text != _baselineTitle,
                            ),
                            child: TextFormField(
                              controller: _titleController,
                              textInputAction: TextInputAction.next,
                              maxLength: _titleMaxLength,
                              maxLines: 1,
                              style: _fieldTextStyle(context),
                              decoration: _plateInputDecoration(
                                context,
                                hint: L10n.get("gigs_post_request_field_title"),
                              ),
                              onChanged: (_) {
                                if (_showTitleError) {
                                  _mutateForm(() => _showTitleError = false);
                                }
                              },
                              buildCounter: (
                                context, {
                                required currentLength,
                                required isFocused,
                                maxLength,
                              }) =>
                                  _buildSubtleCounter(
                                context,
                                currentLength: currentLength,
                                maxLength: maxLength ?? _titleMaxLength,
                                visibleAt: _titleCounterVisibleAt,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FieldLabel(
                            L10n.get("gigs_post_request_field_description"),
                          ),
                          _PlateField(
                            dirtyOutlineColor: dirtyOutline(
                              _descriptionController.text !=
                                  _baselineDescription,
                            ),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 320),
                              reverseDuration:
                                  const Duration(milliseconds: 320),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              clipBehavior: Clip.hardEdge,
                              child: TextFormField(
                                controller: _descriptionController,
                                minLines: _descriptionBaseLines +
                                    (_isDescriptionExpanded
                                        ? _descriptionExpandedExtraLines
                                        : 0),
                                maxLines: _descriptionBaseLines +
                                    (_isDescriptionExpanded
                                        ? _descriptionExpandedExtraLines
                                        : 0),
                                maxLength: _descriptionMaxLength,
                                style: _descriptionTextStyle(context),
                                decoration: _descriptionInputDecoration(
                                  context,
                                  hint: L10n.get(
                                    "gigs_post_request_field_description",
                                  ),
                                ),
                                buildCounter: (
                                  context, {
                                  required currentLength,
                                  required isFocused,
                                  maxLength,
                                }) {
                                  return _GigDescriptionToolbar(
                                    controller: _descriptionController,
                                    isOffer: _mode == GigPublishMode.service,
                                    currentLength: currentLength,
                                    maxLength:
                                        maxLength ?? _descriptionMaxLength,
                                    visibleAt: _descriptionCounterVisibleAt,
                                    isExpanded: _isDescriptionExpanded,
                                    onToggleExpanded: () => _mutateForm(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    }),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (_mode == GigPublishMode.task)
                            ..._buildTaskFields(dirtyOutline)
                          else
                            ..._buildServiceFields(dirtyOutline),
                          const SizedBox(height: 24),
                          if (_isEditingOffer || _isEditingRequest)
                            PrimaryButtonFactory.iconTextCentered(
                              onPressed: submitting ? null : _submit,
                              isLoading: submitting,
                              height: 54,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(16),
                              icon: Icons.save_outlined,
                              text: submitLabel,
                              textStyle: submitTextStyle,
                            )
                          else
                            PrimaryButtonFactory.iconTextCentered(
                              onPressed: submitting ? null : _submit,
                              isLoading: submitting,
                              height: 54,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(16),
                              icon: Icons.add_rounded,
                              text: submitLabel,
                              textStyle: submitTextStyle,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildTaskFields(Color? Function(bool) dirtyOutline) {
    return [
      _FieldLabel(L10n.get("gigs_post_request_field_budget_type")),
      _BudgetTypePlate(
        value: _budgetType,
        onChanged: (v) => _mutateForm(() => _budgetType = v),
        dirtyOutlineColor: dirtyOutline(_budgetType != _baselineBudgetType),
      ),
      const SizedBox(height: 14),
      // Budget amount + Remote toggle share one row (60/40 flex). When the user
      // picks "open budget" there's no amount input, so the remote toggle
      // takes the full width on its own to keep the layout balanced.
      if (_budgetType != GigRequestBudgetType.open)
        _AmountAndRemoteRow(
          amountLabel: L10n.get("gigs_post_request_field_amount"),
          remoteLabel: L10n.get("gigs_post_request_field_remote"),
          amountField: _CurrencyAmountField(
            controller: _budgetController,
            currency: _currency,
            supportedCurrencies: _supportedCurrencies,
            onCurrencyChanged: (c) => _mutateForm(() => _currency = c),
            hint: "0",
            showError: _showAmountError,
            dirtyOutlineColor: dirtyOutline(
              _budgetController.text != _baselineBudgetText ||
                  _currency != _baselineCurrency,
            ),
            onChanged: (_) {
              if (_showAmountError) {
                _mutateForm(() => _showAmountError = false);
              }
            },
          ),
          isRemote: _isRemote,
          onRemoteChanged: (v) => _mutateForm(() => _isRemote = v),
          remoteDirtyOutlineColor: dirtyOutline(_isRemote != _baselineRemote),
        )
      else
        _RemoteTogglePlate(
          value: _isRemote,
          label: L10n.get("gigs_post_request_field_remote"),
          onChanged: (v) => _mutateForm(() => _isRemote = v),
          dirtyOutlineColor: dirtyOutline(_isRemote != _baselineRemote),
        ),
      const SizedBox(height: 14),
      _FieldLabel(L10n.get("gigs_post_request_field_address")),
      _PlateField(
        dirtyOutlineColor: dirtyOutline(
          _addressController.text != _baselineAddressText,
        ),
        child: TextFormField(
          controller: _addressController,
          style: _fieldTextStyle(context),
          decoration: _plateInputDecoration(
            context,
            hint: L10n.get("gigs_post_request_field_address"),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildServiceFields(Color? Function(bool) dirtyOutline) {
    final servicePhotosChanged = _isEditingOffer
        ? _offerPhotosFingerprint(_orderedOfferPhotos) !=
            _baselineOfferPhotosFingerprint
        : !_listsEqual(_selectedPhotos, _baselineSelectedPhotos) ||
            _primaryPhotoIndex != _baselinePrimaryPhotoIndex;

    final photosChrome = dirtyOutline(servicePhotosChanged);
    final photoUploader = PhotoUploader(
      selectedPhotos: _selectedPhotos,
      onPhotosChanged: (photos) {
        _mutateForm(() {
          _selectedPhotos = photos;
          if (photos.isNotEmpty && _primaryPhotoIndex == null) {
            _primaryPhotoIndex = 0;
          } else if (photos.isEmpty) {
            _primaryPhotoIndex = null;
          }
          if (_isEditingOffer) {
            _rebuildOfferOrderedPhotos();
            _photoOrderDirty = true;
          }
        });
      },
      existingPhotos: _isEditingOffer ? _existingOfferPhotos : const <Photo>[],
      onDeleteExistingPhoto:
          _isEditingOffer ? _deleteExistingOfferPhoto : (_) {},
      onMakePhotoPrimary: (_) {},
      onMakeNewPhotoPrimary: _isEditingOffer
          ? null
          : (i) => _mutateForm(() => _primaryPhotoIndex = i),
      deletingPhotoIds:
          _isEditingOffer ? _deletingOfferPhotoIds : const <int>{},
      makingPhotoPrimaryIds:
          _isEditingOffer ? _makingOfferPhotoPrimaryIds : const <int>{},
      maxPhotos: AppConfig.maxPhotosPerGigOffer,
      orderedItems: _isEditingOffer
          ? _orderedOfferPhotos
          : [
              for (final path in _selectedPhotos) NewPhotoItem(path),
            ],
      onReorderItems: _isEditingOffer
          ? (newOrder) {
              _mutateForm(() {
                _orderedOfferPhotos = newOrder;
                _selectedPhotos = [
                  for (final item in newOrder)
                    if (item is NewPhotoItem) item.path,
                ];
                _primaryPhotoIndex = _selectedPhotos.isEmpty ? null : 0;
                _photoOrderDirty = true;
              });
            }
          : (newOrder) {
              _mutateForm(() {
                _selectedPhotos = [
                  for (final item in newOrder)
                    if (item is NewPhotoItem) item.path,
                ];
                _primaryPhotoIndex = _selectedPhotos.isEmpty ? null : 0;
              });
            },
    );

    return [
      _FieldLabel(L10n.get("gigs_post_offer_field_pricing_type")),
      _PricingTypePlate(
        value: _pricingType,
        onChanged: (v) => _mutateForm(() => _pricingType = v),
        dirtyOutlineColor: dirtyOutline(_pricingType != _baselinePricingType),
      ),
      const SizedBox(height: 14),
      // Price + Remote toggle share one row (60/40 flex for digit width).
      _AmountAndRemoteRow(
        amountLabel: L10n.get("gigs_post_offer_field_price"),
        remoteLabel: L10n.get("gigs_post_request_field_remote"),
        amountField: _CurrencyAmountField(
          controller: _priceController,
          currency: _currency,
          supportedCurrencies: _supportedCurrencies,
          onCurrencyChanged: (c) => _mutateForm(() => _currency = c),
          hint: "0",
          showError: _showAmountError,
          dirtyOutlineColor: dirtyOutline(
            _priceController.text != _baselinePriceText ||
                _currency != _baselineCurrency,
          ),
          onChanged: (_) {
            if (_showAmountError) {
              _mutateForm(() => _showAmountError = false);
            }
          },
        ),
        isRemote: _isRemote,
        onRemoteChanged: (v) => _mutateForm(() => _isRemote = v),
        remoteDirtyOutlineColor: dirtyOutline(_isRemote != _baselineRemote),
      ),
      if (_pricingType == GigPricingType.hourly) ...[
        const SizedBox(height: 14),
        _FieldLabel(L10n.get("gigs_post_offer_field_min_duration")),
        _PlateField(
          dirtyOutlineColor: dirtyOutline(
            _minDurationMinutes != _baselineMinDurationMinutes,
          ),
          child: _MinDurationMinuteSpinner(
            minutes: _minDurationMinutes,
            onChanged: (v) => _mutateForm(() => _minDurationMinutes = v),
            textStyle: _fieldTextStyle(context),
          ),
        ),
      ],
      const SizedBox(height: 14),
      // Same uploader as create/edit listing: pick, delete, drag to reorder.
      // Edit-offer hydrates existing [Photo] rows and deletes sync to the API
      // immediately; add/reorder run on Save (mirrors edit-listing semantics).
      if (photosChrome != null)
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ThreeDSurfaceStyle.wheelPickerCornerRadius,
            ),
            border: Border.all(color: photosChrome, width: 1.5),
          ),
          child: photoUploader,
        )
      else
        photoUploader,
    ];
  }

  void _rebuildOfferOrderedPhotos() {
    if (!_isEditingOffer) return;
    final prev = _orderedOfferPhotos;
    final prevKeys = prev.map((e) => e.stableKey).toList();

    final fresh = <PhotoItem>[];
    final primaryIndex = _existingOfferPhotos.indexWhere((p) => p.isPrimary);
    if (primaryIndex > 0) {
      fresh.add(ExistingPhotoItem(_existingOfferPhotos[primaryIndex]));
      for (var i = 0; i < _existingOfferPhotos.length; i++) {
        if (i == primaryIndex) continue;
        fresh.add(ExistingPhotoItem(_existingOfferPhotos[i]));
      }
    } else {
      for (final p in _existingOfferPhotos) {
        fresh.add(ExistingPhotoItem(p));
      }
    }
    for (final path in _selectedPhotos) {
      fresh.add(NewPhotoItem(path));
    }

    if (prevKeys.isEmpty) {
      _orderedOfferPhotos = fresh;
      return;
    }

    final freshByKey = {for (final item in fresh) item.stableKey: item};
    final merged = <PhotoItem>[];
    final used = <String>{};
    for (final key in prevKeys) {
      final item = freshByKey[key];
      if (item != null) {
        merged.add(item);
        used.add(key);
      }
    }
    for (final item in fresh) {
      if (!used.contains(item.stableKey)) {
        merged.add(item);
      }
    }
    _orderedOfferPhotos = merged;
  }

  Future<void> _deleteExistingOfferPhoto(int index) async {
    final offer = widget.editingOffer;
    if (offer == null) return;
    final photo = _existingOfferPhotos[index];

    final shouldDelete = await CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "delete_photo",
      messageKey: "delete_photo_confirmation",
    );

    if (shouldDelete ?? false) {
      try {
        _mutateForm(() {
          _deletingOfferPhotoIds.add(photo.id);
        });

        await getIt<IGigService>().deleteOfferPhoto(
          offerId: offer.id,
          photoId: photo.id,
        );

        final wasPrimary = photo.isPrimary;
        final remainingAfter = _existingOfferPhotos.length - 1;

        _mutateForm(() {
          _existingOfferPhotos.removeAt(index);
          _deletingOfferPhotoIds.remove(photo.id);
          if (wasPrimary && remainingAfter > 0) {
            _existingOfferPhotos[0] =
                _existingOfferPhotos[0].copyWith(isPrimary: true);
            for (var i = 1; i < _existingOfferPhotos.length; i++) {
              _existingOfferPhotos[i] =
                  _existingOfferPhotos[i].copyWith(isPrimary: false);
            }
          }
          _rebuildOfferOrderedPhotos();
        });

        if (remainingAfter == 0) {
          ToastTheme.showSuccess(
            context,
            message: L10n.get("last_photo_deleted"),
          );
        } else {
          ToastTheme.showSuccess(
            context,
            message: L10n.get("photo_deleted_success"),
          );
        }
      } catch (e) {
        _mutateForm(() {
          _deletingOfferPhotoIds.remove(photo.id);
        });
        ToastTheme.showError(
          context,
          message: L10n.get("error_deleting_photo"),
        );
      }
    }
  }
}

class _PublishModeToggle extends StatelessWidget {
  const _PublishModeToggle({required this.value, required this.onChanged});

  final GigPublishMode value;
  final ValueChanged<GigPublishMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return NeumorphicSegmentedSwitch<GigPublishMode>(
      value: value,
      height: 135 * 60 / 145,
      onChanged: onChanged,
      entries: [
        SegmentedSwitchEntry(
          value: GigPublishMode.service,
          label: L10n.get("gigs_publish_mode_service"),
          subtitle: L10n.get("gigs_publish_mode_service_subtitle"),
          icon: Icons.handyman_outlined,
        ),
        SegmentedSwitchEntry(
          value: GigPublishMode.task,
          label: L10n.get("gigs_publish_mode_task"),
          subtitle: L10n.get("gigs_publish_mode_task_subtitle"),
          icon: Icons.assignment_outlined,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared styling helpers — these mirror the file-private helpers in the
// legacy `post_gig_request_screen.dart` / `post_gig_offer_screen.dart`.
// Kept duplicated for now to keep this change contained; promote to a
// shared `gig_form_widgets.dart` once the legacy screens are retired.
// ---------------------------------------------------------------------------

/// Subtle "currentLength/maxLength" badge — hidden until the user is close
/// to the cap, then shown in muted text (red once at the limit). Mirrors
/// the counter style used by the create/edit listing screens.
Widget? _buildSubtleCounter(
  BuildContext context, {
  required int currentLength,
  required int maxLength,
  required int visibleAt,
}) {
  if (currentLength < visibleAt) return null;
  final isAtLimit = currentLength >= maxLength;
  final theme = Theme.of(context);
  final color = isAtLimit
      ? theme.colorScheme.error
      : (ThemeState().isLightTheme
          ? Colors.grey[700]
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8));
  return Padding(
    padding: const EdgeInsets.only(top: 4, right: 4),
    child: Text(
      "$currentLength/$maxLength",
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    ),
  );
}

TextStyle _fieldTextStyle(BuildContext context) {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeState().isLightTheme
        ? Colors.black
        : Theme.of(context).colorScheme.onSurface,
  );
}

/// Description-only text style — mirrors `create_listing_screen.dart` so the
/// gig description field paints the same color as the listing one.
TextStyle _descriptionTextStyle(BuildContext context) {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeState().isLightTheme
        ? Colors.black
        : Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// Description-only [InputDecoration] — mirrors `create_listing_screen.dart`
/// so the gig description plate has the same internal padding, hint color,
/// and (lack of) `isDense` as the listing one. Other gig fields keep the
/// regular [_plateInputDecoration].
InputDecoration _descriptionInputDecoration(
  BuildContext context, {
  String? hint,
}) {
  final cleanedHint = hint?.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  return InputDecoration(
    hintText: cleanedHint,
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7)
          : Colors.grey[400],
    ),
    border: OutlineInputBorder(
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      borderSide: BorderSide.none,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
  );
}

InputDecoration _plateInputDecoration(BuildContext context, {String? hint}) {
  final hintColor = Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)
      : Colors.grey[500];
  final cleanedHint = hint?.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  return InputDecoration(
    hintText: cleanedHint,
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: hintColor,
    ),
    filled: true,
    fillColor: Colors.transparent,
    border: const OutlineInputBorder(borderSide: BorderSide.none),
    enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    // Validation feedback is rendered as a red border on the surrounding
    // plate (see `_PlateField.showErrorBorder`); collapse the inline error
    // text so no red copy ever appears beneath the field.
    errorStyle: const TextStyle(height: 0, fontSize: 0),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    isDense: true,
  );
}

/// Tighter horizontal padding for the gig price / budget amount digits so
/// long UZS values (with thousand separators) fit without growing the row.
InputDecoration _currencyAmountInputDecoration(
  BuildContext context, {
  String? hint,
}) {
  return _plateInputDecoration(context, hint: hint).copyWith(
    contentPadding: const EdgeInsets.fromLTRB(8, 14, 10, 14),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6, top: 2),
      child: Text(
        text.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _PlateField extends StatelessWidget {
  const _PlateField({
    required this.child,
    this.showErrorBorder = false,
    this.dirtyOutlineColor,
  });
  final Widget child;
  final bool showErrorBorder;
  final Color? dirtyOutlineColor;

  @override
  Widget build(BuildContext context) {
    return WheelPickerPlateContainer(
      theme: Theme.of(context),
      showErrorBorder: showErrorBorder,
      dirtyOutlineColor: showErrorBorder ? null : dirtyOutlineColor,
      child: child,
    );
  }
}

/// Stepper for hourly offers: changes in five-minute increments between
/// [_gigMinDurationFloorMinutes] and [_gigMinDurationCeilingMinutes].
class _MinDurationMinuteSpinner extends StatelessWidget {
  const _MinDurationMinuteSpinner({
    required this.minutes,
    required this.onChanged,
    required this.textStyle,
  });

  final int minutes;
  final ValueChanged<int> onChanged;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = scheme.onSurface;
    final canDecrease = minutes > _gigMinDurationFloorMinutes;
    final canIncrease = minutes < _gigMinDurationCeilingMinutes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          IconButton(
            onPressed: canDecrease
                ? () {
                    UiFeedbackUtils.selection();
                    onChanged(
                      (minutes - _gigMinDurationStepMinutes).clamp(
                        _gigMinDurationFloorMinutes,
                        _gigMinDurationCeilingMinutes,
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.remove_circle_outline, color: iconColor),
          ),
          Expanded(
            child: Text(
              "$minutes",
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          IconButton(
            onPressed: canIncrease
                ? () {
                    UiFeedbackUtils.selection();
                    onChanged(
                      (minutes + _gigMinDurationStepMinutes).clamp(
                        _gigMinDurationFloorMinutes,
                        _gigMinDurationCeilingMinutes,
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.add_circle_outline, color: iconColor),
          ),
        ],
      ),
    );
  }
}

/// Numeric input plate with a tappable currency code on the leading edge.
///
/// The chip shows the active code (e.g. "UZS") without the flag — flags stay
/// in the picker sheet — so more width remains for the numeric field. A
/// vertical hairline divider separates the chip from the typed amount.
class _CurrencyAmountField extends StatelessWidget {
  const _CurrencyAmountField({
    required this.controller,
    required this.currency,
    required this.supportedCurrencies,
    required this.onCurrencyChanged,
    this.hint,
    this.showError = false,
    this.dirtyOutlineColor,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currency;
  final List<String> supportedCurrencies;
  final ValueChanged<String> onCurrencyChanged;
  final String? hint;
  final bool showError;
  final Color? dirtyOutlineColor;
  final ValueChanged<String>? onChanged;

  Future<void> _pickCurrency(BuildContext context) async {
    UiFeedbackUtils.selection();
    final picked = await showAppBottomSheet<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        const radius = BorderRadius.vertical(top: Radius.circular(20));
        return GlassBottomSheetSurface(
          borderRadius: radius,
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: supportedCurrencies.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: scheme.onSurface.withValues(alpha: 0.08),
                      ),
                      itemBuilder: (_, i) {
                        final code = supportedCurrencies[i];
                        final isSelected = code == currency;
                        return ListTile(
                          leading: Text(
                            CurrencyDisplayUtils.flagEmoji(code),
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            code,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: scheme.secondary,
                                )
                              : null,
                          onTap: () => Navigator.of(sheetCtx).pop(code),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (picked != null && picked != currency) {
      onCurrencyChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dividerColor = scheme.onSurface.withValues(alpha: 0.18);
    final chipColor =
        ThemeState().isLightTheme ? Colors.black : scheme.onSurface;

    return _PlateField(
      showErrorBorder: showError,
      dirtyOutlineColor: showError ? null : dirtyOutlineColor,
      child: Row(
        children: [
          InkWell(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            onTap: () => _pickCurrency(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: chipColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: chipColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 24, color: dividerColor),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [DotThousandsDigitsInputFormatter()],
              style: _fieldTextStyle(context),
              decoration: _currencyAmountInputDecoration(context, hint: hint),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPlate extends StatelessWidget {
  const _CategoryPlate({
    required this.categories,
    required this.selected,
    required this.language,
    required this.onChanged,
    required this.showError,
    this.dirtyOutlineColor,
  });

  final List<GigCategory> categories;
  final GigCategory? selected;
  final String language;
  final ValueChanged<GigCategory?> onChanged;
  final bool showError;
  final Color? dirtyOutlineColor;

  Future<void> _pick(BuildContext context) async {
    if (categories.isEmpty) return;
    final picked = await showAppBottomSheet<GigCategory>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        const radius = BorderRadius.vertical(top: Radius.circular(20));
        return GlassBottomSheetSurface(
          borderRadius: radius,
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: scheme.onSurface.withValues(alpha: 0.08),
                      ),
                      itemBuilder: (_, i) {
                        final c = categories[i];
                        final isSelected = c.id == selected?.id;
                        return ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: scheme.secondary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:
                                Icon(c.icon, color: scheme.secondary, size: 20),
                          ),
                          title: Text(
                            c.localizedName(language),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_rounded,
                                  color: scheme.secondary)
                              : null,
                          onTap: () => Navigator.of(sheetCtx).pop(c),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hintColor = Theme.of(context).brightness == Brightness.dark
        ? scheme.onSurface.withValues(alpha: 0.45)
        : Colors.grey[500];
    final hasValue = selected != null;
    final canTap = categories.isNotEmpty;
    final placeholder = L10n.get("gigs_post_request_field_category");

    return _PlateField(
      showErrorBorder: showError,
      dirtyOutlineColor: showError ? null : dirtyOutlineColor,
      child: InkWell(
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        onTap: canTap ? () => _pick(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              if (hasValue) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    selected!.icon,
                    color: scheme.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  hasValue ? selected!.localizedName(language) : placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? (ThemeState().isLightTheme
                            ? Colors.black
                            : scheme.onSurface)
                        : hintColor,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetTypePlate extends StatelessWidget {
  const _BudgetTypePlate({
    required this.value,
    required this.onChanged,
    this.dirtyOutlineColor,
  });
  final GigRequestBudgetType value;
  final ValueChanged<GigRequestBudgetType> onChanged;
  final Color? dirtyOutlineColor;

  @override
  Widget build(BuildContext context) {
    Widget child = NeumorphicSegmentedSwitch<GigRequestBudgetType>(
      value: value,
      onChanged: onChanged,
      entries: [
        SegmentedSwitchEntry(
          value: GigRequestBudgetType.fixed,
          label: L10n.get("gigs_budget_type_fixed"),
          icon: Icons.price_change_outlined,
        ),
        SegmentedSwitchEntry(
          value: GigRequestBudgetType.hourly,
          label: L10n.get("gigs_budget_type_hourly"),
          icon: Icons.schedule_outlined,
        ),
        SegmentedSwitchEntry(
          value: GigRequestBudgetType.open,
          label: L10n.get("gigs_budget_type_open"),
          icon: Icons.gavel_outlined,
        ),
      ],
    );
    final outline = dirtyOutlineColor;
    if (outline != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outline, width: 1.5),
        ),
        child: child,
      );
    }
    return child;
  }
}

class _PricingTypePlate extends StatelessWidget {
  const _PricingTypePlate({
    required this.value,
    required this.onChanged,
    this.dirtyOutlineColor,
  });
  final GigPricingType value;
  final ValueChanged<GigPricingType> onChanged;
  final Color? dirtyOutlineColor;

  @override
  Widget build(BuildContext context) {
    Widget child = NeumorphicSegmentedSwitch<GigPricingType>(
      value: value,
      onChanged: onChanged,
      entries: [
        SegmentedSwitchEntry(
          value: GigPricingType.fixed,
          label: L10n.get("gigs_pricing_type_fixed"),
          icon: Icons.price_change_outlined,
        ),
        SegmentedSwitchEntry(
          value: GigPricingType.hourly,
          label: L10n.get("gigs_pricing_type_hourly"),
          icon: Icons.schedule_outlined,
        ),
        SegmentedSwitchEntry(
          value: GigPricingType.perUnit,
          label: L10n.get("gigs_pricing_type_per_unit"),
          icon: Icons.straighten_outlined,
        ),
      ],
    );
    final outline = dirtyOutlineColor;
    if (outline != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outline, width: 1.5),
        ),
        child: child,
      );
    }
    return child;
  }
}

/// Side-by-side row: amount column gets extra horizontal flex so long UZS
/// amounts fit; remote toggle stays readable on the right.
/// Uses [CrossAxisAlignment.end] so the two plates line up at their bottom
/// edge — which is what the eye reads as "the same row" — even though the
/// left column has an extra `_FieldLabel` above the plate.
class _AmountAndRemoteRow extends StatelessWidget {
  const _AmountAndRemoteRow({
    required this.amountLabel,
    required this.remoteLabel,
    required this.amountField,
    required this.isRemote,
    required this.onRemoteChanged,
    this.remoteDirtyOutlineColor,
  });

  final String amountLabel;
  final String remoteLabel;
  final Widget amountField;
  final bool isRemote;
  final ValueChanged<bool> onRemoteChanged;
  final Color? remoteDirtyOutlineColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(amountLabel),
              amountField,
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 40,
          child: _RemoteTogglePlate(
            value: isRemote,
            label: remoteLabel,
            onChanged: onRemoteChanged,
            dirtyOutlineColor: remoteDirtyOutlineColor,
          ),
        ),
      ],
    );
  }
}

class _RemoteTogglePlate extends StatelessWidget {
  const _RemoteTogglePlate({
    required this.value,
    required this.label,
    required this.onChanged,
    this.dirtyOutlineColor,
  });
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final Color? dirtyOutlineColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PlateField(
      dirtyOutlineColor: dirtyOutlineColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            NeumorphicThemeAwareToggle(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// Counter-row used as `TextField.buildCounter` for the description field.
/// Shows the AI-enhance action on the left and a `currentLength/maxLength`
/// + expand chevron on the right. Mirrors the listing screens' affordance
/// — sans the "Template" button, which is housing-specific.
class _GigDescriptionToolbar extends StatelessWidget {
  const _GigDescriptionToolbar({
    required this.controller,
    required this.isOffer,
    required this.currentLength,
    required this.maxLength,
    required this.visibleAt,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  final TextEditingController controller;
  final bool isOffer;
  final int currentLength;
  final int maxLength;
  final int visibleAt;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  bool get _showCounterText {
    if (visibleAt <= 0) return true;
    if (maxLength <= 0) return true;
    return currentLength >= visibleAt;
  }

  Color _resolveCounterColor(BuildContext context) {
    final isAtLimit = maxLength > 0 && currentLength >= maxLength;
    if (isAtLimit) return Theme.of(context).colorScheme.error;
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveCounterColor(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListingDescriptionAiEnhanceButton(
            controller: controller,
            inlineWithCounter: true,
            canEnhance: () => GeminiConfig.isConfigured,
            enhance: (text) => getIt<GeminiService>()
                .enhanceGigDescription(text: text, isOffer: isOffer),
          ),
          const Spacer(),
          if (_showCounterText) ...[
            Text(
              "$currentLength/$maxLength",
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Semantics(
            button: true,
            label: isExpanded ? "Collapse description" : "Expand description",
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                UiFeedbackUtils.tap();
                onToggleExpanded();
              },
              child: SizedBox(
                width: 32,
                height: 28,
                child: Center(
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.expand_more,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Save icon that pulses gently — same behavior as [EditListingScreen]'s
/// trailing control; only mounted while the parent shows the action.
class _PulsingSaveButton extends StatefulWidget {
  const _PulsingSaveButton({required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<_PulsingSaveButton> createState() => _PulsingSaveButtonState();
}

class _PulsingSaveButtonState extends State<_PulsingSaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  final AnimationSettingsState _animSettings = AnimationSettingsState();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _opacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _animSettings.addListener(_syncRepeatPulse);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRepeatPulse();
  }

  void _syncRepeatPulse() {
    if (!mounted) return;
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final allow = _animSettings.uiAnimationsEnabled && !disableAnim;
    if (allow) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animSettings.removeListener(_syncRepeatPulse);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: IconButton(
        onPressed: widget.onPressed,
        icon: const ThemeIcon(Icons.save),
        tooltip: widget.tooltip,
      ),
    );
  }
}
