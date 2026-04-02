import "package:flutter_bloc/flutter_bloc.dart";
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
    this.compatibilityError,
    this.ownerName,
    this.ownerNameListingUserId,
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
  final String? compatibilityError;
  final String? ownerName;
  final int? ownerNameListingUserId;

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
    String? compatibilityError,
    String? ownerName,
    int? ownerNameListingUserId,
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
      compatibilityError: compatibilityError ?? this.compatibilityError,
      ownerName: ownerName ?? this.ownerName,
      ownerNameListingUserId:
          ownerNameListingUserId ?? this.ownerNameListingUserId,
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
        other.compatibilityError == compatibilityError &&
        other.ownerName == ownerName &&
        other.ownerNameListingUserId == ownerNameListingUserId;
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
      ]);
}

/// Cubit for listing detail page-level state. Replaces setState calls.
class ListingDetailPageBloc extends Cubit<ListingDetailPageState> {
  ListingDetailPageBloc() : super(const ListingDetailPageState());

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
    required List<CompatibilityMatch> matches, required List<CompatibilityDifference> differences, int? percent,
    String? ownerName,
  }) =>
      emit(state.copyWith(
        compatibilityPercent: percent,
        compatibilityListingUserId: listingUserId,
        isLoadingCompatibility: false,
        compatibilityMatches: matches,
        compatibilityDifferences: differences,
        compatibilityError: null,
        ownerName: ownerName,
        ownerNameListingUserId: listingUserId,
      ));

  void setLoadingCompatibility(int listingUserId) => emit(
        state.copyWith(
          isLoadingCompatibility: true,
          compatibilityListingUserId: listingUserId,
          compatibilityError: null,
          compatibilityPercent: null,
          compatibilityMatches: [],
          compatibilityDifferences: [],
        ),
      );

  void setCompatibilityError(String error) => emit(
        state.copyWith(
          isLoadingCompatibility: false,
          compatibilityPercent: null,
          compatibilityMatches: [],
          compatibilityDifferences: [],
          compatibilityError: error,
        ),
      );

  void setOwnerName(int listingUserId, String? name) => emit(
        state.copyWith(
          ownerName: name,
          ownerNameListingUserId: listingUserId,
        ),
      );
}
