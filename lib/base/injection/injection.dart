import "package:get_it/get_it.dart";
import "package:uy_dosh/base/api/auth_token_repository.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/api/oauth_dio_configurator.dart";
import "package:uy_dosh/base/api/public_dio_configurator.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/domain/services/admin_area_price_cache_service.dart";
import "package:uy_dosh/domain/services/admin_content_moderation_settings_service.dart";
import "package:uy_dosh/domain/services/admin_telegram_sync_service.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/domain/services/amenity_service.dart";
import "package:uy_dosh/domain/services/auth_service.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/listing_creation_analytics_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/domain/services/otp_service.dart";
import "package:uy_dosh/domain/services/otp_service_impl.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/region_service.dart";
import "package:uy_dosh/domain/services/search_analytics_service.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/domain/services/support_chat_service.dart";
import "package:uy_dosh/domain/services/university_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<AppAnalyticsService>(AppAnalyticsService.new);
  // Register services with meaningful names
  getIt.registerLazySingleton<IPublicDioConfigurator>(
    PublicDioConfigurator.new,
  );

  getIt.registerLazySingleton<IPublicApiClient>(
    () => PublicApiClient(configurator: getIt<IPublicDioConfigurator>()),
  );

  getIt.registerLazySingleton<IPublicAppSettingsService>(
    () => PublicAppSettingsService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<GeminiService>(
    () => GeminiService(publicApiClient: getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<ILocationService>(
    () => LocationService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<ISubwayStationService>(
    () => SubwayStationService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<IOAuthApiClient>(
    () => OAuthApiClient(
      configurator: OAuthDioConfigurator(tokenRepo: AuthTokenRepository()),
    ),
  );

  getIt.registerLazySingleton<IListingService>(
    () => ListingService(getIt<IPublicApiClient>(), getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IFavoriteService>(
    () => FavoriteService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IUserProfileService>(
    () =>
        UserProfileService(getIt<IPublicApiClient>(), getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IAmenityService>(
    () => AmenityService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<IUniversityService>(
    () => UniversityService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<IRegionService>(
    () => RegionService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<IAuthService>(
    () => AuthService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<IOtpService>(
    () => OtpService(getIt<IPublicApiClient>()),
  );

  getIt.registerLazySingleton<IMessagingService>(
    () => MessagingService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IComplaintService>(
    () => ComplaintService(getIt<IPublicApiClient>(), getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IAdminUserService>(
    () => AdminUserService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<ISearchAnalyticsService>(
    () => SearchAnalyticsService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IAdminContentModerationSettingsService>(
    () => AdminContentModerationSettingsService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IAdminTelegramSyncService>(
    () => AdminTelegramSyncService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IAdminAreaPriceCacheService>(
    () => AdminAreaPriceCacheService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IListingCreationAnalyticsService>(
    () => ListingCreationAnalyticsService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IGamificationService>(
    () => GamificationService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<ISupportChatService>(
    () => SupportChatService(getIt<IOAuthApiClient>()),
  );

  getIt.registerLazySingleton<IPushNotificationService>(
    () => PushNotificationService(getIt<IOAuthApiClient>()),
  );
}
