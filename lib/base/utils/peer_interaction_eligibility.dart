import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";

/// Shared rules for UI that only applies when the signed-in user is **not** the
/// publisher of the content (favorite heart, starting chats, similar flows).
///
/// [publisherUserId] is the listing author id, gig service provider id, task
/// client id, etc.
///
/// When [UserListingState] has not hydrated [UserListingState.currentUserId] yet,
/// pass [viewerUserIdFallback] (for example a session uid loaded in parallel) so
/// we do not briefly treat the publisher as a guest viewer.
final class PeerInteractionEligibility {
  const PeerInteractionEligibility._();

  /// Signed in and not the user who published this entity.
  static bool mayInteractWithPublisher({
    required int publisherUserId,
    int? viewerUserIdFallback,
  }) {
    if (!AuthenticationState().isAuthenticated) return false;
    if (UserListingState().isOwner(publisherUserId)) return false;
    final resolvedUid =
        UserListingState().currentUserId ?? viewerUserIdFallback;
    if (resolvedUid != null && resolvedUid == publisherUserId) return false;
    return true;
  }
}
