import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get home;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @add_to_favorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get add_to_favorites;

  /// No description provided for @added_to_favorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get added_to_favorites;

  /// No description provided for @removed_from_favorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removed_from_favorites;

  /// No description provided for @remove_from_favorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get remove_from_favorites;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @complain.
  ///
  /// In en, this message translates to:
  /// **'Complain'**
  String get complain;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sign_in;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @create_listing.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create_listing;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @role_tenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get role_tenant;

  /// No description provided for @role_landlord.
  ///
  /// In en, this message translates to:
  /// **'Landlord'**
  String get role_landlord;

  /// No description provided for @role_manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get role_manager;

  /// No description provided for @role_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get role_admin;

  /// No description provided for @profile_completion.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get profile_completion;

  /// No description provided for @profile_completion_hint.
  ///
  /// In en, this message translates to:
  /// **'A completed profile means more accurate matches and comfortable co-living.'**
  String get profile_completion_hint;

  /// No description provided for @complete_profile_prompt_title.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get complete_profile_prompt_title;

  /// No description provided for @complete_profile_prompt_body.
  ///
  /// In en, this message translates to:
  /// **'Add your lifestyle preferences to get better matches.'**
  String get complete_profile_prompt_body;

  /// No description provided for @complete_profile_prompt_cta.
  ///
  /// In en, this message translates to:
  /// **'Complete now'**
  String get complete_profile_prompt_cta;

  /// No description provided for @complete_profile_prompt_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get complete_profile_prompt_later;

  /// No description provided for @compatibility_title.
  ///
  /// In en, this message translates to:
  /// **'Compatibility with you:'**
  String get compatibility_title;

  /// No description provided for @compatibility_match_percentage.
  ///
  /// In en, this message translates to:
  /// **'Match: {percent}%'**
  String compatibility_match_percentage(String percent);

  /// No description provided for @compatibility_match_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Match: —'**
  String get compatibility_match_placeholder;

  /// No description provided for @compatibility_calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating match...'**
  String get compatibility_calculating;

  /// No description provided for @compatibility_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your compatibility'**
  String get compatibility_sign_in;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @compatibility_matches.
  ///
  /// In en, this message translates to:
  /// **'Matched preferences:'**
  String get compatibility_matches;

  /// No description provided for @compatibility_differences.
  ///
  /// In en, this message translates to:
  /// **'Potential differences:'**
  String get compatibility_differences;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get vs;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname'**
  String get name;

  /// No description provided for @im_from.
  ///
  /// In en, this message translates to:
  /// **'I\'m from:'**
  String get im_from;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get welcome;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to UyDosh'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your perfect roommate or accommodation'**
  String get welcome_subtitle;

  /// No description provided for @splash_subtitle.
  ///
  /// In en, this message translates to:
  /// **'LET\'S LIVE TOGETHER!'**
  String get splash_subtitle;

  /// No description provided for @search_results.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get search_results;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @about_uy_dosh.
  ///
  /// In en, this message translates to:
  /// **'About UyDosh'**
  String get about_uy_dosh;

  /// No description provided for @privacy_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy_title;

  /// No description provided for @privacy_policy_body.
  ///
  /// In en, this message translates to:
  /// **'ОБНОВЛЁННЫЙ PRIVACY POLICY (без рекламы и подписок)\n\nLast updated: [DATE]\n\nUyDosh respects your privacy. This Privacy Policy explains how we collect and use data.\n\n⸻\n\n1. Data We Collect\n\na. Information You Provide\n\t•\tPhone number\n\t•\tName and profile info\n\t•\tListings and photos\n\t•\tMessages\n\nb. Automatically Collected Data\n\t•\tDevice type and OS\n\t•\tApp usage data\n\t•\tCrash diagnostics\n\nc. Location Data\n\t•\tApproximate location (only if enabled)\n\n⸻\n\n2. How We Use Data\n\nWe use data to:\n\t•\toperate the App\n\t•\tdisplay listings and maps\n\t•\tmaintain safety and moderation\n\t•\timprove functionality\n\n⸻\n\n3. Data Sharing\n\nWe do not sell personal data.\n\nWe may share data:\n\t•\twith service providers (hosting, analytics)\n\t•\tif required by law\n\t•\twith other users (only public profile/listing info)\n\n⸻\n\n4. Data Retention\n\nWe store data only as long as necessary.\nYou may request account and data deletion.\n\n⸻\n\n5. Security\n\nWe apply reasonable measures to protect data, but no system is fully secure.\n\n⸻\n\n6. User Rights\n\nYou may request:\n\t•\taccess to your data\n\t•\tcorrection\n\t•\tdeletion\n\nContact: support@uydosh.app\n\n⸻\n\n7. Children\n\nUyDosh is not intended for users under 18.\n\n⸻\n\n8. Third-Party Services\n\nThe App may use third-party services (e.g., maps). Their policies apply independently.\n\n⸻\n\n9. Updates\n\nWe may update this Policy. Changes take effect when published.\n\n⸻\n\n10. Contact\n\nsupport@uydosh.app'**
  String get privacy_policy_body;

  /// No description provided for @user_license_agreement_title.
  ///
  /// In en, this message translates to:
  /// **'User License Agreement'**
  String get user_license_agreement_title;

  /// No description provided for @user_license_agreement_body.
  ///
  /// In en, this message translates to:
  /// **'ОБНОВЛЁННЫЙ EULA (MVP-версия)\n\nLast updated: [DATE]\n\nThis End User License Agreement (\"Agreement\") is a legal agreement between you (\"User\") and UyDosh (\"we\", \"us\", \"our\") governing your use of the UyDosh mobile application (\"App\").\n\nBy accessing or using the App, you agree to this Agreement.\n\n⸻\n\n1. License\n\nWe grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes.\n\n⸻\n\n2. Eligibility\n\nYou must be at least 18 years old to use the App.\n\n⸻\n\n3. Accounts\n\nSome features require account creation.\nYou agree to provide accurate information and keep it up to date.\n\nWe may suspend or terminate accounts that violate this Agreement or pose safety risks.\n\n⸻\n\n4. User Content\n\nThe App allows users to post listings, descriptions, photos, and messages (\"User Content\").\n\nYou retain ownership of your content.\nBy posting content, you grant us a non-exclusive, worldwide license to host, display, and distribute it solely for operating the App.\n\nYou are fully responsible for your User Content.\n\n⸻\n\n5. Prohibited Use\n\nYou agree not to:\n\t•\tPost false, misleading, or illegal listings\n\t•\tHarass, threaten, or discriminate against others\n\t•\tImpersonate another person\n\t•\tUse the App for unlawful purposes\n\t•\tAttempt to access data or accounts without authorization\n\n⸻\n\n6. No Transactions or Guarantees\n\nUyDosh does not participate in rental agreements, payments, or negotiations between users.\n\nWe do not guarantee:\n\t•\taccuracy of listings\n\t•\tavailability of housing\n\t•\tbehavior or reliability of other users\n\nAll interactions occur at your own risk.\n\n⸻\n\n7. Moderation\n\nWe reserve the right to:\n\t•\tremove content\n\t•\trestrict visibility\n\t•\tsuspend or ban users\n\nbased on complaints, violations, or safety concerns.\n\n⸻\n\n8. Location Features\n\nThe App may use approximate location data to display nearby listings and map features.\nYou can disable location access in your device settings.\n\n⸻\n\n9. Disclaimer\n\nThe App is provided \"AS IS\" and \"AS AVAILABLE\".\nWe make no warranties regarding reliability, safety, or suitability.\n\n⸻\n\n10. Limitation of Liability\n\nUyDosh shall not be liable for indirect or consequential damages arising from App usage.\n\n⸻\n\n11. Termination\n\nWe may terminate your access at any time for violation of this Agreement.\n\n⸻\n\n12. Governing Law\n\nThis Agreement is governed by the laws of the jurisdiction where UyDosh operates.\n\n⸻\n\n13. Contact\n\nsupport@uydosh.app\n\n⸻'**
  String get user_license_agreement_body;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @loading_listings.
  ///
  /// In en, this message translates to:
  /// **'Loading listings...'**
  String get loading_listings;

  /// No description provided for @loading_listing_details.
  ///
  /// In en, this message translates to:
  /// **'Loading listing details...'**
  String get loading_listing_details;

  /// No description provided for @loading_universities.
  ///
  /// In en, this message translates to:
  /// **'Loading universities...'**
  String get loading_universities;

  /// No description provided for @loading_regions.
  ///
  /// In en, this message translates to:
  /// **'Loading regions...'**
  String get loading_regions;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @error_loading_listing_details.
  ///
  /// In en, this message translates to:
  /// **'Error loading listing details'**
  String get error_loading_listing_details;

  /// No description provided for @error_listing_not_loaded.
  ///
  /// In en, this message translates to:
  /// **'Listing not loaded yet'**
  String get error_listing_not_loaded;

  /// No description provided for @error_listing_still_loading.
  ///
  /// In en, this message translates to:
  /// **'Listing is still loading'**
  String get error_listing_still_loading;

  /// No description provided for @error_loading_profile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get error_loading_profile;

  /// No description provided for @error_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get error_internet_connection;

  /// No description provided for @error_resource_conflict.
  ///
  /// In en, this message translates to:
  /// **'You have already complained about this listing.'**
  String get error_resource_conflict;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get conversations;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chat_with.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String chat_with(String name);

  /// No description provided for @profile_interlocutor.
  ///
  /// In en, this message translates to:
  /// **'Interlocutor\'s Profile'**
  String get profile_interlocutor;

  /// No description provided for @view_listing.
  ///
  /// In en, this message translates to:
  /// **'View Listing'**
  String get view_listing;

  /// No description provided for @menu_messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get menu_messages;

  /// No description provided for @type_message.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_message;

  /// No description provided for @conversation_created.
  ///
  /// In en, this message translates to:
  /// **'Conversation started'**
  String get conversation_created;

  /// No description provided for @conversation_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start conversation'**
  String get conversation_failed;

  /// No description provided for @no_conversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get no_conversations;

  /// No description provided for @no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get no_messages;

  /// No description provided for @no_messages_description.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t received any messages about your listings yet'**
  String get no_messages_description;

  /// No description provided for @error_not_authenticated.
  ///
  /// In en, this message translates to:
  /// **'Please log in to start a conversation'**
  String get error_not_authenticated;

  /// No description provided for @error_cannot_message_self.
  ///
  /// In en, this message translates to:
  /// **'You cannot message yourself'**
  String get error_cannot_message_self;

  /// No description provided for @start_conversation_from_listing.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation from a listing to begin messaging'**
  String get start_conversation_from_listing;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @in_days.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String in_days(String days);

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @send_first_message.
  ///
  /// In en, this message translates to:
  /// **'Send your first message to start the conversation'**
  String get send_first_message;

  /// No description provided for @opening_existing_conversation.
  ///
  /// In en, this message translates to:
  /// **'Opening existing conversation'**
  String get opening_existing_conversation;

  /// No description provided for @quick_question_room_available.
  ///
  /// In en, this message translates to:
  /// **'Is room available?'**
  String get quick_question_room_available;

  /// No description provided for @quick_question_move_in_date.
  ///
  /// In en, this message translates to:
  /// **'When is move in date?'**
  String get quick_question_move_in_date;

  /// No description provided for @any_date.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get any_date;

  /// No description provided for @quick_question_people_living.
  ///
  /// In en, this message translates to:
  /// **'How many people already live in apartment?'**
  String get quick_question_people_living;

  /// No description provided for @private_room.
  ///
  /// In en, this message translates to:
  /// **'Private Room'**
  String get private_room;

  /// No description provided for @private_room_only.
  ///
  /// In en, this message translates to:
  /// **'Private Room'**
  String get private_room_only;

  /// No description provided for @conversation_count.
  ///
  /// In en, this message translates to:
  /// **'conversation'**
  String get conversation_count;

  /// No description provided for @conversations_count.
  ///
  /// In en, this message translates to:
  /// **'conversations'**
  String get conversations_count;

  /// No description provided for @incoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incoming;

  /// No description provided for @outgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoing;

  /// No description provided for @no_incoming_conversations.
  ///
  /// In en, this message translates to:
  /// **'No incoming conversations'**
  String get no_incoming_conversations;

  /// No description provided for @no_outgoing_conversations.
  ///
  /// In en, this message translates to:
  /// **'No outgoing conversations'**
  String get no_outgoing_conversations;

  /// No description provided for @no_incoming_conversations_description.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t received any messages about your listings yet'**
  String get no_incoming_conversations_description;

  /// No description provided for @no_outgoing_conversations_description.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started any conversations about other listings yet'**
  String get no_outgoing_conversations_description;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back_to_listing.
  ///
  /// In en, this message translates to:
  /// **'Back to listing'**
  String get back_to_listing;

  /// No description provided for @load_more.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get load_more;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_generic;

  /// No description provided for @error_loading_regions.
  ///
  /// In en, this message translates to:
  /// **'Error loading regions: {error}'**
  String error_loading_regions(String error);

  /// No description provided for @error_loading_universities.
  ///
  /// In en, this message translates to:
  /// **'Error loading universities: {error}'**
  String error_loading_universities(String error);

  /// No description provided for @error_creating_listing.
  ///
  /// In en, this message translates to:
  /// **'Error creating listing. Please try again.'**
  String get error_creating_listing;

  /// No description provided for @error_updating_listing.
  ///
  /// In en, this message translates to:
  /// **'Error updating listing'**
  String get error_updating_listing;

  /// No description provided for @error_uploading_photos.
  ///
  /// In en, this message translates to:
  /// **'Error uploading photos'**
  String get error_uploading_photos;

  /// No description provided for @error_deactivating_listing.
  ///
  /// In en, this message translates to:
  /// **'Error deactivating listing'**
  String get error_deactivating_listing;

  /// No description provided for @error_creating_profile.
  ///
  /// In en, this message translates to:
  /// **'Error creating profile: {error}'**
  String error_creating_profile(String error);

  /// No description provided for @error_updating_profile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String error_updating_profile(String error);

  /// No description provided for @error_opening_edit_screen.
  ///
  /// In en, this message translates to:
  /// **'Error opening edit screen: {error}'**
  String error_opening_edit_screen(String error);

  /// No description provided for @error_with_message.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error_with_message(String message);

  /// No description provided for @image_load_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get image_load_error;

  /// No description provided for @listing_created_success.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully!'**
  String get listing_created_success;

  /// No description provided for @listing_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Listing updated successfully'**
  String get listing_updated_success;

  /// No description provided for @profile_completed_success.
  ///
  /// In en, this message translates to:
  /// **'Profile completed successfully!'**
  String get profile_completed_success;

  /// No description provided for @profile_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_updated_success;

  /// No description provided for @favorite_added_success.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favorite_added_success;

  /// No description provided for @favorite_removed_success.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favorite_removed_success;

  /// No description provided for @successfully_signed_in_google.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in with Google!'**
  String get successfully_signed_in_google;

  /// No description provided for @no_listings_found.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get no_listings_found;

  /// No description provided for @no_locations_available.
  ///
  /// In en, this message translates to:
  /// **'No locations available'**
  String get no_locations_available;

  /// No description provided for @no_universities_available.
  ///
  /// In en, this message translates to:
  /// **'No universities available'**
  String get no_universities_available;

  /// No description provided for @no_search_results.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get no_search_results;

  /// No description provided for @try_refreshing.
  ///
  /// In en, this message translates to:
  /// **'Try refreshing or check back later'**
  String get try_refreshing;

  /// No description provided for @try_refining_search.
  ///
  /// In en, this message translates to:
  /// **'Try refining your search criteria'**
  String get try_refining_search;

  /// No description provided for @refine_search.
  ///
  /// In en, this message translates to:
  /// **'Refine Search'**
  String get refine_search;

  /// No description provided for @select_metro_line.
  ///
  /// In en, this message translates to:
  /// **'Subway line'**
  String get select_metro_line;

  /// No description provided for @select_metro_line_title.
  ///
  /// In en, this message translates to:
  /// **'Select\nsubway line'**
  String get select_metro_line_title;

  /// No description provided for @select_location.
  ///
  /// In en, this message translates to:
  /// **'Any district'**
  String get select_location;

  /// No description provided for @not_selected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get not_selected;

  /// No description provided for @search_location_or_metro_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose one option: district or metro station'**
  String get search_location_or_metro_hint;

  /// No description provided for @all_stations_count.
  ///
  /// In en, this message translates to:
  /// **'All {count} stations'**
  String all_stations_count(String count);

  /// No description provided for @all_stations_explanation.
  ///
  /// In en, this message translates to:
  /// **'Search along the entire line <b>{line}</b> through <b>{count}</b> stations'**
  String all_stations_explanation(String line, String count);

  /// No description provided for @metro_tutorial_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search along metro line or by individual stations.'**
  String get metro_tutorial_search_hint;

  /// No description provided for @metro_tutorial_tap_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to continue'**
  String get metro_tutorial_tap_to_continue;

  /// No description provided for @select_region.
  ///
  /// In en, this message translates to:
  /// **'Choose region:'**
  String get select_region;

  /// No description provided for @select_region_profile_creation_title.
  ///
  /// In en, this message translates to:
  /// **'Where are you from?'**
  String get select_region_profile_creation_title;

  /// No description provided for @select_region_profile_creation_description.
  ///
  /// In en, this message translates to:
  /// **'We\'ll help you find people from your hometown.'**
  String get select_region_profile_creation_description;

  /// No description provided for @select_university.
  ///
  /// In en, this message translates to:
  /// **'Select university'**
  String get select_university;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @select_theme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get select_theme;

  /// No description provided for @select_theme_description.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred app theme'**
  String get select_theme_description;

  /// No description provided for @please_complete_previous_steps.
  ///
  /// In en, this message translates to:
  /// **'Please complete previous steps first'**
  String get please_complete_previous_steps;

  /// No description provided for @please_complete_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all fields'**
  String get please_complete_all_fields;

  /// No description provided for @please_select_university.
  ///
  /// In en, this message translates to:
  /// **'Please select a university'**
  String get please_select_university;

  /// No description provided for @tap_to_select_region.
  ///
  /// In en, this message translates to:
  /// **'Tap to select region'**
  String get tap_to_select_region;

  /// No description provided for @no_regions_available.
  ///
  /// In en, this message translates to:
  /// **'No regions available'**
  String get no_regions_available;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @view_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get view_profile;

  /// No description provided for @deactivate_listing.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate_listing;

  /// No description provided for @deactivate_listing_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate this listing? It will no longer be visible to other users.'**
  String get deactivate_listing_confirmation;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate_listing.
  ///
  /// In en, this message translates to:
  /// **'Activate Listing'**
  String get activate_listing;

  /// No description provided for @activate_listing_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to activate this listing? It will become visible to other users.'**
  String get activate_listing_confirmation;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @listing_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get listing_active;

  /// No description provided for @listing_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get listing_inactive;

  /// No description provided for @create_listing_button.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get create_listing_button;

  /// No description provided for @update_listing_button.
  ///
  /// In en, this message translates to:
  /// **'Update Listing'**
  String get update_listing_button;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @blue_theme.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue_theme;

  /// No description provided for @light_theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light_theme;

  /// No description provided for @theme_changed_to.
  ///
  /// In en, this message translates to:
  /// **'Theme changed to {theme}'**
  String theme_changed_to(String theme);

  /// No description provided for @theme_color.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get theme_color;

  /// No description provided for @switch_theme.
  ///
  /// In en, this message translates to:
  /// **'Switch Theme'**
  String get switch_theme;

  /// No description provided for @about_description.
  ///
  /// In en, this message translates to:
  /// **'UyDosh is your trusted platform for finding the perfect home in Tashkent.'**
  String get about_description;

  /// No description provided for @about_feature_1.
  ///
  /// In en, this message translates to:
  /// **'• Browse listings by metro station'**
  String get about_feature_1;

  /// No description provided for @about_feature_2.
  ///
  /// In en, this message translates to:
  /// **'• Search by district'**
  String get about_feature_2;

  /// No description provided for @about_feature_3.
  ///
  /// In en, this message translates to:
  /// **'• Direct contact with property owners'**
  String get about_feature_3;

  /// No description provided for @about_feature_4.
  ///
  /// In en, this message translates to:
  /// **'• Verified and safe listings'**
  String get about_feature_4;

  /// No description provided for @location_on_map.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location_on_map;

  /// No description provided for @show_map.
  ///
  /// In en, this message translates to:
  /// **'Show map'**
  String get show_map;

  /// No description provided for @hide_map.
  ///
  /// In en, this message translates to:
  /// **'Hide map'**
  String get hide_map;

  /// No description provided for @open_in_yandex_maps.
  ///
  /// In en, this message translates to:
  /// **'Open in Yandex Maps'**
  String get open_in_yandex_maps;

  /// No description provided for @open_in_yandex_maps_confirmation.
  ///
  /// In en, this message translates to:
  /// **'A browser with Yandex Maps will be opened.'**
  String get open_in_yandex_maps_confirmation;

  /// No description provided for @listing_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get listing_details;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @show_details.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get show_details;

  /// No description provided for @hide_details.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hide_details;

  /// No description provided for @listing_views_by_others.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String listing_views_by_others(String count);

  /// No description provided for @listing_views_stats_title.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get listing_views_stats_title;

  /// No description provided for @listing_views_stats_empty.
  ///
  /// In en, this message translates to:
  /// **'No views yet'**
  String get listing_views_stats_empty;

  /// No description provided for @error_loading_view_stats.
  ///
  /// In en, this message translates to:
  /// **'Error loading view statistics'**
  String get error_loading_view_stats;

  /// No description provided for @promote_listing.
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promote_listing;

  /// No description provided for @remove_from_top.
  ///
  /// In en, this message translates to:
  /// **'Remove from top'**
  String get remove_from_top;

  /// No description provided for @feature_listing_success.
  ///
  /// In en, this message translates to:
  /// **'Listing moved to top'**
  String get feature_listing_success;

  /// No description provided for @unfeature_listing_success.
  ///
  /// In en, this message translates to:
  /// **'Listing removed from top'**
  String get unfeature_listing_success;

  /// No description provided for @feature_listing_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to update listing'**
  String get feature_listing_error;

  /// No description provided for @error_promotion_once_per_week.
  ///
  /// In en, this message translates to:
  /// **'You can only promote a listing once per week'**
  String get error_promotion_once_per_week;

  /// No description provided for @listing_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter listing title'**
  String get listing_title_hint;

  /// No description provided for @listing_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter listing description'**
  String get listing_description_hint;

  /// No description provided for @listing_price_label.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get listing_price_label;

  /// No description provided for @listing_type_roommate_needed.
  ///
  /// In en, this message translates to:
  /// **'Need Roommate'**
  String get listing_type_roommate_needed;

  /// No description provided for @listing_type_room_needed.
  ///
  /// In en, this message translates to:
  /// **'Need Room'**
  String get listing_type_room_needed;

  /// No description provided for @title_male_roommate.
  ///
  /// In en, this message translates to:
  /// **'#NeedRoommate'**
  String get title_male_roommate;

  /// No description provided for @title_female_roommate.
  ///
  /// In en, this message translates to:
  /// **'#NeedRoommate'**
  String get title_female_roommate;

  /// No description provided for @title_male_room.
  ///
  /// In en, this message translates to:
  /// **'#NeedRoom'**
  String get title_male_room;

  /// No description provided for @title_female_room.
  ///
  /// In en, this message translates to:
  /// **'#NeedRoom'**
  String get title_female_room;

  /// No description provided for @listing_photos_label.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get listing_photos_label;

  /// No description provided for @delete_photo.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get delete_photo;

  /// No description provided for @delete_photo_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get delete_photo_confirmation;

  /// No description provided for @photo_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted successfully'**
  String get photo_deleted_success;

  /// No description provided for @error_deleting_photo.
  ///
  /// In en, this message translates to:
  /// **'Error deleting photo. Please try again.'**
  String get error_deleting_photo;

  /// No description provided for @photo_made_primary.
  ///
  /// In en, this message translates to:
  /// **'Photo set as primary'**
  String get photo_made_primary;

  /// No description provided for @new_primary_photo_selected.
  ///
  /// In en, this message translates to:
  /// **'New primary photo automatically selected'**
  String get new_primary_photo_selected;

  /// No description provided for @last_photo_deleted.
  ///
  /// In en, this message translates to:
  /// **'Last photo deleted - no photos remaining'**
  String get last_photo_deleted;

  /// No description provided for @cannot_delete_last_photo.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the last photo'**
  String get cannot_delete_last_photo;

  /// No description provided for @tap_photo_to_make_primary.
  ///
  /// In en, this message translates to:
  /// **'Tap photo to make primary'**
  String get tap_photo_to_make_primary;

  /// No description provided for @making_primary.
  ///
  /// In en, this message translates to:
  /// **'Making primary...'**
  String get making_primary;

  /// No description provided for @add_photo.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get add_photo;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get take_photo;

  /// No description provided for @choose_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get choose_from_gallery;

  /// No description provided for @photo_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 photos allowed'**
  String get photo_limit_reached;

  /// No description provided for @max_photos_reached.
  ///
  /// In en, this message translates to:
  /// **'Maximum photos reached'**
  String get max_photos_reached;

  /// No description provided for @max_photos_message.
  ///
  /// In en, this message translates to:
  /// **'You can only upload up to 5 photos. Please remove some photos before adding new ones.'**
  String get max_photos_message;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @onboarding_title_1.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Roommates'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_subtitle_1.
  ///
  /// In en, this message translates to:
  /// **'Fast search for roommates for shared living throughout Tashkent'**
  String get onboarding_subtitle_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In en, this message translates to:
  /// **'Search by Metro'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_subtitle_2.
  ///
  /// In en, this message translates to:
  /// **'Search either by stations - or by the entire metro line'**
  String get onboarding_subtitle_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In en, this message translates to:
  /// **'Search by District'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_subtitle_3.
  ///
  /// In en, this message translates to:
  /// **'Convenient search by districts of Tashkent'**
  String get onboarding_subtitle_3;

  /// No description provided for @onboarding_title_4.
  ///
  /// In en, this message translates to:
  /// **'Trustworthy Platform'**
  String get onboarding_title_4;

  /// No description provided for @onboarding_subtitle_4.
  ///
  /// In en, this message translates to:
  /// **'Verified users connecting for apartments and roommates'**
  String get onboarding_subtitle_4;

  /// No description provided for @onboarding_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_get_started;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboarding_back;

  /// No description provided for @onboarding_toggle.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboarding_toggle;

  /// No description provided for @onboarding_toggle_description.
  ///
  /// In en, this message translates to:
  /// **'Show welcome screens'**
  String get onboarding_toggle_description;

  /// No description provided for @haptic_feedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get haptic_feedback;

  /// No description provided for @haptic_feedback_description.
  ///
  /// In en, this message translates to:
  /// **'Vibration for taps and gestures'**
  String get haptic_feedback_description;

  /// No description provided for @current_language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get current_language;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get language_russian;

  /// No description provided for @language_uzbek.
  ///
  /// In en, this message translates to:
  /// **'O\'zbekcha'**
  String get language_uzbek;

  /// No description provided for @language_changed_to.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String language_changed_to(String language);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Guy'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @same_university.
  ///
  /// In en, this message translates to:
  /// **'Same University'**
  String get same_university;

  /// No description provided for @both_students.
  ///
  /// In en, this message translates to:
  /// **'Both students'**
  String get both_students;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @same_region.
  ///
  /// In en, this message translates to:
  /// **'Same Region'**
  String get same_region;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @about_me.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get about_me;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @open_in_telegram.
  ///
  /// In en, this message translates to:
  /// **'Open in Telegram'**
  String get open_in_telegram;

  /// No description provided for @open_in_telegram_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Telegram will be opened.'**
  String get open_in_telegram_confirmation;

  /// No description provided for @employed.
  ///
  /// In en, this message translates to:
  /// **'Employed'**
  String get employed;

  /// No description provided for @cleanliness.
  ///
  /// In en, this message translates to:
  /// **'Cleanliness'**
  String get cleanliness;

  /// No description provided for @noise_level.
  ///
  /// In en, this message translates to:
  /// **'Noise Level'**
  String get noise_level;

  /// No description provided for @sociability.
  ///
  /// In en, this message translates to:
  /// **'Sociability'**
  String get sociability;

  /// No description provided for @guests_allowed.
  ///
  /// In en, this message translates to:
  /// **'Guests Allowed'**
  String get guests_allowed;

  /// No description provided for @smoking_preference.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get smoking_preference;

  /// No description provided for @alcohol_preference.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcohol_preference;

  /// No description provided for @cooking_habits.
  ///
  /// In en, this message translates to:
  /// **'Cooking Habits'**
  String get cooking_habits;

  /// No description provided for @pets_preference.
  ///
  /// In en, this message translates to:
  /// **'Pets Preference'**
  String get pets_preference;

  /// No description provided for @wakeup_time.
  ///
  /// In en, this message translates to:
  /// **'Wake-up Time'**
  String get wakeup_time;

  /// No description provided for @sleep_time.
  ///
  /// In en, this message translates to:
  /// **'Sleep Time'**
  String get sleep_time;

  /// No description provided for @non_smoker.
  ///
  /// In en, this message translates to:
  /// **'Non-smoker'**
  String get non_smoker;

  /// No description provided for @occasional_smoker.
  ///
  /// In en, this message translates to:
  /// **'Occasional smoker'**
  String get occasional_smoker;

  /// No description provided for @regular_smoker.
  ///
  /// In en, this message translates to:
  /// **'Regular smoker'**
  String get regular_smoker;

  /// No description provided for @non_drinker.
  ///
  /// In en, this message translates to:
  /// **'Non-drinker'**
  String get non_drinker;

  /// No description provided for @occasional_drinker.
  ///
  /// In en, this message translates to:
  /// **'Occasional drinker'**
  String get occasional_drinker;

  /// No description provided for @regular_drinker.
  ///
  /// In en, this message translates to:
  /// **'Regular drinker'**
  String get regular_drinker;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @pets_okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get pets_okay;

  /// No description provided for @pets_not_okay.
  ///
  /// In en, this message translates to:
  /// **'Not great'**
  String get pets_not_okay;

  /// No description provided for @lifestyle_preferences.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle Preferences'**
  String get lifestyle_preferences;

  /// No description provided for @very_messy.
  ///
  /// In en, this message translates to:
  /// **'Very Messy'**
  String get very_messy;

  /// No description provided for @messy.
  ///
  /// In en, this message translates to:
  /// **'Messy'**
  String get messy;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @clean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get clean;

  /// No description provided for @very_clean.
  ///
  /// In en, this message translates to:
  /// **'Very Clean'**
  String get very_clean;

  /// No description provided for @very_quiet.
  ///
  /// In en, this message translates to:
  /// **'Very Quiet'**
  String get very_quiet;

  /// No description provided for @quiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get quiet;

  /// No description provided for @loud.
  ///
  /// In en, this message translates to:
  /// **'Loud'**
  String get loud;

  /// No description provided for @very_loud.
  ///
  /// In en, this message translates to:
  /// **'Very Loud'**
  String get very_loud;

  /// No description provided for @very_introverted.
  ///
  /// In en, this message translates to:
  /// **'Very Introverted'**
  String get very_introverted;

  /// No description provided for @introverted.
  ///
  /// In en, this message translates to:
  /// **'Introverted'**
  String get introverted;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @extroverted.
  ///
  /// In en, this message translates to:
  /// **'Extroverted'**
  String get extroverted;

  /// No description provided for @very_extroverted.
  ///
  /// In en, this message translates to:
  /// **'Very Extroverted'**
  String get very_extroverted;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// No description provided for @dont_cook.
  ///
  /// In en, this message translates to:
  /// **'Don\'t cook'**
  String get dont_cook;

  /// No description provided for @not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get not_specified;

  /// No description provided for @complete_profile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get complete_profile;

  /// No description provided for @complete_profile_subheader.
  ///
  /// In en, this message translates to:
  /// **'We use this information to find the perfect roommates and matches for you.'**
  String get complete_profile_subheader;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname'**
  String get full_name;

  /// No description provided for @are_you_student.
  ///
  /// In en, this message translates to:
  /// **'Are you a student?'**
  String get are_you_student;

  /// No description provided for @yes_student.
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m a student'**
  String get yes_student;

  /// No description provided for @no_student.
  ///
  /// In en, this message translates to:
  /// **'No, I\'m not a student'**
  String get no_student;

  /// No description provided for @are_you_landlord_or_renter.
  ///
  /// In en, this message translates to:
  /// **'Are you a landlord or renter?'**
  String get are_you_landlord_or_renter;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name or nickname'**
  String get full_name_hint;

  /// No description provided for @name_required.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname is required'**
  String get name_required;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @firebase_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'Firebase user not found'**
  String get firebase_user_not_found;

  /// No description provided for @user_blocked_violation_title.
  ///
  /// In en, this message translates to:
  /// **'Account restricted'**
  String get user_blocked_violation_title;

  /// No description provided for @user_blocked_violation_message.
  ///
  /// In en, this message translates to:
  /// **'Your account has been restricted due to a violation. You can browse the app but cannot post listings, send messages, or edit content. Please contact support if you have questions.'**
  String get user_blocked_violation_message;

  /// No description provided for @profile_not_loaded_yet.
  ///
  /// In en, this message translates to:
  /// **'Profile not loaded yet'**
  String get profile_not_loaded_yet;

  /// No description provided for @profile_still_loading.
  ///
  /// In en, this message translates to:
  /// **'Profile still loading'**
  String get profile_still_loading;

  /// No description provided for @welcome_back_profile_exists.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Profile already exists.'**
  String get welcome_back_profile_exists;

  /// No description provided for @tap_to_select_university.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a university'**
  String get tap_to_select_university;

  /// No description provided for @menu_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menu_profile;

  /// No description provided for @menu_home.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get menu_home;

  /// No description provided for @menu_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menu_language;

  /// No description provided for @menu_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get menu_favorites;

  /// No description provided for @menu_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menu_history;

  /// No description provided for @menu_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get menu_contact_support;

  /// No description provided for @menu_add_listing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get menu_add_listing;

  /// No description provided for @menu_my_listings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get menu_my_listings;

  /// No description provided for @menu_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menu_about;

  /// No description provided for @menu_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get menu_privacy_policy;

  /// No description provided for @menu_user_license_agreement.
  ///
  /// In en, this message translates to:
  /// **'User License Agreement'**
  String get menu_user_license_agreement;

  /// No description provided for @menu_faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get menu_faq;

  /// No description provided for @menu_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menu_settings;

  /// No description provided for @menu_registration.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get menu_registration;

  /// No description provided for @menu_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menu_logout;

  /// No description provided for @menu_admin_panel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get menu_admin_panel;

  /// No description provided for @manage_property.
  ///
  /// In en, this message translates to:
  /// **'Manage Property'**
  String get manage_property;

  /// No description provided for @admin_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get admin_panel_title;

  /// No description provided for @admin_panel_description.
  ///
  /// In en, this message translates to:
  /// **'Manage users, listings, and reports from one place.'**
  String get admin_panel_description;

  /// No description provided for @admin_panel_section_users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admin_panel_section_users;

  /// No description provided for @admin_panel_section_support_chat.
  ///
  /// In en, this message translates to:
  /// **'Support chat'**
  String get admin_panel_section_support_chat;

  /// No description provided for @admin_panel_section_complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get admin_panel_section_complaints;

  /// No description provided for @admin_panel_section_listing_complaints.
  ///
  /// In en, this message translates to:
  /// **'Listings with complaints'**
  String get admin_panel_section_listing_complaints;

  /// No description provided for @admin_panel_section_district_heatmap.
  ///
  /// In en, this message translates to:
  /// **'District heat map'**
  String get admin_panel_section_district_heatmap;

  /// No description provided for @admin_panel_section_subway_heatmap.
  ///
  /// In en, this message translates to:
  /// **'Subway line heat map'**
  String get admin_panel_section_subway_heatmap;

  /// No description provided for @admin_panel_section_subway_map.
  ///
  /// In en, this message translates to:
  /// **'Subway map'**
  String get admin_panel_section_subway_map;

  /// No description provided for @admin_panel_section_search_analytics.
  ///
  /// In en, this message translates to:
  /// **'Search analytics'**
  String get admin_panel_section_search_analytics;

  /// No description provided for @admin_panel_section_listing_creation_analytics.
  ///
  /// In en, this message translates to:
  /// **'Listings creation analytics'**
  String get admin_panel_section_listing_creation_analytics;

  /// No description provided for @admin_search_analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Search analytics'**
  String get admin_search_analytics_title;

  /// No description provided for @admin_search_analytics_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading search analytics...'**
  String get admin_search_analytics_loading;

  /// No description provided for @admin_search_analytics_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load search analytics'**
  String get admin_search_analytics_error;

  /// No description provided for @admin_search_analytics_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get admin_search_analytics_retry;

  /// No description provided for @admin_search_analytics_time_range.
  ///
  /// In en, this message translates to:
  /// **'Time range'**
  String get admin_search_analytics_time_range;

  /// No description provided for @admin_search_analytics_days.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String admin_search_analytics_days(String days);

  /// No description provided for @admin_search_analytics_all_time.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get admin_search_analytics_all_time;

  /// No description provided for @admin_search_analytics_total.
  ///
  /// In en, this message translates to:
  /// **'Total searches'**
  String get admin_search_analytics_total;

  /// No description provided for @admin_search_analytics_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get admin_search_analytics_today;

  /// No description provided for @admin_search_analytics_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get admin_search_analytics_week;

  /// No description provided for @admin_search_analytics_top_stations.
  ///
  /// In en, this message translates to:
  /// **'Top metro stations'**
  String get admin_search_analytics_top_stations;

  /// No description provided for @admin_search_analytics_top_districts.
  ///
  /// In en, this message translates to:
  /// **'Top districts'**
  String get admin_search_analytics_top_districts;

  /// No description provided for @admin_search_analytics_top_lines.
  ///
  /// In en, this message translates to:
  /// **'Top metro lines'**
  String get admin_search_analytics_top_lines;

  /// No description provided for @admin_search_analytics_searches.
  ///
  /// In en, this message translates to:
  /// **'searches'**
  String get admin_search_analytics_searches;

  /// No description provided for @admin_search_analytics_no_stations.
  ///
  /// In en, this message translates to:
  /// **'No station search data yet'**
  String get admin_search_analytics_no_stations;

  /// No description provided for @admin_search_analytics_no_districts.
  ///
  /// In en, this message translates to:
  /// **'No district search data yet'**
  String get admin_search_analytics_no_districts;

  /// No description provided for @admin_search_analytics_no_lines.
  ///
  /// In en, this message translates to:
  /// **'No line search data yet'**
  String get admin_search_analytics_no_lines;

  /// No description provided for @admin_listing_creation_analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Listings creation analytics'**
  String get admin_listing_creation_analytics_title;

  /// No description provided for @admin_listing_creation_analytics_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading listings creation analytics...'**
  String get admin_listing_creation_analytics_loading;

  /// No description provided for @admin_listing_creation_analytics_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load listings creation analytics'**
  String get admin_listing_creation_analytics_error;

  /// No description provided for @admin_listing_creation_analytics_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get admin_listing_creation_analytics_retry;

  /// No description provided for @admin_listing_creation_analytics_time_range.
  ///
  /// In en, this message translates to:
  /// **'Time range'**
  String get admin_listing_creation_analytics_time_range;

  /// No description provided for @admin_listing_creation_analytics_total.
  ///
  /// In en, this message translates to:
  /// **'Total in period'**
  String get admin_listing_creation_analytics_total;

  /// No description provided for @admin_listing_creation_analytics_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get admin_listing_creation_analytics_today;

  /// No description provided for @admin_listing_creation_analytics_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get admin_listing_creation_analytics_week;

  /// No description provided for @admin_listing_creation_analytics_by_day.
  ///
  /// In en, this message translates to:
  /// **'Listings by day'**
  String get admin_listing_creation_analytics_by_day;

  /// No description provided for @admin_listing_creation_analytics_no_data.
  ///
  /// In en, this message translates to:
  /// **'No listing data in this period'**
  String get admin_listing_creation_analytics_no_data;

  /// No description provided for @admin_district_heatmap_title.
  ///
  /// In en, this message translates to:
  /// **'District heat map'**
  String get admin_district_heatmap_title;

  /// No description provided for @admin_district_heatmap_description.
  ///
  /// In en, this message translates to:
  /// **'Listings by district with heat intensity based on volume.'**
  String get admin_district_heatmap_description;

  /// No description provided for @admin_district_heatmap_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading district stats...'**
  String get admin_district_heatmap_loading;

  /// No description provided for @admin_district_heatmap_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load district stats'**
  String get admin_district_heatmap_error;

  /// No description provided for @admin_district_heatmap_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get admin_district_heatmap_retry;

  /// No description provided for @admin_district_heatmap_total.
  ///
  /// In en, this message translates to:
  /// **'Total listings'**
  String get admin_district_heatmap_total;

  /// No description provided for @admin_district_heatmap_max.
  ///
  /// In en, this message translates to:
  /// **'Max in district'**
  String get admin_district_heatmap_max;

  /// No description provided for @admin_district_heatmap_count_label.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get admin_district_heatmap_count_label;

  /// No description provided for @admin_district_heatmap_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get admin_district_heatmap_unavailable;

  /// No description provided for @admin_district_heatmap_no_data.
  ///
  /// In en, this message translates to:
  /// **'No district data available'**
  String get admin_district_heatmap_no_data;

  /// No description provided for @admin_subway_heatmap_title.
  ///
  /// In en, this message translates to:
  /// **'Subway line heat map'**
  String get admin_subway_heatmap_title;

  /// No description provided for @admin_subway_heatmap_description.
  ///
  /// In en, this message translates to:
  /// **'Listings by subway line with heat intensity based on volume.'**
  String get admin_subway_heatmap_description;

  /// No description provided for @admin_subway_heatmap_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading subway line stats...'**
  String get admin_subway_heatmap_loading;

  /// No description provided for @admin_subway_heatmap_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subway line stats'**
  String get admin_subway_heatmap_error;

  /// No description provided for @admin_subway_heatmap_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get admin_subway_heatmap_retry;

  /// No description provided for @admin_subway_heatmap_total.
  ///
  /// In en, this message translates to:
  /// **'Total listings'**
  String get admin_subway_heatmap_total;

  /// No description provided for @admin_subway_heatmap_max.
  ///
  /// In en, this message translates to:
  /// **'Max on line'**
  String get admin_subway_heatmap_max;

  /// No description provided for @admin_subway_heatmap_count_label.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get admin_subway_heatmap_count_label;

  /// No description provided for @admin_subway_heatmap_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get admin_subway_heatmap_unavailable;

  /// No description provided for @admin_subway_heatmap_no_data.
  ///
  /// In en, this message translates to:
  /// **'No subway line data available'**
  String get admin_subway_heatmap_no_data;

  /// No description provided for @admin_subway_map_title.
  ///
  /// In en, this message translates to:
  /// **'Subway map'**
  String get admin_subway_map_title;

  /// No description provided for @admin_subway_map_description.
  ///
  /// In en, this message translates to:
  /// **'Simplified map with lines and stations only.'**
  String get admin_subway_map_description;

  /// No description provided for @error_loading_map.
  ///
  /// In en, this message translates to:
  /// **'Failed to load map'**
  String get error_loading_map;

  /// No description provided for @admin_users_title.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admin_users_title;

  /// No description provided for @admin_users_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading users...'**
  String get admin_users_loading;

  /// No description provided for @admin_users_empty.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get admin_users_empty;

  /// No description provided for @admin_users_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users'**
  String get admin_users_error;

  /// No description provided for @admin_users_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get admin_users_id;

  /// No description provided for @admin_users_role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get admin_users_role;

  /// No description provided for @admin_users_created_at.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get admin_users_created_at;

  /// No description provided for @admin_users_listings_count.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get admin_users_listings_count;

  /// No description provided for @admin_users_listings_count_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get admin_users_listings_count_loading;

  /// No description provided for @admin_users_listings_count_error.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get admin_users_listings_count_error;

  /// No description provided for @admin_user_detail_title.
  ///
  /// In en, this message translates to:
  /// **'User details'**
  String get admin_user_detail_title;

  /// No description provided for @admin_user_detail_role_title.
  ///
  /// In en, this message translates to:
  /// **'Role management'**
  String get admin_user_detail_role_title;

  /// No description provided for @admin_user_detail_role_label.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get admin_user_detail_role_label;

  /// No description provided for @admin_user_detail_role_save.
  ///
  /// In en, this message translates to:
  /// **'Save role'**
  String get admin_user_detail_role_save;

  /// No description provided for @admin_user_detail_role_updated.
  ///
  /// In en, this message translates to:
  /// **'Role updated'**
  String get admin_user_detail_role_updated;

  /// No description provided for @admin_user_detail_view_listings.
  ///
  /// In en, this message translates to:
  /// **'View listings'**
  String get admin_user_detail_view_listings;

  /// No description provided for @admin_user_detail_view_complaints.
  ///
  /// In en, this message translates to:
  /// **'View complaints'**
  String get admin_user_detail_view_complaints;

  /// No description provided for @admin_user_detail_block_title.
  ///
  /// In en, this message translates to:
  /// **'Block status'**
  String get admin_user_detail_block_title;

  /// No description provided for @admin_user_detail_block.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get admin_user_detail_block;

  /// No description provided for @admin_user_detail_unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get admin_user_detail_unblock;

  /// No description provided for @admin_user_detail_blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get admin_user_detail_blocked;

  /// No description provided for @admin_user_detail_block_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get admin_user_detail_block_reason;

  /// No description provided for @admin_user_detail_block_until.
  ///
  /// In en, this message translates to:
  /// **'Block until'**
  String get admin_user_detail_block_until;

  /// No description provided for @admin_user_detail_block_permanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get admin_user_detail_block_permanent;

  /// No description provided for @admin_user_detail_block_confirm.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get admin_user_detail_block_confirm;

  /// No description provided for @admin_user_detail_blocked_success.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get admin_user_detail_blocked_success;

  /// No description provided for @admin_user_detail_unblocked_success.
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get admin_user_detail_unblocked_success;

  /// No description provided for @admin_user_complaints_title.
  ///
  /// In en, this message translates to:
  /// **'User complaints'**
  String get admin_user_complaints_title;

  /// No description provided for @admin_user_complaints_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get admin_user_complaints_user;

  /// No description provided for @admin_user_complaints_empty.
  ///
  /// In en, this message translates to:
  /// **'No complaints found'**
  String get admin_user_complaints_empty;

  /// No description provided for @admin_user_complaints_group_count.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get admin_user_complaints_group_count;

  /// No description provided for @admin_user_listings_title.
  ///
  /// In en, this message translates to:
  /// **'User listings'**
  String get admin_user_listings_title;

  /// No description provided for @admin_user_listings_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get admin_user_listings_user;

  /// No description provided for @admin_user_listings_empty.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get admin_user_listings_empty;

  /// No description provided for @admin_user_listings_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load listings'**
  String get admin_user_listings_error;

  /// No description provided for @admin_complaints_title.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get admin_complaints_title;

  /// No description provided for @admin_complaints_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading complaints...'**
  String get admin_complaints_loading;

  /// No description provided for @admin_complaints_empty.
  ///
  /// In en, this message translates to:
  /// **'No complaints found'**
  String get admin_complaints_empty;

  /// No description provided for @admin_complaints_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load complaints'**
  String get admin_complaints_error;

  /// No description provided for @admin_complaints_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get admin_complaints_filter_all;

  /// No description provided for @admin_complaints_filter_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get admin_complaints_filter_pending;

  /// No description provided for @admin_complaints_filter_resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get admin_complaints_filter_resolved;

  /// No description provided for @admin_complaints_filter_dismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get admin_complaints_filter_dismissed;

  /// No description provided for @admin_complaints_status_label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get admin_complaints_status_label;

  /// No description provided for @admin_complaints_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get admin_complaints_status_pending;

  /// No description provided for @admin_complaints_status_resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get admin_complaints_status_resolved;

  /// No description provided for @admin_complaints_status_dismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get admin_complaints_status_dismissed;

  /// No description provided for @admin_complaints_listing_id.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get admin_complaints_listing_id;

  /// No description provided for @admin_complaints_complainant_id.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get admin_complaints_complainant_id;

  /// No description provided for @admin_complaints_category_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown category'**
  String get admin_complaints_category_unknown;

  /// No description provided for @admin_complaints_created_at.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get admin_complaints_created_at;

  /// No description provided for @admin_complaints_text.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get admin_complaints_text;

  /// No description provided for @admin_complaints_update_status.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get admin_complaints_update_status;

  /// No description provided for @admin_complaints_status_updated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get admin_complaints_status_updated;

  /// No description provided for @admin_support_chat_title.
  ///
  /// In en, this message translates to:
  /// **'Support chat'**
  String get admin_support_chat_title;

  /// No description provided for @admin_support_chat_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading support threads...'**
  String get admin_support_chat_loading;

  /// No description provided for @admin_support_chat_empty.
  ///
  /// In en, this message translates to:
  /// **'No support threads yet'**
  String get admin_support_chat_empty;

  /// No description provided for @admin_support_chat_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load support chat'**
  String get admin_support_chat_error;

  /// No description provided for @admin_support_chat_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get admin_support_chat_retry;

  /// No description provided for @admin_support_chat_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get admin_support_chat_filter_all;

  /// No description provided for @admin_support_chat_filter_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get admin_support_chat_filter_open;

  /// No description provided for @admin_support_chat_filter_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get admin_support_chat_filter_closed;

  /// No description provided for @admin_support_chat_status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get admin_support_chat_status_open;

  /// No description provided for @admin_support_chat_status_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get admin_support_chat_status_closed;

  /// No description provided for @admin_support_chat_messages.
  ///
  /// In en, this message translates to:
  /// **'messages'**
  String get admin_support_chat_messages;

  /// No description provided for @admin_support_chat_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get admin_support_chat_yesterday;

  /// No description provided for @admin_support_chat_days_ago.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get admin_support_chat_days_ago;

  /// No description provided for @admin_support_chat_no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get admin_support_chat_no_messages;

  /// No description provided for @admin_support_chat_reply_hint.
  ///
  /// In en, this message translates to:
  /// **'Type your reply...'**
  String get admin_support_chat_reply_hint;

  /// No description provided for @admin_support_chat_close_thread.
  ///
  /// In en, this message translates to:
  /// **'Close thread'**
  String get admin_support_chat_close_thread;

  /// No description provided for @admin_support_chat_reopen_thread.
  ///
  /// In en, this message translates to:
  /// **'Reopen thread'**
  String get admin_support_chat_reopen_thread;

  /// No description provided for @admin_support_chat_closed.
  ///
  /// In en, this message translates to:
  /// **'Thread closed'**
  String get admin_support_chat_closed;

  /// No description provided for @admin_support_chat_reopened.
  ///
  /// In en, this message translates to:
  /// **'Thread reopened'**
  String get admin_support_chat_reopened;

  /// No description provided for @admin_support_chat_thread_closed.
  ///
  /// In en, this message translates to:
  /// **'This thread is closed. Reopen to reply.'**
  String get admin_support_chat_thread_closed;

  /// No description provided for @contact_support_title.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support_title;

  /// No description provided for @contact_support_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get contact_support_loading;

  /// No description provided for @contact_support_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load support'**
  String get contact_support_error;

  /// No description provided for @contact_support_empty.
  ///
  /// In en, this message translates to:
  /// **'No support conversations yet. Start a new one to get help.'**
  String get contact_support_empty;

  /// No description provided for @contact_support_new.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get contact_support_new;

  /// No description provided for @contact_support_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get contact_support_message_hint;

  /// No description provided for @admin_listing_complaints_title.
  ///
  /// In en, this message translates to:
  /// **'Listings with complaints'**
  String get admin_listing_complaints_title;

  /// No description provided for @admin_listing_complaints_empty.
  ///
  /// In en, this message translates to:
  /// **'No listings with complaints'**
  String get admin_listing_complaints_empty;

  /// No description provided for @admin_listing_complaints_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load listings with complaints'**
  String get admin_listing_complaints_error;

  /// No description provided for @admin_listing_complaints_last_reported.
  ///
  /// In en, this message translates to:
  /// **'Last complaint'**
  String get admin_listing_complaints_last_reported;

  /// No description provided for @admin_listing_complaints_categories.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get admin_listing_complaints_categories;

  /// No description provided for @admin_listing_complaints_categories_empty.
  ///
  /// In en, this message translates to:
  /// **'No complaint categories'**
  String get admin_listing_complaints_categories_empty;

  /// No description provided for @faq_question.
  ///
  /// In en, this message translates to:
  /// **'How to negotiate with roommates and avoid conflicts?'**
  String get faq_question;

  /// No description provided for @faq_answer.
  ///
  /// In en, this message translates to:
  /// **'Living together is always about respect and the ability to negotiate. Here are some simple rules that will help maintain peace and friendship:\n\nNoise\nAgree on \"quiet hours\". For music — headphones, for calls — hallway or street. It\'s convenient to hang a schedule so everyone knows when someone has study or rest time.\n\nGuests\nWarn each other in advance. A good rule is certain days for guests and days for quiet.\n\nEmotions\nDon\'t accumulate irritation. Speak calmly and immediately if something bothers you. And it\'s better to release extra stress at the gym or on a run.\n\nCommon activities\nSometimes it\'s useful to do something together: go to the movies, take a walk, have a \"cleaning to music\". Shared memories strengthen friendship.\n\nCleaning and household\nDivide responsibilities — someone mops the floor, someone takes out the trash. The main thing is to negotiate and respect personal boundaries. Don\'t touch other people\'s things without permission.\n\nCommunication\nUse \"I-messages\": instead of \"you annoy me\" it\'s better to say \"it\'s hard for me to concentrate when loud music is playing\".\n\nConflict resolution\nTry to discuss everything calmly, listening to each other. Conflict is an opportunity to find a common solution, not an enemy.\n\nFood\nYou can agree on joint purchases or start a \"common shelf\" for treats.\n\nOrder and quiet\nCleaning schedule is your best friend. And if you need to concentrate — you can go to the library or coworking, or turn on the \"quiet hour\" rule again.'**
  String get faq_answer;

  /// No description provided for @faq_question_2.
  ///
  /// In en, this message translates to:
  /// **'Utility debts and how to avoid them'**
  String get faq_question_2;

  /// No description provided for @faq_answer_2.
  ///
  /// In en, this message translates to:
  /// **'Sometimes along with the apartment, the tenant gets utility debts as a \"gift\". As a result — disconnected electricity or water, and the landlord is in no hurry to pay. The tenant is left to choose: move out with losses or pay off the debt at their own expense.\n\nTo avoid such situations:\n\nCheck before signing\nBefore signing the contract, ask the owner for receipts or a report on paid utility bills.\n\nWritten agreement\nIf there is still a debt and you are ready to pay it, be sure to draw up a written agreement: the amount of the debt will be credited to future rent.\n\nThis way you will save both money and peace of mind.'**
  String get faq_answer_2;

  /// No description provided for @faq_question_3.
  ///
  /// In en, this message translates to:
  /// **'Promised repairs take three years to wait'**
  String get faq_question_3;

  /// No description provided for @faq_answer_3.
  ///
  /// In en, this message translates to:
  /// **'Often when renting housing, the owner promises to fix problems in the apartment, buy household appliances and furniture. All this he undertakes to fulfill immediately after moving in. However, time passes, and the problems remain. To avoid becoming a hostage to such a situation, the tenant should include special conditions in the rental agreement.\n\nAlso, oral agreements about repairs by the tenant and the obligation not to charge rent during the work are often violated. For example, you renovate the apartment at your own expense and don\'t pay rent for several months. However, some landlords \"forget\" about the agreements and demand payment for accommodation. Often the parties have disagreements about the cost of finishing, and sometimes the matter even comes to court.\n\nTherefore, you should discuss all aspects of the repair, take them into account in the rental agreement, as well as draw up an estimate and sign it.'**
  String get faq_answer_3;

  /// No description provided for @faq_question_4.
  ///
  /// In en, this message translates to:
  /// **'You are no longer my friend'**
  String get faq_question_4;

  /// No description provided for @faq_answer_4.
  ///
  /// In en, this message translates to:
  /// **'Often when renting housing to relatives or friends, no contract is concluded. At the same time, many scandals and disputes occur precisely between relatives and friends who accepted promises and obligations for rent verbally. Therefore, it is better to conclude a contract, even if you are renting an apartment from your uncle or close friend.\n\nThere are cases when apartments are rented by proxy, which states: the principal gives the authorized person the right to rent out his apartment. \"But the power of attorney does not specify that the authorized person also has the right to receive rent. A situation may occur: the tenant regularly pays the rent to the authorized person, but one day the owner of the living space appears and demands that the tenant pay for the past period of residence in the apartment.\" In this case, you should carefully study the documents, and if the power of attorney does not specify the right to receive rent, discuss this point.'**
  String get faq_answer_4;

  /// No description provided for @faq_question_5.
  ///
  /// In en, this message translates to:
  /// **'Safety guide for renters and neighbors'**
  String get faq_question_5;

  /// No description provided for @faq_answer_5.
  ///
  /// In en, this message translates to:
  /// **'Sometimes unpleasant situations happen not only on our platform. Unfortunately, inadequate or troubled people are everywhere. Therefore, it is important to remember simple safety rules.\n\n🙏 The main thing is your safety!\n\nBefore the meeting\n• Arrange meetings only during the day.\n• Try to choose crowded places — cafes, shopping centers, courtyards with cameras.\n• Tell friends or relatives where you are going and who you are meeting.\n\nDuring the meeting\n• If possible, don\'t come alone.\n• Don\'t hand over money and documents \"hand to hand\" until the contract is signed.\n• Save correspondence and photos/scans of documents — this is your protection.\n\nIf you feel threatened\n• Immediately stop the meeting and leave.\n• Don\'t be afraid to say \"no\" and break off communication.\n• In case of obvious danger — call 102 or contact the nearest police station.\n\nOn the UyDosh platform\n• Use the verification system — verified profiles reduce risk.\n• Report suspicious ads and behavior to moderators.\n• Remember: it\'s better to be safe than sorry.\n\n❤️ Take care of yourself and each other!'**
  String get faq_answer_5;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Logout Confirmation'**
  String get logout_confirmation;

  /// No description provided for @logout_description.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? You will need to sign in again to access your profile.'**
  String get logout_description;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged out'**
  String get logout_success;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get delete_account;

  /// No description provided for @delete_account_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone. All your data, listings, and messages will be permanently removed.'**
  String get delete_account_confirmation;

  /// No description provided for @delete_account_success.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get delete_account_success;

  /// No description provided for @delete_account_error.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account'**
  String get delete_account_error;

  /// No description provided for @delete_account_blocked.
  ///
  /// In en, this message translates to:
  /// **'Your account has been restricted. You cannot delete your account while it is blocked. Please contact support.'**
  String get delete_account_blocked;

  /// No description provided for @favorites_title.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites_title;

  /// No description provided for @favorites_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favorites_empty_title;

  /// No description provided for @favorites_browse_button.
  ///
  /// In en, this message translates to:
  /// **'Browse Listings'**
  String get favorites_browse_button;

  /// No description provided for @view_history_title.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get view_history_title;

  /// No description provided for @view_history_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No viewed listings yet'**
  String get view_history_empty_title;

  /// No description provided for @view_history_browse_button.
  ///
  /// In en, this message translates to:
  /// **'Browse Listings'**
  String get view_history_browse_button;

  /// No description provided for @view_history_auth_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your history.'**
  String get view_history_auth_prompt;

  /// No description provided for @unable_to_load_view_history.
  ///
  /// In en, this message translates to:
  /// **'Unable to load view history. Please try again later.'**
  String get unable_to_load_view_history;

  /// No description provided for @menu_achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get menu_achievements;

  /// No description provided for @achievements_title.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements_title;

  /// No description provided for @achievement_unlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked!'**
  String get achievement_unlocked;

  /// No description provided for @achievement_first_steps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get achievement_first_steps;

  /// No description provided for @achievement_first_steps_desc.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get achievement_first_steps_desc;

  /// No description provided for @achievement_profile_complete.
  ///
  /// In en, this message translates to:
  /// **'Profile Complete'**
  String get achievement_profile_complete;

  /// No description provided for @achievement_profile_complete_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile 100%'**
  String get achievement_profile_complete_desc;

  /// No description provided for @achievement_first_look.
  ///
  /// In en, this message translates to:
  /// **'First Look'**
  String get achievement_first_look;

  /// No description provided for @achievement_first_look_desc.
  ///
  /// In en, this message translates to:
  /// **'View your first listing'**
  String get achievement_first_look_desc;

  /// No description provided for @achievement_bookmarker.
  ///
  /// In en, this message translates to:
  /// **'Bookmarker'**
  String get achievement_bookmarker;

  /// No description provided for @achievement_bookmarker_desc.
  ///
  /// In en, this message translates to:
  /// **'Add your first favorite'**
  String get achievement_bookmarker_desc;

  /// No description provided for @achievement_ice_breaker.
  ///
  /// In en, this message translates to:
  /// **'Ice Breaker'**
  String get achievement_ice_breaker;

  /// No description provided for @achievement_ice_breaker_desc.
  ///
  /// In en, this message translates to:
  /// **'Send your first message'**
  String get achievement_ice_breaker_desc;

  /// No description provided for @achievement_first_listing.
  ///
  /// In en, this message translates to:
  /// **'First Listing'**
  String get achievement_first_listing;

  /// No description provided for @achievement_first_listing_desc.
  ///
  /// In en, this message translates to:
  /// **'Create your first listing'**
  String get achievement_first_listing_desc;

  /// No description provided for @achievement_returning_user.
  ///
  /// In en, this message translates to:
  /// **'Returning User'**
  String get achievement_returning_user;

  /// No description provided for @achievement_returning_user_desc.
  ///
  /// In en, this message translates to:
  /// **'Use the app 7 days in a row'**
  String get achievement_returning_user_desc;

  /// No description provided for @achievement_sharer.
  ///
  /// In en, this message translates to:
  /// **'Sharer'**
  String get achievement_sharer;

  /// No description provided for @achievement_sharer_desc.
  ///
  /// In en, this message translates to:
  /// **'Share your first listing'**
  String get achievement_sharer_desc;

  /// No description provided for @achievements_empty.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get achievements_empty;

  /// No description provided for @achievements_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete actions to unlock achievements'**
  String get achievements_empty_desc;

  /// No description provided for @achievements_auth_prompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to view your achievements'**
  String get achievements_auth_prompt;

  /// No description provided for @favorite_toggle_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite status'**
  String get favorite_toggle_error;

  /// No description provided for @favorite_toggle_network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error updating favorite status'**
  String get favorite_toggle_network_error;

  /// No description provided for @unable_to_load_favorites.
  ///
  /// In en, this message translates to:
  /// **'Unable to load favorites. Please try again later.'**
  String get unable_to_load_favorites;

  /// No description provided for @create_listing_title.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get create_listing_title;

  /// No description provided for @edit_listing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get edit_listing;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @updating_listing.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating_listing;

  /// No description provided for @creating_listing.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating_listing;

  /// No description provided for @title_required.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get title_required;

  /// No description provided for @title_too_long.
  ///
  /// In en, this message translates to:
  /// **'Title must be 25 characters or less'**
  String get title_too_long;

  /// No description provided for @description_required.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get description_required;

  /// No description provided for @description_too_long.
  ///
  /// In en, this message translates to:
  /// **'Description must be 500 characters or less'**
  String get description_too_long;

  /// No description provided for @location_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a location'**
  String get location_required;

  /// No description provided for @auth_required_title.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get auth_required_title;

  /// No description provided for @authentication_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please log in to create listings.'**
  String get authentication_required;

  /// No description provided for @unauthenticated_listing_prompt.
  ///
  /// In en, this message translates to:
  /// **'To create and post listings, you need to sign in to your account.'**
  String get unauthenticated_listing_prompt;

  /// No description provided for @authenticate_to_post_listing.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to post listing'**
  String get authenticate_to_post_listing;

  /// No description provided for @select_location_required.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get select_location_required;

  /// No description provided for @select_metro_line_optional.
  ///
  /// In en, this message translates to:
  /// **'Metro line'**
  String get select_metro_line_optional;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// No description provided for @bed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get bed;

  /// No description provided for @air_conditioning.
  ///
  /// In en, this message translates to:
  /// **'Air Conditioning'**
  String get air_conditioning;

  /// No description provided for @tv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get tv;

  /// No description provided for @microwave.
  ///
  /// In en, this message translates to:
  /// **'Microwave'**
  String get microwave;

  /// No description provided for @washing_machine.
  ///
  /// In en, this message translates to:
  /// **'Washing Machine'**
  String get washing_machine;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets Allowed'**
  String get pets;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @search_listings.
  ///
  /// In en, this message translates to:
  /// **'Search Listings'**
  String get search_listings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @tutorial_search_title.
  ///
  /// In en, this message translates to:
  /// **'Search for listings'**
  String get tutorial_search_title;

  /// No description provided for @tutorial_search_description.
  ///
  /// In en, this message translates to:
  /// **'Tap here to filter listings by location, price, room type, and more.'**
  String get tutorial_search_description;

  /// No description provided for @tutorial_profile_description.
  ///
  /// In en, this message translates to:
  /// **'Your profile and account settings are here.'**
  String get tutorial_profile_description;

  /// No description provided for @tutorial_got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tutorial_got_it;

  /// No description provided for @tutorial_metro_description.
  ///
  /// In en, this message translates to:
  /// **'Choose a metro line, then pick a station to filter by location.'**
  String get tutorial_metro_description;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Move in date'**
  String get select_date;

  /// No description provided for @move_in_date_label.
  ///
  /// In en, this message translates to:
  /// **'Move-in date:'**
  String get move_in_date_label;

  /// No description provided for @publication_date.
  ///
  /// In en, this message translates to:
  /// **'Published on:'**
  String get publication_date;

  /// No description provided for @sign_in_with_google.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Google'**
  String get sign_in_with_google;

  /// No description provided for @sign_in_with_google_description.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Google account to continue'**
  String get sign_in_with_google_description;

  /// No description provided for @signing_in.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signing_in;

  /// No description provided for @google_sign_in_failed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed: {error}'**
  String google_sign_in_failed(String error);

  /// No description provided for @popup_closed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in popup was closed'**
  String get popup_closed;

  /// No description provided for @check_out_listing_on_uydosh.
  ///
  /// In en, this message translates to:
  /// **'Check out this listing on UyDosh!'**
  String get check_out_listing_on_uydosh;

  /// No description provided for @share_subject_uz.
  ///
  /// In en, this message translates to:
  /// **'UyDosh - Uy e\'loni'**
  String get share_subject_uz;

  /// No description provided for @share_subject_ru.
  ///
  /// In en, this message translates to:
  /// **'UyDosh - Объявление о жилье'**
  String get share_subject_ru;

  /// No description provided for @share_subject_en.
  ///
  /// In en, this message translates to:
  /// **'UyDosh - Housing Listing'**
  String get share_subject_en;

  /// No description provided for @contact_user.
  ///
  /// In en, this message translates to:
  /// **'Contact User'**
  String get contact_user;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get message;

  /// No description provided for @delete_listing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get delete_listing;

  /// No description provided for @delete_listing_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing? This action cannot be undone.'**
  String get delete_listing_confirmation;

  /// No description provided for @delete_listing_success.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted successfully'**
  String get delete_listing_success;

  /// No description provided for @delete_listing_error.
  ///
  /// In en, this message translates to:
  /// **'Error deleting listing'**
  String get delete_listing_error;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @create_complaint.
  ///
  /// In en, this message translates to:
  /// **'Create Complaint'**
  String get create_complaint;

  /// No description provided for @select_complaint_category.
  ///
  /// In en, this message translates to:
  /// **'Select Complaint Category'**
  String get select_complaint_category;

  /// No description provided for @complaint_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get complaint_description_hint;

  /// No description provided for @submit_complaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submit_complaint;

  /// No description provided for @complaint_created_success.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted successfully'**
  String get complaint_created_success;

  /// No description provided for @listing_complaints.
  ///
  /// In en, this message translates to:
  /// **'Listing Complaints'**
  String get listing_complaints;

  /// No description provided for @listing_complaints_header.
  ///
  /// In en, this message translates to:
  /// **'Complaints for the listing: {count}'**
  String listing_complaints_header(String count);

  /// No description provided for @view_listing_complaints.
  ///
  /// In en, this message translates to:
  /// **'View listing complaints'**
  String get view_listing_complaints;

  /// No description provided for @complaints_count_short.
  ///
  /// In en, this message translates to:
  /// **'{count} complaints'**
  String complaints_count_short(String count);

  /// No description provided for @no_listing_complaints.
  ///
  /// In en, this message translates to:
  /// **'No complaints for this listing yet'**
  String get no_listing_complaints;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
