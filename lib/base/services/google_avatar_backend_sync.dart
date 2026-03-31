import "package:firebase_auth/firebase_auth.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/auth/update_profile_request.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";

/// Persists the Firebase/Google photo URL to [UserProfile.avatarUrl] when it
/// is still empty, so other users can load it from GET /profiles/:id.
Future<void> syncGoogleAvatarToBackendIfMissing({UserProfile? existingProfile}) async {
  final photo = FirebaseAuth.instance.currentUser?.photoURL?.trim();
  if (photo == null || photo.isEmpty) return;

  try {
    final svc = getIt<IUserProfileService>();
    final profile = existingProfile ?? await svc.getCurrentUserProfile();
    final current = profile.avatarUrl?.trim();
    if (current != null && current.isNotEmpty) return;

    await svc.updateProfile(UpdateProfileRequest(avatarUrl: photo));
    final updated = await svc.getCurrentUserProfile();
    await SessionManager.storeUserProfile(updated);
  } catch (_) {
    // Offline, blocked user, or profile missing — ignore
  }
}
