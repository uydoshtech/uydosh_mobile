import "package:flutter/foundation.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/user_profile.dart";

/// Global state to track profile completion status.
/// Used to show the blinking green dot indicator on the profile icon in the app bar.
class ProfileCompletionState extends ChangeNotifier {
  factory ProfileCompletionState() => _instance;
  ProfileCompletionState._internal();
  static final ProfileCompletionState _instance =
      ProfileCompletionState._internal();

  bool _isProfileComplete = true; // Default to true to avoid showing badge initially
  bool _hasEssentialInfo = true;
  bool _isInitialized = false;

  /// Last known backend [UserProfile.avatarUrl] (may be relative). Used for app bar avatar.
  String? _cachedAvatarUrl;

  /// Whether the profile is 100% complete
  bool get isProfileComplete => _isProfileComplete;

  /// Whether essential info (name, gender, region, role, university if student) is populated
  bool get hasEssentialInfo => _hasEssentialInfo;

  /// Whether the profile needs completion (show blinking dot).
  /// True when not yet loaded (assume incomplete), or when profile is not 100%
  /// complete OR essential info is missing.
  bool get needsProfileCompletion =>
      !_isInitialized || !_isProfileComplete || !_hasEssentialInfo;

  /// Whether the state has been initialized with profile data
  bool get isInitialized => _isInitialized;

  /// Raw avatar URL from the last [updateFromProfile] call (same as [UserProfile.avatarUrl]).
  String? get cachedAvatarUrl => _cachedAvatarUrl;

  /// Calculate profile completion percent (0-100). Shared utility for app_router and profile_screen.
  static int completionPercent(UserProfile profile) {
    return _calculateProfileCompletionPercent(profile);
  }

  /// Update from user profile. Call when profile is loaded or updated.
  void updateFromProfile(UserProfile? profile) {
    if (profile == null) {
      _isProfileComplete = true;
      _hasEssentialInfo = true;
      _isInitialized = false;
      _cachedAvatarUrl = null;
      notifyListeners();
      return;
    }

    final percent = _calculateProfileCompletionPercent(profile);
    final isComplete = percent >= 100;
    final hasEssential = _checkHasEssentialInfo(profile);
    final newAvatarUrl = profile.avatarUrl;
    final avatarChanged = _cachedAvatarUrl != newAvatarUrl;
    _cachedAvatarUrl = newAvatarUrl;

    if (!isComplete && kDebugMode) {
      final missing = getMissingFields(profile);
      logger.d(
        "Profile not 100% complete ($percent%). Missing fields: ${missing.join(", ")}",
      );
    }

    if (_isProfileComplete != isComplete ||
        _hasEssentialInfo != hasEssential ||
        !_isInitialized ||
        avatarChanged) {
      _isProfileComplete = isComplete;
      _hasEssentialInfo = hasEssential;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Reset state (e.g. on logout)
  void reset() {
    _isProfileComplete = true;
    _hasEssentialInfo = true;
    _isInitialized = false;
    _cachedAvatarUrl = null;
    notifyListeners();
  }

  /// Essential info: name, gender, region, employed (role/student status).
  /// If employed=false (student), university is also required.
  static bool _checkHasEssentialInfo(UserProfile profile) {
    if (!_hasText(profile.name)) return false;
    if (profile.gender == null) return false;
    if (profile.region == null && profile.regionId == null) return false;
    if (profile.employed == null) return false;
    if (profile.employed == false &&
        profile.university == null &&
        profile.universityId == null) {
      return false;
    }
    return true;
  }

  static int _calculateProfileCompletionPercent(UserProfile profile) {
    // Non-students (employed=true) don't need university; total = 16. Students need 17.
    final totalFields = profile.employed ?? false ? 16 : 17;
    final completedFields = _countCompletedProfileFields(profile);
    return ((completedFields / totalFields) * 100).round();
  }

  static int _countCompletedProfileFields(UserProfile profile) {
    var completedFields = 0;

    if (_hasText(profile.name)) completedFields++;
    if (profile.gender != null) completedFields++;
    // Either the joined `region` object or the raw `regionId` counts as
    // "region filled". Some API responses (e.g. PUT /profiles/:id) return
    // only the id without the joined object, so checking one is not enough.
    if (profile.region != null || profile.regionId != null) completedFields++;
    if (profile.employed == false) {
      if (profile.university != null || profile.universityId != null) {
        completedFields++;
      }
    }
    if (_hasText(profile.aboutMe)) completedFields++;
    if (_hasText(profile.telegram)) completedFields++;
    if (profile.employed != null) completedFields++;
    if (profile.cleanliness != null) completedFields++;
    if (profile.noiseLevel != null) completedFields++;
    if (profile.sociability != null) completedFields++;
    if (profile.guestsAllowed != null) completedFields++;
    if (_hasText(profile.smokingPreference)) completedFields++;
    if (_hasText(profile.alcoholPreference)) completedFields++;
    if (profile.cookingHabits != null) completedFields++;
    if (profile.petsPreference != null) completedFields++;
    if (_hasText(profile.wakeupTime)) completedFields++;
    if (_hasText(profile.sleepTime)) completedFields++;

    return completedFields;
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Returns list of field names that are not populated (for debug).
  /// Aligned with _countCompletedProfileFields. University only when employed=false (student).
  static List<String> getMissingFields(UserProfile profile) {
    final missing = <String>[];
    if (!_hasText(profile.name)) missing.add("name");
    if (profile.gender == null) missing.add("gender");
    if (profile.region == null && profile.regionId == null) missing.add("region");
    if (profile.employed == null) missing.add("employed");
    if (profile.employed == false &&
        profile.university == null &&
        profile.universityId == null) {
      missing.add("university");
    }
    if (!_hasText(profile.aboutMe)) missing.add("aboutMe");
    if (!_hasText(profile.telegram)) missing.add("telegram");
    if (profile.cleanliness == null) missing.add("cleanliness");
    if (profile.noiseLevel == null) missing.add("noiseLevel");
    if (profile.sociability == null) missing.add("sociability");
    if (profile.guestsAllowed == null) missing.add("guestsAllowed");
    if (!_hasText(profile.smokingPreference)) missing.add("smokingPreference");
    if (!_hasText(profile.alcoholPreference)) missing.add("alcoholPreference");
    if (profile.cookingHabits == null) missing.add("cookingHabits");
    if (profile.petsPreference == null) missing.add("petsPreference");
    if (!_hasText(profile.wakeupTime)) missing.add("wakeupTime");
    if (!_hasText(profile.sleepTime)) missing.add("sleepTime");
    return missing;
  }
}
