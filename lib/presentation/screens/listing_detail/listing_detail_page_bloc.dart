import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_group_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_compatibility_section.dart";

/// Page-level state for listing detail screen. Replaces setState with bloc
/// emissions for targeted rebuilds via BlocSelector.
class ListingDetailPageState {
  const ListingDetailPageState({
    this.isToggling = false,
    this.isDeleting = false,
    this.complaintsCount,
    this.complaintsCountListingId,
    this.isLoadingComplaintsCount = false,
    this.viewCount,
    this.viewCountListingId,
    this.isLoadingViewCount = false,
    this.compatibilityPercent,
    this.compatibilityListingUserId,
    this.isLoadingCompatibility = false,
    this.compatibilityMatches = const [],
    this.compatibilityDifferences = const [],
    this.compatibilityDealbreakers = const [],
    this.compatibilityScoredFieldCount = 0,
    this.compatibilityTotalFieldCount = 0,
    this.compatibilityError,
    this.ownerName,
    this.ownerNameListingUserId,
    this.ownerAvatarUrl,
    this.currentUserAvatarUrl,
    this.isGroupCompatibility = false,
    this.groupMembers = const [],
    this.groupFullMatches = const [],
    this.groupPartialMatches = const [],
    this.groupDiscussItems = const [],
    this.similarListingsCount,
    this.similarListingsCountListingId,
    this.isLoadingSimilarListingsCount = false,
    this.nearbyMatchesCount,
    this.nearbyMatchesCountListingId,
    this.isLoadingNearbyMatchesCount = false,
  });

  final bool isToggling;
  final bool isDeleting;
  final int? complaintsCount;
  final int? complaintsCountListingId;
  final bool isLoadingComplaintsCount;
  final int? viewCount;
  final int? viewCountListingId;
  final bool isLoadingViewCount;
  final int? compatibilityPercent;
  final int? compatibilityListingUserId;
  final bool isLoadingCompatibility;
  final List<CompatibilityMatch> compatibilityMatches;
  final List<CompatibilityDifference> compatibilityDifferences;
  final List<CompatibilityDifference> compatibilityDealbreakers;
  final int compatibilityScoredFieldCount;
  final int compatibilityTotalFieldCount;
  final String? compatibilityError;
  final String? ownerName;
  final int? ownerNameListingUserId;
  final String? ownerAvatarUrl;
  final String? currentUserAvatarUrl;
  final bool isGroupCompatibility;
  final List<ConversationMemberSummary> groupMembers;
  final List<GroupCompatibilityFullMatch> groupFullMatches;
  final List<GroupCompatibilityPartialMatch> groupPartialMatches;
  final List<GroupCompatibilityDiscussItem> groupDiscussItems;

  /// Number of "similar" listings excluding the current one. When this is
  /// known and equal to 0 the UI hides the "view similar" affordance because
  /// the only result would be the current listing itself.
  final int? similarListingsCount;
  final int? similarListingsCountListingId;
  final bool isLoadingSimilarListingsCount;

  /// Cross-type listings near the current one (seeker ↔ offer). Hidden when 0.
  final int? nearbyMatchesCount;
  final int? nearbyMatchesCountListingId;
  final bool isLoadingNearbyMatchesCount;

