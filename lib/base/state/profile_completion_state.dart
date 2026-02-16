import 'package:flutter/foundation.dart';
import 'package:uy_dosh/domain/models/user_profile.dart';

/// Global state to track profile completion status.
/// Used to show the blinking green dot indicator on the profile icon in the app bar.
class ProfileCompletionState extends ChangeNotifier {
  static final ProfileCompletionState _instance =
      ProfileCompletionState._internal();
  factory ProfileCompletionState() => _instance;
  ProfileCompletionState._internal();

  bool _isProfileComplete = true; // Default to true to avoid showing badge initially
  bool _hasEssentialInfo = true;
  bool _isInitialized = false;

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
      notifyListeners();
      return;
    }

    final percent = _calculateProfileCompletionPercent(profile);
    final isComplete = percent >= 100;
    final hasEssential = _checkHasEssentialInfo(profile);

    if (_isProfileComplete != isComplete ||
        _hasEssentialInfo != hasEssential ||
        !_isInitialized) {
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
        profile.universityId == null) return false;
    return true;
  }

  static int _calculateProfileCompletionPercent(UserProfile profile) {
    const totalFields = 17;
    final completedFields = _countCompletedProfileFields(profile);
    return ((completedFields / totalFields) * 100).round();
  }

  static int _countCompletedProfileFields(UserProfile profile) {
    var completedFields = 0;

    if (_hasText(profile.name)) completedFields++;
    if (profile.gender != null) completedFields++;
    if (profile.region != null) completedFields++;
    if (profile.university != null) completedFields++;
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
}
