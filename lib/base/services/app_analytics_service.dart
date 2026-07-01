import "dart:async";

import "package:firebase_analytics/firebase_analytics.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/listing_service.dart";

/// Centralized analytics service wrapping Firebase Analytics.
/// Tracks screens, searches, user actions, and key interactions.
class AppAnalyticsService {
  AppAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  /// Get the underlying FirebaseAnalytics instance for FirebaseAnalyticsObserver.
  FirebaseAnalytics get firebaseAnalytics => _analytics;

  // ─────────────────────────────────────────────────────────────────────────
  // App lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  /// Call when app is opened.
  Future<void> logAppOpened({String? source}) async {
    await _analytics.logEvent(
      name: "app_opened",
      parameters: source != null ? {"source": source} : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Screen tracking
  // ─────────────────────────────────────────────────────────────────────────

  /// Log a screen view. Call from initState of screens.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Onboarding
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logOnboardingStarted() async {
    await _analytics.logEvent(name: "onboarding_started");
  }

  Future<void> logOnboardingCompleted({int? pageCount}) async {
    await _analytics.logEvent(
      name: "onboarding_completed",
      parameters: pageCount != null ? {"page_count": pageCount} : null,
    );
  }

  Future<void> logOnboardingSkipped({int? pageIndex}) async {
    await _analytics.logEvent(
      name: "onboarding_skipped",
      parameters: pageIndex != null ? {"page_index": pageIndex} : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Authentication
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logSignInStarted({required String method}) async {
    await _analytics.logEvent(
      name: "sign_in_started",
      parameters: {"method": method},
    );
  }

  /// Standard GA4/Firebase "login" event (recommended).
  /// See: FirebaseAnalytics.logLogin
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignInSuccess({required String method}) async {
    await SessionManager.storeAuthMethod(method);
    // Also emit the standard GA4 "login" event for easier reporting.
    await logLogin(method: method);
    await _analytics.logEvent(
      name: "sign_in_success",
      parameters: {"method": method},
    );
  }

  /// User dismissed the sign-in flow (closed Google sheet, hit cancel, etc.).
  /// Not an error — emitted as a separate event so funnels can distinguish
  /// "cancelled by user" from "actually failed".
  Future<void> logSignInCancelled({
    required String method,
    String? stage,
    String? reason,
  }) async {
    await _analytics.logEvent(
      name: "sign_in_cancelled",
      parameters: {
        "method": method,
        if (stage != null) "stage": stage,
        if (reason != null) "reason": reason,
      },
    );
  }

  Future<void> logSignInFailure({
    required String method,
    String? stage,
    String? errorCode,
    String? errorType,
  }) async {
    await _analytics.logEvent(
      name: "sign_in_failure",
      parameters: {
        "method": method,
        if (stage != null) "stage": stage,
        if (errorCode != null) "error_code": errorCode,
        if (errorType != null) "error_type": errorType,
      },
    );
  }

  /// More detailed login error event for debugging funnels.
  /// Keep params compact (GA4 parameter limits apply).
  Future<void> logLoginError({
    required String method,
    required String stage,
    String? errorCode,
    String? errorMessage,
  }) async {
    String? truncatedMessage;
    if (errorMessage != null) {
      final msg = errorMessage.trim();
      if (msg.isNotEmpty) {
        truncatedMessage = msg.length > 120 ? msg.substring(0, 120) : msg;
      }
    }

    final parameters = <String, Object>{
      "method": method,
      "stage": stage,
    };
    if (errorCode != null) parameters["error_code"] = errorCode;
    if (truncatedMessage != null) parameters["message"] = truncatedMessage;

    await _analytics.logEvent(name: "login_error", parameters: parameters);
  }

  Future<void> logSignOut() async {
    await _analytics.logEvent(name: "sign_out");
  }

  Future<void> logProfileCreated() async {
    await _analytics.logEvent(name: "profile_created");
  }

  /// Set user ID for analytics (call after sign-in). Use hashed ID for privacy.
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Sync GA4 user properties from the cached session (profile + role).
  Future<void> syncUserPropertiesFromSession() async {
    final profile = await SessionManager.getCachedUserProfile();
    if (profile == null) return;
    final role = await SessionManager.getUserRole();
    final authMethod = await SessionManager.getAuthMethod();
    final appLanguage = await SessionManager.getAppLanguage();
    await syncUserProfileProperties(
      profile: profile,
      role: role,
      authMethod: authMethod,
      appLanguage: appLanguage,
    );
  }

  /// Push profile-derived user properties to GA4/Firebase Analytics.
  ///
  /// Register matching custom definitions in GA4 Admin → Custom definitions
  /// (scope: User) before using them in explorations and audiences.
  Future<void> syncUserProfileProperties({
    required UserProfile profile,
    String? role,
    String? authMethod,
    String? appLanguage,
    bool? hasActiveListing,
  }) async {
    final resolvedAuthMethod =
        authMethod ?? await SessionManager.getAuthMethod();
    final resolvedAppLanguage =
        appLanguage ?? await SessionManager.getAppLanguage();

    final properties = <String, String?>{
      "gender": _genderPropertyValue(profile.gender),
      "is_student": profile.universityId != null ? "true" : "false",
      "university_code": _universityCode(profile),
      "user_role": role != null && role.isNotEmpty ? role : null,
      "region_id": profile.regionId?.toString(),
      "is_verified": profile.isVerified == true ? "true" : "false",
      "auth_method": resolvedAuthMethod,
      "preferred_language": _normalizeLanguageCode(profile.preferredLanguage),
      "profile_completion_pct": _profileCompletionBucket(profile),
      "origin_country_iso2": profile.originCountryIso2?.toUpperCase(),
      "employed": _boolPropertyValue(profile.employed),
      "has_active_listing": hasActiveListing == null
          ? null
          : (hasActiveListing ? "true" : "false"),
      "account_age_days": _accountAgeBucket(profile.createdAt),
      "app_language": _normalizeLanguageCode(resolvedAppLanguage),
      "smoking_preference": profile.smokingPreference,
      "pets_preference": profile.petsPreference,
      "noise_level": profile.noiseLevel?.toString(),
    };

    await Future.wait(
      properties.entries.map((entry) => _setUserProperty(entry.key, entry.value)),
    );

    if (hasActiveListing == null) {
      unawaited(refreshHasActiveListingProperty());
    }
  }

  /// Re-fetch whether the user has any active listing and update GA4.
  Future<void> refreshHasActiveListingProperty() async {
    final hasActiveListing = await _resolveHasActiveListing();
    if (hasActiveListing == null) return;
    await _setUserProperty(
      "has_active_listing",
      hasActiveListing ? "true" : "false",
    );
  }

  /// Update only the UI language user property (e.g. after in-app switch).
  Future<void> syncAppLanguageProperty(String language) async {
    await _setUserProperty(
      "app_language",
      _normalizeLanguageCode(language),
    );
  }

  /// Clear profile-scoped user properties on logout.
  Future<void> clearUserProperties() async {
    const propertyNames = [
      "gender",
      "is_student",
      "university_code",
      "user_role",
      "region_id",
      "is_verified",
      "auth_method",
      "preferred_language",
      "profile_completion_pct",
      "origin_country_iso2",
      "employed",
      "has_active_listing",
      "account_age_days",
      "app_language",
      "smoking_preference",
      "pets_preference",
      "noise_level",
    ];
    await Future.wait(
      propertyNames.map(
        (name) => _analytics.setUserProperty(name: name, value: null),
      ),
    );
  }

  String? _genderPropertyValue(int? gender) {
    return switch (gender) {
      1 => "male",
      2 => "female",
      _ => null,
    };
  }

  String? _boolPropertyValue(bool? value) {
    if (value == null) return null;
    return value ? "true" : "false";
  }

  String? _normalizeLanguageCode(String? language) {
    final normalized = language?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  String _profileCompletionBucket(UserProfile profile) {
    final percent = ProfileCompletionState.completionPercent(profile);
    if (percent <= 25) return "0-25";
    if (percent <= 50) return "26-50";
    if (percent <= 75) return "51-75";
    return "76-100";
  }

  String? _accountAgeBucket(String? createdAt) {
    if (createdAt == null || createdAt.trim().isEmpty) return null;
    try {
      final created = DateTime.parse(createdAt);
      final days = DateTime.now().difference(created).inDays;
      if (days <= 7) return "0-7";
      if (days <= 30) return "8-30";
      if (days <= 90) return "31-90";
      return "90+";
    } catch (_) {
      return null;
    }
  }

  String? _universityCode(UserProfile profile) {
    if (profile.universityId == null) return null;
    final shortName = profile.university?.shortNameEn?.trim();
    if (shortName != null && shortName.isNotEmpty) return shortName;
    return profile.universityId.toString();
  }

  Future<bool?> _resolveHasActiveListing() async {
    if (!getIt.isRegistered<IListingService>()) return null;
    try {
      final response = await getIt<IListingService>().getUserListings(
        page: 1,
        limit: 50,
      );
      return response.data.any((listing) => listing.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> _setUserProperty(String name, String? value) {
    return _analytics.setUserProperty(name: name, value: value);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Listings
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logListingViewed({
    required int listingId,
    String? source,
  }) async {
    await _analytics.logEvent(
      name: "listing_viewed",
      parameters: {
        "listing_id": listingId,
        if (source != null) "source": source,
      },
    );
  }

  Future<void> logListingCreated({
    required bool success, int? listingTypeId,
    int? locationId,
  }) async {
    await _analytics.logEvent(
      name: "listing_created",
      parameters: {
        "success": success.toString(),
        if (listingTypeId != null) "listing_type_id": listingTypeId,
        if (locationId != null) "location_id": locationId,
      },
    );
  }

  /// Listing went live or was republished (create, edit, reactivate, moderation).
  Future<void> logListingPublished({
    required int listingId,
    required String source,
    int? listingTypeId,
    int? locationId,
  }) async {
    await _analytics.logEvent(
      name: "listing_published",
      parameters: {
        "listing_id": listingId,
        "source": source,
        if (listingTypeId != null) "listing_type_id": listingTypeId,
        if (locationId != null) "location_id": locationId,
      },
    );
  }

  Future<void> logListingEdited({required int listingId}) async {
    await _analytics.logEvent(
      name: "listing_edited",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logSearchPerformed({
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    int? subwayLineId,
    int? gender,
    bool? hasPriceFilter,
    bool? hasGenderFilter,
  }) async {
    await _analytics.logEvent(
      name: "search_performed",
      parameters: {
        if (listingTypeId != null) "listing_type_id": listingTypeId,
        if (locationId != null) "location_id": locationId,
        if (subwayStationId != null) "subway_station_id": subwayStationId,
        if (subwayLineId != null) "subway_line_id": subwayLineId,
        if (gender != null) "gender": gender,
        if (hasPriceFilter != null) "has_price_filter": hasPriceFilter.toString(),
        if (hasGenderFilter != null) "has_gender_filter": hasGenderFilter.toString(),
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Engagement
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logFavoriteAdded({required int listingId}) async {
    await _analytics.logEvent(
      name: "favorite_added",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logFavoriteRemoved({required int listingId}) async {
    await _analytics.logEvent(
      name: "favorite_removed",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logShareInitiated({required int listingId}) async {
    await _analytics.logEvent(
      name: "share_initiated",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logShareCompleted({required int listingId}) async {
    await _analytics.logEvent(
      name: "share_completed",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logContactUserTapped({
    int? listingId,
    int? ownerId,
  }) async {
    await _analytics.logEvent(
      name: "contact_user_tapped",
      parameters: {
        if (listingId != null) "listing_id": listingId,
        if (ownerId != null) "owner_id": ownerId,
      },
    );
  }

  Future<void> logOwnerProfileViewed({
    required int ownerId,
    int? listingId,
  }) async {
    await _analytics.logEvent(
      name: "owner_profile_viewed",
      parameters: {
        "owner_id": ownerId,
        if (listingId != null) "listing_id": listingId,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Messaging
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logConversationStarted({
    required int listingId,
    int? ownerId,
  }) async {
    await _analytics.logEvent(
      name: "conversation_started",
      parameters: {
        "listing_id": listingId,
        if (ownerId != null) "owner_id": ownerId,
      },
    );
  }

  Future<void> logMessageSent({int? conversationId}) async {
    await _analytics.logEvent(
      name: "message_sent",
      parameters: conversationId != null
          ? {"conversation_id": conversationId}
          : null,
    );
  }

  Future<void> logQuickQuestionTapped({
    required String questionKey,
    required bool isViewerListingOwner,
    required bool isViewerServiceOfferer,
    int? conversationId,
    int? listingId,
    int? listingTypeId,
  }) async {
    await _analytics.logEvent(
      name: "quick_question_tapped",
      parameters: {
        "question_key": questionKey,
        "is_viewer_listing_owner": isViewerListingOwner ? 1 : 0,
        "is_viewer_service_offerer": isViewerServiceOfferer ? 1 : 0,
        if (conversationId != null) "conversation_id": conversationId,
        if (listingId != null) "listing_id": listingId,
        if (listingTypeId != null) "listing_type_id": listingTypeId,
      },
    );
  }

  Future<void> logChatOpened({
    int? conversationId,
    int? listingId,
  }) async {
    await _analytics.logEvent(
      name: "chat_opened",
      parameters: {
        if (conversationId != null) "conversation_id": conversationId,
        if (listingId != null) "listing_id": listingId,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Gamification
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementKey,
    String? category,
  }) async {
    await _analytics.logEvent(
      name: "achievement_unlocked",
      parameters: {
        "achievement_id": achievementId,
        "achievement_key": achievementKey,
        if (category != null) "category": category,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Deep links
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logDeepLinkOpened({
    required int listingId,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: "deep_link_opened",
      parameters: {
        "listing_id": listingId,
        "source": source,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Settings & preferences
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logLanguageChanged({
    required String fromLanguage,
    required String toLanguage,
  }) async {
    await _analytics.logEvent(
      name: "language_changed",
      parameters: {
        "from_language": fromLanguage,
        "to_language": toLanguage,
      },
    );
  }

  Future<void> logThemeChanged({required String theme}) async {
    await _analytics.logEvent(
      name: "theme_changed",
      parameters: {"theme": theme},
    );
  }

  Future<void> logFaqOpened() async {
    await _analytics.logEvent(name: "faq_opened");
  }

  Future<void> logComplaintSubmitted({
    required int listingId,
    String? complaintType,
  }) async {
    await _analytics.logEvent(
      name: "complaint_submitted",
      parameters: {
        "listing_id": listingId,
        if (complaintType != null) "complaint_type": complaintType,
      },
    );
  }
}
