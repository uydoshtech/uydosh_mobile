// Storage keys for persistent data
class StorageKeys {
  static const String selectedLanguage = "selected_language";
  static const String hasUserSelectedLanguage = "has_user_selected_language";
  static const String favoriteListings = "favorite_listings";
  static const String selectedTheme = "selected_theme";
}

class AppStrings {
  static final Map<String, Map<String, String>> _strings = {
    "en": {
      // ===== NAVIGATION =====
      "home": "Listings",
      "nav_housing": "Housing",
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
      "create_choice_title": "Where shall we start?",
      "create_choice_housing": "Housing",
      "create_choice_housing_subtitle": "Rent out or find a place",
      "create_choice_roommate_needed_subtitle":
          "You've got a place — we'll find roommates you'll feel at home with",
      "create_choice_room_needed_subtitle":
          "We'll find a room or apartment you'll love",
      "create_choice_group_forming": "Gather a group",
      "create_choice_group_forming_subtitle":
          "Team up and rent together — it's more affordable",
      "create_group_title": "Gather a group",
      "listing_type_group_forming": "Gather a group",
      "title_group_forming": "Forming Group",
      "group_size_target_label": "Group size (including you)",
      "group_size_target_option_one": "{count} person total",
      "group_size_target_option_other": "{count} people total",
      "group_budget_per_person_label": "Budget per person range (y.e./mo)",
      "group_budget_per_person_heading": "Budget per person",
      "price_picker_single_title": "Monthly price",
      "price_picker_range_title": "Monthly budget range",
      "group_budget_per_person_amount_line":
          "Each member pays {range} per month",
      "group_budget_total_apartment_line":
          "Total rent for {count} people: {range} per month",
      "group_request_to_join": "Request to join",
      "group_join_request_sent": "Request sent",
      "group_join_request_withdraw": "Withdraw request",
      "group_open_chat": "Open group chat",
      "group_floating_chat_label": "Group chat · {current}/{target}",
      "group_floating_participants_label": "Participants",
      "group_floating_shortlist_label": "Housing options · {count}",
      "group_manage_requests": "Manage requests",
      "group_members_progress": "{current}/{target} members",
      "group_status_looking_for_roommates": "Looking for roommates",
      "group_status_request_pending": "Join request pending",
      "group_status_full": "Group full",
      "group_status_closed": "Group closed",
      "group_status_housing_search": "Searching for housing",
      "group_status_reviewing_shortlist": "Reviewing saved listings",
      "group_status_landlord_outreach_owner": "Waiting for landlord response",
      "group_status_landlord_outreach_member": "Landlord invitation sent",
      "group_status_landlord_joined": "Landlord joined the chat",
      "group_members_needed_one": "Need {count} more person",
      "group_members_needed_other": "Need {count} more people",
      "group_join_request_message_hint": "Introduce yourself (optional)",
      "group_join_request_success": "Join request sent",
      "group_join_requires_profile":
          "Complete your profile before joining this group.",
      "group_join_request_withdrawn": "Request withdrawn",
      "group_join_request_approved": "Member added to the group",
      "group_join_request_rejected": "Request rejected",
      "group_no_pending_requests": "No pending requests",
      "group_new_request_pill": "New request",
      "group_approve_member": "Approve",
      "group_reject_member": "Reject",
      "group_pending_join_requests": "Pending requests",
      "group_member_role_pending_request": "Pending request",
      "create_choice_service": "Service",
      "create_choice_service_subtitle": "Offer or find a service",
      "profile": "Profile",
      "role_tenant": "Tenant",
      "role_landlord": "Landlord",
      "role_manager": "Manager",
      "role_admin": "Admin",
      "role_service_provider": "Service provider",
      "role_service_requester": "Service requester",
      "profile_completion": "Profile completion",
      "profile_completion_hint":
          "A completed profile means more accurate matches and comfortable co-living.",
      "complete_profile_prompt_title": "Complete your profile",
      "complete_profile_prompt_body":
          "Add your lifestyle preferences to get better matches.",
      "missing_fields_title": "Missing:",
      "complete_profile_prompt_more": "+ {count} more",
      "complete_profile_prompt_cta": "Complete now",
      "complete_profile_prompt_later": "Later",
      "compatibility_title": "Compatibility with you:",
      "compatibility_match_percentage": "Match: {percent}%",
      "compatibility_calculating": "Calculating match...",
      "compatibility_sign_in": "Sign in to see your compatibility",
      "na": "N/A",
      "compatibility_matches": "Matched preferences:",
      "compatibility_differences": "Potential differences:",
      "compatibility_critical_differences": "Critical differences:",
      "compatibility_based_on_preferences":
          "Based on {scored} of {total} preferences",
      "group_compatibility_title": "Group compatibility:",
      "group_compatibility_subtitle": "Group of {count} people",
      "group_compatibility_target_description": "for a group of {count} people",
      "group_compatibility_full_matches": "Full matches ({count}/{total})",
      "group_compatibility_partial_matches":
          "Partially matches ({count} of {total})",
      "group_compatibility_discuss": "Worth discussing",
      "group_compatibility_value_count": "{count} — {value}",
      "group_compatibility_summary_full": "full matches",
      "group_compatibility_summary_partial": "partial",
      "group_compatibility_summary_discuss": "topics to discuss",
      "group_compatibility_summary_compact_full": "full",
      "group_compatibility_summary_compact_partial": "partial",
      "group_compatibility_summary_compact_discuss": "discuss",
      "group_profile_summary_title": "Group profile",
      "group_profile_report_title": "Group profile summary",
      "group_preference_matrix_title": "Lifestyle preference matrix",
      "group_preference_matrix_subtitle":
          "Compare all participants at a glance",
      "group_compatibility_report_title": "Group compatibility insight",
      "group_preference_matrix_preference": "Preference",
      "view_member_profiles": "Participant profiles",
      "group_member_profiles_formed": "Group complete",
      "group_find_housing": "Find housing",
      "group_continue_search": "Continue search",
      "group_search_area": "Search area",
      "group_search_area_hint":
          "Pick the districts and metro stations the whole group is searching.",
      "group_search_area_saved": "Search area updated",
      "group_search_area_empty": "Select at least one station or a district",
      "group_shortlist_title": "Housing options",
      "group_shortlist_title_count": "Housing options ({count})",
      "group_shortlist_all_options": "All options",
      "group_shortlist_chip": "Saved ({count})",
      "group_shortlist_save": "Save for group",
      "group_shortlist_save_for_group": "Save for group ({count} people)",
      "group_shortlist_added": "Added to group list",
      "group_shortlist_removed": "Removed from group list",
      "group_shortlist_empty_title": "No saved listings yet",
      "group_shortlist_empty_subtitle":
          "Browse housing offers and save options to discuss with your group",
      "group_shortlist_saved_by": "Saved by",
      "group_shortlist_saved_by_suffix": "",
      "listing_author": "Author",
      "group_shortlist_open": "Open",
      "group_shortlist_view": "View",
      "group_shortlist_open_listing": "View",
      "group_shortlist_remove": "Remove",
      "group_shortlist_saved_for_group_context": "Saved for group \"{label}\"",
      "group_shortlist_group_size_label": "{count} people",
      "group_shortlist_fits_budget_check": "Fits budget",
      "group_shortlist_above_budget_check": "Above budget",
      "group_shortlist_fit_district_named": "District: {name}",
      "group_shortlist_fit_district_unspecified": "District: not specified",
      "group_shortlist_saved_for_group": "Saved for group · {name}",
      "group_shortlist_price_per_person": "{price} / mo per person",
      "group_shortlist_fits_group_budget": "Fits group budget",
      "group_shortlist_suitable_for_group": "Suitable for group:",
      "group_shortlist_fit_budget_ok": "Budget ok",
      "group_shortlist_fit_budget_above": "Above budget",
      "group_shortlist_fit_for_people": "For {count} people",
      "group_shortlist_fit_district_ok": "District matches",
      "group_shortlist_fit_district_diff": "Different district",
      "group_shortlist_discuss_in_group": "Discuss in group",
      "group_shortlist_already_in_discussion":
          "This listing is already in the group discussion",
      "group_shortlist_ref_label": "Listing in discussion",
      "group_shortlist_ref_tap_hint": "Tap to view",
      "group_shortlist_original_not_found":
          "The original listing card isn't loaded yet",
      "group_shortlist_start_listing_discussion": "Start listing discussion",
      "group_shortlist_continue_discussion": "Continue discussion",
      "group_shortlist_discuss_message_intro":
          "What do you think about this option?",
      "messages_preview_shared_listing": "📋 Listing: {title}",
      "messages_preview_shared_listing_no_title": "📋 Shared a listing",
      "messages_preview_referenced_listing": "↪️ {title}",
      "messages_preview_referenced_listing_no_title": "↪️ Mentioned a listing",
      "group_shortlist_discuss_line_location": "📍 {location}",
      "group_shortlist_discuss_line_metro": "🚇 {station}",
      "group_shortlist_discuss_line_price": "💰 {price}",
      "group_shortlist_discuss_line_price_per_person":
          "💰 {price} / mo per person",
      "group_shortlist_discuss_line_link": "🔗 {link}",
      "group_shortlist_rating_summary": "{average} · {count} ratings",
      "group_shortlist_rating_count_summary": "{count} ratings",
      "group_shortlist_rate_prompt": "Rate this option",
      "group_shortlist_rate_cta": "Help the group choose: rate this option",
      "group_shortlist_group_rating": "Group rating",
      "group_shortlist_ai_summary_title": "AI feedback summary",
      "group_shortlist_no_ratings": "No ratings yet",
      "group_shortlist_edit_rating_title": "Edit your rating",
      "group_shortlist_dislike_reasons_title": "What did not work?",
      "group_shortlist_dislike_reason_expensive": "Too expensive",
      "group_shortlist_dislike_reason_far": "Too far",
      "group_shortlist_dislike_reason_condition": "Bad renovation",
      "group_shortlist_dislike_reason_owner": "Owner / terms",
      "group_shortlist_dislike_reason_space": "Not enough space",
      "group_shortlist_dislike_reason_neighborhood": "Bad neighborhood",
      "listing_rating_screen_title": "Rate housing option",
      "listing_rating_screen_subtitle":
          "Your opinion will help the group make a decision",
      "listing_rating_category_price": "Price",
      "listing_rating_category_price_subtitle":
          "Fits the budget, price is fair",
      "listing_rating_category_location": "Location",
      "listing_rating_category_location_subtitle":
          "Close to study/work, transport, area",
      "listing_rating_category_condition": "Housing condition",
      "listing_rating_category_condition_subtitle":
          "Renovation, cleanliness, furniture, kitchen, bathroom",
      "listing_rating_category_group": "Group convenience",
      "listing_rating_category_group_subtitle":
          "Enough space, layout, private space",
      "listing_rating_category_landlord": "Terms and landlord",
      "listing_rating_category_landlord_subtitle": "Rules, trust in the owner",
      "listing_rating_label_excellent": "Excellent",
      "listing_rating_label_good": "Good",
      "listing_rating_label_normal": "Normal",
      "listing_rating_label_bad": "Bad",
      "listing_rating_verdict_title": "Final verdict",
      "listing_rating_verdict_subtitle":
          "Do you want to move forward with this option?",
      "listing_rating_verdict_yes": "Yes,\nfits",
      "listing_rating_verdict_maybe": "Maybe\nconsider",
      "listing_rating_verdict_no": "No,\ndoesn't fit",
      "listing_rating_reasons_title": "What bothers you?",
      "listing_rating_optional": "optional",
      "listing_rating_submit": "Submit rating",
      "listing_rating_participants_summary": "Rated by group participants",
      "group_shortlist_rating_updated": "Rating updated",
      "group_shortlist_contact_landlord": "Invite landlord to chat",
      "group_landlord_invite_revoke": "Revoke invitation",
      "group_landlord_invite_sent":
          "Invite sent. The landlord will only see new messages after joining.",
      "group_landlord_invite_revoked": "Invitation revoked",
      "group_landlord_invite_dialog_title": "Join group chat?",
      "group_landlord_invite_dialog_message":
          "You were invited to discuss this listing with the group. You will only see messages sent after you join.",
      "group_landlord_invite_accept": "Join chat",
      "group_landlord_invite_decline": "Decline",
      "group_landlord_invite_accepted": "You joined the group chat",
      "group_landlord_invite_declined": "Invite declined",
      "group_landlord_invite_chat_card_title": "Group chat invite",
      "group_landlord_invite_chat_card_body":
          "The group owner invited you to discuss this listing with their group. You will only see messages sent after you join.",
      "group_landlord_invite_one_at_a_time":
          "A landlord is already connected to this group chat, or an invite is still pending. Revoke the current invite or finish that discussion before inviting another landlord.",
      "group_shortlist_remove_title": "Remove from saved list?",
      "group_shortlist_remove_message":
          "{title} will be removed from the group saved list.",
      "group_shortlist_remove_confirm": "Remove",
      "group_housing_fits_budget": "Fits group budget",
      "group_housing_above_budget": "Above group budget",
      "group_housing_search_banner": "Group of {count} · up to {budget}/person",
      "group_housing_search_empty": "No matching housing offers found",
      "group_member_role_owner": "Organizer",
      "group_member_role_you": "You",
      "group_member_role_member": "Member",
      "group_member_compat_match": "Match",
      "group_member_compat_difference": "Difference",
      "group_member_compat_dealbreaker": "Conflict",
      "group_remove_member": "Remove from group",
      "group_remove_member_title": "Remove from group?",
      "group_remove_member_message":
          "{name} will lose access to the group chat. A spot will open for a new member.",
      "group_remove_reason_title": "Reason (optional)",
      "group_remove_reason_inactive": "Inactive",
      "group_remove_reason_rules": "Broke rules",
      "group_remove_reason_not_fit": "Not a fit",
      "group_remove_reason_member_request": "Member requested",
      "group_remove_reason_other": "Other",
      "group_remove_reason_other_hint": "Add a short reason",
      "group_remove_member_success": "Member removed from the group",
      "group_leave_group": "Leave group",
      "group_leave_group_title": "Leave group?",
      "group_leave_group_message":
          "You will lose access to the group chat. A spot will open for a new member.",
      "group_leave_group_success": "You left the group",
      "vs": "vs",
      "name": "Name or nickname",
      "im_from": "I'm from:",

      // ===== APP CORE =====
      "user": "User",
      "welcome_title": "Welcome to UyDosh",
      "welcome_subtitle": "Find your perfect roommate or accommodation",
      "splash_subtitle": "LET'S LIVE TOGETHER!",
      "search_results": "Search Results",
      "search_refresh_this_area": "Refresh this area",
      "open_map_view": "Open map view",
      "open_feed_view": "Open feed view",
      "close": "Close",
      "cancel": "Cancel",
      "done": "Done",
      "about_uy_dosh": "About UyDosh",
      "user_license_agreement_title": "User License Agreement",

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

      "error_generic_try_again": "An error occurred. Please try again.",
      "error_unable_to_complete_try_again":
          "Unable to complete the request. Please try again.",
      "error_no_internet":
          "No internet connection. Please check your network settings.",
      "error_timeout_check_connection":
          "Request timed out. Please check your internet connection and try again.",
      "error_server_try_later": "Server error. Please try again later.",
      "error_service_unavailable_try_later":
          "Service temporarily unavailable. Please try again later.",
      "error_invalid_request":
          "Invalid request. Please check your input and try again.",
      "error_auth_required": "Authentication required. Please log in again.",
      "error_access_denied":
          "Access denied. You don't have permission to perform this action.",
      "error_not_found": "The requested resource was not found.",
      "error_conflict":
          "This resource already exists or conflicts with current data.",
      "error_invalid_data": "Invalid data provided. Please check your input.",
      "error_too_many_requests":
          "Too many requests. Please wait a moment and try again.",
      "error_request_cancelled": "Request was cancelled.",
      "error_internet_connection": "Check your internet connection",
      "error_resource_conflict":
          "You have already complained about this listing.",

      // ===== MESSAGING =====
      "conversations": "Messages",
      "messages": "Messages",
      "chat": "Chat",
      "chat_security_ribbon_title": "Protected chat",
      "chat_security_ribbon_body":
          "This chat is protected by AI anti‑fraud & scam filters to help keep you safe.",
      "chat_safety_warning_title_medium": "Safety notice",
      "chat_safety_warning_title_high": "Be careful",
      "chat_safety_warning_fallback":
          "This conversation may contain scam/fraud signals. Be cautious with links, codes, and payment requests.",
      "chat_safety_reason_deposit_to_reserve_room":
          "The user is asking for a deposit to reserve the room.",
      "chat_safety_reason_suspicious_link":
          "The user is sharing a suspicious link.",
      "chat_safety_reason_off_platform":
          "The user is trying to move the conversation off-platform.",
      "chat_safety_reason_otp_code":
          "The user is asking for a verification code (OTP/SMS).",
      "chat_safety_reason_payment_request":
          "The user is requesting prepayment or payment details.",
      "chat_safety_sheet_why_title": "Why this message was flagged",
      "chat_safety_sheet_copy": "Copy message",
      "chat_safety_sheet_report": "Report",
      "chat_safety_sheet_close": "Close",
      "chat_safety_sheet_copied": "Copied",
      "profile_interlocutor": "Interlocutor's Profile",
      "view_listing": "View Listing",
      "view_group": "View Group",
      "chat_menu_translate_to": "Translate to…",
      "chat_menu_show_original": "Show original messages",
      "chat_menu_show_translated": "Show translated messages",
      "admin_delete_conversation": "Delete conversation for everyone",
      "admin_delete_conversation_confirmation":
          "This removes the chat from both users' inboxes and ends the thread for them. Continue?",
      "admin_delete_conversation_success": "Conversation removed",
      "admin_delete_conversation_error": "Could not remove the conversation",
      "admin_listing_owner_conversations_card_title": "Listing chats (admin)",
      "admin_listing_owner_conversations_card_subtitle":
          "See every in-app conversation between guests and this listing's owner.",
      "admin_listing_owner_conversations_screen_title": "Chats on this listing",
      "admin_listing_owner_conversations_empty":
          "No listing chats in the app yet.",
      "admin_listing_owner_conversations_error":
          "Could not load chats for this listing.",
      "admin_listing_owner_conversations_retry": "Try again",
      "admin_listing_owner_conversations_closed_badge": "Closed",
      "chat_translate_picker_title": "Translate this chat to",
      "chat_translate_picker_auto": "Auto (use my language)",
      "chat_translating": "Translating…",
      "chat_translation_quota_exceeded":
          "You've used all free chat translations this month. Upgrade via Payme or Click for more.",
      "menu_messages": "Messages",
      "menu_notifications": "Notifications",
      "menu_enable_notifications": "Enable notifications",
      "notifications_alert_match_header":
          "You will receive a push notification to:",
      "notifications_alert_match_header_paused":
          "Paused — no push notifications for:",
      "notifications_push_off_title": "Push alerts are turned off {where}.",
      "notifications_push_off_where_ios": "on iOS",
      "notifications_push_off_where_android": "on Android",
      "notifications_push_off_where_chrome": "in Chrome",
      "notifications_push_off_where_safari": "in Safari",
      "notifications_push_off_where_firefox": "in Firefox",
      "notifications_push_off_where_edge": "in Edge",
      "notifications_push_off_where_browser": "in this browser",
      "notifications_push_off_where_device": "on this device",
      "inbox_push_off_banner_title":
          "Turn on notifications so you don't miss new messages",
      "notifications_enabled": "Notifications enabled",
      "notifications_enable_in_settings":
          "Please enable notifications in Settings",
      "notifications_appbar_semantics_active_alerts": "Active search alerts",
      "notifications_empty": "No saved alerts yet.",
      "notifications_alerts_explainer":
          "Here are your alerts.\nAs soon as matching housing or a neighbor appears, we'll let you know right away.",
      "notifications_alerts_explainer_enabled":
          "Notifications are enabled.\n\nHere are your alerts. As soon as matching housing or a neighbor appears — we'll send you a push notification.",
      "notifications_open_settings": "Open settings",
      "notifications_disable_all": "Disable all notifications",
      "notifications_delete_all": "Delete all notifications",
      "notifications_disable_all_title": "Disable all notifications?",
      "notifications_disable_all_message":
          "This will turn off all saved search alerts. You can enable them again later.",
      "notifications_delete_all_title": "Delete all notifications?",
      "notifications_delete_all_message":
          "This will permanently delete all saved search alerts. This action cannot be undone.",
      "disable": "Disable",
      "enable": "Enable",
      "type_message": "Type a message...",
      "conversation_created": "Conversation started",
      "conversation_failed": "Failed to start conversation",
      "error_listing_chat_disabled":
          "In-app chat is unavailable for this listing",
      "no_conversations": "No conversations yet",
      "no_messages": "No messages yet",
      "no_messages_description":
          "You haven't received any messages about your listings yet",
      "mark_as_read": "Mark as read",
      "archive": "Archive",
      "unarchive": "Unarchive",
      "archived": "Archived",
      "archived_chats": "Archived chats",
      "archived_chats_tip":
          "Long-press an archived chat to see actions, or swipe left to unarchive.",
      "grouped_chats_expand_coach_hint":
          "Tap the card header (or chevron) to expand or collapse chats about the same listing.",
      "no_archived_conversations": "No archived chats",
      "no_archived_conversations_description":
          "Chats you archive will appear here",
      "chat_archived": "Chat archived",
      "chat_unarchived": "Chat moved back to inbox",
      "chat_edit_message_title": "Edit message",
      "chat_edit_message_save": "Save",
      "chat_edit_message_cancel": "Cancel",
      "chat_edit_message_once_only":
          "You’ve already used your one edit on this message.",
      "chat_edit_hold_already_edited_toast":
          "You can only change a message once—and you’ve already saved your edit.",
      "chat_message_edited_label": "Edited",
      "chat_replying_to": "Replying to {name}",
      "chat_reply_cancel": "Cancel reply",
      "chat_reply_sender_you": "You",
      "chat_reply_sender_unknown": "Message",
      "chat_reply_attachment_fallback": "Attachment",
      "chat_scroll_to_bottom": "Scroll to latest message",
      "archive_failed_has_unread":
          "Can't archive: this chat has unread messages",
      "undo": "Undo",
      "error_not_authenticated": "Please log in to start a conversation",
      "error_cannot_message_self": "You cannot message yourself",
      "start_conversation_from_listing":
          "Start a conversation from a listing to begin messaging",
      "today": "Today",
      "yesterday": "Yesterday",
      "tomorrow": "Tomorrow",
      "in_days": "In {days} days",
      "in_days_one": "In {count} day",
      "in_days_other": "In {count} days",
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
      "quick_question_total_price":
          "What is the total price including utilities?",
      "quick_question_can_visit_soon": "Can I come to see it soon?",
      "quick_question_roommate_still_searching":
          "Are you still looking for a roommate?",
      "quick_question_roommate_move_in_date": "When would someone move in?",
      "quick_question_roommate_household": "Who lives in the flat now?",
      "quick_question_roommate_rent_terms": "How do rent and bills work?",
      "quick_question_roommate_meet_soon": "Could we chat or meet soon?",
      "quick_question_seeker_move_in_when": "When do you want to move in?",
      "quick_question_seeker_budget": "What is your budget?",
      "quick_question_seeker_how_long": "How long are you looking to rent?",
      "quick_question_seeker_about_you": "Could you tell me about yourself?",
      "quick_question_generic_price": "How much does it cost?",
      "quick_question_generic_whats_included": "What's included in the price?",
      "quick_question_generic_when_available": "When are you available?",
      "quick_question_generic_how_soon": "How soon can we start?",
      "quick_question_generic_arrangement":
          "How would you like to arrange this?",
      "quick_question_generic_clarify_details": "Can we clarify the details?",
      "quick_question_offerer_scope": "What exactly do you need done?",
      "quick_question_offerer_deadline": "When do you need this done by?",
      "quick_question_offerer_where": "Where should this take place?",
      "quick_question_offerer_budget": "What budget did you have in mind?",
      "quick_question_offerer_materials":
          "Will you provide materials, or should I?",
      "quick_question_offerer_visit":
          "Can we schedule a short call or visit to assess?",
      "private_room": "Private Room",
      "with_photo": "With photo",
      "search_filter_private_room": "Own room",
      "search_filter_with_photo": "Photos",
      "conversation_count": "conversation",
      "conversations_count": "conversations",
      "conversations_count_one": "{count} conversation",
      "conversations_count_other": "{count} conversations",
      "incoming": "Incoming",
      "outgoing": "Outgoing",
      "no_incoming_conversations": "No incoming conversations",
      "no_outgoing_conversations": "No outgoing conversations",
      "no_incoming_conversations_description":
          "You haven't received any messages about your listings yet",
      "retry": "Retry",
      "back_to_listing": "Back to listing",
      "load_more": "Load More",

      "error_generic": "An error occurred",
      "error_loading_regions": "Error loading regions: {error}",
      "error_loading_universities": "Error loading universities: {error}",
      "error_creating_listing": "Error creating listing. Please try again.",
      "error_updating_listing": "Error updating listing",
      "error_uploading_photos": "Error uploading photos",
      "error_reordering_photos":
          "Couldn't update the main photo. Please try again.",
      "error_deactivating_listing": "Error deactivating listing",
      "error_creating_profile": "Error creating profile: {error}",
      "error_updating_profile": "Error updating profile: {error}",
      "error_opening_edit_screen": "Error opening edit screen: {error}",
      "error_with_message": "Error: {message}",
      "image_load_error": "Failed to load image",

      // ===== SUCCESS MESSAGES =====
      "listing_created_success": "Listing created successfully!",
      "listing_updated_success": "Listing updated successfully",
      "room_scan_title": "3D room scan",
      "room_scan_instructions":
          "Before starting the 3D scan\n\n• Turn on good lighting\n• Move slowly, avoid sudden movements\n• Hold your phone at chest level\n• Scan walls, corners, windows, and doors\n• Try to cover the whole room\n\nThis will help create an accurate 3D model of your home",
      "room_scan_start": "Start scan",
      "room_scan_finish": "Finish",
      "room_scan_scan_other_rooms": "Scan Other Rooms",
      "room_scan_uploading": "Uploading…",
      "room_scan_success": "3D scan saved",
      "room_scan_cancelled": "No scan was captured. Tap Start to try again.",
      "room_scan_error": "Could not save scan. Try again.",
      "room_scan_too_large":
          "3D scan is too large to upload. Please try scanning a smaller area.",
      "room_scan_not_supported":
          "3D room scan requires an iPhone or iPad with LiDAR.",
      "room_scan_camera_required":
          "3D scan needs camera access. If you chose Don't Allow, turn on the camera for UyDosh in Settings.",
      "room_scan_disabled_globally":
          "3D room scanning is turned off in app settings. It may be available again later.",
      "add_room_scan_3d": "Add 3D room scan",
      "replace_room_scan_3d": "Replace 3D room scan",
      "skip": "Skip",
      "view_room_3d": "View 3D room",
      "room_3d_open_error": "Could not open 3D model. Check your connection.",
      "room_3d_viewer_title": "3D",
      "room_3d_dimensions_caption": "Approximate dimensions",
      "room_3d_dimensions_line1_template":
          "Dimensions: {floorLong} × {floorShort} m",
      "room_3d_dimensions_height_template": "Height: {height} m",
      "room_3d_dimensions_line2_template": "Area: ~{floorArea} m²",
      "room_3d_load_error_title": "Could not load 3D model",
      "room_3d_floor_only_button": "Hide walls",
      "room_3d_full_room_button": "Full room",
      "room_3d_floor_only_unavailable":
          "No wall meshes were found by name in this file. Walls must be separate labeled objects in the 3D export.",
      "room_3d_zoom_in": "Zoom in",
      "room_3d_zoom_out": "Zoom out",
      "room_3d_view_mode_label": "3D view mode",
      "room_3d_view_mode_hint":
          "Switch between full room, walls only, and floor with furniture.",
      "room_3d_materials_style_label": "Materials style",
      "room_3d_materials_style_hint":
          "Toggle between real materials and stylized colors.",
      "room_3d_materials_style_value_stylized": "Stylized",
      "room_3d_materials_style_value_real": "Real",
      "room_3d_tab_view_3d": "3D",
      "room_3d_tab_floor_plan": "2D",
      "room_3d_floor_plan_reset": "Reset",
      "room_3d_floor_plan_dimensions_overall": "Overall",
      "room_3d_floor_plan_dimensions_walls": "Wall dims",
      "room_3d_floor_plan_dimensions_hide": "Hide dims",
      "room_3d_floor_plan_show_objects": "Objects",
      "room_3d_floor_plan_hide_objects": "Hide objects",
      "room_3d_floor_plan_show_grid": "Grid",
      "room_3d_floor_plan_hide_grid": "Hide grid",
      "room_3d_floor_plan_auto_align_on": "Auto-align",
      "room_3d_floor_plan_auto_align_off": "Scan angle",
      "room_3d_floor_plan_adjust_north": "North",
      "room_3d_floor_plan_adjust_north_title": "Adjust north",
      "room_3d_floor_plan_adjust_north_message":
          "Rotate if the compass does not match reality. Range ±180°.",
      "room_3d_floor_plan_adjust_north_reset": "Reset to scan",
      "room_3d_floor_plan_adjust_north_updated": "North orientation updated",
      "room_3d_floor_plan_adjust_north_degrees_format": "%+.0f°",
      "room_3d_floor_plan_edit_dimension_title": "Edit dimension",
      "room_3d_floor_plan_edit_dimension_current": "Current",
      "room_3d_floor_plan_edit_dimension_new_value": "New value (m)",
      "room_3d_floor_plan_edit_dimension_cancel": "Cancel",
      "room_3d_floor_plan_edit_dimension_apply": "Apply",
      "room_3d_floor_plan_edit_dimension_updated": "Dimension updated",
      "room_3d_floor_plan_edit_dimension_large_change_title": "Large change",
      "room_3d_floor_plan_edit_dimension_large_change_message":
          "New value differs significantly from the scanned measurement. Apply correction?",
      "room_3d_floor_plan_edit_dimension_invalid_title": "Invalid value",
      "room_3d_floor_plan_edit_dimension_invalid_message":
          "Enter a number between 0.5 and 100 meters.",
      "room_3d_floor_plan_edit_dimension_confirm_large_change": "Apply",
      "room_3d_floor_plan_unit_meters": "meters",
      "room_3d_floor_plan_object_bed": "Bed",
      "room_3d_floor_plan_object_sofa": "Sofa",
      "room_3d_floor_plan_object_table": "Table",
      "room_3d_floor_plan_object_chair": "Chair",
      "room_3d_floor_plan_object_storage": "Storage",
      "room_3d_floor_plan_object_appliance": "Appliance",
      "room_3d_floor_plan_object_cabinet": "Cabinet",
      "room_3d_floor_plan_object_television": "TV",
      "room_3d_floor_plan_object_fixture": "Fixture",
      "room_3d_floor_plan_object_unknown": "Object",
      "room_3d_sun_toggle_label": "Sunlight",
      "room_3d_sun_toggle_hint": "Show or hide sun simulation controls",
      "room_3d_sun_azimuth_label": "Azimuth",
      "room_3d_sun_elevation_label": "Elevation",
      "room_3d_sun_intensity_label": "Intensity",
      "room_3d_sun_preset_morning": "Morning",
      "room_3d_sun_preset_noon": "Noon",
      "room_3d_sun_preset_evening": "Evening",
      "room_3d_sun_today": "Today",
      "room_3d_sun_now": "Now",
      "room_3d_sun_azimuth_format": "Az %d°",
      "room_3d_sun_elevation_format": "El %d°",

      "profile_completed_success": "Profile completed successfully!",
      "profile_updated_success": "Profile updated successfully",
      "auth_terms_finish_header": "Almost Done",
      "auth_terms_finish_title": "Review the terms",
      "auth_terms_finish_body":
          "By continuing, you agree to UyDosh's Terms of Use, Privacy Policy, and Community Rules.",
      "view_terms_of_service": "View Terms of Use",
      "could_not_open_terms_of_service":
          "Could not open the Terms of Use. Please try again.",

      "successfully_signed_in_google": "Successfully signed in with Google!",
      "successfully_signed_in_apple": "Successfully signed in with Apple!",
      "successfully_signed_in_telegram":
          "Successfully signed in with Telegram!",

      // ===== EMPTY STATES =====
      "my_listings_empty_state": "You haven't created any listings yet.",

      "no_locations_available": "No locations available",

      "no_universities_available": "No universities available",
      "no_results": "No results",
      "no_search_results": "No results...",

      // ===== SELECTION & PROMPTS =====
      "select_metro_line": "Subway line",
      "select_metro_line_title": "Select\nsubway line",
      "metro_line_abbr": "ln.",
      "metro_station_abbr": "st.",
      "select_location": "Any district",
      "not_selected": "Not selected",
      "all": "All",

      "all_stations_count": "All {count} stations",
      "all_stations_count_one": "All {count} station",
      "all_stations_count_other": "All {count} stations",
      "stations_count_one": "{count} station",
      "stations_count_other": "{count} stations",
      "all_stations_explanation":
          "Search along the entire line <b>{line}</b> through <b>{count}</b> stations",
      "entire_line_stations": "Entire line {line}: {count} stations",
      "entire_line_stations_one": "Entire line {line}: {count} station",
      "entire_line_stations_other": "Entire line {line}: {count} stations",
      "metro_tutorial_line_hint": "Search listings on all metro line stations",
      "metro_tutorial_station_hint": "Search by particular metro stations",
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
      "country": "Country",
      "city": "City",
      "select_country": "Select country",
      "tap_to_select_country": "Tap to select country",
      "no_regions_for_country": "No regions available for this country yet",

      // ===== ACTION BUTTONS =====
      "refresh": "Refresh",
      "actions": "Actions",

      "view_profile": "Profile",
      "deactivate_listing": "Deactivate",
      "deactivate_listing_confirmation":
          "Are you sure you want to deactivate this listing? It will no longer be visible to other users.",
      "deactivate": "Deactivate",
      "activate_listing": "Activate Listing",
      "activate_listing_confirmation":
          "Are you sure you want to activate this listing? It will become visible to other users.",
      "activate": "Activate",
      "listing_active": "Active",
      "listing_inactive": "Inactive",

      "create_listing_button": "Create Listing",
      "wizard_step_counter": "Step {current} of {total}",
      "wizard_step_basics": "Basics",
      "wizard_step_location": "Location",
      "wizard_step_details": "Details",
      "wizard_step_description": "Description",
      "wizard_step_review": "Review",
      "wizard_next": "Next",
      "wizard_back": "Back",
      "wizard_review_subtitle": "Check everything looks right, then publish.",
      "wizard_review_not_set": "Not set",
      "wizard_amenities_count": "{count} selected",
      "wizard_photos_count": "{count} added",
      "wizard_metro_value": "Line {line} · {station}",
      "wizard_add_station": "Add station",
      "wizard_stations_hint":
          "Pick a line and station, then add it. You can add several.",
      "wizard_selected_stations": "Selected stations",
      "wizard_stations_count": "{count} stations",
      "wizard_station_already_added": "That station is already added",
      "wizard_location_mode_metro": "By metro",
      "wizard_location_mode_district": "By district",
      "all_locations_count": "All {count} districts",
      "wizard_locations_count": "{count} districts",
      "districts_count_one": "{count} District",
      "districts_count_other": "{count} Districts",
      "update_listing_button": "Update Listing",
      "save_changes": "Save Changes",
      "changed_fields": "Changed",
      "unsaved_changes_title": "Unsaved changes",
      "unsaved_changes_message":
          "You have unsaved changes. If you leave now, they will be lost.",
      "keep_editing": "Continue",
      "leave_without_saving": "Leave",
      "publish_consent_title": "Before you post",
      "publish_consent_body":
          "Please follow UyDosh Community Rules. Do not post fake listings, scam offers, illegal content, offensive content, private documents, or someone else's photos without permission.",
      "publish_consent_checkbox":
          "I agree to UyDosh Terms of Use and Community Rules",
      "publish_consent_continue": "Continue",

      "confirm": "Confirm",
      "next": "Next",
      "back": "Back",
      "finish": "Finish",

      "complete": "Complete",

      // ===== THEME & APPEARANCE =====
      "settings": "Settings",
      "settings_section_account": "Account",
      "settings_section_preferences": "Preferences",
      "settings_section_experience": "Experience",
      "settings_section_about": "About",
      "settings_section_legal": "Legal",
      "theme": "Theme",
      "system_theme": "System",
      "blue_theme": "Blue",
      "light_theme": "Light",
      "theme_changed_to": "Theme changed to {theme}",
      "theme_color": "Theme color",
      "switch_theme": "Switch Theme",
      "tooltips_toggle": "Tips",
      "tooltips_toggle_description": "Show helpful hints and tooltips",

      // ===== ABOUT & FEATURES =====
      "about_description":
          "UyDosh is your trusted platform for finding the perfect home in Tashkent.",
      "about_feature_1": "• Browse listings by metro station",
      "about_feature_2": "• Search by district",
      "about_feature_3": "• Direct contact with property owners",
      "about_feature_4": "• Verified and safe listings",

      // ===== METRO SYSTEM =====
      "open_in_yandex_maps": "Open in Yandex Maps",
      "open_in_yandex_maps_confirmation":
          "A browser with Yandex Maps will be opened.",

      // ===== LISTING DETAILS =====
      "listing_details": "Details",
      "listing_detail_id": "Listing ID: {id}",
      "author": "Author",
      "listing_views_by_others": "{count} views",
      "listing_views_count_one": "{count} view",
      "listing_views_count_other": "{count} views",
      "listing_views_stats_title": "View statistics",
      "listing_views_stats_empty": "No views yet",
      "error_loading_view_stats": "Error loading view statistics",
      "promote_listing": "Boost to top",
      "remove_from_top": "Remove from top",
      "feature_listing_success": "Listing moved to top",
      "unfeature_listing_success": "Listing removed from top",
      "feature_listing_error": "Failed to update listing",
      "error_promotion_once_per_week":
          "You can only promote a listing once per week",

      "listing_title_label": "Title",

      "listing_description_hint": "Enter listing text",
      "listing_description_label": "Description",
      "listing_address_field_label": "Address:",
      "listing_address_text_label": "Address (optional)",
      "use_current_location": "Use current location",
      "location_services_disabled":
          "Location services are off. Turn them on to use current location.",
      "location_permission_denied":
          "Location permission is required to use current location.",
      "current_location_address_failed":
          "Could not determine the address from your current location.",
      "listing_title_hint": "Enter listing title",
      "view_similar_results": "View similar",
      "listing_detail_nearby_room_offers": "Find housing",
      "listing_detail_nearby_room_seekers": "People looking nearby",
      "listing_detail_nearby_matches": "Matches nearby",
      "listing_detail_nearby_stores_title": "Stores nearby",
      "listing_detail_nearby_stores_subtitle":
          "Grocery options close to this home.",
      "listing_detail_nearby_stores_meters": "m",
      "listing_detail_nearby_stores_kilometers": "km",
      "coming_soon": "Coming soon",
      "listing_price_label": "Price",
      "listing_translate_tooltip_en": "Translate to English",
      "listing_translate_tooltip_ru": "Translate to Russian",
      "listing_translate_tooltip_uz": "Translate to Uzbek",
      "listing_show_original_description": "Original",
      "listing_translating_description": "Translating…",
      "listing_translation_error": "Couldn’t translate. Try again.",
      "listing_translation_unavailable": "Translation unavailable.",
      "listing_translation_quota_exceeded":
          "You’ve used all free listing translations this month. Upgrade via Payme or Click for more.",
      "listing_translation_sign_in_required":
          "Sign in to translate listing descriptions.",
      "listing_ai_enhance_quota_exceeded":
          "You’ve used all free AI improvements this month. Upgrade via Payme or Click for more.",
      "chat_translated_from_en": "Translated from 🇺🇸",
      "chat_translated_from_ru": "Translated from 🇷🇺",
      "chat_translated_from_uz": "Translated from 🇺🇿",
      "chat_show_original": "Show original",
      "chat_show_translation": "Show translation",
      "listing_ai_enhance": "Improve with AI",
      "listing_ai_enhance_empty": "Enter text first.",
      "listing_ai_enhance_unavailable":
          "AI enhancement isn’t available on this device.",
      "listing_ai_enhance_error": "Couldn’t improve the text. Try again.",
      "listing_description_dictate": "Dictate",
      "listing_description_character_count": "Characters: ",
      "listing_description_dictate_mic_denied":
          "Microphone access is needed to dictate.",
      "listing_description_dictate_failed":
          "Couldn’t transcribe speech. Try again.",
      "listing_description_dictate_not_configured":
          "Speech transcription isn’t available yet. Try again later.",
      "ai_allowance_banner_title": "AI assistant usage",
      "ai_allowance_meter_translate":
          "Listing translations left (UTC month): {count}",
      "ai_allowance_meter_enhance": "AI listing improvements left: {count}",
      "ai_allowance_meter_chat": "Chat translations left: {count}",
      "ai_allowance_meter_unlimited": "Unlimited",
      "ai_allowance_premium_active_until": "AI Premium active until {date}",
      "ai_allowance_month_reset_note":
          "Limits reset each calendar month (UTC).",
      "ai_allowance_upgrade_cta": "Learn about Premium",
      "ai_quota_exceeded_sheet_title": "Monthly AI limit reached",
      "ai_quota_exceeded_sheet_body":
          "You’ve used your allowance for this period. Premium adds higher monthly limits. Limits reset on the 1st of each month (UTC).",
      "ai_quota_exceeded_sheet_dismiss": "OK",
      "ai_premium_placeholder_title": "AI Premium",
      "ai_premium_placeholder_body":
          "In-app checkout for AI Premium (Payme / Click) will be available here soon.",
      "ai_allowance_inline_chat_hint":
          "Chat translations left this month (UTC): {count}",
      "listing_description_template_label": "Template",
      "listing_description_template_room_needed":
          "Looking for a room/flatshare.\nFormat: (private/shared).\nTimeline: (move-in + duration).\nMust-haves: (quiet/guests/pets).",
      "listing_description_template_roommate_needed_male":
          "Looking for a male roommate.\nFormat: (1–2 per room).\nWho lives there: (how many people).\nConditions: (with/without landlord), (private/shared room).\nTimeline: (move-in + duration).",
      "listing_description_template_roommate_needed_female":
          "Looking for a female roommate.\nFormat: (1–2 per room).\nWho lives there: (how many people).\nConditions: (with/without landlord), (private/shared room).\nTimeline: (move-in + duration).",
      "listing_description_template_group_forming":
          "Forming a group to rent together.\nLooking for: (1–2 people, gender/age).\nBudget per person: (amount).\nArea/metro: (where to search).\nFormat: (private/shared rooms).\nMove-in: (date + duration).\nImportant: (cleanliness/quiet/guests/pets).",

      "listing_type_roommate_needed": "Looking for a Roommate",
      "listing_type_roommate_needed_female": "Need Roommate",
      "listing_type_room_needed": "Looking for Housing",
      "listing_type_label": "Listing type",
      "listing_type_short_roommate_needed": "Looking for roommate",
      "listing_type_short_roommate_needed_female": "Looking for roommate",
      "listing_type_short_room_needed": "Looking for room",
      "listing_type_short_group_forming": "Forming Group",
      "gender_short_male": "Male",
      "gender_short_female": "Female",
      "gender_badge_male": "Guy",
      "gender_badge_female": "Girl",
      "listing_photo_coming_soon": "Photo soon",
      "price_unit_uzs_per_month": "UZS/mo",
      "price_unit_usd_per_month": "\$/mo",
      "title_male_roommate": "#NeedRoommate",
      "title_female_roommate": "#NeedRoommate",
      "title_male_room": "#NeedRoom",
      "title_female_room": "#NeedRoom",
      "listing_photos_label": "Photos",
      "listing_photos_count": "Photos {current} / {max}",

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
      "drag_photo_to_reorder": "Drag to reorder. First photo is primary.",
      "make_photo_primary": "Make primary",
      "making_primary": "Making primary...",
      "add_photo": "Add Photo",
      "take_photo": "Take Photo",
      "choose_from_gallery": "Choose from Gallery",
      "photo_limit_reached": "Maximum {max} photos allowed",
      "retake": "Retake",
      "use_photo": "Use Photo",
      "flash": "Flash",
      "camera_unavailable": "Camera is unavailable",
      "error_picking_photo": "Couldn't pick the photo",
      "upload_profile_photo": "Upload profile photo",
      "profile_photo_updated": "Profile photo updated",
      "error_uploading_profile_photo": "Couldn't upload profile photo",
      "crop_profile_photo": "Crop photo",
      "crop_listing_photo": "Crop photo",
      "crop_done": "Done",
      "crop_cancel": "Cancel",
      "crop_rotate_left": "Rotate left",
      "crop_rotate_right": "Rotate right",
      "crop_aspect_free": "Free",

      // Permission rationale screens
      "permission_camera_title": "Take listing photos",
      "permission_camera_body":
          "UyDosh needs camera access so you can capture listing photos right inside the app. We add the UyDosh watermark automatically so your photos can't be reused on other listings.",
      "permission_camera_room_scan_title": "3D room scan",
      "permission_camera_room_scan_body":
          "UyDosh needs camera access to capture a LiDAR room scan. The 3D model is uploaded to your listing so people can understand the space before they visit.",
      "permission_camera_cta": "Allow camera access",
      "permission_camera_denied_title": "Camera access is off",
      "permission_camera_denied_body":
          "Camera access was turned off in iOS Settings. Open Settings to turn it back on, or pick a photo from your gallery instead.",
      "permission_camera_open_settings": "Open Settings",
      "permission_camera_use_gallery": "Use gallery instead",
      "permission_notifications_title": "Get instant alerts",
      "permission_notifications_body":
          "Turn on notifications to know the moment a new listing matches your saved search, and to get a ping when someone messages you about your listing.",
      "permission_notifications_cta": "Turn on notifications",
      "permission_notifications_denied_body":
          "Notifications are turned off in iOS Settings. Open Settings to turn them on so search alerts can reach you.",
      "permission_not_now": "Not now",
      "permission_skip": "Skip",
      "crop_undo": "Undo",
      "crop_aspect_ratio": "Aspect ratio",

      "max_photos_reached": "Maximum photos reached",
      "max_photos_message":
          "You can only upload up to {max} photos. Please remove some photos before adding new ones.",

      "ok": "OK",
      "delete": "Delete",

      // ===== ONBOARDING =====
      "onboarding_title_1": "Find Your People",
      "onboarding_subtitle_1":
          "Verified neighbors, honest listings\nand shared rentals without outsiders.",
      "onboarding_title_2": "Search Where It Is Convenient to Live",
      "onboarding_subtitle_2":
          "Choose a metro station, district, or university —\nwe will show suitable apartments and neighbors nearby.",
      "onboarding_title_3": "Search by District",
      "onboarding_subtitle_3": "Convenient search by districts of Tashkent",
      "onboarding_title_4": "No Realtors or Strangers",
      "onboarding_subtitle_4":
          "We are building an honest community:\nverified profiles, complaints, and protection from scammers.",

      "onboarding_get_started": "Get Started",
      "onboarding_skip": "Skip",
      "onboarding_next": "Next",
      "onboarding_back": "Back",
      "onboarding_toggle": "Onboarding",
      "onboarding_toggle_description": "Show welcome screens",
      "haptic_feedback": "Haptic feedback",
      "haptic_feedback_description": "Vibration for taps and gestures",
      "restore_filters_on_start": "Restore filters on app start",
      "restore_filters_on_start_description":
          "Re-apply your last search filters when the app launches. Turn off to start with a clean search each time.",
      "sound_effects": "Sound effects",
      "sound_effects_description": "Short UI sounds for actions",
      "ui_animations": "UI animations",
      "ui_animations_description": "Motion effects like pulsing and swinging",
      "ui_animations_optimized_for_device": "Optimized for this device",
      "ui_animation_search_pulse": "Search button pulse",
      "ui_animation_bell_idle": "Bell idle swing",
      "ui_animation_bell_tap": "Bell tap animation",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "English",
      "language": "Language",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_name_english": "English",
      "language_name_russian": "Russian",
      "language_name_uzbek": "Uzbek",
      "language_changed_to": "Language changed to {language}",
      "price_display_currency": "Price currency",
      "price_display_currency_national": "🇺🇿 Uzbek Sum",
      "price_display_currency_usd": "🇺🇸 US dollars (USD)",

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
      "open_in_telegram": "Telegram",
      "open_in_telegram_confirmation": "Telegram will be opened.",

      // New profile fields
      "work": "Work",
      "employed": "Employed",
      "not_employed": "Not working",
      "cleanliness": "Cleanliness",
      "noise_level": "Noise Level",
      "sociability": "Sociability",
      "guests": "Guests",
      "guests_allowed": "Guests Allowed",
      "guests_permitted": "Allowed",
      "guests_not_permitted": "Not allowed",
      "smoking_preference": "Smoking",
      "alcohol_preference": "Alcohol",
      "cooking_habits": "Cooking",
      "pets_preference": "Pets Preference",
      "wakeup_time": "Wake-up Time",
      "sleep_time": "Sleep Time",
      "sleep_schedule": "Sleep schedule",

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
      "pets_like_pets": "Like pets",
      "pets_dont_like_pets": "Don't like pets",
      "pets_have_cat": "Have a cat",
      "pets_have_dog": "Have a dog",

      // Slider labels
      "lifestyle_preferences": "Lifestyle",
      "what_im_looking_for": "What I'm looking for",
      "what_im_looking_for_subtitle": "Used to better match you with roommates",
      "preferred_roommate_gender": "Preferred roommate gender",
      "any_gender": "Any",
      "your_birth_year": "Your year of birth",
      "birth_year_hint": "e.g. 2000",
      "desired_age_range": "Preferred roommate age",
      "age_from_hint": "From",
      "age_to_hint": "To",
      "your_budget_range": "Your monthly budget",
      "budget_from_hint": "From",
      "budget_to_hint": "To",
      "require_budget_overlap": "Budgets must overlap",
      "dealbreakers_label": "Dealbreakers",
      "dealbreakers_hint": "Non-negotiable — a mismatch here drops the match",
      "top_priorities_label": "Top priorities",
      "top_priorities_hint": "Weighted more heavily (up to 3)",
      "match_dim_gender": "Gender",
      "match_dim_age": "Age",
      "match_dim_budget": "Budget",
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
      "cook": "I cook at home",
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
      "select_your_primary_role": "Primary role",
      "tap_to_select_primary_role": "Choose role",

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
      "menu_language": "Language",

      "menu_favorites": "Favorites",
      "nav_my": "My",
      "menu_history": "History",
      "menu_contact_support": "Contact Support",
      "menu_add_listing": "Add Listing",
      "menu_my_listings": "My Listings",
      "menu_my_groups": "My Groups",
      "my_hub_tab_groups": "Groups",
      "my_hub_tab_bookmarks": "My Bookmarks",
      "my_hub_tab_alerts": "My Alerts",
      "my_groups_empty_subtitle": "Groups you own or joined will appear here.",
      "menu_gigs": "Services",

      // ===== GIGS =====
      "gigs_hub_title": "Services",
      "gigs_hub_browse_title": "Browse services",
      "gigs_hub_browse_subtitle": "Find people who can help with tasks",
      "gigs_hub_post_title": "Post a task",
      "gigs_hub_post_subtitle": "Describe what you need; let people bid",
      "gigs_hub_my_bookings_title": "My tasks",
      "gigs_hub_my_bookings_subtitle": "Tasks you booked or accepted",
      "gigs_hub_open_requests_title": "Open requests",
      "gigs_hub_open_requests_subtitle": "Tasks people are looking to get done",
      "gigs_hub_publish_offer_title": "Publish a service",
      "gigs_hub_publish_offer_subtitle":
          "Offer your skills — let clients book you",
      "gigs_hub_publish_title": "Publish",
      "gigs_hub_publish_subtitle":
          "A task you need done, or a service you offer",
      "gigs_publish_screen_title": "Publish",
      "gigs_publish_mode_task": "Task",
      "gigs_publish_mode_task_subtitle": "I need something done",
      "gigs_publish_mode_service": "Service",
      "gigs_publish_mode_service_subtitle": "I can do something",
      "gigs_hub_feed_services": "Services",
      "gigs_hub_feed_tasks": "Tasks",

      "gigs_browse_title": "Browse services",
      "gigs_browse_empty": "No services available yet.",
      "gigs_offer_detail_title": "Service",
      "gigs_offer_book_cta": "Book this service",
      "gigs_offer_book_view_orders_cta": "Booked: chat with {user_name}",
      "gigs_offer_edit_cta": "Edit service",
      "gigs_offer_provider_fallback": "Service provider",
      "gigs_offer_provider_completed_jobs": "{count} jobs completed",
      "gigs_offer_tile_jobs_one": "{count} job",
      "gigs_offer_tile_jobs_other": "{count} jobs",
      "gigs_offer_tile_reviews_one": "{count} review",
      "gigs_offer_tile_reviews_other": "{count} reviews",
      "gigs_booking_created_toast": "Booking created.",

      "gigs_post_request_title": "Post a task",
      "gigs_post_request_submit": "Post task",
      "gigs_loading": "Loading…",
      "gigs_categories_unavailable": "Categories unavailable. Tap to retry.",
      "gigs_post_request_field_category": "Category",
      "gigs_post_request_field_title": "Title",
      "gigs_post_request_field_description": "Description (optional)",
      "gig_description_template_service":
          "What I offer:\n(Scope — what's included)\n\nWhere & when:\n(Area or remote) · (availability)\n\nNotes:\n(experience, materials, etc.)",
      "gig_description_template_task":
          "What I need:\n(Describe the job)\n\nWhere & when:\n(Location or remote) · (date/time)\n\nAccess / notes:\n(parking, tools, constraints)",
      "gigs_post_request_field_budget_type": "Budget type",
      "gigs_post_request_field_amount": "Amount",
      "gigs_post_request_field_address": "Address (optional)",
      "gigs_post_field_address_detail": "Detailed address (optional)",
      "address_suggest_connection_error":
          "Could not load address suggestions. Check your connection.",
      "address_suggest_unavailable":
          "Address suggestions are temporarily unavailable.",
      "address_suggest_failed": "Could not load address suggestions.",
      "gigs_post_field_district": "District (optional)",
      "gigs_post_request_field_remote": "Remote",
      "gigs_post_request_required": "Required",
      "gigs_post_request_choose_category": "Choose a category",
      "gigs_post_request_success_toast": "Task posted.",
      "gigs_budget_type_fixed": "Fixed",
      "gigs_budget_type_hourly": "Hourly",
      "gigs_budget_type_open": "Open",

      "gigs_post_offer_title": "Publish a service",
      "gigs_post_offer_submit": "Publish",
      "gigs_post_offer_success_toast": "Service published.",
      "gigs_edit_offer_title": "Edit service",
      "gigs_edit_offer_submit": "Save",
      "gigs_edit_offer_success_toast": "Service updated.",
      "gigs_edit_request_title": "Edit task",
      "gigs_edit_request_success_toast": "Task updated.",
      "gigs_request_edit_cta": "Edit task",
      "gigs_request_delete_menu": "Delete task",
      "gigs_request_delete_title": "Delete this task?",
      "gigs_request_delete_message":
          "It will be removed from the task list for everyone. You can't undo this in the app.",
      "gigs_request_delete_success": "Task removed.",
      "gigs_request_delete_failed": "Couldn't remove the task. Try again.",
      "gigs_offer_delete_menu": "Delete service",
      "gigs_offer_delete_title": "Delete this service?",
      "gigs_offer_delete_message":
          "It will be removed from the services list for everyone. You can't undo this in the app.",
      "gigs_offer_delete_success": "Service removed.",
      "gigs_offer_delete_failed": "Couldn't remove the service. Try again.",
      "gigs_post_offer_field_pricing_type": "Pricing type",
      "gigs_post_offer_field_price": "Price",
      "gigs_post_offer_field_min_duration": "Minimum duration (minutes)",
      "gigs_post_offer_field_min_duration_hint": "e.g. 60",
      "gigs_pricing_type_fixed": "Fixed",
      "gigs_pricing_type_hourly": "Hourly",
      "gigs_pricing_type_per_unit": "Per unit",

      "gigs_my_bookings_title": "My bookings",
      "gigs_my_bookings_tab_all": "All",
      "gigs_my_bookings_tab_client": "As client",
      "gigs_my_bookings_tab_provider": "As provider",
      "gigs_my_bookings_empty": "No bookings yet.",
      "gigs_my_published_title": "My published",
      "gigs_my_published_tab_services": "Services",
      "gigs_my_published_tab_tasks": "Tasks",
      "gigs_my_published_add_service": "Add service",
      "gigs_my_published_add_task": "Add task",
      "gigs_my_published_empty_services":
          "You have not published any services yet.",
      "gigs_my_published_empty_tasks": "You have not posted any tasks yet.",
      "gigs_my_published_sign_in":
          "Sign in to see the services and tasks you have published.",
      "gigs_action_cancel": "Cancel",
      "gigs_action_mark_complete": "Mark complete",
      "gigs_status_pending": "Pending",
      "gigs_status_accepted": "Accepted",
      "gigs_status_in_progress": "In progress",
      "gigs_status_completed": "Completed",
      "gigs_status_cancelled": "Cancelled",
      "gigs_status_disputed": "Disputed",

      "gigs_chat_menu_invite_provider_to_book":
          "Invite to book (needs their OK)",
      "gigs_invite_provider_dialog_title": "Invite provider",
      "gigs_invite_provider_dialog_body":
          "They must accept under My bookings before the job is confirmed. Enter the agreed amount if there is no task budget.",
      "gigs_invite_provider_dialog_field_hint":
          "Agreed amount (optional if task has a budget)",
      "gigs_invite_provider_confirm": "Send invite",
      "gigs_invite_provider_success_toast":
          "Invite sent. They can tap Accept under My bookings.",
      "gigs_invite_provider_failed_toast": "Could not send invite. Try again.",
      "gigs_invite_provider_amount_required":
          "Enter an agreed amount, or add a budget to the task first.",
      "gigs_invite_provider_owner_only":
          "Only the person who posted the task can invite.",
      "gigs_invite_provider_not_open_task":
          "This task is no longer open for invites.",
      "gigs_action_accept_booking": "Accept",
      "gigs_action_chat_booking": "Chat",
      "gigs_booking_chat_peer_fallback": "Participant",
      "gigs_booking_cancel_confirm_title": "Cancel this booking?",
      "gigs_booking_cancel_confirm_message":
          "The other participant will be notified.",

      "gigs_requests_title": "Open tasks",
      "gigs_requests_empty": "No open tasks right now.",
      "gigs_request_budget_open": "Open budget",
      "gigs_request_budget_fixed": "Budget: {amount} {currency}",
      "gigs_request_detail_title": "Task",
      "gigs_request_description_label": "About this task",
      "gigs_request_contact_cta": "Message client",
      "gigs_request_contact_failed": "Couldn't open chat. Please try again.",
      "gigs_request_messages_appbar_semantics": "Chats for this task",
      "gigs_request_messages_title": "Task chats",
      "gigs_request_messages_empty": "No chats for this task yet.",
      "gigs_request_messages_empty_subtitle":
          "When providers write to you here, threads will appear in this list.",

      "gigs_price_per_hour": "{amount} {currency} / hr",
      "gigs_price_per_unit": "{amount} {currency}/unit",
      "gigs_price_fixed": "{amount} {currency}",
      "gigs_retry": "Retry",
      "gigs_scheduled_at": "Scheduled: {when}",

      "menu_about": "About",
      "menu_privacy_policy": "Privacy Policy",
      "menu_user_license_agreement": "User License Agreement",
      "menu_faq": "FAQ",
      "menu_settings": "Settings",
      "menu_registration": "Sign in",
      "menu_logout": "Logout",
      "menu_admin_panel": "Admin Panel",
      "profile_menu_collapsible_listings_group": "Listings & chats",
      "profile_menu_collapsible_services_group": "Notifications & support",
      "manage_property": "Manage Property",

      "admin_panel_title": "Admin Panel",
      "admin_panel_category_management": "Users & moderation",
      "admin_panel_category_maps": "Maps",
      "admin_panel_category_analytics": "Analytics",
      "admin_panel_category_settings": "Application Settings",
      "admin_panel_section_content_moderation": "Client configuration",
      "admin_content_moderation_title": "Client configuration",
      "admin_client_settings_show_listing_contacts":
          "Show listing contact details",
      "admin_client_settings_show_listing_contacts_description":
          "Telegram and call buttons in Matching when contacts are set.",
      "admin_client_settings_show_price_insights": "Show price insights",
      "admin_client_settings_show_price_insights_description":
          "Median price by area/station on listing details.",
      "admin_client_settings_show_push_debug": "Show push debug panel",
      "admin_client_settings_show_push_debug_description":
          "Shows the push notification debug tools on the Notifications screen (admin only).",
      "admin_client_settings_show_listing_move_to_top":
          "Show move listing to top controls",
      "admin_client_settings_show_listing_move_to_top_description":
          "Owner promote/remove pill on listing detail, admin overflow menu, and long-press on featured feed tiles.",
      "admin_client_config_hide_gemini_listing_ui":
          "Show translation & AI improve",
      "admin_client_config_hide_gemini_listing_ui_description":
          "Listing language buttons and AI improve when creating or editing.",
      "admin_client_config_disable_custom_camera": "Use in-app custom camera",
      "admin_client_config_disable_custom_camera_description":
          "On: in-app camera with watermark. Off: device camera.",
      "admin_client_config_show_listing_dictation_meter":
          "Dictation level meter & timer",
      "admin_client_config_show_listing_dictation_meter_description":
          "Waveform and timer while dictating; off: mic/stop only.",
      "admin_client_config_disable_lidar_room_scan": "Enable LiDAR room scan",
      "admin_client_config_disable_lidar_room_scan_description":
          "Post-create scan step, edit-screen control, and uploads.",
      "admin_content_moderation_blur_enabled":
          "Detect and blur offensive photos",
      "admin_content_moderation_loading": "Loading moderation settings...",
      "admin_content_moderation_error": "Could not load moderation settings",
      "admin_content_moderation_save_error": "Could not save setting",
      "admin_app_setting_listing_gig_moderation_queue_title":
          "Require approval for new listings and gigs",
      "admin_app_setting_listing_gig_moderation_queue_subtitle":
          "New listings and gigs hidden until admin approval.",
      "admin_app_setting_phone_sign_in_enabled_title":
          "Allow sign-in with phone",
      "admin_app_setting_phone_sign_in_enabled_subtitle":
          "Firebase SMS sign-in in the auth wizard.",
      "admin_app_setting_group_forming_membership_limit_title":
          "Max active groups per user",
      "admin_app_setting_group_forming_membership_limit_subtitle":
          "Includes groups the user created and groups they joined.",

      "admin_panel_section_telegram_sync": "Data import",
      "admin_panel_section_telegram_listing_groups": "Telegram listing groups",
      "admin_telegram_listing_groups_title": "Telegram listing groups",
      "admin_telegram_listing_groups_loading": "Loading groups…",
      "admin_telegram_listing_groups_empty": "No scraped listings found",
      "admin_telegram_listing_groups_detail_empty": "No listings in this group",
      "admin_telegram_listing_groups_error": "Failed to load listing groups",
      "admin_telegram_listing_groups_unknown": "No contact (ungrouped)",
      "admin_telegram_listing_groups_listing_count": "{count} listing(s)",
      "admin_telegram_listing_groups_summary_scraped": "Scraped listings",
      "admin_telegram_listing_groups_summary_groups": "Groups",
      "admin_telegram_listing_groups_summary_duplicates":
          "Groups with duplicates",
      "admin_telegram_listing_groups_summary_ungrouped": "Ungrouped listings",
      "admin_telegram_listing_groups_sort_title": "Sort groups",
      "admin_telegram_listing_groups_sort_count": "Most listings",
      "admin_telegram_listing_groups_sort_recent": "Most recent activity",
      "admin_telegram_listing_groups_sort_name": "Name (A–Z)",
      "admin_telegram_sync_title": "Data import",
      "admin_telegram_sync_chat_label": "Chat",
      "admin_telegram_sync_chat_custom_label": "Custom chat (@handle or id)",
      "admin_telegram_sync_channel_custom": "Custom…",
      "admin_telegram_sync_channels_loading": "Loading channels…",
      "admin_telegram_sync_add_channel": "Add channel",
      "admin_telegram_sync_add_channel_title": "Add Telegram channel",
      "admin_telegram_sync_add_channel_label": "Channel handle",
      "admin_telegram_sync_add_channel_helper":
          "Paste @handle, t.me/handle, or a numeric chat id.",
      "admin_telegram_sync_add_channel_invalid":
          "Enter a valid channel handle or id without spaces.",
      "admin_telegram_sync_add_channel_save": "Add",
      "admin_telegram_sync_add_channel_done": "Added {channel}.",
      "admin_telegram_sync_limit_label": "Message limit",
      "admin_telegram_sync_import_user_label": "Listing owner user ID",
      "admin_telegram_sync_import_user_sync_only":
          "DB sync only (no listing import)",
      "admin_telegram_sync_admins_loading": "Loading admin accounts…",
      "admin_telegram_sync_admins_error": "Could not load admin list",
      "admin_telegram_sync_admins_retry": "Retry",
      "admin_telegram_sync_admins_empty": "No admin users found.",
      "admin_telegram_sync_newest_first": "Newest first",
      "admin_telegram_sync_skip_listing_import":
          "Skip listing import (DB ingest only)",
      "admin_telegram_sync_run": "Run sync",
      "admin_telegram_sync_running": "Running…",
      "admin_telegram_sync_result_header": "Result",
      "admin_telegram_sync_sync_section": "DB sync",
      "admin_telegram_sync_listing_section": "Listing import",
      "admin_telegram_sync_log_scanned": "scanned",
      "admin_telegram_sync_log_created": "created",
      "admin_telegram_sync_log_skipped_no_peer": "skippedNoPeer",
      "admin_telegram_sync_log_skipped_broadcast": "skippedBroadcast",
      "admin_telegram_sync_log_skipped_empty": "skippedEmpty",
      "admin_telegram_sync_log_skipped_no_type": "skippedNoType",
      "admin_telegram_sync_log_skipped_failed": "skippedFailed",
      "admin_telegram_sync_log_errors_title": "Errors:",
      "admin_telegram_sync_log_more": "… ({count} more)",
      "admin_telegram_sync_invalid_chat_limit":
          "Enter a chat (e.g. @roommateuz).",
      "admin_area_price_cache_section_title": "Listing area price cache",
      "admin_area_price_cache_run": "Refresh area price cache",
      "admin_area_price_cache_running": "Rebuilding cache…",
      "admin_area_price_cache_screen_body":
          "Rebuilds cached median and average rents by metro station, line, and district (the “typical rent nearby” block on listing detail). Run after large Telegram imports or if that block stays empty.",
      "admin_telegram_export_section_title": "Download ingested messages",
      "admin_telegram_export_intro":
          "Exports rows from telegram_ingested_messages as a .jsonl text file (one JSON object per line). No Telegram calls. Output includes all chats, capped by max rows.",
      "admin_telegram_export_max_rows_label": "Max rows",
      "admin_telegram_export_download": "Download export",
      "admin_telegram_export_running": "Preparing download…",
      "admin_telegram_export_invalid_max_rows":
          "Max rows must be between 1 and 500000.",
      "admin_telegram_export_done":
          "Export ready — use the share sheet or browser download.",
      "admin_data_import_danger_section_title": "Danger zone",
      "admin_data_import_danger_intro":
          "Destructive operations that reset the database. Use on dev/staging when re-running imports. Cannot be undone.",
      "admin_data_import_clear_listings_button": "Clear listings table",
      "admin_data_import_clear_listings_running": "Clearing listings…",
      "admin_data_import_clear_listings_confirm_title": "Clear all listings?",
      "admin_data_import_clear_listings_confirm_body":
          "This wipes every row in the listings table. All photos, amenities, favorites, complaints, conversations and ingested Telegram messages that reference listings are deleted too. Sequence ids are reset. This cannot be undone.",
      "admin_data_import_clear_listings_done":
          "Cleared {listings_str} (and {ingested_str}).",
      "admin_data_import_clear_ingested_button":
          "Clear ingested Telegram messages",
      "admin_data_import_clear_ingested_running": "Clearing ingested messages…",
      "admin_data_import_clear_ingested_confirm_title":
          "Clear ingested Telegram messages?",
      "admin_data_import_clear_ingested_confirm_body":
          "This wipes every row in the telegram_ingested_messages table. Existing listings are kept. Sequence id is reset. This cannot be undone.",
      "admin_data_import_clear_ingested_done": "Cleared {ingested_str}.",
      "listings_count_one": "{count} listing",
      "listings_count_other": "{count} listings",
      "ingested_messages_count_one": "{count} ingested message",
      "ingested_messages_count_other": "{count} ingested messages",
      "admin_data_import_clear_confirm_action": "Clear",
      "admin_panel_section_users": "Users",
      "admin_reassign_ownership_submit": "Reassign",
      "admin_reassign_ownership_success": "Ownership updated",
      "admin_reassign_owner_menu": "Reassign owner",
      "admin_reassign_owner_dialog_title": "Reassign owner",
      "admin_reassign_owner_search_placeholder": "Search by id, email, or name",
      "admin_reassign_owner_from_user": "Owner ID: {id}",
      "admin_reassign_owner_listing_id": "Listing ID: {id}",
      "admin_reassign_owner_gig_offer_id": "Gig offer ID: {id}",
      "admin_reassign_owner_gig_request_id": "Gig request ID: {id}",
      "admin_reassign_owner_empty": "No users match this search.",
      "admin_panel_section_support_chat": "Support chat",
      "admin_panel_section_complaints": "Complaints",
      "admin_panel_section_listing_complaints": "Listings with complaints",
      "admin_panel_section_listing_moderation": "Approve listings",
      "admin_listing_moderation_title": "Pending listings",
      "admin_listing_moderation_loading": "Loading moderation queue…",
      "admin_listing_moderation_error": "Could not load moderation queue",
      "admin_listing_moderation_retry": "Retry",
      "admin_listing_moderation_summary_total": "Pending",
      "admin_listing_moderation_summary_today": "New today",
      "admin_listing_moderation_summary_oldest": "Longest wait",
      "admin_listing_moderation_days_short": "d",
      "admin_listing_moderation_section_list": "Awaiting review",
      "admin_listing_moderation_empty": "No listings are waiting for approval.",
      "admin_listing_moderation_open": "View",
      "admin_listing_moderation_approve": "Approve",
      "admin_listing_moderation_id": "ID",
      "admin_listing_moderation_user": "User",
      "admin_listing_moderation_load_more": "Load more",
      "admin_listing_moderation_approved_toast": "Listing published",
      "admin_listing_moderation_approve_confirm_title": "Approve listing?",
      "admin_listing_moderation_approve_confirm_message":
          "This will publish the listing and make it visible to everyone.",
      "admin_parser_review_title": "Parser review",
      "admin_parser_review_loading": "Loading parser review…",
      "admin_parser_review_error": "Couldn't load parser review",
      "admin_parser_review_raw_source": "Raw Telegram post",
      "admin_parser_review_raw_empty": "(no text in source)",
      "admin_parser_review_manual_source": "Manually added listing",
      "admin_parser_review_manual_source_description":
          "This listing was added manually by a user, not imported from Telegram.",
      "admin_parser_review_section_fields": "Parser predictions vs. current",
      "admin_parser_review_section_corrections": "Recorded corrections",
      "admin_parser_review_parser_label": "Parser",
      "admin_parser_review_current_label": "Current",
      "admin_parser_review_chip_added": "added",
      "admin_parser_review_chip_removed": "removed",
      "admin_parser_review_chip_changed": "changed",
      "admin_parser_review_chip_confirmed": "confirmed",
      "admin_parser_review_corrections_summary":
          "{changed} of {total} fields corrected",
      "admin_parser_review_open_full": "Open full listing",
      "admin_parser_review_edit": "Edit & correct",
      "admin_parser_review_already_approved": "Already approved",
      "admin_parser_review_field_title": "Title",
      "admin_parser_review_field_price": "Price (USD)",
      "admin_parser_review_field_gender": "Gender preference",
      "admin_parser_review_field_metro": "Metro",
      "admin_parser_review_field_district": "District",
      "admin_parser_review_field_move_in": "Move-in date",
      "admin_parser_review_field_contact_phone": "Contact phone",
      "admin_parser_review_field_contact_telegram": "Contact telegram",
      "admin_parser_review_field_amenities": "Amenities",
      "admin_parser_review_field_description": "Description",
      "admin_parser_review_owner_section": "Telegram owner",
      "admin_parser_review_owner_hint": "username",
      "admin_parser_review_owner_help":
          "Telegram @username of whoever originally posted this listing. Used as the contact handle when no contact telegram is set.",
      "admin_parser_review_owner_save": "Save owner",
      "admin_parser_review_owner_saved": "Telegram owner updated",
      "admin_panel_section_gig_moderation": "Approve gigs",
      "admin_gig_moderation_title": "Gig moderation",
      "admin_gig_moderation_tab_offers": "Services",
      "admin_gig_moderation_tab_requests": "Tasks",
      "admin_gig_moderation_section_offers": "Services awaiting review",
      "admin_gig_moderation_section_requests": "Tasks awaiting review",
      "admin_gig_moderation_empty_offers":
          "No gig services are waiting for approval.",
      "admin_gig_moderation_empty_requests":
          "No gig tasks are waiting for approval.",
      "admin_gig_moderation_provider": "Provider",
      "admin_gig_moderation_client": "Client",
      "admin_gig_moderation_approved_offer_toast": "Service published",
      "admin_gig_moderation_approved_request_toast": "Task published",
      "admin_panel_section_district_heatmap": "District heat map",
      "admin_panel_section_subway_heatmap": "Subway line heat map",
      "admin_panel_section_subway_map": "Subway map",
      "admin_panel_section_universities_map": "Universities map",
      "admin_universities_map_title": "Universities map",
      "admin_universities_map_error": "Could not load universities",
      "admin_universities_map_retry": "Retry",
      "admin_universities_map_empty":
          "No universities with map coordinates yet.",
      "admin_panel_section_search_analytics": "Search analytics",
      "admin_panel_section_listing_creation_analytics":
          "Listings creation analytics",

      "admin_search_analytics_title": "Search analytics",
      "admin_search_analytics_loading": "Loading search analytics...",
      "admin_search_analytics_error": "Failed to load search analytics",
      "admin_search_analytics_retry": "Retry",
      "admin_search_analytics_time_range": "Time range",
      "admin_search_analytics_days": "Last {days} days",
      "admin_search_analytics_days_one": "Last {count} day",
      "admin_search_analytics_days_other": "Last {count} days",
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
      "admin_listing_creation_analytics_by_month": "Listings grouped by month",
      "admin_listing_creation_analytics_no_data":
          "No listing data in this period",

      "admin_district_heatmap_title": "District heat map",
      "admin_district_heatmap_loading": "Loading district stats...",
      "admin_district_heatmap_error": "Failed to load district stats",
      "admin_district_heatmap_retry": "Retry",
      "admin_district_heatmap_total": "Total listings",
      "admin_district_heatmap_max": "Max in district",
      "admin_district_heatmap_count_label": "Listings",
      "admin_district_heatmap_unavailable": "Unavailable",
      "admin_district_heatmap_no_data": "No district data available",

      "admin_subway_heatmap_title": "Subway line heat map",
      "admin_subway_heatmap_loading": "Loading subway line stats...",
      "admin_subway_heatmap_error": "Failed to load subway line stats",
      "admin_subway_heatmap_retry": "Retry",
      "admin_subway_heatmap_total": "Total listings",
      "admin_subway_heatmap_max": "Max on line",
      "admin_subway_heatmap_count_label": "Listings",
      "admin_subway_heatmap_unavailable": "Unavailable",
      "admin_subway_heatmap_no_data": "No subway line data available",

      "admin_subway_map_title": "Subway map",

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
      "admin_user_detail_role_save": "Save role",
      "admin_user_detail_role_updated": "Role updated",
      "admin_user_detail_view_listings": "View listings",
      "admin_user_detail_view_complaints": "View complaints",
      "admin_user_detail_view_alerts": "View user alerts",
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
      "admin_user_detail_self_moderation_not_allowed":
          "You can’t block/unblock or change the role for your own admin account.",
      "admin_user_detail_devices_title": "Devices",
      "admin_user_detail_devices_empty": "No registered devices",
      "admin_user_detail_devices_last_seen": "Last seen",
      "admin_user_detail_devices_model_unknown": "Unknown device",
      "admin_user_detail_devices_details_unknown": "Details unavailable",
      "admin_user_detail_devices_app_prefix": "App",
      "admin_user_complaints_title": "User complaints",
      "admin_user_complaints_user": "User",
      "admin_user_complaints_empty": "No complaints found",
      "admin_user_complaints_group_count": "Complaints",

      "admin_user_listings_title": "User listings",
      "admin_user_listings_user": "User",
      "admin_user_listings_empty": "No listings found",
      "admin_user_listings_error": "Failed to load listings",
      "admin_user_alerts_title": "User alerts",
      "admin_user_alerts_empty": "No alerts found",

      "admin_complaints_title": "Complaints",
      "admin_complaints_loading": "Loading complaints...",
      "admin_complaints_empty": "No complaints found",
      "admin_complaints_error": "Failed to load complaints",
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
      "admin_complaints_view_author": "View author",

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
      "admin_support_chat_days_ago_one": "{count} day ago",
      "admin_support_chat_days_ago_other": "{count} days ago",
      "admin_support_chat_no_messages": "No messages yet",
      "admin_support_chat_reply_hint": "Type your reply...",
      "admin_support_chat_close_thread": "Close thread",
      "admin_support_chat_reopen_thread": "Reopen thread",
      "admin_support_chat_closed": "Thread closed",
      "admin_support_chat_reopened": "Thread reopened",
      "admin_support_chat_thread_closed":
          "This thread is closed. Reopen to reply.",

      "contact_support_title": "Contact Support",
      "contact_support_loading": "Loading...",
      "contact_support_error": "Failed to load support",
      "contact_support_empty":
          "No support conversations yet. Start a new one to get help.",
      "contact_support_new": "New conversation",
      "contact_support_message_hint": "Type your message...",
      "admin_listing_complaints_title": "Listings with complaints",
      "admin_listing_complaints_empty": "No listings with complaints",
      "admin_listing_complaints_error":
          "Failed to load listings with complaints",
      "admin_listing_complaints_categories_empty": "No complaint categories",

      // ===== FAQ CONTENT =====
      "faq_question": "How to negotiate with roommates and avoid conflicts?",
      "faq_answer":
          "Living together is always about respect and the ability to negotiate. Here are some simple rules that will help maintain peace and friendship:\n\nNoise\nAgree on \"quiet hours\". For music — headphones, for calls — hallway or street. It's convenient to hang a schedule so everyone knows when someone has study or rest time.\n\nGuests\nWarn each other in advance. A good rule is certain days for guests and days for quiet.\n\nEmotions\nDon't accumulate irritation. Speak calmly and immediately if something bothers you. And it's better to release extra stress at the gym or on a run.\n\nCommon activities\nSometimes it's useful to do something together: go to the movies, take a walk, have a \"cleaning to music\". Shared memories strengthen friendship.\n\nCleaning and household\nDivide responsibilities — someone mops the floor, someone takes out the trash. The main thing is to negotiate and respect personal boundaries. Don't touch other people's things without permission.\n\nCommunication\nUse \"I-messages\": instead of \"you annoy me\" it's better to say \"it's hard for me to concentrate when loud music is playing\".\n\nConflict resolution\nTry to discuss everything calmly, listening to each other. Conflict is an opportunity to find a common solution, not an enemy.\n\nFood\nYou can agree on joint purchases or start a \"common shelf\" for treats.\n\nOrder and quiet\nCleaning schedule is your best friend. And if you need to concentrate — you can go to the library or coworking, or turn on the \"quiet hour\" rule again.",

      "faq_question_2": "Utility debts and how to avoid them",
      "faq_answer_2":
          "Sometimes along with the apartment, the tenant gets utility debts as a \"gift\". As a result — disconnected electricity or water, and the landlord is in no hurry to pay. The tenant is left to choose: move out with losses or pay off the debt at their own expense.\n\nTo avoid such situations:\n\nCheck before signing\nBefore signing the contract, ask the owner for receipts or a report on paid utility bills.\n\nWritten agreement\nIf there is still a debt and you are ready to pay it, be sure to draw up a written agreement: the amount of the debt will be credited to future rent.\n\nThis way you will save both money and peace of mind.",

      "faq_question_3": "Promised repairs take three years to wait",
      "faq_answer_3":
          "Often when renting housing, the owner promises to fix problems in the apartment, buy household appliances and furniture. All this he undertakes to fulfill immediately after moving in. However, time passes, and the problems remain. To avoid becoming a hostage to such a situation, the tenant should include special conditions in the rental agreement.\n\nAlso, oral agreements about repairs by the tenant and the obligation not to charge rent during the work are often violated. For example, you renovate the apartment at your own expense and don't pay rent for several months. However, some landlords \"forget\" about the agreements and demand payment for accommodation. Often the parties have disagreements about the cost of finishing, and sometimes the matter even comes to court.\n\nTherefore, you should discuss all aspects of the repair, take them into account in the rental agreement, as well as draw up an estimate and sign it.",

      "faq_question_4": "You are no longer my friend",
      "faq_answer_4":
          "Often when renting housing to relatives or friends, no contract is concluded. At the same time, many scandals and disputes occur precisely between relatives and friends who accepted promises and obligations for rent verbally. Therefore, it is better to conclude a contract, even if you are renting an apartment from your uncle or close friend.\n\nThere are cases when apartments are rented by proxy, which states: the principal gives the authorized person the right to rent out his apartment. \"But the power of attorney does not specify that the authorized person also has the right to receive rent. A situation may occur: the tenant regularly pays the rent to the authorized person, but one day the owner of the living space appears and demands that the tenant pay for the past period of residence in the apartment.\" In this case, you should carefully study the documents, and if the power of attorney does not specify the right to receive rent, discuss this point.",

      "faq_question_5": "Safety guide for renters and neighbors",
      "faq_answer_5":
          "Sometimes unpleasant situations happen not only on our platform. Unfortunately, inadequate or troubled people are everywhere. Therefore, it is important to remember simple safety rules.\n\n🙏 The main thing is your safety!\n\nBefore the meeting\n• Arrange meetings only during the day.\n• Try to choose crowded places — cafes, shopping centers, courtyards with cameras.\n• Tell friends or relatives where you are going and who you are meeting.\n\nDuring the meeting\n• If possible, don't come alone.\n• Don't hand over money and documents \"hand to hand\" until the contract is signed.\n• Save correspondence and photos/scans of documents — this is your protection.\n\nIf you feel threatened\n• Immediately stop the meeting and leave.\n• Don't be afraid to say \"no\" and break off communication.\n• In case of obvious danger — call 102 or contact the nearest police station.\n\nOn the UyDosh platform\n• Use the verification system — verified profiles reduce risk.\n• Report suspicious ads and behavior to moderators.\n• Remember: it's better to be safe than sorry.\n\n❤️ Take care of yourself and each other!",

      // ===== LOGOUT & SESSION =====
      "logout_confirmation": "Logout Confirmation",
      "logout_description":
          "Are you sure you want to logout? You will need to sign in again to access your profile.",
      "logout": "Logout",
      "logout_success": "Successfully logged out",
      "session_expired": "Your session has expired. Please sign in again.",

      // ===== DELETE ACCOUNT =====
      "delete_account": "Delete account",
      "delete_account_confirmation":
          "Are you sure you want to delete your account? This action cannot be undone. All your data, listings, and messages will be permanently removed.",
      "delete_account_success": "Account deleted successfully",
      "delete_account_error": "Error deleting account",
      "delete_account_blocked":
          "Your account has been restricted. You cannot delete your account while it is blocked. Please contact support.",
      "delete_account_not_allowed":
          "This account cannot be deleted from the app. Please contact support if you need help.",

      // ===== FAVORITES =====
      "favorites_title": "Favorites",
      "favorites_empty_title": "No favorites yet",
      "favorites_tab_listings": "Listings",
      "favorites_tab_services": "Services",
      "favorites_tab_tasks": "Tasks",
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
      "create_listing_title": "Publish",
      "edit_profile": "Edit Profile",
      "updating_listing": "Updating...",
      "creating_listing": "Creating...",
      "title_required": "Title is required",
      "title_too_long": "Title must be 50 characters or less",
      "description_required": "Text is required",
      "description_too_long": "Text must be 500 characters or less",
      "location_required": "Please select a location",
      "location_metro_required": "Please select a metro station",
      "location_district_required": "Please select a district",
      "price_required": "Please set a price",
      "listing_price_minimum": "Price must be at least 1 USD per month",

      "auth_required_title": "Authentication required",
      "authentication_required":
          "Authentication required. Please log in to create listings.",

      "unauthenticated_listing_prompt":
          "To create and post listings, you need to sign in to your account.",
      "authenticate_to_post_listing": "Authenticate to post listing",
      "select_location_required": "Select location",
      "select_metro_line_optional": "Metro line",
      "metro_station_label": "Metro station",

      // ===== AMENITIES & FEATURES =====
      "amenities": "Amenities",
      "amenities_header_roommate_needed": "The apartment has:",
      "amenities_header_need_room": "I need:",
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
      "filters_bar_label": "Filters",
      "search_alert_notify_me": "Notify when available",
      "search_alert_cta_title": "Get alerts for this search?",
      "search_alert_cta_create": "Create alert",
      "search_clear_filters": "Clear filters",
      "search_alert_login_required":
          "Sign in to get notifications for this search.",
      "search_alert_created":
          "You will be notified when matching listings are posted.",
      "search_alert_already_exists": "This alert was added before.",
      "search_alert_too_wide":
          "Please select a district or a metro line/station to save an alert.",
      "search_alert_failed": "Could not save this alert. Try again.",
      "search_alert_station_already_covered":
          "This station is already included in your alerts.",
      "search_alert_station_already_covered_by_line":
          "Station {station} is already covered by your {line} line alert.",
      "search_alert_permission":
          "Enable notifications in settings to receive alerts.",
      "search_alert_bell_hint": "Get notifications about similar listings",
      "tutorial_search_description":
          "Tap here to filter listings by location, price, room type, and more.",
      "tutorial_profile_description":
          "Your profile and account settings are here.",
      "tutorial_alert_bell_description":
          "Turn on alerts for new matching listings.",
      "tutorial_notifications_bell_description":
          "Your alerts are here. Tap to manage them.",

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
      "sign_in_with_google_or_apple": "Sign in with Google or Apple",
      "sign_in_oauth_prompt": "Sign in to continue",
      "sign_in_oauth_continue": "Continue",
      "auth_wizard_oauth_step_header": "Sign in to UyDosh",
      "successfully_logged_in": "You have successfully logged in",

      "signing_in": "Signing in...",
      "google_sign_in_failed": "Google Sign-In failed: {error}",
      "popup_closed": "Sign-in popup was closed",

      // ===== APPLE AUTHENTICATION (iOS only — required by App Store
      //                            Review Guideline 4.8 alongside Google) =====
      "sign_in_with_apple": "Sign in with Apple",
      "sign_in_with_telegram": "Sign In with Telegram",
      "link_telegram": "Link Telegram",
      "unlink_telegram": "Unlink Telegram",
      "telegram_account_linked": "Telegram account linked",
      "telegram_linked_success": "Telegram linked to your account",
      "telegram_unlinked_success": "Telegram unlinked from your account",
      "telegram_unlinked_relink_hint":
          "To connect again, use Link Telegram in your profile—not Sign in with Telegram on the login screen.",
      "telegram_already_linked": "Telegram is already linked to this account",
      "telegram_not_linked": "Telegram is not linked to this account",
      "telegram_only_sign_in_method":
          "Add Google, Apple, or phone sign-in before unlinking Telegram",
      "telegram_unlink_failed": "Could not unlink Telegram: {error}",
      "unlink_telegram_confirmation_title": "Unlink Telegram?",
      "unlink_telegram_confirmation_message":
          "You will no longer be able to sign in with Telegram on this account. Your profile username will stay visible.",
      "telegram_account_in_use":
          "This Telegram account is already linked to another UyDosh account",
      "telegram_link_failed": "Could not link Telegram: {error}",
      "telegram_bind_not_available":
          "Link Telegram is not available yet. Update the app or try again later.",
      "telegram_bind_invalid_token":
          "Telegram sign-in expired. Please try linking again.",
      "telegram_bind_not_configured":
          "Telegram login is temporarily unavailable on the server.",
      "telegram_login_continue_in_browser":
          "Finish signing in in the browser, then return here.",
      "telegram_sign_in_failed": "Telegram sign-in failed: {error}",
      "could_not_open_telegram": "Could not open Telegram",
      "telegram_alerts_enable_title": "Get alerts in Telegram?",
      "telegram_alerts_enable_body":
          "Receive message and search-match notifications in Telegram when push is off or unavailable.",
      "telegram_alerts_enable_button": "Enable in Telegram",
      "telegram_alerts_enable_waiting":
          "Subscribe in Telegram, then return here.",
      "telegram_alerts_enabled_success": "Telegram alerts are on",
      "telegram_alerts_enable_failed":
          "Could not open Telegram alerts setup. Try again later.",
      "telegram_alerts_settings_title": "Telegram notifications are off",
      "telegram_alerts_settings_body":
          "Open @uydosh_bot in Telegram and subscribe to get message and search alerts here.",
      "telegram_alerts_settings_button": "Enable Telegram notifications",
      "telegram_alerts_settings_waiting":
          "Subscribe in @uydosh_bot, then return here.",
      "telegram_alerts_connected": "Telegram notifications are on",
      "telegram_alerts_disable_button": "Turn off notifications",
      "telegram_alerts_disabled_success": "Telegram alerts turned off",
      "telegram_alerts_disable_failed": "Could not turn off Telegram alerts",
      "apple_sign_in_failed": "Apple Sign-In failed: {error}",

      // ===== PHONE AUTHENTICATION =====
      "sign_in_with_phone": "Sign in with phone",
      "phone_sign_in_under_construction":
          "Sign-in with phone is under construction. Use Google or Apple for now.",
      "sign_in_with_phone_description":
          "We'll text you a 6-digit code to confirm your number.",
      "auth_separator_or": "or",
      "phone_number_example": "+998 90 123 45 67",
      "phone_send_code": "Send code",
      "phone_resend_code": "Resend code",
      "phone_resend_in_seconds": "Resend in {seconds}s",
      "phone_invalid_format":
          "Please enter a valid phone number including country code (e.g. +998 90 123 45 67).",
      "phone_code_entry_title": "Enter the 6-digit code",
      "phone_code_entry_description": "Sent to {phone}",
      "phone_code_invalid": "That code is incorrect or has expired.",
      "phone_verify": "Verify",
      "phone_verifying": "Verifying...",
      "phone_verification_failed": "Phone verification failed: {error}",
      "phone_too_many_requests":
          "Too many attempts. Please try again in a few minutes.",
      "phone_quota_exceeded":
          "Phone verification is temporarily unavailable. Please try again later.",
      "change_phone_number": "Change phone number",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Check out this listing on UyDosh!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Contact User",
      "follow": "Follow",
      "following": "Following",
      "followers_count_one": "{count} follower",
      "followers_count_other": "{count} followers",
      "following_count_one": "{count} following",
      "following_count_other": "{count} following",
      "followers_list_title": "Followers",
      "following_list_title": "Following",
      "no_followers_yet": "No followers yet",
      "no_following_yet": "Not following anyone yet",
      "common_connections": "Common connections",
      "common_connections_count": "{count}",
      "message": "Text in Chat",
      "uydosh_chat": "UyDosh Chat",
      "admin_listing_contacts": "Listing contacts (admin)",

      // ===== STATUS & STATE =====
      "delete_listing": "Delete Listing",
      "delete_listing_confirmation":
          "Are you sure you want to delete this listing? This action cannot be undone.",
      "delete_listing_success": "Listing deleted successfully",
      "delete_listing_error": "Error deleting listing",
      "unknown": "Unknown",

      // ===== COMPLAINTS =====
      "create_complaint": "Create Complaint",
      "complaint_description_hint": "Add details (optional)",
      "submit_complaint": "Submit Complaint",
      "complaint_created_success": "Complaint submitted successfully",
      "listing_complaints": "Listing Complaints",
      "listing_complaints_header": "Complaints for the listing: {count}",
      "view_listing_complaints": "View listing complaints",
      "complaints_count_short": "{count} complaints",
      "complaints_count_short_one": "{count} complaint",
      "complaints_count_short_other": "{count} complaints",
      "no_listing_complaints": "No complaints for this listing yet",
    },
    "ru": {
      // ===== NAVIGATION =====
      "home": "Объявления",
      "nav_housing": "Жильё",
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
      "create_choice_title": "С чего начнём?",
      "create_choice_housing": "Жильё",
      "create_choice_housing_subtitle": "Сдать или снять жильё",
      "create_choice_roommate_needed_subtitle":
          "Жильё есть — найдём соседей, с которыми будет комфортно",
      "create_choice_room_needed_subtitle":
          "Подберём комнату или квартиру по душе",
      "create_choice_group_forming": "Собрать группу",
      "create_choice_group_forming_subtitle":
          "Объединимся и снимем жильё вместе — выгоднее",
      "create_group_title": "Собрать группу",
      "listing_type_group_forming": "Собрать группу",
      "title_group_forming": "Собираем Группу",
      "group_size_target_label": "Размер группы (включая вас)",
      "group_size_target_option_one": "{count} человек всего",
      "group_size_target_option_few": "{count} человека всего",
      "group_size_target_option_many": "{count} человек всего",
      "group_budget_per_person_label": "Диапазон бюджета на человека в месяц",
      "group_budget_per_person_heading": "Бюджет на человека",
      "price_picker_single_title": "Цена за месяц",
      "price_picker_range_title": "Диапазон бюджета в месяц",
      "group_budget_per_person_amount_line":
          "С каждого участника: {range} в месяц",
      "group_budget_total_apartment_line":
          "Общая аренда на {count} человек: {range} в месяц",
      "group_request_to_join": "Подать заявку",
      "group_join_request_sent": "Заявка отправлена",
      "group_join_request_withdraw": "Отозвать заявку",
      "group_open_chat": "Открыть групповой чат",
      "group_floating_chat_label": "Чат группы · {current}/{target}",
      "group_floating_participants_label": "Участники",
      "group_floating_shortlist_label": "Варианты жилья · {count}",
      "group_manage_requests": "Заявки в группу",
      "group_members_progress": "{current}/{target} участников",
      "group_status_looking_for_roommates": "Ищем соседей",
      "group_status_request_pending": "Заявка отправлена",
      "group_status_full": "Группа набрана",
      "group_status_closed": "Группа закрыта",
      "group_status_housing_search": "Ищем жильё",
      "group_status_reviewing_shortlist": "Обсуждаем сохранённые варианты",
      "group_status_landlord_outreach_owner": "Ждём ответа арендодателя",
      "group_status_landlord_outreach_member":
          "Приглашение арендодателю отправлено",
      "group_status_landlord_joined": "Арендодатель в чате",
      "group_members_needed_one": "Нужен ещё {count} участник",
      "group_members_needed_few": "Нужно ещё {count} участника",
      "group_members_needed_many": "Нужно ещё {count} участников",
      "group_join_request_message_hint": "Коротко о себе (необязательно)",
      "group_join_request_success": "Заявка отправлена",
      "group_join_requires_profile":
          "Заполните профиль, чтобы вступить в эту группу.",
      "group_join_request_withdrawn": "Заявка отозвана",
      "group_join_request_approved": "Участник добавлен в группу",
      "group_join_request_rejected": "Заявка отклонена",
      "group_no_pending_requests": "Нет новых заявок",
      "group_new_request_pill": "Новая заявка",
      "group_approve_member": "Принять",
      "group_reject_member": "Отклонить",
      "group_pending_join_requests": "Ожидающие заявки",
      "group_member_role_pending_request": "Заявка на вступление",
      "create_choice_service": "Услуга",
      "create_choice_service_subtitle": "Предложить или найти услугу",
      "profile": "Профиль",
      "role_tenant": "Арендатор",
      "role_landlord": "Арендодатель",
      "role_manager": "Менеджер",
      "role_admin": "Администратор",
      "role_service_provider": "Исполнитель услуг",
      "role_service_requester": "Заказчик услуг",
      "profile_completion": "Заполнение профиля",
      "profile_completion_hint":
          "Заполненный профиль = более точные совпадения и комфортное соседство.",
      "complete_profile_prompt_title": "Заполните профиль",
      "complete_profile_prompt_body":
          "Укажите предпочтения по образу жизни, чтобы получить лучшие совпадения.",
      "missing_fields_title": "Не заполнено:",
      "complete_profile_prompt_more": "+ ещё {count}",
      "complete_profile_prompt_cta": "Заполнить сейчас",
      "complete_profile_prompt_later": "Позже",
      "compatibility_title": "Совместимость с вами:",
      "compatibility_match_percentage": "Совпадение: {percent}%",
      "compatibility_calculating": "Считаем совпадение...",
      "compatibility_sign_in": "Войдите, чтобы увидеть совместимость",
      "na": "Н/Д",
      "compatibility_matches": "Совпадающие предпочтения:",
      "compatibility_differences": "Возможные различия:",
      "compatibility_critical_differences": "Критичные различия:",
      "compatibility_based_on_preferences":
          "На основе {scored} из {total} предпочтений",
      "group_compatibility_title": "Совместимость группы:",
      "group_compatibility_subtitle": "Группа из {count} человек",
      "group_compatibility_target_description": "в группу из {count} человек",
      "group_compatibility_full_matches": "Общие совпадения ({count}/{total})",
      "group_compatibility_partial_matches":
          "Частично совпадает ({count} из {total})",
      "group_compatibility_discuss": "Стоит обсудить",
      "group_compatibility_value_count": "{count} — {value}",
      "group_compatibility_summary_full": "полных совпадений",
      "group_compatibility_summary_partial": "частичных",
      "group_compatibility_summary_discuss": "темы обсудить",
      "group_compatibility_summary_compact_full": "полных",
      "group_compatibility_summary_compact_partial": "частичных",
      "group_compatibility_summary_compact_discuss": "обсудить",
      "group_profile_summary_title": "Профиль группы",
      "group_profile_report_title": "Сводка профиля группы",
      "group_preference_matrix_title": "Матрица бытовых предпочтений",
      "group_preference_matrix_subtitle":
          "Сравните всех участников одним взглядом",
      "group_compatibility_report_title": "Сводка совместимости группы",
      "group_preference_matrix_preference": "Предпочтение",
      "view_member_profiles": "Профили участников",
      "group_member_profiles_formed": "Группа сформирована",
      "group_find_housing": "Найти жильё для группы",
      "group_continue_search": "Продолжить поиск",
      "group_search_area": "Область поиска",
      "group_search_area_hint":
          "Выберите районы и станции метро, по которым ищет вся группа.",
      "group_search_area_saved": "Область поиска обновлена",
      "group_search_area_empty": "Выберите хотя бы одну станцию или район",
      "group_shortlist_title": "Варианты жилья",
      "group_shortlist_title_count": "Варианты жилья ({count})",
      "group_shortlist_all_options": "Все варианты",
      "group_shortlist_chip": "Сохранено ({count})",
      "group_shortlist_save": "Сохранить для группы",
      "group_shortlist_save_for_group": "Сохранить для группы ({count} чел.)",
      "group_shortlist_added": "Добавлено в список группы",
      "group_shortlist_removed": "Удалено из списка группы",
      "group_shortlist_empty_title": "Пока нет сохранённых объявлений",
      "group_shortlist_empty_subtitle":
          "Ищите жильё и сохраняйте варианты для обсуждения с группой",
      "group_shortlist_saved_by": "",
      "group_shortlist_saved_by_female": "Сохранила",
      "group_shortlist_saved_by_suffix": "сохранил",
      "listing_author": "Автор",
      "group_shortlist_open": "Открыть",
      "group_shortlist_view": "Посмотреть",
      "group_shortlist_open_listing": "Просмотреть",
      "group_shortlist_remove": "Убрать",
      "group_shortlist_saved_for_group_context":
          "Сохранено для группы «{label}»",
      "group_shortlist_group_size_label": "{count} человека",
      "group_shortlist_fits_budget_check": "Вписывается в бюджет",
      "group_shortlist_above_budget_check": "Выше бюджета",
      "group_shortlist_fit_district_named": "Район: {name}",
      "group_shortlist_fit_district_unspecified": "Район: не указан",
      "group_shortlist_saved_for_group": "Сохранено для группы · {name}",
      "group_shortlist_price_per_person": "{price} / мес за человека",
      "group_shortlist_fits_group_budget": "Вписывается в бюджет группы",
      "group_shortlist_suitable_for_group": "Подходит группе:",
      "group_shortlist_fit_budget_ok": "Бюджет ок",
      "group_shortlist_fit_budget_above": "Выше бюджета",
      "group_shortlist_fit_for_people": "Для {count} чел.",
      "group_shortlist_fit_district_ok": "Район подходит",
      "group_shortlist_fit_district_diff": "Другой район",
      "group_shortlist_discuss_in_group": "Обсудить в группе",
      "group_shortlist_already_in_discussion":
          "Это объявление уже добавлено в обсуждение группы",
      "group_shortlist_ref_label": "Объявление в обсуждении",
      "group_shortlist_ref_tap_hint": "Нажмите, чтобы открыть",
      "group_shortlist_original_not_found":
          "Исходная карточка объявления ещё не загружена",
      "group_shortlist_start_listing_discussion": "Начать обсуждение",
      "group_shortlist_continue_discussion": "Продолжить обсуждение",
      "group_shortlist_discuss_message_intro": "Как вам этот вариант?",
      "messages_preview_shared_listing": "📋 Объявление: {title}",
      "messages_preview_shared_listing_no_title": "📋 Поделился объявлением",
      "messages_preview_referenced_listing": "↪️ {title}",
      "messages_preview_referenced_listing_no_title": "↪️ Упомянул объявление",
      "group_shortlist_discuss_line_location": "📍 {location}",
      "group_shortlist_discuss_line_metro": "🚇 {station}",
      "group_shortlist_discuss_line_price": "💰 {price}",
      "group_shortlist_discuss_line_price_per_person":
          "💰 {price} / мес за человека",
      "group_shortlist_discuss_line_link": "🔗 {link}",
      "group_shortlist_rating_summary": "{average} · {count} оценок",
      "group_shortlist_rating_count_summary": "{count} оценок",
      "group_shortlist_rate_prompt": "Оцените вариант",
      "group_shortlist_rate_cta": "Помогите группе выбрать: оцените вариант",
      "group_shortlist_group_rating": "Оценка группы",
      "group_shortlist_ai_summary_title": "AI-сводка отзывов",
      "group_shortlist_no_ratings": "Пока нет оценок",
      "group_shortlist_edit_rating_title": "Изменить вашу оценку",
      "group_shortlist_dislike_reasons_title": "Что не понравилось?",
      "group_shortlist_dislike_reason_expensive": "Слишком дорого",
      "group_shortlist_dislike_reason_far": "Далеко",
      "group_shortlist_dislike_reason_condition": "Плохой ремонт",
      "group_shortlist_dislike_reason_owner": "Хозяин / условия",
      "group_shortlist_dislike_reason_space": "Мало места",
      "group_shortlist_dislike_reason_neighborhood": "Плохой район",
      "listing_rating_screen_title": "Оцените вариант жилья",
      "listing_rating_screen_subtitle":
          "Ваше мнение поможет группе принять решение",
      "listing_rating_category_price": "Цена",
      "listing_rating_category_price_subtitle":
          "Соответствует бюджету, цена адекватная",
      "listing_rating_category_location": "Локация",
      "listing_rating_category_location_subtitle":
          "Близость к учёбе/работе, транспорт, район",
      "listing_rating_category_condition": "Состояние жилья",
      "listing_rating_category_condition_subtitle":
          "Ремонт, чистота, мебель, кухня, санузел",
      "listing_rating_category_group": "Удобство для группы",
      "listing_rating_category_group_subtitle":
          "Хватит ли места всем, планировка, личное пространство",
      "listing_rating_category_landlord": "Условия и арендодатель",
      "listing_rating_category_landlord_subtitle":
          "Правила, адекватность хозяина, доверие",
      "listing_rating_label_excellent": "Отлично",
      "listing_rating_label_good": "Хорошо",
      "listing_rating_label_normal": "Нормально",
      "listing_rating_label_bad": "Плохо",
      "listing_rating_verdict_title": "Итоговый вердикт",
      "listing_rating_verdict_subtitle":
          "Хотите ли вы двигаться дальше с этим вариантом?",
      "listing_rating_verdict_yes": "Да,\nподходит",
      "listing_rating_verdict_maybe": "Можно\nрассмотреть",
      "listing_rating_verdict_no": "Нет, не\nподходит",
      "listing_rating_reasons_title": "Что смущает?",
      "listing_rating_optional": "необязательно",
      "listing_rating_submit": "Отправить оценку",
      "listing_rating_participants_summary": "Оценяют участники группы",
      "group_shortlist_rating_updated": "Оценка обновлена",
      "group_shortlist_contact_landlord": "Пригласить арендодателя в чат",
      "group_landlord_invite_revoke": "Отозвать приглашение",
      "group_landlord_invite_sent":
          "Приглашение отправлено. Арендодатель увидит только новые сообщения после входа.",
      "group_landlord_invite_revoked": "Приглашение отозвано",
      "group_landlord_invite_dialog_title": "Войти в групповой чат?",
      "group_landlord_invite_dialog_message":
          "Вас пригласили обсудить это объявление с группой. Вы увидите только сообщения, отправленные после входа.",
      "group_landlord_invite_accept": "Войти в чат",
      "group_landlord_invite_decline": "Отклонить",
      "group_landlord_invite_accepted": "Вы вошли в групповой чат",
      "group_landlord_invite_declined": "Приглашение отклонено",
      "group_landlord_invite_chat_card_title": "Приглашение в групповой чат",
      "group_landlord_invite_chat_card_body":
          "Организатор группы пригласил вас обсудить это объявление с группой. Вы увидите только сообщения, отправленные после входа.",
      "group_landlord_invite_one_at_a_time":
          "Арендодатель уже подключён к этому групповому чату или приглашение ещё ожидает ответа. Отзовите текущее приглашение или завершите обсуждение, прежде чем приглашать другого арендодателя.",
      "group_shortlist_remove_title": "Удалить из сохранённых?",
      "group_shortlist_remove_message":
          "«{title}» будет удалено из списка сохранённых группы.",
      "group_shortlist_remove_confirm": "Удалить",
      "group_housing_fits_budget": "Вписывается в бюджет",
      "group_housing_above_budget": "Выше бюджета группы",
      "group_housing_search_banner":
          "Группа из {count} чел. · до {budget}/чел.",
      "group_housing_search_empty": "Подходящих объявлений не найдено",
      "group_member_role_owner": "Организатор",
      "group_member_role_you": "Вы",
      "group_member_role_member": "Участник",
      "group_member_compat_match": "Совпадение",
      "group_member_compat_difference": "Различие",
      "group_member_compat_dealbreaker": "Конфликт",
      "group_remove_member": "Удалить из группы",
      "group_remove_member_title": "Удалить из группы?",
      "group_remove_member_message":
          "{name} потеряет доступ к групповому чату. Освободится место для нового участника.",
      "group_remove_reason_title": "Причина удаления (необязательно)",
      "group_remove_reason_inactive": "Неактивен",
      "group_remove_reason_rules": "Нарушение правил",
      "group_remove_reason_not_fit": "Не подходит группе",
      "group_remove_reason_member_request": "По просьбе участника",
      "group_remove_reason_other": "Другое",
      "group_remove_reason_other_hint": "Коротко укажите причину",
      "group_remove_member_success": "Участник удалён из группы",
      "group_leave_group": "Покинуть группу",
      "group_leave_group_title": "Покинуть группу?",
      "group_leave_group_message":
          "Вы потеряете доступ к групповому чату. Освободится место для нового участника.",
      "group_leave_group_success": "Вы покинули группу",
      "vs": "vs",
      "name": "Имя или никнейм",
      "im_from": "Я из:",

      // ===== APP CORE =====
      "user": "Пользователь",
      "welcome_title": "Добро пожаловать в UyDosh",
      "welcome_subtitle": "Найди идеального соседа или жильё",
      "splash_subtitle": "ДАВАЙТЕ ЖИТЬ ВМЕСТЕ!",
      "search_results": "Результаты поиска",
      "search_refresh_this_area": "Обновить эту область",
      "open_map_view": "Открыть карту",
      "open_feed_view": "Открыть ленту",
      "close": "Закрыть",
      "cancel": "Отмена",
      "done": "Готово",
      "about_uy_dosh": "Об UyDosh",
      "user_license_agreement_title": "Лицензионное соглашение пользователя",

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

      "error_generic_try_again":
          "Произошла ошибка. Пожалуйста, попробуйте снова.",
      "error_unable_to_complete_try_again":
          "Не удалось выполнить запрос. Пожалуйста, попробуйте снова.",
      "error_no_internet":
          "Нет подключения к интернету. Проверьте настройки сети.",
      "error_timeout_check_connection":
          "Время ожидания истекло. Проверьте интернет-соединение и попробуйте снова.",
      "error_server_try_later": "Ошибка сервера. Пожалуйста, попробуйте позже.",
      "error_service_unavailable_try_later":
          "Сервис временно недоступен. Пожалуйста, попробуйте позже.",
      "error_invalid_request":
          "Некорректный запрос. Проверьте данные и попробуйте снова.",
      "error_auth_required":
          "Требуется авторизация. Пожалуйста, войдите снова.",
      "error_access_denied": "Доступ запрещён. У вас нет прав на это действие.",
      "error_not_found": "Запрошенный ресурс не найден.",
      "error_conflict":
          "Ресурс уже существует или конфликтует с текущими данными.",
      "error_invalid_data": "Переданы некорректные данные. Проверьте ввод.",
      "error_too_many_requests":
          "Слишком много запросов. Подождите немного и попробуйте снова.",
      "error_request_cancelled": "Запрос был отменён.",
      "error_internet_connection": "Проверьте подключение к интернету",
      "error_resource_conflict": "Вы уже пожаловались на это объявление.",

      // ===== MESSAGING =====
      "conversations": "Сообщения",
      "messages": "Сообщения",
      "chat": "Чат",
      "chat_security_ribbon_title": "Защищённый чат",
      "chat_security_ribbon_body":
          "Чат защищён AI‑фильтрами от мошенничества и скама, чтобы вам было безопаснее общаться.",
      "chat_safety_warning_title_medium": "Предупреждение",
      "chat_safety_warning_title_high": "Будьте осторожны",
      "chat_safety_warning_fallback":
          "В этом разговоре могут быть признаки мошенничества. Осторожнее со ссылками, кодами и просьбами об оплате.",
      "chat_safety_reason_deposit_to_reserve_room":
          "Пользователь просит внести депозит, чтобы забронировать комнату.",
      "chat_safety_reason_suspicious_link":
          "Собеседник отправляет подозрительную ссылку.",
      "chat_safety_reason_off_platform":
          "Собеседник пытается перевести общение вне платформы.",
      "chat_safety_reason_otp_code":
          "Собеседник просит код подтверждения (OTP/SMS).",
      "chat_safety_reason_payment_request":
          "Собеседник просит предоплату или платежные данные.",
      "chat_safety_sheet_why_title": "Почему это отмечено",
      "chat_safety_sheet_copy": "Скопировать сообщение",
      "chat_safety_sheet_report": "Пожаловаться",
      "chat_safety_sheet_close": "Закрыть",
      "chat_safety_sheet_copied": "Скопировано",
      "profile_interlocutor": "Профиль Собеседника",
      "view_listing": "Посмотреть объявление",
      "view_group": "Посмотреть группу",
      "chat_menu_translate_to": "Перевести на…",
      "chat_menu_show_original": "Оригиналы",
      "chat_menu_show_translated": "Переводы",
      "admin_delete_conversation": "Удалить переписку для всех",
      "admin_delete_conversation_confirmation":
          "Чат исчезнет из списков обоих пользователей, продолжить общение в этой ветке будет нельзя. Продолжить?",
      "admin_delete_conversation_success": "Переписка удалена",
      "admin_delete_conversation_error": "Не удалось удалить переписку",
      "admin_listing_owner_conversations_card_title":
          "Чаты по объявлению (админ)",
      "admin_listing_owner_conversations_card_subtitle":
          "Все диалоги в приложении между пользователями и автором объявления.",
      "admin_listing_owner_conversations_screen_title":
          "Чаты по этому объявлению",
      "admin_listing_owner_conversations_empty":
          "Пока нет чатов по этому объявлению.",
      "admin_listing_owner_conversations_error":
          "Не удалось загрузить чаты объявления.",
      "admin_listing_owner_conversations_retry": "Повторить",
      "admin_listing_owner_conversations_closed_badge": "Закрыт",
      "chat_translate_picker_title": "Перевести этот чат на",
      "chat_translate_picker_auto": "Авто (мой язык)",
      "chat_translating": "Перевод…",
      "chat_translation_quota_exceeded":
          "Лимит бесплатных переводов чата на месяц исчерпан. Подключите премиум через Payme или Click.",
      "menu_messages": "Сообщения",
      "menu_notifications": "Уведомления",
      "menu_enable_notifications": "Включить уведомления",
      "notifications_alert_match_header": "Вы получите пуш-уведомление на:",
      "notifications_alert_match_header_paused":
          "Приостановлено — без пуш-уведомлений для:",
      "notifications_push_off_title": "Push-уведомления {where} отключены",
      "notifications_push_off_where_ios": "на iOS",
      "notifications_push_off_where_android": "на Android",
      "notifications_push_off_where_chrome": "в Chrome",
      "notifications_push_off_where_safari": "в Safari",
      "notifications_push_off_where_firefox": "в Firefox",
      "notifications_push_off_where_edge": "в Edge",
      "notifications_push_off_where_browser": "в браузере",
      "notifications_push_off_where_device": "на устройстве",
      "inbox_push_off_banner_title":
          "Включите уведомления, чтобы не пропустить сообщения",
      "notifications_enabled": "Уведомления включены",
      "notifications_enable_in_settings":
          "Включите уведомления в настройках приложения",
      "notifications_appbar_semantics_active_alerts":
          "Есть активные оповещения о поиске",
      "notifications_empty": "Пока нет сохранённых оповещений.",
      "notifications_alerts_explainer":
          "Здесь ваши оповещения.\nКак только появится подходящее жильё или сосед — мы сразу сообщим.",
      "notifications_alerts_explainer_enabled":
          "Уведомления включены.\n\nЗдесь ваши оповещения. Как только появится подходящее жильё или сосед — мы пришлём push-уведомление.",
      "notifications_open_settings": "Открыть настройки",
      "notifications_disable_all": "Отключить все уведомления",
      "notifications_delete_all": "Удалить все уведомления",
      "notifications_disable_all_title": "Отключить все уведомления?",
      "notifications_disable_all_message":
          "Это выключит все сохранённые оповещения о поиске. Позже их можно включить снова.",
      "notifications_delete_all_title": "Удалить все уведомления?",
      "notifications_delete_all_message":
          "Это навсегда удалит все сохранённые оповещения о поиске. Это действие нельзя отменить.",
      "disable": "Отключить",
      "enable": "Включить",
      "type_message": "Введите сообщение...",
      "conversation_created": "Разговор начат",
      "conversation_failed": "Не удалось начать разговор",
      "error_listing_chat_disabled":
          "Чат в приложении недоступен для этого объявления",
      "no_conversations": "Пока нет разговоров",
      "no_messages": "Пока нет сообщений",
      "no_messages_description":
          "Вы еще не получили сообщений о ваших объявлениях",
      "mark_as_read": "Отметить как прочитанное",
      "archive": "В архив",
      "unarchive": "Из архива",
      "archived": "Архив",
      "archived_chats": "Архив чатов",
      "archived_chats_tip":
          "Удерживайте чат в архиве, чтобы открыть действия, или смахните влево, чтобы вернуть его во входящие.",
      "grouped_chats_expand_coach_hint":
          "Нажмите на заголовок карточки (или стрелку), чтобы развернуть или свернуть чаты по одному объявлению.",
      "no_archived_conversations": "В архиве пусто",
      "no_archived_conversations_description":
          "Архивированные чаты появятся здесь",
      "chat_archived": "Чат в архиве",
      "chat_unarchived": "Чат возвращён во входящие",
      "chat_edit_message_title": "Редактировать сообщение",
      "chat_edit_message_save": "Сохранить",
      "chat_edit_message_cancel": "Отмена",
      "chat_edit_message_once_only":
          "Вы уже использовали единственное редактирование для этого сообщения.",
      "chat_edit_hold_already_edited_toast":
          "Каждое сообщение можно изменить только один раз — вы уже сохранили правку.",
      "chat_message_edited_label": "Изменено",
      "chat_replying_to": "Ответ для {name}",
      "chat_reply_cancel": "Отменить ответ",
      "chat_reply_sender_you": "вас",
      "chat_reply_sender_unknown": "Сообщение",
      "chat_reply_attachment_fallback": "Вложение",
      "chat_scroll_to_bottom": "К последнему сообщению",
      "archive_failed_has_unread":
          "Нельзя архивировать чат с непрочитанными сообщениями",
      "undo": "Отменить",
      "error_not_authenticated": "Войдите в систему, чтобы начать разговор",
      "error_cannot_message_self": "Вы не можете писать сообщения себе",
      "start_conversation_from_listing":
          "Начните разговор с объявления, чтобы начать общение",
      "today": "Сегодня",
      "yesterday": "Вчера",
      "tomorrow": "Завтра",
      "in_days": "Через {days} дней",
      "in_days_one": "Через {count} день",
      "in_days_few": "Через {count} дня",
      "in_days_many": "Через {count} дней",
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
      "quick_question_total_price":
          "Какая итоговая цена со всеми коммунальными?",
      "quick_question_can_visit_soon": "Можно прийти посмотреть на днях?",
      "quick_question_roommate_still_searching": "Вы ещё ищете сожителя?",
      "quick_question_roommate_move_in_date": "Когда можно было бы заселиться?",
      "quick_question_roommate_household": "Кто уже живёт в квартире?",
      "quick_question_roommate_rent_terms": "Как делите аренду и коммунальные?",
      "quick_question_roommate_meet_soon":
          "Можем познакомиться или созвониться?",
      "quick_question_seeker_move_in_when": "Когда планируете заехать?",
      "quick_question_seeker_budget": "Какой у вас бюджет?",
      "quick_question_seeker_how_long": "На какой срок ищете?",
      "quick_question_seeker_about_you": "Расскажете немного о себе?",
      "quick_question_generic_price": "Сколько стоит?",
      "quick_question_generic_whats_included": "Что входит в стоимость?",
      "quick_question_generic_when_available": "Когда вы свободны?",
      "quick_question_generic_how_soon": "Как быстро можно начать?",
      "quick_question_generic_arrangement": "Как удобнее организовать?",
      "quick_question_generic_clarify_details": "Можно уточнить детали?",
      "quick_question_offerer_scope": "Что именно нужно сделать?",
      "quick_question_offerer_deadline": "К какому сроку это нужно?",
      "quick_question_offerer_where": "Где это будет происходить?",
      "quick_question_offerer_budget": "Какой бюджет вы закладываете?",
      "quick_question_offerer_materials":
          "Материалы предоставите вы или мне брать с собой?",
      "quick_question_offerer_visit":
          "Можем договориться о коротком звонке или выезде для оценки?",
      "private_room": "Отдельная комната",
      "with_photo": "С фото",
      "search_filter_private_room": "Отдельная комната",
      "search_filter_with_photo": "С фото",
      "conversation_count": "разговор",
      "conversations_count": "разговора",
      "conversations_count_one": "{count} разговор",
      "conversations_count_few": "{count} разговора",
      "conversations_count_many": "{count} разговоров",
      "incoming": "Входящие",
      "outgoing": "Исходящие",
      "no_incoming_conversations": "Нет входящих разговоров",
      "no_outgoing_conversations": "Нет исходящих разговоров",
      "no_incoming_conversations_description":
          "Вы еще не получили сообщений о ваших объявлениях",
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
      "error_reordering_photos":
          "Не удалось обновить главное фото. Попробуйте еще раз.",
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
      "room_scan_title": "3D-скан комнаты",
      "room_scan_instructions":
          "Перед началом 3D-сканирования\n\n• Включите хорошее освещение\n• Двигайтесь медленно, без резких движений\n• Держите телефон на уровне груди\n• Сканируйте стены, углы, окна и двери\n• Постарайтесь охватить всю комнату\n\nЭто поможет создать точную 3D-модель вашего жилья",
      "room_scan_start": "Начать сканирование",
      "room_scan_finish": "Завершить",
      "room_scan_scan_other_rooms": "Сканировать другие комнаты",
      "room_scan_uploading": "Загрузка…",
      "room_scan_success": "3D-скан сохранён",
      "room_scan_cancelled":
          "Скан не был сделан. Нажмите «Начать», чтобы попробовать снова.",
      "room_scan_error": "Не удалось сохранить скан. Попробуйте снова.",
      "room_scan_too_large":
          "3D-скан слишком большой для загрузки. Попробуйте отсканировать меньшую область.",
      "room_scan_not_supported": "3D-скан требует iPhone или iPad с LiDAR.",
      "room_scan_camera_required":
          "Для 3D-сканирования нужен доступ к камере. Если вы нажали «Запретить», включите камеру для UyDosh в Настройках.",
      "room_scan_disabled_globally":
          "3D-сканирование комнаты отключено в настройках приложения. Позже оно может снова стать доступным.",
      "add_room_scan_3d": "Добавить 3D-скан комнаты",
      "replace_room_scan_3d": "Заменить 3D-скан комнаты",
      "skip": "Пропустить",
      "view_room_3d": "Смотреть комнату в 3D",
      "room_3d_open_error":
          "Не удалось открыть 3D-модель. Проверьте подключение.",
      "room_3d_viewer_title": "3D",
      "room_3d_dimensions_caption": "Приблизительные размеры",
      "room_3d_dimensions_line1_template":
          "Размеры: {floorLong} × {floorShort} м",
      "room_3d_dimensions_height_template": "Высота: {height} м",
      "room_3d_dimensions_line2_template": "Площадь: ~{floorArea} м²",
      "room_3d_load_error_title": "Не удалось загрузить 3D-модель",
      "room_3d_floor_only_button": "Скрыть стены",
      "room_3d_full_room_button": "Вся комната",
      "room_3d_floor_only_unavailable":
          "В файле не найдены отдельные стены по имени. В экспорте стены должны быть отдельными объектами.",
      "room_3d_zoom_in": "Приблизить",
      "room_3d_zoom_out": "Отдалить",
      "room_3d_view_mode_label": "Режим 3D-просмотра",
      "room_3d_view_mode_hint":
          "Переключайте: вся комната, только стены или пол с мебелью.",
      "room_3d_materials_style_label": "Стиль материалов",
      "room_3d_materials_style_hint":
          "Переключайте между реальными материалами и стилизованными цветами.",
      "room_3d_materials_style_value_stylized": "Стилизованный",
      "room_3d_materials_style_value_real": "Реальный",
      "room_3d_tab_view_3d": "3D",
      "room_3d_tab_floor_plan": "2D",
      "room_3d_floor_plan_reset": "Сброс",
      "room_3d_floor_plan_dimensions_overall": "Общие",
      "room_3d_floor_plan_dimensions_walls": "Стены",
      "room_3d_floor_plan_dimensions_hide": "Скрыть",
      "room_3d_floor_plan_show_objects": "Объекты",
      "room_3d_floor_plan_hide_objects": "Скрыть объекты",
      "room_3d_floor_plan_show_grid": "Сетка",
      "room_3d_floor_plan_hide_grid": "Скрыть сетку",
      "room_3d_floor_plan_auto_align_on": "Выравнивание",
      "room_3d_floor_plan_auto_align_off": "Угол скана",
      "room_3d_floor_plan_adjust_north": "Север",
      "room_3d_floor_plan_adjust_north_title": "Настроить север",
      "room_3d_floor_plan_adjust_north_message":
          "Поверните, если компас не совпадает с реальностью. Диапазон ±180°.",
      "room_3d_floor_plan_adjust_north_reset": "Сбросить к скану",
      "room_3d_floor_plan_adjust_north_updated": "Ориентация севера обновлена",
      "room_3d_floor_plan_adjust_north_degrees_format": "%+.0f°",
      "room_3d_floor_plan_edit_dimension_title": "Изменить размер",
      "room_3d_floor_plan_edit_dimension_current": "Текущее",
      "room_3d_floor_plan_edit_dimension_new_value": "Новое значение (м)",
      "room_3d_floor_plan_edit_dimension_cancel": "Отмена",
      "room_3d_floor_plan_edit_dimension_apply": "Применить",
      "room_3d_floor_plan_edit_dimension_updated": "Размер обновлён",
      "room_3d_floor_plan_edit_dimension_large_change_title":
          "Большое изменение",
      "room_3d_floor_plan_edit_dimension_large_change_message":
          "Новое значение сильно отличается от результата сканирования. Применить исправление?",
      "room_3d_floor_plan_edit_dimension_invalid_title": "Неверное значение",
      "room_3d_floor_plan_edit_dimension_invalid_message":
          "Введите число от 0,5 до 100 метров.",
      "room_3d_floor_plan_edit_dimension_confirm_large_change": "Применить",
      "room_3d_floor_plan_unit_meters": "метры",
      "room_3d_floor_plan_object_bed": "Кровать",
      "room_3d_floor_plan_object_sofa": "Диван",
      "room_3d_floor_plan_object_table": "Стол",
      "room_3d_floor_plan_object_chair": "Стул",
      "room_3d_floor_plan_object_storage": "Хранение",
      "room_3d_floor_plan_object_appliance": "Техника",
      "room_3d_floor_plan_object_cabinet": "Шкаф",
      "room_3d_floor_plan_object_television": "ТВ",
      "room_3d_floor_plan_object_fixture": "Сантехника",
      "room_3d_floor_plan_object_unknown": "Объект",
      "room_3d_sun_toggle_label": "Солнечный свет",
      "room_3d_sun_toggle_hint": "Показать или скрыть симуляцию солнца",
      "room_3d_sun_azimuth_label": "Азимут",
      "room_3d_sun_elevation_label": "Высота",
      "room_3d_sun_intensity_label": "Яркость",
      "room_3d_sun_preset_morning": "Утро",
      "room_3d_sun_preset_noon": "Полдень",
      "room_3d_sun_preset_evening": "Вечер",
      "room_3d_sun_today": "Сегодня",
      "room_3d_sun_now": "Сейчас",
      "room_3d_sun_azimuth_format": "Аз %d°",
      "room_3d_sun_elevation_format": "Выс %d°",

      "profile_completed_success": "Профиль успешно завершен!",
      "profile_updated_success": "Профиль успешно обновлен",
      "auth_terms_finish_header": "Почти готово",
      "auth_terms_finish_title": "Ознакомьтесь с условиями",
      "auth_terms_finish_body":
          "Продолжая, вы соглашаетесь с Условиями использования, Политикой конфиденциальности и Правилами сообщества UyDosh.",
      "view_terms_of_service": "Открыть Условия использования",
      "could_not_open_terms_of_service":
          "Не удалось открыть Условия использования. Попробуйте снова.",

      "successfully_signed_in_google": "Успешный вход через Google!",
      "successfully_signed_in_apple": "Успешный вход через Apple!",
      "successfully_signed_in_telegram": "Успешный вход через Telegram!",

      // ===== EMPTY STATES =====
      "my_listings_empty_state": "Вы еще не создали ни одного объявления.",

      "no_locations_available": "Районы недоступны",

      "no_universities_available": "Университеты недоступны",
      "no_results": "Нет результатов",
      "no_search_results": "Нет результатов...",

      // ===== SELECTION & PROMPTS =====
      "select_metro_line": "Линия метро",
      "select_metro_line_title": "Выберите\nлинию метро",
      "metro_line_abbr": "лн.",
      "metro_station_abbr": "ст.",
      "select_location": "Любой район",
      "not_selected": "Не выбрано",
      "all": "Все",

      "all_stations_count": "Все {count} станций",
      "all_stations_count_one": "Вся {count} станция",
      "all_stations_count_few": "Все {count} станции",
      "all_stations_count_many": "Все {count} станций",
      "stations_count_one": "{count} станция",
      "stations_count_few": "{count} станции",
      "stations_count_many": "{count} станций",
      "all_stations_explanation":
          "Поиск вдоль всей линии <b>{line}</b> по <b>{count}</b> станциям",
      "entire_line_stations": "Вся линия {line}: {count} станций",
      "entire_line_stations_one": "Вся линия {line}: {count} станция",
      "entire_line_stations_few": "Вся линия {line}: {count} станции",
      "entire_line_stations_many": "Вся линия {line}: {count} станций",
      "metro_tutorial_line_hint":
          "Поиск объявлений на всех станциях линий метро",
      "metro_tutorial_station_hint": "Поиск по конкретным станциям метро",
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
      "country": "Страна",
      "city": "Город",
      "select_country": "Выберите страну",
      "tap_to_select_country": "Нажмите, чтобы выбрать страну",
      "no_regions_for_country": "Для этой страны регионы пока недоступны",

      // ===== ACTION BUTTONS =====
      "refresh": "Обновить",
      "actions": "Действия",

      "view_profile": "Профиль",
      "deactivate_listing": "Деактивировать",
      "deactivate_listing_confirmation":
          "Вы уверены, что хотите деактивировать это объявление? Оно больше не будет видно другим пользователям.",
      "deactivate": "Деактивировать",
      "activate_listing": "Активировать объявление",
      "activate_listing_confirmation":
          "Вы уверены, что хотите активировать это объявление? Оно станет видно другим пользователям.",
      "activate": "Активировать",
      "listing_active": "Активно",
      "listing_inactive": "Неактивно",

      "create_listing_button": "Создать",
      "wizard_step_counter": "Шаг {current} из {total}",
      "wizard_step_basics": "Основное",
      "wizard_step_location": "Локация",
      "wizard_step_details": "Детали",
      "wizard_step_description": "Описание",
      "wizard_step_review": "Проверка",
      "wizard_next": "Далее",
      "wizard_back": "Назад",
      "wizard_review_subtitle": "Проверьте, всё ли верно, и публикуйте.",
      "wizard_review_not_set": "Не указано",
      "wizard_amenities_count": "Выбрано: {count}",
      "wizard_photos_count": "Добавлено: {count}",
      "wizard_metro_value": "Линия {line} · {station}",
      "wizard_add_station": "Добавить станцию",
      "wizard_stations_hint":
          "Выберите линию и станцию, затем добавьте. Можно добавить несколько.",
      "wizard_selected_stations": "Выбранные станции",
      "wizard_stations_count": "Станций: {count}",
      "wizard_station_already_added": "Эта станция уже добавлена",
      "wizard_location_mode_metro": "По метро",
      "wizard_location_mode_district": "По районам",
      "all_locations_count": "Все районы: {count}",
      "wizard_locations_count": "Районов: {count}",
      "update_listing_button": "Обновить объявление",
      "save_changes": "Сохранить изменения",
      "changed_fields": "Изменено",
      "unsaved_changes_title": "Несохранённые изменения",
      "unsaved_changes_message":
          "У вас есть несохранённые изменения. Если выйти сейчас, они будут потеряны.",
      "keep_editing": "Продолжить",
      "leave_without_saving": "Выйти",
      "publish_consent_title": "Перед публикацией",
      "publish_consent_body":
          "Пожалуйста, соблюдайте правила сообщества UyDosh. Не публикуйте фейковые объявления, мошеннические предложения, незаконный контент, оскорбительные материалы, личные документы или чужие фотографии без разрешения.",
      "publish_consent_checkbox":
          "Я согласен с Условиями использования и Правилами сообщества UyDosh",
      "publish_consent_continue": "Продолжить",

      "confirm": "Подтвердить",
      "next": "Далее",
      "back": "Назад",
      "finish": "Готово",

      "complete": "Завершить",

      // ===== THEME & APPEARANCE =====
      "settings": "Настройки",
      "settings_section_account": "Аккаунт",
      "settings_section_preferences": "Предпочтения",
      "settings_section_experience": "Удобства",
      "settings_section_about": "О приложении",
      "settings_section_legal": "Правовая информация",
      "theme": "Тема",
      "system_theme": "Системная",
      "blue_theme": "Синяя",
      "light_theme": "Светлая",
      "theme_changed_to": "Тема изменена на {theme}",
      "theme_color": "Цвет темы",
      "switch_theme": "Переключить тему",
      "tooltips_toggle": "Подсказки",
      "tooltips_toggle_description": "Показывать подсказки и тултипы",

      // ===== ABOUT & FEATURES =====
      "about_description":
          "UyDosh - ваша надежная платформа для поиска идеального жилья в Ташкенте.",
      "about_feature_1": "Поиск объявлений по метро",
      "about_feature_2": "Поиск по районам",
      "about_feature_3": "Прямой контакт с владельцами",
      "about_feature_4": "Проверенные и безопасные объявления",

      // ===== METRO SYSTEM =====
      "open_in_yandex_maps": "Открыть в Яндекс Картах",
      "open_in_yandex_maps_confirmation":
          "Браузер с Яндекс Картами будет открыт.",

      // ===== LISTING DETAILS =====
      "listing_details": "Детали",
      "listing_detail_id": "ID объявления: {id}",
      "author": "Автор",
      "listing_views_by_others": "{count} просмотров",
      "listing_views_count_one": "{count} просмотр",
      "listing_views_count_few": "{count} просмотра",
      "listing_views_count_many": "{count} просмотров",
      "districts_count_one": "{count} Район",
      "districts_count_few": "{count} Района",
      "districts_count_many": "{count} Районов",
      "listing_views_stats_title": "Статистика просмотров",
      "listing_views_stats_empty": "Пока нет просмотров",
      "error_loading_view_stats": "Ошибка загрузки статистики просмотров",
      "promote_listing": "Поднять в топ",
      "remove_from_top": "Убрать с верха",
      "feature_listing_success": "Объявление поднято вверх",
      "unfeature_listing_success": "Объявление убрано с верха",
      "feature_listing_error": "Не удалось обновить объявление",
      "error_promotion_once_per_week":
          "Вы можете поднять объявление только раз в неделю",

      "listing_title_label": "Заголовок",

      "listing_description_hint": "Введите текст объявления",
      "listing_description_label": "Описание",
      "listing_address_field_label": "Адрес:",
      "listing_address_text_label": "Адрес (необязательно)",
      "use_current_location": "Моя геолокация",
      "location_services_disabled":
          "Геолокация выключена. Включите её, чтобы использовать текущее местоположение.",
      "location_permission_denied":
          "Для текущего местоположения нужен доступ к геолокации.",
      "current_location_address_failed":
          "Не удалось определить адрес по текущему местоположению.",
      "listing_title_hint": "Введите заголовок объявления",
      "view_similar_results": "Похожие объявления",
      "listing_detail_nearby_room_offers": "Найти жилье",
      "listing_detail_nearby_room_seekers": "Ищут жильё рядом",
      "listing_detail_nearby_matches": "Подходящие рядом",
      "listing_detail_nearby_stores_title": "Магазины рядом",
      "listing_detail_nearby_stores_subtitle":
          "Продуктовые магазины рядом с этим жильём.",
      "listing_detail_nearby_stores_meters": "м",
      "listing_detail_nearby_stores_kilometers": "км",
      "coming_soon": "Скоро будет",
      "listing_price_label": "Цена",
      "listing_translate_tooltip_en": "Перевести на английский",
      "listing_translate_tooltip_ru": "Перевести на русский",
      "listing_translate_tooltip_uz": "Перевести на узбекский",
      "listing_show_original_description": "Оригинал",
      "listing_translating_description": "Перевод…",
      "listing_translation_error": "Не удалось перевести. Попробуйте снова.",
      "listing_translation_unavailable": "Перевод недоступен.",
      "listing_translation_quota_exceeded":
          "Лимит бесплатных переводов объявлений на месяц исчёрпан. Подключите премиум через Payme или Click.",
      "listing_translation_sign_in_required":
          "Войдите в аккаунт, чтобы переводить описание объявления.",
      "listing_ai_enhance_quota_exceeded":
          "Лимит бесплатных улучшений AI на месяц исчёрпан. Подключите премиум через Payme или Click.",
      "chat_translated_from_en": "Переведено с 🇺🇸",
      "chat_translated_from_ru": "Переведено с 🇷🇺",
      "chat_translated_from_uz": "Переведено с 🇺🇿",
      "chat_show_original": "Показать оригинал",
      "chat_show_translation": "Показать перевод",
      "listing_ai_enhance": "Улучшить с AI",
      "listing_ai_enhance_empty": "Сначала введите текст.",
      "listing_ai_enhance_unavailable": "Улучшение с AI недоступно.",
      "listing_ai_enhance_error":
          "Не удалось улучшить текст. Попробуйте снова.",
      "listing_description_dictate": "Диктовка",
      "listing_description_character_count": "Символов: ",
      "listing_description_dictate_mic_denied":
          "Для диктовки нужен доступ к микрофону.",
      "listing_description_dictate_failed":
          "Не удалось распознать речь. Попробуйте снова.",
      "listing_description_dictate_not_configured":
          "Распознавание речи пока недоступно. Попробуйте позже.",
      "ai_allowance_banner_title": "Использование AI-помощника",
      "ai_allowance_meter_translate":
          "Осталось переводов объявлений (UTC-месяц): {count}",
      "ai_allowance_meter_enhance": "Осталось улучшений описания AI: {count}",
      "ai_allowance_meter_chat": "Осталось переводов в чате: {count}",
      "ai_allowance_meter_unlimited": "Без лимита",
      "ai_allowance_premium_active_until": "AI Premium до {date}",
      "ai_allowance_month_reset_note":
          "Лимиты обновляются каждый календарный месяц (UTC).",
      "ai_allowance_upgrade_cta": "Узнать про Premium",
      "ai_quota_exceeded_sheet_title": "Достигнут месячный лимит AI",
      "ai_quota_exceeded_sheet_body":
          "Лимит на этот период израсходован. Premium даёт более высокие лимиты. Сброс — 1-го числа каждого месяца (UTC).",
      "ai_quota_exceeded_sheet_dismiss": "ОК",
      "ai_premium_placeholder_title": "AI Premium",
      "ai_premium_placeholder_body":
          "Оплата AI Premium (Payme / Click) в приложении скоро появится здесь.",
      "ai_allowance_inline_chat_hint":
          "Переводов в чате в этом месяце (UTC): {count}",
      "listing_description_template_label": "Шаблон",
      "listing_description_template_room_needed":
          "Ищу комнату/подселение.\nФормат: (отдельная/подселение).\nСрок: (заезд + на сколько).\nВажно: (тихо/гости/животные).",
      "listing_description_template_roommate_needed_male":
          "Ищу соседа.\nФормат: (1–2 в комнате).\nКто уже живёт: (сколько человек).\nУсловия: (с хозяйкой/без), (отдельная/общая комната).\nСрок: (заезд) + (на сколько).",
      "listing_description_template_roommate_needed_female":
          "Ищу соседку.\nФормат: (1–2 в комнате).\nКто уже живёт: (сколько человек).\nУсловия: (с хозяйкой/без), (отдельная/общая комната).\nСрок: (заезд) + (на сколько).",
      "listing_description_template_group_forming":
          "Собираем группу для совместной аренды.\nКого ищем: (1–2 человека, пол/возраст).\nБюджет на человека: (сумма).\nРайон/метро: (где ищем).\nФормат: (отдельные/общие комнаты).\nЗаезд: (дата + срок).\nВажно: (чистота/тишина/гости/животные).",

      "listing_type_roommate_needed": "Ищу Соседа",
      "listing_type_roommate_needed_female": "Ищу соседку",
      "listing_type_room_needed": "Ищу Жильё",
      "listing_type_label": "Тип объявления",
      "listing_type_short_roommate_needed": "Ищем Соседа",
      "listing_type_short_roommate_needed_female": "Ищем Соседку",
      "listing_type_short_room_needed": "Ищу Комнату",
      "listing_type_short_group_forming": "Собираем Группу",
      "gender_short_male": "Парень",
      "gender_short_female": "Девушка",
      "gender_badge_male": "Парня",
      "gender_badge_female": "Девушка",
      "listing_photo_coming_soon": "Фото скоро",
      "price_unit_uzs_per_month": "сум/мес",
      "price_unit_usd_per_month": "\$/мес",
      "title_male_roommate": "#ИщемСоседа",
      "title_female_roommate": "#ИщемСоседку",
      "title_male_room": "#ИщуКомнату",
      "title_female_room": "#ИщуКомнату",
      "listing_photos_label": "Фотографии",
      "listing_photos_count": "Фото {current} / {max}",

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
      "drag_photo_to_reorder": "Перетащите для сортировки. Первое — основное.",
      "make_photo_primary": "Сделать основным",
      "making_primary": "Создание основного...",
      "add_photo": "Добавить фото",
      "take_photo": "Сделать фото",
      "choose_from_gallery": "Выбрать из галереи",
      "photo_limit_reached": "Максимум {max} фотографий",
      "retake": "Переснять",
      "use_photo": "Использовать",
      "flash": "Вспышка",
      "camera_unavailable": "Камера недоступна",
      "error_picking_photo": "Не удалось загрузить фото",
      "upload_profile_photo": "Загрузить фото профиля",
      "profile_photo_updated": "Фото профиля обновлено",
      "error_uploading_profile_photo": "Не удалось загрузить фото профиля",
      "crop_profile_photo": "Обрезать фото",
      "crop_listing_photo": "Обрезать фото",
      "crop_done": "Готово",
      "crop_cancel": "Отмена",
      "crop_rotate_left": "Повернуть влево",
      "crop_rotate_right": "Повернуть вправо",
      "crop_aspect_free": "Свободно",

      // Permission rationale screens
      "permission_camera_title": "Фото для объявления",
      "permission_camera_body":
          "UyDosh нужен доступ к камере, чтобы вы могли снимать фото объявления прямо в приложении. Мы автоматически добавляем водяной знак UyDosh, чтобы фото нельзя было использовать в чужих объявлениях.",
      "permission_camera_room_scan_title": "3D‑скан комнаты",
      "permission_camera_room_scan_body":
          "UyDosh нужен доступ к камере, чтобы снять LiDAR‑скан комнаты. 3D‑модель загружается в объявление, чтобы люди понимали пространство до просмотра.",
      "permission_camera_cta": "Разрешить доступ к камере",
      "permission_camera_denied_title": "Доступ к камере выключен",
      "permission_camera_denied_body":
          "Доступ к камере отключён в настройках iOS. Откройте Настройки, чтобы включить его, или выберите фото из галереи.",
      "permission_camera_open_settings": "Открыть настройки",
      "permission_camera_use_gallery": "Выбрать из галереи",
      "permission_notifications_title": "Мгновенные уведомления",
      "permission_notifications_body":
          "Включите уведомления, чтобы узнавать о новых объявлениях по вашему поиску в момент их публикации и получать пинг, когда вам пишут об объявлении.",
      "permission_notifications_cta": "Включить уведомления",
      "permission_notifications_denied_body":
          "Уведомления отключены в настройках iOS. Откройте Настройки, чтобы включить их, и тогда уведомления о новых объявлениях смогут до вас доходить.",
      "permission_not_now": "Не сейчас",
      "permission_skip": "Пропустить",
      "crop_undo": "Отменить",
      "crop_aspect_ratio": "Пропорции",

      "max_photos_reached": "Достигнут максимум фотографий",
      "max_photos_message": "Вы можете загрузить максимум {max} фото.",

      "ok": "ОК",
      "delete": "Удалить",

      // ===== ONBOARDING =====
      "onboarding_title_1": "Найди своих",
      "onboarding_subtitle_1":
          "Проверенные соседи, честные объявления\nи совместная аренда без лишних людей.",
      "onboarding_title_2": "Ищи там, где удобно жить",
      "onboarding_subtitle_2":
          "Выбирай метро, район или вуз —\nмы покажем подходящие квартиры и соседей рядом.",
      "onboarding_title_3": "Поиск по району",
      "onboarding_subtitle_3": "Удобный поиск по районам Ташкента",
      "onboarding_title_4": "Без риэлторов и чужих",
      "onboarding_subtitle_4":
          "Мы строим честное комьюнити:\nпроверенные профили, жалобы и защита от мошенников.",

      "onboarding_get_started": "Начать",
      "onboarding_skip": "Пропустить",
      "onboarding_next": "Далее",
      "onboarding_back": "Назад",
      "onboarding_toggle": "Обучение",
      "onboarding_toggle_description": "Показать приветствие",
      "haptic_feedback": "Виброотклик",
      "haptic_feedback_description": "Вибрация при нажатиях и жестах",
      "restore_filters_on_start": "Восстанавливать фильтры при запуске",
      "restore_filters_on_start_description":
          "Применять последние фильтры поиска при открытии приложения. Отключите, чтобы каждый раз начинать с чистого поиска.",
      "sound_effects": "Звуковые эффекты",
      "sound_effects_description": "Короткие UI-звуки для действий",
      "ui_animations": "Анимации интерфейса",
      "ui_animations_description": "Эффекты движения: пульсация и качание",
      "ui_animations_optimized_for_device":
          "Оптимизировано для этого устройства",
      "ui_animation_search_pulse": "Пульсация кнопки поиска",
      "ui_animation_bell_idle": "Качание колокольчика",
      "ui_animation_bell_tap": "Анимация колокольчика при тапе",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "Русский",
      "language": "Язык",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_name_english": "Английский",
      "language_name_russian": "Русский",
      "language_name_uzbek": "Узбекский",
      "language_changed_to": "Язык изменен на {language}",
      "price_display_currency": "Валюта цен",
      "price_display_currency_national": "🇺🇿 Сум",
      "price_display_currency_usd": "🇺🇸 Доллар",

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
      "open_in_telegram": "Telegram",
      "open_in_telegram_confirmation":
          "Telegram откроется в приложении или браузере.",

      // New profile fields
      "work": "Работа",
      "employed": "Работаю",
      "not_employed": "Не работаю",
      "cleanliness": "Чистоплотность",
      "noise_level": "Уровень шума",
      "sociability": "Общительность",
      "guests": "Гости",
      "guests_allowed": "Гости разрешены",
      "guests_permitted": "Разрешены",
      "guests_not_permitted": "Не разрешены",
      "smoking_preference": "Курение",
      "alcohol_preference": "Алкоголь",
      "cooking_habits": "Готовка",
      "pets_preference": "Отношение к животным",
      "wakeup_time": "Время подъема",
      "sleep_time": "Время сна",
      "sleep_schedule": "Режим сна",

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
      "pets_like_pets": "Люблю животных",
      "pets_dont_like_pets": "Не люблю животных",
      "pets_have_cat": "Есть кот",
      "pets_have_dog": "Есть собака",

      // Slider labels
      "lifestyle_preferences": "Образ жизни",
      "what_im_looking_for": "Что я ищу",
      "what_im_looking_for_subtitle": "Поможет точнее подобрать соседей",
      "preferred_roommate_gender": "Желаемый пол соседа",
      "any_gender": "Любой",
      "your_birth_year": "Ваш год рождения",
      "birth_year_hint": "напр. 2000",
      "desired_age_range": "Желаемый возраст соседа",
      "age_from_hint": "От",
      "age_to_hint": "До",
      "your_budget_range": "Ваш бюджет в месяц",
      "budget_from_hint": "От",
      "budget_to_hint": "До",
      "require_budget_overlap": "Бюджеты должны совпадать",
      "dealbreakers_label": "Неприемлемо",
      "dealbreakers_hint":
          "Принципиально — несовпадение резко снижает совместимость",
      "top_priorities_label": "Главные приоритеты",
      "top_priorities_hint": "Учитываются сильнее (до 3)",
      "match_dim_gender": "Пол",
      "match_dim_age": "Возраст",
      "match_dim_budget": "Бюджет",
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
      "cook": "Готовлю дома",
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
      "select_your_primary_role": "Основная роль",
      "tap_to_select_primary_role": "Выберите роль",

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
      "menu_language": "Язык",

      "menu_favorites": "Избранное",
      "nav_my": "Моё",
      "menu_history": "История",
      "menu_contact_support": "Связаться с поддержкой",
      "menu_add_listing": "Добавить объявление",
      "menu_my_listings": "Мои объявления",
      "menu_my_groups": "Мои группы",
      "my_hub_tab_groups": "Группы",
      "my_hub_tab_bookmarks": "Мои закладки",
      "my_hub_tab_alerts": "Мои оповещения",
      "my_groups_empty_subtitle":
          "Группы, которыми вы управляете или к которым присоединились, появятся здесь.",
      "menu_gigs": "Услуги",

      // ===== GIGS =====
      "gigs_hub_title": "Услуги",
      "gigs_hub_browse_title": "Найти исполнителя",
      "gigs_hub_browse_subtitle": "Кто может помочь с вашей задачей",
      "gigs_hub_post_title": "Опубликовать задачу",
      "gigs_hub_post_subtitle": "Опишите задачу — исполнители предложат цену",
      "gigs_hub_my_bookings_title": "Мои заказы",
      "gigs_hub_my_bookings_subtitle":
          "Задачи, которые вы заказали или приняли",
      "gigs_hub_open_requests_title": "Открытые задачи",
      "gigs_hub_open_requests_subtitle": "Задачи от заказчиков",
      "gigs_hub_publish_offer_title": "Опубликовать услугу",
      "gigs_hub_publish_offer_subtitle":
          "Предложите свои навыки — клиенты сами вас найдут",
      "gigs_hub_publish_title": "Опубликовать",
      "gigs_hub_publish_subtitle":
          "Задача, которую нужно сделать, или услуга, которую вы оказываете",
      "gigs_publish_screen_title": "Опубликовать",
      "gigs_publish_mode_task": "Задача",
      "gigs_publish_mode_task_subtitle": "мне нужно что-то сделать",
      "gigs_publish_mode_service": "Услуга",
      "gigs_publish_mode_service_subtitle": "я умею что-то делать",
      "gigs_hub_feed_services": "Услуги",
      "gigs_hub_feed_tasks": "Задачи",

      "gigs_browse_title": "Услуги",
      "gigs_browse_empty": "Пока нет доступных услуг",
      "gigs_offer_detail_title": "Услуга",
      "gigs_offer_book_cta": "Заказать услугу",
      "gigs_offer_book_view_orders_cta": "Заказано: чат с {user_name}",
      "gigs_offer_edit_cta": "Редактировать услугу",
      "gigs_offer_provider_fallback": "Исполнитель",
      "gigs_offer_provider_completed_jobs": "Выполнено заказов: {count}",
      "gigs_offer_tile_jobs_one": "{count} заказ",
      "gigs_offer_tile_jobs_few": "{count} заказа",
      "gigs_offer_tile_jobs_many": "{count} заказов",
      "gigs_offer_tile_reviews_one": "{count} отзыв",
      "gigs_offer_tile_reviews_few": "{count} отзыва",
      "gigs_offer_tile_reviews_many": "{count} отзывов",
      "gigs_booking_created_toast": "Заказ создан.",

      "gigs_post_request_title": "Опубликовать задачу",
      "gigs_post_request_submit": "Опубликовать",
      "gigs_loading": "Загрузка…",
      "gigs_categories_unavailable":
          "Категории недоступны. Нажмите, чтобы повторить.",
      "gigs_post_request_field_category": "Категория",
      "gigs_post_request_field_title": "Название",
      "gigs_post_request_field_description": "Описание (необязательно)",
      "gig_description_template_service":
          "Что предлагаю:\n(Объём — что входит)\n\nГде и когда:\n(Район или удалённо) · (сроки / доступность)\n\nПримечания:\n(опыт, материалы и т.д.)",
      "gig_description_template_task":
          "Что нужно сделать:\n(Опишите задачу)\n\nГде и когда:\n(Адрес или удалённо) · (дата/время)\n\nДоступ / примечания:\n(парковка, инструменты, ограничения)",
      "gigs_post_request_field_budget_type": "Тип бюджета",
      "gigs_post_request_field_amount": "Сумма",
      "gigs_post_request_field_address": "Адрес (необязательно)",
      "gigs_post_field_address_detail": "Подробный адрес (необязательно)",
      "address_suggest_connection_error":
          "Не удалось загрузить подсказки адреса. Проверьте подключение к интернету.",
      "address_suggest_unavailable": "Подсказки адреса временно недоступны.",
      "address_suggest_failed": "Не удалось загрузить подсказки адреса.",
      "gigs_post_field_district": "Район (необязательно)",
      "gigs_post_request_field_remote": "Удалённо",
      "gigs_post_request_required": "Обязательное поле",
      "gigs_post_request_choose_category": "Выберите категорию",
      "gigs_post_request_success_toast": "Задача опубликована.",
      "gigs_budget_type_fixed": "Фиксированный",
      "gigs_budget_type_hourly": "Почасовой",
      "gigs_budget_type_open": "Открытый",

      "gigs_post_offer_title": "Опубликовать услугу",
      "gigs_post_offer_submit": "Опубликовать",
      "gigs_post_offer_success_toast": "Услуга опубликована.",
      "gigs_edit_offer_title": "Редактировать услугу",
      "gigs_edit_offer_submit": "Сохранить",
      "gigs_edit_offer_success_toast": "Услуга обновлена.",
      "gigs_edit_request_title": "Редактировать задачу",
      "gigs_edit_request_success_toast": "Задача обновлена.",
      "gigs_request_edit_cta": "Редактировать задачу",
      "gigs_request_delete_menu": "Удалить задачу",
      "gigs_request_delete_title": "Удалить задачу?",
      "gigs_request_delete_message":
          "Задача пропадёт из списка для всех. В приложении это действие нельзя отменить.",
      "gigs_request_delete_success": "Задача удалена.",
      "gigs_request_delete_failed":
          "Не удалось удалить задачу. Попробуйте снова.",
      "gigs_offer_delete_menu": "Удалить услугу",
      "gigs_offer_delete_title": "Удалить услугу?",
      "gigs_offer_delete_message":
          "Услуга пропадёт из списка для всех. В приложении это действие нельзя отменить.",
      "gigs_offer_delete_success": "Услуга удалена.",
      "gigs_offer_delete_failed":
          "Не удалось удалить услугу. Попробуйте снова.",
      "gigs_post_offer_field_pricing_type": "Тип цены",
      "gigs_post_offer_field_price": "Цена",
      "gigs_post_offer_field_min_duration": "Минимальная длительность (мин)",
      "gigs_post_offer_field_min_duration_hint": "например, 60",
      "gigs_pricing_type_fixed": "Фиксированная",
      "gigs_pricing_type_hourly": "Почасовая",
      "gigs_pricing_type_per_unit": "За единицу",

      "gigs_my_bookings_title": "Мои заказы",
      "gigs_my_bookings_tab_all": "Все",
      "gigs_my_bookings_tab_client": "Как заказчик",
      "gigs_my_bookings_tab_provider": "Как исполнитель",
      "gigs_my_bookings_empty": "Заказов пока нет.",
      "gigs_my_published_title": "Мои публикации",
      "gigs_my_published_tab_services": "Услуги",
      "gigs_my_published_tab_tasks": "Задачи",
      "gigs_my_published_add_service": "Добавить услугу",
      "gigs_my_published_add_task": "Добавить задачу",
      "gigs_my_published_empty_services": "Вы ещё не опубликовали услуги.",
      "gigs_my_published_empty_tasks": "Вы ещё не публиковали задачи.",
      "gigs_my_published_sign_in":
          "Войдите, чтобы увидеть опубликованные услуги и задачи.",
      "gigs_action_cancel": "Отменить",
      "gigs_action_mark_complete": "Завершить",
      "gigs_status_pending": "Ожидает",
      "gigs_status_accepted": "Принято",
      "gigs_status_in_progress": "В процессе",
      "gigs_status_completed": "Завершено",
      "gigs_status_cancelled": "Отменено",
      "gigs_status_disputed": "Спор",

      "gigs_chat_menu_invite_provider_to_book": "Пригласить подтвердить заказ",
      "gigs_invite_provider_dialog_title": "Пригласить исполнителя",
      "gigs_invite_provider_dialog_body":
          "Он должен принять заказ во вкладке «Мои заказы», прежде чем всё будет подтверждено. Введите сумму, если в задаче открытый бюджет.",
      "gigs_invite_provider_dialog_field_hint":
          "Согласованная сумма (если в задаче нет суммы)",
      "gigs_invite_provider_confirm": "Отправить приглашение",
      "gigs_invite_provider_success_toast":
          "Приглашение отправлено. Принять можно во вкладке «Мои заказы».",
      "gigs_invite_provider_failed_toast":
          "Не удалось отправить. Попробуйте ещё раз.",
      "gigs_invite_provider_amount_required":
          "Укажите сумму или задайте бюджет в задаче.",
      "gigs_invite_provider_owner_only":
          "Пригласить может только автор задачи.",
      "gigs_invite_provider_not_open_task":
          "Эта задача уже не доступна для приглашения.",
      "gigs_action_accept_booking": "Принять",
      "gigs_action_chat_booking": "Чат",
      "gigs_booking_chat_peer_fallback": "Участник",
      "gigs_booking_cancel_confirm_title": "Отменить заказ?",
      "gigs_booking_cancel_confirm_message":
          "Второй участник получит уведомление.",

      "gigs_requests_title": "Открытые задачи",
      "gigs_requests_empty": "Сейчас нет открытых задач.",
      "gigs_request_budget_open": "Бюджет не указан",
      "gigs_request_budget_fixed": "Бюджет: {amount} {currency}",
      "gigs_request_detail_title": "Задача",
      "gigs_request_description_label": "Об этой задаче",
      "gigs_request_contact_cta": "Написать заказчику",
      "gigs_request_contact_failed":
          "Не удалось открыть чат. Попробуйте снова.",
      "gigs_request_messages_appbar_semantics": "Чаты по этой задаче",
      "gigs_request_messages_title": "Чаты по задаче",
      "gigs_request_messages_empty": "Пока нет переписки по этой задаче.",
      "gigs_request_messages_empty_subtitle":
          "Когда исполнители напишут вам, диалоги появятся в этом списке.",

      "gigs_price_per_hour": "{amount} {currency} / час",
      "gigs_price_per_unit": "{amount} {currency}/ед.",
      "gigs_price_fixed": "{amount} {currency}",
      "gigs_retry": "Повторить",
      "gigs_scheduled_at": "Запланировано: {when}",

      "menu_about": "О приложении",
      "menu_privacy_policy": "Политика конфиденциальности",
      "menu_user_license_agreement": "Лицензионное соглашение пользователя",
      "menu_faq": "Вопросы и ответы",
      "menu_settings": "Настройки",
      "menu_registration": "Вход",
      "menu_logout": "Выйти",
      "menu_admin_panel": "Админ-панель",
      "profile_menu_collapsible_listings_group": "Объявления и чаты",
      "profile_menu_collapsible_services_group": "Уведомления и поддержка",
      "manage_property": "Управление жильём",

      "admin_panel_title": "Админ-панель",
      "admin_panel_category_management": "Пользователи и модерация",
      "admin_panel_category_maps": "Карты",
      "admin_panel_category_analytics": "Аналитика",
      "admin_panel_category_settings": "Настройки приложения",
      "admin_panel_section_content_moderation": "Настройки клиента",
      "admin_content_moderation_title": "Настройки клиента",
      "admin_client_settings_show_listing_contacts":
          "Показывать контакты в объявлениях",
      "admin_client_settings_show_listing_contacts_description":
          "Telegram и звонок в «Совместимости» при указанных контактах.",
      "admin_client_settings_show_price_insights":
          "Показывать ориентир по цене",
      "admin_client_settings_show_price_insights_description":
          "Медиана цены по району/станции в карточке объявления.",
      "admin_client_settings_show_push_debug": "Показывать отладку push",
      "admin_client_settings_show_push_debug_description":
          "Показывает инструменты отладки push-уведомлений на экране «Уведомления» (только для админов).",
      "admin_client_settings_show_listing_move_to_top":
          "Показывать управление «поднять в топ»",
      "admin_client_settings_show_listing_move_to_top_description":
          "Кнопка «поднять в топ» у владельца на экране объявления, пункт в меню админа и долгое нажатие на плитку в ленте.",
      "admin_client_config_hide_gemini_listing_ui":
          "Показывать перевод и улучшение ИИ",
      "admin_client_config_hide_gemini_listing_ui_description":
          "Кнопки языка в описании и «Улучшить ИИ» при создании/редактировании.",
      "admin_client_config_disable_custom_camera":
          "Использовать кастомную камеру",
      "admin_client_config_disable_custom_camera_description":
          "Вкл — камера приложения с водяным знаком; выкл — системная.",
      "admin_client_config_show_listing_dictation_meter":
          "Индикатор уровня и таймер диктовки",
      "admin_client_config_show_listing_dictation_meter_description":
          "Волна и таймер при диктовке; иначе только микрофон/стоп.",
      "admin_client_config_disable_lidar_room_scan":
          "Включить сканирование LiDAR",
      "admin_client_config_disable_lidar_room_scan_description":
          "Шаг скана после создания, кнопка в редакторе, загрузка.",
      "admin_content_moderation_blur_enabled":
          "Проверять и размывать нежелательные фото",
      "admin_content_moderation_loading": "Загрузка настроек модерации...",
      "admin_content_moderation_error":
          "Не удалось загрузить настройки модерации",
      "admin_content_moderation_save_error": "Не удалось сохранить настройку",
      "admin_app_setting_listing_gig_moderation_queue_title":
          "Ручное одобрение новых объявлений и гигов",
      "admin_app_setting_listing_gig_moderation_queue_subtitle":
          "Новые объявления и гиги скрыты до одобрения админом.",
      "admin_app_setting_phone_sign_in_enabled_title":
          "Разрешить вход по номеру телефона",
      "admin_app_setting_phone_sign_in_enabled_subtitle":
          "SMS-вход через Firebase в мастере авторизации.",
      "admin_app_setting_listing_owner_conversations_title":
          "Чаты по объявлению (админ)",
      "admin_app_setting_listing_owner_conversations_subtitle":
          "Когда включено, админ может открыть все in-app диалоги по объявлению с его экрана.",
      "admin_app_setting_group_forming_membership_limit_title":
          "Максимум активных групп на пользователя",
      "admin_app_setting_group_forming_membership_limit_subtitle":
          "Учитываются группы, которые пользователь создал или к которым присоединился.",

      "admin_panel_section_telegram_sync": "Импорт данных",
      "admin_panel_section_telegram_listing_groups":
          "Группы объявлений Telegram",
      "admin_telegram_listing_groups_title": "Группы объявлений Telegram",
      "admin_telegram_listing_groups_loading": "Загрузка групп…",
      "admin_telegram_listing_groups_empty":
          "Импортированные объявления не найдены",
      "admin_telegram_listing_groups_detail_empty":
          "В этой группе нет объявлений",
      "admin_telegram_listing_groups_error":
          "Не удалось загрузить группы объявлений",
      "admin_telegram_listing_groups_unknown": "Без контакта (без группы)",
      "admin_telegram_listing_groups_listing_count": "Объявлений: {count}",
      "admin_telegram_listing_groups_summary_scraped":
          "Импортированные объявления",
      "admin_telegram_listing_groups_summary_groups": "Группы",
      "admin_telegram_listing_groups_summary_duplicates":
          "Группы с дубликатами",
      "admin_telegram_listing_groups_summary_ungrouped":
          "Объявления без группы",
      "admin_telegram_listing_groups_sort_title": "Сортировка групп",
      "admin_telegram_listing_groups_sort_count": "Больше объявлений",
      "admin_telegram_listing_groups_sort_recent": "Недавняя активность",
      "admin_telegram_listing_groups_sort_name": "Имя (А–Я)",
      "admin_telegram_sync_title": "Импорт данных",
      "admin_telegram_sync_chat_label": "Чат",
      "admin_telegram_sync_chat_custom_label": "Другой чат (@handle или id)",
      "admin_telegram_sync_channel_custom": "Другой…",
      "admin_telegram_sync_channels_loading": "Загрузка каналов…",
      "admin_telegram_sync_add_channel": "Добавить канал",
      "admin_telegram_sync_add_channel_title": "Добавить Telegram-канал",
      "admin_telegram_sync_add_channel_label": "Канал",
      "admin_telegram_sync_add_channel_helper":
          "Вставьте @handle, t.me/handle или числовой id чата.",
      "admin_telegram_sync_add_channel_invalid":
          "Введите канал или id без пробелов.",
      "admin_telegram_sync_add_channel_save": "Добавить",
      "admin_telegram_sync_add_channel_done": "Добавлен {channel}.",
      "admin_telegram_sync_limit_label": "Лимит сообщений",
      "admin_telegram_sync_import_user_label": "ID владельца объявлений",
      "admin_telegram_sync_import_user_sync_only":
          "Только синк БД (без импорта объявлений)",
      "admin_telegram_sync_admins_loading": "Загрузка списка админов…",
      "admin_telegram_sync_admins_error": "Не удалось загрузить список админов",
      "admin_telegram_sync_admins_retry": "Повторить",
      "admin_telegram_sync_admins_empty": "Админов не найдено.",
      "admin_telegram_sync_newest_first": "Сначала новые",
      "admin_telegram_sync_skip_listing_import":
          "Без импорта объявлений (только БД)",
      "admin_telegram_sync_run": "Запустить синк",
      "admin_telegram_sync_running": "Выполняется…",
      "admin_telegram_sync_result_header": "Результат",
      "admin_telegram_sync_sync_section": "Синк БД",
      "admin_telegram_sync_listing_section": "Импорт объявлений",
      "admin_telegram_sync_log_scanned": "просканировано",
      "admin_telegram_sync_log_created": "создано",
      "admin_telegram_sync_log_skipped_no_peer": "пропущеноБезПира",
      "admin_telegram_sync_log_skipped_broadcast": "пропущеноБродкаст",
      "admin_telegram_sync_log_skipped_empty": "пропущеноПустое",
      "admin_telegram_sync_log_skipped_no_type": "пропущеноБезТипа",
      "admin_telegram_sync_log_skipped_failed": "пропущеноСОшибкой",
      "admin_telegram_sync_log_errors_title": "Ошибки:",
      "admin_telegram_sync_log_more": "… (ещё {count})",
      "admin_telegram_sync_invalid_chat_limit":
          "Укажите чат (например @roommateuz).",
      "admin_area_price_cache_section_title": "Кэш цен по району объявления",
      "admin_area_price_cache_run": "Обновить кэш цен",
      "admin_area_price_cache_running": "Пересчёт кэша…",
      "admin_area_price_cache_screen_body":
          "Пересобирает кэш медианы и средней аренды по станциям, линиям метро и районам (блок «ориентир по цене» в объявлении). Запускайте после крупного импорта из Telegram или если блок пустой.",
      "admin_telegram_export_section_title": "Скачать загруженные сообщения",
      "admin_telegram_export_intro":
          "Экспорт строк из telegram_ingested_messages в файл .jsonl (по одному JSON на строку). Без вызовов Telegram. Все чаты, объём ограничен числом строк.",
      "admin_telegram_export_max_rows_label": "Макс. строк",
      "admin_telegram_export_download": "Скачать экспорт",
      "admin_telegram_export_running": "Готовим файл…",
      "admin_telegram_export_invalid_max_rows": "Макс. строк: от 1 до 500000.",
      "admin_telegram_export_done":
          "Файл готов — поделитесь или сохраните из браузера.",
      "admin_data_import_danger_section_title": "Опасная зона",
      "admin_data_import_danger_intro":
          "Разрушительные операции, которые сбрасывают базу. Используйте на dev/staging перед повторным импортом. Нельзя отменить.",
      "admin_data_import_clear_listings_button": "Очистить таблицу объявлений",
      "admin_data_import_clear_listings_running": "Очистка объявлений…",
      "admin_data_import_clear_listings_confirm_title":
          "Очистить все объявления?",
      "admin_data_import_clear_listings_confirm_body":
          "Будут удалены все строки из таблицы listings. Также удалятся все фотографии, удобства, избранное, жалобы, чаты и загруженные сообщения из Telegram, ссылающиеся на объявления. ID-секвенсы сбросятся. Отменить нельзя.",
      "admin_data_import_clear_listings_done":
          "Удалено {listings_str} (и {ingested_str}).",
      "admin_data_import_clear_ingested_button":
          "Очистить загруженные сообщения Telegram",
      "admin_data_import_clear_ingested_running":
          "Очистка загруженных сообщений…",
      "admin_data_import_clear_ingested_confirm_title":
          "Очистить загруженные сообщения Telegram?",
      "admin_data_import_clear_ingested_confirm_body":
          "Будут удалены все строки из таблицы telegram_ingested_messages. Объявления остаются. ID-секвенс сбросится. Отменить нельзя.",
      "admin_data_import_clear_ingested_done": "Удалено {ingested_str}.",
      "listings_count_one": "{count} объявление",
      "listings_count_few": "{count} объявления",
      "listings_count_many": "{count} объявлений",
      "ingested_messages_count_one": "{count} загруженное сообщение",
      "ingested_messages_count_few": "{count} загруженных сообщения",
      "ingested_messages_count_many": "{count} загруженных сообщений",
      "admin_data_import_clear_confirm_action": "Очистить",
      "admin_panel_section_users": "Пользователи",
      "admin_reassign_ownership_submit": "Перенести",
      "admin_reassign_ownership_success": "Владелец обновлён",
      "admin_reassign_owner_menu": "Сменить владельца",
      "admin_reassign_owner_dialog_title": "Смена владельца",
      "admin_reassign_owner_search_placeholder": "Поиск по id, email или имени",
      "admin_reassign_owner_from_user": "ID владельца: {id}",
      "admin_reassign_owner_listing_id": "ID объявления: {id}",
      "admin_reassign_owner_gig_offer_id": "ID предложения: {id}",
      "admin_reassign_owner_gig_request_id": "ID заявки: {id}",
      "admin_reassign_owner_empty": "Пользователи не найдены.",
      "admin_panel_section_support_chat": "Поддержка",
      "admin_panel_section_complaints": "Жалобы",
      "admin_panel_section_listing_complaints": "Объявления с жалобами",
      "admin_panel_section_listing_moderation": "Модерация объявлений",
      "admin_listing_moderation_title": "На проверке",
      "admin_listing_moderation_loading": "Загрузка очереди модерации…",
      "admin_listing_moderation_error": "Не удалось загрузить очередь",
      "admin_listing_moderation_retry": "Повторить",
      "admin_listing_moderation_summary_total": "В очереди",
      "admin_listing_moderation_summary_today": "Сегодня",
      "admin_listing_moderation_summary_oldest": "Дольше всего",
      "admin_listing_moderation_days_short": "дн.",
      "admin_listing_moderation_section_list": "Ожидают проверки",
      "admin_listing_moderation_empty": "Нет объявлений, ожидающих одобрения.",
      "admin_listing_moderation_open": "Открыть",
      "admin_listing_moderation_approve": "Одобрить",
      "admin_listing_moderation_id": "ID",
      "admin_listing_moderation_user": "Пользователь",
      "admin_listing_moderation_load_more": "Ещё",
      "admin_listing_moderation_approved_toast": "Объявление опубликовано",
      "admin_listing_moderation_approve_confirm_title": "Одобрить объявление?",
      "admin_listing_moderation_approve_confirm_message":
          "Объявление будет опубликовано и станет видно всем.",
      "admin_parser_review_title": "Проверка парсера",
      "admin_parser_review_loading": "Загрузка проверки парсера…",
      "admin_parser_review_error": "Не удалось загрузить проверку парсера",
      "admin_parser_review_raw_source": "Исходный пост из Telegram",
      "admin_parser_review_raw_empty": "(в источнике нет текста)",
      "admin_parser_review_manual_source": "Объявление добавлено вручную",
      "admin_parser_review_manual_source_description":
          "Объявление добавлено пользователем вручную, не импортировано из Telegram.",
      "admin_parser_review_section_fields": "Парсер vs. текущие значения",
      "admin_parser_review_section_corrections": "Зафиксированные исправления",
      "admin_parser_review_parser_label": "Парсер",
      "admin_parser_review_current_label": "Текущее",
      "admin_parser_review_chip_added": "добавлено",
      "admin_parser_review_chip_removed": "удалено",
      "admin_parser_review_chip_changed": "изменено",
      "admin_parser_review_chip_confirmed": "подтверждено",
      "admin_parser_review_corrections_summary":
          "Исправлено полей: {changed} из {total}",
      "admin_parser_review_open_full": "Открыть объявление",
      "admin_parser_review_edit": "Изменить и исправить",
      "admin_parser_review_already_approved": "Уже одобрено",
      "admin_parser_review_field_title": "Заголовок",
      "admin_parser_review_field_price": "Цена (USD)",
      "admin_parser_review_field_gender": "Предпочтение по полу",
      "admin_parser_review_field_metro": "Метро",
      "admin_parser_review_field_district": "Район",
      "admin_parser_review_field_move_in": "Дата заселения",
      "admin_parser_review_field_contact_phone": "Контактный телефон",
      "admin_parser_review_field_contact_telegram": "Контакт в Telegram",
      "admin_parser_review_field_amenities": "Удобства",
      "admin_parser_review_field_description": "Описание",
      "admin_parser_review_owner_section": "Владелец в Telegram",
      "admin_parser_review_owner_hint": "username",
      "admin_parser_review_owner_help":
          "Telegram @username того, кто изначально опубликовал это объявление. Используется как контакт, если контакт в Telegram не указан.",
      "admin_parser_review_owner_save": "Сохранить владельца",
      "admin_parser_review_owner_saved": "Владелец в Telegram обновлён",
      "admin_panel_section_gig_moderation": "Модерация услуг и задач",
      "admin_gig_moderation_title": "Модерация объявлений (гига)",
      "admin_gig_moderation_tab_offers": "Услуги",
      "admin_gig_moderation_tab_requests": "Задачи",
      "admin_gig_moderation_section_offers": "Услуги на проверке",
      "admin_gig_moderation_section_requests": "Задачи на проверке",
      "admin_gig_moderation_empty_offers": "Нет услуг, ожидающих одобрения.",
      "admin_gig_moderation_empty_requests": "Нет задач, ожидающих одобрения.",
      "admin_gig_moderation_provider": "Исполнитель",
      "admin_gig_moderation_client": "Заказчик",
      "admin_gig_moderation_approved_offer_toast": "Услуга опубликована",
      "admin_gig_moderation_approved_request_toast": "Задача опубликована",
      "admin_panel_section_district_heatmap": "Тепловая карта районов",
      "admin_panel_section_subway_heatmap": "Тепловая карта линий метро",
      "admin_panel_section_subway_map": "Схема метро",
      "admin_panel_section_universities_map": "Карта университетов",
      "admin_universities_map_title": "Карта университетов",
      "admin_universities_map_error": "Не удалось загрузить университеты",
      "admin_universities_map_retry": "Повторить",
      "admin_universities_map_empty":
          "Пока нет университетов с координатами для карты.",
      "admin_panel_section_search_analytics": "Аналитика поиска",
      "admin_panel_section_listing_creation_analytics":
          "Аналитика создания объявлений",

      "admin_search_analytics_title": "Аналитика поиска",
      "admin_search_analytics_loading": "Загрузка аналитики поиска...",
      "admin_search_analytics_error": "Не удалось загрузить аналитику",
      "admin_search_analytics_retry": "Повторить",
      "admin_search_analytics_time_range": "Период",
      "admin_search_analytics_days": "За {days} дн.",
      "admin_search_analytics_days_one": "За {count} день",
      "admin_search_analytics_days_few": "За {count} дня",
      "admin_search_analytics_days_many": "За {count} дней",
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

      "admin_listing_creation_analytics_title": "Аналитика создания объявлений",
      "admin_listing_creation_analytics_loading":
          "Загрузка аналитики создания объявлений...",
      "admin_listing_creation_analytics_error":
          "Не удалось загрузить аналитику",
      "admin_listing_creation_analytics_retry": "Повторить",
      "admin_listing_creation_analytics_time_range": "Период",
      "admin_listing_creation_analytics_total": "Всего за период",
      "admin_listing_creation_analytics_today": "Сегодня",
      "admin_listing_creation_analytics_week": "За неделю",
      "admin_listing_creation_analytics_by_month": "Объявления по месяцам",
      "admin_listing_creation_analytics_no_data":
          "Нет данных за выбранный период",

      "admin_district_heatmap_title": "Тепловая карта районов",
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
      "admin_subway_heatmap_loading": "Загрузка статистики по линиям метро...",
      "admin_subway_heatmap_error":
          "Не удалось загрузить статистику по линиям метро",
      "admin_subway_heatmap_retry": "Повторить",
      "admin_subway_heatmap_total": "Всего объявлений",
      "admin_subway_heatmap_max": "Максимум на линии",
      "admin_subway_heatmap_count_label": "Объявления",
      "admin_subway_heatmap_unavailable": "Недоступно",
      "admin_subway_heatmap_no_data": "Нет данных по линиям метро",

      "admin_subway_map_title": "Схема метро",

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
      "admin_user_detail_role_save": "Сохранить роль",
      "admin_user_detail_role_updated": "Роль обновлена",
      "admin_user_detail_view_listings": "Объявления пользователя",
      "admin_user_detail_view_complaints": "Жалобы пользователя",
      "admin_user_detail_view_alerts": "Оповещения пользователя",
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
      "admin_user_detail_self_moderation_not_allowed":
          "Нельзя блокировать/разблокировать или менять роль у своего админ-аккаунта.",
      "admin_user_detail_devices_title": "Устройства",
      "admin_user_detail_devices_empty": "Нет зарегистрированных устройств",
      "admin_user_detail_devices_last_seen": "Последняя активность",
      "admin_user_detail_devices_model_unknown": "Неизвестное устройство",
      "admin_user_detail_devices_details_unknown": "Нет данных",
      "admin_user_detail_devices_app_prefix": "Приложение",
      "admin_user_complaints_title": "Жалобы пользователя",
      "admin_user_complaints_user": "Пользователь",
      "admin_user_complaints_empty": "Жалобы не найдены",
      "admin_user_complaints_group_count": "Жалобы",

      "admin_user_listings_title": "Объявления пользователя",
      "admin_user_listings_user": "Пользователь",
      "admin_user_listings_empty": "Объявления не найдены",
      "admin_user_listings_error": "Не удалось загрузить объявления",
      "admin_user_alerts_title": "Оповещения пользователя",
      "admin_user_alerts_empty": "Оповещений не найдено",

      "admin_complaints_title": "Жалобы",
      "admin_complaints_loading": "Загрузка жалоб...",
      "admin_complaints_empty": "Жалобы не найдены",
      "admin_complaints_error": "Не удалось загрузить жалобы",
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
      "admin_complaints_view_author": "Профиль пользователя",
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
      "admin_support_chat_days_ago_one": "{count} день назад",
      "admin_support_chat_days_ago_few": "{count} дня назад",
      "admin_support_chat_days_ago_many": "{count} дней назад",
      "admin_support_chat_no_messages": "Сообщений пока нет",
      "admin_support_chat_reply_hint": "Введите ответ...",
      "admin_support_chat_close_thread": "Закрыть обращение",
      "admin_support_chat_reopen_thread": "Открыть снова",
      "admin_support_chat_closed": "Обращение закрыто",
      "admin_support_chat_reopened": "Обращение открыто",
      "admin_support_chat_thread_closed":
          "Обращение закрыто. Откройте, чтобы ответить.",
      "contact_support_title": "Поддержка",
      "contact_support_loading": "Загрузка...",
      "contact_support_error": "Не удалось загрузить поддержку",
      "contact_support_empty":
          "Обращений пока нет. Создайте новое, чтобы получить помощь.",
      "contact_support_new": "Новое обращение",
      "contact_support_message_hint": "Введите сообщение...",
      "admin_listing_complaints_title": "Объявления с жалобами",
      "admin_listing_complaints_empty": "Объявлений с жалобами нет",
      "admin_listing_complaints_error":
          "Не удалось загрузить объявления с жалобами",
      "admin_listing_complaints_categories_empty": "Нет категорий жалоб",

      // ===== FAQ CONTENT =====
      "faq_question": "Как договариваться с соседями и избегать конфликтов?",
      "faq_answer":
          "Жить вместе — это всегда про уважение и умение договариваться. Вот несколько простых правил, которые помогут сохранить мир и дружбу:\n\nШум\nДоговоритесь о «тихих часах». Для музыки — наушники, для звонков — коридор или улица. Удобно повесить расписание, чтобы все знали, когда у кого учеба или отдых.\n\nГости\nПредупреждайте друг друга заранее. Хорошее правило — определённые дни для гостей и дни для тишины.\n\nЭмоции\nНе копите раздражение. Говорите спокойно и сразу, если что-то мешает. А лишний стресс лучше выплеснуть в спортзале или на пробежке.\n\nОбщие дела\nИногда полезно что-то делать вместе: сходить в кино, прогуляться, устроить «уборку под музыку». Общие воспоминания укрепляют дружбу.\n\nУборка и быт\nРазделите обязанности — кто-то моет пол, кто-то выносит мусор. Главное — договариваться и уважать личные границы. Чужие вещи без спроса не трогаем.\n\nОбщение\nИспользуйте «я-сообщения»: вместо «ты меня бесишь» лучше сказать «мне тяжело сосредоточиться, когда играет громкая музыка».\n\nРешение конфликтов\nСтарайтесь обсуждать всё спокойно, выслушивая друг друга. Конфликт — это повод найти общее решение, а не врага.\n\nЕда\nМожно договориться о совместных покупках или завести «общую полочку» для вкусняшек.\n\nПорядок и тишина\nГрафик уборки — лучший друг. А если нужно сосредоточиться — можно уйти в библиотеку или коворкинг, либо снова включить правило «тихого часа».",

      "faq_question_2": "Неожиданный счёт за чужую коммуналку",
      "faq_answer_2":
          "Иногда вместе с квартирой жильцу «в подарок» достаются и долги за коммунальные услуги. В итоге — отключённый свет или вода, а арендодатель не спешит платить. Жильцу остаётся выбирать: съезжать с убытками или гасить долг за свой счёт.\n\nЧтобы избежать таких ситуаций:\n\nПроверка перед подписанием\nПеред подписанием договора попросите у хозяина квитанции или отчёт об оплаченных коммунальных платежах.\n\nПисьменное соглашение\nЕсли долг всё-таки есть и вы готовы его оплатить, обязательно оформите письменное соглашение: сумма долга будет зачтена в счёт будущей аренды.\n\nТак вы сохраните и деньги, и спокойствие.",

      "faq_question_3": "Обещания арендодателя: ремонт, техника, мебель",
      "faq_answer_3":
          "Нередко при аренде жилья собственник обещает устранить неисправности в квартире, купить бытовую технику и мебель. Все это он обязуется исполнить сразу после заселения. Однако проходит время, а неисправности так и остаются. Чтобы не стать заложником подобной ситуации, арендатору следует прописать в договоре найма особые условия.\n\nТакже нередко нарушается устная договоренность о выполнении ремонта силами квартиранта и обязательство не взимать арендную плату во время проведения работ. Например, вы делаете ремонт квартиры за свой счет и не платите за аренду несколько месяцев. Однако некоторые арендодатели «забывают» о договоренностях и требуют оплаты проживания. Зачастую у сторон возникают разногласия по поводу стоимости отделки, а иногда дело и вовсе доходит до суда.\n\nПоэтому следует обсудить все моменты ремонта, учесть их в договоре найма, а также составить смету и подписать её.",

      "faq_question_4": "О Важности Договора",
      "faq_answer_4":
          "Часто при сдаче жилья родственникам или друзьям договор не заключаются. При этом, многие скандалы и разбирательства происходят как раз между родственниками и друзьями, которые приняли обещания и обязательства по аренде на словах. Поэтому лучше заключить договор, даже если вы снимаете квартиру у своего дяди или близкого друга.\n\nЕсть случаи, когда квартиры сдаются по доверенности, где указано: доверитель дает доверенному лицу право сдать его квартиру внаем. «Но в доверенности не прописано, что доверенное лицо имеет также право получать арендную плату. Может произойти ситуация: квартирант исправно вносит арендную сумму доверенному лицу, но однажды появляется собственник жилплощади и требует арендатора оплатить прошедший период проживания в квартире». В данном случае следует тщательно изучать документы, и если в доверенности не указано право на получение арендной платы, обсудить этот пункт.",

      "faq_question_5": "Гайд по безопасности для арендаторов и соседей",
      "faq_answer_5":
          "Иногда происходят неприятные ситуации не только на нашей платформе. К сожалению, неадекватные или озабоченные люди встречаются везде. Поэтому важно помнить о простых правилах безопасности.\n\n🙏 Главное — ваша безопасность!\n\nПеред встречей\n• Договаривайтесь о встречах только в дневное время.\n• Старайтесь выбирать людные места — кафе, торговый центр, двор с камерами.\n• Сообщите друзьям или родным, куда идёте и с кем встречаетесь.\n\nВо время встречи\n• По возможности приходите не одни.\n• Не передавайте деньги и документы «из рук в руки» до подписания договора.\n• Сохраняйте переписку и фото/сканы документов — это ваша защита.\n\nЕсли чувствуете угрозу\n• Немедленно прекращайте встречу и уходите.\n• Не бойтесь сказать «нет» и оборвать общение.\n• При явной опасности — звоните 102 или обращайтесь в ближайшее отделение РОВД.\n\nНа платформе UyDosh\n• Пользуйтесь системой верификации — проверенные профили снижают риск.\n• Сообщайте модераторам о подозрительных объявлениях и поведении.\n• Помните: лучше перестраховаться, чем потом сожалеть.\n\n❤️ Берегите себя и друг друга!",

      // ===== LOGOUT & SESSION =====
      "logout_confirmation": "Подтверждение выхода",
      "logout_description":
          "Вы уверены, что хотите выйти? Вам нужно будет снова войти, чтобы получить доступ к профилю.",
      "logout": "Выйти",
      "logout_success": "Вы успешно вышли из системы",
      "session_expired": "Сессия истекла. Пожалуйста, войдите снова.",

      // ===== DELETE ACCOUNT =====
      "delete_account": "Удалить аккаунт",
      "delete_account_confirmation":
          "Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить. Все ваши данные, объявления и сообщения будут безвозвратно удалены.",
      "delete_account_success": "Аккаунт успешно удалён",
      "delete_account_error": "Ошибка удаления аккаунта",
      "delete_account_blocked":
          "Ваш аккаунт ограничен. Вы не можете удалить аккаунт, пока он заблокирован. Обратитесь в службу поддержки.",
      "delete_account_not_allowed":
          "Этот аккаунт нельзя удалить из приложения. Если нужна помощь — обратитесь в поддержку.",

      // ===== FAVORITES =====
      "favorites_title": "Избранное",
      "favorites_empty_title": "Пока нет избранного",
      "favorites_tab_listings": "Жильё",
      "favorites_tab_services": "Услуги",
      "favorites_tab_tasks": "Задачи",
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
      "achievements_empty_desc":
          "Выполняйте действия, чтобы разблокировать достижения",
      "achievements_auth_prompt": "Войдите, чтобы просмотреть достижения",

      "favorite_toggle_error": "Не удалось обновить статус избранного",
      "favorite_toggle_network_error":
          "Ошибка сети при обновлении статуса избранного",

      "unable_to_load_favorites":
          "Не удалось загрузить избранное. Попробуйте позже.",

      // ===== CREATE & EDIT LISTING =====
      "create_listing_title": "Опубликовать",
      "edit_profile": "Редактировать профиль",
      "updating_listing": "Обновляется...",
      "creating_listing": "Создается...",
      "title_required": "Заголовок обязателен",
      "title_too_long": "Заголовок должен быть не более 50 символов",
      "description_required": "Текст обязателен",
      "description_too_long": "Текст должен быть не более 500 символов",
      "location_required": "Пожалуйста, выберите район",
      "location_metro_required": "Пожалуйста, выберите станцию метро",
      "location_district_required": "Пожалуйста, выберите район",
      "price_required": "Пожалуйста, укажите цену",
      "listing_price_minimum": "Цена должна быть не менее 1 USD в месяц",

      "auth_required_title": "Требуется аутентификация",
      "authentication_required":
          "Требуется аутентификация. Пожалуйста, войдите в систему для создания объявлений.",

      "unauthenticated_listing_prompt":
          "Для создания и размещения объявлений необходимо войти в свой аккаунт.",
      "authenticate_to_post_listing": "Войти для размещения объявления",
      "select_location_required": "Выберите район",
      "select_metro_line_optional": "Линия метро",
      "metro_station_label": "Станция метро",

      // ===== AMENITIES & FEATURES =====
      "amenities": "Удобства",
      "amenities_header_roommate_needed": "В квартире имеются:",
      "amenities_header_need_room": "Мне нужно:",
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
      "filters_bar_label": "Фильтры",
      "search_alert_notify_me": "Уведомлять о появлении",
      "search_alert_cta_title": "Уведомлять по этому поиску?",
      "search_alert_cta_create": "Создать уведомление",
      "search_clear_filters": "Сбросить фильтры",
      "search_alert_login_required":
          "Войдите, чтобы получать уведомления по этому поиску.",
      "search_alert_created":
          "Мы сообщим, когда появятся подходящие объявления.",
      "search_alert_already_exists": "Это уведомление уже было добавлено.",
      "search_alert_too_wide":
          "Чтобы сохранить оповещение, выберите район или линию/станцию метро.",
      "search_alert_failed":
          "Не удалось сохранить оповещение. Попробуйте снова.",
      "search_alert_station_already_covered":
          "Эта станция уже входит в ваши оповещения.",
      "search_alert_station_already_covered_by_line":
          "Станция {station} уже входит в ваше оповещение по линии {line}.",
      "search_alert_permission":
          "Включите уведомления в настройках, чтобы получать оповещения.",
      "search_alert_bell_hint": "Получать уведомления о похожих объявлениях",
      "tutorial_search_description":
          "Здесь можно выбрать район, цену и другие фильтры.",
      "tutorial_profile_description":
          "Здесь находятся ваш профиль и настройки аккаунта.",
      "tutorial_alert_bell_description":
          "Включите оповещение о новых объявлениях.",
      "tutorial_notifications_bell_description":
          "Ваши оповещения здесь. Нажмите, чтобы управлять ими.",

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
      "sign_in_with_google_or_apple": "Войти через Google или Apple",
      "sign_in_oauth_prompt": "Войдите, чтобы продолжить",
      "sign_in_oauth_continue": "Продолжить",
      "auth_wizard_oauth_step_header": "Войти в UyDosh",
      "successfully_logged_in": "Вы успешно вошли",

      "signing_in": "Вход в систему...",
      "google_sign_in_failed": "Ошибка входа через Google: {error}",
      "popup_closed": "Окно входа было закрыто",

      // ===== APPLE AUTHENTICATION (iOS only) =====
      "sign_in_with_apple": "Войти через Apple",
      "sign_in_with_telegram": "Войти через Telegram",
      "link_telegram": "Привязать Telegram",
      "unlink_telegram": "Отвязать Telegram",
      "telegram_account_linked": "Telegram привязан",
      "telegram_linked_success": "Telegram привязан к вашему аккаунту",
      "telegram_unlinked_success": "Telegram отвязан от вашего аккаунта",
      "telegram_unlinked_relink_hint":
          "Чтобы снова подключить Telegram, используйте «Привязать Telegram» в профиле — не «Войти через Telegram» на экране входа.",
      "telegram_already_linked": "Telegram уже привязан к этому аккаунту",
      "telegram_not_linked": "Telegram не привязан к этому аккаунту",
      "telegram_only_sign_in_method":
          "Сначала добавьте вход через Google, Apple или телефон, затем отвяжите Telegram",
      "telegram_unlink_failed": "Не удалось отвязать Telegram: {error}",
      "unlink_telegram_confirmation_title": "Отвязать Telegram?",
      "unlink_telegram_confirmation_message":
          "Вы больше не сможете входить через Telegram в этот аккаунт. Имя пользователя в профиле останется.",
      "telegram_account_in_use":
          "Этот Telegram уже привязан к другому аккаунту UyDosh",
      "telegram_link_failed": "Не удалось привязать Telegram: {error}",
      "telegram_bind_not_available":
          "Привязка Telegram пока недоступна. Обновите приложение или попробуйте позже.",
      "telegram_bind_invalid_token":
          "Сессия Telegram истекла. Попробуйте привязать снова.",
      "telegram_bind_not_configured":
          "Вход через Telegram временно недоступен на сервере.",
      "telegram_login_continue_in_browser":
          "Завершите вход в браузере, затем вернитесь в приложение.",
      "telegram_sign_in_failed": "Вход через Telegram не удался: {error}",
      "could_not_open_telegram": "Не удалось открыть Telegram",
      "telegram_alerts_enable_title": "Получать уведомления в Telegram?",
      "telegram_alerts_enable_body":
          "Сообщения и совпадения по поиску будут приходить в Telegram, если push недоступен.",
      "telegram_alerts_enable_button": "Включить в Telegram",
      "telegram_alerts_enable_waiting":
          "Подпишитесь в Telegram, затем вернитесь сюда.",
      "telegram_alerts_enabled_success": "Уведомления в Telegram включены",
      "telegram_alerts_enable_failed":
          "Не удалось открыть настройку Telegram-уведомлений. Попробуйте позже.",
      "telegram_alerts_settings_title": "Уведомления в Телеграм отключены",
      "telegram_alerts_settings_body":
          "Откройте @uydosh_bot в Telegram и подпишитесь на уведомления о сообщениях и совпадениях по поиску.",
      "telegram_alerts_settings_button": "Включить Телеграм уведомления",
      "telegram_alerts_settings_waiting":
          "Подпишитесь в @uydosh_bot, затем вернитесь сюда.",
      "telegram_alerts_connected": "Уведомления в Телеграм включены",
      "telegram_alerts_disable_button": "Отключить уведомления",
      "telegram_alerts_disabled_success": "Уведомления в Telegram отключены",
      "telegram_alerts_disable_failed":
          "Не удалось отключить уведомления в Telegram",
      "apple_sign_in_failed": "Ошибка входа через Apple: {error}",

      // ===== PHONE AUTHENTICATION =====
      "sign_in_with_phone": "Войти по номеру",
      "phone_sign_in_under_construction":
          "Вход по номеру в разработке. Пока воспользуйтесь Google или Apple.",
      "sign_in_with_phone_description":
          "Мы отправим SMS с 6-значным кодом для подтверждения номера.",
      "auth_separator_or": "или",
      "phone_number_example": "+998 90 123 45 67",
      "phone_send_code": "Отправить код",
      "phone_resend_code": "Отправить код ещё раз",
      "phone_resend_in_seconds": "Повторно через {seconds} с",
      "phone_invalid_format":
          "Введите номер с кодом страны (например, +998 90 123 45 67).",
      "phone_code_entry_title": "Введите 6-значный код",
      "phone_code_entry_description": "Отправлен на {phone}",
      "phone_code_invalid": "Код неверный или просрочен.",
      "phone_verify": "Подтвердить",
      "phone_verifying": "Проверка...",
      "phone_verification_failed": "Ошибка подтверждения: {error}",
      "phone_too_many_requests":
          "Слишком много попыток. Попробуйте через несколько минут.",
      "phone_quota_exceeded":
          "Подтверждение по телефону временно недоступно. Попробуйте позже.",
      "change_phone_number": "Изменить номер",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Посмотрите это объявление на UyDosh!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Связаться с пользователем",
      "follow": "Подписаться",
      "following": "Подписан",
      "followers_count_one": "{count} подписчик",
      "followers_count_few": "{count} подписчика",
      "followers_count_many": "{count} подписчиков",
      "following_count_one": "{count} подписка",
      "following_count_few": "{count} подписки",
      "following_count_many": "{count} подписок",
      "followers_list_title": "Подписчики",
      "following_list_title": "Подписки",
      "no_followers_yet": "Пока нет подписчиков",
      "no_following_yet": "Пока нет подписок",
      "common_connections": "Общие связи",
      "common_connections_count": "{count}",
      "message": "Написать в чат",
      "uydosh_chat": "Чат UyDosh",
      "admin_listing_contacts": "Контакты объявления (админ)",

      // ===== STATUS & STATE =====
      "delete_listing": "Удалить объявление",
      "delete_listing_confirmation":
          "Вы уверены, что хотите удалить это объявление? Это действие нельзя отменить.",
      "delete_listing_success": "Объявление успешно удалено",
      "delete_listing_error": "Ошибка удаления объявления",
      "unknown": "Неизвестно",

      // ===== COMPLAINTS =====
      "create_complaint": "Создать жалобу",
      "complaint_description_hint": "Добавьте подробности (необязательно)",
      "submit_complaint": "Отправить жалобу",
      "complaint_created_success": "Жалоба успешно отправлена",
      "listing_complaints": "Жалобы по объявлению",
      "listing_complaints_header": "Жалобы по объявлению: {count}",
      "view_listing_complaints": "Показать жалобы",
      "complaints_count_short": "{count} жалоб",
      "complaints_count_short_one": "{count} жалоба",
      "complaints_count_short_few": "{count} жалобы",
      "complaints_count_short_many": "{count} жалоб",
      "no_listing_complaints": "Жалоб по этому объявлению пока нет",
    },
    "uz": {
      // ===== NAVIGATION =====
      "home": "E'lonlar",
      "nav_housing": "Uy-joy",
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
      "create_choice_title": "Nimadan boshlaymiz?",
      "create_choice_housing": "Uy-joy",
      "create_choice_housing_subtitle": "Ijaraga berish yoki topish",
      "create_choice_roommate_needed_subtitle":
          "Uyingiz bor — o'zingizga mos, qulay xonadoshlarni topamiz",
      "create_choice_room_needed_subtitle":
          "Ko'nglingizga mos xona yoki kvartira topamiz",
      "create_choice_group_forming": "Guruh yig'ish",
      "create_choice_group_forming_subtitle":
          "Birlashamiz va birga ijaraga olamiz — arzonroq",
      "create_group_title": "Guruh yig'ish",
      "listing_type_group_forming": "Guruh yig'ish",
      "title_group_forming": "Guruh Yigamiz",
      "group_size_target_label": "Guruh hajmi (siz bilan)",
      "group_size_target_option_other": "Jami {count} kishi",
      "group_budget_per_person_label":
          "Har bir kishi uchun byudjet diapazoni (y.e./oy)",
      "group_budget_per_person_heading": "Har bir kishi uchun byudjet",
      "price_picker_single_title": "Oylik narx",
      "price_picker_range_title": "Oylik byudjet diapazoni",
      "group_budget_per_person_amount_line":
          "Har bir a'zo oyiga {range} to'laydi",
      "group_budget_total_apartment_line":
          "{count} kishi uchun umumiy ijara: oyiga {range}",
      "group_request_to_join": "Guruhga qo'shilish",
      "group_join_request_sent": "So'rov yuborildi",
      "group_join_request_withdraw": "So'rovni bekor qilish",
      "group_open_chat": "Guruh chatini ochish",
      "group_floating_chat_label": "Guruh chati · {current}/{target}",
      "group_floating_participants_label": "Ishtirokchilar",
      "group_floating_shortlist_label": "Uy-joy variantlari · {count}",
      "group_manage_requests": "So'rovlarni boshqarish",
      "group_members_progress": "{current}/{target} a'zo",
      "group_status_looking_for_roommates": "Xonadoshlar qidirilmoqda",
      "group_status_request_pending": "Qo'shilish so'rovi yuborilgan",
      "group_status_full": "Guruh to'ldi",
      "group_status_closed": "Guruh yopilgan",
      "group_status_housing_search": "Uy-joy qidirilmoqda",
      "group_status_reviewing_shortlist":
          "Saqlangan variantlar muhokama qilinmoqda",
      "group_status_landlord_outreach_owner":
          "Ijara beruvchining javobi kutilmoqda",
      "group_status_landlord_outreach_member":
          "Ijara beruvchiga taklif yuborilgan",
      "group_status_landlord_joined": "Ijara beruvchi chatda",
      "group_members_needed_other": "Yana {count} ishtirokchi kerak",
      "group_join_request_message_hint": "O'zingiz haqingizda (ixtiyoriy)",
      "group_join_request_success": "So'rov yuborildi",
      "group_join_requires_profile":
          "Bu guruhga qo'shilishdan oldin profilingizni to'ldiring.",
      "group_join_request_withdrawn": "So'rov bekor qilindi",
      "group_join_request_approved": "A'zo guruhga qo'shildi",
      "group_join_request_rejected": "So'rov rad etildi",
      "group_no_pending_requests": "Yangi so'rovlar yo'q",
      "group_new_request_pill": "Yangi so'rov",
      "group_approve_member": "Qabul qilish",
      "group_reject_member": "Rad etish",
      "group_pending_join_requests": "Kutilayotgan so'rovlar",
      "group_member_role_pending_request": "Qo'shilish so'rovi",
      "create_choice_service": "Xizmat",
      "create_choice_service_subtitle": "Xizmat taklif qilish yoki topish",
      "profile": "Profil",
      "role_tenant": "Ijarachi",
      "role_landlord": "Ijaraga beruvchi",
      "role_manager": "Menejer",
      "role_admin": "Administrator",
      "role_service_provider": "Xizmat koʻrsatuvchi",
      "role_service_requester": "Xizmatga ehtiyoji bor",
      "profile_completion": "Profil to'ldirilishi",
      "profile_completion_hint":
          "Profil to'liq bo'lsa, mosliklar aniqroq va qo'shnichilik qulayroq bo'ladi.",
      "complete_profile_prompt_title": "Profilni to'ldiring",
      "complete_profile_prompt_body":
          "Turmush tarzi bo'yicha xohishlarni qo'shing, mosliklar yaxshilanadi.",
      "missing_fields_title": "To'ldirilmagan:",
      "complete_profile_prompt_more": "+ yana {count}",
      "complete_profile_prompt_cta": "Hozir to'ldirish",
      "complete_profile_prompt_later": "Keyinroq",
      "compatibility_title": "Siz bilan moslik:",
      "compatibility_match_percentage": "Moslik: {percent}%",
      "compatibility_calculating": "Moslik hisoblanmoqda...",
      "compatibility_sign_in": "Moslikni ko'rish uchun tizimga kiring",
      "na": "N/A",
      "compatibility_matches": "Mos keladigan xususiyatlar:",
      "compatibility_differences": "Ehtimoliy farqlar:",
      "compatibility_critical_differences": "Muhim farqlar:",
      "compatibility_based_on_preferences":
          "{total} ta afzallikdan {scored} tasiga asoslangan",
      "group_compatibility_title": "Guruh mosligi:",
      "group_compatibility_subtitle": "{count} kishilik guruh",
      "group_compatibility_target_description": "{count} kishilik guruhga",
      "group_compatibility_full_matches": "To'liq mos keladi ({count}/{total})",
      "group_compatibility_partial_matches":
          "Qisman mos keladi ({count} dan {total})",
      "group_compatibility_discuss": "Muhokama qilish kerak",
      "group_compatibility_value_count": "{count} — {value}",
      "group_compatibility_summary_full": "to'liq moslik",
      "group_compatibility_summary_partial": "qisman",
      "group_compatibility_summary_discuss": "muhokama qilish",
      "group_compatibility_summary_compact_full": "to'liq",
      "group_compatibility_summary_compact_partial": "qisman",
      "group_compatibility_summary_compact_discuss": "muhokama",
      "group_profile_summary_title": "Guruh profili",
      "group_profile_report_title": "Guruh profili xulosasi",
      "group_preference_matrix_title": "Turmush tarzi afzalliklari jadvali",
      "group_preference_matrix_subtitle":
          "Barcha ishtirokchilarni tez solishtiring",
      "group_compatibility_report_title": "Guruh moslik xulosasi",
      "group_preference_matrix_preference": "Afzallik",
      "view_member_profiles": "Ishtirokchi profillari",
      "group_member_profiles_formed": "Guruh to'ldi",
      "group_find_housing": "Uy-joy qidirish",
      "group_continue_search": "Qidirishni davom ettirish",
      "group_search_area": "Qidiruv hududi",
      "group_search_area_hint":
          "Butun guruh qidiradigan tumanlar va metro bekatlarini tanlang.",
      "group_search_area_saved": "Qidiruv hududi yangilandi",
      "group_search_area_empty": "Kamida bitta bekat yoki tuman tanlang",
      "group_shortlist_title": "Uy-joy variantlari",
      "group_shortlist_title_count": "Uy-joy variantlari ({count})",
      "group_shortlist_all_options": "Barcha variantlar",
      "group_shortlist_chip": "Saqlangan ({count})",
      "group_shortlist_save": "Guruh uchun saqlash",
      "group_shortlist_save_for_group": "Guruh uchun saqlash ({count} kishi)",
      "group_shortlist_added": "Guruh ro'yxatiga qo'shildi",
      "group_shortlist_removed": "Guruh ro'yxatidan olib tashlandi",
      "group_shortlist_empty_title": "Hali saqlangan e'lonlar yo'q",
      "group_shortlist_empty_subtitle":
          "Uy-joy e'lonlarini qidiring va guruh bilan muhokama qilish uchun saqlang",
      "group_shortlist_saved_by": "",
      "group_shortlist_saved_by_suffix": "saqladi",
      "listing_author": "Muallif",
      "group_shortlist_open": "Ochish",
      "group_shortlist_view": "Ko'rish",
      "group_shortlist_open_listing": "Ko'rish",
      "group_shortlist_remove": "Olib tashlash",
      "group_shortlist_saved_for_group_context":
          "Guruh uchun saqlangan \"{label}\"",
      "group_shortlist_group_size_label": "{count} kishi",
      "group_shortlist_fits_budget_check": "Byudjetga mos",
      "group_shortlist_above_budget_check": "Byudjetdan yuqori",
      "group_shortlist_fit_district_named": "Tuman: {name}",
      "group_shortlist_fit_district_unspecified": "Tuman: ko'rsatilmagan",
      "group_shortlist_saved_for_group": "Guruh uchun saqlangan · {name}",
      "group_shortlist_price_per_person": "Har bir kishi uchun {price} / oy",
      "group_shortlist_fits_group_budget": "Guruh byudjetiga mos",
      "group_shortlist_suitable_for_group": "Guruhga mos:",
      "group_shortlist_fit_budget_ok": "Byudjet mos",
      "group_shortlist_fit_budget_above": "Byudjetdan yuqori",
      "group_shortlist_fit_for_people": "{count} kishi uchun",
      "group_shortlist_fit_district_ok": "Tuman mos",
      "group_shortlist_fit_district_diff": "Boshqa tuman",
      "group_shortlist_discuss_in_group": "Guruhda muhokama qilish",
      "group_shortlist_already_in_discussion":
          "Bu e'lon allaqachon guruh muhokamasiga qo'shilgan",
      "group_shortlist_ref_label": "Muhokamadagi e'lon",
      "group_shortlist_ref_tap_hint": "Ko'rish uchun bosing",
      "group_shortlist_original_not_found":
          "Asl e'lon kartochkasi hali yuklanmagan",
      "group_shortlist_start_listing_discussion": "E'lon muhokamasini boshlash",
      "group_shortlist_continue_discussion": "Muhokamani davom ettirish",
      "group_shortlist_discuss_message_intro": "Bu variant sizga qanday?",
      "messages_preview_shared_listing": "📋 E'lon: {title}",
      "messages_preview_shared_listing_no_title": "📋 E'lon ulashildi",
      "messages_preview_referenced_listing": "↪️ {title}",
      "messages_preview_referenced_listing_no_title": "↪️ E'lon eslatildi",
      "group_shortlist_discuss_line_location": "📍 {location}",
      "group_shortlist_discuss_line_metro": "🚇 {station}",
      "group_shortlist_discuss_line_price": "💰 {price}",
      "group_shortlist_discuss_line_price_per_person":
          "💰 {price} / oy har bir kishi uchun",
      "group_shortlist_discuss_line_link": "🔗 {link}",
      "group_shortlist_rating_summary": "{average} · {count} baho",
      "group_shortlist_rating_count_summary": "{count} baho",
      "group_shortlist_rate_prompt": "Variantni baholang",
      "group_shortlist_rate_cta":
          "Guruhga tanlashda yordam bering: variantni baholang",
      "group_shortlist_group_rating": "Guruh bahosi",
      "group_shortlist_ai_summary_title": "AI fikrlar xulosasi",
      "group_shortlist_no_ratings": "Hali baho yo'q",
      "group_shortlist_edit_rating_title": "Bahongizni o'zgartiring",
      "group_shortlist_dislike_reasons_title": "Nima yoqmadi?",
      "group_shortlist_dislike_reason_expensive": "Juda qimmat",
      "group_shortlist_dislike_reason_far": "Uzoq",
      "group_shortlist_dislike_reason_condition": "Yomon ta'mir",
      "group_shortlist_dislike_reason_owner": "Uy egasi / shartlar",
      "group_shortlist_dislike_reason_space": "Joy kam",
      "group_shortlist_dislike_reason_neighborhood": "Yomon hudud",
      "listing_rating_screen_title": "Uy-joy variantini baholang",
      "listing_rating_screen_subtitle":
          "Fikringiz guruhga qaror qabul qilishga yordam beradi",
      "listing_rating_category_price": "Narx",
      "listing_rating_category_price_subtitle": "Byudjetga mos, narxi adolatli",
      "listing_rating_category_location": "Joylashuv",
      "listing_rating_category_location_subtitle":
          "O'qish/ishga yaqinlik, transport, hudud",
      "listing_rating_category_condition": "Uy holati",
      "listing_rating_category_condition_subtitle":
          "Ta'mir, tozalik, mebel, oshxona, sanuzel",
      "listing_rating_category_group": "Guruh uchun qulaylik",
      "listing_rating_category_group_subtitle":
          "Hammaga joy yetadimi, reja, shaxsiy hudud",
      "listing_rating_category_landlord": "Shartlar va uy egasi",
      "listing_rating_category_landlord_subtitle":
          "Qoidalar, uy egasiga ishonch",
      "listing_rating_label_excellent": "A'lo",
      "listing_rating_label_good": "Yaxshi",
      "listing_rating_label_normal": "Normal",
      "listing_rating_label_bad": "Yomon",
      "listing_rating_verdict_title": "Yakuniy xulosa",
      "listing_rating_verdict_subtitle":
          "Bu variant bilan davom etishni xohlaysizmi?",
      "listing_rating_verdict_yes": "Ha,\nmos",
      "listing_rating_verdict_maybe": "Ko'rib\nchiqish mumkin",
      "listing_rating_verdict_no": "Yo'q,\nmos emas",
      "listing_rating_reasons_title": "Nima shubha uyg'otdi?",
      "listing_rating_optional": "ixtiyoriy",
      "listing_rating_submit": "Bahoni yuborish",
      "listing_rating_participants_summary": "Guruh a'zolari baholamoqda",
      "group_shortlist_rating_updated": "Baho yangilandi",
      "group_shortlist_contact_landlord":
          "Ijara beruvchini chatga taklif qilish",
      "group_landlord_invite_revoke": "Taklifni bekor qilish",
      "group_landlord_invite_sent":
          "Taklif yuborildi. Ijara beruvchi qo'shilgandan keyingi yangi xabarlarni ko'radi.",
      "group_landlord_invite_revoked": "Taklif bekor qilindi",
      "group_landlord_invite_dialog_title": "Guruh chatiga qo'shilasizmi?",
      "group_landlord_invite_dialog_message":
          "Siz bu e'lonni guruh bilan muhokama qilishga taklif qilindingiz. Faqat qo'shilganingizdan keyingi xabarlarni ko'rasiz.",
      "group_landlord_invite_accept": "Chatga qo'shilish",
      "group_landlord_invite_decline": "Rad etish",
      "group_landlord_invite_accepted": "Guruh chatiga qo'shildingiz",
      "group_landlord_invite_declined": "Taklif rad etildi",
      "group_landlord_invite_chat_card_title": "Guruh chatiga taklif",
      "group_landlord_invite_chat_card_body":
          "Guruh egasi sizni bu e'lonni guruh bilan muhokama qilishga taklif qildi. Faqat qo'shilganingizdan keyingi xabarlarni ko'rasiz.",
      "group_landlord_invite_one_at_a_time":
          "Bu guruh chatiga ijara beruvchi allaqachon ulangan yoki taklif hali javob kutmoqda. Boshqa ijara beruvchini taklif qilishdan oldin joriy taklifni bekor qiling yoki muhokamani yakunlang.",
      "group_shortlist_remove_title":
          "Saqlanganlar ro'yxatidan olib tashlansinmi?",
      "group_shortlist_remove_message":
          "«{title}» guruhning saqlangan ro'yxatidan olib tashlanadi.",
      "group_shortlist_remove_confirm": "Olib tashlash",
      "group_housing_fits_budget": "Byudjetga mos",
      "group_housing_above_budget": "Guruh byudjetidan yuqori",
      "group_housing_search_banner":
          "{count} kishilik guruh · {budget}/kishi gacha",
      "group_housing_search_empty": "Mos uy-joy e'lonlari topilmadi",
      "group_member_role_owner": "Tashkilotchi",
      "group_member_role_you": "Siz",
      "group_member_role_member": "A'zo",
      "group_member_compat_match": "Mos keladi",
      "group_member_compat_difference": "Farq",
      "group_member_compat_dealbreaker": "Ziddiyat",
      "group_remove_member": "Guruhdan olib tashlash",
      "group_remove_member_title": "Guruhdan olib tashlansinmi?",
      "group_remove_member_message":
          "{name} guruh chatiga kira olmaydi. Yangi a'zo uchun joy ochiladi.",
      "group_remove_reason_title": "Sabab (ixtiyoriy)",
      "group_remove_reason_inactive": "Faol emas",
      "group_remove_reason_rules": "Qoidalarni buzdi",
      "group_remove_reason_not_fit": "Guruhga mos emas",
      "group_remove_reason_member_request": "A'zo iltimosiga ko'ra",
      "group_remove_reason_other": "Boshqa",
      "group_remove_reason_other_hint": "Qisqa sabab yozing",
      "group_remove_member_success": "A'zo guruhdan olib tashlandi",
      "group_leave_group": "Guruhni tark etish",
      "group_leave_group_title": "Guruh tark etilsinmi?",
      "group_leave_group_message":
          "Guruh chatiga kira olmaysiz. Yangi a'zo uchun joy ochiladi.",
      "group_leave_group_success": "Guruhni tark etdingiz",
      "vs": "vs",
      "name": "Ism yoki taxallus",
      "im_from": "Men:",

      // ===== APP CORE =====
      "user": "Foydalanuvchi",
      "welcome_title": "UyDosh ga xush kelibsiz",
      "welcome_subtitle": "Mukammal xonadon yoki turar joy toping",
      "splash_subtitle": "KELING BIRGA YASHAYMIZ!",
      "search_results": "Qidiruv natijalari",
      "search_refresh_this_area": "Bu hududni yangilash",
      "open_map_view": "Xaritani ochish",
      "open_feed_view": "Lentani ochish",
      "close": "Yopish",
      "cancel": "Bekor qilish",
      "done": "Tayyor",
      "about_uy_dosh": "UyDosh haqida",
      "user_license_agreement_title": "Foydalanuvchi litsenziya shartnomasi",

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

      "error_generic_try_again":
          "Xatolik yuz berdi. Iltimos, qayta urinib ko‘ring.",
      "error_unable_to_complete_try_again":
          "So‘rovni bajarib bo‘lmadi. Iltimos, qayta urinib ko‘ring.",
      "error_no_internet": "Internet yo‘q. Tarmoq sozlamalarini tekshiring.",
      "error_timeout_check_connection":
          "So‘rov vaqti tugadi. Internet aloqangizni tekshirib, qayta urinib ko‘ring.",
      "error_server_try_later":
          "Server xatoligi. Iltimos, keyinroq urinib ko‘ring.",
      "error_service_unavailable_try_later":
          "Xizmat vaqtincha ishlamayapti. Iltimos, keyinroq urinib ko‘ring.",
      "error_invalid_request":
          "Noto‘g‘ri so‘rov. Kiritilgan ma’lumotlarni tekshirib, qayta urinib ko‘ring.",
      "error_auth_required": "Avtorizatsiya kerak. Iltimos, qayta kiring.",
      "error_access_denied": "Ruxsat berilmadi. Bu amal uchun huquqingiz yo‘q.",
      "error_not_found": "So‘ralgan resurs topilmadi.",
      "error_conflict":
          "Resurs allaqachon mavjud yoki joriy ma’lumotlar bilan ziddiyatda.",
      "error_invalid_data":
          "Noto‘g‘ri ma’lumot yuborildi. Kiritishni tekshiring.",
      "error_too_many_requests":
          "So‘rovlar juda ko‘p. Biroz kuting va qayta urinib ko‘ring.",
      "error_request_cancelled": "So‘rov bekor qilindi.",
      "error_internet_connection": "Internet aloqangizni tekshiring",
      "error_resource_conflict":
          "Siz bu e'lon haqida allaqachon shikoyat qilgansiz.",

      // ===== MESSAGING =====
      "conversations": "Xabarlar",
      "messages": "Xabarlar",
      "chat": "Chat",
      "chat_security_ribbon_title": "Himoyalangan chat",
      "chat_security_ribbon_body":
          "Bu chat AI anti‑firibgarlik va scam filtrlari bilan himoyalangan — xavfsizroq muloqot uchun.",
      "chat_safety_warning_title_medium": "Ogohlantirish",
      "chat_safety_warning_title_high": "Ehtiyot bo‘ling",
      "chat_safety_warning_fallback":
          "Bu suhbatda firibgarlik belgilari bo‘lishi mumkin. Havolalar, kodlar va to‘lov so‘rovlaridan ehtiyot bo‘ling.",
      "chat_safety_reason_deposit_to_reserve_room":
          "Foydalanuvchi xonani band qilish uchun depozit so‘ramoqda.",
      "chat_safety_reason_suspicious_link":
          "Suhbatdosh shubhali havola yuborayapti.",
      "chat_safety_reason_off_platform":
          "Suhbatdosh muloqotni platformadan tashqariga olib chiqmoqchi.",
      "chat_safety_reason_otp_code":
          "Suhbatdosh tasdiqlash kodini (OTP/SMS) so‘rayapti.",
      "chat_safety_reason_payment_request":
          "Suhbatdosh oldindan to‘lov yoki to‘lov ma’lumotlarini so‘rayapti.",
      "chat_safety_sheet_why_title": "Nega bu belgilandi",
      "chat_safety_sheet_copy": "Xabarni nusxalash",
      "chat_safety_sheet_report": "Shikoyat qilish",
      "chat_safety_sheet_close": "Yopish",
      "chat_safety_sheet_copied": "Nusxalandi",
      "profile_interlocutor": "Suhbatdosh profili",
      "view_listing": "E'lonni ko'rish",
      "view_group": "Guruhni ko'rish",
      "chat_menu_translate_to": "Tarjima qilish…",
      "chat_menu_show_original": "Asl xabarlarni ko‘rsatish",
      "chat_menu_show_translated": "Tarjima qilingan xabarlarni ko‘rsatish",
      "admin_delete_conversation": "Suhbatni hammadan o‘chirish",
      "admin_delete_conversation_confirmation":
          "Bu chat ikkala foydalanuvchi ro‘yxatidan ham olib tashlanadi va ular uchun tugatiladi. Davom etilsinmi?",
      "admin_delete_conversation_success": "Suhbat olib tashlandi",
      "admin_delete_conversation_error": "Suhbatni olib tashlab bo‘lmadi",
      "admin_listing_owner_conversations_card_title": "Chatlar — e‘lon (admin)",
      "admin_listing_owner_conversations_card_subtitle":
          "Mehmondoshlar va e‘lon egasi o‘rtasidagi barcha ilova ichidagi suhbatlar.",
      "admin_listing_owner_conversations_screen_title": "Bu e‘lon chatlari",
      "admin_listing_owner_conversations_empty":
          "Hali bu e‘lon bo‘yicha chat yo‘q.",
      "admin_listing_owner_conversations_error":
          "E‘lon chatlarini yuklab bo‘lmadi.",
      "admin_listing_owner_conversations_retry": "Qayta urinish",
      "admin_listing_owner_conversations_closed_badge": "Yopilgan",
      "chat_translate_picker_title":
          "Ushbu chatni quyidagi tilga tarjima qilish",
      "chat_translate_picker_auto": "Avto (mening tilim)",
      "chat_translating": "Tarjima qilinmoqda…",
      "chat_translation_quota_exceeded":
          "Bu oy uchun bepul chat tarjamalari tugadi. Payme yoki Click orqali kengaytiring.",
      "menu_messages": "Xabarlar",
      "menu_notifications": "Bildirishnomalar",
      "menu_enable_notifications": "Bildirishnomalarni yoqish",
      "notifications_alert_match_header":
          "Siz push-bildirishnomani quyidagiga olasiz:",
      "notifications_alert_match_header_paused":
          "Vaqtincha to‘xtatilgan — quyidagilar bo‘yicha push-bildirishnoma yuborilmaydi:",
      "notifications_push_off_title":
          "Push-bildirishnomalar {where} o‘chirilgan",
      "notifications_push_off_where_ios": "iOS’da",
      "notifications_push_off_where_android": "Android’da",
      "notifications_push_off_where_chrome": "Chrome’da",
      "notifications_push_off_where_safari": "Safari’da",
      "notifications_push_off_where_firefox": "Firefox’da",
      "notifications_push_off_where_edge": "Edge’da",
      "notifications_push_off_where_browser": "brauzerda",
      "notifications_push_off_where_device": "bu qurilmada",
      "inbox_push_off_banner_title":
          "Yangi xabarlarni o'tkazib yubormaslik uchun bildirishnomalarni yoqing",
      "notifications_enabled": "Bildirishnomalar yoqildi",
      "notifications_enable_in_settings":
          "Ilova sozlamalarida bildirishnomalarni yoqing",
      "notifications_appbar_semantics_active_alerts":
          "Faol qidiruv bildirishnomalari",
      "notifications_empty": "Hozircha saqlangan bildirishnomalar yo'q.",
      "notifications_alerts_explainer":
          "Bu yerda sizning ogohlantirishlaringiz.\nMos uy-joy yoki qo‘shni paydo bo‘lishi bilan darhol xabar beramiz.",
      "notifications_alerts_explainer_enabled":
          "Bildirishnomalar yoqilgan.\n\nBu yerda sizning ogohlantirishlaringiz. Mos uy-joy yoki qo‘shni paydo bo‘lishi bilanoq — sizga push-bildirishnoma yuboramiz.",
      "notifications_open_settings": "Sozlamalarni ochish",
      "notifications_disable_all": "Barcha bildirishnomalarni o‘chirish",
      "notifications_delete_all": "Barcha bildirishnomalarni o‘chirib tashlash",
      "notifications_disable_all_title":
          "Barcha bildirishnomalar o‘chirilsinmi?",
      "notifications_disable_all_message":
          "Bu barcha saqlangan qidiruv ogohlantirishlarini o‘chiradi. Keyinroq yana yoqishingiz mumkin.",
      "notifications_delete_all_title":
          "Barcha bildirishnomalar o‘chirib tashlansinmi?",
      "notifications_delete_all_message":
          "Bu barcha saqlangan qidiruv ogohlantirishlarini butunlay o‘chirib tashlaydi. Bu amalni bekor qilib bo‘lmaydi.",
      "disable": "O‘chirish",
      "enable": "Yoqish",
      "type_message": "Xabar yozing...",
      "conversation_created": "Suhbat boshlandi",
      "conversation_failed": "Suhbat boshlanmadi",
      "error_listing_chat_disabled":
          "Bu e'lon uchun ilova ichidagi chat mavjud emas",
      "no_conversations": "Hali suhbatlar yo'q",
      "no_messages": "Hali xabarlar yo'q",
      "no_messages_description":
          "Siz hali e'lonlaringiz haqida xabar olmadingiz",
      "mark_as_read": "O‘qilgan deb belgilash",
      "archive": "Arxivlash",
      "unarchive": "Arxivdan chiqarish",
      "archived": "Arxiv",
      "archived_chats": "Arxivdagi suhbatlar",
      "archived_chats_tip":
          "Amallarni ko'rish uchun arxivdagi suhbatni bosib ushlab turing yoki qayta kirish qutisiga qaytarish uchun chapga suring.",
      "grouped_chats_expand_coach_hint":
          "Bitta e'lon bo'yicha suhbatlarni yoyish yoki yig'ish uchun karta sarlavhasiga yoki strelkaga bosing.",
      "no_archived_conversations": "Arxivda suhbatlar yo'q",
      "no_archived_conversations_description":
          "Arxivlangan suhbatlar shu yerda ko'rinadi",
      "chat_archived": "Suhbat arxivga olindi",
      "chat_unarchived": "Suhbat qayta kirish qutisiga qaytdi",
      "chat_edit_message_title": "Xabarni tahrirlash",
      "chat_edit_message_save": "Saqlash",
      "chat_edit_message_cancel": "Bekor qilish",
      "chat_edit_message_once_only":
          "Bu xabar uchun bitta tahriringizni allaqachon ishlatgansiz.",
      "chat_edit_hold_already_edited_toast":
          "Har bir xabarni faqat bir marta o‘zgartirish mumkin — tahriringiz allaqachon saqlangan.",
      "chat_message_edited_label": "Tahrirlangan",
      "chat_replying_to": "{name} ga javob",
      "chat_reply_cancel": "Javobni bekor qilish",
      "chat_reply_sender_you": "Siz",
      "chat_reply_sender_unknown": "Xabar",
      "chat_reply_attachment_fallback": "Ilova",
      "chat_scroll_to_bottom": "Oxirgi xabarga o'tish",
      "archive_failed_has_unread":
          "O'qilmagan xabari bor suhbatni arxivlab bo'lmaydi",
      "undo": "Bekor qilish",
      "error_not_authenticated": "Suhbatni boshlash uchun tizimga kiring",
      "error_cannot_message_self": "O'zingizga xabar yubora olmaysiz",
      "start_conversation_from_listing":
          "Xabar almashishni boshlash uchun e'londan suhbatni boshlang",
      "today": "Bugun",
      "yesterday": "Kecha",
      "tomorrow": "Ertaga",
      "in_days": "{days} kundan keyin",
      "in_days_other": "{count} kundan keyin",
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
      "quick_question_total_price":
          "Kommunal xarajatlar bilan umumiy narxi qancha?",
      "quick_question_can_visit_soon":
          "Yaqin kunlarda ko'rish uchun kelsam bo'ladimi?",
      "quick_question_roommate_still_searching":
          "Hali ham xonadosh qidiryapsizmi?",
      "quick_question_roommate_move_in_date":
          "Xonadosh qachon ko'chib kelishi mumkin?",
      "quick_question_roommate_household": "Hozir kvartirada kimlar yashaydi?",
      "quick_question_roommate_rent_terms":
          "Ijara va kommunal to'lovlar qanday bo'ladi?",
      "quick_question_roommate_meet_soon":
          "Suhbatlashish yoki uchrashish mumkinmi?",
      "quick_question_seeker_move_in_when": "Qachon ko'chib kelmoqchisiz?",
      "quick_question_seeker_budget": "Byudjetingiz qancha?",
      "quick_question_seeker_how_long": "Qancha muddatga ijaraga qidiryapsiz?",
      "quick_question_seeker_about_you":
          "O'zingiz haqingizda biroz gapirib bering?",
      "quick_question_generic_price": "Narxi qancha?",
      "quick_question_generic_whats_included": "Narxga nimalar kiradi?",
      "quick_question_generic_when_available": "Qachon bo'sh vaqtingiz bor?",
      "quick_question_generic_how_soon": "Qanchalik tez boshlash mumkin?",
      "quick_question_generic_arrangement": "Qanday tashkil qilish qulay?",
      "quick_question_generic_clarify_details":
          "Tafsilotlarni aniqlashtirsak bo'ladimi?",
      "quick_question_offerer_scope": "Aynan nima qilish kerak?",
      "quick_question_offerer_deadline": "Buni qachongacha tugatish kerak?",
      "quick_question_offerer_where": "Bu qayerda bo'lishi kerak?",
      "quick_question_offerer_budget": "Qancha byudjet bo'lishini o'ylagansiz?",
      "quick_question_offerer_materials":
          "Materiallarni o'zingiz taminlaysizmi, yoki men olib kelamanmi?",
      "quick_question_offerer_visit":
          "Baholash uchun qisqa qo'ng'iroq yoki ko'rish belgilash mumkinmi?",
      "private_room": "Shaxsiy xona",
      "with_photo": "Surat bilan",
      "search_filter_private_room": "Shaxsiy xona",
      "search_filter_with_photo": "Suratli",
      "conversation_count": "suhbat",
      "conversations_count": "suhbat",
      "conversations_count_other": "{count} suhbat",
      "incoming": "Kiruvchi",
      "outgoing": "Chiquvchi",
      "no_incoming_conversations": "Kiruvchi suhbatlar yo'q",
      "no_outgoing_conversations": "Chiquvchi suhbatlar yo'q",
      "no_incoming_conversations_description":
          "Sizning e'lonlaringiz haqida hali xabar olmadingiz",
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
      "error_reordering_photos":
          "Asosiy rasmni yangilab bo'lmadi. Qayta urinib ko'ring.",
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
      "room_scan_title": "3D xona skani",
      "room_scan_instructions":
          "3D skanlashni boshlashdan oldin\n\n• Yaxshi yoritishni yoqing\n• Sekin harakat qiling, keskin harakatlarsiz\n• Telefonni ko‘krak balandligida ushlang\n• Devorlar, burchaklar, derazalar va eshiklarni skanerlang\n• Butun xonani qamrab olishga harakat qiling\n\nBu uyingizning aniq 3D modelini yaratishga yordam beradi",
      "room_scan_start": "Skanlashni boshlash",
      "room_scan_finish": "Yakunlash",
      "room_scan_scan_other_rooms": "Boshqa xonalarni skanerlash",
      "room_scan_uploading": "Yuklanmoqda…",
      "room_scan_success": "3D skan saqlandi",
      "room_scan_cancelled":
          "Skan qilinmadi. Qayta urinish uchun «Boshlash»ni bosing.",
      "room_scan_error": "Skanni saqlab bo'lmadi. Qayta urinib ko'ring.",
      "room_scan_too_large":
          "3D skan yuklash uchun juda katta. Iltimos, kichikroq hududni skanerlab ko'ring.",
      "room_scan_not_supported":
          "3D skan uchun LiDARli iPhone yoki iPad kerak.",
      "room_scan_camera_required":
          "3D skan uchun kamera ruxsati kerak. «Ruxsat bermaslik»ni tanlasangiz, Sozlamalarda UyDosh uchun kamerani yoqing.",
      "room_scan_disabled_globally":
          "3D xona skanlash ilova sozlamalarida o'chirilgan. Keyinroq yana yoqilishi mumkin.",
      "add_room_scan_3d": "3D xona skanini qo'shish",
      "replace_room_scan_3d": "3D xona skanini almashtirish",
      "skip": "O'tkazib yuborish",
      "view_room_3d": "3D xonani ko'rish",
      "room_3d_open_error": "3D modelni ochib bo'lmadi. Internetni tekshiring.",
      "room_3d_viewer_title": "3D",
      "room_3d_dimensions_caption": "Taxminiy o'lchamlar",
      "room_3d_dimensions_line1_template":
          "O'lchamlar: {floorLong} x {floorShort} м",
      "room_3d_dimensions_height_template": "Balandlik: {height} м",
      "room_3d_dimensions_line2_template": "Maydon: ~{floorArea} м²",
      "room_3d_load_error_title": "3D modelni yuklab bo'lmadi",
      "room_3d_floor_only_button": "Devorlarni yashirish",
      "room_3d_full_room_button": "Butun xona",
      "room_3d_floor_only_unavailable":
          "Bu faylda devorlar nomi bo'yicha topilmadi. 3D eksportda devorlar alohida obyektlar bo'lishi kerak.",
      "room_3d_zoom_in": "Yaqinlashtirish",
      "room_3d_zoom_out": "Uzoqlashtirish",
      "room_3d_view_mode_label": "3D ko'rish rejimi",
      "room_3d_view_mode_hint":
          "Butun xona, faqat devorlar yoki pol va mebel rejimiga o'ting.",
      "room_3d_materials_style_label": "Materiallar uslubi",
      "room_3d_materials_style_hint":
          "Haqiqiy materiallar va uslubiy ranglar orasida almashtiring.",
      "room_3d_materials_style_value_stylized": "Uslubiy",
      "room_3d_materials_style_value_real": "Haqiqiy",
      "room_3d_tab_view_3d": "3D",
      "room_3d_tab_floor_plan": "2D",
      "room_3d_floor_plan_reset": "Tiklash",
      "room_3d_floor_plan_dimensions_overall": "Umumiy",
      "room_3d_floor_plan_dimensions_walls": "Devorlar",
      "room_3d_floor_plan_dimensions_hide": "Yashirish",
      "room_3d_floor_plan_show_objects": "Buyumlar",
      "room_3d_floor_plan_hide_objects": "Buyumlarni yashirish",
      "room_3d_floor_plan_show_grid": "To'r",
      "room_3d_floor_plan_hide_grid": "To'rni yashirish",
      "room_3d_floor_plan_auto_align_on": "Tekislash",
      "room_3d_floor_plan_auto_align_off": "Skan burchagi",
      "room_3d_floor_plan_adjust_north": "Shimol",
      "room_3d_floor_plan_adjust_north_title": "Shimolni sozlash",
      "room_3d_floor_plan_adjust_north_message":
          "Kompas haqiqatga mos kelmasa, aylantiring. Oraliq ±180°.",
      "room_3d_floor_plan_adjust_north_reset": "Skanga qaytarish",
      "room_3d_floor_plan_adjust_north_updated": "Shimol yo'nalishi yangilandi",
      "room_3d_floor_plan_adjust_north_degrees_format": "%+.0f°",
      "room_3d_floor_plan_edit_dimension_title": "O'lchamni tahrirlash",
      "room_3d_floor_plan_edit_dimension_current": "Joriy",
      "room_3d_floor_plan_edit_dimension_new_value": "Yangi qiymat (m)",
      "room_3d_floor_plan_edit_dimension_cancel": "Bekor qilish",
      "room_3d_floor_plan_edit_dimension_apply": "Qo'llash",
      "room_3d_floor_plan_edit_dimension_updated": "O'lcham yangilandi",
      "room_3d_floor_plan_edit_dimension_large_change_title": "Katta o'zgarish",
      "room_3d_floor_plan_edit_dimension_large_change_message":
          "Yangi qiymat skan natijasidan sezilarli darajada farq qiladi. Tuzatishni qo'llash?",
      "room_3d_floor_plan_edit_dimension_invalid_title": "Noto'g'ri qiymat",
      "room_3d_floor_plan_edit_dimension_invalid_message":
          "0,5 dan 100 metrgacha bo'lgan son kiriting.",
      "room_3d_floor_plan_edit_dimension_confirm_large_change": "Qo'llash",
      "room_3d_floor_plan_unit_meters": "metr",
      "room_3d_floor_plan_object_bed": "Karavot",
      "room_3d_floor_plan_object_sofa": "Divan",
      "room_3d_floor_plan_object_table": "Stol",
      "room_3d_floor_plan_object_chair": "Stul",
      "room_3d_floor_plan_object_storage": "Saqlash",
      "room_3d_floor_plan_object_appliance": "Maishiy texnika",
      "room_3d_floor_plan_object_cabinet": "Shkaf",
      "room_3d_floor_plan_object_television": "TV",
      "room_3d_floor_plan_object_fixture": "Sanitar jihoz",
      "room_3d_floor_plan_object_unknown": "Buyum",
      "room_3d_sun_toggle_label": "Quyosh nuri",
      "room_3d_sun_toggle_hint":
          "Quyosh simulyatsiyasi boshqaruvlarini ko'rsatish/yashirish",
      "room_3d_sun_azimuth_label": "Azimut",
      "room_3d_sun_elevation_label": "Balandlik",
      "room_3d_sun_intensity_label": "Yorqinlik",
      "room_3d_sun_preset_morning": "Ertalab",
      "room_3d_sun_preset_noon": "Tush",
      "room_3d_sun_preset_evening": "Kechqurun",
      "room_3d_sun_today": "Bugun",
      "room_3d_sun_now": "Hozir",
      "room_3d_sun_azimuth_format": "Az %d°",
      "room_3d_sun_elevation_format": "Bl %d°",

      "profile_completed_success": "Profil muvaffaqiyatli to'ldirildi!",
      "profile_updated_success": "Profil muvaffaqiyatli yangilandi",
      "auth_terms_finish_header": "Deyarli tayyor",
      "auth_terms_finish_title": "Shartlarni ko'rib chiqing",
      "auth_terms_finish_body":
          "Davom etish orqali siz UyDosh Foydalanish shartlari, Maxfiylik siyosati va Hamjamiyat qoidalariga rozilik bildirasiz.",
      "view_terms_of_service": "Foydalanish shartlarini ko'rish",
      "could_not_open_terms_of_service":
          "Foydalanish shartlarini ochib bo'lmadi. Qayta urinib ko'ring.",

      "successfully_signed_in_google":
          "Google orqali muvaffaqiyatli kirdingiz!",
      "successfully_signed_in_apple": "Apple orqali muvaffaqiyatli kirdingiz!",
      "successfully_signed_in_telegram":
          "Telegram orqali muvaffaqiyatli kirdingiz!",

      // ===== EMPTY STATES =====
      "my_listings_empty_state": "Siz hali hech qanday e'lon yaratmagansiz.",

      "no_locations_available": "Tumanlar mavjud emas",

      "no_universities_available": "Universitetlar mavjud emas",
      "no_results": "Natija topilmadi",
      "no_search_results": "Natija topilmadi...",

      // ===== SELECTION & PROMPTS =====
      "select_metro_line": "Liniyani tanlang",
      "select_metro_line_title": "Metro\nliniyasini tanlang",
      "metro_line_abbr": "yo'n.",
      "metro_station_abbr": "bek.",
      "select_location": "Har qanday tuman",
      "not_selected": "Tanlanmagan",
      "all": "Barchasi",

      "all_stations_count": "Barcha {count} bekat",
      "all_stations_count_other": "Barcha {count} bekat",
      "stations_count_other": "{count} bekat",
      "all_stations_explanation":
          "Liniya <b>{line}</b> bo'ylab <b>{count}</b> bekat orqali qidiruv",
      "entire_line_stations": "Butun liniya {line}: {count} bekat",
      "entire_line_stations_other": "Butun liniya {line}: {count} bekat",
      "metro_tutorial_line_hint":
          "Barcha metro liniyasi stansiyalarida e'lonlarni qidiring",
      "metro_tutorial_station_hint":
          "Muayyan metro stansiyalari bo'yicha qidiruv",
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
      "country": "Davlat",
      "city": "Shahar",
      "select_country": "Davlatni tanlang",
      "tap_to_select_country": "Davlatni tanlash uchun bosing",
      "no_regions_for_country": "Bu davlat uchun hududlar hozircha mavjud emas",

      // ===== ACTION BUTTONS =====
      "refresh": "Yangilash",
      "actions": "Harakatlar",

      "view_profile": "Profil",
      "deactivate_listing": "Deaktivlashtirish",
      "deactivate_listing_confirmation":
          "Bu e'loni deaktivlashtirishni xohlaysizmi? U boshqa foydalanuvchilarga ko'rinmaydi.",
      "deactivate": "Deaktivlashtirish",
      "activate_listing": "E'lonni aktivlashtirish",
      "activate_listing_confirmation":
          "Bu e'loni aktivlashtirishni xohlaysizmi? U boshqa foydalanuvchilarga ko'rinadi.",
      "activate": "Aktivlashtirish",
      "listing_active": "Aktiv",
      "listing_inactive": "Noaktiv",

      "create_listing_button": "E'lon yaratish",
      "wizard_step_counter": "{total} dan {current}-qadam",
      "wizard_step_basics": "Asosiy",
      "wizard_step_location": "Joylashuv",
      "wizard_step_details": "Tafsilotlar",
      "wizard_step_description": "Tavsif",
      "wizard_step_review": "Tekshirish",
      "wizard_next": "Keyingi",
      "wizard_back": "Orqaga",
      "wizard_review_subtitle":
          "Hammasi to'g'ri ekanini tekshiring va e'lon qiling.",
      "wizard_review_not_set": "Belgilanmagan",
      "wizard_amenities_count": "{count} ta tanlandi",
      "wizard_photos_count": "{count} ta qo'shildi",
      "wizard_metro_value": "{line}-liniya · {station}",
      "wizard_add_station": "Stansiya qo'shish",
      "wizard_stations_hint":
          "Liniya va stansiyani tanlab, qo'shing. Bir nechtasini qo'shishingiz mumkin.",
      "wizard_selected_stations": "Tanlangan stansiyalar",
      "wizard_stations_count": "{count} ta stansiya",
      "wizard_station_already_added": "Bu stansiya allaqachon qo'shilgan",
      "wizard_location_mode_metro": "Metro bo'yicha",
      "wizard_location_mode_district": "Tuman bo'yicha",
      "all_locations_count": "Barcha {count} tuman",
      "wizard_locations_count": "{count} ta tuman",
      "update_listing_button": "E'loni yangilash",
      "save_changes": "O'zgarishlarni saqlash",
      "changed_fields": "O'zgargan",
      "unsaved_changes_title": "Saqlanmagan o'zgarishlar",
      "unsaved_changes_message":
          "Saqlanmagan o'zgarishlaringiz bor. Hozir chiqsangiz, ular yo'qoladi.",
      "keep_editing": "Davom etish",
      "leave_without_saving": "Chiqish",
      "publish_consent_title": "Joylashdan oldin",
      "publish_consent_body":
          "Iltimos, UyDosh hamjamiyati qoidalariga amal qiling. Soxta e'lonlar, firibgarlik takliflari, noqonuniy kontent, haqoratomuz kontent, shaxsiy hujjatlar yoki ruxsatsiz boshqa birovning rasmlarini joylamang.",
      "publish_consent_checkbox":
          "UyDosh Foydalanish shartlari va Hamjamiyat qoidalariga roziman",
      "publish_consent_continue": "Davom etish",

      "confirm": "Tasdiqlash",
      "next": "Keyingi",
      "back": "Orqaga",
      "finish": "Tugatish",

      "complete": "Tugatish",

      // ===== THEME & APPEARANCE =====
      "settings": "Sozlamalar",
      "settings_section_account": "Hisob",
      "settings_section_preferences": "Sozlamalar",
      "settings_section_experience": "Qulayliklar",
      "settings_section_about": "Ilova haqida",
      "settings_section_legal": "Huquqiy ma'lumot",
      "theme": "Mavzu",
      "system_theme": "Tizim",
      "blue_theme": "Ko'k",
      "light_theme": "Yorug'",
      "theme_changed_to": "Mavzu o'zgartirildi: {theme}",
      "theme_color": "Mavzu rangi",
      "switch_theme": "Mavzuni almashtirish",
      "tooltips_toggle": "Maslahatlar",
      "tooltips_toggle_description":
          "Foydali maslahatlar va tooltiplarni ko'rsatish",

      // ===== ABOUT & FEATURES =====
      "about_description":
          "UyDosh - Toshkentda mukammal turar joy topish uchun ishonchli platformangiz.",
      "about_feature_1": "• Metro stansiyalari bo'yicha e'lonlarni ko'rish",
      "about_feature_2": "• Tumanlar bo'yicha qidiruv",
      "about_feature_3": "• Egasi bilan to'g'ridan-to'g'ri aloqa",
      "about_feature_4": "• Tekshirilgan va xavfsiz e'lonlar",

      // ===== METRO SYSTEM =====
      "open_in_yandex_maps": "Yandex Xaritalarida ochish",
      "open_in_yandex_maps_confirmation":
          "Brauzerda Yandex Xaritalari ochiladi.",

      // ===== LISTING DETAILS =====
      "listing_details": "Tafsilotlar",
      "listing_detail_id": "E'lon ID: {id}",
      "author": "Muallif",
      "listing_views_by_others": "{count} ko'rilgan",
      "listing_views_count_other": "{count} ko'rilgan",
      "districts_count_other": "{count} tuman",
      "listing_views_stats_title": "Ko'rish statistikasi",
      "listing_views_stats_empty": "Hali ko'rishlar yo'q",
      "error_loading_view_stats": "Ko'rish statistikasini yuklashda xatolik",
      "promote_listing": "Topga chiqarish",
      "remove_from_top": "Yuqoridan olib tashlash",
      "feature_listing_success": "E'lon yuqoriga ko'tarildi",
      "unfeature_listing_success": "E'lon yuqoridan olib tashlandi",
      "feature_listing_error": "E'loni yangilash muvaffaqiyatsiz",
      "error_promotion_once_per_week":
          "E'loni haftada faqat bir marta yuqoriga ko'tarish mumkin",

      "listing_title_label": "Sarlavha",

      "listing_description_hint": "E'lon matnini kiriting",
      "listing_description_label": "Tavsif",
      "listing_address_field_label": "Manzil:",
      "listing_address_text_label": "Manzil (ixtiyoriy)",
      "use_current_location": "Joriy joylashuv",
      "location_services_disabled":
          "Joylashuv xizmatlari o‘chiq. Joriy joylashuvdan foydalanish uchun ularni yoqing.",
      "location_permission_denied":
          "Joriy joylashuvdan foydalanish uchun joylashuv ruxsati kerak.",
      "current_location_address_failed":
          "Joriy joylashuv bo‘yicha manzilni aniqlab bo‘lmadi.",
      "listing_title_hint": "E'lon sarlavhasini kiriting",
      "view_similar_results": "O‘xshash e'lonlar",
      "listing_detail_nearby_room_offers": "Uy-joy topish",
      "listing_detail_nearby_room_seekers": "Yaqin atrofda uy qidiruvchilar",
      "listing_detail_nearby_matches": "Yaqin atrofdagi mos keluvchilar",
      "listing_detail_nearby_stores_title": "Yaqin atrofdagi do‘konlar",
      "listing_detail_nearby_stores_subtitle":
          "Bu uyga yaqin oziq-ovqat do‘konlari.",
      "listing_detail_nearby_stores_meters": "m",
      "listing_detail_nearby_stores_kilometers": "km",
      "coming_soon": "Tez orada",
      "listing_price_label": "Narxi",
      "listing_translate_tooltip_en": "Inglizchaga tarjima qilish",
      "listing_translate_tooltip_ru": "Rus tiliga tarjima qilish",
      "listing_translate_tooltip_uz": "O‘zbekchaga tarjima qilish",
      "listing_show_original_description": "Asl matn",
      "listing_translating_description": "Tarjima qilinmoqda…",
      "listing_translation_error": "Tarjima qilinmadi. Qayta urinib ko‘ring.",
      "listing_translation_unavailable": "Tarjima mavjud emas.",
      "listing_translation_quota_exceeded":
          "Bu oy uchun bepul e'lon tarjimalari tugadi. Payme yoki Click orqali kengaytiring.",
      "listing_translation_sign_in_required":
          "E'lon tavsifini tarjima qilish uchun hisobingizga kiring.",
      "listing_ai_enhance_quota_exceeded":
          "Bu oy uchun bepul AI yaxshilashlar tugadi. Payme yoki Click orqali kengaytiring.",
      "chat_translated_from_en": "Tarjima: 🇺🇸",
      "chat_translated_from_ru": "Tarjima: 🇷🇺",
      "chat_translated_from_uz": "Tarjima: 🇺🇿",
      "chat_show_original": "Asl matnni ko‘rsatish",
      "chat_show_translation": "Tarjimani ko‘rsatish",
      "listing_ai_enhance": "AI bilan yaxshilash",
      "listing_ai_enhance_empty": "Avval matn kiriting.",
      "listing_ai_enhance_unavailable": "AI yaxshilash mavjud emas.",
      "listing_ai_enhance_error":
          "Matnni yaxshilab bo‘lmadi. Qayta urinib ko‘ring.",
      "listing_description_dictate": "Diktat",
      "listing_description_character_count": "Belgilar: ",
      "listing_description_dictate_mic_denied":
          "Dictaphone uchun mikrofonga ruxsat kerak.",
      "listing_description_dictate_failed":
          "Nutqni taniy olmadik. Qayta urinib ko‘ring.",
      "listing_description_dictate_not_configured":
          "Nutqni tanish hozircha ishlamayapti. Keyinroq urinib ko‘ring.",
      "ai_allowance_banner_title": "AI yordamchisi",
      "ai_allowance_meter_translate":
          "Qolgan e'lon tarjimalari (UTC oy): {count}",
      "ai_allowance_meter_enhance": "Qolgan AI yaxshilashlar: {count}",
      "ai_allowance_meter_chat": "Chat tarjimalari qoldi: {count}",
      "ai_allowance_meter_unlimited": "Cheksiz",
      "ai_allowance_premium_active_until": "AI Premium {date} gacha",
      "ai_allowance_month_reset_note":
          "Limitlar har UTC kalender oyida yangilanadi.",
      "ai_allowance_upgrade_cta": "Premium haqida",
      "ai_quota_exceeded_sheet_title": "AI uchun oylik limit tugadi",
      "ai_quota_exceeded_sheet_body":
          "Bu davr uchun limitingiz tugadi. Premium yuqori oylik limitlar beradi. Limitlar har oyning 1-kuni (UTC) yangilanadi.",
      "ai_quota_exceeded_sheet_dismiss": "OK",
      "ai_premium_placeholder_title": "AI Premium",
      "ai_premium_placeholder_body":
          "AI Premium uchun ilova ichida to‘lov (Payme / Click) tez orada shu yerda bo‘ladi.",
      "ai_allowance_inline_chat_hint":
          "Bu oy chat tarjimalari qoldi (UTC): {count}",
      "listing_description_template_label": "Shablon",
      "listing_description_template_room_needed":
          "Xona/qo‘shilish qidiryapman.\nFormat: (alohida/qo‘shilish).\nMuddat: (kirish sanasi + qancha).\nMuhim: (tinchlik/mehmon/uy hayvoni).",
      "listing_description_template_roommate_needed_male":
          "Qo‘shni yigit qidiryapman.\nFormat: (xonada 1–2).\nKim yashaydi: (necha kishi).\nSharoit: (xo‘jayinsiz/xo‘jayinli), (alohida/umumiy xona).\nMuddat: (kirish) + (qancha).",
      "listing_description_template_roommate_needed_female":
          "Qo‘shni qiz qidiryapman.\nFormat: (xonada 1–2).\nKim yashaydi: (necha kishi).\nSharoit: (xo‘jayinsiz/xo‘jayinli), (alohida/umumiy xona).\nMuddat: (kirish) + (qancha).",
      "listing_description_template_group_forming":
          "Guruh bo‘lib ijara olish uchun odam yig‘yapmiz.\nKim kerak: (1–2 kishi, jins/yosh).\nHar kishi budjeti: (summa).\nHudud/metro: (qayerdan qidiramiz).\nFormat: (alohida/umumiy xonalar).\nKirish: (sana + muddat).\nMuhim: (tozalik/tinchlik/mehmon/uy hayvoni).",

      "listing_type_roommate_needed": "Xonadosh qidiryapman",
      "listing_type_roommate_needed_female": "Xonadosh qidiraman",
      "listing_type_room_needed": "Uy-joy qidiryapman",
      "listing_type_label": "E'lon turi",
      "listing_type_short_roommate_needed": "Xonadosh qidiramiz",
      "listing_type_short_roommate_needed_female": "Xonadosh qidiramiz",
      "listing_type_short_room_needed": "Xona qidiryapman",
      "listing_type_short_group_forming": "Guruh Yigamiz",
      "gender_short_male": "Yigit",
      "gender_short_female": "Qiz",
      "gender_badge_male": "Yigit",
      "gender_badge_female": "Qiz",
      "listing_photo_coming_soon": "Foto tez orada",
      "price_unit_uzs_per_month": "so'm/oy",
      "price_unit_usd_per_month": "\$/oy",
      "title_male_roommate": "#YigitXonadoshQidiramiz",
      "title_female_roommate": "#QizXonadoshQidiramiz",
      "title_male_room": "#YigitXonadonQidiramiz",
      "title_female_room": "#QizXonadonQidiramiz",
      "listing_photos_label": "Rasmlar",
      "listing_photos_count": "Rasmlar {current} / {max}",

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
      "drag_photo_to_reorder": "Tartib uchun suring. Birinchisi — asosiy.",
      "make_photo_primary": "Asosiy qilish",
      "making_primary": "Asosiy sifatida belgilash...",
      "add_photo": "Rasm qo'shish",
      "take_photo": "Rasm olish",
      "choose_from_gallery": "Galereyadan tanlash",
      "photo_limit_reached": "Maksimal {max} ta rasm",
      "retake": "Qayta olish",
      "use_photo": "Foydalanish",
      "flash": "Chaqnoq",
      "camera_unavailable": "Kamera mavjud emas",
      "error_picking_photo": "Rasmni yuklab bo'lmadi",
      "upload_profile_photo": "Profil rasmini yuklash",
      "profile_photo_updated": "Profil rasmi yangilandi",
      "error_uploading_profile_photo": "Profil rasmini yuklab bo'lmadi",
      "crop_profile_photo": "Rasmni kesish",
      "crop_listing_photo": "Rasmni kesish",
      "crop_done": "Tayyor",
      "crop_cancel": "Bekor qilish",
      "crop_rotate_left": "Chapga burish",
      "crop_rotate_right": "O'ngga burish",
      "crop_aspect_free": "Erkin",

      // Permission rationale screens
      "permission_camera_title": "E'lon uchun rasm",
      "permission_camera_body":
          "UyDosh kameraga kirish ruxsatini so'raydi, shunda siz e'lon rasmlarini to'g'ridan-to'g'ri ilovada olishingiz mumkin. Biz UyDosh suv belgisini avtomatik qo'shamiz, shunda rasmlardan boshqa e'lonlarda foydalanib bo'lmaydi.",
      "permission_camera_room_scan_title": "Xonanining 3D skani",
      "permission_camera_room_scan_body":
          "UyDosh LiDAR yordamida xona 3D skanini olish uchun kameraga ruxsat so'raydi. 3D model e'loningizga yuklanadi, shunda odamlar ko'rishdan oldin makonni tushunishlari mumkin.",
      "permission_camera_cta": "Kameraga ruxsat berish",
      "permission_camera_denied_title": "Kameraga kirish o'chirilgan",
      "permission_camera_denied_body":
          "Kameraga kirish iOS sozlamalarida o'chirilgan. Yoqish uchun Sozlamalarni oching yoki galereyadan rasm tanlang.",
      "permission_camera_open_settings": "Sozlamalarni ochish",
      "permission_camera_use_gallery": "Galereyadan tanlash",
      "permission_notifications_title": "Tezkor bildirishnomalar",
      "permission_notifications_body":
          "Sizning qidiringizga mos yangi e'lon paydo bo'lishi bilan xabar olish va e'loningiz bo'yicha xabar yuborganda ping olish uchun bildirishnomalarni yoqing.",
      "permission_notifications_cta": "Bildirishnomalarni yoqish",
      "permission_notifications_denied_body":
          "Bildirishnomalar iOS sozlamalarida o'chirilgan. Yoqish uchun Sozlamalarni oching, shunda qidiruv bildirishnomalari sizga yetib borishi mumkin.",
      "permission_not_now": "Hozir emas",
      "permission_skip": "O'tkazib yuborish",
      "crop_undo": "Bekor qilish",
      "crop_aspect_ratio": "Tomonlar nisbati",

      "max_photos_reached": "Maksimal rasmlar soniga yetildi",
      "max_photos_message":
          "Siz faqat {max} tagacha rasm yuklashingiz mumkin. Iltimos, yangi rasmlar qo'shishdan oldin ba'zi rasmlarni o'chiring.",

      "ok": "OK",
      "delete": "O'chirish",

      // ===== ONBOARDING =====
      "onboarding_title_1": "O‘z odamlaringizni toping",
      "onboarding_subtitle_1":
          "Ishonchli qo‘shnilar, halol e’lonlar\nva ortiqcha odamlarsiz birgalikdagi ijara.",
      "onboarding_title_2": "Yashash qulay bo‘lgan joydan qidiring",
      "onboarding_subtitle_2":
          "Metro, tuman yoki universitetni tanlang —\nyaqindagi mos kvartiralar va qo‘shnilarni ko‘rsatamiz.",
      "onboarding_title_3": "Tuman bo'yicha qidiruv",
      "onboarding_subtitle_3": "Toshkent tumanlari bo'yicha qulay qidiruv",
      "onboarding_title_4": "Rieltorlarsiz va begonalarsiz",
      "onboarding_subtitle_4":
          "Biz halol hamjamiyat qurmoqdamiz:\ntekshirilgan profillar, shikoyatlar va firibgarlardan himoya.",

      "onboarding_get_started": "Boshlash",
      "onboarding_skip": "O'tkazib yuborish",
      "onboarding_next": "Keyingi",
      "onboarding_back": "Orqaga",
      "onboarding_toggle": "Boshlash",
      "onboarding_toggle_description": "Xush kelish ekrani",
      "haptic_feedback": "Haptik javob",
      "haptic_feedback_description": "Bosish va jestlar uchun tebranish",
      "restore_filters_on_start": "Filtrlarni ilova ochilganda tiklash",
      "restore_filters_on_start_description":
          "Ilova ishga tushganda oxirgi qidiruv filtrlaringiz qayta qo'llaniladi. Har safar toza qidiruvdan boshlash uchun o'chiring.",
      "sound_effects": "Ovoz effektlari",
      "sound_effects_description": "Harakatlar uchun qisqa UI-ovozlar",
      "ui_animations": "Interfeys animatsiyalari",
      "ui_animations_description": "Pulsatsiya va tebranish kabi effektlar",
      "ui_animations_optimized_for_device":
          "Ushbu qurilma uchun optimallashtirilgan",
      "ui_animation_search_pulse": "Qidiruv tugmasi pulsatsiyasi",
      "ui_animation_bell_idle": "Qo‘ng‘iroq tebranishi",
      "ui_animation_bell_tap": "Qo‘ng‘iroq bosish animatsiyasi",

      // ===== LANGUAGE & LOCALIZATION =====
      "current_language": "O'zbekcha",
      "language": "Til",
      "language_english": "English",
      "language_russian": "Русский",
      "language_uzbek": "O'zbekcha",
      "language_name_english": "Ingliz tili",
      "language_name_russian": "Rus tili",
      "language_name_uzbek": "O'zbek tili",
      "language_changed_to": "Til o'zgartirildi: {language}",
      "price_display_currency": "Narx valyutasi",
      "price_display_currency_national": "🇺🇿 O'zbek so'mi",
      "price_display_currency_usd": "🇺🇸 AQSh dollari (USD)",

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
      "open_in_telegram": "Telegram",
      "open_in_telegram_confirmation":
          "Telegram ilova yoki brauzerda ochiladi.",

      // New profile fields
      "work": "Ish",
      "employed": "Ishlaydi",
      "not_employed": "Ishlamayman",
      "cleanliness": "Tozalik",
      "noise_level": "Shovqin darajasi",
      "sociability": "Ijtimoiylik",
      "guests": "Mehmonlar",
      "guests_allowed": "Mehmonlar ruxsat etilgan",
      "guests_permitted": "Ruxsat berilgan",
      "guests_not_permitted": "Ruxsat berilmagan",
      "smoking_preference": "Chekish",
      "alcohol_preference": "Alkogol",
      "cooking_habits": "Pishirish",
      "pets_preference": "Hayvonlarga munosabat",
      "wakeup_time": "Uyg'onish vaqti",
      "sleep_time": "Uxlash vaqti",
      "sleep_schedule": "Uyqu rejimi",

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
      "pets_like_pets": "Hayvonlarni yaxshi ko'raman",
      "pets_dont_like_pets": "Hayvonlarni yoqtirmayman",
      "pets_have_cat": "Menda mushuk bor",
      "pets_have_dog": "Menda it bor",

      // Slider labels
      "lifestyle_preferences": "Turmush tarzi",
      "what_im_looking_for": "Men nimani qidiryapman",
      "what_im_looking_for_subtitle":
          "Sizni hamxonalar bilan yaxshiroq moslashtirishga yordam beradi",
      "preferred_roommate_gender": "Hamxona jinsi (afzal)",
      "any_gender": "Farqi yo'q",
      "your_birth_year": "Tug'ilgan yilingiz",
      "birth_year_hint": "masalan, 2000",
      "desired_age_range": "Hamxonaning afzal yoshi",
      "age_from_hint": "Dan",
      "age_to_hint": "Gacha",
      "your_budget_range": "Oylik byudjetingiz",
      "budget_from_hint": "Dan",
      "budget_to_hint": "Gacha",
      "require_budget_overlap": "Byudjetlar mos kelishi shart",
      "dealbreakers_label": "Murosasiz shartlar",
      "dealbreakers_hint": "Mos kelmasa, moslik keskin pasayadi",
      "top_priorities_label": "Asosiy ustuvorliklar",
      "top_priorities_hint": "Kuchliroq hisobga olinadi (3 tagacha)",
      "match_dim_gender": "Jins",
      "match_dim_age": "Yosh",
      "match_dim_budget": "Byudjet",
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
      "cook": "Uyda pishiraman",
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

      "are_you_landlord_or_renter":
          "Siz ijaraga beruvchimisiz yoki ijarachimisiz?",
      "select_your_primary_role": "Asosiy rol",
      "tap_to_select_primary_role": "Rolni tanlang",

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
      "menu_language": "Til",

      "menu_favorites": "Sevimlilar",
      "nav_my": "Mening",
      "menu_history": "Tarix",
      "menu_contact_support": "Qo'llab-quvvatlash bilan bog'lanish",
      "menu_add_listing": "E'lon qo'shish",
      "menu_my_listings": "Mening e'lonlarim",
      "menu_my_groups": "Mening guruhlarim",
      "my_hub_tab_groups": "Guruhlar",
      "my_hub_tab_bookmarks": "Mening xatcho'plarim",
      "my_hub_tab_alerts": "Mening ogohlantirishlarim",
      "my_groups_empty_subtitle":
          "Siz boshqaradigan yoki qo'shilgan guruhlar shu yerda ko'rinadi.",
      "menu_gigs": "Xizmatlar",

      // ===== GIGS =====
      "gigs_hub_title": "Xizmatlar",
      "gigs_hub_browse_title": "Xizmatlarni topish",
      "gigs_hub_browse_subtitle": "Vazifa bilan yordam beradigan kishilar",
      "gigs_hub_post_title": "Vazifa joylash",
      "gigs_hub_post_subtitle": "Sizga nima kerakligini yozing — taklif olasiz",
      "gigs_hub_my_bookings_title": "Mening buyurtmalarim",
      "gigs_hub_my_bookings_subtitle":
          "Siz buyurtma qilgan yoki qabul qilgan vazifalar",
      "gigs_hub_open_requests_title": "Ochiq vazifalar",
      "gigs_hub_open_requests_subtitle": "Bajaruvchi izlayotgan vazifalar",
      "gigs_hub_publish_offer_title": "Xizmat e'lon qilish",
      "gigs_hub_publish_offer_subtitle":
          "Mahoratingizni taklif qiling — mijozlar topadi",
      "gigs_hub_publish_title": "Joylash",
      "gigs_hub_publish_subtitle":
          "Bajarilishi kerak vazifa yoki siz taklif qilayotgan xizmat",
      "gigs_publish_screen_title": "Joylash",
      "gigs_publish_mode_task": "Vazifa",
      "gigs_publish_mode_task_subtitle": "Menga nimadir qilish kerak",
      "gigs_publish_mode_service": "Xizmat",
      "gigs_publish_mode_service_subtitle": "Men nimadir qilishni bilaman",
      "gigs_hub_feed_services": "Xizmatlar",
      "gigs_hub_feed_tasks": "Vazifalar",

      "gigs_browse_title": "Xizmatlar",
      "gigs_browse_empty": "Hozircha xizmatlar yo'q.",
      "gigs_offer_detail_title": "Xizmat",
      "gigs_offer_book_cta": "Xizmatni buyurtma qilish",
      "gigs_offer_book_view_orders_cta":
          "Buyurtma qilindi: {user_name} bilan chat",
      "gigs_offer_edit_cta": "Xizmatni tahrirlash",
      "gigs_offer_provider_fallback": "Bajaruvchi",
      "gigs_offer_provider_completed_jobs": "Bajarilgan buyurtmalar: {count}",
      "gigs_offer_tile_jobs_other": "{count} buyurtma",
      "gigs_offer_tile_reviews_other": "{count} sharh",
      "gigs_booking_created_toast": "Buyurtma yaratildi.",

      "gigs_post_request_title": "Vazifa joylash",
      "gigs_post_request_submit": "Joylash",
      "gigs_loading": "Yuklanmoqda…",
      "gigs_categories_unavailable":
          "Kategoriyalar mavjud emas. Qayta urinib ko'ring.",
      "gigs_post_request_field_category": "Kategoriya",
      "gigs_post_request_field_title": "Sarlavha",
      "gigs_post_request_field_description": "Tavsif (ixtiyoriy)",
      "gig_description_template_service":
          "Taklif qilaman:\n(Qamrov — nima kiradi)\n\nQayer va qachon:\n(Hudud yoki masofadan) · (mavjudlik)\n\nIzoh:\n(tajriba, materiallar va h.k.)",
      "gig_description_template_task":
          "Kerak:\n(Vazifani tasvirlang)\n\nQayer va qachon:\n(Manzil yoki masofadan) · (sana/vaqt)\n\nKirish / izoh:\n(avtoturargoh, asboblar, cheklovlar)",
      "gigs_post_request_field_budget_type": "Byudjet turi",
      "gigs_post_request_field_amount": "Summa",
      "gigs_post_request_field_address": "Manzil (ixtiyoriy)",
      "gigs_post_field_address_detail": "Batafsil manzil (ixtiyoriy)",
      "address_suggest_connection_error":
          "Manzil takliflarini yuklab bo‘lmadi. Internet aloqasini tekshiring.",
      "address_suggest_unavailable": "Manzil takliflari vaqtincha mavjud emas.",
      "address_suggest_failed": "Manzil takliflarini yuklab bo‘lmadi.",
      "gigs_post_field_district": "Tuman (ixtiyoriy)",
      "gigs_post_request_field_remote": "Masofadan",
      "gigs_post_request_required": "Majburiy",
      "gigs_post_request_choose_category": "Kategoriyani tanlang",
      "gigs_post_request_success_toast": "Vazifa joylandi.",
      "gigs_budget_type_fixed": "Aniq",
      "gigs_budget_type_hourly": "Soatlik",
      "gigs_budget_type_open": "Ochiq",

      "gigs_post_offer_title": "Xizmat e'lon qilish",
      "gigs_post_offer_submit": "E'lon qilish",
      "gigs_post_offer_success_toast": "Xizmat e'lon qilindi.",
      "gigs_edit_offer_title": "Xizmatni tahrirlash",
      "gigs_edit_offer_submit": "Saqlash",
      "gigs_edit_offer_success_toast": "Xizmat yangilandi.",
      "gigs_edit_request_title": "Vazifani tahrirlash",
      "gigs_edit_request_success_toast": "Vazifa yangilandi.",
      "gigs_request_edit_cta": "Vazifani tahrirlash",
      "gigs_request_delete_menu": "Vazifani o'chirish",
      "gigs_request_delete_title": "Vazifani o'chirasizmi?",
      "gigs_request_delete_message":
          "U hamma uchun ro'yxatdan yo'qoladi. Ilovada bekor qilib bo'lmaydi.",
      "gigs_request_delete_success": "Vazifa o'chirildi.",
      "gigs_request_delete_failed":
          "Vazifani o'chirib bo'lmadi. Qayta urinib ko'ring.",
      "gigs_offer_delete_menu": "Xizmatni o'chirish",
      "gigs_offer_delete_title": "Xizmatni o'chirasizmi?",
      "gigs_offer_delete_message":
          "U hamma uchun ro'yxatdan yo'qoladi. Ilovada bekor qilib bo'lmaydi.",
      "gigs_offer_delete_success": "Xizmat o'chirildi.",
      "gigs_offer_delete_failed":
          "Xizmatni o'chirib bo'lmadi. Qayta urinib ko'ring.",
      "gigs_post_offer_field_pricing_type": "Narx turi",
      "gigs_post_offer_field_price": "Narx",
      "gigs_post_offer_field_min_duration": "Minimal davomiylik (daqiqa)",
      "gigs_post_offer_field_min_duration_hint": "masalan, 60",
      "gigs_pricing_type_fixed": "Aniq",
      "gigs_pricing_type_hourly": "Soatlik",
      "gigs_pricing_type_per_unit": "Birlik uchun",

      "gigs_my_bookings_title": "Buyurtmalarim",
      "gigs_my_bookings_tab_all": "Barchasi",
      "gigs_my_bookings_tab_client": "Buyurtmachi sifatida",
      "gigs_my_bookings_tab_provider": "Bajaruvchi sifatida",
      "gigs_my_bookings_empty": "Buyurtmalar yo'q.",
      "gigs_my_published_title": "Men nashr qilganlar",
      "gigs_my_published_tab_services": "Xizmatlar",
      "gigs_my_published_tab_tasks": "Vazifalar",
      "gigs_my_published_add_service": "Xizmat qo'shish",
      "gigs_my_published_add_task": "Vazifa qo'shish",
      "gigs_my_published_empty_services":
          "Siz hali hech qanday xizmat joylashtmagansiz.",
      "gigs_my_published_empty_tasks":
          "Siz hali hech qanday vazifa joylashtmagansiz.",
      "gigs_my_published_sign_in":
          "Joylashtirgan xizmat va vazifalaringizni ko‘rish uchun kiring.",
      "gigs_action_cancel": "Bekor qilish",
      "gigs_action_mark_complete": "Tugallandi",
      "gigs_status_pending": "Kutilmoqda",
      "gigs_status_accepted": "Qabul qilindi",
      "gigs_status_in_progress": "Jarayonda",
      "gigs_status_completed": "Tugallandi",
      "gigs_status_cancelled": "Bekor qilindi",
      "gigs_status_disputed": "Nizoli",

      "gigs_chat_menu_invite_provider_to_book":
          "Bron qilishga taklif (tasdiqlashi kerak)",
      "gigs_invite_provider_dialog_title": "Bajaruvchini taklif qilish",
      "gigs_invite_provider_dialog_body":
          "Ish tasdiqlanishidan oldin u «Buyurtmalarim»da Qabul tugmasini bosishi kerak. Vazifada summasi bo‘lmasa, kelishilgan miqdorni kiriting.",
      "gigs_invite_provider_dialog_field_hint":
          "Kelishilgan summa (vazifada summa yo‘q bo‘lsa majburiy)",
      "gigs_invite_provider_confirm": "Taklif yuborish",
      "gigs_invite_provider_success_toast":
          "Taklif yuborildi. «Buyurtmalarim»da qabul qilishi mumkin.",
      "gigs_invite_provider_failed_toast":
          "Yuborib bo‘lmadi. Qayta urinib ko‘ring.",
      "gigs_invite_provider_amount_required":
          "Summani kiriting yoki oldin vazifaga byudjet qo‘shing.",
      "gigs_invite_provider_owner_only":
          "Faqat vazifa muallifi taklif yubora oladi.",
      "gigs_invite_provider_not_open_task":
          "Bu vazifa endi taklif uchun ochiq emas.",
      "gigs_action_accept_booking": "Qabul qilish",
      "gigs_action_chat_booking": "Suhbat",
      "gigs_booking_chat_peer_fallback": "Ishtirokchi",
      "gigs_booking_cancel_confirm_title": "Buyurtmani bekor qilasizmi?",
      "gigs_booking_cancel_confirm_message":
          "Boshqa ishtirokchi xabardor qilinadi.",

      "gigs_requests_title": "Ochiq vazifalar",
      "gigs_requests_empty": "Hozircha ochiq vazifa yo'q.",
      "gigs_request_budget_open": "Byudjet ko'rsatilmagan",
      "gigs_request_budget_fixed": "Byudjet: {amount} {currency}",
      "gigs_request_detail_title": "Vazifa",
      "gigs_request_description_label": "Vazifa haqida",
      "gigs_request_contact_cta": "Buyurtmachiga yozish",
      "gigs_request_contact_failed":
          "Chatni ochib bo'lmadi. Qayta urinib ko'ring.",
      "gigs_request_messages_appbar_semantics": "Ushbu vazifa bo'yicha chatlar",
      "gigs_request_messages_title": "Vazifa chatlari",
      "gigs_request_messages_empty": "Bu vazifa bo'yicha hali chat yo'q.",
      "gigs_request_messages_empty_subtitle":
          "Ijrochilar yozganda suhbatlar shu yerda ko'rinadi.",

      "gigs_price_per_hour": "{amount} {currency} / soat",
      "gigs_price_per_unit": "{amount} {currency}/dona",
      "gigs_price_fixed": "{amount} {currency}",
      "gigs_retry": "Qayta urinish",
      "gigs_scheduled_at": "Rejalashtirilgan: {when}",

      "menu_about": "Ilova haqida",
      "menu_privacy_policy": "Maxfiylik siyosati",
      "menu_user_license_agreement": "Foydalanuvchi litsenziya shartnomasi",
      "menu_faq": "Savol-javob",
      "menu_settings": "Sozlamalar",
      "menu_registration": "Kirish",
      "menu_logout": "Chiqish",
      "menu_admin_panel": "Admin paneli",
      "profile_menu_collapsible_listings_group": "E'lonlar va suhbatlar",
      "profile_menu_collapsible_services_group": "Bildirishnomalar va yordam",
      "manage_property": "Uyni boshqarish",

      "admin_panel_title": "Admin paneli",
      "admin_panel_category_management": "Foydalanuvchilar va moderatsiya",
      "admin_panel_category_maps": "Xaritalar",
      "admin_panel_category_analytics": "Analitika",
      "admin_panel_category_settings": "Ilova sozlamalari",
      "admin_panel_section_content_moderation": "Klient sozlamalari",
      "admin_content_moderation_title": "Klient sozlamalari",
      "admin_client_settings_show_listing_contacts":
          "Eʼlondagi kontaktlarni ko‘rsatish",
      "admin_client_settings_show_listing_contacts_description":
          "Kontaktlar bo'lsa, «Moslik»da Telegram va qo'ng'iroq tugmalari.",
      "admin_client_settings_show_price_insights":
          "Narx bo‘yicha orientirni ko‘rsatish",
      "admin_client_settings_show_price_insights_description":
          "E’lon kartasida tuman/stansiya bo‘yicha median narx.",
      "admin_client_settings_show_push_debug": "Push debug panelini ko‘rsatish",
      "admin_client_settings_show_push_debug_description":
          "«Bildirishnomalar» ekranida push debug vositalarini ko‘rsatadi (faqat adminlar uchun).",
      "admin_client_settings_show_listing_move_to_top":
          "Eʼlonni yuqoriga ko‘tarish boshqaruvini ko‘rsatish",
      "admin_client_settings_show_listing_move_to_top_description":
          "Eʼlon sahifasidagi egasi tugmasi, admin menyusi va lenta plitkasida uzoq bosish.",
      "admin_client_config_hide_gemini_listing_ui":
          "Tarjima va AI yaxshilashni ko‘rsatish",
      "admin_client_config_hide_gemini_listing_ui_description":
          "E’lon tafsifida til tugmalari; yaratish/tahrirlashda AI yaxshilash.",
      "admin_client_config_disable_custom_camera":
          "Maxsus kameradan foydalanish",
      "admin_client_config_disable_custom_camera_description":
          "Yoniq — suv belgili ilova kamerasi; o‘chiq — qurilma kamerasi.",
      "admin_client_config_show_listing_dictation_meter":
          "Diktat darajasi va taymer",
      "admin_client_config_show_listing_dictation_meter_description":
          "Diktovqa paytida toʻlqin va taymer; aks holda faqat mik/stop.",
      "admin_client_config_disable_lidar_room_scan":
          "LiDAR xona skanini yoqish",
      "admin_client_config_disable_lidar_room_scan_description":
          "Yaratgach skan qadamı, tahrirda tugma, yuklash.",
      "admin_content_moderation_blur_enabled":
          "Nojo'ya fotolarni aniqla va xira qil",
      "admin_content_moderation_loading":
          "Moderatsiya sozlamalari yuklanmoqda...",
      "admin_content_moderation_error": "Moderatsiya sozlamalari yuklanmadi",
      "admin_content_moderation_save_error": "Sozlama saqlanmadi",
      "admin_app_setting_listing_gig_moderation_queue_title":
          "Yangi e'lon va gig'larni tasdiqlash",
      "admin_app_setting_listing_gig_moderation_queue_subtitle":
          "Yangi e'lon va giglar admin tasdig'igacha yashiriladi.",
      "admin_app_setting_phone_sign_in_enabled_title":
          "Telefon raqami bilan kirishga ruxsat",
      "admin_app_setting_phone_sign_in_enabled_subtitle":
          "Kirish oynasida Firebase SMS orqali kirish.",
      "admin_app_setting_listing_owner_conversations_title":
          "E'lon chatlari (admin)",
      "admin_app_setting_listing_owner_conversations_subtitle":
          "Yoqilganda admin e'lon sahifasidan shu e'lon bo'yicha barcha in-app chatlarni ochishi mumkin.",
      "admin_app_setting_group_forming_membership_limit_title":
          "Har foydalanuvchi uchun aktiv guruhlar limiti",
      "admin_app_setting_group_forming_membership_limit_subtitle":
          "Foydalanuvchi yaratgan va qo'shilgan guruhlar hisobga olinadi.",

      "admin_panel_section_telegram_sync": "Maʼlumot importi",
      "admin_panel_section_telegram_listing_groups": "Telegram e'lon guruhlari",
      "admin_telegram_listing_groups_title": "Telegram e'lon guruhlari",
      "admin_telegram_listing_groups_loading": "Guruhlar yuklanmoqda…",
      "admin_telegram_listing_groups_empty":
          "Import qilingan e'lonlar topilmadi",
      "admin_telegram_listing_groups_detail_empty": "Bu guruhda e'lonlar yo'q",
      "admin_telegram_listing_groups_error": "Guruhlarni yuklashda xatolik",
      "admin_telegram_listing_groups_unknown": "Kontaktsiz (guruhsiz)",
      "admin_telegram_listing_groups_listing_count": "{count} ta e'lon",
      "admin_telegram_listing_groups_summary_scraped":
          "Import qilingan e'lonlar",
      "admin_telegram_listing_groups_summary_groups": "Guruhlar",
      "admin_telegram_listing_groups_summary_duplicates": "Dublikatli guruhlar",
      "admin_telegram_listing_groups_summary_ungrouped": "Guruhsiz e'lonlar",
      "admin_telegram_listing_groups_sort_title": "Guruhlarni saralash",
      "admin_telegram_listing_groups_sort_count": "Ko'p e'lonli",
      "admin_telegram_listing_groups_sort_recent": "So'nggi faollik",
      "admin_telegram_listing_groups_sort_name": "Nomi (A–Z)",
      "admin_telegram_sync_title": "Maʼlumot importi",
      "admin_telegram_sync_chat_label": "Chat",
      "admin_telegram_sync_chat_custom_label": "Boshqa chat (@handle yoki id)",
      "admin_telegram_sync_channel_custom": "Boshqa…",
      "admin_telegram_sync_channels_loading": "Kanallar yuklanmoqda…",
      "admin_telegram_sync_add_channel": "Kanal qo‘shish",
      "admin_telegram_sync_add_channel_title": "Telegram kanal qo‘shish",
      "admin_telegram_sync_add_channel_label": "Kanal handle",
      "admin_telegram_sync_add_channel_helper":
          "@handle, t.me/handle yoki raqamli chat id kiriting.",
      "admin_telegram_sync_add_channel_invalid":
          "Bo‘sh joysiz to‘g‘ri kanal yoki id kiriting.",
      "admin_telegram_sync_add_channel_save": "Qo‘shish",
      "admin_telegram_sync_add_channel_done": "{channel} qo‘shildi.",
      "admin_telegram_sync_limit_label": "Xabar limiti",
      "admin_telegram_sync_import_user_label": "E’lon egasi user ID",
      "admin_telegram_sync_import_user_sync_only":
          "Faqat DB sinxron (e’lon importisiz)",
      "admin_telegram_sync_admins_loading": "Adminlar ro‘yxati yuklanmoqda…",
      "admin_telegram_sync_admins_error": "Adminlar ro‘yxati yuklanmadi",
      "admin_telegram_sync_admins_retry": "Qayta urinish",
      "admin_telegram_sync_admins_empty": "Adminlar topilmadi.",
      "admin_telegram_sync_newest_first": "Avval yangilar",
      "admin_telegram_sync_skip_listing_import": "E’lon importisiz (faqat DB)",
      "admin_telegram_sync_run": "Sinxronni ishga tushirish",
      "admin_telegram_sync_running": "Bajarilmoqda…",
      "admin_telegram_sync_result_header": "Natija",
      "admin_telegram_sync_sync_section": "DB sinxron",
      "admin_telegram_sync_listing_section": "E’lon importi",
      "admin_telegram_sync_log_scanned": "ko‘rib chiqildi",
      "admin_telegram_sync_log_created": "yaratildi",
      "admin_telegram_sync_log_skipped_no_peer": "peerYo‘qO‘tkazibYuborildi",
      "admin_telegram_sync_log_skipped_broadcast": "broadcastO‘tkazibYuborildi",
      "admin_telegram_sync_log_skipped_empty": "bo‘shO‘tkazibYuborildi",
      "admin_telegram_sync_log_skipped_no_type": "turiYo‘qO‘tkazibYuborildi",
      "admin_telegram_sync_log_skipped_failed": "xatoBilanO‘tkazibYuborildi",
      "admin_telegram_sync_log_errors_title": "Xatolar:",
      "admin_telegram_sync_log_more": "… (yana {count})",
      "admin_telegram_sync_invalid_chat_limit":
          "Chat kiriting (masalan @roommateuz).",
      "admin_area_price_cache_section_title": "E’lon hududi narxlari keshi",
      "admin_area_price_cache_run": "Narx keshini yangilash",
      "admin_area_price_cache_running": "Kesh qayta hisoblanmoqda…",
      "admin_area_price_cache_screen_body":
          "Metro bekati, liniya va tuman bo‘yicha median va o‘rtacha ijarani keshda qayta hisoblaydi (e’lon tafsilotidagi «atrofdagi narx» bloki). Katta Telegram importidan keyin yoki bo‘sh qolsa ishga tushiring.",
      "admin_telegram_export_section_title":
          "Yuklangan xabarlarni yuklab olish",
      "admin_telegram_export_intro":
          "telegram_ingested_messages jadvalidan .jsonl fayl (har qatorda bitta JSON). Telegram chaqiruvi yo‘q. Barcha chatlar, hajm maks. qatorlar bilan cheklangan.",
      "admin_telegram_export_max_rows_label": "Maks. qatorlar",
      "admin_telegram_export_download": "Eksportni yuklab olish",
      "admin_telegram_export_running": "Fayl tayyorlanmoqda…",
      "admin_telegram_export_invalid_max_rows":
          "Maks. qatorlar 1 dan 500000 gacha bo‘lishi kerak.",
      "admin_telegram_export_done":
          "Tayyor — ulashish oynasi yoki brauzer yuklab olishi.",
      "admin_data_import_danger_section_title": "Xavfli zona",
      "admin_data_import_danger_intro":
          "Ma'lumotlar bazasini tozalaydigan buzg'unchi amallar. dev/staging muhitida qayta import qilishdan oldin ishlating. Qaytarib bo'lmaydi.",
      "admin_data_import_clear_listings_button": "E'lonlar jadvalini tozalash",
      "admin_data_import_clear_listings_running": "E'lonlar tozalanmoqda…",
      "admin_data_import_clear_listings_confirm_title":
          "Barcha e'lonlarni tozalaysizmi?",
      "admin_data_import_clear_listings_confirm_body":
          "Bu listings jadvalidagi barcha qatorlarni o'chiradi. Fotolar, qulayliklar, sevimlilar, shikoyatlar, suhbatlar va Telegram’dan yuklangan xabarlar ham o'chadi. ID-sekvenslar qayta boshlanadi. Qaytarib bo'lmaydi.",
      "admin_data_import_clear_listings_done":
          "{listings_str} ({ingested_str} bilan birga) tozalandi.",
      "admin_data_import_clear_ingested_button":
          "Yuklangan Telegram xabarlarini tozalash",
      "admin_data_import_clear_ingested_running":
          "Yuklangan xabarlar tozalanmoqda…",
      "admin_data_import_clear_ingested_confirm_title":
          "Yuklangan Telegram xabarlarini tozalaysizmi?",
      "admin_data_import_clear_ingested_confirm_body":
          "Bu telegram_ingested_messages jadvalidagi barcha qatorlarni o'chiradi. E'lonlar saqlanib qoladi. ID-sekvens qayta boshlanadi. Qaytarib bo'lmaydi.",
      "admin_data_import_clear_ingested_done": "{ingested_str} tozalandi.",
      "listings_count_other": "{count} e'lon",
      "ingested_messages_count_other": "{count} yuklangan xabar",
      "admin_data_import_clear_confirm_action": "Tozalash",
      "admin_panel_section_users": "Foydalanuvchilar",
      "admin_reassign_ownership_submit": "O'tkazish",
      "admin_reassign_ownership_success": "Ega yangilandi",
      "admin_reassign_owner_menu": "Egani almashtirish",
      "admin_reassign_owner_dialog_title": "Egani o'zgartirish",
      "admin_reassign_owner_search_placeholder":
          "Id, email yoki ism bo'yicha qidiruv",
      "admin_reassign_owner_from_user": "Ega ID: {id}",
      "admin_reassign_owner_listing_id": "E'lon ID: {id}",
      "admin_reassign_owner_gig_offer_id": "Taklif ID: {id}",
      "admin_reassign_owner_gig_request_id": "So'rov ID: {id}",
      "admin_reassign_owner_empty": "Hech kim topilmadi.",
      "admin_panel_section_support_chat": "Qo'llab-quvvatlash",
      "admin_panel_section_complaints": "Shikoyatlar",
      "admin_panel_section_listing_complaints": "Shikoyatli e'lonlar",
      "admin_panel_section_listing_moderation": "E'lonlarni tasdiqlash",
      "admin_listing_moderation_title": "Tasdiq kutilmoqda",
      "admin_listing_moderation_loading": "Moderatsiya navbati yuklanmoqda…",
      "admin_listing_moderation_error": "Navbat yuklanmadi",
      "admin_listing_moderation_retry": "Qayta urinish",
      "admin_listing_moderation_summary_total": "Navbatda",
      "admin_listing_moderation_summary_today": "Bugun",
      "admin_listing_moderation_summary_oldest": "Eng uzoq",
      "admin_listing_moderation_days_short": "kun",
      "admin_listing_moderation_section_list": "Ko'rib chiqish kutilmoqda",
      "admin_listing_moderation_empty": "Tasdiq kutilayotgan e'lonlar yo'q.",
      "admin_listing_moderation_open": "Ochish",
      "admin_listing_moderation_approve": "Tasdiqlash",
      "admin_listing_moderation_id": "ID",
      "admin_listing_moderation_user": "Foydalanuvchi",
      "admin_listing_moderation_load_more": "Yana",
      "admin_listing_moderation_approved_toast": "E'lon e'lon qilindi",
      "admin_listing_moderation_approve_confirm_title": "E'lon tasdiqlansinmi?",
      "admin_listing_moderation_approve_confirm_message":
          "E'lon chop etiladi va hammaga ko'rinadigan bo'ladi.",
      "admin_parser_review_title": "Parser tekshiruvi",
      "admin_parser_review_loading": "Parser tekshiruvi yuklanmoqda…",
      "admin_parser_review_error": "Parser tekshiruvini yuklab bo'lmadi",
      "admin_parser_review_raw_source": "Telegram'dagi asl post",
      "admin_parser_review_raw_empty": "(manbada matn yo'q)",
      "admin_parser_review_manual_source": "E'lon qo'lda qo'shilgan",
      "admin_parser_review_manual_source_description":
          "Bu e'lon foydalanuvchi tomonidan qo'lda qo'shilgan, Telegramdan import qilinmagan.",
      "admin_parser_review_section_fields": "Parser bashorati vs. joriy",
      "admin_parser_review_section_corrections": "Qayd etilgan tuzatishlar",
      "admin_parser_review_parser_label": "Parser",
      "admin_parser_review_current_label": "Joriy",
      "admin_parser_review_chip_added": "qo'shildi",
      "admin_parser_review_chip_removed": "olib tashlandi",
      "admin_parser_review_chip_changed": "o'zgartirildi",
      "admin_parser_review_chip_confirmed": "tasdiqlandi",
      "admin_parser_review_corrections_summary":
          "{total} tadan {changed} ta maydon tuzatildi",
      "admin_parser_review_open_full": "To'liq e'lonni ochish",
      "admin_parser_review_edit": "Tahrirlash va tuzatish",
      "admin_parser_review_already_approved": "Allaqachon tasdiqlangan",
      "admin_parser_review_field_title": "Sarlavha",
      "admin_parser_review_field_price": "Narx (USD)",
      "admin_parser_review_field_gender": "Jins bo'yicha afzallik",
      "admin_parser_review_field_metro": "Metro",
      "admin_parser_review_field_district": "Tuman",
      "admin_parser_review_field_move_in": "Ko'chib o'tish sanasi",
      "admin_parser_review_field_contact_phone": "Aloqa telefoni",
      "admin_parser_review_field_contact_telegram": "Telegram aloqasi",
      "admin_parser_review_field_amenities": "Qulayliklar",
      "admin_parser_review_field_description": "Tavsif",
      "admin_parser_review_owner_section": "Telegram egasi",
      "admin_parser_review_owner_hint": "username",
      "admin_parser_review_owner_help":
          "Ushbu e'lonni dastlab joylagan shaxsning Telegram @username'i. Telegram aloqasi ko'rsatilmaganda kontakt sifatida ishlatiladi.",
      "admin_parser_review_owner_save": "Egasini saqlash",
      "admin_parser_review_owner_saved": "Telegram egasi yangilandi",
      "admin_panel_section_gig_moderation": "Gig'larni tasdiqlash",
      "admin_gig_moderation_title": "Gig moderatsiyasi",
      "admin_gig_moderation_tab_offers": "Xizmatlar",
      "admin_gig_moderation_tab_requests": "Vazifalar",
      "admin_gig_moderation_section_offers": "Tekshiruvdagi xizmatlar",
      "admin_gig_moderation_section_requests": "Tekshiruvdagi vazifalar",
      "admin_gig_moderation_empty_offers":
          "Tasdiq kutilayotgan xizmatlar yo'q.",
      "admin_gig_moderation_empty_requests":
          "Tasdiq kutilayotgan vazifalar yo'q.",
      "admin_gig_moderation_provider": "Ijrochi",
      "admin_gig_moderation_client": "Buyurtmachi",
      "admin_gig_moderation_approved_offer_toast": "Xizmat e'lon qilindi",
      "admin_gig_moderation_approved_request_toast": "Vazifa e'lon qilindi",
      "admin_panel_section_district_heatmap": "Tumanlar issiqlik xaritasi",
      "admin_panel_section_subway_heatmap":
          "Metro liniyalari issiqlik xaritasi",
      "admin_panel_section_subway_map": "Metro sxemasi",
      "admin_panel_section_universities_map": "Universitetlar xaritasi",
      "admin_universities_map_title": "Universitetlar xaritasi",
      "admin_universities_map_error": "Universitetlar yuklanmadi",
      "admin_universities_map_retry": "Qayta urinish",
      "admin_universities_map_empty":
          "Xarita koordinatalari bor universitetlar hali yo'q.",
      "admin_panel_section_search_analytics": "Qidiruv statistikasi",
      "admin_panel_section_listing_creation_analytics":
          "E'lonlar yaratilishi statistikasi",

      "admin_search_analytics_title": "Qidiruv statistikasi",
      "admin_search_analytics_loading": "Qidiruv statistikasi yuklanmoqda...",
      "admin_search_analytics_error": "Statistika yuklanmadi",
      "admin_search_analytics_retry": "Qayta urinish",
      "admin_search_analytics_time_range": "Davr",
      "admin_search_analytics_days": "So'nggi {days} kun",
      "admin_search_analytics_days_other": "So'nggi {count} kun",
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
      "admin_listing_creation_analytics_by_month": "Oylar bo'yicha e'lonlar",
      "admin_listing_creation_analytics_no_data":
          "Tanlangan davrda ma'lumot yo'q",

      "admin_district_heatmap_title": "Tumanlar issiqlik xaritasi",
      "admin_district_heatmap_loading": "Tumanlar statistikasi yuklanmoqda...",
      "admin_district_heatmap_error": "Tumanlar statistikasi yuklanmadi",
      "admin_district_heatmap_retry": "Qayta urinish",
      "admin_district_heatmap_total": "Jami e'lonlar",
      "admin_district_heatmap_max": "Tumandagi maksimum",
      "admin_district_heatmap_count_label": "E'lonlar",
      "admin_district_heatmap_unavailable": "Mavjud emas",
      "admin_district_heatmap_no_data": "Tumanlar bo'yicha ma'lumot yo'q",

      "admin_subway_heatmap_title": "Metro liniyalari issiqlik xaritasi",
      "admin_subway_heatmap_loading":
          "Metro liniyalari statistikasi yuklanmoqda...",
      "admin_subway_heatmap_error": "Metro liniyalari statistikasi yuklanmadi",
      "admin_subway_heatmap_retry": "Qayta urinish",
      "admin_subway_heatmap_total": "Jami e'lonlar",
      "admin_subway_heatmap_max": "Liniyadagi maksimum",
      "admin_subway_heatmap_count_label": "E'lonlar",
      "admin_subway_heatmap_unavailable": "Mavjud emas",
      "admin_subway_heatmap_no_data": "Metro liniyalari bo'yicha ma'lumot yo'q",

      "admin_subway_map_title": "Metro sxemasi",

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
      "admin_user_detail_role_save": "Rolni saqlash",
      "admin_user_detail_role_updated": "Rol yangilandi",
      "admin_user_detail_view_listings": "E'lonlarni ko'rish",
      "admin_user_detail_view_complaints": "Shikoyatlarni ko'rish",
      "admin_user_detail_view_alerts": "Ogohlantirishlarni ko'rish",
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
      "admin_user_detail_self_moderation_not_allowed":
          "O'zingizning admin hisobingizni bloklab/ochib bo'lmaydi yoki rolini o'zgartirib bo'lmaydi.",
      "admin_user_detail_devices_title": "Qurilmalar",
      "admin_user_detail_devices_empty": "Ro'yxatdan o'tgan qurilmalar yo'q",
      "admin_user_detail_devices_last_seen": "Oxirgi faollik",
      "admin_user_detail_devices_model_unknown": "Noma'lum qurilma",
      "admin_user_detail_devices_details_unknown": "Ma'lumot yo'q",
      "admin_user_detail_devices_app_prefix": "Ilova",
      "admin_user_complaints_title": "Foydalanuvchi shikoyatlari",
      "admin_user_complaints_user": "Foydalanuvchi",
      "admin_user_complaints_empty": "Shikoyatlar topilmadi",
      "admin_user_complaints_group_count": "Shikoyatlar",

      "admin_user_listings_title": "Foydalanuvchi e'lonlari",
      "admin_user_listings_user": "Foydalanuvchi",
      "admin_user_listings_empty": "E'lonlar topilmadi",
      "admin_user_listings_error": "E'lonlarni yuklashda xatolik",
      "admin_user_alerts_title": "Foydalanuvchi ogohlantirishlari",
      "admin_user_alerts_empty": "Ogohlantirishlar topilmadi",

      "admin_complaints_title": "Shikoyatlar",
      "admin_complaints_loading": "Shikoyatlar yuklanmoqda...",
      "admin_complaints_empty": "Shikoyatlar topilmadi",
      "admin_complaints_error": "Shikoyatlarni yuklashda xatolik",
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
      "admin_complaints_view_author": "Foydalanuvchi profili",
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
      "admin_support_chat_days_ago_other": "{count} kun oldin",
      "admin_support_chat_no_messages": "Xabarlar hali yo'q",
      "admin_support_chat_reply_hint": "Javob yozing...",
      "admin_support_chat_close_thread": "Murojaatni yopish",
      "admin_support_chat_reopen_thread": "Qayta ochish",
      "admin_support_chat_closed": "Murojaat yopildi",
      "admin_support_chat_reopened": "Murojaat qayta ochildi",
      "admin_support_chat_thread_closed":
          "Murojaat yopilgan. Javob berish uchun qayta oching.",
      "contact_support_title": "Qo'llab-quvvatlash",
      "contact_support_loading": "Yuklanmoqda...",
      "contact_support_error": "Qo'llab-quvvatlash yuklanmadi",
      "contact_support_empty":
          "Murojaatlar hali yo'q. Yordam olish uchun yangi murojaat yarating.",
      "contact_support_new": "Yangi murojaat",
      "contact_support_message_hint": "Xabaringizni yozing...",
      "admin_listing_complaints_title": "Shikoyatli e'lonlar",
      "admin_listing_complaints_empty": "Shikoyatli e'lonlar yo'q",
      "admin_listing_complaints_error":
          "Shikoyatli e'lonlarni yuklashda xatolik",
      "admin_listing_complaints_categories_empty":
          "Shikoyat kategoriyalari yo'q",

      // ===== FAQ CONTENT =====
      "faq_question":
          "Xonadoshlar bilan qanday kelishish va nizolardan qanday qochish kerak?",
      "faq_answer":
          "Birga yashash — bu doimo hurmat va kelishish qobiliyati haqida. Tinchlik va do'stlikni saqlab qolishga yordam beradigan bir nechta oddiy qoidalar:\n\nShovqin\n\"Jimlik soatlari\" haqida kelishingiz. Musiqa uchun — quloqchinlar, qo'ng'iroqlar uchun — koridor yoki ko'cha. Har kimning qachon o'qish yoki dam olish vaqti ekanligini bilishi uchun jadval osish qulay.\n\nMehmonlar\nBir-biringizni oldindan ogohlantiring. Yaxshi qoida — mehmonlar uchun aniq kunlar va jimlik kunlari.\n\nHis-tuyg'ular\nAchchiqlanishni to'plamang. Agar biror narsa bezovta qilsa, tinch va darhol gapiring. Qo'shimcha stressni sport zalida yoki yugurishda chiqarish yaxshiroq.\n\nUmumiy ishlar\nBa'zan biror narsani birga qilish foydali: kinoga borish, sayr qilish, \"musiqa ostida tozalash\" tashkil etish. Umumiy xotiralar do'stlikni mustahkamlaydi.\n\nTozalash va uy ishlari\nMas'uliyatlarni bo'ling — kimdir polni artadi, kimdir axlatni olib chiqadi. Asosiy narsa — kelishish va shaxsiy chegaralarni hurmat qilish. Boshqalarning narsalarini ruxsatsiz tegmang.\n\nMuloqot\n\"Men-mesajlar\"dan foydalaning: \"sen meni jahldor qilasang\" o'rniga \"baland musiqa chalinsa, diqqatni jamlash qiyin\" deyish yaxshiroq.\n\nNizolarni hal qilish\nHamma narsani tinch muhokama qilishga harakat qiling, bir-biringizni tinglang. Nizo — dushman emas, balki umumiy yechim topish imkoniyati.\n\nOvqat\nBirgalikda xarid qilish yoki \"umumiy javon\" ochish haqida kelishishingiz mumkin.\n\nTartib va jimlik\nTozalash jadvali — eng yaxshi do'stingiz. Agar diqqatni jamlash kerak bo'lsa — kutubxonaga yoki kovorkingga borishingiz yoki yana \"jimlik soati\" qoidasini yoqishingiz mumkin.",

      "faq_question_2": "Kommunal qarzlar va ularni qanday oldini olish",
      "faq_answer_2":
          "Ba'zan kvartira bilan birga ijarachiga kommunal xizmatlar bo'yicha qarzlar ham \"sovg'a\" sifatida tushadi. Natijada — o'chirilgan yorug'lik yoki suv, ijaraga beruvchi esa to'lashga shoshilmaydi. Ijarachiga qoladi: zarar bilan ko'chib ketish yoki qarzni o'z hisobidan to'lash.\n\nBunday vaziyatlardan qochish uchun:\n\nImzolashdan oldin tekshirish\nShartnomani imzolashdan oldin xo'jayindan to'langan kommunal to'lovlar bo'yicha kvitansiyalar yoki hisobot so'rang.\n\nYozma kelishuv\nAgar qarz hali ham bo'lsa va uni to'lashga tayyor bo'lsangiz, albatta yozma kelishuv tuzing: qarz summasi kelajakdagi ijara uchun hisobga olinadi.\n\nShunday qilib siz ham pulni, ham tinchlikni saqlab qolasiz.",

      "faq_question_3": "Vad qilingan ta'mirlash uchun uch yil kutish kerak",
      "faq_answer_3":
          "Ko'pincha uy ijaraga olishda, xo'jayin kvartira muammolarini hal qilish, maishiy texnika va mebel sotib olishni va'da qiladi. Bularning barchasini u ko'chib kelgandan so'ng darhol bajarishni o'z zimmasiga oladi. Biroq vaqt o'tadi, muammolar qoladi. Bunday vaziyatning garovi bo'lmaslik uchun ijarachi ijaraga olish shartnomasiga maxsus shartlarni kiritishi kerak.\n\nShuningdek, ijarachi tomonidan ta'mirlash va ishlar davomida ijara haqini undirmaslik haqidagi og'zaki kelishuvlar ham tez-tez buziladi. Masalan, siz kvartirani o'z hisobingizdan ta'mirlaysiz va bir necha oy ijara haqini to'lamaysiz. Biroq ba'zi ijaraga beruvchilar kelishuvlarni \"unutib\" qo'yadi va yashash uchun to'lov talab qiladi. Ko'pincha tomonlar bezatish narxi haqida kelishmovchiliklar paydo bo'ladi, ba'zida esa ish sudga ham borga.\n\nShuning uchun ta'mirlashning barcha jihatlarini muhokama qilish, ularni ijaraga olish shartnomasida hisobga olish, shuningdek smeta tuzish va imzolash kerak.",

      "faq_question_4": "Sen endi mening do'stim emassan",
      "faq_answer_4":
          "Ko'pincha uyni qarindoshlar yoki do'stlarga ijaraga berishda shartnoma tuzilmaydi. Shu bilan birga, ko'plab janjallar va tortishuvlar aynan og'zaki ijara va'da va majburiyatlarini qabul qilgan qarindoshlar va do'stlar o'rtasida yuzaga keladi. Shuning uchun shartnoma tuzish yaxshiroq, hatto siz amakivachchangiz yoki yaqin do'stingizdan kvartira ijaraga olsangiz ham.\n\nKvartiralar vasiylik orqali ijaraga beriladigan hollar ham bor, unda ko'rsatilgan: vasiylik beruvchi vasiylik oluvchiga o'z kvartirasini ijaraga berish huquqini beradi. \"Lekin vasiylikda vasiylik oluvchining ijara haqini olish huquqiga ega ekanligi ko'rsatilmagan. Vaziyat yuzaga kelishi mumkin: ijarachi muntazam ravishda ijara summasini vasiylik oluvchiga to'laydi, lekin bir kuni uy-joy egasi paydo bo'lib, ijarachidan kvartira yashash davri uchun to'lov talab qiladi.\" Bunday holda hujjatlarni diqqat bilan o'rganish kerak, va agar vasiylikda ijara haqini olish huquqi ko'rsatilmagan bo'lsa, bu masalani muhokama qilish kerak.",

      "faq_question_5":
          "Ijarachilar va qo'shnilar uchun xavfsizlik qo'llanmasi",
      "faq_answer_5":
          "Ba'zan noqulay vaziyatlar nafaqat bizning platformamizda yuzaga keladi. Afsuski, noto'g'ri yoki muammoli odamlar hamma joyda uchraydi. Shuning uchun oddiy xavfsizlik qoidalarini eslab qolish muhim.\n\n🙏 Asosiy narsa — sizning xavfsizligingiz!\n\nUchrashuvdan oldin\n• Uchrashuvlarni faqat kunduzgi vaqtda rejalashtiring.\n• Ko'p odamli joylarni tanlang — kafe, savdo markazi, kamerali hovli.\n• Do'stlaringiz yoki qarindoshlaringizga qayerga va kim bilan uchrashayotganingizni ayting.\n\nUchrashuv paytida\n• Iloji bo'lsa, yolg'iz keling.\n• Shartnoma imzolanmaguncha pul va hujjatlarni \"qo'ldan qo'liga\" bermang.\n• Yozishmalar va hujjatlar fotosuratlarini/skanlarini saqlang — bu sizning himoyangiz.\n\nAgar tahdid his qilsangiz\n• Darhol uchrashuvni to'xtating va keting.\n• \"Yo'q\" deyishdan va aloqani uzishdan qo'rqmang.\n• Aniq xavf bo'lsa — 102 ga qo'ng'iroq qiling yoki eng yaqin politsiya bo'limiga murojaat qiling.\n\nUyDosh platformasida\n• Tasdiqlash tizimidan foydalaning — tasdiqlangan profillar xavfni kamaytiradi.\n• Shubhali e'lonlar va xatti-harakatlar haqida moderatorlarga xabar bering.\n• Esda tuting: ehtiyot bo'lish, keyin afsuslanishdan yaxshiroq.\n\n❤️ O'zingizni va bir-biringizni asrang!",

      // ===== LOGOUT & SESSION =====
      "logout_confirmation": "Chiqish tasdiqlash",
      "logout_description":
          "Chiqishni xohlaysizmi? Profilingizga kirish uchun qaytadan tizimga kirishingiz kerak bo'ladi.",
      "logout": "Chiqish",
      "logout_success": "Muvaffaqiyatli chiqildi",
      "session_expired":
          "Sessiya muddati tugadi. Iltimos, qayta tizimga kiring.",

      // ===== DELETE ACCOUNT =====
      "delete_account": "Hisobni o'chirish",
      "delete_account_confirmation":
          "Hisobingizni o'chirishni xohlaysizmi? Bu amalni bekor qilish mumkin emas. Barcha ma'lumotlaringiz, e'lonlaringiz va xabarlaringiz butunlay o'chiriladi.",
      "delete_account_success": "Hisob muvaffaqiyatli o'chirildi",
      "delete_account_error": "Hisobni o'chirishda xatolik",
      "delete_account_blocked":
          "Hisobingiz cheklangan. Bloklangan paytda hisobni o'chirish mumkin emas. Qo'llab-quvvatlash xizmatiga murojaat qiling.",
      "delete_account_not_allowed":
          "Bu hisobni ilova orqali o'chirib bo'lmaydi. Yordam kerak bo'lsa, qo'llab-quvvatlash xizmatiga yozing.",

      // ===== FAVORITES =====
      "favorites_title": "Sevimlilar",
      "favorites_empty_title": "Hali sevimlilar yo'q",
      "favorites_tab_listings": "Uy-joy",
      "favorites_tab_services": "Xizmatlar",
      "favorites_tab_tasks": "Vazifalar",
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
      "achievements_empty_desc":
          "Yutuqlarni ochish uchun harakatlarni bajaring",
      "achievements_auth_prompt":
          "Yutuqlaringizni ko'rish uchun tizimga kiring",

      "favorite_toggle_error": "Sevimli holatini yangilashda xatolik",
      "favorite_toggle_network_error":
          "Sevimli holatini yangilashda tarmoq xatoligi",

      "unable_to_load_favorites":
          "Sevimlilarni yuklash imkoni yo'q. Keyinroq urinib ko'ring.",

      // ===== CREATE & EDIT LISTING =====
      "create_listing_title": "E'lon qilish",
      "edit_profile": "Profilni tahrirlash",
      "updating_listing": "Yangilanmoqda...",
      "creating_listing": "Yaratilmoqda...",
      "title_required": "Sarlavha talab qilinadi",
      "title_too_long": "Sarlavha 50 belgidan ko'p bo'lmasligi kerak",
      "description_required": "Matn talab qilinadi",
      "description_too_long": "Matn 500 belgidan ko'p bo'p bo'lmasligi kerak",
      "location_required": "Iltimos, tuman tanlang",
      "location_metro_required": "Iltimos, metro bekatini tanlang",
      "location_district_required": "Iltimos, tuman tanlang",
      "price_required": "Iltimos, narxni belgilang",
      "listing_price_minimum": "Oyiga kamida 1 USD bo'lishi kerak",

      "auth_required_title": "Autentifikatsiya talab qilinadi",
      "authentication_required":
          "Autentifikatsiya talab qilinadi. Iltimos, e'lon yaratish uchun tizimga kiring.",

      "unauthenticated_listing_prompt":
          "E'lon yaratish va joylashtirish uchun hisobingizga kirishingiz kerak.",
      "authenticate_to_post_listing":
          "E'lon joylashtirish uchun tizimga kiring",
      "select_location_required": "Tumanni tanlang",
      "select_metro_line_optional": "Metro liniyasi",
      "metro_station_label": "Metro bekati",

      // ===== AMENITIES & FEATURES =====
      "amenities": "Qulayliklar",
      "amenities_header_roommate_needed": "Kvartirada bor:",
      "amenities_header_need_room": "Menga kerak:",
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
      "filters_bar_label": "Filtrlar",
      "search_alert_notify_me": "Paydo bo‘lsa xabar berish",
      "search_alert_cta_title": "Ushbu qidiruv bo‘yicha xabarlar?",
      "search_alert_cta_create": "Bildirishnoma yaratish",
      "search_clear_filters": "Filtrlarni tozalash",
      "search_alert_login_required":
          "Bu qidiruv bo'yicha bildirishnomalar uchun tizimga kiring.",
      "search_alert_created": "Mos e'lonlar chiqqanda xabar beramiz.",
      "search_alert_already_exists": "Bu bildirishnoma avval ham qo'shilgan.",
      "search_alert_too_wide":
          "Bildirishnomani saqlash uchun tuman yoki metro liniyasi/stansiyasini tanlang.",
      "search_alert_failed":
          "Bildirishnomani saqlab bo'lmadi. Qayta urinib ko'ring.",
      "search_alert_station_already_covered":
          "Bu bekat allaqachon bildirishnomalaringizga kiradi.",
      "search_alert_station_already_covered_by_line":
          "{station} bekati allaqachon {line} liniyasi bo‘yicha bildirishnomangizga kiradi.",
      "search_alert_permission":
          "Bildirishnomalar uchun sozlamalarda ruxsat bering.",
      "search_alert_bell_hint":
          "O'xshash e'lonlar haqida bildirishnomalar olish",
      "tutorial_search_description":
          "E'lonlarni tuman, narx, xona turi va boshqa parametrlar bo'yicha filtrlash uchun bosing.",
      "tutorial_profile_description":
          "Profilingiz va hisob sozlamalari shu yerda.",
      "tutorial_alert_bell_description":
          "Yangi mos e'lonlar uchun bildirishnoma yoqing.",
      "tutorial_notifications_bell_description":
          "Bildirishnomalaringiz shu yerda. Boshqarish uchun bosing.",

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
      "sign_in_with_google_or_apple": "Google yoki Apple orqali kirish",
      "sign_in_oauth_prompt": "Davom etish uchun kiring",
      "sign_in_oauth_continue": "Davom etish",
      "auth_wizard_oauth_step_header": "UyDosh ga kirish",
      "successfully_logged_in": "Muvaffaqiyatli tizimga kirdingiz",

      "signing_in": "Tizimga kirilmoqda...",
      "google_sign_in_failed": "Google orqali kirishda xatolik: {error}",
      "popup_closed": "Kirish oynasi yopildi",

      // ===== APPLE AUTHENTICATION (iOS only) =====
      "sign_in_with_apple": "Apple orqali kirish",
      "sign_in_with_telegram": "Telegram orqali kirish",
      "link_telegram": "Telegramni ulash",
      "unlink_telegram": "Telegramni uzish",
      "telegram_account_linked": "Telegram hisobi ulangan",
      "telegram_linked_success": "Telegram hisobingizga ulandi",
      "telegram_unlinked_success": "Telegram hisobingizdan uzildi",
      "telegram_unlinked_relink_hint":
          "Qayta ulash uchun profildagi «Telegramni ulash» tugmasidan foydalaning — kirish ekranidagi «Telegram orqali kirish» emas.",
      "telegram_already_linked": "Telegram allaqachon ushbu hisobga ulangan",
      "telegram_not_linked": "Telegram ushbu hisobga ulanmagan",
      "telegram_only_sign_in_method":
          "Telegramni uzishdan oldin Google, Apple yoki telefon orqali kirishni qo'shing",
      "telegram_unlink_failed": "Telegramni uzib bo'lmadi: {error}",
      "unlink_telegram_confirmation_title": "Telegramni uzish?",
      "unlink_telegram_confirmation_message":
          "Endi ushbu hisobga Telegram orqali kira olmaysiz. Profildagi foydalanuvchi nomi qoladi.",
      "telegram_account_in_use": "Bu Telegram boshqa UyDosh hisobiga ulangan",
      "telegram_link_failed": "Telegramni ulab bo'lmadi: {error}",
      "telegram_bind_not_available":
          "Telegramni ulash hozircha mavjud emas. Ilovani yangilang yoki keyinroq urinib ko'ring.",
      "telegram_bind_invalid_token":
          "Telegram sessiyasi tugagan. Qayta ulashga harakat qiling.",
      "telegram_bind_not_configured":
          "Telegram orqali kirish serverda vaqtincha ishlamayapti.",
      "telegram_login_continue_in_browser":
          "Brauzerda kirishni yakunlang, so‘ng ilovaga qayting.",
      "telegram_sign_in_failed":
          "Telegram orqali kirish amalga oshmadi: {error}",
      "could_not_open_telegram": "Telegramni ochib bo‘lmadi",
      "telegram_alerts_enable_title": "Telegramda bildirishnomalar?",
      "telegram_alerts_enable_body":
          "Push ishlamasa, xabarlar va qidiruv mosliklari Telegramga keladi.",
      "telegram_alerts_enable_button": "Telegramda yoqish",
      "telegram_alerts_enable_waiting":
          "Telegramda obuna bo‘ling, so‘ng bu yerga qayting.",
      "telegram_alerts_enabled_success": "Telegram bildirishnomalari yoqildi",
      "telegram_alerts_enable_failed":
          "Telegram bildirishnomalarini yoqib bo‘lmadi. Keyinroq urinib ko‘ring.",
      "telegram_alerts_settings_title":
          "Telegram bildirishnomalari o‘chirilgan",
      "telegram_alerts_settings_body":
          "Telegramda @uydosh_bot ni oching va bildirishnomalarga obuna bo‘ling — xabarlar va qidiruv mosliklari shu yerda keladi.",
      "telegram_alerts_settings_button": "Telegram bildirishnomalarini yoqish",
      "telegram_alerts_settings_waiting":
          "@uydosh_bot da obuna bo‘ling, so‘ng bu yerga qayting.",
      "telegram_alerts_connected": "Telegram bildirishnomalari yoqilgan",
      "telegram_alerts_disable_button": "Bildirishnomalarni o‘chirish",
      "telegram_alerts_disabled_success":
          "Telegram bildirishnomalari o‘chirildi",
      "telegram_alerts_disable_failed":
          "Telegram bildirishnomalarini o‘chirib bo‘lmadi",
      "apple_sign_in_failed": "Apple orqali kirishda xatolik: {error}",

      // ===== PHONE AUTHENTICATION =====
      "sign_in_with_phone": "Telefon raqami orqali kirish",
      "phone_sign_in_under_construction":
          "Telefon bilan kirish hozircha tayyorlanmoqda. Hozircha Google yoki Apple dan foydalaning.",
      "sign_in_with_phone_description":
          "Raqamingizni tasdiqlash uchun 6 xonali kod yuboramiz.",
      "auth_separator_or": "yoki",
      "phone_number_example": "+998 90 123 45 67",
      "phone_send_code": "Kod yuborish",
      "phone_resend_code": "Kodni qayta yuborish",
      "phone_resend_in_seconds": "Qayta yuborish {seconds} s dan keyin",
      "phone_invalid_format":
          "Davlat kodini qo'shib to'g'ri raqam kiriting (masalan, +998 90 123 45 67).",
      "phone_code_entry_title": "6 xonali kodni kiriting",
      "phone_code_entry_description": "{phone} raqamiga yuborildi",
      "phone_code_invalid": "Kod noto'g'ri yoki muddati tugagan.",
      "phone_verify": "Tasdiqlash",
      "phone_verifying": "Tekshirilmoqda...",
      "phone_verification_failed": "Tasdiqlashda xatolik: {error}",
      "phone_too_many_requests":
          "Juda ko'p urinish. Bir necha daqiqadan so'ng qayta urinib ko'ring.",
      "phone_quota_exceeded":
          "Telefon orqali tasdiqlash vaqtincha mavjud emas. Keyinroq urinib ko'ring.",
      "change_phone_number": "Raqamni o'zgartirish",

      // ===== SHARING & CONTACT =====
      "check_out_listing_on_uydosh": "Bu e'lonni UyDosh da ko'ring!",
      "share_subject_uz": "UyDosh - Uy e'loni",
      "share_subject_ru": "UyDosh - Объявление о жилье",
      "share_subject_en": "UyDosh - Housing Listing",

      "contact_user": "Foydalanuvchi bilan bog'lanish",
      "follow": "Kuzatish",
      "following": "Kuzatilmoqda",
      "followers_count_other": "{count} kuzatuvchi",
      "following_count_other": "{count} kuzatilmoqda",
      "followers_list_title": "Kuzatuvchilar",
      "following_list_title": "Kuzatilmoqda",
      "no_followers_yet": "Hali kuzatuvchilar yo'q",
      "no_following_yet": "Hali hech kim kuzatilmagan",
      "common_connections": "Umumiy tanishlar",
      "common_connections_count": "{count}",
      "message": "Chatda yozish",
      "uydosh_chat": "UyDosh Chat",
      "admin_listing_contacts": "E'lon kontaktlari (admin)",

      // ===== STATUS & STATE =====
      "delete_listing": "E'loni o'chirish",
      "delete_listing_confirmation":
          "Bu e'loni o'chirishni xohlaysizmi? Bu amalni qaytarib bo'lmaydi.",
      "delete_listing_success": "E'lon muvaffaqiyatli o'chirildi",
      "delete_listing_error": "E'loni o'chirishda xatolik",
      "unknown": "Noma'lum",

      // ===== COMPLAINTS =====
      "create_complaint": "Shikoyat yaratish",
      "complaint_description_hint": "Tafsilotlar qo'shing (ixtiyoriy)",
      "submit_complaint": "Shikoyatni yuborish",
      "complaint_created_success": "Shikoyat muvaffaqiyatli yuborildi",
      "listing_complaints": "E'lon bo'yicha shikoyatlar",
      "listing_complaints_header": "E'lon bo'yicha shikoyatlar: {count}",
      "view_listing_complaints": "Shikoyatlarni ko'rish",
      "complaints_count_short": "{count} ta shikoyat",
      "complaints_count_short_other": "{count} ta shikoyat",
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
