import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_moderation_admin_service.dart";
import "package:uy_dosh/domain/services/listing_parser_review_admin_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/edit_listing/edit_listing_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// One field comparison row: the parser's prediction next to the value
/// currently saved on the operational listing.
class _FieldRow {
  _FieldRow({
    required this.label,
    required this.parserKey,
    required this.currentValue,
  });
  final String label;
  final String parserKey;
  final dynamic currentValue;
}

/// Admin review surface for a Telegram-ingested listing: shows the raw source,
/// the parser's predictions vs. the current listing, lets the admin edit
/// (capturing a human_corrected snapshot) and approve (capturing approved_final
/// + correction diffs + a training example).
class AdminListingParserReviewScreen extends StatefulWidget {
  const AdminListingParserReviewScreen({required this.listingId, super.key});

  final int listingId;

  @override
  State<AdminListingParserReviewScreen> createState() =>
      _AdminListingParserReviewScreenState();
}

class _AdminListingParserReviewScreenState
    extends State<AdminListingParserReviewScreen> {
  final IListingParserReviewAdminService _reviewService =
      getIt<IListingParserReviewAdminService>();
  final IListingModerationAdminService _moderationService =
      getIt<IListingModerationAdminService>();
  final IListingService _listingService = getIt<IListingService>();
  final ISubwayStationService _subwayService = getIt<ISubwayStationService>();
  final ILocationService _locationService = getIt<ILocationService>();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  ParserReviewBundle? _bundle;
  bool _busy = false;
  bool _rawExpanded = true;

  /// id -> localized name lookups so metro/district render as names, not ids.
  final Map<int, String> _stationNames = {};
  final Map<int, String> _locationNames = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    try {
      final bundle = await _reviewService.getParserReview(widget.listingId);
      await _ensureNameLookups();
      setStateIfMounted(() {
        _bundle = bundle;
        _isLoading = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Best-effort load of subway/location reference data so we can show names
  /// instead of raw ids. Failures are swallowed — we just fall back to ids.
  Future<void> _ensureNameLookups() async {
    if (_stationNames.isNotEmpty && _locationNames.isNotEmpty) return;
    try {
      final stations = await _subwayService.getSubwayStations();
      for (final s in stations) {
        final name = _pickName(s.nameUz, s.nameRu, s.nameEn);
        if (name.isNotEmpty) _stationNames[s.id] = name;
      }
    } catch (_) {
      // ignore: metro names are optional polish.
    }
    try {
      final locations = await _locationService.getLocations();
      for (final l in locations) {
        final name = _pickName(l.nameUz, l.nameRu, l.nameEn);
        if (name.isNotEmpty) _locationNames[l.id] = name;
      }
    } catch (_) {
      // ignore: location names are optional polish.
    }
  }

  String _pickName(String? uz, String? ru, String? en) {
    switch (LanguageState().currentLanguage) {
      case "ru":
        return (ru ?? en ?? uz ?? "").trim();
      case "en":
        return (en ?? ru ?? uz ?? "").trim();
      default:
        return (uz ?? ru ?? en ?? "").trim();
    }
  }

  int? _asId(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  String _stationLabel(dynamic v) {
    final id = _asId(v);
    if (id != null) {
      final name = _stationNames[id];
      if (name != null && name.isNotEmpty) return name;
    }
    return _fmt(v);
  }

  String _locationLabel(dynamic v) {
    final id = _asId(v);
    if (id != null) {
      final name = _locationNames[id];
      if (name != null && name.isNotEmpty) return name;
    }
    return _fmt(v);
  }

  String _formatValue(String parserKey, dynamic v) {
    switch (parserKey) {
      case "gender_preference":
        return _genderLabel(v);
      case "metro":
        return _stationLabel(v);
      case "district":
        return _locationLabel(v);
      default:
        return _fmt(v);
    }
  }

  bool get _isApproved {
    final status = _bundle?.listing["moderation_status"] ??
        _bundle?.listing["moderationStatus"];
    return status == "approved";
  }

  Future<void> _openFullListing() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ListingDetailBloc(getIt<IListingService>()),
            ),
            BlocProvider(create: (_) => ListingDetailPageBloc()),
          ],
          child: ListingDetailScreen(listingId: widget.listingId),
        ),
      ),
    );
    await _load();
  }

  Future<void> _editAndCorrect() async {
    if (_busy) return;
    setState(() => _busy = true);
    ListingDetail? detail;
    try {
      detail = await _listingService.getListingDetail(widget.listingId);
    } catch (e) {
      if (mounted) ToastTheme.showErrorSimple(context, message: e.toString());
    } finally {
      setStateIfMounted(() => _busy = false);
    }
    if (detail == null || !mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<SubwayStationsBloc>(
              create: (context) => SubwayStationsBloc(),
            ),
            BlocProvider<LocationsBloc>(
              create: (context) => LocationsBloc(getIt<ILocationService>()),
            ),
          ],
          child: EditListingScreen(listingDetail: detail!),
        ),
      ),
    );
    // Reload so the parser-vs-current comparison reflects the admin's edits
    // (a human_corrected snapshot was captured server-side on save).
    if (result == true) {
      await _load();
    }
  }

  Future<void> _approve() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _moderationService.approveListing(widget.listingId);
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get(
          "admin_listing_moderation_approved_toast",
          fallback: "Listing approved",
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ToastTheme.showErrorSimple(context, message: e.toString());
      setStateIfMounted(() => _busy = false);
    }
  }

  String _fmt(dynamic v) {
    if (v == null) return "—";
    if (v is String) return v.trim().isEmpty ? "—" : v.trim();
    return v.toString();
  }

  String _genderLabel(dynamic v) {
    final n = v is num ? v.toInt() : int.tryParse("$v");
    if (n == 1) {
      return L10n.get("gender_short_male", fallback: "Male");
    }
    if (n == 2) {
      return L10n.get("gender_short_female", fallback: "Female");
    }
    return _fmt(v);
  }

  List<_FieldRow> _buildRows(Map<String, dynamic> listing) {
    return [
      _FieldRow(
        label: L10n.get("admin_parser_review_field_title", fallback: "Title"),
        parserKey: "title",
        currentValue: listing["title"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_price",
          fallback: "Price (USD)",
        ),
        parserKey: "price",
        currentValue: listing["price"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_gender",
          fallback: "Gender preference",
        ),
        parserKey: "gender_preference",
        currentValue: listing["gender"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_metro",
          fallback: "Metro",
        ),
        parserKey: "metro",
        currentValue: listing["subway_station_id"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_district",
          fallback: "District",
        ),
        parserKey: "district",
        currentValue: listing["location_id"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_move_in",
          fallback: "Move-in date",
        ),
        parserKey: "available_from",
        currentValue: listing["move_in_date"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_contact_phone",
          fallback: "Contact phone",
        ),
        parserKey: "contact_phone",
        currentValue: listing["contact_phone"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_contact_telegram",
          fallback: "Contact telegram",
        ),
        parserKey: "contact_telegram",
        currentValue: listing["contact_telegram"],
      ),
      _FieldRow(
        label: L10n.get(
          "admin_parser_review_field_description",
          fallback: "Description",
        ),
        parserKey: "description",
        currentValue: listing["description"],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get(
            "admin_parser_review_title",
            fallback: "Parser review",
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          if (_hasError) {
            return UydoshErrorRetryColumn(
              title: L10n.get(
                "admin_parser_review_error",
                fallback: "Couldn't load parser review",
              ),
              message: _errorMessage,
              messageMaxLines: 3,
              messageOverflow: TextOverflow.ellipsis,
              padding: const EdgeInsets.all(24),
              spacingAfterTitle: 8,
              spacingBeforeButton: 20,
              onRetry: _load,
              retryLabel: L10n.get("retry", fallback: "Retry"),
            );
          }
          if (_isLoading && _bundle == null) {
            return CenteredHouseLoadingIndicator(
              text: L10n.get(
                "admin_parser_review_loading",
                fallback: "Loading parser review…",
              ),
            );
          }
          final bundle = _bundle;
          if (bundle == null) {
            return const SizedBox.shrink();
          }
          return _buildContent(context, bundle);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ParserReviewBundle bundle) {
    final scheme = Theme.of(context).colorScheme;
    final rows = _buildRows(bundle.listing);

    return UydoshRefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!bundle.hasParserData) _buildNoParserBanner(context),
                _buildRawSourceCard(context, bundle),
                const SizedBox(height: 16),
                _buildSectionTitle(
                  context,
                  L10n.get(
                    "admin_parser_review_section_fields",
                    fallback: "Parser predictions vs. current",
                  ),
                  Icons.compare_arrows_rounded,
                ),
                const SizedBox(height: 8),
                _buildFieldsCard(context, bundle, rows),
                if (bundle.correctionDiffs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle(
                    context,
                    L10n.get(
                      "admin_parser_review_section_corrections",
                      fallback: "Recorded corrections",
                    ),
                    Icons.fact_check_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildDiffsCard(context, bundle),
                ],
                const SizedBox(height: 16),
                _buildActions(context, scheme),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoParserBanner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ThemeIcon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              L10n.get(
                "admin_parser_review_no_parser",
                fallback:
                    "No parser snapshot for this listing (not a tracked Telegram import). You can still edit and approve.",
              ),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawSourceCard(BuildContext context, ParserReviewBundle bundle) {
    final raw = bundle.rawSource;
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final textColor = themeState.cardTextColor;
        final secondaryTextColor = themeState.cardSecondaryTextColor;
        final iconColor = themeState.cardIconColor;
        final meta = <String>[
          if (raw?.chatKey != null) raw!.chatKey!,
          if (raw?.authorUsername != null) "@${raw!.authorUsername}",
          if (raw?.messageDate != null) raw!.messageDate!,
        ];
        return ThreeDElevatedSurface(
          baseColor: themeState.cardColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _rawExpanded = !_rawExpanded),
                  child: Row(
                    children: [
                      ThemeIcon(Icons.telegram, size: 20, color: iconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          L10n.get(
                            "admin_parser_review_raw_source",
                            fallback: "Raw Telegram post",
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _rawExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: ThemeIcon(Icons.expand_more, color: iconColor),
                      ),
                    ],
                  ),
                ),
                if (_rawExpanded) ...[
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      meta.join(" · "),
                      style:
                          TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SelectableText(
                    (raw?.text == null || raw!.text!.trim().isEmpty)
                        ? L10n.get(
                            "admin_parser_review_raw_empty",
                            fallback: "(no text in source)",
                          )
                        : raw.text!.trim(),
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldsCard(
    BuildContext context,
    ParserReviewBundle bundle,
    List<_FieldRow> rows,
  ) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        return ThreeDElevatedSurface(
          baseColor: themeState.cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _buildFieldRow(context, bundle, rows[i]),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldRow(
    BuildContext context,
    ParserReviewBundle bundle,
    _FieldRow row,
  ) {
    final themeState = ThemeState();
    final textColor = themeState.cardTextColor;
    final secondaryTextColor = themeState.cardSecondaryTextColor;

    final parserRaw = bundle.parserSnapshot?.outputJson[row.parserKey];
    final parserText = _formatValue(row.parserKey, parserRaw);
    final currentText = _formatValue(row.parserKey, row.currentValue);

    final parserEmpty = parserText == "—";
    final currentEmpty = currentText == "—";
    String? chip;
    Color? chipColor;
    final scheme = Theme.of(context).colorScheme;
    if (bundle.hasParserData) {
      if (parserEmpty && currentEmpty) {
        chip = null;
      } else if (parserEmpty && !currentEmpty) {
        chip = L10n.get("admin_parser_review_chip_added", fallback: "added");
        chipColor = Colors.green;
      } else if (!parserEmpty && currentEmpty) {
        chip =
            L10n.get("admin_parser_review_chip_removed", fallback: "removed");
        chipColor = Colors.red;
      } else if (parserText != currentText) {
        chip =
            L10n.get("admin_parser_review_chip_changed", fallback: "changed");
        chipColor = scheme.primary;
      } else {
        chip = L10n.get(
          "admin_parser_review_chip_confirmed",
          fallback: "confirmed",
        );
        chipColor = scheme.onSurfaceVariant;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ),
              if (chip != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (chipColor ?? scheme.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    chip,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: chipColor ?? scheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.get(
                        "admin_parser_review_parser_label",
                        fallback: "Parser",
                      ),
                      style:
                          TextStyle(fontSize: 10, color: secondaryTextColor),
                    ),
                    Text(
                      parserText,
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.get(
                        "admin_parser_review_current_label",
                        fallback: "Current",
                      ),
                      style:
                          TextStyle(fontSize: 10, color: secondaryTextColor),
                    ),
                    Text(
                      currentText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiffsCard(BuildContext context, ParserReviewBundle bundle) {
    final themeState = ThemeState();
    final textColor = themeState.cardTextColor;
    final secondaryTextColor = themeState.cardSecondaryTextColor;
    // Surface the non-confirmed corrections first (the interesting ones).
    final diffs = [...bundle.correctionDiffs]
      ..sort((a, b) {
        int rank(String t) => t == "confirmed" ? 1 : 0;
        return rank(a.correctionType).compareTo(rank(b.correctionType));
      });
    final changed = bundle.correctionDiffs
        .where((d) => d.correctionType != "confirmed")
        .length;

    return ThreeDElevatedSurface(
      baseColor: themeState.cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.getWithParams(
                "admin_parser_review_corrections_summary",
                params: {
                  "changed": "$changed",
                  "total": "${bundle.correctionDiffs.length}",
                },
                fallback:
                    "$changed of ${bundle.correctionDiffs.length} fields corrected",
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            for (final d in diffs.where((x) => x.correctionType != "confirmed"))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${d.fieldName}: ${_fmt(d.oldValue)} → ${_fmt(d.newValue)}  (${d.correctionType})",
                  style: TextStyle(fontSize: 13, color: textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GhostButtonFactory.iconTextCentered(
                onPressed: _busy ? null : _openFullListing,
                icon: Icons.open_in_new_rounded,
                text: L10n.get(
                  "admin_parser_review_open_full",
                  fallback: "Open full listing",
                ),
                iconSize: 18,
                neumorphicSoftUi: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GhostButtonFactory.iconTextCentered(
                onPressed: _busy ? null : _editAndCorrect,
                icon: Icons.edit_outlined,
                text: L10n.get(
                  "admin_parser_review_edit",
                  fallback: "Edit & correct",
                ),
                iconSize: 18,
                neumorphicSoftUi: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: (_busy || _isApproved) ? null : _approve,
            isLoading: _busy,
            surfaceGradientBase: scheme.primary,
            textColor: scheme.onPrimary,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeIcon(
                  _isApproved
                      ? Icons.verified_outlined
                      : Icons.check_circle_outline,
                  size: 18,
                  color: scheme.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  _isApproved
                      ? L10n.get(
                          "admin_parser_review_already_approved",
                          fallback: "Already approved",
                        )
                      : L10n.get(
                          "admin_listing_moderation_approve",
                          fallback: "Approve",
                        ),
                  style: TextStyle(color: scheme.onPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        ThemeIcon(icon, size: 20, color: scheme.onSurface),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
