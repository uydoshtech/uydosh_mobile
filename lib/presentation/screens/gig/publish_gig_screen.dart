import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_offer_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_request_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/photo_item.dart";
import "package:uy_dosh/presentation/widgets/common/photo_uploader.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

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
  });

  final GigPublishMode initialMode;

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
  final _minDurationController = TextEditingController();
  GigPricingType _pricingType = GigPricingType.fixed;

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

  /// ISO-4217-ish code shown as the prefix on the budget/price input. Shared
  /// between task and service modes so a user who flips back and forth keeps
  /// their currency choice. Backend default is also "UZS", so the empty
  /// state matches what the API would record on its own.
  String _currency = "UZS";
  static const List<String> _supportedCurrencies = ["UZS", "USD"];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _minDurationController.dispose();
    super.dispose();
  }

  void _setMode(GigPublishMode next) {
    if (next == _mode) return;
    setState(() {
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
    final n = int.tryParse(text);
    return n == null || n <= 0;
  }

  void _submit() {
    final titleMissing = _titleController.text.trim().isEmpty;
    final categoryMissing = _selectedCategory == null;
    final amountMissing = _isAmountMissing();

    if (titleMissing != _showTitleError ||
        categoryMissing != _showCategoryError ||
        amountMissing != _showAmountError) {
      setState(() {
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
      final budget = _budgetController.text.trim().isEmpty
          ? null
          : int.tryParse(_budgetController.text.trim());
      context.read<GigPostRequestBloc>().add(
            SubmitGigRequest(
              categoryId: _selectedCategory!.id,
              title: _titleController.text.trim(),
              budgetType: _budgetType,
              budgetAmount: budget,
              currencyCode: _currency,
              descriptionRu: desc,
              addressText: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              isRemote: _isRemote,
            ),
          );
    } else {
      final price = int.tryParse(_priceController.text.trim());
      if (price == null) return;
      final minDuration = _minDurationController.text.trim().isEmpty
          ? null
          : int.tryParse(_minDurationController.text.trim());
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
              minDurationMinutes:
                  _pricingType == GigPricingType.hourly ? minDuration : null,
              isRemote: _isRemote,
              photoPaths: List<String>.unmodifiable(_selectedPhotos),
              primaryPhotoIndex: _primaryPhotoIndex,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    return Scaffold(
      appBar: AppBar(title: Text(L10n.get("gigs_publish_screen_title"))),
      // Two listeners — one per bloc — handle the success/error toasts.
      // `MultiBlocListener` keeps the body free of nested builders.
      body: MultiBlocListener(
        listeners: [
          BlocListener<GigPostRequestBloc, GigPostRequestState>(
            listener: (context, state) {
              if (state is GigPostRequestSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(L10n.get("gigs_post_request_success_toast")),
                  ),
                );
                Navigator.of(context).pop();
              } else if (state is GigPostRequestError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<GigPostOfferBloc, GigPostOfferState>(
            listener: (context, state) {
              if (state is GigPostOfferSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(L10n.get("gigs_post_offer_success_toast")),
                  ),
                );
                Navigator.of(context).pop();
              } else if (state is GigPostOfferError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<GigPostRequestBloc, GigPostRequestState>(
          builder: (context, requestState) {
            return BlocBuilder<GigPostOfferBloc, GigPostOfferState>(
              builder: (context, offerState) {
                // Both blocs are seeded from the same [GigCategoryCache], so
                // the picker can read either one — but we still pull from
                // whichever matches the current mode in case future cache
                // semantics diverge per-flavor (e.g. service-only categories).
                final List<GigCategory> categories;
                if (_mode == GigPublishMode.task) {
                  final idle = requestState is GigPostRequestIdle
                      ? requestState
                      : null;
                  categories = idle?.categories ?? const <GigCategory>[];
                } else {
                  final idle =
                      offerState is GigPostOfferIdle ? offerState : null;
                  categories = idle?.categories ?? const <GigCategory>[];
                }

                final submitting = (_mode == GigPublishMode.task &&
                        requestState is GigPostRequestSubmitting) ||
                    (_mode == GigPublishMode.service &&
                        offerState is GigPostOfferSubmitting);

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _PublishModeToggle(
                        value: _mode,
                        onChanged: _setMode,
                      ),
                      const SizedBox(height: 22),
                      _FieldLabel(
                        L10n.get("gigs_post_request_field_category"),
                      ),
                      _CategoryPlate(
                        categories: categories,
                        selected: _selectedCategory,
                        language: language,
                        showError: _showCategoryError,
                        onChanged: (c) {
                          setState(() {
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
                              setState(() => _showTitleError = false);
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
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          minLines: 4,
                          maxLength: _descriptionMaxLength,
                          style: _fieldTextStyle(context),
                          decoration: _plateInputDecoration(
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
                          }) =>
                              _buildSubtleCounter(
                            context,
                            currentLength: currentLength,
                            maxLength: maxLength ?? _descriptionMaxLength,
                            visibleAt: _descriptionCounterVisibleAt,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (_mode == GigPublishMode.task)
                        ..._buildTaskFields()
                      else
                        ..._buildServiceFields(),
                      const SizedBox(height: 14),
                      _RemoteTogglePlate(
                        value: _isRemote,
                        label:
                            L10n.get("gigs_post_request_field_remote"),
                        onChanged: (v) =>
                            setState(() => _isRemote = v),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: submitting ? null : _submit,
                        isLoading: submitting,
                        height: 54,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                        child: Text(
                          _mode == GigPublishMode.task
                              ? L10n.get("gigs_post_request_submit")
                              : L10n.get("gigs_post_offer_submit"),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildTaskFields() {
    return [
      _FieldLabel(L10n.get("gigs_post_request_field_budget_type")),
      _BudgetTypePlate(
        value: _budgetType,
        onChanged: (v) => setState(() => _budgetType = v),
      ),
      if (_budgetType != GigRequestBudgetType.open) ...[
        const SizedBox(height: 14),
        _FieldLabel(L10n.get("gigs_post_request_field_amount")),
        _CurrencyAmountField(
          controller: _budgetController,
          currency: _currency,
          supportedCurrencies: _supportedCurrencies,
          onCurrencyChanged: (c) => setState(() => _currency = c),
          hint: "0",
          showError: _showAmountError,
          onChanged: (_) {
            if (_showAmountError) {
              setState(() => _showAmountError = false);
            }
          },
        ),
      ],
      const SizedBox(height: 14),
      _FieldLabel(L10n.get("gigs_post_request_field_address")),
      _PlateField(
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

  List<Widget> _buildServiceFields() {
    return [
      _FieldLabel(L10n.get("gigs_post_offer_field_pricing_type")),
      _PricingTypePlate(
        value: _pricingType,
        onChanged: (v) => setState(() => _pricingType = v),
      ),
      const SizedBox(height: 14),
      _FieldLabel(L10n.get("gigs_post_offer_field_price")),
      _CurrencyAmountField(
        controller: _priceController,
        currency: _currency,
        supportedCurrencies: _supportedCurrencies,
        onCurrencyChanged: (c) => setState(() => _currency = c),
        hint: "0",
        showError: _showAmountError,
        onChanged: (_) {
          if (_showAmountError) {
            setState(() => _showAmountError = false);
          }
        },
      ),
      if (_pricingType == GigPricingType.hourly) ...[
        const SizedBox(height: 14),
        _FieldLabel(L10n.get("gigs_post_offer_field_min_duration")),
        _PlateField(
          child: TextFormField(
            controller: _minDurationController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: _fieldTextStyle(context),
            decoration: _plateInputDecoration(
              context,
              hint: L10n.get("gigs_post_offer_field_min_duration_hint"),
            ),
          ),
        ),
      ],
      const SizedBox(height: 14),
      // Reuses the same uploader that powers create/edit-listing — same
      // pick / crop / camera flow, same primary-photo pill, same drag
      // reorder. We feed it `existingPhotos: const []` because the
      // publish screen always starts from a blank slate; the edit-offer
      // screen (forthcoming) will pass real `Photo`s here.
      PhotoUploader(
        selectedPhotos: _selectedPhotos,
        onPhotosChanged: (photos) {
          setState(() {
            _selectedPhotos = photos;
            // Mirror create-listing: first picked photo becomes primary
            // by default. Stays sticky if the user already chose one.
            if (photos.isNotEmpty && _primaryPhotoIndex == null) {
              _primaryPhotoIndex = 0;
            } else if (photos.isEmpty) {
              _primaryPhotoIndex = null;
            }
          });
        },
        existingPhotos: const [],
        onDeleteExistingPhoto: (_) {},
        onMakePhotoPrimary: (_) {},
        onMakeNewPhotoPrimary: (i) =>
            setState(() => _primaryPhotoIndex = i),
        deletingPhotoIds: const {},
        makingPhotoPrimaryIds: const {},
        maxPhotos: AppConfig.maxPhotosPerGigOffer,
        // Drive the grid off `_selectedPhotos` directly so drag-reorder
        // updates both the on-screen order and the upload order on
        // submit (slot 0 is uploaded as primary unless the user
        // explicitly tapped a different tile).
        orderedItems: [
          for (final path in _selectedPhotos) NewPhotoItem(path),
        ],
        onReorderItems: (newOrder) {
          setState(() {
            _selectedPhotos = [
              for (final item in newOrder)
                if (item is NewPhotoItem) item.path,
            ];
            _primaryPhotoIndex = _selectedPhotos.isEmpty ? null : 0;
          });
        },
      ),
    ];
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
      onChanged: onChanged,
      entries: [
        SegmentedSwitchEntry(
          value: GigPublishMode.task,
          label: L10n.get("gigs_publish_mode_task"),
          icon: Icons.assignment_outlined,
        ),
        SegmentedSwitchEntry(
          value: GigPublishMode.service,
          label: L10n.get("gigs_publish_mode_service"),
          icon: Icons.handyman_outlined,
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

InputDecoration _plateInputDecoration(BuildContext context, {String? hint}) {
  final hintColor = Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)
      : Colors.grey[500];
  return InputDecoration(
    hintText: hint,
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
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    isDense: true,
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
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _PlateField extends StatelessWidget {
  const _PlateField({required this.child, this.showErrorBorder = false});
  final Widget child;
  final bool showErrorBorder;

  @override
  Widget build(BuildContext context) {
    return WheelPickerPlateContainer(
      theme: Theme.of(context),
      showErrorBorder: showErrorBorder,
      child: child,
    );
  }
}

/// Numeric input plate with a tappable currency code on the leading edge.
///
/// The chip itself shows the active code (e.g. "UZS"); tapping it opens a
/// bottom sheet with [supportedCurrencies] so the user can switch. A
/// vertical hairline divider separates the chip from the typed amount so
/// the prefix reads as "part of the value", not a stray button.
class _CurrencyAmountField extends StatelessWidget {
  const _CurrencyAmountField({
    required this.controller,
    required this.currency,
    required this.supportedCurrencies,
    required this.onCurrencyChanged,
    this.hint,
    this.showError = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currency;
  final List<String> supportedCurrencies;
  final ValueChanged<String> onCurrencyChanged;
  final String? hint;
  final bool showError;
  final ValueChanged<String>? onChanged;

  /// Maps a currency code → leading flag emoji. The codebase already uses
  /// Unicode flag emojis (auth wizard, chat translation prompts) so they
  /// render consistently here without dragging in flag image assets.
  static String _flagFor(String currencyCode) {
    switch (currencyCode) {
      case "USD":
        return "🇺🇸";
      case "RUB":
        return "🇷🇺";
      case "EUR":
        return "🇪🇺";
      case "UZS":
      default:
        return "🇺🇿";
    }
  }

  Future<void> _pickCurrency(BuildContext context) async {
    HapticFeedbackUtils.selection();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      isScrollControlled: true,
      useSafeArea: true,
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                          _flagFor(code),
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
                            ? Icon(Icons.check_rounded,
                                color: scheme.secondary)
                            : null,
                        onTap: () => Navigator.of(sheetCtx).pop(code),
                      );
                    },
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
    final chipColor = ThemeState().isLightTheme
        ? Colors.black
        : scheme.onSurface;

    return _PlateField(
      showErrorBorder: showError,
      child: Row(
        children: [
          InkWell(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            onTap: () => _pickCurrency(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _flagFor(currency),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: chipColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: _fieldTextStyle(context),
              decoration: _plateInputDecoration(context, hint: hint),
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
  });

  final List<GigCategory> categories;
  final GigCategory? selected;
  final String language;
  final ValueChanged<GigCategory?> onChanged;
  final bool showError;

  Future<void> _pick(BuildContext context) async {
    if (categories.isEmpty) return;
    final picked = await showModalBottomSheet<GigCategory>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      isScrollControlled: true,
      useSafeArea: true,
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
                      shrinkWrap: true,
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
                              color:
                                  scheme.secondary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(c.icon,
                                color: scheme.secondary, size: 20),
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
  const _BudgetTypePlate({required this.value, required this.onChanged});
  final GigRequestBudgetType value;
  final ValueChanged<GigRequestBudgetType> onChanged;

  @override
  Widget build(BuildContext context) {
    return NeumorphicSegmentedSwitch<GigRequestBudgetType>(
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
  }
}

class _PricingTypePlate extends StatelessWidget {
  const _PricingTypePlate({required this.value, required this.onChanged});
  final GigPricingType value;
  final ValueChanged<GigPricingType> onChanged;

  @override
  Widget build(BuildContext context) {
    return NeumorphicSegmentedSwitch<GigPricingType>(
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
  }
}

class _RemoteTogglePlate extends StatelessWidget {
  const _RemoteTogglePlate({
    required this.value,
    required this.label,
    required this.onChanged,
  });
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PlateField(
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
