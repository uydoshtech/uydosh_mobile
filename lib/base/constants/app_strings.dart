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
      "name": "Name",
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
      "view_listing": "View Listing",
      "menu_messages": 'Messages',
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
      "search_location_or_metro_hint":
          "Choose one option: district or metro station",

      "all_stations_count": "All {count} stations",
      "all_stations_explanation":
          "Search along the entire line <b>{line}</b> through <b>{count}</b> stations",
      "select_region": "Select region",
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
      "retry": "Retry",
      "refresh": "Refresh",
      "actions": "Actions",
      "load_more": "Load More",

      "view_profile": "View Profile",
      "deactivate_listing": "Deactivate Listing",
      "deactivate_listing_confirmation": "Are you sure you want to deactivate this listing? It will no longer be visible to other users.",
      "deactivate": "Deactivate",
      "activate_listing": "Activate Listing",
      "activate_listing_confirmation": "Are you sure you want to activate this listing? It will become visible to other users.",
      "activate": "Activate",

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
      "open_in_yandex_maps": "Open in Yandex Maps",
      "open_in_yandex_maps_confirmation":
          "A browser with Yandex Maps will be opened.",

      // ===== LISTING DETAILS =====
      "listing_details": "Details",

      "listing_title_hint": "Enter listing title",

      "listing_description_hint": "Enter listing description",
      "listing_price_label": "Price",

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

      "onboarding_get_started": "Get Started",
      "onboarding_skip": "Skip",
      "onboarding_next": "Next",
      "onboarding_back": "Back",
      "onboarding_toggle": "Onboarding",
      "onboarding_toggle_description": "Show welcome screens",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "English",
      "language": "Language",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_changed_to": "Language changed to {language}",

      // ===== PROFILE & USER INFO =====
      "gender": "Gender",
      "male": "Male",
      "female": "Female",
      "other": "Other",

      "university": "University",
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
      "smoking_preference": "Smoking Preference",
      "alcohol_preference": "Alcohol Preference",
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

      "not_specified": "Not Specified",

      // ===== AUTHENTICATION =====
      "complete_profile": "Complete Your Profile",

      "full_name": "Full Name",

      "are_you_student": "Are you a student?",
      "yes_student": "Yes, I'm a student",
      "no_student": "No, I'm not a student",

      "selected": "Selected",

      "full_name_hint": "Enter your full name",
      "name_required": "Name is required",
      "saving": "Saving...",
      "firebase_user_not_found": "Firebase user not found",
      "profile_not_loaded_yet": "Profile not loaded yet",
      "profile_still_loading": "Profile still loading",
      "welcome_back_profile_exists": "Welcome back! Profile already exists.",
      "tap_to_select_university": "Tap to select a university",

      // ===== MENU & NAVIGATION =====
      "menu_profile": "Profile",
      "menu_home": "Listings",
      "menu_language": "Language",

      "menu_favorites": "Favorites",
      "menu_add_listing": "Add Listing",
      "menu_my_listings": "My Listings",

      "menu_about": "About",
      "menu_faq": "FAQ",
      "menu_settings": "Settings",
      "menu_registration": "Sign in",
      "menu_logout": "Logout",

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

      // ===== FAVORITES =====
      "favorites_title": "Favorites",
      "favorites_empty_title": "No favorites yet",
      "favorites_browse_button": "Browse Listings",

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
      "publication_date": "Publication date:",
      "cancel": "Cancel",
      "ok": "OK",

      // ===== GOOGLE AUTHENTICATION =====
      "sign_in_with_google": "Sign In with Google",
      "sign_in_with_google_description":
          "Sign in to your Google account to continue",

      "signing_in": "Signing in...",
      "google_sign_in_failed": "Google Sign-In failed: {error}",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Check out this listing on UyDosh!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Contact User",

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
      "name": "Имя",
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
      "search_location_or_metro_hint":
          "Выберите один вариант: район или станцию метро",

      "all_stations_count": "Все {count} станций",
      "all_stations_explanation":
          "Поиск вдоль ВСЕЙ линии <b>{line}</b> по <b>{count}</b> станциям",
      "select_region": "Выберите район",
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
      "retry": "Повторить",
      "refresh": "Обновить",
      "actions": "Действия",
      "load_more": "Загрузить ещё",

      "view_profile": "Просмотреть профиль",
      "deactivate_listing": "Деактивировать объявление",
      "deactivate_listing_confirmation": "Вы уверены, что хотите деактивировать это объявление? Оно больше не будет видно другим пользователям.",
      "deactivate": "Деактивировать",
      "activate_listing": "Активировать объявление",
      "activate_listing_confirmation": "Вы уверены, что хотите активировать это объявление? Оно станет видно другим пользователям.",
      "activate": "Активировать",

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
      "open_in_yandex_maps": "Открыть в Яндекс Картах",
      "open_in_yandex_maps_confirmation":
          "Браузер с Яндекс Картами будет открыт.",

      // ===== LISTING DETAILS =====
      "listing_details": "Детали",

      "listing_title_hint": "Введите заголовок объявления",

      "listing_description_hint": "Введите описание объявления",
      "listing_price_label": "Цена",

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

      "onboarding_get_started": "Начать",
      "onboarding_skip": "Пропустить",
      "onboarding_next": "Далее",
      "onboarding_back": "Назад",
      "onboarding_toggle": "Обучение",
      "onboarding_toggle_description": "Показать приветствие",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "Русский",
      "language": "Язык",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_changed_to": "Язык изменен на {language}",

      // ===== PROFILE & USER INFO =====
      "gender": "Пол",
      "male": "Мужской",
      "female": "Женский",
      "other": "Другой",

      "university": "Университет",
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
      "smoking_preference": "Отношение к курению",
      "alcohol_preference": "Отношение к алкоголю",
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
      "very_loud": "Очень громкий",
      "very_introverted": "Необщительный",
      "introverted": "Интроверт",
      "balanced": "Средне",
      "extroverted": "Экстраверт",
      "very_extroverted": "Очень общительный",
      "yes": "Да",
      "no": "Нет",

      "not_specified": "Не указано",

      // ===== AUTHENTICATION =====
      "complete_profile": "Завершите профиль",

      "full_name": "Полное имя",

      "are_you_student": "Вы студент?",
      "yes_student": "Студент",
      "no_student": "Не студент",

      "selected": "Выбрано",

      "full_name_hint": "Введите ваше полное имя",
      "name_required": "Имя обязательно",
      "saving": "Сохранение...",
      "firebase_user_not_found": "Пользователь Firebase не найден",
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
      "menu_add_listing": "Добавить объявление",
      "menu_my_listings": "Мои объявления",

      "menu_about": "О приложении",
      "menu_faq": "Часто задаваемые вопросы",
      "menu_settings": "Настройки",
      "menu_registration": "Вход",
      "menu_logout": "Выйти",

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

      // ===== FAVORITES =====
      "favorites_title": "Избранное",
      "favorites_empty_title": "Пока нет избранного",
      "favorites_browse_button": "Просмотреть объявления",

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
      "publication_date": "Дата публикации:",
      "cancel": "Отмена",
      "ok": "ОК",

      // ===== GOOGLE AUTHENTICATION =====
      "sign_in_with_google": "Войти через Google",
      "sign_in_with_google_description":
          "Войдите в свой аккаунт Google для продолжения",

      "signing_in": "Вход в систему...",
      "google_sign_in_failed": "Ошибка входа через Google: {error}",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Посмотрите это объявление на UyDosh!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Связаться с пользователем",

      // ===== STATUS & STATE =====
      "delete_listing": "Удалить объявление",
      "delete_listing_confirmation":
          "Вы уверены, что хотите удалить это объявление? Это действие нельзя отменить.",
      "delete_listing_success": "Объявление успешно удалено",
      "delete_listing_error": "Ошибка удаления объявления",

      // ===== COMPLAINTS =====
      "create_complaint": "Создать жалобу",
      "select_complaint_category": "Выберите категорию жалобы",
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
      "name": "Ism",
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
      "search_location_or_metro_hint":
          "Bitta variantni tanlang: tuman yoki metro bekati",

      "all_stations_count": "Barcha {count} bekatlar",
      "all_stations_explanation":
          "Liniya <b>{line}</b> bo'ylab <b>{count}</b> bekat orqali qidiruv",
      "select_region": "Tumanni tanlang",
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
      "retry": "Qayta urinish",
      "refresh": "Yangilash",
      "actions": "Harakatlar",
      "load_more": "Yana yuklash",

      "view_profile": "Profilni ko'rish",
      "deactivate_listing": "E'lonni deaktivlashtirish",
      "deactivate_listing_confirmation": "Bu e'loni deaktivlashtirishni xohlaysizmi? U boshqa foydalanuvchilarga ko'rinmaydi.",
      "deactivate": "Deaktivlashtirish",
      "activate_listing": "E'lonni aktivlashtirish",
      "activate_listing_confirmation": "Bu e'loni aktivlashtirishni xohlaysizmi? U boshqa foydalanuvchilarga ko'rinadi.",
      "activate": "Aktivlashtirish",

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
      "open_in_yandex_maps": "Yandex Xaritalarida ochish",
      "open_in_yandex_maps_confirmation":
          "Brauzerda Yandex Xaritalari ochiladi.",

      // ===== LISTING DETAILS =====
      "listing_details": "Tafsilotlar",

      "listing_title_hint": "E'lon sarlavhasini kiriting",

      "listing_description_hint": "E'lon tavsifini kiriting",
      "listing_price_label": "Narxi",

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

      "onboarding_get_started": "Boshlash",
      "onboarding_skip": "O'tkazib yuborish",
      "onboarding_next": "Keyingi",
      "onboarding_back": "Orqaga",
      "onboarding_toggle": "Boshlash",
      "onboarding_toggle_description": "Xush kelish ekrani",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "O'zbekcha",
      "language": "Til",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_changed_to": "Til o'zgartirildi: {language}",

      // ===== PROFILE & USER INFO =====
      "gender": "Jinsi",
      "male": "Erkak",
      "female": "Ayol",
      "other": "Boshqa",

      "university": "Universitet",
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
      "smoking_preference": "Chekishga munosabat",
      "alcohol_preference": "Alkogolga munosabat",
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

      "not_specified": "Ko'rsatilmagan",

      // ===== AUTHENTICATION =====
      "complete_profile": "Profilni to'ldiring",

      "full_name": "To'liq ism",

      "are_you_student": "Siz talabamisiz?",
      "yes_student": "Men talabaman",
      "no_student": "Men talaba emasman",

      "selected": "Tanlangan",

      "full_name_hint": "To'liq ismingizni kiriting",
      "name_required": "Ism talab qilinadi",
      "saving": "Saqlanmoqda...",
      "firebase_user_not_found": "Firebase foydalanuvchisi topilmadi",
      "profile_not_loaded_yet": "Profil hali yuklanmagan",
      "profile_still_loading": "Profil hali yuklanmoqda",
      "welcome_back_profile_exists": "Xush kelibsiz! Profil allaqachon mavjud.",
      "tap_to_select_university": "Universitetni tanlash uchun bosing",

      // ===== MENU & NAVIGATION =====
      "menu_profile": "Profil",
      "menu_home": "E'lonlar",
      "menu_language": "Til",

      "menu_favorites": "Sevimlilar",
      "menu_add_listing": "E'lon qo'shish",
      "menu_my_listings": "Mening e'lonlarim",

      "menu_about": "Ilova haqida",
      "menu_faq": "Tez-tez so'raladigan savollar",
      "menu_settings": "Sozlamalar",
      "menu_registration": "Kirish",
      "menu_logout": "Chiqish",

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

      // ===== FAVORITES =====
      "favorites_title": "Sevimlilar",
      "favorites_empty_title": "Hali sevimlilar yo'q",
      "favorites_browse_button": "E'lonlarni ko'rish",

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
      "cancel": "Bekor qilish",
      "ok": "OK",

      // ===== GOOGLE AUTHENTICATION =====
      "sign_in_with_google": "Google orqali kirish",
      "sign_in_with_google_description":
          "Davom etish uchun Google hisobingizga kiring",

      "signing_in": "Tizimga kirilmoqda...",
      "google_sign_in_failed": "Google orqali kirishda xatolik: {error}",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Bu e'lonni UyDosh da ko'ring!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Foydalanuvchi bilan bog'lanish",

      // ===== STATUS & STATE =====
      "delete_listing": "E'loni o'chirish",
      "delete_listing_confirmation":
          "Bu e'loni o'chirishni xohlaysizmi? Bu amalni qaytarib bo'lmaydi.",
      "delete_listing_success": "E'lon muvaffaqiyatli o'chirildi",
      "delete_listing_error": "E'loni o'chirishda xatolik",

      // ===== COMPLAINTS =====
      "create_complaint": "Shikoyat yaratish",
      "select_complaint_category": "Shikoyat kategoriyasini tanlang",
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
