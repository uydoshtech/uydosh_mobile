import "dart:async";

import "package:firebase_analytics/firebase_analytics.dart";
import "package:posthog_flutter/posthog_flutter.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/posthog_bootstrap.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/listing_service.dart";

/// Centralized analytics service wrapping Firebase Analytics + PostHog.
/// Tracks screens, searches, user actions, and key interactions.
///
/// Call sites stay unchanged: every event is dual-written to Firebase and,
/// when [PosthogBootstrap.isEnabled], to PostHog.
class AppAnalyticsService {
  AppAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  /// Get the underlying FirebaseAnalytics instance for FirebaseAnalyticsObserver.
  FirebaseAnalytics get firebaseAnalytics => _analytics;

  // ─────────────────────────────────────────────────────────────────────────
  // Dual-write helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _capture(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
    await _posthogCapture(name, parameters);
  }

  Future<void> _posthogCapture(
    String name,
    Map<String, Object>? parameters,
  ) async {
    if (!PosthogBootstrap.isEnabled) return;
    try {
      await Posthog().capture(eventName: name, properties: parameters);
    } catch (_) {
      // Analytics must never break product flows.
    }
  }

  Future<void> _posthogScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (!PosthogBootstrap.isEnabled) return;
    try {
      await Posthog().screen(
        screenName: screenName,
        properties: screenClass != null ? {"screen_class": screenClass} : null,
      );
    } catch (_) {}
  }

  Future<void> _posthogIdentify(String userId) async {
    if (!PosthogBootstrap.isEnabled) return;
    try {
      await Posthog().identify(userId: userId);
    } catch (_) {}
  }

  Future<void> _posthogReset() async {
    if (!PosthogBootstrap.isEnabled) return;
    try {
      await Posthog().reset();
    } catch (_) {}
  }

  Future<void> _posthogSetPersonProperties(Map<String, Object> properties) async {
    if (!PosthogBootstrap.isEnabled || properties.isEmpty) return;
    try {
      await Posthog().setPersonProperties(userPropertiesToSet: properties);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // App lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  /// Call when app is opened.
  Future<void> logAppOpened({String? source}) async {
    await _capture(
      "app_opened",
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
    final resolvedClass = screenClass ?? screenName;
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: resolvedClass,
    );
    await _posthogScreen(screenName: screenName, screenClass: resolvedClass);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Onboarding
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logOnboardingStarted() async {
    await _capture("onboarding_started");
  }

  Future<void> logOnboardingCompleted({int? pageCount}) async {
    await _capture(
      "onboarding_completed",
      parameters: pageCount != null ? {"page_count": pageCount} : null,
    );
  }

  Future<void> logOnboardingSkipped({int? pageIndex}) async {
    await _capture(
      "onboarding_skipped",
      parameters: pageIndex != null ? {"page_index": pageIndex} : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Authentication
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logSignInStarted({required String method}) async {
    await _capture(
      "sign_in_started",
      parameters: {"method": method},
    );
  }

  /// Standard GA4/Firebase "login" event (recommended).
  /// See: FirebaseAnalytics.logLogin
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
    await _posthogCapture("login", {"method": method});
  }

  Future<void> logSignInSuccess({required String method}) async {
    await SessionManager.storeAuthMethod(method);
    // Also emit the standard GA4 "login" event for easier reporting.
    await logLogin(method: method);
    await _capture(
      "sign_in_success",
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
    await _capture(
      "sign_in_cancelled",
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
    await _capture(
      "sign_in_failure",
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

    await _capture("login_error", parameters: parameters);
  }

  Future<void> logSignOut() async {
    await _capture("sign_out");
  }

  Future<void> logProfileCreated() async {
    await _capture("profile_created");
  }

  /// Set user ID for analytics (call after sign-in). Use hashed ID for privacy.
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    if (userId == null || userId.isEmpty) {
      await _posthogReset();
    } else {
      await _posthogIdentify(userId);
    }
  }

  /// Sync GA4 / PostHog user properties from the cached session (profile + role).
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

  /// Push profile-derived user properties to Firebase Analytics + PostHog.
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

    final posthogProps = <String, Object>{
      for (final entry in properties.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    await _posthogSetPersonProperties(posthogProps);

    if (hasActiveListing == null) {
      unawaited(refreshHasActiveListingProperty());
    }
  }

  /// Re-fetch whether the user has any active listing and update GA4 / PostHog.
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
    // PostHog person props are cleared via [setUserId] → reset on logout.
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

  Future<void> _setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
    if (value != null) {
      await _posthogSetPersonProperties({name: value});
    }
  }

  /// Compact user context for event params (not PII — backend user id + profile buckets).
  Future<Map<String, Object>> _userContextEventParams() async {
    final params = <String, Object>{};

    final userId = await SessionManager.getBackendUserId();
    if (userId != null) params["user_id"] = userId;

    final role = await SessionManager.getUserRole();
    if (role != null && role.isNotEmpty) params["user_role"] = role;

    final authMethod = await SessionManager.getAuthMethod();
    if (authMethod != null && authMethod.isNotEmpty) {
      params["auth_method"] = authMethod;
    }

    final profile = await SessionManager.getCachedUserProfile();
    if (profile != null) {
      final gender = _genderPropertyValue(profile.gender);
      if (gender != null) params["gender"] = gender;
      params["is_student"] = profile.universityId != null ? "true" : "false";
      final regionId = profile.regionId;
      if (regionId != null) params["region_id"] = regionId;
      params["profile_completion_pct"] = _profileCompletionBucket(profile);
      if (profile.isVerified == true) params["is_verified"] = "true";
      final appLanguage = await SessionManager.getAppLanguage();
      final normalizedLang = _normalizeLanguageCode(appLanguage);
      if (normalizedLang != null) params["app_language"] = normalizedLang;
    }

    return params;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Listings
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logListingViewed({
    required int listingId,
    String? source,
  }) async {
    await _capture(
      "listing_viewed",
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
    await _capture(
      "listing_created",
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
    await _capture(
      "listing_published",
      parameters: {
        "listing_id": listingId,
        "source": source,
        if (listingTypeId != null) "listing_type_id": listingTypeId,
        if (locationId != null) "location_id": locationId,
      },
    );
  }

  /// User tapped Publish / Create listing (before API call).
  /// Includes compact session user context for funnel breakdowns.
  Future<void> logListingPublishTapped({
    required String flow,
    int? listingTypeId,
    int? listingId,
    int? photoCount,
  }) async {
    final parameters = <String, Object>{
      "flow": flow,
      ...(await _userContextEventParams()),
      if (listingTypeId != null) "listing_type_id": listingTypeId,
      if (listingId != null) "listing_id": listingId,
      if (photoCount != null) "photo_count": photoCount,
    };
    await _capture(
      "listing_publish_tapped",
      parameters: parameters,
    );
  }

  Future<void> logListingEdited({required int listingId}) async {
    await _capture(
      "listing_edited",
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
    await _capture(
      "search_performed",
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
    await _capture(
      "favorite_added",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logFavoriteRemoved({required int listingId}) async {
    await _capture(
      "favorite_removed",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logShareInitiated({required int listingId}) async {
    await _capture(
      "share_initiated",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logShareCompleted({required int listingId}) async {
    await _capture(
      "share_completed",
      parameters: {"listing_id": listingId},
    );
  }

  Future<void> logContactUserTapped({
    int? listingId,
    int? ownerId,
  }) async {
    await _capture(
      "contact_user_tapped",
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
    await _capture(
      "owner_profile_viewed",
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
    await _capture(
      "conversation_started",
      parameters: {
        "listing_id": listingId,
        if (ownerId != null) "owner_id": ownerId,
      },
    );
  }

  Future<void> logMessageSent({int? conversationId}) async {
    await _capture(
      "message_sent",
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
    await _capture(
      "quick_question_tapped",
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
    await _capture(
      "chat_opened",
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
    await _capture(
      "achievement_unlocked",
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
    await _capture(
      "deep_link_opened",
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
    await _capture(
      "language_changed",
      parameters: {
        "from_language": fromLanguage,
        "to_language": toLanguage,
      },
    );
  }

  Future<void> logThemeChanged({required String theme}) async {
    await _capture(
      "theme_changed",
      parameters: {"theme": theme},
    );
  }

  Future<void> logFaqOpened() async {
    await _capture("faq_opened");
  }

  Future<void> logComplaintSubmitted({
    required int listingId,
    String? complaintType,
  }) async {
    await _capture(
      "complaint_submitted",
      parameters: {
        "listing_id": listingId,
        if (complaintType != null) "complaint_type": complaintType,
      },
    );
  }
}
