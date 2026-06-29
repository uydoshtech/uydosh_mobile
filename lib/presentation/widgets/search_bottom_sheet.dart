import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/onboarding_state.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/tutorial_state.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart"; // ignore: unused_import
import "package:uy_dosh/domain/services/search_alert_service.dart"; // ignore: unused_import
import "package:uy_dosh/presentation/screens/permissions/notification_permission_gate.dart"; // ignore: unused_import
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/modal_sheet_glass_scope.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/notify_search_alert_app_bar_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart"; // ignore: unused_import
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet/search_bottom_sheet_filter_section.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet/search_bottom_sheet_location_section.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet/search_bottom_sheet_metro_section.dart";
import "package:uy_dosh/presentation/widgets/tutorial/metro_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

part "search_bottom_sheet/search_bottom_sheet_state.dart";

enum SearchBottomSheetAction { feed, map }

class SearchBottomSheetResult {
  const SearchBottomSheetResult({
    required this.listingTypeId,
    required this.gender,
    required this.locationId,
    required this.subwayStationId,
    required this.subwayLineId,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
    this.action = SearchBottomSheetAction.feed,
    this.subwayStationIds = const [],
  });

  final int listingTypeId;
  final int? gender;
  final int? locationId;
  final int? subwayStationId;

  /// Full multi-station selection. `subwayStationId` mirrors the single value
  /// when exactly one station is chosen (kept for backward compatibility).
  final List<int> subwayStationIds;
  final int? subwayLineId;
  final double minPrice;
  final double maxPrice;
  final bool privateRoom;
  final bool withPhoto;
  final SearchBottomSheetAction action;
}

/// Reusable search bottom sheet widget that can be used throughout the app
///
/// Features:
/// - Location and metro filters are mutually exclusive
/// - When metro line is selected, location picker is reset
/// - When location is selected, metro filters are reset
/// - Wheel pickers are automatically reset to initial positions
class SearchBottomSheetWidget {
  /// Shows the search bottom sheet with all available filters.
  static Future<void> show(
    BuildContext context, {
    bool replaceCurrentRoute = false,
    bool openedFromHomeScreen = false,
    bool metroOnly = false,
    bool applyProfileDefaults = true,
    bool commitFiltersOnApply = true,
    int? currentListingTypeId,
    int? currentLocationId,
    int? currentSubwayStationId,
    List<int>? currentSubwayStationIds,
    int? currentSubwayLineId,
    int? currentGender,
    double? currentMinPrice,
    double? currentMaxPrice,
    bool? currentPrivateRoom,
    bool? currentWithPhoto,
    void Function(SearchBottomSheetResult result)? onApply,
    String primaryLabelKey = "search",
    IconData primaryIcon = Icons.search,
    SearchBottomSheetAction primaryAction = SearchBottomSheetAction.feed,
  }) async {
    final searchFiltersState = SearchFiltersState();

    searchFiltersState.beginEditingSession();
    final preSheetSnapshot = SearchFiltersSnapshot.capture(searchFiltersState);
    var didCommit = false;

    final isFirstOpen = searchFiltersState.isFirstSearchSheetOpen;
    final resolvedListingTypeId = applyProfileDefaults && isFirstOpen
        ? searchFiltersState.selectedListingTypeId
        : currentListingTypeId;
    final resolvedGender = applyProfileDefaults && isFirstOpen
        ? searchFiltersState.selectedGender
        : currentGender;

    void markCommitted() {
      didCommit = true;
    }

    try {
      await showAppBottomSheet<void>(
        context: context,
        useSafeArea: false,
        builder: (context) => ModalSheetGlassScope(
          nestedPlateBlurEnabled: false,
          child: _SearchBottomSheetContent(
            replaceCurrentRoute: replaceCurrentRoute,
            openedFromHomeScreen: openedFromHomeScreen,
            metroOnly: metroOnly,
            commitFiltersOnApply: commitFiltersOnApply,
            currentListingTypeId: resolvedListingTypeId,
            currentLocationId: currentLocationId,
            currentSubwayStationId: currentSubwayStationId,
            currentSubwayStationIds: currentSubwayStationIds,
            currentSubwayLineId: currentSubwayLineId,
            currentGender: resolvedGender,
            currentMinPrice: currentMinPrice,
            currentMaxPrice: currentMaxPrice,
            currentPrivateRoom: currentPrivateRoom,
            currentWithPhoto: currentWithPhoto,
            onApply: onApply,
            onCommit: markCommitted,
            primaryLabelKey: primaryLabelKey,
            primaryIcon: primaryIcon,
            primaryAction: primaryAction,
          ),
        ),
      );
    } finally {
      if (didCommit) {
        // End the session and notify outside listeners so the home chips
        // ribbon picks up the freshly applied filters.
        searchFiltersState.endEditingSession(commit: true);
      } else {
        // User dismissed without searching: revert any in-sheet edits so the
        // home filter chips ribbon (and persisted prefs) keep their prior
        // values.
        searchFiltersState.endEditingSession(commit: false);
        await searchFiltersState.restoreToSnapshot(preSheetSnapshot);
      }
    }
  }
}

class _SearchBottomSheetContent extends StatefulWidget {
  const _SearchBottomSheetContent({
    this.replaceCurrentRoute = false,
    this.openedFromHomeScreen = false,
    this.metroOnly = false,
    this.commitFiltersOnApply = true,
    this.currentListingTypeId,
    this.currentLocationId,
    this.currentSubwayStationId,
    this.currentSubwayStationIds,
    this.currentSubwayLineId,
    this.currentGender,
    this.currentMinPrice,
    this.currentMaxPrice,
    this.currentPrivateRoom,
    this.currentWithPhoto,
    this.onApply,
    this.onCommit,
    this.primaryLabelKey = "search",
    this.primaryIcon = Icons.search,
    this.primaryAction = SearchBottomSheetAction.feed,
  });
  final bool replaceCurrentRoute;
  final bool openedFromHomeScreen;
  final bool metroOnly;
  final bool commitFiltersOnApply;
  final int? currentListingTypeId;
  final int? currentLocationId;
  final int? currentSubwayStationId;
  final List<int>? currentSubwayStationIds;
  final int? currentSubwayLineId;
  final int? currentGender;
  final double? currentMinPrice;
  final double? currentMaxPrice;
  final bool? currentPrivateRoom;
  final bool? currentWithPhoto;
  final void Function(SearchBottomSheetResult result)? onApply;

  /// Called by [_performSearch] BEFORE popping the sheet so the show()
  /// caller knows to commit (vs. revert) the in-session filter edits.
  final VoidCallback? onCommit;
  final String primaryLabelKey;
  final IconData primaryIcon;
  final SearchBottomSheetAction primaryAction;

  @override
  State<_SearchBottomSheetContent> createState() =>
      _SearchBottomSheetContentState();
}