  ListingDetailPageState copyWith({
    bool? isToggling,
    bool? isDeleting,
    int? complaintsCount,
    int? complaintsCountListingId,
    bool? isLoadingComplaintsCount,
    int? viewCount,
    int? viewCountListingId,
    bool? isLoadingViewCount,
    int? compatibilityPercent,
    int? compatibilityListingUserId,
    bool? isLoadingCompatibility,
    List<CompatibilityMatch>? compatibilityMatches,
    List<CompatibilityDifference>? compatibilityDifferences,
    List<CompatibilityDifference>? compatibilityDealbreakers,
    int? compatibilityScoredFieldCount,
    int? compatibilityTotalFieldCount,
    String? compatibilityError,
    String? ownerName,
    int? ownerNameListingUserId,
    String? ownerAvatarUrl,
    String? currentUserAvatarUrl,
    bool? isGroupCompatibility,
    List<ConversationMemberSummary>? groupMembers,
    List<GroupCompatibilityFullMatch>? groupFullMatches,
    List<GroupCompatibilityPartialMatch>? groupPartialMatches,
    List<GroupCompatibilityDiscussItem>? groupDiscussItems,
    int? similarListingsCount,
    int? similarListingsCountListingId,
    bool? isLoadingSimilarListingsCount,
    int? nearbyMatchesCount,
    int? nearbyMatchesCountListingId,
    bool? isLoadingNearbyMatchesCount,
  }) {
    return ListingDetailPageState(
      isToggling: isToggling ?? this.isToggling,
      isDeleting: isDeleting ?? this.isDeleting,
      complaintsCount: complaintsCount ?? this.complaintsCount,
      complaintsCountListingId:
          complaintsCountListingId ?? this.complaintsCountListingId,
      isLoadingComplaintsCount:
          isLoadingComplaintsCount ?? this.isLoadingComplaintsCount,
      viewCount: viewCount ?? this.viewCount,
      viewCountListingId: viewCountListingId ?? this.viewCountListingId,
      isLoadingViewCount: isLoadingViewCount ?? this.isLoadingViewCount,
      compatibilityPercent:
          compatibilityPercent ?? this.compatibilityPercent,
      compatibilityListingUserId:
          compatibilityListingUserId ?? this.compatibilityListingUserId,
      isLoadingCompatibility:
          isLoadingCompatibility ?? this.isLoadingCompatibility,
      compatibilityMatches:
          compatibilityMatches ?? this.compatibilityMatches,
      compatibilityDifferences:
          compatibilityDifferences ?? this.compatibilityDifferences,
      compatibilityDealbreakers:
          compatibilityDealbreakers ?? this.compatibilityDealbreakers,
      compatibilityScoredFieldCount: compatibilityScoredFieldCount ??
          this.compatibilityScoredFieldCount,
      compatibilityTotalFieldCount: compatibilityTotalFieldCount ??
          this.compatibilityTotalFieldCount,
      compatibilityError: compatibilityError ?? this.compatibilityError,
      ownerName: ownerName ?? this.ownerName,
      ownerNameListingUserId:
          ownerNameListingUserId ?? this.ownerNameListingUserId,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      currentUserAvatarUrl: currentUserAvatarUrl ?? this.currentUserAvatarUrl,
      isGroupCompatibility: isGroupCompatibility ?? this.isGroupCompatibility,
      groupMembers: groupMembers ?? this.groupMembers,
      groupFullMatches: groupFullMatches ?? this.groupFullMatches,
      groupPartialMatches: groupPartialMatches ?? this.groupPartialMatches,
      groupDiscussItems: groupDiscussItems ?? this.groupDiscussItems,
      similarListingsCount:
          similarListingsCount ?? this.similarListingsCount,
      similarListingsCountListingId:
          similarListingsCountListingId ?? this.similarListingsCountListingId,
      isLoadingSimilarListingsCount: isLoadingSimilarListingsCount ??
          this.isLoadingSimilarListingsCount,
      nearbyMatchesCount: nearbyMatchesCount ?? this.nearbyMatchesCount,
      nearbyMatchesCountListingId:
          nearbyMatchesCountListingId ?? this.nearbyMatchesCountListingId,
      isLoadingNearbyMatchesCount: isLoadingNearbyMatchesCount ??
          this.isLoadingNearbyMatchesCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingDetailPageState &&
        other.isToggling == isToggling &&
        other.isDeleting == isDeleting &&
        other.complaintsCount == complaintsCount &&
        other.complaintsCountListingId == complaintsCountListingId &&
        other.isLoadingComplaintsCount == isLoadingComplaintsCount &&
        other.viewCount == viewCount &&
        other.viewCountListingId == viewCountListingId &&
        other.isLoadingViewCount == isLoadingViewCount &&
        other.compatibilityPercent == compatibilityPercent &&
        other.compatibilityListingUserId == compatibilityListingUserId &&
        other.isLoadingCompatibility == isLoadingCompatibility &&
        _listEquals(other.compatibilityMatches, compatibilityMatches) &&
        _listEquals(other.compatibilityDifferences, compatibilityDifferences) &&
        _listEquals(other.compatibilityDealbreakers, compatibilityDealbreakers) &&
        other.compatibilityScoredFieldCount == compatibilityScoredFieldCount &&
        other.compatibilityTotalFieldCount == compatibilityTotalFieldCount &&
        other.compatibilityError == compatibilityError &&
        other.ownerName == ownerName &&
        other.ownerNameListingUserId == ownerNameListingUserId &&
        other.ownerAvatarUrl == ownerAvatarUrl &&
        other.currentUserAvatarUrl == currentUserAvatarUrl &&
        other.isGroupCompatibility == isGroupCompatibility &&
        _listEquals(other.groupMembers, groupMembers) &&
        _listEquals(other.groupFullMatches, groupFullMatches) &&
        _listEquals(other.groupPartialMatches, groupPartialMatches) &&
        _listEquals(other.groupDiscussItems, groupDiscussItems) &&
        other.similarListingsCount == similarListingsCount &&
        other.similarListingsCountListingId == similarListingsCountListingId &&
        other.isLoadingSimilarListingsCount == isLoadingSimilarListingsCount &&
        other.nearbyMatchesCount == nearbyMatchesCount &&
        other.nearbyMatchesCountListingId == nearbyMatchesCountListingId &&
        other.isLoadingNearbyMatchesCount == isLoadingNearbyMatchesCount;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hashAll([
        isToggling,
        isDeleting,
        complaintsCount,
        complaintsCountListingId,
        isLoadingComplaintsCount,
        viewCount,
        viewCountListingId,
        isLoadingViewCount,
        compatibilityPercent,
        compatibilityListingUserId,
        isLoadingCompatibility,
        compatibilityError,
        ownerName,
        ownerNameListingUserId,
        ownerAvatarUrl,
        currentUserAvatarUrl,
        similarListingsCount,
        similarListingsCountListingId,
        isLoadingSimilarListingsCount,
        nearbyMatchesCount,
        nearbyMatchesCountListingId,
        isLoadingNearbyMatchesCount,
      ]);
}

/// Cubit for listing detail page-level state. Replaces setState calls.
class ListingDetailPageBloc extends Cubit<ListingDetailPageState> {
  ListingDetailPageBloc() : super(const ListingDetailPageState());

  /// Drops owner-facing presentation cached from a **different** listing owner
  /// (e.g. after admin reassignment). Without this, async profile/compatibility
  /// loads for the previous owner can finish later and keep the UI stale.
  void invalidateStaleListingOwnerPresentation(int listingOwnerUserId) {
    final s = state;
    final stale =
        (s.ownerNameListingUserId != null &&
            s.ownerNameListingUserId != listingOwnerUserId) ||
        (s.compatibilityListingUserId != null &&
            s.compatibilityListingUserId != listingOwnerUserId);
    if (!stale) return;

    emit(
      ListingDetailPageState(
        isToggling: s.isToggling,
        isDeleting: s.isDeleting,
        complaintsCount: s.complaintsCount,
        complaintsCountListingId: s.complaintsCountListingId,
        isLoadingComplaintsCount: s.isLoadingComplaintsCount,
        viewCount: s.viewCount,
        viewCountListingId: s.viewCountListingId,
        isLoadingViewCount: s.isLoadingViewCount,
        similarListingsCount: s.similarListingsCount,
        similarListingsCountListingId: s.similarListingsCountListingId,
        isLoadingSimilarListingsCount: s.isLoadingSimilarListingsCount,
        nearbyMatchesCount: s.nearbyMatchesCount,
        nearbyMatchesCountListingId: s.nearbyMatchesCountListingId,
        isLoadingNearbyMatchesCount: s.isLoadingNearbyMatchesCount,
      ),
    );
  }

  void setToggling(bool value) =>
      emit(state.copyWith(isToggling: value));

  void setDeleting(bool value) =>
      emit(state.copyWith(isDeleting: value));

  void setComplaintsCount(int listingId, int count) => emit(
        state.copyWith(
          complaintsCount: count,
          complaintsCountListingId: listingId,
          isLoadingComplaintsCount: false,
        ),
      );

  void setLoadingComplaintsCount(int listingId) => emit(
        state.copyWith(
          isLoadingComplaintsCount: true,
          complaintsCountListingId: listingId,
        ),
      );

  void setComplaintsCountError() => emit(
        state.copyWith(isLoadingComplaintsCount: false),
      );

  void setViewCount(int listingId, int count) => emit(
        state.copyWith(
          viewCount: count,
          viewCountListingId: listingId,
          isLoadingViewCount: false,
        ),
      );

  void setLoadingViewCount(int listingId) => emit(
        state.copyWith(
          isLoadingViewCount: true,
          viewCountListingId: listingId,
        ),
      );

  void setViewCountError() => emit(
        state.copyWith(isLoadingViewCount: false),
      );

  void setCompatibilityResult({
    required int listingUserId,
    required List<CompatibilityMatch> matches,
    required List<CompatibilityDifference> differences,
    required List<CompatibilityDifference> dealbreakers,
    required int scoredFieldCount,
    required int totalFieldCount,
    int? percent,
    String? ownerName,
    String? ownerAvatarUrl,
    String? currentUserAvatarUrl,
    bool isGroupCompatibility = false,
    List<ConversationMemberSummary> groupMembers = const [],
    List<GroupCompatibilityFullMatch> groupFullMatches = const [],
    List<GroupCompatibilityPartialMatch> groupPartialMatches = const [],
    List<GroupCompatibilityDiscussItem> groupDiscussItems = const [],
  }) =>
      emit(state.copyWith(
        compatibilityPercent: percent,
        compatibilityListingUserId: listingUserId,
        isLoadingCompatibility: false,
        compatibilityMatches: matches,
        compatibilityDifferences: differences,
        compatibilityDealbreakers: dealbreakers,
        compatibilityScoredFieldCount: scoredFieldCount,
        compatibilityTotalFieldCount: totalFieldCount,
        compatibilityError: null,
        ownerName: ownerName,
        ownerNameListingUserId: listingUserId,
        ownerAvatarUrl: ownerAvatarUrl,
        currentUserAvatarUrl: currentUserAvatarUrl,
        isGroupCompatibility: isGroupCompatibility,
        groupMembers: groupMembers,
        groupFullMatches: groupFullMatches,
        groupPartialMatches: groupPartialMatches,
        groupDiscussItems: groupDiscussItems,
      ));

  void setLoadingCompatibility(int listingUserId) => emit(
        state.copyWith(
          isLoadingCompatibility: true,
          compatibilityListingUserId: listingUserId,
          compatibilityError: null,
          compatibilityPercent: null,
          compatibilityMatches: [],
          compatibilityDifferences: [],
          compatibilityDealbreakers: [],
          compatibilityScoredFieldCount: 0,
          compatibilityTotalFieldCount: 0,
          isGroupCompatibility: false,
          groupMembers: [],
          groupFullMatches: [],
          groupPartialMatches: [],
          groupDiscussItems: [],
        ),
      );

  void setCompatibilityError(String error) => emit(
        state.copyWith(
          isLoadingCompatibility: false,
          compatibilityPercent: null,
          compatibilityMatches: [],
          compatibilityDifferences: [],
          compatibilityDealbreakers: [],
          compatibilityScoredFieldCount: 0,
          compatibilityTotalFieldCount: 0,
          compatibilityError: error,
          isGroupCompatibility: false,
          groupMembers: [],
          groupFullMatches: [],
          groupPartialMatches: [],
          groupDiscussItems: [],
        ),
      );

  void setOwnerName(
    int listingUserId,
    String? name, {
    String? avatarUrl,
  }) =>
      emit(
        state.copyWith(
          ownerName: name,
          ownerNameListingUserId: listingUserId,
          ownerAvatarUrl: avatarUrl,
        ),
      );

  void setLoadingSimilarListingsCount(int listingId) => emit(
        state.copyWith(
          isLoadingSimilarListingsCount: true,
          similarListingsCountListingId: listingId,
        ),
      );

  void setSimilarListingsCount(int listingId, int count) => emit(
        state.copyWith(
          similarListingsCount: count,
          similarListingsCountListingId: listingId,
          isLoadingSimilarListingsCount: false,
        ),
      );

  void setSimilarListingsCountError() => emit(
        state.copyWith(isLoadingSimilarListingsCount: false),
      );

  void setLoadingNearbyMatchesCount(int listingId) => emit(
        state.copyWith(
          isLoadingNearbyMatchesCount: true,
          nearbyMatchesCountListingId: listingId,
        ),
      );

  void setNearbyMatchesCount(int listingId, int count) => emit(
        state.copyWith(
          nearbyMatchesCount: count,
          nearbyMatchesCountListingId: listingId,
          isLoadingNearbyMatchesCount: false,
        ),
      );

  void setNearbyMatchesCountError() => emit(
        state.copyWith(isLoadingNearbyMatchesCount: false),
      );
}
