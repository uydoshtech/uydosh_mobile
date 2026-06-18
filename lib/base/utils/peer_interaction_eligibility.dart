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

  static const String _internalChatDisabledPublisherEmail =
      "uydoshtech@gmail.com";

  /// True when the signed-in viewer is the publisher of this entity.
  ///
  /// Pass [viewerUserIdFallback] while [UserListingState] is still hydrating so
  /// we do not briefly treat the publisher as a guest viewer (e.g. "Chat with
  /// yourself" on listing detail).
  static bool isPublisher({
    required int publisherUserId,
    int? viewerUserIdFallback,
  }) {
    if (UserListingState().isOwner(publisherUserId)) return true;
    final resolvedUid =
        UserListingState().currentUserId ?? viewerUserIdFallback;
    return resolvedUid != null && resolvedUid == publisherUserId;
  }

  /// Signed in and not the user who published this entity.
  static bool mayInteractWithPublisher({
    required int publisherUserId,
    int? viewerUserIdFallback,
  }) {
    if (!AuthenticationState().isAuthenticated) return false;
    if (isPublisher(
      publisherUserId: publisherUserId,
      viewerUserIdFallback: viewerUserIdFallback,
    )) {
      return false;
    }
    final resolvedUid =
        UserListingState().currentUserId ?? viewerUserIdFallback;
    // Viewer identity not ready yet — hide peer actions until we know.
    if (resolvedUid == null) return false;
    return true;
  }

  /// Listings imported/published under the UyDosh admin account should not
  /// accept in-app peer chat, even for staff viewers.
  static bool isInternalListingChatDisabledForPublisherEmail(
    String? publisherEmail,
  ) {
    return publisherEmail?.trim().toLowerCase() ==
        _internalChatDisabledPublisherEmail;
  }
}
