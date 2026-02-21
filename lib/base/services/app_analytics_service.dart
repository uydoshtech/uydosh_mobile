import "package:firebase_analytics/firebase_analytics.dart";

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

  Future<void> logSignInSuccess({required String method}) async {
    await _analytics.logEvent(
      name: "sign_in_success",
      parameters: {"method": method},
    );
  }

  Future<void> logSignInFailure({
    required String method,
    String? errorType,
  }) async {
    await _analytics.logEvent(
      name: "sign_in_failure",
      parameters: {
        "method": method,
        if (errorType != null) "error_type": errorType,
      },
    );
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
    int? listingTypeId,
    int? locationId,
    required bool success,
  }) async {
    await _analytics.logEvent(
      name: "listing_created",
      parameters: {
        "success": success,
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
        if (hasPriceFilter != null) "has_price_filter": hasPriceFilter,
        if (hasGenderFilter != null) "has_gender_filter": hasGenderFilter,
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
