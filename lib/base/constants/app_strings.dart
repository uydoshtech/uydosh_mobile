// Storage keys for persistent data
class StorageKeys {
  static const String selectedLanguage = "selected_language";
  static const String favoriteListings = "favorite_listings";
  static const String selectedTheme = "selected_theme";
}

class AppStrings {
  static final Map<String, Map<String, String>> _strings = {
    "en": {
      // ===== NAVIGATION =====
      "home": "Listings",
      "favorites": "Favorites",
      "add_to_favorites": "Add to favorites",
      "added_to_favorites": "Added to favorites",
      "removed_from_favorites": "Removed from favorites",
      "remove_from_favorites": "Remove from favorites",
      "edit": "Edit",
      "share": "Share",
      "complain": "Complain",
      "sign_in": "Sign in",

      "location": "Location",
      "create_listing": "Create",
      "profile": "Profile",
      "role_tenant": "Tenant",
      "role_landlord": "Landlord",
      "role_manager": "Manager",
      "role_admin": "Admin",
      "profile_completion": "Profile completion",
      "profile_completion_hint":
          "A completed profile means more accurate matches and comfortable co-living.",
      "complete_profile_prompt_title": "Complete your profile",
      "complete_profile_prompt_body":
          "Add your lifestyle preferences to get better matches.",
      "complete_profile_prompt_cta": "Complete now",
      "complete_profile_prompt_later": "Later",
      "compatibility_title": "Compatibility with you:",
      "compatibility_match_percentage": "Match: {percent}%",
      "compatibility_match_placeholder": "Match: —",
      "compatibility_calculating": "Calculating match...",
      "compatibility_sign_in": "Sign in to see your compatibility",
      "na": "N/A",
      "compatibility_matches": "Matched preferences:",
      "compatibility_differences": "Potential differences:",
      "vs": "vs",
      "name": "Name or nickname",
      "im_from": "I'm from:",

      // ===== APP CORE =====
      "welcome": "Hello",
      "user": "User",
      "welcome_title": "Welcome to UyDosh",
      "welcome_subtitle": "Find your perfect roommate or accommodation",
      "splash_subtitle": "LET'S LIVE TOGETHER!",
      "search_results": "Search Results",
      "close": "Close",
      "cancel": "Cancel",
      "about_uy_dosh": "About UyDosh",
      "privacy_policy_title": "Privacy Policy",
      "privacy_policy_body":
          "ОБНОВЛЁННЫЙ PRIVACY POLICY (без рекламы и подписок)\n\nLast updated: [DATE]\n\nUyDosh respects your privacy. This Privacy Policy explains how we collect and use data.\n\n⸻\n\n1. Data We Collect\n\na. Information You Provide\n\t•\tPhone number\n\t•\tName and profile info\n\t•\tListings and photos\n\t•\tMessages\n\nb. Automatically Collected Data\n\t•\tDevice type and OS\n\t•\tApp usage data\n\t•\tCrash diagnostics\n\nc. Location Data\n\t•\tApproximate location (only if enabled)\n\n⸻\n\n2. How We Use Data\n\nWe use data to:\n\t•\toperate the App\n\t•\tdisplay listings and maps\n\t•\tmaintain safety and moderation\n\t•\timprove functionality\n\n⸻\n\n3. Data Sharing\n\nWe do not sell personal data.\n\nWe may share data:\n\t•\twith service providers (hosting, analytics)\n\t•\tif required by law\n\t•\twith other users (only public profile/listing info)\n\n⸻\n\n4. Data Retention\n\nWe store data only as long as necessary.\nYou may request account and data deletion.\n\n⸻\n\n5. Security\n\nWe apply reasonable measures to protect data, but no system is fully secure.\n\n⸻\n\n6. User Rights\n\nYou may request:\n\t•\taccess to your data\n\t•\tcorrection\n\t•\tdeletion\n\nContact: support@uydosh.app\n\n⸻\n\n7. Children\n\nUyDosh is not intended for users under 18.\n\n⸻\n\n8. Third-Party Services\n\nThe App may use third-party services (e.g., maps). Their policies apply independently.\n\n⸻\n\n9. Updates\n\nWe may update this Policy. Changes take effect when published.\n\n⸻\n\n10. Contact\n\nsupport@uydosh.app",
      "user_license_agreement_title": "User License Agreement",
      "user_license_agreement_body":
          "ОБНОВЛЁННЫЙ EULA (MVP-версия)\n\nLast updated: [DATE]\n\nThis End User License Agreement (\"Agreement\") is a legal agreement between you (\"User\") and UyDosh (\"we\", \"us\", \"our\") governing your use of the UyDosh mobile application (\"App\").\n\nBy accessing or using the App, you agree to this Agreement.\n\n⸻\n\n1. License\n\nWe grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes.\n\n⸻\n\n2. Eligibility\n\nYou must be at least 18 years old to use the App.\n\n⸻\n\n3. Accounts\n\nSome features require account creation.\nYou agree to provide accurate information and keep it up to date.\n\nWe may suspend or terminate accounts that violate this Agreement or pose safety risks.\n\n⸻\n\n4. User Content\n\nThe App allows users to post listings, descriptions, photos, and messages (\"User Content\").\n\nYou retain ownership of your content.\nBy posting content, you grant us a non-exclusive, worldwide license to host, display, and distribute it solely for operating the App.\n\nYou are fully responsible for your User Content.\n\n⸻\n\n5. Prohibited Use\n\nYou agree not to:\n\t•\tPost false, misleading, or illegal listings\n\t•\tHarass, threaten, or discriminate against others\n\t•\tImpersonate another person\n\t•\tUse the App for unlawful purposes\n\t•\tAttempt to access data or accounts without authorization\n\n⸻\n\n6. No Transactions or Guarantees\n\nUyDosh does not participate in rental agreements, payments, or negotiations between users.\n\nWe do not guarantee:\n\t•\taccuracy of listings\n\t•\tavailability of housing\n\t•\tbehavior or reliability of other users\n\nAll interactions occur at your own risk.\n\n⸻\n\n7. Moderation\n\nWe reserve the right to:\n\t•\tremove content\n\t•\trestrict visibility\n\t•\tsuspend or ban users\n\nbased on complaints, violations, or safety concerns.\n\n⸻\n\n8. Location Features\n\nThe App may use approximate location data to display nearby listings and map features.\nYou can disable location access in your device settings.\n\n⸻\n\n9. Disclaimer\n\nThe App is provided \"AS IS\" and \"AS AVAILABLE\".\nWe make no warranties regarding reliability, safety, or suitability.\n\n⸻\n\n10. Limitation of Liability\n\nUyDosh shall not be liable for indirect or consequential damages arising from App usage.\n\n⸻\n\n11. Termination\n\nWe may terminate your access at any time for violation of this Agreement.\n\n⸻\n\n12. Governing Law\n\nThis Agreement is governed by the laws of the jurisdiction where UyDosh operates.\n\n⸻\n\n13. Contact\n\nsupport@uydosh.app\n\n⸻",

      // ===== LOADING STATES =====
      "loading": "Loading",
      "loading...": "Loading...",
      "loading_listings": "Loading listings...",
      "loading_listing_details": "Loading listing details...",

      "loading_universities": "Loading universities...",
      "loading_regions": "Loading regions...",

      // ===== ERROR MESSAGES =====
      "error": "Error",
      "error_loading_listing_details": "Error loading listing details",
      "error_listing_not_loaded": "Listing not loaded yet",
      "error_listing_still_loading": "Listing is still loading",

      "error_loading_profile": "Unable to load profile",

      "error_internet_connection": "Check your internet connection",
      "error_resource_conflict":
          "You have already complained about this listing.",

      // ===== MESSAGING =====
      "conversations": "Messages",
      "messages": "Messages",
      "chat": "Chat",
      "chat_with": "Chat with {name}",
      "profile_interlocutor": "Interlocutor's Profile",
      "view_listing": "View Listing",
      "menu_messages": "Messages",
      "type_message": "Type a message...",
      "conversation_created": "Conversation started",
      "conversation_failed": "Failed to start conversation",
      "no_conversations": "No conversations yet",
      "no_messages": "No messages yet",
      "no_messages_description":
          "You haven't received any messages about your listings yet",
      "error_not_authenticated": "Please log in to start a conversation",
      "error_cannot_message_self": "You cannot message yourself",
      "start_conversation_from_listing":
          "Start a conversation from a listing to begin messaging",
      "today": "Today",
      "tomorrow": "Tomorrow",
      "yesterday": "Yesterday",
      "in_days": "In {days} days",
      "monday": "Monday",
      "tuesday": "Tuesday",
      "wednesday": "Wednesday",
      "thursday": "Thursday",
      "friday": "Friday",
      "saturday": "Saturday",
      "sunday": "Sunday",
      "now": "now",
      "send_first_message": "Send your first message to start the conversation",
      "opening_existing_conversation": "Opening existing conversation",

      // ===== QUICK QUESTIONS =====
      "quick_question_room_available": "Is room available?",
      "quick_question_move_in_date": "When is move in date?",
      "any_date": "Any date",
      "quick_question_people_living":
          "How many people already live in apartment?",
      "private_room": "Private Room",
      "private_room_only": "Private Room",
      "conversation_count": "conversation",
      "conversations_count": "conversations",
      "incoming": "Incoming",
      "outgoing": "Outgoing",
      "no_incoming_conversations": "No incoming conversations",
      "no_outgoing_conversations": "No outgoing conversations",
      "no_incoming_conversations_description":
          "You haven't received any messages about your listings yet",
      "no_outgoing_conversations_description":
          "You haven't started any conversations about other listings yet",
      "retry": "Retry",
      "back_to_listing": "Back to listing",
      "load_more": "Load More",

      "error_generic": "An error occurred",
      "error_loading_regions": "Error loading regions: {error}",
      "error_loading_universities": "Error loading universities: {error}",
      "error_creating_listing": "Error creating listing. Please try again.",
      "error_updating_listing": "Error updating listing",
      "error_uploading_photos": "Error uploading photos",
      "error_deactivating_listing": "Error deactivating listing",
      "error_creating_profile": "Error creating profile: {error}",
      "error_updating_profile": "Error updating profile: {error}",
      "error_opening_edit_screen": "Error opening edit screen: {error}",
      "error_with_message": "Error: {message}",
      "image_load_error": "Failed to load image",

      // ===== SUCCESS MESSAGES =====
      "listing_created_success": "Listing created successfully!",
      "listing_updated_success": "Listing updated successfully",

      "profile_completed_success": "Profile completed successfully!",
      "profile_updated_success": "Profile updated successfully",
      "favorite_added_success": "Added to favorites",
      "favorite_removed_success": "Removed from favorites",

      "successfully_signed_in_google": "Successfully signed in with Google!",

      // ===== EMPTY STATES =====
      "no_listings_found": "No listings found",

      "no_locations_available": "No locations available",

      "no_universities_available": "No universities available",
      "no_search_results": "No search results found",
      "try_refreshing": "Try refreshing or check back later",
      "try_refining_search": "Try refining your search criteria",
      "refine_search": "Refine Search",

      // ===== SELECTION & PROMPTS =====
      "select_metro_line": "Subway line",
      "select_metro_line_title": "Select\nsubway line",
      "select_location": "Any district",
      "not_selected": "Not selected",
      "search_location_or_metro_hint":
          "Choose one option: district or metro station",

      "all_stations_count": "All {count} stations",
      "all_stations_explanation":
          "Search along the entire line <b>{line}</b> through <b>{count}</b> stations",
      "metro_tutorial_search_hint":
          "Search along metro line or by individual stations.",
      "metro_tutorial_line_hint": "Search listings on all metro line stations",
      "metro_tutorial_station_hint": "Search by particular metro stations",
      "metro_tutorial_tap_to_continue": "Tap anywhere to continue",
      "select_region": "Choose region:",
      "select_region_profile_creation_title": "Where are you from?",
      "select_region_profile_creation_description":
          "We'll help you find people from your hometown.",
      "select_university": "Select university",

      "select_language": "Select Language",
      "select_theme": "Select Theme",
      "select_theme_description": "Choose your preferred app theme",
      "please_complete_previous_steps": "Please complete previous steps first",
      "please_complete_all_fields": "Please complete all fields",
      "please_select_university": "Please select a university",
      "tap_to_select_region": "Tap to select region",
      "no_regions_available": "No regions available",

      // ===== ACTION BUTTONS =====
      "refresh": "Refresh",
      "actions": "Actions",

      "view_profile": "Profile",
      "deactivate_listing": "Deactivate",
      "deactivate_listing_confirmation": "Are you sure you want to deactivate this listing? It will no longer be visible to other users.",
      "deactivate": "Deactivate",
      "activate_listing": "Activate Listing",
      "activate_listing_confirmation": "Are you sure you want to activate this listing? It will become visible to other users.",
      "activate": "Activate",
      "listing_active": "Active",
      "listing_inactive": "Inactive",

      "create_listing_button": "Create Listing",
      "update_listing_button": "Update Listing",
      "save_changes": "Save Changes",

      "confirm": "Confirm",
      "next": "Next",
      "back": "Back",

      "complete": "Complete",

      // ===== THEME & APPEARANCE =====
      "settings": "Settings",
      "theme": "Theme",
      "blue_theme": "Blue",
      "light_theme": "Light",
      "theme_changed_to": "Theme changed to {theme}",
      "theme_color": "Theme color",
      "switch_theme": "Switch Theme",

      // ===== ABOUT & FEATURES =====
      "about_description":
          "UyDosh is your trusted platform for finding the perfect home in Tashkent.",
      "about_feature_1": "• Browse listings by metro station",
      "about_feature_2": "• Search by district",
      "about_feature_3": "• Direct contact with property owners",
      "about_feature_4": "• Verified and safe listings",

      // ===== METRO SYSTEM =====
      "location_on_map": "Location",
      "show_map": "Show map",
      "hide_map": "Hide map",
      "open_in_yandex_maps": "Open in Yandex Maps",
      "open_in_yandex_maps_confirmation":
          "A browser with Yandex Maps will be opened.",

      // ===== LISTING DETAILS =====
      "listing_details": "Details",
      "author": "Author",
      "show_details": "Show details",
      "hide_details": "Hide details",
      "listing_views_by_others": "{count} views",
      "listing_views_stats_title": "View statistics",
      "listing_views_stats_empty": "No views yet",
      "error_loading_view_stats": "Error loading view statistics",
      "promote_listing": "Promote",
      "remove_from_top": "Remove from top",
      "feature_listing_success": "Listing moved to top",
      "unfeature_listing_success": "Listing removed from top",
      "feature_listing_error": "Failed to update listing",
      "error_promotion_once_per_week":
          "You can only promote a listing once per week",

      "listing_title_hint": "Enter listing title",

      "listing_description_hint": "Enter listing description",
      "listing_price_label": "Price",
      "listing_translate_tooltip_en": "Translate to English",
      "listing_translate_tooltip_ru": "Translate to Russian",
      "listing_translate_tooltip_uz": "Translate to Uzbek",
      "listing_show_original_description": "Original",
      "listing_translating_description": "Translating…",
      "listing_translation_error": "Couldn’t translate. Try again.",
      "listing_translation_unavailable": "Translation unavailable.",
      "listing_ai_enhance": "AI enhance",
      "listing_ai_enhance_empty": "Enter a description first.",
      "listing_ai_enhance_unavailable": "AI enhancement isn’t available on this device.",
      "listing_ai_enhance_error": "Couldn’t improve the text. Try again.",

      "listing_type_roommate_needed": "Need Roommate",
      "listing_type_room_needed": "Need Room",
      "title_male_roommate": "#NeedRoommate",
      "title_female_roommate": "#NeedRoommate",
      "title_male_room": "#NeedRoom",
      "title_female_room": "#NeedRoom",
      "listing_photos_label": "Photos",

      "delete_photo": "Delete Photo",
      "delete_photo_confirmation":
          "Are you sure you want to delete this photo?",
      "photo_deleted_success": "Photo deleted successfully",
      "error_deleting_photo": "Error deleting photo. Please try again.",
      "photo_made_primary": "Photo set as primary",
      "new_primary_photo_selected": "New primary photo automatically selected",
      "last_photo_deleted": "Last photo deleted - no photos remaining",
      "cannot_delete_last_photo": "Cannot delete the last photo",
      "tap_photo_to_make_primary": "Tap photo to make primary",
      "making_primary": "Making primary...",
      "add_photo": "Add Photo",
      "take_photo": "Take Photo",
      "choose_from_gallery": "Choose from Gallery",
      "photo_limit_reached": "Maximum 5 photos allowed",

      "max_photos_reached": "Maximum photos reached",
      "max_photos_message":
          "You can only upload up to 5 photos. Please remove some photos before adding new ones.",

      "ok": "OK",
      "delete": "Delete",

      // ===== ONBOARDING =====
      "onboarding_title_1": "Find Your Perfect Roommates",
      "onboarding_subtitle_1":
          "Fast search for roommates for shared living throughout Tashkent",
      "onboarding_title_2": "Search by Metro",
      "onboarding_subtitle_2":
          "Search either by stations - or by the entire metro line",
      "onboarding_title_3": "Search by District",
      "onboarding_subtitle_3": "Convenient search by districts of Tashkent",
      "onboarding_title_4": "Trustworthy Platform",
      "onboarding_subtitle_4":
          "Verified users connecting for apartments and roommates",

      "onboarding_get_started": "Get Started",
      "onboarding_skip": "Skip",
      "onboarding_next": "Next",
      "onboarding_back": "Back",
      "onboarding_toggle": "Onboarding",
      "onboarding_toggle_description": "Show welcome screens",
      "haptic_feedback": "Haptic feedback",
      "haptic_feedback_description": "Vibration for taps and gestures",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "English",
      "language": "Language",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_changed_to": "Language changed to {language}",

      // ===== PROFILE & USER INFO =====
      "gender": "Gender",
      "male": "Guy",
      "female": "Girl",
      "other": "Other",

      "university": "University",
      "same_university": "Same University",
      "both_students": "Both students",
      "region": "Region",
      "same_region": "Same Region",
      "rating": "Rating",
      "about_me": "About Me",
      "telegram": "Telegram",
      "open_in_telegram": "Open in Telegram",
      "open_in_telegram_confirmation": "Telegram will be opened.",

      // New profile fields
      "employed": "Employed",
      "cleanliness": "Cleanliness",
      "noise_level": "Noise Level",
      "sociability": "Sociability",
      "guests_allowed": "Guests Allowed",
      "smoking_preference": "Smoking",
      "alcohol_preference": "Alcohol",
      "cooking_habits": "Cooking Habits",
      "pets_preference": "Pets Preference",
      "wakeup_time": "Wake-up Time",
      "sleep_time": "Sleep Time",

      // Preference options
      "non_smoker": "Non-smoker",
      "occasional_smoker": "Occasional smoker",
      "regular_smoker": "Regular smoker",
      "non_drinker": "Non-drinker",
      "occasional_drinker": "Occasional drinker",
      "regular_drinker": "Regular drinker",
      "morning": "Morning",
      "evening": "Evening",
      "night": "Night",
      "pets_okay": "Okay",
      "pets_not_okay": "Not great",

      // Slider labels
      "lifestyle_preferences": "Lifestyle Preferences",
      "very_messy": "Very Messy",
      "messy": "Messy",
      "average": "Average",
      "clean": "Clean",
      "very_clean": "Very Clean",
      "very_quiet": "Very Quiet",
      "quiet": "Quiet",
      "loud": "Loud",
      "very_loud": "Very Loud",
      "very_introverted": "Very Introverted",
      "introverted": "Introverted",
      "balanced": "Balanced",
      "extroverted": "Extroverted",
      "very_extroverted": "Very Extroverted",
      "yes": "Yes",
      "no": "No",
      "cook": "Cook",
      "dont_cook": "Don't cook",

      "not_specified": "Not Specified",

      // ===== AUTHENTICATION =====
      "complete_profile": "Complete Your Profile",
      "complete_profile_subheader":
          "We use this information to find the perfect roommates and matches for you.",

      "full_name": "Name or nickname",

      "are_you_student": "Are you a student?",
      "yes_student": "Yes, I'm a student",
      "no_student": "No, I'm not a student",

      "are_you_landlord_or_renter": "Are you a landlord or renter?",

      "selected": "Selected",

      "full_name_hint": "Enter your name or nickname",
      "name_required": "Name or nickname is required",
      "saving": "Saving...",
      "firebase_user_not_found": "Firebase user not found",
      "user_blocked_violation_title": "Account restricted",
      "user_blocked_violation_message":
          "Your account has been restricted due to a violation. You can browse the app but cannot post listings, send messages, or edit content. Please contact support if you have questions.",
      "profile_not_loaded_yet": "Profile not loaded yet",
      "profile_still_loading": "Profile still loading",
      "welcome_back_profile_exists": "Welcome back! Profile already exists.",
      "tap_to_select_university": "Tap to select a university",

      // ===== MENU & NAVIGATION =====
      "menu_profile": "Profile",
      "menu_home": "Listings",
      "menu_language": "Language",

      "menu_favorites": "Favorites",
      "menu_history": "History",
      "menu_contact_support": "Contact Support",
      "menu_add_listing": "Add Listing",
      "menu_my_listings": "My Listings",

      "menu_about": "About",
      "menu_privacy_policy": "Privacy Policy",
      "menu_user_license_agreement": "User License Agreement",
      "menu_faq": "FAQ",
      "menu_settings": "Settings",
      "menu_registration": "Sign in",
      "menu_logout": "Logout",
      "menu_admin_panel": "Admin Panel",
      "manage_property": "Manage Property",

      "admin_panel_title": "Admin Panel",
      "admin_panel_section_content_moderation": "Photo moderation",
      "admin_content_moderation_title": "Photo moderation",
      "admin_content_moderation_description":
          "When enabled, uploaded photos are scanned for offensive content; matching images are blurred before they are stored. When disabled, scanning and blurring are skipped (no AWS Rekognition calls).",
      "admin_content_moderation_blur_enabled": "Detect and blur offensive photos",
      "admin_content_moderation_loading": "Loading moderation settings...",
      "admin_content_moderation_error": "Could not load moderation settings",
      "admin_content_moderation_save_error": "Could not save setting",

      "admin_panel_section_users": "Users",
      "admin_panel_section_support_chat": "Support chat",
      "admin_panel_section_complaints": "Complaints",
      "admin_panel_section_listing_complaints": "Listings with complaints",
      "admin_panel_section_district_heatmap": "District heat map",
      "admin_panel_section_subway_heatmap": "Subway line heat map",
      "admin_panel_section_subway_map": "Subway map",
      "admin_panel_section_search_analytics": "Search analytics",
      "admin_panel_section_listing_creation_analytics":
          "Listings creation analytics",

      "admin_search_analytics_title": "Search analytics",
      "admin_search_analytics_loading": "Loading search analytics...",
      "admin_search_analytics_error": "Failed to load search analytics",
      "admin_search_analytics_retry": "Retry",
      "admin_search_analytics_time_range": "Time range",
      "admin_search_analytics_days": "Last {days} days",
      "admin_search_analytics_all_time": "All time",
      "admin_search_analytics_total": "Total searches",
      "admin_search_analytics_today": "Today",
      "admin_search_analytics_week": "This week",
      "admin_search_analytics_top_stations": "Top metro stations",
      "admin_search_analytics_top_districts": "Top districts",
      "admin_search_analytics_top_lines": "Top metro lines",
      "admin_search_analytics_searches": "searches",
      "admin_search_analytics_no_stations": "No station search data yet",
      "admin_search_analytics_no_districts": "No district search data yet",
      "admin_search_analytics_no_lines": "No line search data yet",

      "admin_listing_creation_analytics_title": "Listings creation analytics",
      "admin_listing_creation_analytics_loading":
          "Loading listings creation analytics...",
      "admin_listing_creation_analytics_error":
          "Failed to load listings creation analytics",
      "admin_listing_creation_analytics_retry": "Retry",
      "admin_listing_creation_analytics_time_range": "Time range",
      "admin_listing_creation_analytics_total": "Total in period",
      "admin_listing_creation_analytics_today": "Today",
      "admin_listing_creation_analytics_week": "This week",
      "admin_listing_creation_analytics_by_day": "Listings by day",
      "admin_listing_creation_analytics_no_data": "No listing data in this period",

      "admin_district_heatmap_title": "District heat map",
      "admin_district_heatmap_description":
          "Listings by district with heat intensity based on volume.",
      "admin_district_heatmap_loading": "Loading district stats...",
      "admin_district_heatmap_error": "Failed to load district stats",
      "admin_district_heatmap_retry": "Retry",
      "admin_district_heatmap_total": "Total listings",
      "admin_district_heatmap_max": "Max in district",
      "admin_district_heatmap_count_label": "Listings",
      "admin_district_heatmap_unavailable": "Unavailable",
      "admin_district_heatmap_no_data": "No district data available",

      "admin_subway_heatmap_title": "Subway line heat map",
      "admin_subway_heatmap_description":
          "Listings by subway line with heat intensity based on volume.",
      "admin_subway_heatmap_loading": "Loading subway line stats...",
      "admin_subway_heatmap_error": "Failed to load subway line stats",
      "admin_subway_heatmap_retry": "Retry",
      "admin_subway_heatmap_total": "Total listings",
      "admin_subway_heatmap_max": "Max on line",
      "admin_subway_heatmap_count_label": "Listings",
      "admin_subway_heatmap_unavailable": "Unavailable",
      "admin_subway_heatmap_no_data": "No subway line data available",

      "admin_subway_map_title": "Subway map",
      "admin_subway_map_description":
          "Simplified map with lines and stations only.",
      "error_loading_map": "Failed to load map",

      "admin_users_title": "Users",
      "admin_users_loading": "Loading users...",
      "admin_users_empty": "No users found",
      "admin_users_error": "Failed to load users",
      "admin_users_id": "ID",
      "admin_users_role": "Role",
      "admin_users_created_at": "Created",
      "admin_users_listings_count": "Listings",
      "admin_users_listings_count_loading": "Loading...",
      "admin_users_listings_count_error": "Unavailable",
      "admin_user_detail_title": "User details",
      "admin_user_detail_role_title": "Role management",
      "admin_user_detail_role_label": "Role",
      "admin_user_detail_role_save": "Save role",
      "admin_user_detail_role_updated": "Role updated",
      "admin_user_detail_view_listings": "View listings",
      "admin_user_detail_view_complaints": "View complaints",
      "admin_user_detail_block_title": "Block status",
      "admin_user_detail_block": "Block user",
      "admin_user_detail_unblock": "Unblock",
      "admin_user_detail_blocked": "Blocked",
      "admin_user_detail_block_reason": "Reason",
      "admin_user_detail_block_until": "Block until",
      "admin_user_detail_block_permanent": "Permanent",
      "admin_user_detail_block_confirm": "Block",
      "admin_user_detail_blocked_success": "User blocked",
      "admin_user_detail_unblocked_success": "User unblocked",
      "admin_user_complaints_title": "User complaints",
      "admin_user_complaints_user": "User",
      "admin_user_complaints_empty": "No complaints found",
      "admin_user_complaints_group_count": "Complaints",

      "admin_user_listings_title": "User listings",
      "admin_user_listings_user": "User",
      "admin_user_listings_empty": "No listings found",
      "admin_user_listings_error": "Failed to load listings",

      "admin_complaints_title": "Complaints",
      "admin_complaints_loading": "Loading complaints...",
      "admin_complaints_empty": "No complaints found",
      "admin_complaints_error": "Failed to load complaints",
      "admin_complaints_filter_all": "All",
      "admin_complaints_filter_pending": "Pending",
      "admin_complaints_filter_resolved": "Resolved",
      "admin_complaints_filter_dismissed": "Dismissed",
      "admin_complaints_status_label": "Status",
      "admin_complaints_status_pending": "Pending",
      "admin_complaints_status_resolved": "Resolved",
      "admin_complaints_status_dismissed": "Dismissed",
      "admin_complaints_listing_id": "Listing",
      "admin_complaints_complainant_id": "User",
      "admin_complaints_category_unknown": "Unknown category",
      "admin_complaints_created_at": "Created",
      "admin_complaints_text": "Description",
      "admin_complaints_update_status": "Update status",
      "admin_complaints_status_updated": "Status updated",

      "admin_support_chat_title": "Support chat",
      "admin_support_chat_loading": "Loading support threads...",
      "admin_support_chat_empty": "No support threads yet",
      "admin_support_chat_error": "Failed to load support chat",
      "admin_support_chat_retry": "Retry",
      "admin_support_chat_filter_all": "All",
      "admin_support_chat_filter_open": "Open",
      "admin_support_chat_filter_closed": "Closed",
      "admin_support_chat_status_open": "Open",
      "admin_support_chat_status_closed": "Closed",
      "admin_support_chat_messages": "messages",
      "admin_support_chat_yesterday": "Yesterday",
      "admin_support_chat_days_ago": "days ago",
      "admin_support_chat_no_messages": "No messages yet",
      "admin_support_chat_reply_hint": "Type your reply...",
      "admin_support_chat_close_thread": "Close thread",
      "admin_support_chat_reopen_thread": "Reopen thread",
      "admin_support_chat_closed": "Thread closed",
      "admin_support_chat_reopened": "Thread reopened",
      "admin_support_chat_thread_closed": "This thread is closed. Reopen to reply.",

      "contact_support_title": "Contact Support",
      "contact_support_loading": "Loading...",
      "contact_support_error": "Failed to load support",
      "contact_support_empty": "No support conversations yet. Start a new one to get help.",
      "contact_support_new": "New conversation",
      "contact_support_message_hint": "Type your message...",
      "admin_listing_complaints_title": "Listings with complaints",
      "admin_listing_complaints_empty": "No listings with complaints",
      "admin_listing_complaints_error": "Failed to load listings with complaints",
      "admin_listing_complaints_last_reported": "Last complaint",
      "admin_listing_complaints_categories": "Complaints",
      "admin_listing_complaints_categories_empty": "No complaint categories",

      // ===== FAQ CONTENT =====
      "faq_question": "How to negotiate with roommates and avoid conflicts?",
      "faq_answer": "Living together is always about respect and the ability to negotiate. Here are some simple rules that will help maintain peace and friendship:\n\nNoise\nAgree on \"quiet hours\". For music — headphones, for calls — hallway or street. It's convenient to hang a schedule so everyone knows when someone has study or rest time.\n\nGuests\nWarn each other in advance. A good rule is certain days for guests and days for quiet.\n\nEmotions\nDon't accumulate irritation. Speak calmly and immediately if something bothers you. And it's better to release extra stress at the gym or on a run.\n\nCommon activities\nSometimes it's useful to do something together: go to the movies, take a walk, have a \"cleaning to music\". Shared memories strengthen friendship.\n\nCleaning and household\nDivide responsibilities — someone mops the floor, someone takes out the trash. The main thing is to negotiate and respect personal boundaries. Don't touch other people's things without permission.\n\nCommunication\nUse \"I-messages\": instead of \"you annoy me\" it's better to say \"it's hard for me to concentrate when loud music is playing\".\n\nConflict resolution\nTry to discuss everything calmly, listening to each other. Conflict is an opportunity to find a common solution, not an enemy.\n\nFood\nYou can agree on joint purchases or start a \"common shelf\" for treats.\n\nOrder and quiet\nCleaning schedule is your best friend. And if you need to concentrate — you can go to the library or coworking, or turn on the \"quiet hour\" rule again.",

      "faq_question_2": "Utility debts and how to avoid them",
      "faq_answer_2": "Sometimes along with the apartment, the tenant gets utility debts as a \"gift\". As a result — disconnected electricity or water, and the landlord is in no hurry to pay. The tenant is left to choose: move out with losses or pay off the debt at their own expense.\n\nTo avoid such situations:\n\nCheck before signing\nBefore signing the contract, ask the owner for receipts or a report on paid utility bills.\n\nWritten agreement\nIf there is still a debt and you are ready to pay it, be sure to draw up a written agreement: the amount of the debt will be credited to future rent.\n\nThis way you will save both money and peace of mind.",

      "faq_question_3": "Promised repairs take three years to wait",
      "faq_answer_3": "Often when renting housing, the owner promises to fix problems in the apartment, buy household appliances and furniture. All this he undertakes to fulfill immediately after moving in. However, time passes, and the problems remain. To avoid becoming a hostage to such a situation, the tenant should include special conditions in the rental agreement.\n\nAlso, oral agreements about repairs by the tenant and the obligation not to charge rent during the work are often violated. For example, you renovate the apartment at your own expense and don't pay rent for several months. However, some landlords \"forget\" about the agreements and demand payment for accommodation. Often the parties have disagreements about the cost of finishing, and sometimes the matter even comes to court.\n\nTherefore, you should discuss all aspects of the repair, take them into account in the rental agreement, as well as draw up an estimate and sign it.",

      "faq_question_4": "You are no longer my friend",
      "faq_answer_4": "Often when renting housing to relatives or friends, no contract is concluded. At the same time, many scandals and disputes occur precisely between relatives and friends who accepted promises and obligations for rent verbally. Therefore, it is better to conclude a contract, even if you are renting an apartment from your uncle or close friend.\n\nThere are cases when apartments are rented by proxy, which states: the principal gives the authorized person the right to rent out his apartment. \"But the power of attorney does not specify that the authorized person also has the right to receive rent. A situation may occur: the tenant regularly pays the rent to the authorized person, but one day the owner of the living space appears and demands that the tenant pay for the past period of residence in the apartment.\" In this case, you should carefully study the documents, and if the power of attorney does not specify the right to receive rent, discuss this point.",

      "faq_question_5": "Safety guide for renters and neighbors",
      "faq_answer_5": "Sometimes unpleasant situations happen not only on our platform. Unfortunately, inadequate or troubled people are everywhere. Therefore, it is important to remember simple safety rules.\n\n🙏 The main thing is your safety!\n\nBefore the meeting\n• Arrange meetings only during the day.\n• Try to choose crowded places — cafes, shopping centers, courtyards with cameras.\n• Tell friends or relatives where you are going and who you are meeting.\n\nDuring the meeting\n• If possible, don't come alone.\n• Don't hand over money and documents \"hand to hand\" until the contract is signed.\n• Save correspondence and photos/scans of documents — this is your protection.\n\nIf you feel threatened\n• Immediately stop the meeting and leave.\n• Don't be afraid to say \"no\" and break off communication.\n• In case of obvious danger — call 102 or contact the nearest police station.\n\nOn the UyDosh platform\n• Use the verification system — verified profiles reduce risk.\n• Report suspicious ads and behavior to moderators.\n• Remember: it's better to be safe than sorry.\n\n❤️ Take care of yourself and each other!",

      // ===== LOGOUT & SESSION =====
      "logout_confirmation": "Logout Confirmation",
      "logout_description":
          "Are you sure you want to logout? You will need to sign in again to access your profile.",
      "logout": "Logout",
      "logout_success": "Successfully logged out",

      // ===== DELETE ACCOUNT =====
      "delete_account": "Delete account",
      "delete_account_confirmation":
          "Are you sure you want to delete your account? This action cannot be undone. All your data, listings, and messages will be permanently removed.",
      "delete_account_success": "Account deleted successfully",
      "delete_account_error": "Error deleting account",
      "delete_account_blocked":
          "Your account has been restricted. You cannot delete your account while it is blocked. Please contact support.",

      // ===== FAVORITES =====
      "favorites_title": "Favorites",
      "favorites_empty_title": "No favorites yet",
      "favorites_browse_button": "Browse Listings",

      // ===== VIEW HISTORY =====
      "view_history_title": "View history",
      "view_history_empty_title": "No viewed listings yet",
      "view_history_browse_button": "Browse Listings",
      "view_history_auth_prompt": "Please log in to view your history.",
      "unable_to_load_view_history":
          "Unable to load view history. Please try again later.",

      // ===== ACHIEVEMENTS =====
      "menu_achievements": "Achievements",
      "achievements_title": "Achievements",
      "achievement_unlocked": "Achievement unlocked!",
      "achievement_first_steps": "First Steps",
      "achievement_first_steps_desc": "Create your account",
      "achievement_profile_complete": "Profile Complete",
      "achievement_profile_complete_desc": "Complete your profile 100%",
      "achievement_first_look": "First Look",
      "achievement_first_look_desc": "View your first listing",
      "achievement_bookmarker": "Bookmarker",
      "achievement_bookmarker_desc": "Add your first favorite",
      "achievement_ice_breaker": "Ice Breaker",
      "achievement_ice_breaker_desc": "Send your first message",
      "achievement_first_listing": "First Listing",
      "achievement_first_listing_desc": "Create your first listing",
      "achievement_returning_user": "Returning User",
      "achievement_returning_user_desc": "Use the app 7 days in a row",
      "achievement_sharer": "Sharer",
      "achievement_sharer_desc": "Share your first listing",
      "achievements_empty": "No achievements yet",
      "achievements_empty_desc": "Complete actions to unlock achievements",
      "achievements_auth_prompt": "Log in to view your achievements",

      "favorite_toggle_error": "Failed to update favorite status",
      "favorite_toggle_network_error": "Network error updating favorite status",

      "unable_to_load_favorites":
          "Unable to load favorites. Please try again later.",

      // ===== CREATE & EDIT LISTING =====
      "create_listing_title": "Create Listing",
      "edit_listing": "Edit Listing",
      "edit_profile": "Edit Profile",
      "updating_listing": "Updating...",
      "creating_listing": "Creating...",
      "title_required": "Title is required",
      "title_too_long": "Title must be 25 characters or less",
      "description_required": "Description is required",
      "description_too_long": "Description must be 500 characters or less",
      "location_required": "Please select a location",

      "auth_required_title": "Authentication required",
      "authentication_required":
          "Authentication required. Please log in to create listings.",

      "unauthenticated_listing_prompt":
          "To create and post listings, you need to sign in to your account.",
      "authenticate_to_post_listing": "Authenticate to post listing",
      "select_location_required": "Select location",
      "select_metro_line_optional": "Metro line",

      // ===== AMENITIES & FEATURES =====
      "amenities": "Amenities",
      "photos": "Photos",
      "primary": "Primary",
      "wifi": "Wi-Fi",
      "bed": "Bed",
      "air_conditioning": "Air Conditioning",
      "tv": "TV",
      "microwave": "Microwave",
      "washing_machine": "Washing Machine",
      "pets": "Pets Allowed",

      // ===== PRICING & FINANCIAL =====
      "month": "month",

      // ===== SEARCH & FILTERS =====
      "search_listings": "Search Listings",

      "search": "Search",
      "tutorial_search_title": "Search for listings",
      "tutorial_search_description":
          "Tap here to filter listings by location, price, room type, and more.",
      "tutorial_profile_description":
          "Your profile and account settings are here.",
      "tutorial_got_it": "Got it",
      "tutorial_metro_description":
          "Choose a metro line, then pick a station to filter by location.",

      // ===== TIME & DATES =====
      "january": "January",
      "february": "February",
      "march": "March",
      "april": "April",
      "may": "May",
      "june": "June",
      "july": "July",
      "august": "August",
      "september": "September",
      "october": "October",
      "november": "November",
      "december": "December",
      "select_date": "Move in date",
      "move_in_date_label": "Move-in date:",
      "publication_date": "Published on:",

      // ===== GOOGLE AUTHENTICATION =====
      "sign_in_with_google": "Sign In with Google",
      "sign_in_with_google_description":
          "Sign in to your Google account to continue",

      "signing_in": "Signing in...",
      "google_sign_in_failed": "Google Sign-In failed: {error}",
      "popup_closed": "Sign-in popup was closed",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Check out this listing on UyDosh!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Contact User",
      "message": "Write",

      // ===== STATUS & STATE =====
      "delete_listing": "Delete Listing",
      "delete_listing_confirmation":
          "Are you sure you want to delete this listing? This action cannot be undone.",
      "delete_listing_success": "Listing deleted successfully",
      "delete_listing_error": "Error deleting listing",
      "unknown": "Unknown",

      // ===== COMPLAINTS =====
      "create_complaint": "Create Complaint",
      "select_complaint_category": "Select Complaint Category",
      "complaint_description_hint": "Add details (optional)",
      "submit_complaint": "Submit Complaint",
      "complaint_created_success": "Complaint submitted successfully",
      "listing_complaints": "Listing Complaints",
      "listing_complaints_header": "Complaints for the listing: {count}",
      "view_listing_complaints": "View listing complaints",
      "complaints_count_short": "{count} complaints",
      "no_listing_complaints": "No complaints for this listing yet",
    },
    "ru": {
      // ===== NAVIGATION =====
      "home": "Объявления",
      "favorites": "Избранное",
      "add_to_favorites": "Добавить в избранное",
      "added_to_favorites": "Добавлено в избранное",
      "removed_from_favorites": "Удалено из избранного",
      "remove_from_favorites": "Удалить из избранного",
      "edit": "Редактировать",
      "share": "Поделиться",
      "complain": "Пожаловаться",
      "sign_in": "Войти",

      "location": "Район",
      "create_listing": "Создать",
      "profile": "Профиль",
      "role_tenant": "Арендатор",
      "role_landlord": "Арендодатель",
      "role_manager": "Менеджер",
      "role_admin": "Администратор",
      "profile_completion": "Заполнение профиля",
      "profile_completion_hint":
          "Заполненный профиль = более точные совпадения и комфортное соседство.",
      "complete_profile_prompt_title": "Заполните профиль",
      "complete_profile_prompt_body":
          "Укажите предпочтения по образу жизни, чтобы получить лучшие совпадения.",
      "complete_profile_prompt_cta": "Заполнить сейчас",
      "complete_profile_prompt_later": "Позже",
      "compatibility_title": "Совместимость с вами:",
      "compatibility_match_percentage": "Совпадение: {percent}%",
      "compatibility_match_placeholder": "Совпадение: —",
      "compatibility_calculating": "Считаем совпадение...",
      "compatibility_sign_in": "Войдите, чтобы увидеть совместимость",
      "na": "Н/Д",
      "compatibility_matches": "Совпадающие предпочтения:",
      "compatibility_differences": "Возможные различия:",
      "vs": "vs",
      "name": "Имя или никнейм",
      "im_from": "Я из:",

      // ===== APP CORE =====
      "welcome": "Привет",
      "user": "Пользователь",
      "welcome_title": "Добро пожаловать в UyDosh",
      "welcome_subtitle": "Найди идеального соседа или жильё",
      "splash_subtitle": "ДАВАЙТЕ ЖИТЬ ВМЕСТЕ!",
      "search_results": "Результаты поиска",
      "close": "Закрыть",
      "cancel": "Отмена",
      "about_uy_dosh": "Об UyDosh",
      "privacy_policy_title": "Политика конфиденциальности",
      "privacy_policy_body":
          "ОБНОВЛЁННЫЙ PRIVACY POLICY (без рекламы и подписок)\n\nLast updated: [DATE]\n\nUyDosh respects your privacy. This Privacy Policy explains how we collect and use data.\n\n⸻\n\n1. Data We Collect\n\na. Information You Provide\n\t•\tPhone number\n\t•\tName and profile info\n\t•\tListings and photos\n\t•\tMessages\n\nb. Automatically Collected Data\n\t•\tDevice type and OS\n\t•\tApp usage data\n\t•\tCrash diagnostics\n\nc. Location Data\n\t•\tApproximate location (only if enabled)\n\n⸻\n\n2. How We Use Data\n\nWe use data to:\n\t•\toperate the App\n\t•\tdisplay listings and maps\n\t•\tmaintain safety and moderation\n\t•\timprove functionality\n\n⸻\n\n3. Data Sharing\n\nWe do not sell personal data.\n\nWe may share data:\n\t•\twith service providers (hosting, analytics)\n\t•\tif required by law\n\t•\twith other users (only public profile/listing info)\n\n⸻\n\n4. Data Retention\n\nWe store data only as long as necessary.\nYou may request account and data deletion.\n\n⸻\n\n5. Security\n\nWe apply reasonable measures to protect data, but no system is fully secure.\n\n⸻\n\n6. User Rights\n\nYou may request:\n\t•\taccess to your data\n\t•\tcorrection\n\t•\tdeletion\n\nContact: support@uydosh.app\n\n⸻\n\n7. Children\n\nUyDosh is not intended for users under 18.\n\n⸻\n\n8. Third-Party Services\n\nThe App may use third-party services (e.g., maps). Their policies apply independently.\n\n⸻\n\n9. Updates\n\nWe may update this Policy. Changes take effect when published.\n\n⸻\n\n10. Contact\n\nsupport@uydosh.app",
      "user_license_agreement_title": "Лицензионное соглашение пользователя",
      "user_license_agreement_body":
          "ОБНОВЛЁННЫЙ EULA (MVP-версия)\n\nLast updated: [DATE]\n\nThis End User License Agreement (\"Agreement\") is a legal agreement between you (\"User\") and UyDosh (\"we\", \"us\", \"our\") governing your use of the UyDosh mobile application (\"App\").\n\nBy accessing or using the App, you agree to this Agreement.\n\n⸻\n\n1. License\n\nWe grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes.\n\n⸻\n\n2. Eligibility\n\nYou must be at least 18 years old to use the App.\n\n⸻\n\n3. Accounts\n\nSome features require account creation.\nYou agree to provide accurate information and keep it up to date.\n\nWe may suspend or terminate accounts that violate this Agreement or pose safety risks.\n\n⸻\n\n4. User Content\n\nThe App allows users to post listings, descriptions, photos, and messages (\"User Content\").\n\nYou retain ownership of your content.\nBy posting content, you grant us a non-exclusive, worldwide license to host, display, and distribute it solely for operating the App.\n\nYou are fully responsible for your User Content.\n\n⸻\n\n5. Prohibited Use\n\nYou agree not to:\n\t•\tPost false, misleading, or illegal listings\n\t•\tHarass, threaten, or discriminate against others\n\t•\tImpersonate another person\n\t•\tUse the App for unlawful purposes\n\t•\tAttempt to access data or accounts without authorization\n\n⸻\n\n6. No Transactions or Guarantees\n\nUyDosh does not participate in rental agreements, payments, or negotiations between users.\n\nWe do not guarantee:\n\t•\taccuracy of listings\n\t•\tavailability of housing\n\t•\tbehavior or reliability of other users\n\nAll interactions occur at your own risk.\n\n⸻\n\n7. Moderation\n\nWe reserve the right to:\n\t•\tremove content\n\t•\trestrict visibility\n\t•\tsuspend or ban users\n\nbased on complaints, violations, or safety concerns.\n\n⸻\n\n8. Location Features\n\nThe App may use approximate location data to display nearby listings and map features.\nYou can disable location access in your device settings.\n\n⸻\n\n9. Disclaimer\n\nThe App is provided \"AS IS\" and \"AS AVAILABLE\".\nWe make no warranties regarding reliability, safety, or suitability.\n\n⸻\n\n10. Limitation of Liability\n\nUyDosh shall not be liable for indirect or consequential damages arising from App usage.\n\n⸻\n\n11. Termination\n\nWe may terminate your access at any time for violation of this Agreement.\n\n⸻\n\n12. Governing Law\n\nThis Agreement is governed by the laws of the jurisdiction where UyDosh operates.\n\n⸻\n\n13. Contact\n\nsupport@uydosh.app\n\n⸻",

      // ===== LOADING STATES =====
      "loading": "Загрузка",
      "loading...": "Загрузка...",
      "loading_listings": "Загрузка объявлений...",
      "loading_listing_details": "Загрузка деталей объявления...",

      "loading_universities": "Загрузка университетов...",
      "loading_regions": "Загрузка районов...",

      // ===== ERROR MESSAGES =====
      "error": "Ошибка",
      "error_loading_listing_details": "Ошибка загрузки деталей объявления",
      "error_listing_not_loaded": "Объявление еще не загружено",
      "error_listing_still_loading": "Объявление все еще загружается",

      "error_loading_profile": "Не удалось загрузить профиль",

      "error_internet_connection": "Проверьте подключение к интернету",
      "error_resource_conflict": "Вы уже пожаловались на это объявление.",

      // ===== MESSAGING =====
      "conversations": "Сообщения",
      "messages": "Сообщения",
      "chat": "Чат",
      "chat_with": "Чат с {name}",
      "profile_interlocutor": "Профиль Собеседника",
      "view_listing": "Посмотреть объявление",
      "menu_messages": "Сообщения",
      "type_message": "Введите сообщение...",
      "conversation_created": "Разговор начат",
      "conversation_failed": "Не удалось начать разговор",
      "no_conversations": "Пока нет разговоров",
      "no_messages": "Пока нет сообщений",
      "no_messages_description":
          "Вы еще не получили сообщений о ваших объявлениях",
      "error_not_authenticated": "Войдите в систему, чтобы начать разговор",
      "error_cannot_message_self": "Вы не можете писать сообщения себе",
      "start_conversation_from_listing":
          "Начните разговор с объявления, чтобы начать общение",
      "today": "Сегодня",
      "tomorrow": "Завтра",
      "yesterday": "Вчера",
      "in_days": "Через {days} дней",
      "monday": "Понедельник",
      "tuesday": "Вторник",
      "wednesday": "Среда",
      "thursday": "Четверг",
      "friday": "Пятница",
      "saturday": "Суббота",
      "sunday": "Воскресенье",
      "now": "сейчас",
      "send_first_message": "Отправьте первое сообщение, чтобы начать разговор",
      "opening_existing_conversation": "Открытие существующего разговора",

      // ===== QUICK QUESTIONS =====
      "quick_question_room_available": "Комната свободна?",
      "quick_question_move_in_date": "Когда можно въехать?",
      "any_date": "Любая дата",
      "quick_question_people_living": "Сколько людей уже живет в квартире?",
      "private_room": "Отдельная комната",
      "private_room_only": "Отдельная комната",
      "conversation_count": "разговор",
      "conversations_count": "разговора",
      "incoming": "Входящие",
      "outgoing": "Исходящие",
      "no_incoming_conversations": "Нет входящих разговоров",
      "no_outgoing_conversations": "Нет исходящих разговоров",
      "no_incoming_conversations_description":
          "Вы еще не получили сообщений о ваших объявлениях",
      "no_outgoing_conversations_description":
          "Вы еще не начали разговоры о других объявлениях",
      "retry": "Повторить",
      "back_to_listing": "Вернуться к объявлению",
      "load_more": "Загрузить еще",

      "error_generic": "Произошла ошибка",
      "error_loading_regions": "Ошибка загрузки районов: {error}",
      "error_loading_universities": "Ошибка загрузки университетов: {error}",
      "error_creating_listing":
          "Ошибка создания объявления. Попробуйте еще раз.",
      "error_updating_listing": "Ошибка при обновлении объявления",
      "error_uploading_photos": "Ошибка загрузки фотографий",
      "error_deactivating_listing": "Ошибка деактивации объявления",
      "error_creating_profile": "Ошибка создания профиля. Попробуйте еще раз.",
      "error_updating_profile": "Ошибка обновления профиля: {error}",
      "error_opening_edit_screen":
          "Ошибка открытия экрана редактирования: {error}",
      "error_with_message": "Ошибка: {message}",
      "image_load_error": "Не удалось загрузить изображение",

      // ===== SUCCESS MESSAGES =====
      "listing_created_success": "Объявление успешно создано!",
      "listing_updated_success": "Объявление успешно обновлено",

      "profile_completed_success": "Профиль успешно завершен!",
      "profile_updated_success": "Профиль успешно обновлен",
      "favorite_added_success": "Добавлено в избранное",
      "favorite_removed_success": "Удалено из избранного",

      "successfully_signed_in_google": "Успешный вход через Google!",

      // ===== EMPTY STATES =====
      "no_listings_found": "Объявления не найдены",

      "no_locations_available": "Районы недоступны",

      "no_universities_available": "Университеты недоступны",
      "no_search_results": "Результаты поиска не найдены",
      "try_refreshing": "Попробуйте обновить или проверьте позже",
      "try_refining_search": "Попробуйте уточнить критерии поиска",
      "refine_search": "Уточнить поиск",

      // ===== SELECTION & PROMPTS =====
      "select_metro_line": "Линия метро",
      "select_metro_line_title": "Выберите\nлинию метро",
      "select_location": "Любой район",
      "not_selected": "Не выбрано",
      "search_location_or_metro_hint":
          "Выберите один вариант: район или станцию метро",

      "all_stations_count": "Все {count} станций",
      "all_stations_explanation":
          "Поиск вдоль ВСЕЙ линии <b>{line}</b> по <b>{count}</b> станциям",
      "metro_tutorial_search_hint":
          "Поиск по линии метро или по отдельным станциям.",
      "metro_tutorial_line_hint": "Поиск объявлений на всех станциях линий метро",
      "metro_tutorial_station_hint": "Поиск по конкретным станциям метро",
      "metro_tutorial_tap_to_continue": "Нажмите, чтобы продолжить",
      "select_region": "Выберите область",
      "select_region_profile_creation_title": "Откуда вы?",
      "select_region_profile_creation_description":
          "Мы поможем вам найти людей из вашего родного города.",
      "select_university": "Выберите университет",

      "select_language": "Выбрать язык",
      "select_theme": "Выбрать тему",
      "select_theme_description": "Выберите предпочитаемую тему приложения",
      "please_complete_previous_steps":
          "Пожалуйста, сначала завершите предыдущие шаги",
      "please_complete_all_fields": "Пожалуйста, заполните все поля",
      "please_select_university": "Пожалуйста, выберите университет",
      "tap_to_select_region": "Нажмите, чтобы выбрать район",
      "no_regions_available": "Районов недоступно",

      // ===== ACTION BUTTONS =====
      "refresh": "Обновить",
      "actions": "Действия",

      "view_profile": "Профиль",
      "deactivate_listing": "Деактивировать",
      "deactivate_listing_confirmation": "Вы уверены, что хотите деактивировать это объявление? Оно больше не будет видно другим пользователям.",
      "deactivate": "Деактивировать",
      "activate_listing": "Активировать объявление",
      "activate_listing_confirmation": "Вы уверены, что хотите активировать это объявление? Оно станет видно другим пользователям.",
      "activate": "Активировать",
      "listing_active": "Активно",
      "listing_inactive": "Неактивно",

      "create_listing_button": "Создать объявление",
      "update_listing_button": "Обновить объявление",
      "save_changes": "Сохранить изменения",

      "confirm": "Подтвердить",
      "next": "Далее",
      "back": "Назад",

      "complete": "Завершить",

      // ===== THEME & APPEARANCE =====
      "settings": "Настройки",
      "theme": "Тема",
      "blue_theme": "Синяя",
      "light_theme": "Светлая",
      "theme_changed_to": "Тема изменена на {theme}",
      "theme_color": "Цвет темы",
      "switch_theme": "Переключить тему",

      // ===== ABOUT & FEATURES =====
      "about_description":
          "UyDosh - ваша надежная платформа для поиска идеального жилья в Ташкенте.",
      "about_feature_1": "Поиск объявлений по метро",
      "about_feature_2": "Поиск по районам",
      "about_feature_3": "Прямой контакт с владельцами",
      "about_feature_4": "Проверенные и безопасные объявления",

      // ===== METRO SYSTEM =====
      "location_on_map": "Локация",
      "show_map": "Показать карту",
      "hide_map": "Скрыть карту",
      "open_in_yandex_maps": "Открыть в Яндекс Картах",
      "open_in_yandex_maps_confirmation":
          "Браузер с Яндекс Картами будет открыт.",

      // ===== LISTING DETAILS =====
      "listing_details": "Детали",
      "author": "Автор",
      "show_details": "Показать детали",
      "hide_details": "Скрыть детали",
      "listing_views_by_others": "{count} просмотров",
      "listing_views_stats_title": "Статистика просмотров",
      "listing_views_stats_empty": "Пока нет просмотров",
      "error_loading_view_stats": "Ошибка загрузки статистики просмотров",
      "promote_listing": "Поднять",
      "remove_from_top": "Убрать с верха",
      "feature_listing_success": "Объявление поднято вверх",
      "unfeature_listing_success": "Объявление убрано с верха",
      "feature_listing_error": "Не удалось обновить объявление",
      "error_promotion_once_per_week":
          "Вы можете поднять объявление только раз в неделю",

      "listing_title_hint": "Введите заголовок объявления",

      "listing_description_hint": "Введите описание объявления",
      "listing_price_label": "Цена",
      "listing_translate_tooltip_en": "Перевести на английский",
      "listing_translate_tooltip_ru": "Перевести на русский",
      "listing_translate_tooltip_uz": "Перевести на узбекский",
      "listing_show_original_description": "Оригинал",
      "listing_translating_description": "Перевод…",
      "listing_translation_error": "Не удалось перевести. Попробуйте снова.",
      "listing_translation_unavailable": "Перевод недоступен.",
      "listing_ai_enhance": "Улучшить с AI",
      "listing_ai_enhance_empty": "Сначала введите описание.",
      "listing_ai_enhance_unavailable": "Улучшение с AI недоступно.",
      "listing_ai_enhance_error": "Не удалось улучшить текст. Попробуйте снова.",

      "listing_type_roommate_needed": "Ищу соседа",
      "listing_type_room_needed": "Ищу жилье",
      "title_male_roommate": "#ИщемСоседа",
      "title_female_roommate": "#ИщемСоседку",
      "title_male_room": "#ИщуКомнату",
      "title_female_room": "#ИщуКомнату",
      "listing_photos_label": "Фотографии",

      "delete_photo": "Удалить фото",
      "delete_photo_confirmation": "Вы уверены, что хотите удалить это фото?",
      "photo_deleted_success": "Фото успешно удалено",
      "error_deleting_photo": "Ошибка удаления фото. Попробуйте еще раз.",
      "photo_made_primary": "Фото установлено как основное",
      "new_primary_photo_selected": "Новое основное фото автоматически выбрано",
      "last_photo_deleted": "Последнее фото удалено - больше нет фотографий",
      "cannot_delete_last_photo": "Невозможно удалить последнее фото",
      "tap_photo_to_make_primary":
          "Нажмите на фото, чтобы сделать его основным",
      "making_primary": "Создание основного...",
      "add_photo": "Добавить фото",
      "take_photo": "Сделать фото",
      "choose_from_gallery": "Выбрать из галереи",
      "photo_limit_reached": "Максимум 5 фотографий",

      "max_photos_reached": "Достигнут максимум фотографий",
      "max_photos_message": "Вы можете загрузить максимум 5 фото.",

      "ok": "ОК",
      "delete": "Удалить",

      // ===== ONBOARDING =====
      "onboarding_title_1": "Найди своих идеальных соседей",
      "onboarding_subtitle_1":
          "Быстрый поиск соседей для совместного проживания по всему Ташкенту",
      "onboarding_title_2": "Поиск по метро",
      "onboarding_subtitle_2":
          "Ищите либо по станциям - либо по всей линии метро",
      "onboarding_title_3": "Поиск по району",
      "onboarding_subtitle_3": "Удобный поиск по районам Ташкента",
      "onboarding_title_4": "Надёжная платформа",
      "onboarding_subtitle_4":
          "Проверенные пользователи ищут квартиры и соседей",

      "onboarding_get_started": "Начать",
      "onboarding_skip": "Пропустить",
      "onboarding_next": "Далее",
      "onboarding_back": "Назад",
      "onboarding_toggle": "Обучение",
      "onboarding_toggle_description": "Показать приветствие",
      "haptic_feedback": "Виброотклик",
      "haptic_feedback_description": "Вибрация при нажатиях и жестах",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "Русский",
      "language": "Язык",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_changed_to": "Язык изменен на {language}",

      // ===== PROFILE & USER INFO =====
      "gender": "Пол",
      "male": "Парень",
      "female": "Девушка",
      "other": "Другой",

      "university": "Университет",
      "same_university": "Один университет",
      "both_students": "Оба студента",
      "region": "Область",
      "same_region": "Один регион",
      "rating": "Рейтинг",
      "about_me": "Обо мне",
      "telegram": "Telegram",
      "open_in_telegram": "Открыть в Telegram",
      "open_in_telegram_confirmation": "Telegram откроется в приложении или браузере.",

      // New profile fields
      "employed": "Работаю",
      "cleanliness": "Чистоплотность",
      "noise_level": "Уровень шума",
      "sociability": "Общительность",
      "guests_allowed": "Гости разрешены",
      "smoking_preference": "Курение",
      "alcohol_preference": "Алкоголь",
      "cooking_habits": "Привычки готовки",
      "pets_preference": "Отношение к животным",
      "wakeup_time": "Время подъема",
      "sleep_time": "Время сна",

      // Preference options
      "non_smoker": "Не курю",
      "occasional_smoker": "Курю иногда",
      "regular_smoker": "Курю регулярно",
      "non_drinker": "Не пью",
      "occasional_drinker": "Пью иногда",
      "regular_drinker": "Пью регулярно",
      "morning": "Утро",
      "evening": "Вечер",
      "night": "Ночь",
      "pets_okay": "Нормальное",
      "pets_not_okay": "Не очень",

      // Slider labels
      "lifestyle_preferences": "Предпочтения образа жизни",
      "very_messy": "Грязный",
      "messy": "Неопрятный",
      "average": "Средне",
      "clean": "Чистоплотный",
      "very_clean": "Очень чистоплотный",
      "very_quiet": "Очень тихий",
      "quiet": "Тихий",
      "loud": "Громкий",
      "very_loud": "Очень шумный",
      "very_introverted": "Необщительный",
      "introverted": "Интроверт",
      "balanced": "Средне",
      "extroverted": "Экстраверт",
      "very_extroverted": "Очень общительный",
      "yes": "Да",
      "no": "Нет",
      "cook": "Готовлю",
      "dont_cook": "Не готовлю",

      "not_specified": "Не указано",

      // ===== AUTHENTICATION =====
      "complete_profile": "Завершите профиль",
      "complete_profile_subheader":
          "Мы используем эту информацию, чтобы подобрать идеальных соседей и совпадения для вас.",

      "full_name": "Имя или никнейм",

      "are_you_student": "Вы студент?",
      "yes_student": "Студент",
      "no_student": "Не студент",

      "are_you_landlord_or_renter": "Вы арендодатель или арендатор?",

      "selected": "Выбрано",

      "full_name_hint": "Введите ваше имя или никнейм",
      "name_required": "Имя или никнейм обязательно",
      "saving": "Сохранение...",
      "firebase_user_not_found": "Пользователь Firebase не найден",
      "user_blocked_violation_title": "Аккаунт ограничен",
      "user_blocked_violation_message":
          "Ваш аккаунт ограничен из-за нарушения. Вы можете просматривать приложение, но не можете публиковать объявления, отправлять сообщения или редактировать контент. Свяжитесь с поддержкой, если у вас есть вопросы.",
      "profile_not_loaded_yet": "Профиль еще не загружен",
      "profile_still_loading": "Профиль все еще загружается",
      "welcome_back_profile_exists":
          "Добро пожаловать обратно! Профиль уже существует.",
      "tap_to_select_university": "Нажмите, чтобы выбрать университет",

      // ===== MENU & NAVIGATION =====
      "menu_profile": "Профиль",
      "menu_home": "Объявления",
      "menu_language": "Язык",

      "menu_favorites": "Избранное",
      "menu_history": "История",
      "menu_contact_support": "Связаться с поддержкой",
      "menu_add_listing": "Добавить объявление",
      "menu_my_listings": "Мои объявления",

      "menu_about": "О приложении",
      "menu_privacy_policy": "Политика конфиденциальности",
      "menu_user_license_agreement": "Лицензионное соглашение пользователя",
      "menu_faq": "Вопросы и ответы",
      "menu_settings": "Настройки",
      "menu_registration": "Вход",
      "menu_logout": "Выйти",
      "menu_admin_panel": "Админ-панель",
      "manage_property": "Управление жильём",

      "admin_panel_title": "Админ-панель",
      "admin_panel_section_content_moderation": "Модерация фото",
      "admin_content_moderation_title": "Модерация фото",
      "admin_content_moderation_description":
          "Если включено, загружаемые фото проверяются на нежелательный контент; при срабатывании изображение размывается перед сохранением. Если выключено, проверка и размытие не выполняются (вызовы AWS Rekognition отключены).",
      "admin_content_moderation_blur_enabled": "Проверять и размывать нежелательные фото",
      "admin_content_moderation_loading": "Загрузка настроек модерации...",
      "admin_content_moderation_error": "Не удалось загрузить настройки модерации",
      "admin_content_moderation_save_error": "Не удалось сохранить настройку",

      "admin_panel_section_users": "Пользователи",
      "admin_panel_section_support_chat": "Поддержка",
      "admin_panel_section_complaints": "Жалобы",
      "admin_panel_section_listing_complaints": "Объявления с жалобами",
      "admin_panel_section_district_heatmap": "Тепловая карта районов",
      "admin_panel_section_subway_heatmap": "Тепловая карта линий метро",
      "admin_panel_section_subway_map": "Схема метро",
      "admin_panel_section_search_analytics": "Аналитика поиска",
      "admin_panel_section_listing_creation_analytics":
          "Аналитика создания объявлений",

      "admin_search_analytics_title": "Аналитика поиска",
      "admin_search_analytics_loading": "Загрузка аналитики поиска...",
      "admin_search_analytics_error": "Не удалось загрузить аналитику",
      "admin_search_analytics_retry": "Повторить",
      "admin_search_analytics_time_range": "Период",
      "admin_search_analytics_days": "За {days} дн.",
      "admin_search_analytics_all_time": "Всё время",
      "admin_search_analytics_total": "Всего поисков",
      "admin_search_analytics_today": "Сегодня",
      "admin_search_analytics_week": "За неделю",
      "admin_search_analytics_top_stations": "Популярные станции метро",
      "admin_search_analytics_top_districts": "Популярные районы",
      "admin_search_analytics_top_lines": "Популярные линии метро",
      "admin_search_analytics_searches": "поисков",
      "admin_search_analytics_no_stations": "Нет данных по станциям",
      "admin_search_analytics_no_districts": "Нет данных по районам",
      "admin_search_analytics_no_lines": "Нет данных по линиям",

      "admin_listing_creation_analytics_title":
          "Аналитика создания объявлений",
      "admin_listing_creation_analytics_loading":
          "Загрузка аналитики создания объявлений...",
      "admin_listing_creation_analytics_error":
          "Не удалось загрузить аналитику",
      "admin_listing_creation_analytics_retry": "Повторить",
      "admin_listing_creation_analytics_time_range": "Период",
      "admin_listing_creation_analytics_total": "Всего за период",
      "admin_listing_creation_analytics_today": "Сегодня",
      "admin_listing_creation_analytics_week": "За неделю",
      "admin_listing_creation_analytics_by_day": "Объявления по дням",
      "admin_listing_creation_analytics_no_data":
          "Нет данных за выбранный период",

      "admin_district_heatmap_title": "Тепловая карта районов",
      "admin_district_heatmap_description":
          "Объявления по районам с цветовой интенсивностью.",
      "admin_district_heatmap_loading": "Загрузка статистики по районам...",
      "admin_district_heatmap_error":
          "Не удалось загрузить статистику по районам",
      "admin_district_heatmap_retry": "Повторить",
      "admin_district_heatmap_total": "Всего объявлений",
      "admin_district_heatmap_max": "Максимум в районе",
      "admin_district_heatmap_count_label": "Объявления",
      "admin_district_heatmap_unavailable": "Недоступно",
      "admin_district_heatmap_no_data": "Нет данных по районам",

      "admin_subway_heatmap_title": "Тепловая карта линий метро",
      "admin_subway_heatmap_description":
          "Объявления по линиям метро с цветовой интенсивностью.",
      "admin_subway_heatmap_loading":
          "Загрузка статистики по линиям метро...",
      "admin_subway_heatmap_error":
          "Не удалось загрузить статистику по линиям метро",
      "admin_subway_heatmap_retry": "Повторить",
      "admin_subway_heatmap_total": "Всего объявлений",
      "admin_subway_heatmap_max": "Максимум на линии",
      "admin_subway_heatmap_count_label": "Объявления",
      "admin_subway_heatmap_unavailable": "Недоступно",
      "admin_subway_heatmap_no_data": "Нет данных по линиям метро",

      "admin_subway_map_title": "Схема метро",
      "admin_subway_map_description":
          "Упрощенная схема с линиями и станциями.",
      "error_loading_map": "Не удалось загрузить карту",

      "admin_users_title": "Пользователи",
      "admin_users_loading": "Загрузка пользователей...",
      "admin_users_empty": "Пользователи не найдены",
      "admin_users_error": "Не удалось загрузить пользователей",
      "admin_users_id": "ID",
      "admin_users_role": "Роль",
      "admin_users_created_at": "Создан",
      "admin_users_listings_count": "Объявления",
      "admin_users_listings_count_loading": "Загрузка...",
      "admin_users_listings_count_error": "Недоступно",
      "admin_user_detail_title": "Пользователь",
      "admin_user_detail_role_title": "Управление ролью",
      "admin_user_detail_role_label": "Роль",
      "admin_user_detail_role_save": "Сохранить роль",
      "admin_user_detail_role_updated": "Роль обновлена",
      "admin_user_detail_view_listings": "Объявления пользователя",
      "admin_user_detail_view_complaints": "Жалобы пользователя",
      "admin_user_detail_block_title": "Блокировка",
      "admin_user_detail_block": "Заблокировать",
      "admin_user_detail_unblock": "Разблокировать",
      "admin_user_detail_blocked": "Заблокирован",
      "admin_user_detail_block_reason": "Причина",
      "admin_user_detail_block_until": "До",
      "admin_user_detail_block_permanent": "Постоянно",
      "admin_user_detail_block_confirm": "Заблокировать",
      "admin_user_detail_blocked_success": "Пользователь заблокирован",
      "admin_user_detail_unblocked_success": "Пользователь разблокирован",
      "admin_user_complaints_title": "Жалобы пользователя",
      "admin_user_complaints_user": "Пользователь",
      "admin_user_complaints_empty": "Жалобы не найдены",
      "admin_user_complaints_group_count": "Жалобы",

      "admin_user_listings_title": "Объявления пользователя",
      "admin_user_listings_user": "Пользователь",
      "admin_user_listings_empty": "Объявления не найдены",
      "admin_user_listings_error": "Не удалось загрузить объявления",

      "admin_complaints_title": "Жалобы",
      "admin_complaints_loading": "Загрузка жалоб...",
      "admin_complaints_empty": "Жалобы не найдены",
      "admin_complaints_error": "Не удалось загрузить жалобы",
      "admin_complaints_filter_all": "Все",
      "admin_complaints_filter_pending": "В ожидании",
      "admin_complaints_filter_resolved": "Решено",
      "admin_complaints_filter_dismissed": "Отклонено",
      "admin_complaints_status_label": "Статус",
      "admin_complaints_status_pending": "В ожидании",
      "admin_complaints_status_resolved": "Решено",
      "admin_complaints_status_dismissed": "Отклонено",
      "admin_complaints_listing_id": "Объявление",
      "admin_complaints_complainant_id": "Пользователь",
      "admin_complaints_category_unknown": "Неизвестная категория",
      "admin_complaints_created_at": "Создан",
      "admin_complaints_text": "Описание",
      "admin_complaints_update_status": "Обновить статус",
      "admin_complaints_status_updated": "Статус обновлен",
      "admin_support_chat_title": "Поддержка",
      "admin_support_chat_loading": "Загрузка обращений...",
      "admin_support_chat_empty": "Обращений пока нет",
      "admin_support_chat_error": "Не удалось загрузить поддержку",
      "admin_support_chat_retry": "Повторить",
      "admin_support_chat_filter_all": "Все",
      "admin_support_chat_filter_open": "Открытые",
      "admin_support_chat_filter_closed": "Закрытые",
      "admin_support_chat_status_open": "Открыт",
      "admin_support_chat_status_closed": "Закрыт",
      "admin_support_chat_messages": "сообщений",
      "admin_support_chat_yesterday": "Вчера",
      "admin_support_chat_days_ago": "дн. назад",
      "admin_support_chat_no_messages": "Сообщений пока нет",
      "admin_support_chat_reply_hint": "Введите ответ...",
      "admin_support_chat_close_thread": "Закрыть обращение",
      "admin_support_chat_reopen_thread": "Открыть снова",
      "admin_support_chat_closed": "Обращение закрыто",
      "admin_support_chat_reopened": "Обращение открыто",
      "admin_support_chat_thread_closed": "Обращение закрыто. Откройте, чтобы ответить.",
      "contact_support_title": "Поддержка",
      "contact_support_loading": "Загрузка...",
      "contact_support_error": "Не удалось загрузить поддержку",
      "contact_support_empty": "Обращений пока нет. Создайте новое, чтобы получить помощь.",
      "contact_support_new": "Новое обращение",
      "contact_support_message_hint": "Введите сообщение...",
      "admin_listing_complaints_title": "Объявления с жалобами",
      "admin_listing_complaints_empty": "Объявлений с жалобами нет",
      "admin_listing_complaints_error":
          "Не удалось загрузить объявления с жалобами",
      "admin_listing_complaints_last_reported": "Последняя жалоба",
      "admin_listing_complaints_categories": "Жалобы",
      "admin_listing_complaints_categories_empty": "Нет категорий жалоб",

      // ===== FAQ CONTENT =====
      "faq_question": "Как договариваться с соседями и избегать конфликтов?",
      "faq_answer": "Жить вместе — это всегда про уважение и умение договариваться. Вот несколько простых правил, которые помогут сохранить мир и дружбу:\n\nШум\nДоговоритесь о «тихих часах». Для музыки — наушники, для звонков — коридор или улица. Удобно повесить расписание, чтобы все знали, когда у кого учеба или отдых.\n\nГости\nПредупреждайте друг друга заранее. Хорошее правило — определённые дни для гостей и дни для тишины.\n\nЭмоции\nНе копите раздражение. Говорите спокойно и сразу, если что-то мешает. А лишний стресс лучше выплеснуть в спортзале или на пробежке.\n\nОбщие дела\nИногда полезно что-то делать вместе: сходить в кино, прогуляться, устроить «уборку под музыку». Общие воспоминания укрепляют дружбу.\n\nУборка и быт\nРазделите обязанности — кто-то моет пол, кто-то выносит мусор. Главное — договариваться и уважать личные границы. Чужие вещи без спроса не трогаем.\n\nОбщение\nИспользуйте «я-сообщения»: вместо «ты меня бесишь» лучше сказать «мне тяжело сосредоточиться, когда играет громкая музыка».\n\nРешение конфликтов\nСтарайтесь обсуждать всё спокойно, выслушивая друг друга. Конфликт — это повод найти общее решение, а не врага.\n\nЕда\nМожно договориться о совместных покупках или завести «общую полочку» для вкусняшек.\n\nПорядок и тишина\nГрафик уборки — лучший друг. А если нужно сосредоточиться — можно уйти в библиотеку или коворкинг, либо снова включить правило «тихого часа».",

      "faq_question_2": "Неожиданный счёт за чужую коммуналку",
      "faq_answer_2": "Иногда вместе с квартирой жильцу «в подарок» достаются и долги за коммунальные услуги. В итоге — отключённый свет или вода, а арендодатель не спешит платить. Жильцу остаётся выбирать: съезжать с убытками или гасить долг за свой счёт.\n\nЧтобы избежать таких ситуаций:\n\nПроверка перед подписанием\nПеред подписанием договора попросите у хозяина квитанции или отчёт об оплаченных коммунальных платежах.\n\nПисьменное соглашение\nЕсли долг всё-таки есть и вы готовы его оплатить, обязательно оформите письменное соглашение: сумма долга будет зачтена в счёт будущей аренды.\n\nТак вы сохраните и деньги, и спокойствие.",

      "faq_question_3": "Обещания арендодателя: ремонт, техника, мебель",
      "faq_answer_3": "Нередко при аренде жилья собственник обещает устранить неисправности в квартире, купить бытовую технику и мебель. Все это он обязуется исполнить сразу после заселения. Однако проходит время, а неисправности так и остаются. Чтобы не стать заложником подобной ситуации, арендатору следует прописать в договоре найма особые условия.\n\nТакже нередко нарушается устная договоренность о выполнении ремонта силами квартиранта и обязательство не взимать арендную плату во время проведения работ. Например, вы делаете ремонт квартиры за свой счет и не платите за аренду несколько месяцев. Однако некоторые арендодатели «забывают» о договоренностях и требуют оплаты проживания. Зачастую у сторон возникают разногласия по поводу стоимости отделки, а иногда дело и вовсе доходит до суда.\n\nПоэтому следует обсудить все моменты ремонта, учесть их в договоре найма, а также составить смету и подписать её.",

      "faq_question_4": "О Важности Договора",
      "faq_answer_4": "Часто при сдаче жилья родственникам или друзьям договор не заключаются. При этом, многие скандалы и разбирательства происходят как раз между родственниками и друзьями, которые приняли обещания и обязательства по аренде на словах. Поэтому лучше заключить договор, даже если вы снимаете квартиру у своего дяди или близкого друга.\n\nЕсть случаи, когда квартиры сдаются по доверенности, где указано: доверитель дает доверенному лицу право сдать его квартиру внаем. «Но в доверенности не прописано, что доверенное лицо имеет также право получать арендную плату. Может произойти ситуация: квартирант исправно вносит арендную сумму доверенному лицу, но однажды появляется собственник жилплощади и требует арендатора оплатить прошедший период проживания в квартире». В данном случае следует тщательно изучать документы, и если в доверенности не указано право на получение арендной платы, обсудить этот пункт.",

      "faq_question_5": "Гайд по безопасности для арендаторов и соседей",
      "faq_answer_5": "Иногда происходят неприятные ситуации не только на нашей платформе. К сожалению, неадекватные или озабоченные люди встречаются везде. Поэтому важно помнить о простых правилах безопасности.\n\n🙏 Главное — ваша безопасность!\n\nПеред встречей\n• Договаривайтесь о встречах только в дневное время.\n• Старайтесь выбирать людные места — кафе, торговый центр, двор с камерами.\n• Сообщите друзьям или родным, куда идёте и с кем встречаетесь.\n\nВо время встречи\n• По возможности приходите не одни.\n• Не передавайте деньги и документы «из рук в руки» до подписания договора.\n• Сохраняйте переписку и фото/сканы документов — это ваша защита.\n\nЕсли чувствуете угрозу\n• Немедленно прекращайте встречу и уходите.\n• Не бойтесь сказать «нет» и оборвать общение.\n• При явной опасности — звоните 102 или обращайтесь в ближайшее отделение РОВД.\n\nНа платформе UyDosh\n• Пользуйтесь системой верификации — проверенные профили снижают риск.\n• Сообщайте модераторам о подозрительных объявлениях и поведении.\n• Помните: лучше перестраховаться, чем потом сожалеть.\n\n❤️ Берегите себя и друг друга!",

      // ===== LOGOUT & SESSION =====
      "logout_confirmation": "Подтверждение выхода",
      "logout_description":
          "Вы уверены, что хотите выйти? Вам нужно будет снова войти, чтобы получить доступ к профилю.",
      "logout": "Выйти",
      "logout_success": "Вы успешно вышли из системы",

      // ===== DELETE ACCOUNT =====
      "delete_account": "Удалить аккаунт",
      "delete_account_confirmation":
          "Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить. Все ваши данные, объявления и сообщения будут безвозвратно удалены.",
      "delete_account_success": "Аккаунт успешно удалён",
      "delete_account_error": "Ошибка удаления аккаунта",
      "delete_account_blocked":
          "Ваш аккаунт ограничен. Вы не можете удалить аккаунт, пока он заблокирован. Обратитесь в службу поддержки.",

      // ===== FAVORITES =====
      "favorites_title": "Избранное",
      "favorites_empty_title": "Пока нет избранного",
      "favorites_browse_button": "Просмотреть объявления",

      "view_history_title": "История просмотров",
      "view_history_empty_title": "Пока нет просмотренных объявлений",
      "view_history_browse_button": "Просмотреть объявления",
      "view_history_auth_prompt": "Войдите, чтобы просмотреть историю.",
      "unable_to_load_view_history":
          "Не удалось загрузить историю. Попробуйте позже.",

      // ===== ACHIEVEMENTS =====
      "menu_achievements": "Достижения",
      "achievements_title": "Достижения",
      "achievement_unlocked": "Достижение разблокировано!",
      "achievement_first_steps": "Первые шаги",
      "achievement_first_steps_desc": "Создайте аккаунт",
      "achievement_profile_complete": "Профиль заполнен",
      "achievement_profile_complete_desc": "Заполните профиль на 100%",
      "achievement_first_look": "Первый взгляд",
      "achievement_first_look_desc": "Просмотрите первое объявление",
      "achievement_bookmarker": "В закладках",
      "achievement_bookmarker_desc": "Добавьте первое избранное",
      "achievement_ice_breaker": "Разговор начат",
      "achievement_ice_breaker_desc": "Отправьте первое сообщение",
      "achievement_first_listing": "Первое объявление",
      "achievement_first_listing_desc": "Создайте первое объявление",
      "achievement_returning_user": "Постоянный пользователь",
      "achievement_returning_user_desc": "Используйте приложение 7 дней подряд",
      "achievement_sharer": "Поделился",
      "achievement_sharer_desc": "Поделитесь первым объявлением",
      "achievements_empty": "Пока нет достижений",
      "achievements_empty_desc": "Выполняйте действия, чтобы разблокировать достижения",
      "achievements_auth_prompt": "Войдите, чтобы просмотреть достижения",

      "favorite_toggle_error": "Не удалось обновить статус избранного",
      "favorite_toggle_network_error":
          "Ошибка сети при обновлении статуса избранного",

      "unable_to_load_favorites":
          "Не удалось загрузить избранное. Попробуйте позже.",

      // ===== CREATE & EDIT LISTING =====
      "create_listing_title": "Создать объявление",
      "edit_listing": "Редактировать объявление",
      "edit_profile": "Редактировать профиль",
      "updating_listing": "Обновляется...",
      "creating_listing": "Создается...",
      "title_required": "Заголовок обязателен",
      "title_too_long": "Заголовок должен быть не более 25 символов",
      "description_required": "Описание обязательно",
      "description_too_long": "Описание должно быть не более 500 символов",
      "location_required": "Пожалуйста, выберите район",

      "auth_required_title": "Требуется аутентификация",
      "authentication_required":
          "Требуется аутентификация. Пожалуйста, войдите в систему для создания объявлений.",

      "unauthenticated_listing_prompt":
          "Для создания и размещения объявлений необходимо войти в свой аккаунт.",
      "authenticate_to_post_listing": "Войти для размещения объявления",
      "select_location_required": "Выберите район",
      "select_metro_line_optional": "Линия метро",

      // ===== AMENITIES & FEATURES =====
      "amenities": "Удобства",
      "photos": "Фотографии",
      "primary": "Основное",
      "wifi": "Wi-Fi",
      "bed": "Кровать",
      "air_conditioning": "Кондиционер",
      "tv": "Телевизор",
      "microwave": "Микроволновка",
      "washing_machine": "Стиральная машина",
      "pets": "Домашние животные разрешены",

      // ===== PRICING & FINANCIAL =====
      "month": "месяц",

      // ===== SEARCH & FILTERS =====
      "search_listings": "Поиск объявлений",

      "search": "Поиск",
      "tutorial_search_title": "Поиск объявлений",
      "tutorial_search_description":
          "Нажмите здесь, чтобы фильтровать объявления по району, цене, типу комнаты и другим параметрам.",
      "tutorial_profile_description":
          "Здесь находятся ваш профиль и настройки аккаунта.",
      "tutorial_got_it": "Понятно",
      "tutorial_metro_description":
          "Выберите линию метро, затем станцию для фильтрации по местоположению.",

      // ===== TIME & DATES =====
      "january": "Январь",
      "february": "Февраль",
      "march": "Март",
      "april": "Апрель",
      "may": "Май",
      "june": "Июнь",
      "july": "Июль",
      "august": "Август",
      "september": "Сентябрь",
      "october": "Октябрь",
      "november": "Ноябрь",
      "december": "Декабрь",
      "select_date": "Дата вселения",
      "move_in_date_label": "Дата вселения:",
      "publication_date": "Опубликовано:",

      // ===== GOOGLE AUTHENTICATION =====
      "sign_in_with_google": "Войти через Google",
      "sign_in_with_google_description":
          "Войдите в свой аккаунт Google для продолжения",

      "signing_in": "Вход в систему...",
      "google_sign_in_failed": "Ошибка входа через Google: {error}",
      "popup_closed": "Окно входа было закрыто",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Посмотрите это объявление на UyDosh!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Связаться с пользователем",
      "message": "Написать",

      // ===== STATUS & STATE =====
      "delete_listing": "Удалить объявление",
      "delete_listing_confirmation":
          "Вы уверены, что хотите удалить это объявление? Это действие нельзя отменить.",
      "delete_listing_success": "Объявление успешно удалено",
      "delete_listing_error": "Ошибка удаления объявления",
      "unknown": "Неизвестно",

      // ===== COMPLAINTS =====
      "create_complaint": "Создать жалобу",
      "select_complaint_category": "Выберите категорию жалобы",
      "complaint_description_hint": "Добавьте подробности (необязательно)",
      "submit_complaint": "Отправить жалобу",
      "complaint_created_success": "Жалоба успешно отправлена",
      "listing_complaints": "Жалобы по объявлению",
      "listing_complaints_header": "Жалобы по объявлению: {count}",
      "view_listing_complaints": "Показать жалобы",
      "complaints_count_short": "{count} жалоб",
      "no_listing_complaints": "Жалоб по этому объявлению пока нет",
    },
    "uz": {
      // ===== NAVIGATION =====
      "home": "E'lonlar",
      "favorites": "Sevimlilar",
      "add_to_favorites": "Sevimlilariga qo'shish",
      "added_to_favorites": "Sevimlilariga qo'shildi",
      "removed_from_favorites": "Sevimlilardan o'chirildi",
      "remove_from_favorites": "Sevimlilardan o'chirish",
      "edit": "Tahrirlash",
      "share": "Ulashish",
      "complain": "Shikoyat qilish",
      "sign_in": "Kirish",

      "location": "Tuman",
      "create_listing": "Yaratish",
      "profile": "Profil",
      "role_tenant": "Ijarachi",
      "role_landlord": "Ijaraga beruvchi",
      "role_manager": "Menejer",
      "role_admin": "Administrator",
      "profile_completion": "Profil to'ldirilishi",
      "profile_completion_hint":
          "Profil to'liq bo'lsa, mosliklar aniqroq va qo'shnichilik qulayroq bo'ladi.",
      "complete_profile_prompt_title": "Profilni to'ldiring",
      "complete_profile_prompt_body":
          "Turmush tarzi bo'yicha xohishlarni qo'shing, mosliklar yaxshilanadi.",
      "complete_profile_prompt_cta": "Hozir to'ldirish",
      "complete_profile_prompt_later": "Keyinroq",
      "compatibility_title": "Siz bilan moslik:",
      "compatibility_match_percentage": "Moslik: {percent}%",
      "compatibility_match_placeholder": "Moslik: —",
      "compatibility_calculating": "Moslik hisoblanmoqda...",
      "compatibility_sign_in": "Moslikni ko'rish uchun tizimga kiring",
      "na": "N/A",
      "compatibility_matches": "Mos keladigan xususiyatlar:",
      "compatibility_differences": "Ehtimoliy farqlar:",
      "vs": "vs",
      "name": "Ism yoki taxallus",
      "im_from": "Men:",

      // ===== APP CORE =====
      "welcome": "Salom",
      "user": "Foydalanuvchi",
      "welcome_title": "UyDosh ga xush kelibsiz",
      "welcome_subtitle": "Mukammal xonadon yoki turar joy toping",
      "splash_subtitle": "KELING BIRGA YASHAYMIZ!",
      "search_results": "Qidiruv natijalari",
      "close": "Yopish",
      "cancel": "Bekor qilish",
      "about_uy_dosh": "UyDosh haqida",
      "privacy_policy_title": "Maxfiylik siyosati",
      "privacy_policy_body":
          "ОБНОВЛЁННЫЙ PRIVACY POLICY (без рекламы и подписок)\n\nLast updated: [DATE]\n\nUyDosh respects your privacy. This Privacy Policy explains how we collect and use data.\n\n⸻\n\n1. Data We Collect\n\na. Information You Provide\n\t•\tPhone number\n\t•\tName and profile info\n\t•\tListings and photos\n\t•\tMessages\n\nb. Automatically Collected Data\n\t•\tDevice type and OS\n\t•\tApp usage data\n\t•\tCrash diagnostics\n\nc. Location Data\n\t•\tApproximate location (only if enabled)\n\n⸻\n\n2. How We Use Data\n\nWe use data to:\n\t•\toperate the App\n\t•\tdisplay listings and maps\n\t•\tmaintain safety and moderation\n\t•\timprove functionality\n\n⸻\n\n3. Data Sharing\n\nWe do not sell personal data.\n\nWe may share data:\n\t•\twith service providers (hosting, analytics)\n\t•\tif required by law\n\t•\twith other users (only public profile/listing info)\n\n⸻\n\n4. Data Retention\n\nWe store data only as long as necessary.\nYou may request account and data deletion.\n\n⸻\n\n5. Security\n\nWe apply reasonable measures to protect data, but no system is fully secure.\n\n⸻\n\n6. User Rights\n\nYou may request:\n\t•\taccess to your data\n\t•\tcorrection\n\t•\tdeletion\n\nContact: support@uydosh.app\n\n⸻\n\n7. Children\n\nUyDosh is not intended for users under 18.\n\n⸻\n\n8. Third-Party Services\n\nThe App may use third-party services (e.g., maps). Their policies apply independently.\n\n⸻\n\n9. Updates\n\nWe may update this Policy. Changes take effect when published.\n\n⸻\n\n10. Contact\n\nsupport@uydosh.app",
      "user_license_agreement_title": "Foydalanuvchi litsenziya shartnomasi",
      "user_license_agreement_body":
          "ОБНОВЛЁННЫЙ EULA (MVP-версия)\n\nLast updated: [DATE]\n\nThis End User License Agreement (\"Agreement\") is a legal agreement between you (\"User\") and UyDosh (\"we\", \"us\", \"our\") governing your use of the UyDosh mobile application (\"App\").\n\nBy accessing or using the App, you agree to this Agreement.\n\n⸻\n\n1. License\n\nWe grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes.\n\n⸻\n\n2. Eligibility\n\nYou must be at least 18 years old to use the App.\n\n⸻\n\n3. Accounts\n\nSome features require account creation.\nYou agree to provide accurate information and keep it up to date.\n\nWe may suspend or terminate accounts that violate this Agreement or pose safety risks.\n\n⸻\n\n4. User Content\n\nThe App allows users to post listings, descriptions, photos, and messages (\"User Content\").\n\nYou retain ownership of your content.\nBy posting content, you grant us a non-exclusive, worldwide license to host, display, and distribute it solely for operating the App.\n\nYou are fully responsible for your User Content.\n\n⸻\n\n5. Prohibited Use\n\nYou agree not to:\n\t•\tPost false, misleading, or illegal listings\n\t•\tHarass, threaten, or discriminate against others\n\t•\tImpersonate another person\n\t•\tUse the App for unlawful purposes\n\t•\tAttempt to access data or accounts without authorization\n\n⸻\n\n6. No Transactions or Guarantees\n\nUyDosh does not participate in rental agreements, payments, or negotiations between users.\n\nWe do not guarantee:\n\t•\taccuracy of listings\n\t•\tavailability of housing\n\t•\tbehavior or reliability of other users\n\nAll interactions occur at your own risk.\n\n⸻\n\n7. Moderation\n\nWe reserve the right to:\n\t•\tremove content\n\t•\trestrict visibility\n\t•\tsuspend or ban users\n\nbased on complaints, violations, or safety concerns.\n\n⸻\n\n8. Location Features\n\nThe App may use approximate location data to display nearby listings and map features.\nYou can disable location access in your device settings.\n\n⸻\n\n9. Disclaimer\n\nThe App is provided \"AS IS\" and \"AS AVAILABLE\".\nWe make no warranties regarding reliability, safety, or suitability.\n\n⸻\n\n10. Limitation of Liability\n\nUyDosh shall not be liable for indirect or consequential damages arising from App usage.\n\n⸻\n\n11. Termination\n\nWe may terminate your access at any time for violation of this Agreement.\n\n⸻\n\n12. Governing Law\n\nThis Agreement is governed by the laws of the jurisdiction where UyDosh operates.\n\n⸻\n\n13. Contact\n\nsupport@uydosh.app\n\n⸻",

      // ===== LOADING STATES =====
      "loading": "Yuklanmoqda",
      "loading...": "Yuklanmoqda...",
      "loading_listings": "E'lonlar yuklanmoqda...",
      "loading_listing_details": "E'lon tafsilotlari yuklanmoqda...",

      "loading_universities": "Universitetlar yuklanmoqda...",
      "loading_regions": "Tumanlar yuklanmoqda...",

      // ===== ERROR MESSAGES =====
      "error": "Xatolik",
      "error_loading_listing_details": "E'lon tafsilotlarini yuklashda xatolik",
      "error_listing_not_loaded": "E'lon hali yuklanmagan",
      "error_listing_still_loading": "E'lon hali yuklanmoqda",

      "error_loading_profile": "Profildi yuklash imkoni yo'q",

      "error_internet_connection": "Internet aloqangizni tekshiring",
      "error_resource_conflict":
          "Siz bu e'lon haqida allaqachon shikoyat qilgansiz.",

      // ===== MESSAGING =====
      "conversations": "Xabarlar",
      "messages": "Xabarlar",
      "chat": "Chat",
      "chat_with": "{name} bilan chat",
      "profile_interlocutor": "Suhbatdosh profili",
      "view_listing": "E'lonni ko'rish",
      "menu_messages": "Xabarlar",
      "type_message": "Xabar yozing...",
      "conversation_created": "Suhbat boshlandi",
      "conversation_failed": "Suhbat boshlanmadi",
      "no_conversations": "Hali suhbatlar yo'q",
      "no_messages": "Hali xabarlar yo'q",
      "no_messages_description":
          "Siz hali e'lonlaringiz haqida xabar olmadingiz",
      "error_not_authenticated": "Suhbatni boshlash uchun tizimga kiring",
      "error_cannot_message_self": "O'zingizga xabar yubora olmaysiz",
      "start_conversation_from_listing":
          "Xabar almashishni boshlash uchun e'londan suhbatni boshlang",
      "today": "Bugun",
      "tomorrow": "Ertaga",
      "yesterday": "Kecha",
      "in_days": "{days} kundan keyin",
      "monday": "Dushanba",
      "tuesday": "Seshanba",
      "wednesday": "Chorshanba",
      "thursday": "Payshanba",
      "friday": "Juma",
      "saturday": "Shanba",
      "sunday": "Yakshanba",
      "now": "hozir",
      "send_first_message":
          "Suhbatni boshlash uchun birinchi xabaringizni yuboring",
      "opening_existing_conversation": "Mavjud suhbatni ochish",

      // ===== QUICK QUESTIONS =====
      "quick_question_room_available": "Xona bo'shmi?",
      "quick_question_move_in_date": "Ko'chib kelish sanasi qachon?",
      "any_date": "Har qanday sanasi",
      "quick_question_people_living": "Kvartiraga necha kishi yashaydi?",
      "private_room": "Shaxsiy xona",
      "private_room_only": "Shaxsiy xona",
      "conversation_count": "suhbat",
      "conversations_count": "suhbat",
      "incoming": "Kiruvchi",
      "outgoing": "Chiquvchi",
      "no_incoming_conversations": "Kiruvchi suhbatlar yo'q",
      "no_outgoing_conversations": "Chiquvchi suhbatlar yo'q",
      "no_incoming_conversations_description":
          "Sizning e'lonlaringiz haqida hali xabar olmadingiz",
      "no_outgoing_conversations_description":
          "Boshqa e'lonlar haqida hali suhbat boshlamadingiz",
      "retry": "Qayta urinish",
      "back_to_listing": "E'longa qaytish",
      "load_more": "Ko'proq yuklash",

      "error_generic": "Xatolik yuz berdi",
      "error_loading_regions": "Tumanlarni yuklashda xatolik: {error}",
      "error_loading_universities":
          "Universitetlarni yuklashda xatolik: {error}",
      "error_creating_listing":
          "E'lon yaratishda xatolik. Iltimos, qayta urinib ko'ring.",
      "error_updating_listing": "E'loni yangilashda xatolik",
      "error_uploading_photos": "Fotosuratlarni yuklashda xatolik",
      "error_deactivating_listing": "E'lonni deaktivlashtirishda xatolik",
      "error_creating_profile": "Profil yaratishda xatolik: {error}",
      "error_updating_profile": "Profildi yangilashda xatolik: {error}",
      "error_opening_edit_screen":
          "Tahrirlash ekranini ochishda xatolik: {error}",
      "error_with_message": "Xatolik: {message}",
      "image_load_error": "Rasmni yuklashda xatolik",

      // ===== SUCCESS MESSAGES =====
      "listing_created_success": "E'lon muvaffaqiyatli yaratildi!",
      "listing_updated_success": "E'lon muvaffaqiyatli yangilandi",

      "profile_completed_success": "Profil muvaffaqiyatli to'ldirildi!",
      "profile_updated_success": "Profil muvaffaqiyatli yangilandi",
      "favorite_added_success": "Sevimlilar qo'shildi",
      "favorite_removed_success": "Sevimlilardan o'chirildi",

      "successfully_signed_in_google":
          "Google orqali muvaffaqiyatli kirdingiz!",

      // ===== EMPTY STATES =====
      "no_listings_found": "E'lonlar topilmadi",

      "no_locations_available": "Tumanlar mavjud emas",

      "no_universities_available": "Universitetlar mavjud emas",
      "no_search_results": "Qidiruv natijalari topilmadi",
      "try_refreshing": "Yangilashni sinab ko'ring yoki keyinroq tekshiring",
      "try_refining_search": "Qidiruv mezonlarini aniqlashni sinab ko'ring",
      "refine_search": "Qidiruvni aniqlash",

      // ===== SELECTION & PROMPTS =====
      "select_metro_line": "Liniyani tanlang",
      "select_metro_line_title": "Metro\nliniyasini tanlang",
      "select_location": "Har qanday tuman",
      "not_selected": "Tanlanmagan",
      "search_location_or_metro_hint":
          "Bitta variantni tanlang: tuman yoki metro bekati",

      "all_stations_count": "Barcha {count} bekatlar",
      "all_stations_explanation":
          "Liniya <b>{line}</b> bo'ylab <b>{count}</b> bekat orqali qidiruv",
      "metro_tutorial_search_hint":
          "Metro liniyasi bo'ylab yoki alohida bekatlar bo'yicha qidiruv.",
      "metro_tutorial_line_hint": "Barcha metro liniyasi stansiyalarida e'lonlarni qidiring",
      "metro_tutorial_station_hint": "Muayyan metro stansiyalari bo'yicha qidiruv",
      "metro_tutorial_tap_to_continue": "Davom etish uchun bosing",
      "select_region": "Tumanni tanlang",
      "select_region_profile_creation_title": "Qayerdansiz?",
      "select_region_profile_creation_description":
          "Vataningizdagi odamlarni topishga yordam beramiz.",
      "select_university": "Universitetni tanlang",

      "select_language": "Tilni tanlang",
      "select_theme": "Mavzuni tanlang",
      "select_theme_description": "Ilova uchun o'zingizning mavzuni tanlang",
      "please_complete_previous_steps":
          "Iltimos, avval oldingi qadamlarni bajarib bo'ling",
      "please_complete_all_fields": "Iltimos, barcha maydonlarni to'ldiring",
      "please_select_university": "Iltimos, universitetni tanlang",
      "tap_to_select_region": "Tumanni tanlash uchun bosing",
      "no_regions_available": "Tumanlar mavjud emas",

      // ===== ACTION BUTTONS =====
      "refresh": "Yangilash",
      "actions": "Harakatlar",

      "view_profile": "Profil",
      "deactivate_listing": "Deaktivlashtirish",
      "deactivate_listing_confirmation": "Bu e'loni deaktivlashtirishni xohlaysizmi? U boshqa foydalanuvchilarga ko'rinmaydi.",
      "deactivate": "Deaktivlashtirish",
      "activate_listing": "E'lonni aktivlashtirish",
      "activate_listing_confirmation": "Bu e'loni aktivlashtirishni xohlaysizmi? U boshqa foydalanuvchilarga ko'rinadi.",
      "activate": "Aktivlashtirish",
      "listing_active": "Aktiv",
      "listing_inactive": "Noaktiv",

      "create_listing_button": "E'lon yaratish",
      "update_listing_button": "E'loni yangilash",
      "save_changes": "O'zgarishlarni saqlash",

      "confirm": "Tasdiqlash",
      "next": "Keyingi",
      "back": "Orqaga",

      "complete": "Tugatish",

      // ===== THEME & APPEARANCE =====
      "settings": "Sozlamalar",
      "theme": "Mavzu",
      "blue_theme": "Ko'k",
      "light_theme": "Yorug'",
      "theme_changed_to": "Mavzu o'zgartirildi: {theme}",
      "theme_color": "Mavzu rangi",
      "switch_theme": "Mavzuni almashtirish",

      // ===== ABOUT & FEATURES =====
      "about_description":
          "UyDosh - Toshkentda mukammal turar joy topish uchun ishonchli platformangiz.",
      "about_feature_1": "• Metro stansiyalari bo'yicha e'lonlarni ko'rish",
      "about_feature_2": "• Tumanlar bo'yicha qidiruv",
      "about_feature_3": "• Egasi bilan to'g'ridan-to'g'ri aloqa",
      "about_feature_4": "• Tekshirilgan va xavfsiz e'lonlar",

      // ===== METRO SYSTEM =====
      "location_on_map": "Xaritadagi joylashuv",
      "show_map": "Xaritani ko'rsatish",
      "hide_map": "Xaritani yashirish",
      "open_in_yandex_maps": "Yandex Xaritalarida ochish",
      "open_in_yandex_maps_confirmation":
          "Brauzerda Yandex Xaritalari ochiladi.",

      // ===== LISTING DETAILS =====
      "listing_details": "Tafsilotlar",
      "author": "Muallif",
      "show_details": "Tafsilotlarni ko'rsatish",
      "hide_details": "Tafsilotlarni yashirish",
      "listing_views_by_others": "{count} ko'rilgan",
      "listing_views_stats_title": "Ko'rish statistikasi",
      "listing_views_stats_empty": "Hali ko'rishlar yo'q",
      "error_loading_view_stats": "Ko'rish statistikasini yuklashda xatolik",
      "promote_listing": "Yuqoriga chiqarish",
      "remove_from_top": "Yuqoridan olib tashlash",
      "feature_listing_success": "E'lon yuqoriga ko'tarildi",
      "unfeature_listing_success": "E'lon yuqoridan olib tashlandi",
      "feature_listing_error": "E'loni yangilash muvaffaqiyatsiz",
      "error_promotion_once_per_week":
          "E'loni haftada faqat bir marta yuqoriga ko'tarish mumkin",

      "listing_title_hint": "E'lon sarlavhasini kiriting",

      "listing_description_hint": "E'lon tavsifini kiriting",
      "listing_price_label": "Narxi",
      "listing_translate_tooltip_en": "Inglizchaga tarjima qilish",
      "listing_translate_tooltip_ru": "Rus tiliga tarjima qilish",
      "listing_translate_tooltip_uz": "O‘zbekchaga tarjima qilish",
      "listing_show_original_description": "Asl matn",
      "listing_translating_description": "Tarjima qilinmoqda…",
      "listing_translation_error": "Tarjima qilinmadi. Qayta urinib ko‘ring.",
      "listing_translation_unavailable": "Tarjima mavjud emas.",
      "listing_ai_enhance": "AI bilan yaxshilash",
      "listing_ai_enhance_empty": "Avval tavsif kiriting.",
      "listing_ai_enhance_unavailable": "AI yaxshilash mavjud emas.",
      "listing_ai_enhance_error": "Matnni yaxshilab bo‘lmadi. Qayta urinib ko‘ring.",

      "listing_type_roommate_needed": "Xonadosh qidiraman",
      "listing_type_room_needed": "Xonadon kerak",
      "title_male_roommate": "#YigitXonadoshQidiramiz",
      "title_female_roommate": "#QizXonadoshQidiramiz",
      "title_male_room": "#YigitXonadonQidiramiz",
      "title_female_room": "#QizXonadonQidiramiz",
      "listing_photos_label": "Rasmlar",

      "delete_photo": "Rasmni o'chirish",
      "delete_photo_confirmation": "Bu rasmni o'chirishni xohlaysizmi?",
      "photo_deleted_success": "Rasm muvaffaqiyatli o'chirildi",
      "error_deleting_photo":
          "Rasmni o'chirishda xatolik. Iltimos, qayta urinib ko'ring.",
      "photo_made_primary": "Rasm asosiy sifatida belgilandi",
      "new_primary_photo_selected":
          "Yangi asosiy rasm avtomatik tarzda tanlandi",
      "last_photo_deleted": "Oxirgi rasm o'chirildi - hali rasm qolmadi",
      "cannot_delete_last_photo": "Oxirgi rasmni o'chirib bo'lmaydi",
      "tap_photo_to_make_primary": "Rasmni asosiy sifatida belgilash",
      "making_primary": "Asosiy sifatida belgilash...",
      "add_photo": "Rasm qo'shish",
      "take_photo": "Rasm olish",
      "choose_from_gallery": "Galereyadan tanlash",
      "photo_limit_reached": "Maksimal 5 ta rasm",

      "max_photos_reached": "Maksimal rasmlar soniga yetildi",
      "max_photos_message":
          "Siz faqat 5 tagacha rasm yuklashingiz mumkin. Iltimos, yangi rasmlar qo'shishdan oldin ba'zi rasmlarni o'chiring.",

      "ok": "OK",
      "delete": "O'chirish",

      // ===== ONBOARDING =====
      "onboarding_title_1": "O'zingizning mukammal xonadoshlaringizni toping",
      "onboarding_subtitle_1":
          "Butun Toshkent bo'ylab birgalikda yashash uchun xonadoshlarni tez qidirish",
      "onboarding_title_2": "Metro bo'yicha qidiruv",
      "onboarding_subtitle_2":
          "Yoki stansiyalar bo'yicha - yoki butun metro liniyasi bo'yicha qidiring",
      "onboarding_title_3": "Tuman bo'yicha qidiruv",
      "onboarding_subtitle_3": "Toshkent tumanlari bo'yicha qulay qidiruv",
      "onboarding_title_4": "Ishonchli platforma",
      "onboarding_subtitle_4":
          "Tekshirilgan foydalanuvchilar kvartiralar va xonadoshlar uchun",

      "onboarding_get_started": "Boshlash",
      "onboarding_skip": "O'tkazib yuborish",
      "onboarding_next": "Keyingi",
      "onboarding_back": "Orqaga",
      "onboarding_toggle": "Boshlash",
      "onboarding_toggle_description": "Xush kelish ekrani",
      "haptic_feedback": "Haptik javob",
      "haptic_feedback_description":
          "Bosish va jestlar uchun tebranish",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "O'zbekcha",
      "language": "Til",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_changed_to": "Til o'zgartirildi: {language}",

      // ===== PROFILE & USER INFO =====
      "gender": "Jinsi",
      "male": "Yigit",
      "female": "Qiz",
      "other": "Boshqa",

      "university": "Universitet",
      "same_university": "Bir xil universitet",
      "both_students": "Ikkalasi ham talaba",
      "region": "Tuman",
      "same_region": "Bir xil tuman",
      "rating": "Reyting",
      "about_me": "Men haqimda",
      "telegram": "Telegram",
      "open_in_telegram": "Telegramda ochish",
      "open_in_telegram_confirmation": "Telegram ilova yoki brauzerda ochiladi.",

      // New profile fields
      "employed": "Ishlaydi",
      "cleanliness": "Tozalik",
      "noise_level": "Shovqin darajasi",
      "sociability": "Ijtimoiylik",
      "guests_allowed": "Mehmonlar ruxsat etilgan",
      "smoking_preference": "Chekish",
      "alcohol_preference": "Alkogol",
      "cooking_habits": "Ovqat pishirish odatlari",
      "pets_preference": "Hayvonlarga munosabat",
      "wakeup_time": "Uyg'onish vaqti",
      "sleep_time": "Uxlash vaqti",

      // Preference options
      "non_smoker": "Chekmayman",
      "occasional_smoker": "Ba'zan chekaman",
      "regular_smoker": "Muntazam chekaman",
      "non_drinker": "Ichmayman",
      "occasional_drinker": "Ba'zan ichaman",
      "regular_drinker": "Muntazam ichaman",
      "morning": "Ertalab",
      "evening": "Kechqurun",
      "night": "Tun",
      "pets_okay": "Yaxshi",
      "pets_not_okay": "Unchalik emas",

      // Slider labels
      "lifestyle_preferences": "Turmush tarzi afzalliklari",
      "very_messy": "Juda iflos",
      "messy": "Iflos",
      "average": "O'rtacha",
      "clean": "Toza",
      "very_clean": "Juda toza",
      "very_quiet": "Juda jim",
      "quiet": "Jim",
      "loud": "Baland",
      "very_loud": "Juda baland",
      "very_introverted": "Juda ichkariga qarab",
      "introverted": "Ichkariga qarab",
      "balanced": "Muvozanatli",
      "extroverted": "Tashqariga qarab",
      "very_extroverted": "Juda tashqariga qarab",
      "yes": "Ha",
      "no": "Yo'q",
      "cook": "Pishiraman",
      "dont_cook": "Pishirmayman",

      "not_specified": "Ko'rsatilmagan",

      // ===== AUTHENTICATION =====
      "complete_profile": "Profilni to'ldiring",
      "complete_profile_subheader":
          "Biz ushbu ma'lumotlardan sizga eng mos yotoqdoshlar va mos keluvchilarni topish uchun foydalanamiz.",

      "full_name": "Ism yoki taxallus",

      "are_you_student": "Siz talabamisiz?",
      "yes_student": "Men talabaman",
      "no_student": "Men talaba emasman",

      "are_you_landlord_or_renter": "Siz ijaraga beruvchimisiz yoki ijarachimisiz?",

      "selected": "Tanlangan",

      "full_name_hint": "Ismingiz yoki taxallusingizni kiriting",
      "name_required": "Ism yoki taxallus talab qilinadi",
      "saving": "Saqlanmoqda...",
      "firebase_user_not_found": "Firebase foydalanuvchisi topilmadi",
      "user_blocked_violation_title": "Hisob cheklangan",
      "user_blocked_violation_message":
          "Qoidabuzarlik tufayli hisobingiz cheklangan. Ilovani ko'rib chiqishingiz mumkin, lekin e'lon joylashtirish, xabar yuborish yoki kontentni tahrirlash mumkin emas. Savollaringiz bo'lsa, qo'llab-quvvatlash bilan bog'laning.",
      "profile_not_loaded_yet": "Profil hali yuklanmagan",
      "profile_still_loading": "Profil hali yuklanmoqda",
      "welcome_back_profile_exists": "Xush kelibsiz! Profil allaqachon mavjud.",
      "tap_to_select_university": "Universitetni tanlash uchun bosing",

      // ===== MENU & NAVIGATION =====
      "menu_profile": "Profil",
      "menu_home": "E'lonlar",
      "menu_language": "Til",

      "menu_favorites": "Sevimlilar",
      "menu_history": "Tarix",
      "menu_contact_support": "Qo'llab-quvvatlash bilan bog'lanish",
      "menu_add_listing": "E'lon qo'shish",
      "menu_my_listings": "Mening e'lonlarim",

      "menu_about": "Ilova haqida",
      "menu_privacy_policy": "Maxfiylik siyosati",
      "menu_user_license_agreement": "Foydalanuvchi litsenziya shartnomasi",
      "menu_faq": "Savol-javob",
      "menu_settings": "Sozlamalar",
      "menu_registration": "Kirish",
      "menu_logout": "Chiqish",
      "menu_admin_panel": "Admin paneli",
      "manage_property": "Uyni boshqarish",

      "admin_panel_title": "Admin paneli",
      "admin_panel_section_content_moderation": "Foto moderatsiyasi",
      "admin_content_moderation_title": "Foto moderatsiyasi",
      "admin_content_moderation_description":
          "Yoqilganda, yuklangan fotolar nojo'ya kontent uchun tekshiriladi; aniqlansa, saqlashdan oldin xira qilinadi. O'chirilganda tekshirish va xiralashtirish o'tkazilmaydi (AWS Rekognition chaqiruvlari yo'q).",
      "admin_content_moderation_blur_enabled": "Nojo'ya fotolarni aniqla va xira qil",
      "admin_content_moderation_loading": "Moderatsiya sozlamalari yuklanmoqda...",
      "admin_content_moderation_error": "Moderatsiya sozlamalari yuklanmadi",
      "admin_content_moderation_save_error": "Sozlama saqlanmadi",

      "admin_panel_section_users": "Foydalanuvchilar",
      "admin_panel_section_support_chat": "Qo'llab-quvvatlash",
      "admin_panel_section_complaints": "Shikoyatlar",
      "admin_panel_section_listing_complaints": "Shikoyatli e'lonlar",
      "admin_panel_section_district_heatmap": "Tumanlar issiqlik xaritasi",
      "admin_panel_section_subway_heatmap":
          "Metro liniyalari issiqlik xaritasi",
      "admin_panel_section_subway_map": "Metro sxemasi",
      "admin_panel_section_search_analytics": "Qidiruv statistikasi",
      "admin_panel_section_listing_creation_analytics":
          "E'lonlar yaratilishi statistikasi",

      "admin_search_analytics_title": "Qidiruv statistikasi",
      "admin_search_analytics_loading": "Qidiruv statistikasi yuklanmoqda...",
      "admin_search_analytics_error": "Statistika yuklanmadi",
      "admin_search_analytics_retry": "Qayta urinish",
      "admin_search_analytics_time_range": "Davr",
      "admin_search_analytics_days": "So'nggi {days} kun",
      "admin_search_analytics_all_time": "Barcha vaqt",
      "admin_search_analytics_total": "Jami qidiruvlar",
      "admin_search_analytics_today": "Bugun",
      "admin_search_analytics_week": "Haftada",
      "admin_search_analytics_top_stations": "Ommabop metro bekatlari",
      "admin_search_analytics_top_districts": "Ommabop tumanlar",
      "admin_search_analytics_top_lines": "Ommabop metro liniyalari",
      "admin_search_analytics_searches": "qidiruv",
      "admin_search_analytics_no_stations": "Bekatlar bo'yicha ma'lumot yo'q",
      "admin_search_analytics_no_districts": "Tumanlar bo'yicha ma'lumot yo'q",
      "admin_search_analytics_no_lines": "Liniyalar bo'yicha ma'lumot yo'q",

      "admin_listing_creation_analytics_title":
          "E'lonlar yaratilishi statistikasi",
      "admin_listing_creation_analytics_loading":
          "E'lonlar statistikasi yuklanmoqda...",
      "admin_listing_creation_analytics_error": "Statistika yuklanmadi",
      "admin_listing_creation_analytics_retry": "Qayta urinish",
      "admin_listing_creation_analytics_time_range": "Davr",
      "admin_listing_creation_analytics_total": "Davrdagi jami",
      "admin_listing_creation_analytics_today": "Bugun",
      "admin_listing_creation_analytics_week": "Haftada",
      "admin_listing_creation_analytics_by_day": "Kunlar bo'yicha e'lonlar",
      "admin_listing_creation_analytics_no_data":
          "Tanlangan davrda ma'lumot yo'q",

      "admin_district_heatmap_title": "Tumanlar issiqlik xaritasi",
      "admin_district_heatmap_description":
          "E'lonlar tumanlar bo'yicha rang zichligi bilan ko'rsatiladi.",
      "admin_district_heatmap_loading": "Tumanlar statistikasi yuklanmoqda...",
      "admin_district_heatmap_error":
          "Tumanlar statistikasi yuklanmadi",
      "admin_district_heatmap_retry": "Qayta urinish",
      "admin_district_heatmap_total": "Jami e'lonlar",
      "admin_district_heatmap_max": "Tumandagi maksimum",
      "admin_district_heatmap_count_label": "E'lonlar",
      "admin_district_heatmap_unavailable": "Mavjud emas",
      "admin_district_heatmap_no_data": "Tumanlar bo'yicha ma'lumot yo'q",

      "admin_subway_heatmap_title": "Metro liniyalari issiqlik xaritasi",
      "admin_subway_heatmap_description":
          "E'lonlar metro liniyalari bo'yicha rang zichligi bilan ko'rsatiladi.",
      "admin_subway_heatmap_loading":
          "Metro liniyalari statistikasi yuklanmoqda...",
      "admin_subway_heatmap_error": "Metro liniyalari statistikasi yuklanmadi",
      "admin_subway_heatmap_retry": "Qayta urinish",
      "admin_subway_heatmap_total": "Jami e'lonlar",
      "admin_subway_heatmap_max": "Liniyadagi maksimum",
      "admin_subway_heatmap_count_label": "E'lonlar",
      "admin_subway_heatmap_unavailable": "Mavjud emas",
      "admin_subway_heatmap_no_data":
          "Metro liniyalari bo'yicha ma'lumot yo'q",

      "admin_subway_map_title": "Metro sxemasi",
      "admin_subway_map_description":
          "Faqat yo'nalishlar va bekatlardan iborat soddalashtirilgan sxema.",
      "error_loading_map": "Xaritani yuklab bo'lmadi",

      "admin_users_title": "Foydalanuvchilar",
      "admin_users_loading": "Foydalanuvchilar yuklanmoqda...",
      "admin_users_empty": "Foydalanuvchilar topilmadi",
      "admin_users_error": "Foydalanuvchilarni yuklashda xatolik",
      "admin_users_id": "ID",
      "admin_users_role": "Rol",
      "admin_users_created_at": "Yaratilgan",
      "admin_users_listings_count": "E'lonlar",
      "admin_users_listings_count_loading": "Yuklanmoqda...",
      "admin_users_listings_count_error": "Mavjud emas",
      "admin_user_detail_title": "Foydalanuvchi",
      "admin_user_detail_role_title": "Rolni boshqarish",
      "admin_user_detail_role_label": "Rol",
      "admin_user_detail_role_save": "Rolni saqlash",
      "admin_user_detail_role_updated": "Rol yangilandi",
      "admin_user_detail_view_listings": "E'lonlarni ko'rish",
      "admin_user_detail_view_complaints": "Shikoyatlarni ko'rish",
      "admin_user_detail_block_title": "Bloklash",
      "admin_user_detail_block": "Bloklash",
      "admin_user_detail_unblock": "Blokdan chiqarish",
      "admin_user_detail_blocked": "Bloklangan",
      "admin_user_detail_block_reason": "Sabab",
      "admin_user_detail_block_until": "Qadar",
      "admin_user_detail_block_permanent": "Doimiy",
      "admin_user_detail_block_confirm": "Bloklash",
      "admin_user_detail_blocked_success": "Foydalanuvchi bloklandi",
      "admin_user_detail_unblocked_success": "Foydalanuvchi blokdan chiqarildi",
      "admin_user_complaints_title": "Foydalanuvchi shikoyatlari",
      "admin_user_complaints_user": "Foydalanuvchi",
      "admin_user_complaints_empty": "Shikoyatlar topilmadi",
      "admin_user_complaints_group_count": "Shikoyatlar",

      "admin_user_listings_title": "Foydalanuvchi e'lonlari",
      "admin_user_listings_user": "Foydalanuvchi",
      "admin_user_listings_empty": "E'lonlar topilmadi",
      "admin_user_listings_error": "E'lonlarni yuklashda xatolik",

      "admin_complaints_title": "Shikoyatlar",
      "admin_complaints_loading": "Shikoyatlar yuklanmoqda...",
      "admin_complaints_empty": "Shikoyatlar topilmadi",
      "admin_complaints_error": "Shikoyatlarni yuklashda xatolik",
      "admin_complaints_filter_all": "Barchasi",
      "admin_complaints_filter_pending": "Kutilmoqda",
      "admin_complaints_filter_resolved": "Hal qilindi",
      "admin_complaints_filter_dismissed": "Rad etildi",
      "admin_complaints_status_label": "Holat",
      "admin_complaints_status_pending": "Kutilmoqda",
      "admin_complaints_status_resolved": "Hal qilindi",
      "admin_complaints_status_dismissed": "Rad etildi",
      "admin_complaints_listing_id": "E'lon",
      "admin_complaints_complainant_id": "Foydalanuvchi",
      "admin_complaints_category_unknown": "Noma'lum kategoriya",
      "admin_complaints_created_at": "Yaratilgan",
      "admin_complaints_text": "Tavsif",
      "admin_complaints_update_status": "Holatni yangilash",
      "admin_complaints_status_updated": "Holat yangilandi",
      "admin_support_chat_title": "Qo'llab-quvvatlash",
      "admin_support_chat_loading": "Murojaatlar yuklanmoqda...",
      "admin_support_chat_empty": "Murojaatlar hali yo'q",
      "admin_support_chat_error": "Qo'llab-quvvatlash yuklanmadi",
      "admin_support_chat_retry": "Qayta urinish",
      "admin_support_chat_filter_all": "Barchasi",
      "admin_support_chat_filter_open": "Ochiq",
      "admin_support_chat_filter_closed": "Yopiq",
      "admin_support_chat_status_open": "Ochiq",
      "admin_support_chat_status_closed": "Yopiq",
      "admin_support_chat_messages": "xabar",
      "admin_support_chat_yesterday": "Kecha",
      "admin_support_chat_days_ago": "kun oldin",
      "admin_support_chat_no_messages": "Xabarlar hali yo'q",
      "admin_support_chat_reply_hint": "Javob yozing...",
      "admin_support_chat_close_thread": "Murojaatni yopish",
      "admin_support_chat_reopen_thread": "Qayta ochish",
      "admin_support_chat_closed": "Murojaat yopildi",
      "admin_support_chat_reopened": "Murojaat qayta ochildi",
      "admin_support_chat_thread_closed": "Murojaat yopilgan. Javob berish uchun qayta oching.",
      "contact_support_title": "Qo'llab-quvvatlash",
      "contact_support_loading": "Yuklanmoqda...",
      "contact_support_error": "Qo'llab-quvvatlash yuklanmadi",
      "contact_support_empty": "Murojaatlar hali yo'q. Yordam olish uchun yangi murojaat yarating.",
      "contact_support_new": "Yangi murojaat",
      "contact_support_message_hint": "Xabaringizni yozing...",
      "admin_listing_complaints_title": "Shikoyatli e'lonlar",
      "admin_listing_complaints_empty": "Shikoyatli e'lonlar yo'q",
      "admin_listing_complaints_error":
          "Shikoyatli e'lonlarni yuklashda xatolik",
      "admin_listing_complaints_last_reported": "So'nggi shikoyat",
      "admin_listing_complaints_categories": "Shikoyatlar",
      "admin_listing_complaints_categories_empty":
          "Shikoyat kategoriyalari yo'q",

      // ===== FAQ CONTENT =====
      "faq_question": "Xonadoshlar bilan qanday kelishish va nizolardan qanday qochish kerak?",
      "faq_answer": "Birga yashash — bu doimo hurmat va kelishish qobiliyati haqida. Tinchlik va do'stlikni saqlab qolishga yordam beradigan bir nechta oddiy qoidalar:\n\nShovqin\n\"Jimlik soatlari\" haqida kelishingiz. Musiqa uchun — quloqchinlar, qo'ng'iroqlar uchun — koridor yoki ko'cha. Har kimning qachon o'qish yoki dam olish vaqti ekanligini bilishi uchun jadval osish qulay.\n\nMehmonlar\nBir-biringizni oldindan ogohlantiring. Yaxshi qoida — mehmonlar uchun aniq kunlar va jimlik kunlari.\n\nHis-tuyg'ular\nAchchiqlanishni to'plamang. Agar biror narsa bezovta qilsa, tinch va darhol gapiring. Qo'shimcha stressni sport zalida yoki yugurishda chiqarish yaxshiroq.\n\nUmumiy ishlar\nBa'zan biror narsani birga qilish foydali: kinoga borish, sayr qilish, \"musiqa ostida tozalash\" tashkil etish. Umumiy xotiralar do'stlikni mustahkamlaydi.\n\nTozalash va uy ishlari\nMas'uliyatlarni bo'ling — kimdir polni artadi, kimdir axlatni olib chiqadi. Asosiy narsa — kelishish va shaxsiy chegaralarni hurmat qilish. Boshqalarning narsalarini ruxsatsiz tegmang.\n\nMuloqot\n\"Men-mesajlar\"dan foydalaning: \"sen meni jahldor qilasang\" o'rniga \"baland musiqa chalinsa, diqqatni jamlash qiyin\" deyish yaxshiroq.\n\nNizolarni hal qilish\nHamma narsani tinch muhokama qilishga harakat qiling, bir-biringizni tinglang. Nizo — dushman emas, balki umumiy yechim topish imkoniyati.\n\nOvqat\nBirgalikda xarid qilish yoki \"umumiy javon\" ochish haqida kelishishingiz mumkin.\n\nTartib va jimlik\nTozalash jadvali — eng yaxshi do'stingiz. Agar diqqatni jamlash kerak bo'lsa — kutubxonaga yoki kovorkingga borishingiz yoki yana \"jimlik soati\" qoidasini yoqishingiz mumkin.",

      "faq_question_2": "Kommunal qarzlar va ularni qanday oldini olish",
      "faq_answer_2": "Ba'zan kvartira bilan birga ijarachiga kommunal xizmatlar bo'yicha qarzlar ham \"sovg'a\" sifatida tushadi. Natijada — o'chirilgan yorug'lik yoki suv, ijaraga beruvchi esa to'lashga shoshilmaydi. Ijarachiga qoladi: zarar bilan ko'chib ketish yoki qarzni o'z hisobidan to'lash.\n\nBunday vaziyatlardan qochish uchun:\n\nImzolashdan oldin tekshirish\nShartnomani imzolashdan oldin xo'jayindan to'langan kommunal to'lovlar bo'yicha kvitansiyalar yoki hisobot so'rang.\n\nYozma kelishuv\nAgar qarz hali ham bo'lsa va uni to'lashga tayyor bo'lsangiz, albatta yozma kelishuv tuzing: qarz summasi kelajakdagi ijara uchun hisobga olinadi.\n\nShunday qilib siz ham pulni, ham tinchlikni saqlab qolasiz.",

      "faq_question_3": "Vad qilingan ta'mirlash uchun uch yil kutish kerak",
      "faq_answer_3": "Ko'pincha uy ijaraga olishda, xo'jayin kvartira muammolarini hal qilish, maishiy texnika va mebel sotib olishni va'da qiladi. Bularning barchasini u ko'chib kelgandan so'ng darhol bajarishni o'z zimmasiga oladi. Biroq vaqt o'tadi, muammolar qoladi. Bunday vaziyatning garovi bo'lmaslik uchun ijarachi ijaraga olish shartnomasiga maxsus shartlarni kiritishi kerak.\n\nShuningdek, ijarachi tomonidan ta'mirlash va ishlar davomida ijara haqini undirmaslik haqidagi og'zaki kelishuvlar ham tez-tez buziladi. Masalan, siz kvartirani o'z hisobingizdan ta'mirlaysiz va bir necha oy ijara haqini to'lamaysiz. Biroq ba'zi ijaraga beruvchilar kelishuvlarni \"unutib\" qo'yadi va yashash uchun to'lov talab qiladi. Ko'pincha tomonlar bezatish narxi haqida kelishmovchiliklar paydo bo'ladi, ba'zida esa ish sudga ham borga.\n\nShuning uchun ta'mirlashning barcha jihatlarini muhokama qilish, ularni ijaraga olish shartnomasida hisobga olish, shuningdek smeta tuzish va imzolash kerak.",

      "faq_question_4": "Sen endi mening do'stim emassan",
      "faq_answer_4": "Ko'pincha uyni qarindoshlar yoki do'stlarga ijaraga berishda shartnoma tuzilmaydi. Shu bilan birga, ko'plab janjallar va tortishuvlar aynan og'zaki ijara va'da va majburiyatlarini qabul qilgan qarindoshlar va do'stlar o'rtasida yuzaga keladi. Shuning uchun shartnoma tuzish yaxshiroq, hatto siz amakivachchangiz yoki yaqin do'stingizdan kvartira ijaraga olsangiz ham.\n\nKvartiralar vasiylik orqali ijaraga beriladigan hollar ham bor, unda ko'rsatilgan: vasiylik beruvchi vasiylik oluvchiga o'z kvartirasini ijaraga berish huquqini beradi. \"Lekin vasiylikda vasiylik oluvchining ijara haqini olish huquqiga ega ekanligi ko'rsatilmagan. Vaziyat yuzaga kelishi mumkin: ijarachi muntazam ravishda ijara summasini vasiylik oluvchiga to'laydi, lekin bir kuni uy-joy egasi paydo bo'lib, ijarachidan kvartira yashash davri uchun to'lov talab qiladi.\" Bunday holda hujjatlarni diqqat bilan o'rganish kerak, va agar vasiylikda ijara haqini olish huquqi ko'rsatilmagan bo'lsa, bu masalani muhokama qilish kerak.",

      "faq_question_5": "Ijarachilar va qo'shnilar uchun xavfsizlik qo'llanmasi",
      "faq_answer_5": "Ba'zan noqulay vaziyatlar nafaqat bizning platformamizda yuzaga keladi. Afsuski, noto'g'ri yoki muammoli odamlar hamma joyda uchraydi. Shuning uchun oddiy xavfsizlik qoidalarini eslab qolish muhim.\n\n🙏 Asosiy narsa — sizning xavfsizligingiz!\n\nUchrashuvdan oldin\n• Uchrashuvlarni faqat kunduzgi vaqtda rejalashtiring.\n• Ko'p odamli joylarni tanlang — kafe, savdo markazi, kamerali hovli.\n• Do'stlaringiz yoki qarindoshlaringizga qayerga va kim bilan uchrashayotganingizni ayting.\n\nUchrashuv paytida\n• Iloji bo'lsa, yolg'iz keling.\n• Shartnoma imzolanmaguncha pul va hujjatlarni \"qo'ldan qo'liga\" bermang.\n• Yozishmalar va hujjatlar fotosuratlarini/skanlarini saqlang — bu sizning himoyangiz.\n\nAgar tahdid his qilsangiz\n• Darhol uchrashuvni to'xtating va keting.\n• \"Yo'q\" deyishdan va aloqani uzishdan qo'rqmang.\n• Aniq xavf bo'lsa — 102 ga qo'ng'iroq qiling yoki eng yaqin politsiya bo'limiga murojaat qiling.\n\nUyDosh platformasida\n• Tasdiqlash tizimidan foydalaning — tasdiqlangan profillar xavfni kamaytiradi.\n• Shubhali e'lonlar va xatti-harakatlar haqida moderatorlarga xabar bering.\n• Esda tuting: ehtiyot bo'lish, keyin afsuslanishdan yaxshiroq.\n\n❤️ O'zingizni va bir-biringizni asrang!",

      // ===== LOGOUT & SESSION =====
      "logout_confirmation": "Chiqish tasdiqlash",
      "logout_description":
          "Chiqishni xohlaysizmi? Profilingizga kirish uchun qaytadan tizimga kirishingiz kerak bo'ladi.",
      "logout": "Chiqish",
      "logout_success": "Muvaffaqiyatli chiqildi",

      // ===== DELETE ACCOUNT =====
      "delete_account": "Hisobni o'chirish",
      "delete_account_confirmation":
          "Hisobingizni o'chirishni xohlaysizmi? Bu amalni bekor qilish mumkin emas. Barcha ma'lumotlaringiz, e'lonlaringiz va xabarlaringiz butunlay o'chiriladi.",
      "delete_account_success": "Hisob muvaffaqiyatli o'chirildi",
      "delete_account_error": "Hisobni o'chirishda xatolik",
      "delete_account_blocked":
          "Hisobingiz cheklangan. Bloklangan paytda hisobni o'chirish mumkin emas. Qo'llab-quvvatlash xizmatiga murojaat qiling.",

      // ===== FAVORITES =====
      "favorites_title": "Sevimlilar",
      "favorites_empty_title": "Hali sevimlilar yo'q",
      "favorites_browse_button": "E'lonlarni ko'rish",

      "view_history_title": "Ko'rilganlar tarixi",
      "view_history_empty_title": "Hali ko'rilgan e'lonlar yo'q",
      "view_history_browse_button": "E'lonlarni ko'rish",
      "view_history_auth_prompt": "Tarixni ko'rish uchun tizimga kiring.",
      "unable_to_load_view_history":
          "Tarixni yuklash imkoni yo'q. Keyinroq urinib ko'ring.",

      // ===== ACHIEVEMENTS =====
      "menu_achievements": "Yutuqlar",
      "achievements_title": "Yutuqlar",
      "achievement_unlocked": "Yutuq ochildi!",
      "achievement_first_steps": "Birinchi qadamlar",
      "achievement_first_steps_desc": "Hisob yarating",
      "achievement_profile_complete": "Profil to'liq",
      "achievement_profile_complete_desc": "Profilni 100% to'ldiring",
      "achievement_first_look": "Birinchi qarash",
      "achievement_first_look_desc": "Birinchi e'loningizni ko'ring",
      "achievement_bookmarker": "Sevimlilar",
      "achievement_bookmarker_desc": "Birinchi sevimlini qo'shing",
      "achievement_ice_breaker": "Suhbat boshlovchi",
      "achievement_ice_breaker_desc": "Birinchi xabaringizni yuboring",
      "achievement_first_listing": "Birinchi e'lon",
      "achievement_first_listing_desc": "Birinchi e'loningizni yarating",
      "achievement_returning_user": "Doimiy foydalanuvchi",
      "achievement_returning_user_desc": "Ilovani 7 kun ketma-ket ishlating",
      "achievement_sharer": "Ulashuvchi",
      "achievement_sharer_desc": "Birinchi e'loningizni ulashing",
      "achievements_empty": "Hali yutuqlar yo'q",
      "achievements_empty_desc": "Yutuqlarni ochish uchun harakatlarni bajaring",
      "achievements_auth_prompt": "Yutuqlaringizni ko'rish uchun tizimga kiring",

      "favorite_toggle_error": "Sevimli holatini yangilashda xatolik",
      "favorite_toggle_network_error":
          "Sevimli holatini yangilashda tarmoq xatoligi",

      "unable_to_load_favorites":
          "Sevimlilarni yuklash imkoni yo'q. Keyinroq urinib ko'ring.",

      // ===== CREATE & EDIT LISTING =====
      "create_listing_title": "E'lon yaratish",
      "edit_listing": "E'lonni tahrirlash",
      "edit_profile": "Profilni tahrirlash",
      "updating_listing": "Yangilanmoqda...",
      "creating_listing": "Yaratilmoqda...",
      "title_required": "Sarlavha talab qilinadi",
      "title_too_long": "Sarlavha 25 belgidan ko'p bo'lmasligi kerak",
      "description_required": "Tavsif talab qilinadi",
      "description_too_long": "Tavsif 500 belgidan ko'p bo'p bo'lmasligi kerak",
      "location_required": "Iltimos, tuman tanlang",

      "auth_required_title": "Autentifikatsiya talab qilinadi",
      "authentication_required":
          "Autentifikatsiya talab qilinadi. Iltimos, e'lon yaratish uchun tizimga kiring.",

      "unauthenticated_listing_prompt":
          "E'lon yaratish va joylashtirish uchun hisobingizga kirishingiz kerak.",
      "authenticate_to_post_listing":
          "E'lon joylashtirish uchun tizimga kiring",
      "select_location_required": "Tumanni tanlang",
      "select_metro_line_optional": "Metro liniyasi",

      // ===== AMENITIES & FEATURES =====
      "amenities": "Qulayliklar",
      "photos": "Rasmlar",
      "primary": "Asosiy",
      "wifi": "Wi-Fi",
      "bed": "Krovat",
      "air_conditioning": "Konditsioner",
      "tv": "Televizor",
      "microwave": "Mikrovolnovka",
      "washing_machine": "Kir yuvish mashinasi",
      "pets": "Uy hayvonlari ruxsat beriladi",

      // ===== PRICING & FINANCIAL =====
      "month": "oy",

      // ===== SEARCH & FILTERS =====
      "search_listings": "E'lonlarni qidirish",

      "search": "Qidirish",
      "tutorial_search_title": "E'lonlarni qidirish",
      "tutorial_search_description":
          "E'lonlarni tuman, narx, xona turi va boshqa parametrlar bo'yicha filtrlash uchun bosing.",
      "tutorial_profile_description":
          "Profilingiz va hisob sozlamalari shu yerda.",
      "tutorial_got_it": "Tushundim",
      "tutorial_metro_description":
          "Metro liniyasini tanlang, keyin joylashuv bo'yicha filtrlash uchun stansiyani tanlang.",

      // ===== TIME & DATES =====
      "january": "Yanvar",
      "february": "Fevral",
      "march": "Mart",
      "april": "Aprel",
      "may": "May",
      "june": "Iyun",
      "july": "Iyul",
      "august": "Avgust",
      "september": "Sentabr",
      "october": "Oktabr",
      "november": "Noyabr",
      "december": "Dekabr",
      "select_date": "Ko'chib kelish sanasi",
      "move_in_date_label": "Ko'chib kelish sanasi:",
      "publication_date": "Nashr sanasi:",

      // ===== GOOGLE AUTHENTICATION =====
      "sign_in_with_google": "Google orqali kirish",
      "sign_in_with_google_description":
          "Davom etish uchun Google hisobingizga kiring",

      "signing_in": "Tizimga kirilmoqda...",
      "google_sign_in_failed": "Google orqali kirishda xatolik: {error}",
      "popup_closed": "Kirish oynasi yopildi",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Bu e'lonni UyDosh da ko'ring!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Foydalanuvchi bilan bog'lanish",
      "message": "Yozish",

      // ===== STATUS & STATE =====
      "delete_listing": "E'loni o'chirish",
      "delete_listing_confirmation":
          "Bu e'loni o'chirishni xohlaysizmi? Bu amalni qaytarib bo'lmaydi.",
      "delete_listing_success": "E'lon muvaffaqiyatli o'chirildi",
      "delete_listing_error": "E'loni o'chirishda xatolik",
      "unknown": "Noma'lum",

      // ===== COMPLAINTS =====
      "create_complaint": "Shikoyat yaratish",
      "select_complaint_category": "Shikoyat kategoriyasini tanlang",
      "complaint_description_hint": "Tafsilotlar qo'shing (ixtiyoriy)",
      "submit_complaint": "Shikoyatni yuborish",
      "complaint_created_success": "Shikoyat muvaffaqiyatli yuborildi",
      "listing_complaints": "E'lon bo'yicha shikoyatlar",
      "listing_complaints_header": "E'lon bo'yicha shikoyatlar: {count}",
      "view_listing_complaints": "Shikoyatlarni ko'rish",
      "complaints_count_short": "{count} ta shikoyat",
      "no_listing_complaints": "Bu e'lon bo'yicha hali shikoyatlar yo'q",
    },
  };

  /// Get a string value based on language code
  ///
  /// [key] - The string key to retrieve
  /// [language] - Language code ("en", "ru", "uz")
  /// [fallback] - Optional fallback value if key is not found
  static String get(String key, String language, {String? fallback}) {
    final langStrings = _strings[language] ?? _strings["en"]!;
    return langStrings[key] ?? fallback ?? key;
  }

  /// Get a string with parameters
  ///
  /// [key] - The string key to retrieve
  /// [language] - Language code ("en", "ru", "uz")
  /// [params] - Map of parameters to replace in the string
  /// [fallback] - Optional fallback value if key is not found
  static String getWithParams(
    String key,
    String language, {
    Map<String, String>? params,
    String? fallback,
  }) {
    var value = get(key, language, fallback: fallback);

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll("{$paramKey}", paramValue);
      });
    }

    return value;
  }

  /// Get all strings for a specific language
  static Map<String, String> getAllForLanguage(String language) {
    return _strings[language] ?? _strings["en"]!;
  }

  /// Check if a key exists for a language
  static bool hasKey(String key, String language) {
    final langStrings = _strings[language] ?? _strings["en"]!;
    return langStrings.containsKey(key);
  }
}
