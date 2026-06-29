import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/follow_service.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/chat_composer_draft_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/scam_trigger.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_shortlist_pill_button.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_group_member_profiles_sheet.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/domain/models/discussed_listing.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/models/message_translation.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/conversations_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/router/main_navigation.dart";
import "package:uy_dosh/presentation/screens/complaint/create_complaint_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/group_member_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/screens/profile/ai_premium_placeholder_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_entry_flow.dart";
import "package:uy_dosh/presentation/utils/destructive_action_flow.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_header.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_input.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_messages_skeleton.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_security_ribbon.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_safety_warning_ribbon.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/vertical_participant_avatar_stack.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/widgets/chat/listing_ref_message_bubble.dart";
import "package:uy_dosh/presentation/widgets/chat/mentioned_listings_ribbon.dart";
import "package:uy_dosh/presentation/widgets/chat/listing_share_message_bubble.dart";
import "package:uy_dosh/presentation/widgets/chat/message_bubble.dart";
import "package:uy_dosh/presentation/widgets/chat/message_grouping_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/quick_questions_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/suspicious_message_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/gemini_quota_exceeded_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/labeled_field_overlay.dart";
import "package:uy_dosh/presentation/widgets/common/listing_rating_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_alert_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_plate_text_form_field.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";

class ChatScreen extends StatefulWidget {
  /// Root [Navigator] route name for this conversation. Push with
  /// `RouteSettings(name: routeName(conversationId))` so deep links / push
  /// handling can pop back to an existing chat instead of stacking another.
  static String routeName(int conversationId) =>
      ConversationEntryFlow.chatRouteName(conversationId);

  const ChatScreen({
    required this.conversationId,
    super.key,
    this.listingId,
    this.listingTypeId,
    this.listingOwnerUserId,

    /// Backend `conversation.context_type` (`gig_request`, `gig_offer`, …).
    /// Used with [conversationParticipantId] when [listingOwnerUserId] is insufficient
    /// (e.g. task client is `participant_id` for `gig_request` chats).
    this.conversationContextType,

    /// Backend `participant_id` for this thread (see inbox / gig models).
    this.conversationParticipantId,
    this.gigRequestId,
    this.gigRequestTitle,
    this.listingTitle,

    /// When true, [GigRequestDetailScreen] for [gigRequestId] is already on
    /// the stack under this chat (e.g. opened via Contact on that screen).
    /// "View task" should pop to it instead of pushing a duplicate route.
    this.gigRequestDetailRouteBelow = false,
    this.otherUserInitials,
    this.otherUserName,
    this.otherUserId,
    this.otherUserAvatar,

    /// When set, pre-fills the composer on open (e.g. sharing a saved listing
    /// into a group chat). Takes precedence over a persisted draft.
    this.initialComposerText,

    /// When set, the chat opens to discuss this housing listing in a group
    /// thread. If a listing-share card for it already exists, the chat scrolls
    /// to and highlights that card; otherwise [listingShareToPost] is posted
    /// once on open (so the encoded payload never lands in the composer).
    this.discussListingId,
    this.listingShareToPost,
  }) : assert(conversationId > 0, "Conversation ID must be positive");
  final int conversationId;
  final int? listingId;

  /// Scopes the quick-question chip set. Call-sites that know the listing
  /// should pass this; callers without it (e.g. push deep-links) can omit and
  /// the widget falls back to the legacy chip set.
  final int? listingTypeId;

  /// Owner of [listingId]. Used to detect whether the current viewer is the
  /// listing author so quick-question chips can address the counterparty.
  /// By server convention owner == `conversation.participant_id`.
  final int? listingOwnerUserId;

  /// When set with [conversationParticipantId], refines offerer-side detection for
  /// gig threads (notably `gig_request`, where [listingOwnerUserId] is omitted).
  final String? conversationContextType;

  /// See [conversationContextType].
  final int? conversationParticipantId;

  /// Set when this chat is anchored to a gig request rather than a listing.
  /// Powers the header subtitle + the "View task" action menu entry.
  /// Mutually exclusive with [listingId] in practice — a conversation has
  /// exactly one context.
  final int? gigRequestId;

  /// Cached gig-request title plumbed by callers that already have it
  /// (inbox tile, gig request detail screen). The chat will simply omit
  /// the subtitle when this is null.
  final String? gigRequestTitle;

  /// Listing headline for the app bar when [listingId] is set (preset-aware
  /// callers pass the same string as inbox tiles).
  final String? listingTitle;

  final bool gigRequestDetailRouteBelow;

  final String? otherUserInitials;
  final String? otherUserName;
  final int? otherUserId;
  final String? otherUserAvatar;
  final String? initialComposerText;
  final int? discussListingId;
  final String? listingShareToPost;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late FocusNode _messageFocusNode;
  int? _currentUserId;
  List<Message> _messages = [];
  bool _isSendingMessage = false;

  // Mentioned-listings ribbon: server-authoritative set of listing cards posted
  // in this group chat (complete even when only a page of messages is loaded).
  List<DiscussedListing> _discussedFromServer = const [];
  bool _discussedFetchInFlight = false;

  // "Discuss in group" flow: scroll to an existing listing card or post a new
  // one exactly once after the first message load.
  int? _pendingDiscussListingId;
  String? _pendingListingShareToPost;
  bool _pendingDiscussHandled = false;
  bool _highlightNextSentShare = false;

  // Scroll-to-message + transient highlight for the focused listing card.
  int? _scrollTargetMessageId;
  final GlobalKey _scrollTargetKey = GlobalKey();
  int? _highlightedMessageId;
  Timer? _highlightTimer;

  /// When non-null, send submits an [EditMessage] for this id instead of posting.
  int? _editingMessageId;
  Message? _replyingToMessage;
  bool _hasLoadedMessagesForConversation =
      false; // Track if we've completed initial fetch (avoids loading when bloc is overwritten by RefreshConversations)
  final Set<int> _newMessageIds =
      {}; // Track which messages are new in this session
  UserProfile? _currentUserProfile; // Store the current user's profile
  // Authoritative peer avatar URL for this session. Initialised from the
  // constructor prop (what the previous screen knew), then overwritten with
  // the freshly-fetched profile so newly-uploaded avatars show up without
  // requiring the user to reopen the chat.
  String? _peerAvatarUrl;
  bool _peerProfileFetchInFlight = false;
  bool _inviteBookingInFlight = false;
  int? _peerProfileFetchedForUserId;
  List<ConversationMemberSummary> _groupParticipants = [];
  bool _groupMembersFetchInFlight = false;
  Map<int, GroupMemberCompatibilitySummary> _groupMemberCompatibility = {};
  ListingDetail? _groupListingDetail;
  bool _groupHousingContextLoaded = false;
  bool _groupChatIsOwner = false;
  PendingLandlordInvite? _pendingLandlordInvite;
  bool _pendingLandlordInviteFetchInFlight = false;
  bool _landlordInviteActionInFlight = false;
  bool _showSecurityRibbon = true;
  // Raw safety-warning state. We intentionally store the *raw* reason
  // (Gemini's English string) and the severity, then re-derive the
  // localized title + body on every build via [_titleForRiskLevel] and
  // [_localizedSafetyReason]. This way:
  //   1. Language switches re-render the ribbon in the new language
  //      instead of leaving it frozen at check-time.
  //   2. Code updates to the matcher take effect on the next build,
  //      without having to wait for a fresh safety-check call.
  bool _safetyWarningActive = false;
  String _safetyWarningRawReason = "";
  ChatSafetyWarningSeverity _safetyWarningSeverity =
      ChatSafetyWarningSeverity.medium;
  final Map<int, String> _messageRiskById = {}; // messageId -> 'medium'|'high'
  // Stores the raw (English) reason from Gemini. Localize on read via
  // [_localizedSafetyReason] so language switches reflect immediately.
  final Map<int, String> _messageSafetyReasonById = {};
  DateTime? _lastSafetyCheckAt;
  bool _safetyCheckInFlight = false;
  // Lazily populated Gemini translations for text messages from the OTHER
  // participant, keyed by message id. Filled on chat open + whenever new
  // messages arrive via refresh/push. Surviving a translation request does
  // NOT require a rebuild of the whole list because bubble widgets read
  // from this map via their props.
  final Map<int, MessageTranslation> _translationsById = {};
  final Set<int> _showOriginalMessageIds = {};
  final Set<int> _translationInFlightIds = {};
  final Set<int> _translationCompletedIds = {};

  // Per-conversation translation prefs (persisted via SessionManager). The
  // 3-dot menu lets the viewer:
  //   - flip every bubble to its original text ("Show original messages"),
  //   - request translations into a non-default language ("Translate to…").
  // Both default to off / null on first open and survive screen re-entry.
  bool _showOriginalAll = false;
  String? _targetLanguageOverride;
  bool _showRefreshSkeleton = false;
  DateTime? _refreshSkeletonStartedAt;
  Completer<void>? _refreshCompleter;
  bool _isAdmin = false;
  bool _adminDeleteBusy = false;
  bool _showScrollToBottomButton = false;
  Timer? _incomingRefreshDebounce;
  late final VoidCallback _unreadMessagesListener;
  int _lastObservedUnreadCount = 0;
  int? _lastIncomingSoundMessageId;
  ListingAiQuotaSnapshot? _listingAiQuotaRibbon;

  static const Duration _minSkeletonDuration = Duration(milliseconds: 450);
  static const String _chatTranslateAutoTarget = "";
  static const double _translateTargetSwitchHeight = 135 * 60 / 145;
  static const double _scrollToBottomShowOffset = 72;
  static const double _scrollToBottomHideOffset = 24;

  /// Reserve space so the last messages clear the stacked glass composer (blue theme).
  static const double _glassComposerEstimatedHeight = 196;

  /// Memoized output of [MessageGroupingUtils.groupMessagesAsItems] — invalidated when
  /// [messages] reference, [_currentUserId], or [_newMessageIds] meaningfully change.
  List<MessageGroupListItem>? _cachedGroupedItems;
  List<Message>? _groupedCacheMessagesRef;
  int? _groupedCacheCurrentUserId;
  int _groupedCacheNewMessageIdsFingerprint = 0;
  final GlobalKey _messagesViewportKey = GlobalKey();
  final Map<String, GlobalKey> _dateHeaderKeys = {};
  final Map<int, GlobalKey> _messageItemKeys = {};
  final Map<int, DateTime> _messageItemDates = {};
  DateTime? _stickyDateHeaderDate;
  bool _stickyDateHeaderUpdateScheduled = false;

  int _fingerprintNewMessageIds(Set<int> ids) {
    if (ids.isEmpty) return 0;
    final sorted = ids.toList()..sort();
    return Object.hashAll(sorted);
  }

  bool get _isGroupChat {
    final ctx = widget.conversationContextType?.trim().toLowerCase();
    if (ctx == "listing_group") return true;
    return widget.listingTypeId == ListingTypeIds.groupForming &&
        widget.otherUserId == null;
  }

  bool get _showGroupShortlistPill =>
      _isGroupChat &&
      widget.listingId != null &&
      _groupListingDetail?.groupContext?.canUseHousingShortlist == true;

  bool get _waitingForGroupFooterActions =>
      _isGroupChat && widget.listingId != null && !_groupHousingContextLoaded;

  double get _composerBottomReserveHeight {
    return _glassComposerEstimatedHeight +
        (_replyingToMessage == null ? 0 : 64);
  }

  void _handleMessageListScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final offsetFromBottom = (position.pixels - position.minScrollExtent)
        .clamp(0.0, position.maxScrollExtent);
    final shouldShow = _showScrollToBottomButton
        ? offsetFromBottom > _scrollToBottomHideOffset
        : offsetFromBottom > _scrollToBottomShowOffset;
    if (shouldShow == _showScrollToBottomButton) return;
    setState(() => _showScrollToBottomButton = shouldShow);
  }

  String _dateHeaderKey(DateTime date) =>
      "${date.year}-${date.month}-${date.day}";

  GlobalKey _dateHeaderGlobalKey(DateTime date) {
    return _dateHeaderKeys.putIfAbsent(_dateHeaderKey(date), GlobalKey.new);
  }

  GlobalKey _messageItemGlobalKey(Message message) {
    return _messageItemKeys.putIfAbsent(message.id, GlobalKey.new);
  }

  void _syncDateHeaderKeys(List<MessageGroupListItem> groupedItems) {
    final activeKeys = groupedItems
        .whereType<DateHeaderListItem>()
        .map((item) => _dateHeaderKey(item.date))
        .toSet();
    _dateHeaderKeys.removeWhere((key, value) => !activeKeys.contains(key));

    final activeMessageIds = <int>{};
    for (final item in groupedItems.whereType<MessageListItem>()) {
      activeMessageIds.add(item.message.id);
      _messageItemDates[item.message.id] =
          DateTime.parse(item.message.createdAt).toLocal();
    }
    _messageItemKeys
        .removeWhere((key, value) => !activeMessageIds.contains(key));
    _messageItemDates
        .removeWhere((key, value) => !activeMessageIds.contains(key));
  }

  void _scheduleStickyDateHeaderUpdate() {
    if (_stickyDateHeaderUpdateScheduled) return;
    _stickyDateHeaderUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stickyDateHeaderUpdateScheduled = false;
      if (!mounted) return;
      _syncStickyDateHeaderDate();
    });
  }

  void _syncStickyDateHeaderDate() {
    final viewportContext = _messagesViewportKey.currentContext;
    final viewportRenderObject = viewportContext?.findRenderObject();
    if (viewportRenderObject is! RenderBox) return;

    final viewportTop = viewportRenderObject.localToGlobal(Offset.zero).dy;
    final anchorY = viewportTop + _messagesListPadding(context).top;
    final nextDateFromMessages = _stickyDateFromVisibleMessages(anchorY);
    if (nextDateFromMessages != null) {
      _setStickyDateHeaderDate(nextDateFromMessages);
      return;
    }

    final nextDateFromHeaders = _stickyDateFromVisibleDateHeaders(anchorY);
    _setStickyDateHeaderDate(nextDateFromHeaders);
  }

  DateTime? _stickyDateFromVisibleMessages(double anchorY) {
    final visibleMessages = <({DateTime date, double y, double bottom})>[];

    for (final entry in _messageItemKeys.entries) {
      final messageDate = _messageItemDates[entry.key];
      final messageContext = entry.value.currentContext;
      final messageRenderObject = messageContext?.findRenderObject();
      if (messageDate == null ||
          messageRenderObject is! RenderBox ||
          !messageRenderObject.hasSize) {
        continue;
      }

      final messageTop = messageRenderObject.localToGlobal(Offset.zero).dy;
      visibleMessages.add(
        (
          date: messageDate,
          y: messageTop,
          bottom: messageTop + messageRenderObject.size.height,
        ),
      );
    }

    if (visibleMessages.isEmpty) return null;
    visibleMessages.sort((a, b) => a.y.compareTo(b.y));

    final crossingMessages = visibleMessages
        .where((message) => message.y <= anchorY && message.bottom >= anchorY);
    if (crossingMessages.isNotEmpty) return crossingMessages.last.date;

    final aboveMessages =
        visibleMessages.where((message) => message.y <= anchorY);
    if (aboveMessages.isNotEmpty) return aboveMessages.last.date;

    return visibleMessages.first.date;
  }

  DateTime? _stickyDateFromVisibleDateHeaders(double anchorY) {
    final visibleHeaders = <({DateTime date, double y})>[];

    for (final entry in _dateHeaderKeys.entries) {
      final headerContext = entry.value.currentContext;
      final headerRenderObject = headerContext?.findRenderObject();
      if (headerRenderObject is! RenderBox || !headerRenderObject.hasSize) {
        continue;
      }
      visibleHeaders.add(
        (
          date: _dateFromHeaderKey(entry.key),
          y: headerRenderObject.localToGlobal(Offset.zero).dy,
        ),
      );
    }

    if (visibleHeaders.isEmpty) return null;

    visibleHeaders.sort((a, b) => a.y.compareTo(b.y));
    final passedHeaders = visibleHeaders.where((header) => header.y <= anchorY);
    return passedHeaders.isNotEmpty
        ? passedHeaders.last.date
        : visibleHeaders.first.date;
  }

  void _setStickyDateHeaderDate(DateTime? nextDate) {
    final current = _stickyDateHeaderDate;
    if (current == null && nextDate == null) return;
    if (current != null &&
        nextDate != null &&
        _isSameLocalDate(current, nextDate)) {
      return;
    }
    setState(() => _stickyDateHeaderDate = nextDate);
  }

  DateTime _dateFromHeaderKey(String key) {
    final parts = key.split("-");
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  bool _isSameLocalDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _loadGroupParticipants() async {
    if (!_isGroupChat || _groupMembersFetchInFlight) return;
    _groupMembersFetchInFlight = true;
    try {
      final members = await getIt<IMessagingService>().getConversationMembers(
        widget.conversationId,
      );
      if (!mounted) return;
      setState(() {
        _groupParticipants =
            members.isNotEmpty ? members : _participantsFromMessages();
        _groupMemberCompatibility = _groupMemberCompatibilityForParticipants(
          _groupParticipants,
        );
      });
      unawaited(_loadGroupMemberCompatibility());
    } catch (e) {
      logger.d("❌ [ChatScreen] Error fetching group participants: $e");
      if (!mounted) return;
      final fallback = _participantsFromMessages();
      if (fallback.isNotEmpty) {
        setState(() => _groupParticipants = fallback);
      }
    } finally {
      _groupMembersFetchInFlight = false;
    }
  }

  Future<void> _loadGroupHousingContext() async {
    final listingId = widget.listingId;
    if (!_isGroupChat || listingId == null) return;
    try {
      final detail = await getIt<IListingService>().getListingDetail(listingId);
      if (!mounted) return;
      final ctx = detail.groupContext;
      final canUseShortlist = ctx?.canUseHousingShortlist == true;
      final count = canUseShortlist
          ? ctx?.groupShortlistCount ??
              await getIt<IListingGroupService>().getShortlistCount(
                groupListingId: listingId,
              )
          : null;
      if (!mounted) return;
      setState(() {
        _groupListingDetail = detail;
        _groupHousingContextLoaded = true;
        _groupChatIsOwner = ctx?.isOwner == true;
      });
      if (count != null) {
        GroupShortlistState().setShortlistCountForGroup(listingId, count);
      }
    } catch (e) {
      logger.d("❌ [ChatScreen] Error loading group housing context: $e");
      if (!mounted) return;
      setState(() => _groupHousingContextLoaded = true);
    }
  }

  Future<void> _loadPendingLandlordInvite() async {
    if (_isGroupChat ||
        widget.listingId == null ||
        _pendingLandlordInviteFetchInFlight) {
      return;
    }
    _pendingLandlordInviteFetchInFlight = true;
    try {
      final invite = await getIt<IListingGroupService>()
          .getPendingLandlordInviteForConversation(
        conversationId: widget.conversationId,
      );
      if (!mounted) return;
      setState(() => _pendingLandlordInvite = invite);
    } catch (e) {
      logger.d("❌ [ChatScreen] Error loading landlord invite: $e");
    } finally {
      _pendingLandlordInviteFetchInFlight = false;
    }
  }

  /// Pulls the authoritative set of listing cards posted in this group chat so
  /// the quick-jump ribbon is complete regardless of how many messages are
  /// loaded. Best-effort: failures just leave the ribbon to message-derived
  /// chips (see [_mentionedListings]).
  Future<void> _loadDiscussedListings() async {
    if (!_isGroupChat || _discussedFetchInFlight) return;
    _discussedFetchInFlight = true;
    try {
      final items = await getIt<IMessagingService>().getDiscussedListings(
        widget.conversationId,
      );
      if (!mounted) return;
      setState(() => _discussedFromServer = items);
    } catch (e) {
      logger.d("❌ [ChatScreen] Error loading discussed listings: $e");
    } finally {
      _discussedFetchInFlight = false;
    }
  }

  /// Merges the server-authoritative card list with any share cards present in
  /// the loaded window (so freshly posted/received cards appear immediately),
  /// de-duplicated by listing and ordered by the original share message id.
  ///
  /// Message ids are the stable timeline order. Created timestamps can be equal
  /// or arrive skewed, which previously made option badges appear as #2, #1, ...
  List<({int listingId, String title})> _mentionedListings() {
    final byListingId = <int,
        ({int listingId, String title, int messageId, int fallbackOrder})>{};
    var fallbackOrder = 0;

    for (final d in _discussedFromServer) {
      byListingId[d.listingId] = (
        listingId: d.listingId,
        title: d.title,
        messageId: d.messageId,
        fallbackOrder: fallbackOrder++,
      );
    }

    for (final m in _messages) {
      if (m.isDeleted == true) continue;
      final payload = ListingShareMessageCodec.parse(m.content);
      if (payload == null) continue;
      final existing = byListingId[payload.listingId];
      if (existing == null ||
          existing.messageId <= 0 ||
          (m.id > 0 && m.id < existing.messageId)) {
        byListingId[payload.listingId] = (
          listingId: payload.listingId,
          title: payload.title,
          messageId: m.id,
          fallbackOrder: existing?.fallbackOrder ?? fallbackOrder++,
        );
      }
    }

    final result = byListingId.values.toList()
      ..sort((a, b) {
        final aMessageId = a.messageId;
        final bMessageId = b.messageId;
        if (aMessageId > 0 && bMessageId > 0) {
          return aMessageId.compareTo(bMessageId);
        }
        if (aMessageId > 0) return -1;
        if (bMessageId > 0) return 1;
        return a.fallbackOrder.compareTo(b.fallbackOrder);
      });

    return [
      for (final item in result) (listingId: item.listingId, title: item.title),
    ];
  }

  int? _listingShareOptionNumber(ListingShareMessagePayload payload) {
    final index = _mentionedListings().indexWhere(
      (item) => item.listingId == payload.listingId,
    );
    if (index < 0) return null;
    return index + 1;
  }

  Widget _buildGroupShortlistFooterPill(BuildContext context) {
    final listingId = widget.listingId;
    if (listingId == null) return const SizedBox.shrink();

    return GroupShortlistPillButton(
      groupListingId: listingId,
      isOwner: _groupChatIsOwner,
      groupListingDetail: _groupListingDetail,
    );
  }

  Widget _buildGroupParticipantsFooterPill(BuildContext context) {
    final participants = _groupParticipants;
    final count = participants.length;
    final pendingJoinRequestCount =
        _groupListingDetail?.groupContext?.pendingJoinRequestCount ?? 0;
    final label = count > 0
        ? "${L10n.get("group_floating_participants_label")} $count"
        : L10n.get("group_floating_participants_label");

    return _GroupParticipantsFooterPill(
      participants: participants,
      currentUserId: _currentUserId,
      semanticsLabel: label,
      showDot: pendingJoinRequestCount > 0,
      dotTrigger: pendingJoinRequestCount,
      onTap: participants.isEmpty
          ? null
          : () => unawaited(_openGroupParticipantsSheet()),
    );
  }

  Widget _groupChatFooterRibbon({required bool blendWithGlassBackdrop}) {
    final themeState = ThemeState();
    final stripDecoration = blendWithGlassBackdrop
        ? const BoxDecoration()
        : BoxDecoration(
            color: themeState.chatInputBarBackgroundColor,
            border: Border(
              bottom: BorderSide(color: themeState.borderColor, width: 0.5),
            ),
          );

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.viewPaddingOf(context).bottom + 12,
      ),
      decoration: stripDecoration,
      child: _waitingForGroupFooterActions
          ? const SizedBox(height: 38, width: double.infinity)
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_showGroupShortlistPill)
                    _buildGroupShortlistFooterPill(context),
                  if (_showGroupShortlistPill) const SizedBox(width: 10),
                  _buildGroupParticipantsFooterPill(context),
                ],
              ),
            ),
    );
  }

  Widget _chatComposerColumn({required bool blendWithGlassBackdrop}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _chatComposerWithListener(
          blendWithGlassBackdrop: blendWithGlassBackdrop,
        ),
        if (_isGroupChat)
          _groupChatFooterRibbon(blendWithGlassBackdrop: blendWithGlassBackdrop)
        else
          QuickQuestionsWidget(
            onQuestionTap: _onQuestionTap,
            conversationContextType: widget.conversationContextType,
            listingTypeId: widget.listingTypeId,
            isViewerServiceOfferer: _isViewerServiceOfferer,
            isViewerListingAuthor: _isViewerListingOwner,
            blendWithGlassBackdrop: blendWithGlassBackdrop,
          ),
      ],
    );
  }

  Widget _chatComposerSection({required bool blendWithGlassBackdrop}) {
    return _chatComposerColumn(
      blendWithGlassBackdrop: blendWithGlassBackdrop,
    );
  }

  /// Best-effort roster when the members endpoint is unavailable or empty.
  List<ConversationMemberSummary> _participantsFromMessages() {
    final byId = <int, ConversationMemberSummary>{};
    for (final message in _messages) {
      if (byId.containsKey(message.senderId)) continue;
      final sender = message.sender;
      final profile = sender?.profile;
      byId[message.senderId] = ConversationMemberSummary(
        userId: message.senderId,
        name: profile?.name?.trim().isNotEmpty == true
            ? profile!.name!.trim()
            : (sender?.email ?? "User"),
        avatarUrl: profile?.avatarUrl,
      );
    }
    final me = _currentUserId;
    final myProfile = _currentUserProfile;
    if (me != null && myProfile != null) {
      byId[me] = ConversationMemberSummary(
        userId: me,
        name: myProfile.name?.trim().isNotEmpty == true
            ? myProfile.name!.trim()
            : "User",
        avatarUrl: myProfile.avatarUrl,
      );
    }
    return byId.values.toList();
  }

  void _refreshGroupParticipantsFromMessages() {
    if (!_isGroupChat) return;
    final derived = _participantsFromMessages();
    if (derived.isEmpty) return;
    if (_groupParticipants.isNotEmpty) return;
    setState(() => _groupParticipants = derived);
  }

  Map<int, GroupMemberCompatibilitySummary>
      _groupMemberCompatibilityForParticipants(
    List<ConversationMemberSummary> participants,
  ) {
    final participantIds = participants.map((member) => member.userId).toSet();
    return Map<int, GroupMemberCompatibilitySummary>.fromEntries(
      _groupMemberCompatibility.entries.where(
        (entry) => participantIds.contains(entry.key),
      ),
    );
  }

  Future<Map<int, GroupMemberCompatibilitySummary>>
      _loadGroupMemberCompatibility() async {
    final participants = List<ConversationMemberSummary>.of(_groupParticipants);
    final currentUserId = _currentUserId;
    if (!_isGroupChat || participants.isEmpty || currentUserId == null) {
      return _groupMemberCompatibility;
    }

    final targetIds = participants
        .map((member) => member.userId)
        .where((userId) => userId != currentUserId)
        .toSet();
    final missingIds = targetIds
        .where((userId) => !_groupMemberCompatibility.containsKey(userId))
        .toList(growable: false);
    if (missingIds.isEmpty) {
      return _groupMemberCompatibilityForParticipants(participants);
    }

    try {
      final profileService = getIt<IUserProfileService>();
      final currentProfile =
          _currentUserProfile ?? await profileService.getCurrentUserProfile();
      final entries = await Future.wait(
        missingIds.map((userId) async {
          try {
            final memberProfile = await profileService.getUserProfile(userId);
            return MapEntry(
              userId,
              GroupMemberCompatibilityHelper.summarize(
                currentProfile,
                memberProfile,
              ),
            );
          } catch (e) {
            logger.d(
              "❌ [ChatScreen] Error loading member compatibility for $userId: $e",
            );
            return MapEntry(userId, GroupMemberCompatibilitySummary.empty);
          }
        }),
      );
      if (!mounted) return _groupMemberCompatibility;

      setState(() {
        _currentUserProfile ??= currentProfile;
        _groupMemberCompatibility = {
          ..._groupMemberCompatibilityForParticipants(participants),
          for (final entry in entries) entry.key: entry.value,
        };
      });
    } catch (e) {
      logger.d("❌ [ChatScreen] Error loading group compatibility: $e");
    }

    return _groupMemberCompatibilityForParticipants(participants);
  }

  bool _isLandlordMessage(Message message) {
    if (!_isGroupChat) return false;
    for (final participant in _groupParticipants) {
      if (participant.userId != message.senderId) continue;
      return participant.role?.trim().toLowerCase() == "landlord_guest";
    }
    return false;
  }

  List<MessageGroupListItem> _groupedItemsFor(List<Message> messages) {
    final fp = _fingerprintNewMessageIds(_newMessageIds);
    if (_cachedGroupedItems != null &&
        identical(messages, _groupedCacheMessagesRef) &&
        _currentUserId == _groupedCacheCurrentUserId &&
        fp == _groupedCacheNewMessageIdsFingerprint) {
      return _cachedGroupedItems!;
    }
    final items = MessageGroupingUtils.groupMessagesAsItems(
      messages,
      _currentUserId,
      _newMessageIds,
    );
    _groupedCacheMessagesRef = messages;
    _groupedCacheCurrentUserId = _currentUserId;
    _groupedCacheNewMessageIdsFingerprint = fp;
    _cachedGroupedItems = items;
    return items;
  }

  /// Web/desktop-style chat: Enter sends, Shift+Enter still inserts a newline.
  KeyEventResult _messageComposerOnKeyEvent(FocusNode node, KeyEvent event) {
    if (!kIsWeb) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.enter) {
      return KeyEventResult.ignored;
    }
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    if (_isSendingMessage) return KeyEventResult.handled;
    if (_messageController.text.trim().isEmpty) return KeyEventResult.handled;
    HapticFeedbackUtils.impact();
    _sendMessage();
    return KeyEventResult.handled;
  }

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "chat");
    getIt<AppAnalyticsService>().logChatOpened(
      conversationId: widget.conversationId,
      listingId: widget.listingId,
    );
    _messageController = TextEditingController();
    _messageController.addListener(_syncComposerDraft);
    unawaited(_restoreComposerDraft());
    _scrollController = ScrollController();
    _scrollController.addListener(_handleMessageListScroll);
    _messageFocusNode = FocusNode(onKeyEvent: _messageComposerOnKeyEvent);
    _peerAvatarUrl = widget.otherUserAvatar;
    _pendingDiscussListingId = widget.discussListingId;
    _pendingListingShareToPost = widget.listingShareToPost;

    // Load translation prefs FIRST so the very first /translate-unseen call
    // already carries the persisted [_targetLanguageOverride]. Otherwise we'd
    // briefly translate into the user's profile language and then re-fetch
    // in the override language on the next refresh tick.
    _loadTranslationPrefs().whenComplete(() {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeChat());
    });
    _loadSecurityRibbonState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadChatAiQuotaRibbon());
    });

    _lastObservedUnreadCount = UnreadMessagesState().unreadCount;
    _unreadMessagesListener = _onUnreadMessagesChanged;
    UnreadMessagesState().addListener(_unreadMessagesListener);

    // Mark this conversation as "active" so push handler can avoid playing
    // sound before the UI updates; ChatScreen will play it post-frame instead.
    UnreadMessagesState().setActiveConversationId(widget.conversationId);
  }

  void _syncComposerDraft() {
    if (_editingMessageId != null) return;
    ChatComposerDraftState().setDraft(
      widget.conversationId,
      _messageController.text,
    );
  }

  Future<void> _restoreComposerDraft() async {
    await ChatComposerDraftState().ensureLoaded();
    if (!mounted || _editingMessageId != null) return;

    final initial = widget.initialComposerText?.trim();
    if (initial != null && initial.isNotEmpty) {
      _messageController.value = TextEditingValue(
        text: initial,
        selection: TextSelection.collapsed(offset: initial.length),
      );
      ChatComposerDraftState().setDraft(widget.conversationId, initial);
      return;
    }

    final draft = ChatComposerDraftState().draftFor(widget.conversationId);
    if (draft == null) return;
    if (_messageController.text.isNotEmpty) return;
    _messageController.value = TextEditingValue(
      text: draft,
      selection: TextSelection.collapsed(offset: draft.length),
    );
  }

  void _persistComposerDraftIfNeeded() {
    if (_editingMessageId != null) return;
    ChatComposerDraftState().setDraft(
      widget.conversationId,
      _messageController.text,
    );
  }

  @override
  void dispose() {
    if (UnreadMessagesState().activeConversationId == widget.conversationId) {
      UnreadMessagesState().setActiveConversationId(null);
    }
    UnreadMessagesState().removeListener(_unreadMessagesListener);
    _incomingRefreshDebounce?.cancel();
    _highlightTimer?.cancel();
    _messageController.removeListener(_syncComposerDraft);
    _persistComposerDraftIfNeeded();
    _messageController.dispose();
    _scrollController.removeListener(_handleMessageListScroll);
    _scrollController.dispose();
    _messageFocusNode.dispose();
    // Surface any achievement that was unlocked while the user was inside
    // this chat (e.g. ice breaker on first sent message). We hold it back
    // so the unlock sheet doesn't cover the chat the user is still using.
    AchievementUnlockState().flushDeferredAchievement();
    super.dispose();
  }

  Future<void> _loadChatAiQuotaRibbon() async {
    final q = await getIt<GeminiService>().fetchListingAiQuota();
    if (!mounted) {
      return;
    }
    setState(() => _listingAiQuotaRibbon = q);
  }

  void _onUnreadMessagesChanged() {
    final current = UnreadMessagesState().unreadCount;
    final previous = _lastObservedUnreadCount;
    _lastObservedUnreadCount = current;

    if (!mounted) return;
    // Only if this chat screen is the visible (top) route.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    // Only refresh for pushes targeting THIS conversation.
    final incomingConversationId =
        UnreadMessagesState().lastIncomingConversationId;
    if (incomingConversationId != widget.conversationId) return;
    // Ignore non-changes (extra safety).
    if (current == previous) return;

    _incomingRefreshDebounce?.cancel();
    _incomingRefreshDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      context.read<MessagingBloc>().add(
            RefreshMessages(conversationId: widget.conversationId),
          );
    });
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;
    try {
      // Get current user ID
      _currentUserId = await SessionManager.getUserId();
      final role = await SessionManager.getUserRole();
      final isAdmin = role == "admin";

      // Fetch current user profile and messages using shared blocs
      context.read<CurrentUserProfileBloc>().add(
            const CurrentUserProfileEvent.fetchProfile(),
          );
      context.read<MessagingBloc>().add(
            FetchMessages(conversationId: widget.conversationId),
          );
      if (!mounted) return;
      setState(() => _isAdmin = isAdmin);
      if (_isGroupChat) {
        unawaited(_loadGroupParticipants());
        unawaited(_loadGroupHousingContext());
        unawaited(_loadDiscussedListings());
      } else {
        _refreshPeerAvatarIfPossible();
        unawaited(_loadPendingLandlordInvite());
      }
    } catch (e) {
      logger.d("❌ [ChatScreen] Error initializing chat: $e");
    }
  }

  /// Lazily pulls the peer's profile so the header / bubbles show the most
  /// recent avatar (and name) instead of a potentially stale value handed
  /// down by the calling screen. Safe to call multiple times — dedupes via
  /// [_peerProfileFetchInFlight] / [_peerProfileFetchedForUserId].
  Future<void> _refreshPeerAvatarIfPossible() async {
    final peerId = widget.otherUserId ?? _getOtherUserIdFromMessages();
    if (peerId == null) return;
    if (_peerProfileFetchInFlight) return;
    if (_peerProfileFetchedForUserId == peerId) return;

    _peerProfileFetchInFlight = true;
    try {
      final profile = await getIt<IUserProfileService>().getUserProfile(peerId);
      if (!mounted) return;
      _peerProfileFetchedForUserId = peerId;
      final fetchedAvatar = profile.avatarUrl?.trim();
      if (fetchedAvatar == null || fetchedAvatar.isEmpty) return;
      if (fetchedAvatar == _peerAvatarUrl) return;
      setState(() {
        _peerAvatarUrl = fetchedAvatar;
      });
    } catch (e) {
      logger.d("❌ [ChatScreen] Error fetching peer profile: $e");
    } finally {
      _peerProfileFetchInFlight = false;
    }
  }

  void _applyMessagesAndMarkNewOnes(List<Message> nextMessages) {
    final hadAny = _messages.isNotEmpty;
    final prevIds = hadAny ? _messages.map((m) => m.id).toSet() : const <int>{};
    var hasNewIncoming = false;
    int? newestIncomingId;

    // Mark IDs that newly appeared since last render. This preserves the
    // existing "new message" animation even when we refresh from the server.
    // Skip marking on initial load so we don't animate the full history.
    if (_hasLoadedMessagesForConversation && prevIds.isNotEmpty) {
      for (final m in nextMessages) {
        if (!prevIds.contains(m.id)) {
          _newMessageIds.add(m.id);
          if (_currentUserId != null && m.senderId != _currentUserId) {
            hasNewIncoming = true;
            newestIncomingId = m.id;
          }
        }
      }
    }

    _messages = nextMessages;
    _hasLoadedMessagesForConversation = true;
    _refreshGroupParticipantsFromMessages();

    // Play incoming sound only AFTER the UI has a chance to render the new bubble.
    // Also dedupe if multiple refreshes return the same latest message.
    if (hasNewIncoming &&
        newestIncomingId != null &&
        newestIncomingId != _lastIncomingSoundMessageId) {
      _lastIncomingSoundMessageId = newestIncomingId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        SoundService().playIncomingMessage();
      });
    }

    // Kick off translation for any un-translated text messages from the
    // other participant. Runs lazily (post-frame) so it never blocks the
    // first paint of the chat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestMissingTranslations();
    });
  }

  /// Collects text messages from the other participant that we don't yet
  /// have a translation for and asks the server to fill them in. Server
  /// returns a mix of cached + freshly generated translations so calling
  /// this aggressively (open, refresh, websocket) stays cheap when the
  /// cache is warm.
  Future<void> _requestMissingTranslations() async {
    if (_currentUserId == null) return;
    // Auto mode (no override) only translates messages from the OTHER
    // participant — there's no point translating the viewer's own text into
    // their own language. When the viewer explicitly picks "Translate to…",
    // include their messages too: the user said "translate this chat", so
    // showing a half-translated transcript would feel broken.
    final translateOwnMessages = _targetLanguageOverride != null;
    final candidateIds = <int>[];
    for (final m in _messages) {
      if (m.messageType != "text") continue;
      if (!translateOwnMessages && m.senderId == _currentUserId) continue;
      if ((m.isDeleted ?? false)) continue;
      // Encoded listing cards / anchors are rendered from their payload, not
      // their raw text — never spend a translation call on the JSON blob.
      if (m.content.startsWith(listingShareMessagePrefix)) continue;
      if (m.content.startsWith(listingRefMessagePrefix)) continue;
      if (_translationsById.containsKey(m.id)) continue;
      if (_translationInFlightIds.contains(m.id)) continue;
      if (_translationCompletedIds.contains(m.id)) continue;
      candidateIds.add(m.id);
    }
    if (candidateIds.isEmpty) return;
    // Server caps at 50; pick the most recent page worth first so the
    // messages currently on-screen translate first.
    final idsToRequest = candidateIds.length > 50
        ? candidateIds.sublist(candidateIds.length - 50)
        : candidateIds;
    _translationInFlightIds.addAll(idsToRequest);
    // Trigger a rebuild immediately so bubbles can show the "translating"
    // indicator *before* the translated text arrives and swaps in.
    if (mounted) setState(() {});

    try {
      final service = getIt<IMessagingService>();
      final resp = await service.translateUnseenMessages(
        conversationId: widget.conversationId,
        messageIds: idsToRequest,
        targetLanguage: _targetLanguageOverride,
      );
      if (!mounted) return;
      final data = resp["data"];
      if (data is! Map) return;
      final target = data["target_language_code"];
      final translations = data["translations"];
      if (target is! String || translations is! List) return;
      var changed = false;
      final returnedIds = <int>{};
      for (final raw in translations) {
        if (raw is! Map) continue;
        final id = raw["message_id"];
        final resolvedId = id is int ? id : int.tryParse("$id");
        if (resolvedId == null) continue;
        final translation = MessageTranslation.fromResponseItem(
          raw.cast<String, dynamic>(),
          target,
        );
        if (translation == null) continue;
        _translationsById[resolvedId] = translation;
        returnedIds.add(resolvedId);
        changed = true;
      }
      // Mark ids we requested but didn't get back as "completed". The server
      // intentionally omits same-language "translations" (where translated ==
      // original) so the client doesn't draw a misleading footer; without this
      // we'd repeatedly request those ids and never finish "Translate to…".
      for (final id in idsToRequest) {
        if (!returnedIds.contains(id)) {
          _translationCompletedIds.add(id);
        }
      }
      if (changed) setState(() {});
    } on ChatTranslateQuotaExceededException catch (_) {
      if (!mounted) {
        return;
      }
      unawaited(GeminiQuotaExceededSheet.show(context));
      unawaited(_loadChatAiQuotaRibbon());
    } catch (e) {
      logger.d("💬 [ChatScreen] Translation request failed: $e");
    } finally {
      _translationInFlightIds.removeAll(idsToRequest);
      // Ensure we remove any per-bubble loaders even when the server returns
      // no translation rows (e.g. same-language content) and `changed==false`.
      if (mounted) setState(() {});
    }

    // In explicit override mode, keep translating progressively in the
    // background until the currently-loaded transcript is done.
    if (!mounted || _targetLanguageOverride == null) return;
    var hasMore = false;
    for (final m in _messages) {
      if (m.messageType != "text") continue;
      if ((m.isDeleted ?? false)) continue;
      if (_translationsById.containsKey(m.id)) continue;
      if (_translationInFlightIds.contains(m.id)) continue;
      if (_translationCompletedIds.contains(m.id)) continue;
      hasMore = true;
      break;
    }
    if (hasMore) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        _requestMissingTranslations();
      });
    }
  }

  Future<void> _loadSecurityRibbonState() async {
    try {
      final dismissed = await SessionManager.isChatSecurityRibbonDismissed();
      setStateIfMounted(() => _showSecurityRibbon = !dismissed);
    } catch (_) {
      // If prefs fail, keep ribbon visible.
    }
  }

  Future<void> _dismissSecurityRibbon() async {
    HapticFeedbackUtils.impact();
    if (mounted) setState(() => _showSecurityRibbon = false);
    try {
      await SessionManager.dismissChatSecurityRibbon();
    } catch (_) {
      // Ignore.
    }
  }

  /// Pulls the per-conversation translation prefs from local storage at chat
  /// open. Failures fall back to defaults so a corrupt prefs entry can never
  /// break chat rendering.
  Future<void> _loadTranslationPrefs() async {
    try {
      final results = await Future.wait([
        SessionManager.getChatShowOriginal(widget.conversationId),
        SessionManager.getChatTranslationTarget(widget.conversationId),
      ]);
      setStateIfMounted(() {
        _showOriginalAll = results[0] as bool;
        _targetLanguageOverride = results[1] as String?;
      });
    } catch (_) {
      // Defaults are already correct.
    }
  }

  /// Toggles the "Show original messages" mode for this conversation. When ON
  /// every bubble that has a translation falls back to rendering the original
  /// text. The per-bubble translation toggle still works as an exception.
  Future<void> _toggleShowOriginalAll() async {
    HapticFeedbackUtils.impact();
    final next = !_showOriginalAll;
    setState(() {
      _showOriginalAll = next;
      // Clear per-message exceptions so the new global default is what the
      // user actually sees — otherwise a previously-flipped bubble would be
      // confusingly inverted relative to the new mode.
      _showOriginalMessageIds.clear();
    });
    try {
      await SessionManager.setChatShowOriginal(widget.conversationId, next);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  /// Switches the per-conversation target language. Pass `null` to clear the
  /// override and fall back to the user's profile language. Drops cached
  /// translations + in-flight markers so all visible messages re-fetch in the
  /// new language on the next refresh tick.
  Future<void> _setTargetLanguageOverride(String? language) async {
    HapticFeedbackUtils.impact();
    setState(() {
      _targetLanguageOverride = language;
      _translationsById.clear();
      _translationInFlightIds.clear();
      _translationCompletedIds.clear();
      // Per-message overrides are about original-vs-translation, not language,
      // so leaving them alone is fine here.
    });
    try {
      await SessionManager.setChatTranslationTarget(
        widget.conversationId,
        language,
      );
    } catch (_) {
      // Best-effort persistence.
    }
    // Kick off a re-fetch so users see translations in the new language
    // without having to scroll/refresh manually.
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestMissingTranslations();
    });
  }

  /// Bottom-sheet language picker for "Translate to…". Returns the chosen
  /// language code, the empty string for "Auto", or `null` when the user
  /// dismissed the sheet without picking. We treat empty-string and null
  /// distinctly so dismiss is a no-op while explicit Auto clears the override.
  Future<void> _openTranslateLanguagePicker() async {
    final picked = await showAppBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      cardColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    L10n.get("chat_translate_picker_title"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      leadingDistribution: TextLeadingDistribution.even,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ListenableBuilder(
                  listenable: ThemeState(),
                  builder: (context, _) {
                    final themeState = ThemeState();
                    return NeumorphicSegmentedSwitch<String>(
                      liquidGlass: themeState.usesLiquidGlassChrome,
                      forceGlassPlate: true,
                      height: _translateTargetSwitchHeight,
                      value:
                          _targetLanguageOverride ?? _chatTranslateAutoTarget,
                      onChanged: (next) => Navigator.of(sheetContext).pop(next),
                      entries: [
                        SegmentedSwitchEntry(
                          value: _chatTranslateAutoTarget,
                          label:
                              "${languageFlagForCode(_chatTranslateAutoTarget)} "
                              "${L10n.get("chat_translate_picker_auto")}",
                        ),
                        SegmentedSwitchEntry(
                          value: "uz",
                          label: "${languageFlagForCode("uz")} UZ",
                        ),
                        SegmentedSwitchEntry(
                          value: "ru",
                          label: "${languageFlagForCode("ru")} RU",
                        ),
                        SegmentedSwitchEntry(
                          value: "en",
                          label: "${languageFlagForCode("en")} EN",
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || picked == null) return;
    // Empty string === explicit "Auto", which clears the override.
    await _setTargetLanguageOverride(picked.isEmpty ? null : picked);
  }

  String _localizedSafetyReason(String reason) {
    final normalized = reason.trim();
    final lower = normalized.toLowerCase();

    // Backend can return English "reason" strings. Map known reasons to localized text.
    if (lower.contains("deposit") && lower.contains("reserve")) {
      return L10n.get("chat_safety_reason_deposit_to_reserve_room");
    }

    if (lower.contains("suspicious") && lower.contains("link")) {
      return L10n.get("chat_safety_reason_suspicious_link");
    }

    if (lower.contains("off-platform") ||
        lower.contains("off platform") ||
        lower.contains("move the conversation") ||
        (lower.contains("telegram") || lower.contains("whatsapp"))) {
      return L10n.get("chat_safety_reason_off_platform");
    }

    if (lower.contains("otp") ||
        lower.contains("verification") ||
        (lower.contains("code") && lower.contains("sms"))) {
      return L10n.get("chat_safety_reason_otp_code");
    }

    if (lower.contains("prepay") ||
        lower.contains("advance") ||
        lower.contains("deposit") ||
        lower.contains("card") ||
        lower.contains("iban") ||
        lower.contains("swift") ||
        lower.contains("crypto") ||
        lower.contains("wallet") ||
        // Phishing-style reasons where the peer asks for the *viewer's*
        // bank info (Gemini phrases this as "bank details", "routing
        // number", "account number", "bank account"). Same localized
        // bucket as outbound payment requests since both are
        // payment-credential scams.
        lower.contains("bank") ||
        lower.contains("routing") ||
        lower.contains("account number") ||
        lower.contains("phishing")) {
      return L10n.get("chat_safety_reason_payment_request");
    }

    return normalized;
  }

  Future<void> _maybeRunSafetyCheck({required String triggerText}) async {
    if (_safetyCheckInFlight) return;

    // debounce / rate-limit: at most once per 15 seconds
    final now = DateTime.now();
    if (_lastSafetyCheckAt != null &&
        now.difference(_lastSafetyCheckAt!) < const Duration(seconds: 15)) {
      return;
    }

    if (!ScamTrigger.matches(triggerText)) return;
    _lastSafetyCheckAt = now;
    _safetyCheckInFlight = true;

    try {
      final service = getIt<IMessagingService>();
      final resp = await service.safetyCheckConversation(
        conversationId: widget.conversationId,
        limit: 8,
      );

      final data = resp["data"];
      if (data is Map) {
        final risk = (data["risk_level"] as String?)?.toLowerCase();
        final reason = data["reason"] as String?;
        final evidence = data["evidence_message_ids"];

        if ((risk == "medium" || risk == "high") && evidence is List) {
          final ids = evidence
              .map((e) => e is int ? e : int.tryParse("$e"))
              .whereType<int>();
          if (mounted) {
            setState(() {
              for (final id in ids) {
                _messageRiskById[id] = risk!;
                if (reason != null && reason.trim().isNotEmpty) {
                  // Store raw; localize at render time so language
                  // switches and matcher updates take effect.
                  _messageSafetyReasonById[id] = reason.trim();
                }
              }
            });
          }
        }
        if (risk == "medium" || risk == "high") {
          setStateIfMounted(() {
            _safetyWarningActive = true;
            _safetyWarningSeverity = risk == "high"
                ? ChatSafetyWarningSeverity.high
                : ChatSafetyWarningSeverity.medium;
            _safetyWarningRawReason =
                (reason != null && reason.trim().isNotEmpty)
                    ? reason.trim()
                    : "";
          });
        }
      }
    } catch (_) {
      // Ignore safety check failures (non-blocking).
    } finally {
      _safetyCheckInFlight = false;
    }
  }

  void _dismissSafetyWarning() {
    setState(() {
      _safetyWarningActive = false;
      _safetyWarningRawReason = "";
      _safetyWarningSeverity = ChatSafetyWarningSeverity.medium;
    });
  }

  /// Resolves the ribbon body string for the current locale based on the
  /// raw reason stashed by [_maybeRunSafetyCheck]. Empty raw reason →
  /// generic localized fallback so the ribbon never goes blank.
  String _resolvedSafetyWarningBody() {
    if (_safetyWarningRawReason.isEmpty) {
      return L10n.get("chat_safety_warning_fallback");
    }
    return _localizedSafetyReason(_safetyWarningRawReason);
  }

  String _titleForRiskLevel(String? riskLevel) {
    final rl = (riskLevel ?? "").toLowerCase();
    if (rl == "high") return L10n.get("chat_safety_warning_title_high");
    return L10n.get("chat_safety_warning_title_medium");
  }

  Future<void> _openSuspiciousMessageSheet({
    required Message message,
    required String riskLevel,
  }) async {
    final raw = _messageSafetyReasonById[message.id];
    final reason = (raw == null || raw.isEmpty)
        ? L10n.get("chat_safety_warning_fallback")
        : _localizedSafetyReason(raw);

    await SuspiciousMessageBottomSheet.show(
      context,
      title: _titleForRiskLevel(riskLevel),
      reasons: [reason],
      onCopyPressed: () async {
        await Clipboard.setData(ClipboardData(text: message.content));
        if (!mounted) return;
        ToastTheme.showSuccess(
          context,
          message: L10n.get("chat_safety_sheet_copied"),
        );
      },
      onReportPressed: widget.listingId == null ? null : _createComplaint,
    );
  }

  String? _chatHeaderSubtitle() {
    final gig = widget.gigRequestTitle?.trim();
    if (gig != null && gig.isNotEmpty) return gig;
    final listing = widget.listingTitle?.trim();
    if (widget.listingId != null && listing != null && listing.isNotEmpty) {
      return listing;
    }
    return null;
  }

  String _getPeerDisplayName(BuildContext context) {
    if (_isGroupChat) {
      return _groupHeaderTitle();
    }
    final name = widget.otherUserName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return L10n.get("chat");
  }

  String _groupHeaderTitle() {
    final names = _groupParticipants
        .map((p) => StringUtils.splitFullName(p.name.trim()).$1)
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) {
      return L10n.get("chat");
    }
    if (names.length <= 3) {
      return names.join(", ");
    }
    return "${names.take(2).join(", ")} +${names.length - 2}";
  }

  EdgeInsets _messagesListPadding(BuildContext context) {
    const base = EdgeInsets.all(16);
    if (!ThemeState().isBlueTheme) return base;
    final extra =
        _composerBottomReserveHeight + MediaQuery.viewPaddingOf(context).bottom;
    return base.copyWith(bottom: base.bottom + extra);
  }

  Widget _chatComposerWithListener({required bool blendWithGlassBackdrop}) {
    return BlocListener<MessagingBloc, MessagingState>(
      listener: (context, state) {
        if (!mounted) return;
        state.when(
          initial: () {},
          loading: () {},
          conversationsLoaded: (conversations, hasMore, currentPage) {},
          conversationsCleared: () {},
          messagesLoaded: (messages, hasMore, currentPage, conversationId) {},
          conversationCreated: (conversation) {},
          messageSent: (message) {
            setState(() {
              _isSendingMessage = false;
            });
            HapticFeedbackUtils.impact();
          },
          messageEdited: (message) {
            setState(() {
              _isSendingMessage = false;
              if (_editingMessageId == message.id) {
                _messageController.clear();
                _editingMessageId = null;
              }
            });
            unawaited(_restoreComposerDraft());
          },
          messagesMarkedAsRead: (conversationId, markedCount) {},
          error: (message) {
            setState(() {
              _isSendingMessage = false;
            });
            if (message.contains("USER_BLOCKED")) return;
            if (message.contains("LISTING_ALREADY_DISCUSSED")) {
              ToastTheme.showInfo(
                context,
                message: L10n.get("group_shortlist_already_in_discussion"),
              );
              return;
            }
            ToastTheme.showError(context, message: message);
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToMessage != null)
            _ComposerReplyPreview(
              senderName: _messageSenderDisplayName(_replyingToMessage!),
              preview: _messagePreviewText(_replyingToMessage!),
              avatarUrl: _messageSenderAvatarUrl(_replyingToMessage!),
              initials: _messageSenderInitials(_replyingToMessage!),
              isCurrentUser: _replyingToMessage!.senderId == _currentUserId,
              blendWithGlassBackdrop: blendWithGlassBackdrop,
              onCancel: _clearReplyMode,
            ),
          ChatMessageInput(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSend: _sendMessage,
            isSendingMessage: _isSendingMessage,
            blendWithGlassBackdrop: blendWithGlassBackdrop,
            isEditingExistingMessage: _editingMessageId != null,
          ),
        ],
      ),
    );
  }

  Widget _blueGlassComposerPanel() {
    const topRadius = BorderRadius.vertical(top: Radius.circular(20));
    final enableGlass = LiquidGlassRendering.effectsEnabled(context);
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: topRadius,
        color: BlueThemeColors.background.withValues(alpha: 0.44),
      ),
      child: _chatComposerColumn(blendWithGlassBackdrop: enableGlass),
    );

    return ClipRRect(
      borderRadius: topRadius,
      child: LiquidGlassRendering.backdropBlur(
        enabled: enableGlass,
        sigma: LiquidGlassRendering.switchGlassBlurSigma,
        child: panel,
      ),
    );
  }

  Future<void> _acceptPendingLandlordInvite() async {
    final invite = _pendingLandlordInvite;
    if (invite == null || _landlordInviteActionInFlight) return;
    setState(() => _landlordInviteActionInFlight = true);
    try {
      final conversationId =
          await getIt<IListingGroupService>().acceptLandlordInvite(
        groupListingId: invite.groupListingId,
        inviteId: invite.inviteId,
      );
      if (!mounted) return;
      setState(() => _pendingLandlordInvite = null);
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_landlord_invite_accepted"),
      );
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: ChatScreen.routeName(conversationId)),
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            listingId: invite.groupListingId,
            listingTitle: invite.groupListingTitle,
            conversationContextType: "listing_group",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic_try_again"),
      );
    } finally {
      if (mounted) setState(() => _landlordInviteActionInFlight = false);
    }
  }

  Future<void> _declinePendingLandlordInvite() async {
    final invite = _pendingLandlordInvite;
    if (invite == null || _landlordInviteActionInFlight) return;
    setState(() => _landlordInviteActionInFlight = true);
    try {
      await getIt<IListingGroupService>().declineLandlordInvite(
        groupListingId: invite.groupListingId,
        inviteId: invite.inviteId,
      );
      if (!mounted) return;
      setState(() => _pendingLandlordInvite = null);
      ToastTheme.showInfo(
        context,
        message: L10n.get("group_landlord_invite_declined"),
      );
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic_try_again"),
      );
    } finally {
      if (mounted) setState(() => _landlordInviteActionInFlight = false);
    }
  }

  Widget _buildPendingLandlordInviteCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.72),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              child: VerticalParticipantAvatarStack(
                participants: _pendingLandlordInvite?.members ?? const [],
                avatarSize: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    L10n.get("group_landlord_invite_chat_card_title"),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    L10n.get("group_landlord_invite_chat_card_body"),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: _landlordInviteActionInFlight
                            ? null
                            : () => unawaited(_declinePendingLandlordInvite()),
                        child: Text(L10n.get("group_landlord_invite_decline")),
                      ),
                      FilledButton(
                        onPressed: _landlordInviteActionInFlight
                            ? null
                            : () => unawaited(_acceptPendingLandlordInvite()),
                        child: _landlordInviteActionInFlight
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: UydoshInlineSpinner(
                                  color: Colors.white,
                                ),
                              )
                            : Text(L10n.get("group_landlord_invite_accept")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _chatLeadingRibbonWidgets() {
    final mentioned = _isGroupChat
        ? _mentionedListings()
        : const <({int listingId, String title})>[];
    return [
      if (mentioned.isNotEmpty)
        MentionedListingsRibbon(
          items: [
            for (final m in mentioned)
              MentionedListingChip(listingId: m.listingId, title: m.title),
          ],
          onTap: (id) => _jumpToSharedListing(id, focusComposer: false),
        ),
      if (_pendingLandlordInvite != null) _buildPendingLandlordInviteCard(),
      if (_showSecurityRibbon)
        ChatSecurityRibbon(onClose: _dismissSecurityRibbon),
      if (_safetyWarningActive)
        ChatSafetyWarningRibbon(
          title: _titleForRiskLevel(
            _safetyWarningSeverity == ChatSafetyWarningSeverity.high
                ? "high"
                : "medium",
          ),
          body: _resolvedSafetyWarningBody(),
          severity: _safetyWarningSeverity,
          onClose: _dismissSafetyWarning,
        ),
      if (_listingAiQuotaRibbon != null &&
          _listingAiQuotaRibbon!.shouldShowLowChatTranslateHint)
        Material(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.55),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const AiPremiumPlaceholderScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                L10n.getWithParams(
                  "ai_allowance_inline_chat_hint",
                  params: {
                    "count": "${_listingAiQuotaRibbon!.chatTranslateRemaining}",
                  },
                ),
                // Use [onSurface] (not [primary]) so the hint stays legible on the
                // dark blue chat surface, where [primary] is a near-invisible navy.
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _messageScrollExpanded() {
    return Expanded(
      child: Stack(
        children: [
          MultiBlocListener(
            listeners: [
              BlocListener<MessagingBloc, MessagingState>(
                listener: (context, state) {
                  if (!mounted) return;
                  state.when(
                    initial: () {},
                    loading: () {},
                    conversationsLoaded:
                        (conversations, hasMore, currentPage) {},
                    conversationsCleared: () {},
                    messagesLoaded: (
                      messages,
                      hasMore,
                      currentPage,
                      conversationId,
                    ) {
                      if (conversationId != widget.conversationId) return;
                      setState(() {
                        _applyMessagesAndMarkNewOnes(messages);
                      });
                      _finishRefreshSkeletonIfNeeded();
                      _refreshPeerAvatarIfPossible();
                      _maybeHandlePendingDiscuss();
                      context.read<MessagingBloc>().add(
                            MarkMessagesAsRead(conversationId: conversationId),
                          );

                      final latestMessage =
                          messages.isNotEmpty ? messages.last : null;
                      final latest = latestMessage?.content;
                      final latestSenderId = latestMessage?.senderId;
                      if (latest != null &&
                          latestSenderId != null &&
                          _currentUserId != null &&
                          latestSenderId != _currentUserId) {
                        _maybeRunSafetyCheck(triggerText: latest);
                      }
                    },
                    conversationCreated: (conversation) {},
                    messageSent: (message) {
                      setState(() {
                        _messages = [..._messages, message];
                        _newMessageIds.clear();
                        _newMessageIds.add(message.id);
                      });
                      _messageController.clear();
                      _scrollToBottom();
                      HapticFeedbackUtils.impact();
                      if (_highlightNextSentShare) {
                        _highlightNextSentShare = false;
                        _highlightMessage(message.id);
                      }
                    },
                    messageEdited: (message) {
                      setState(() {
                        final i =
                            _messages.indexWhere((m) => m.id == message.id);
                        if (i >= 0) {
                          _messages = List<Message>.from(_messages)
                            ..[i] = message;
                        }
                        _translationsById.remove(message.id);
                        _showOriginalMessageIds.remove(message.id);
                      });
                      HapticFeedbackUtils.impact();
                    },
                    messagesMarkedAsRead: (conversationId, markedCount) {},
                    error: (message) {
                      _finishRefreshSkeletonIfNeeded();
                    },
                  );
                },
              ),
              BlocListener<CurrentUserProfileBloc, CurrentUserProfileState>(
                listener: (context, state) {
                  if (!mounted) return;
                  state.when(
                    initial: () {},
                    loading: () {},
                    loaded: (profile) {
                      setState(() {
                        _currentUserProfile = profile;
                      });
                      if (_isGroupChat && _groupParticipants.isEmpty) {
                        _refreshGroupParticipantsFromMessages();
                      }
                    },
                    error: (message) {
                      logger.d(
                        "❌ [ChatScreen] Error loading current user profile: $message",
                      );
                    },
                  );
                },
              ),
            ],
            child: BlocBuilder<MessagingBloc, MessagingState>(
              buildWhen: (previous, current) {
                if (_messages.isNotEmpty) {
                  return false;
                }
                return previous != current;
              },
              builder: (context, state) {
                if (_showRefreshSkeleton) {
                  return const ChatMessagesSkeleton();
                }
                if (_messages.isNotEmpty) {
                  return _buildMessagesList(_messages);
                }
                return state.when(
                  initial: _buildLoadingState,
                  loading: _buildLoadingState,
                  conversationsLoaded: (conversations, hasMore, currentPage) =>
                      _hasLoadedMessagesForConversation
                          ? _buildMessagesList(_messages)
                          : _buildLoadingState(),
                  conversationsCleared: _buildEmptyState,
                  messagesLoaded: (
                    messages,
                    hasMore,
                    currentPage,
                    conversationId,
                  ) =>
                      _buildMessagesList(messages),
                  conversationCreated: (conversation) =>
                      _hasLoadedMessagesForConversation
                          ? _buildMessagesList(_messages)
                          : _buildLoadingState(),
                  messageSent: (message) => _buildEmptyState(),
                  messageEdited: (message) => _messages.isNotEmpty
                      ? _buildMessagesList(_messages)
                      : _buildEmptyState(),
                  messagesMarkedAsRead: (conversationId, markedCount) =>
                      _buildEmptyState(),
                  error: _buildErrorState,
                );
              },
            ),
          ),
          // Show a tiny global indicator whenever background translation is
          // running (auto mode or explicit "Translate to…"). This prevents
          // messages from "changing language out of nowhere".
          if (_translationInFlightIds.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.transparent,
              ),
            ),
          Positioned(
            right: 16,
            bottom: _scrollToBottomButtonBottomOffset(context),
            child: _buildScrollToBottomButton(),
          ),
        ],
      ),
    );
  }

  double _scrollToBottomButtonBottomOffset(BuildContext context) {
    if (!ThemeState().isBlueTheme) return 16;
    return _composerBottomReserveHeight +
        MediaQuery.viewPaddingOf(context).bottom +
        16;
  }

  Widget _buildScrollToBottomButton() {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableGlass = LiquidGlassRendering.effectsEnabled(context);
    final glassTint = themeState.isBlueTheme
        ? BlueThemeColors.background
        : (themeState.isLightTheme ? scheme.surface : themeState.cardColor);
    final iconColor =
        themeState.isBlueTheme ? Colors.white : themeState.cardIconColor;
    const shape = CircleBorder();

    return AnimatedScale(
      scale: _showScrollToBottomButton ? 1 : 0.88,
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _showScrollToBottomButton ? 1 : 0,
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: IgnorePointer(
          ignoring: !_showScrollToBottomButton,
          child: Tooltip(
            message: L10n.get("chat_scroll_to_bottom"),
            child: Material(
              type: MaterialType.transparency,
              shape: shape,
              clipBehavior: Clip.antiAlias,
              child: LiquidGlassRendering.backdropBlur(
                enabled: enableGlass,
                sigma: LiquidGlassRendering.plateBlurSigma,
                child: InkWell(
                  customBorder: shape,
                  onTap: () {
                    UiFeedbackUtils.selection();
                    _scrollToBottom();
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glassTint.withValues(alpha: isDark ? 0.30 : 0.46),
                      border: Border.all(
                        color: (themeState.isBlueTheme
                                ? Colors.white
                                : scheme.onSurface)
                            .withValues(
                          alpha: themeState.isBlueTheme ? 0.22 : 0.12,
                        ),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.26 : 0.14,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: iconColor,
                        size: 30,
                        semanticLabel: L10n.get("chat_scroll_to_bottom"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final backgroundColor = themeState.backgroundColor;

        return Scaffold(
          extendBodyBehindAppBar:
              themeState.isBlueTheme && themeState.usesLiquidGlassChrome,
          backgroundColor: backgroundColor,
          appBar: ChatHeader(
            displayName: _getPeerDisplayName(context),
            subtitle: _chatHeaderSubtitle(),
            peerAvatarUrl: _isGroupChat ? null : _peerAvatarUrl,
            peerInitials: _isGroupChat ? null : widget.otherUserInitials,
            groupParticipants: _isGroupChat && _groupParticipants.isNotEmpty
                ? _groupParticipants
                : null,
            currentUserId: _currentUserId,
            onPeerAvatarTap: _isGroupChat ? null : _navigateToUserProfile,
            onGroupParticipantsTap: _isGroupChat
                ? () => unawaited(_openGroupParticipantsSheet())
                : null,
            actionBeforeMenu: widget.gigRequestId != null
                ? _buildInviteToBookAppBarButton(context)
                : null,
            actionMenuItems: _buildActionMenuItems(),
          ),
          body: GestureDetector(
            onTap: () {
              // Hide keyboard when tapping outside of text input
              FocusScope.of(context).unfocus();
            },
            child: themeState.isBlueTheme && themeState.usesLiquidGlassChrome
                ? Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.paddingOf(context).top +
                                kToolbarHeight,
                          ),
                          child: Column(
                            children: [
                              ..._chatLeadingRibbonWidgets(),
                              _messageScrollExpanded(),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: RepaintBoundary(
                          child: _blueGlassComposerPanel(),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ..._chatLeadingRibbonWidgets(),
                      _messageScrollExpanded(),
                      _chatComposerSection(blendWithGlassBackdrop: false),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: HouseLoadingIndicator());
  }

  Widget _buildErrorState(String message) {
    final displayMessage = message.contains("USER_BLOCKED")
        ? L10n.get("user_blocked_violation_message")
        : (message.contains("DioException") ||
                message.contains("bad response") ||
                message.contains("status code"))
            ? L10n.get("error_generic")
            : message;

    return UydoshErrorRetryColumn(
      message: displayMessage,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      onRetry: () {
        context.read<MessagingBloc>().add(
              RefreshMessages(conversationId: widget.conversationId),
            );
      },
    );
  }

  Widget _buildChatMessageBubble({
    required Message message,
    required bool isCurrentUser,
    required bool isLatest,
  }) {
    if (_isGroupChat) {
      final refPayload = ListingRefMessageCodec.parse(message.content);
      if (refPayload != null) {
        final senderName =
            message.sender?.profile?.name ?? message.sender?.email ?? "";
        return ListingRefMessageBubble(
          key: ValueKey("listing_ref_${message.id}_${message.createdAt}"),
          message: message,
          payload: refPayload,
          isCurrentUser: isCurrentUser,
          isLandlordBubble: _isLandlordMessage(message),
          leftAvatarInitials:
              isCurrentUser ? null : StringUtils.extractInitials(senderName),
          rightAvatarInitials: _getCurrentUserInitials(),
          leftAvatarUrl:
              isCurrentUser ? null : message.sender?.profile?.avatarUrl,
          rightAvatarUrl: _currentUserProfile?.avatarUrl,
          onTapAnchor: () => _jumpToSharedListing(refPayload.listingId),
        );
      }
      final payload = ListingShareMessageCodec.parse(message.content);
      if (payload != null) {
        final senderName =
            message.sender?.profile?.name ?? message.sender?.email ?? "";
        final previousPayload = _listingShareNeighborPayload(
          message: message,
          next: false,
        );
        final nextPayload = _listingShareNeighborPayload(
          message: message,
          next: true,
        );
        return ListingShareMessageBubble(
          key: ValueKey("listing_share_${message.id}_${message.createdAt}"),
          message: message,
          payload: payload,
          rating: message.listingRating,
          optionNumber: _listingShareOptionNumber(payload),
          isCurrentUser: isCurrentUser,
          isLandlordBubble: _isLandlordMessage(message),
          leftAvatarInitials:
              isCurrentUser ? null : StringUtils.extractInitials(senderName),
          rightAvatarInitials: _getCurrentUserInitials(),
          leftAvatarUrl:
              isCurrentUser ? null : message.sender?.profile?.avatarUrl,
          rightAvatarUrl: _currentUserProfile?.avatarUrl,
          onOpenListing: () => _openSharedListing(payload.listingId),
          onOpenPreviousListing: previousPayload == null
              ? null
              : () => _openSharedListing(previousPayload.listingId),
          onOpenNextListing: nextPayload == null
              ? null
              : () => _openSharedListing(nextPayload.listingId),
          onRate: (stars) => _openListingRatingDialog(
            message,
            initialStars: stars,
          ),
        );
      }
    }

    return MessageBubble(
      key: ValueKey("message_${message.id}_${message.createdAt}"),
      message: message,
      isCurrentUser: isCurrentUser,
      isLatest: isLatest,
      riskLevel: _messageRiskById[message.id],
      riskReason: () {
        final raw = _messageSafetyReasonById[message.id];
        if (raw == null || raw.isEmpty) return null;
        return _localizedSafetyReason(raw);
      }(),
      onRiskBadgeTap: () {
        final riskLevel = _messageRiskById[message.id];
        if (riskLevel == null) return;
        _openSuspiciousMessageSheet(
          message: message,
          riskLevel: riskLevel,
        );
      },
      onAnimationComplete: () {
        setStateIfMounted(() => _newMessageIds.remove(message.id));
      },
      currentUserProfile: _currentUserProfile,
      otherUserInitials: _isGroupChat ? null : widget.otherUserInitials,
      otherUserAvatarUrl: _isGroupChat ? null : _peerAvatarUrl,
      translation: _translationsById[message.id],
      isTranslating: _translationInFlightIds.contains(message.id),
      showOriginal:
          _showOriginalAll ^ _showOriginalMessageIds.contains(message.id),
      onToggleTranslation: _translationsById[message.id] == null
          ? null
          : () {
              setState(() {
                if (_showOriginalMessageIds.contains(message.id)) {
                  _showOriginalMessageIds.remove(message.id);
                } else {
                  _showOriginalMessageIds.add(message.id);
                }
              });
            },
      onSetReaction: isCurrentUser
          ? null
          : (reactionId) => _setMessageReaction(message, reactionId),
      onClearReaction:
          isCurrentUser ? null : () => _clearMessageReaction(message),
      onLongPressEditOwnMessage:
          isCurrentUser && _isOwnTextBubbleForLongPressEdit(message)
              ? () => _onLongPressOwnMessageForEdit(message)
              : null,
      isLandlordBubble: _isLandlordMessage(message),
      onTapReplyPreview: (replyId) => _jumpToMessageById(
        replyId,
        focusComposer: false,
      ),
    );
  }

  String? _getCurrentUserInitials() {
    return StringUtils.extractInitials(_currentUserProfile?.name);
  }

  Future<void> _openSharedListing(int housingListingId) async {
    await context.pushListingDetail(
      housingListingId,
      groupHousingContextListingId: widget.listingId,
    );
  }

  ListingShareMessagePayload? _listingShareNeighborPayload({
    required Message message,
    required bool next,
  }) {
    final sharedListings =
        <({Message message, ListingShareMessagePayload payload})>[];
    for (final candidate in _messages) {
      if (candidate.isDeleted == true) continue;
      final payload = ListingShareMessageCodec.parse(candidate.content);
      if (payload == null) continue;
      sharedListings.add((message: candidate, payload: payload));
    }

    final currentIndex =
        sharedListings.indexWhere((entry) => entry.message.id == message.id);
    if (currentIndex < 0) return null;

    final targetIndex = currentIndex + (next ? 1 : -1);
    if (targetIndex < 0 || targetIndex >= sharedListings.length) return null;
    return sharedListings[targetIndex].payload;
  }

  /// Whether a (non-deleted) listing-share card for [listingId] is already
  /// present among the currently loaded messages of this conversation.
  bool _listingAlreadyShared(int listingId) {
    return _firstSharedListing(listingId) != null;
  }

  /// Earliest (non-deleted) listing-share card for [listingId] with its parsed
  /// payload. [_messages] is chronological ascending, so the first match is the
  /// oldest mention.
  ({int id, ListingShareMessagePayload payload})? _firstSharedListing(
    int listingId,
  ) {
    for (final candidate in _messages) {
      if (candidate.isDeleted == true) continue;
      final payload = ListingShareMessageCodec.parse(candidate.content);
      if (payload != null && payload.listingId == listingId) {
        return (id: candidate.id, payload: payload);
      }
    }
    return null;
  }

  /// Tap handler for an anchor breadcrumb / ribbon chip: scroll to (and flash)
  /// the original listing card. If it isn't in the loaded window, tell the user.
  ///
  /// [focusComposer] is true for the inline anchor (so the user can reply in
  /// context). The ribbon passes false: opening the keyboard there resizes the
  /// viewport mid-scroll, which made the first tap appear to do nothing.
  void _jumpToSharedListing(int listingId, {bool focusComposer = true}) {
    final existing = _firstSharedListing(listingId);
    if (existing == null) {
      ToastTheme.showInfo(
        context,
        message: L10n.get("group_shortlist_original_not_found"),
      );
      return;
    }
    unawaited(
      _focusExistingSharedListing(existing.id, focusComposer: focusComposer),
    );
  }

  /// Runs once after the first message load when the chat was opened to discuss
  /// a specific listing. If the card already exists we scroll to it; otherwise
  /// we post it directly so the encoded payload never appears in the composer.
  void _maybeHandlePendingDiscuss() {
    if (_pendingDiscussHandled) return;
    final listingId = _pendingDiscussListingId;
    if (listingId == null) return;
    _pendingDiscussHandled = true;

    final existing = _firstSharedListing(listingId);
    if (existing != null) {
      // Continue discussion: drop a compact, tappable anchor into the timeline
      // instead of re-posting the full card or scrolling away.
      final sharePayload = _pendingListingShareToPost == null
          ? null
          : ListingShareMessageCodec.parse(_pendingListingShareToPost!);
      _pendingListingShareToPost = null;
      final title = existing.payload.title.trim().isNotEmpty
          ? existing.payload.title.trim()
          : (sharePayload?.title.trim() ?? "");
      final refContent = ListingRefMessageCodec.encode(
        ListingRefMessagePayload(listingId: listingId, title: title),
      );
      setState(() => _isSendingMessage = true);
      context.read<MessagingBloc>().add(
            SendMessage(
              conversationId: widget.conversationId,
              content: refContent,
            ),
          );
      return;
    }

    final content = _pendingListingShareToPost?.trim();
    _pendingListingShareToPost = null;
    if (content == null || content.isEmpty) return;
    _highlightNextSentShare = true;
    setState(() => _isSendingMessage = true);
    context.read<MessagingBloc>().add(
          SendMessage(conversationId: widget.conversationId, content: content),
        );
  }

  /// Scrolls to an already-posted listing card and flashes it. When
  /// [focusComposer] is true it also focuses the composer so the user can
  /// comment in context; otherwise the keyboard is dismissed first so the
  /// viewport stays put while we scroll.
  Future<void> _focusExistingSharedListing(
    int messageId, {
    bool focusComposer = true,
  }) async {
    if (!mounted) return;
    if (!focusComposer) {
      // Dismiss the keyboard and wait for the viewport to finish resizing
      // before scrolling. Scrolling while the keyboard is still animating
      // closed makes the first tap land on the wrong offset (it looks like
      // nothing happened), which is why the chip used to need a second tap.
      final keyboardWasOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
      FocusScope.of(context).unfocus();
      if (keyboardWasOpen) {
        await _waitForKeyboardDismissed();
        if (!mounted) return;
      }
    }
    setState(() => _scrollTargetMessageId = messageId);
    await _scrollToMessageById(messageId);
    if (!mounted) return;
    _highlightMessage(messageId);
    if (focusComposer) {
      _messageFocusNode.requestFocus();
    }
  }

  Future<void> _jumpToMessageById(
    int messageId, {
    bool focusComposer = false,
  }) {
    return _focusExistingSharedListing(
      messageId,
      focusComposer: focusComposer,
    );
  }

  /// Waits until the on-screen keyboard has finished collapsing (bottom inset
  /// back to zero) so a subsequent scroll runs against a stable viewport.
  /// Bails out after a short budget in case the inset never settles.
  Future<void> _waitForKeyboardDismissed() async {
    final deadline = DateTime.now().add(const Duration(milliseconds: 450));
    while (mounted &&
        MediaQuery.viewInsetsOf(context).bottom > 0 &&
        DateTime.now().isBefore(deadline)) {
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  /// Brings the message carrying [_scrollTargetKey] into view. Items are built
  /// lazily, so when the target is off-screen we step the list toward it until
  /// it mounts, then center it.
  ///
  /// The list is reversed (newest at the bottom ⇒ larger scroll offset = older
  /// messages). We estimate the target's offset from its index so we step in
  /// the correct direction whether it's above or below the current viewport —
  /// otherwise jumping from the top of the chat (where the target is *newer*,
  /// i.e. at a smaller offset) would never move.
  Future<void> _scrollToMessageById(int messageId) async {
    const maxAttempts = 24;

    double? targetOffsetEstimate;
    if (_scrollController.hasClients) {
      final grouped = _groupedItemsFor(_messages);
      final itemIndex = grouped.indexWhere(
        (it) => it is MessageListItem && it.message.id == messageId,
      );
      if (itemIndex >= 0 && grouped.length > 1) {
        // Reversed list index for this item; fraction → estimated pixels.
        final listIndex = grouped.length - 1 - itemIndex;
        final fraction = listIndex / (grouped.length - 1);
        targetOffsetEstimate =
            fraction * _scrollController.position.maxScrollExtent;
      }
    }

    // Pick the step direction once and keep it. Recomputing it each iteration
    // against the fixed estimate makes the list oscillate (overshoot → flip →
    // undershoot → flip…). We only ever reverse a single time, and only if we
    // hit a boundary without mounting the target.
    var goUp = targetOffsetEstimate == null ||
        (_scrollController.hasClients &&
            targetOffsetEstimate >= _scrollController.position.pixels);
    var reversedOnce = false;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (!mounted) return;
      final ctx = _scrollTargetKey.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          alignment: 0.3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
        return;
      }
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final step = position.viewportDimension * 0.85;
      final next = (goUp ? position.pixels + step : position.pixels - step)
          .clamp(0.0, position.maxScrollExtent);
      if ((next - position.pixels).abs() < 1) {
        // Reached an edge without finding the target. The initial guess may
        // have been wrong; try the other direction exactly once.
        if (reversedOnce) return;
        reversedOnce = true;
        goUp = !goUp;
        continue;
      }
      await _scrollController.animateTo(
        next,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      await Future<void>.delayed(const Duration(milliseconds: 24));
    }
  }

  void _highlightMessage(int messageId) {
    _highlightTimer?.cancel();
    setState(() => _highlightedMessageId = messageId);
    _highlightTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _highlightedMessageId = null;
        _scrollTargetMessageId = null;
      });
    });
  }

  /// Tags the focused/flashing listing card so it carries [_scrollTargetKey]
  /// (for `ensureVisible`) and a brief highlight tint. Untouched messages are
  /// returned as-is to avoid per-row overhead.
  Widget _wrapMessageForFocus(Message message, Widget child) {
    final isTarget = _scrollTargetMessageId == message.id;
    final isHighlighted = _highlightedMessageId == message.id;
    if (!isTarget && !isHighlighted) return child;

    Widget result = child;
    final isListingShare =
        ListingShareMessageCodec.parse(message.content) != null;
    if (isHighlighted && !isListingShare) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: result,
      );
    }
    if (isTarget) {
      result = KeyedSubtree(key: _scrollTargetKey, child: result);
    }
    return result;
  }

  Widget _wrapMessageForReplyGesture(Message message, Widget child) {
    if (!_canReplyToMessage(message)) return child;
    return _ReplySwipeWrapper(
      onReply: () => _startReplyToMessage(message),
      child: child,
    );
  }

  Future<void> _openListingRatingDialog(
    Message message, {
    required int initialStars,
  }) async {
    final currentStars = message.listingRating?.myStars ?? 0;
    final currentReasons =
        message.listingRating?.myReasons.toSet() ?? const <String>{};
    final currentCategoryRatings =
        message.listingRating?.myCategoryRatings ?? const <String, int>{};
    final currentVerdict = message.listingRating?.myVerdict;
    final result = await showListingRatingDialog(
      context: context,
      currentStars: initialStars,
      initialReasonCodes: currentReasons,
      initialCategoryRatings: currentCategoryRatings,
      prefillMissingCategoryRatings: false,
    );

    if (result == null || !mounted) {
      return;
    }
    final reasons = result.reasons;
    if (result.stars == currentStars &&
        setEquals(currentReasons, reasons.toSet()) &&
        mapEquals(currentCategoryRatings, result.categoryRatings) &&
        currentVerdict == result.verdict) {
      return;
    }
    await _setListingRating(
      message,
      result.stars,
      reasons: reasons,
      categoryRatings: result.categoryRatings,
      verdict: result.verdict,
    );
  }

  Future<void> _setListingRating(
    Message message,
    int stars, {
    List<String> reasons = const [],
    Map<String, int> categoryRatings = const {},
    String? verdict,
  }) async {
    try {
      final updated = await getIt<IMessagingService>().setListingRating(
        messageId: message.id,
        stars: stars,
        reasons: reasons,
        categoryRatings: categoryRatings,
        verdict: verdict,
      );
      if (!mounted) return;
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index >= 0) {
          _messages = List<Message>.from(_messages)..[index] = updated;
        }
      });
      HapticFeedbackUtils.selectionClick();
      context.read<MessagingBloc>().add(
            RefreshMessages(conversationId: widget.conversationId),
          );
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains("USER_BLOCKED")) {
        ToastTheme.showError(
          context,
          message: L10n.get("user_blocked_violation_message"),
        );
        return;
      }
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic"),
      );
    }
  }

  Widget _buildMessagesList(List<Message> messages) {
    if (messages.isEmpty) {
      return UydoshRefreshIndicator(
        onRefresh: () async {
          await _refreshMessagesWithSkeleton();
        },
        child: _buildEmptyState(),
      );
    }

    // Group messages by date for lazy building (memoized across rebuilds)
    final groupedItems = _groupedItemsFor(messages);
    _syncDateHeaderKeys(groupedItems);
    _scheduleStickyDateHeaderUpdate();

    return Stack(
      key: _messagesViewportKey,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _scheduleStickyDateHeaderUpdate();
            return false;
          },
          child: CommonListView(
            controller: _scrollController,
            padding: _messagesListPadding(context),
            reverse: true, // Show newest messages at bottom
            itemSpacing: 0, // Message grouping handles spacing
            itemCount: groupedItems.length,
            itemBuilder: (context, index) {
              // Since we're using reverse: true, we need to reverse the index
              final itemIndex = groupedItems.length - 1 - index;
              final item = groupedItems[itemIndex];

              return switch (item) {
                DateHeaderListItem(:final date) => SizedBox(
                    key: _dateHeaderGlobalKey(date),
                    height: 10,
                  ),
                MessageListItem(
                  :final message,
                  :final isCurrentUser,
                  :final isLatest,
                ) =>
                  KeyedSubtree(
                    key: _messageItemGlobalKey(message),
                    child: _wrapMessageForReplyGesture(
                      message,
                      _wrapMessageForFocus(
                        message,
                        _buildChatMessageBubble(
                          message: message,
                          isCurrentUser: isCurrentUser,
                          isLatest: isLatest,
                        ),
                      ),
                    ),
                  ),
              };
            },
            showRefreshIndicator: true,
            onRefresh: () async {
              await _refreshMessagesWithSkeleton();
            },
          ),
        ),
        if (_stickyDateHeaderDate case final stickyDate?)
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: IgnorePointer(
              child: DateHeaderWidget(
                dateString: AppDateUtils.formatDateHeader(stickyDate, context),
                date: stickyDate,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _refreshMessagesWithSkeleton() async {
    // Coalesce multiple taps/gestures into a single refresh.
    if (_refreshCompleter != null && !(_refreshCompleter!.isCompleted)) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();
    _refreshSkeletonStartedAt = DateTime.now();
    if (mounted) {
      setState(() => _showRefreshSkeleton = true);
    }

    context.read<MessagingBloc>().add(
          RefreshMessages(conversationId: widget.conversationId),
        );

    return _refreshCompleter!.future;
  }

  void _finishRefreshSkeletonIfNeeded() {
    final completer = _refreshCompleter;
    if (completer == null || completer.isCompleted) return;

    final startedAt = _refreshSkeletonStartedAt;
    final elapsed = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);
    final remaining = elapsed >= _minSkeletonDuration
        ? Duration.zero
        : _minSkeletonDuration - elapsed;

    Future<void>.delayed(remaining, () {
      setStateIfMounted(() => _showRefreshSkeleton = false);
      if (!completer.isCompleted) completer.complete();
      _refreshCompleter = null;
      _refreshSkeletonStartedAt = null;
    });
  }

  Widget _buildEmptyState() {
    return UydoshEmptyColumn(
      icon: Icons.chat_bubble_outline,
      title: L10n.get("no_messages"),
      subtitle: L10n.get("send_first_message"),
      fillViewportForRefresh: true,
    );
  }

  bool _isOwnTextBubbleForLongPressEdit(Message message) {
    if (message.isDeleted == true) return false;
    if (message.messageType.toLowerCase() != 'text') return false;
    final atts = message.attachments;
    if (atts != null && atts.isNotEmpty) return false;
    return true;
  }

  bool _canReplyToMessage(Message message) {
    if (message.isDeleted == true) return false;
    return message.messageType.toLowerCase() != "system";
  }

  void _startReplyToMessage(Message message) {
    if (!_canReplyToMessage(message) || !mounted) return;
    setState(() {
      _editingMessageId = null;
      _replyingToMessage = message;
    });
    HapticFeedbackUtils.lightImpact();
    _messageFocusNode.requestFocus();
  }

  void _clearReplyMode() {
    if (_replyingToMessage == null) return;
    setState(() => _replyingToMessage = null);
  }

  String _messageSenderDisplayName(Message message) {
    if (message.senderId == _currentUserId) {
      return L10n.get("chat_reply_sender_you");
    }
    final name = message.sender?.profile?.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = message.sender?.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    if (!_isGroupChat) {
      final peerName = widget.otherUserName?.trim();
      if (peerName != null && peerName.isNotEmpty) return peerName;
    }
    return L10n.get("chat_reply_sender_unknown");
  }

  String _messagePreviewText(Message message) {
    final listingShare = ListingShareMessageCodec.parse(message.content);
    if (listingShare != null) return listingShare.title;
    final listingRef = ListingRefMessageCodec.parse(message.content);
    if (listingRef != null) {
      return listingRef.title.trim().isEmpty
          ? L10n.get("group_shortlist_ref_label")
          : listingRef.title.trim();
    }
    final text = message.content.trim().replaceAll(RegExp(r"\s+"), " ");
    if (text.isNotEmpty) return text;
    return L10n.get("chat_reply_attachment_fallback");
  }

  String? _messageSenderAvatarUrl(Message message) {
    if (message.senderId == _currentUserId) {
      return _currentUserProfile?.avatarUrl;
    }
    return message.sender?.profile?.avatarUrl ??
        (!_isGroupChat ? _peerAvatarUrl : null);
  }

  String? _messageSenderInitials(Message message) {
    if (message.senderId == _currentUserId) {
      return StringUtils.extractInitials(_currentUserProfile?.name);
    }
    final name = message.sender?.profile?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return StringUtils.extractInitials(name);
    }
    final email = message.sender?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return StringUtils.extractInitials(email);
    }
    return null;
  }

  /// Opens composer edit mode, or explains that this bubble was already revised.
  void _onLongPressOwnMessageForEdit(Message message) {
    if (!_isOwnTextBubbleForLongPressEdit(message) || !mounted) return;
    if (_messageIsEditable(message)) {
      _startComposerEditFromMessage(message);
      return;
    }
    if (message.isVisiblyEdited) {
      ToastTheme.showInfo(
        context,
        message: context.l10n.chat_edit_hold_already_edited_toast,
      );
    }
  }

  void _startComposerEditFromMessage(Message message) {
    if (!_messageIsEditable(message) || !mounted) return;
    setState(() {
      _editingMessageId = message.id;
      _replyingToMessage = null;
      _messageController.value = TextEditingValue(
        text: message.content,
        selection: TextSelection.collapsed(offset: message.content.length),
      );
    });
    _messageFocusNode.requestFocus();
    HapticFeedbackUtils.lightImpact();
    _scrollToBottom();
  }

  void _clearComposerEditMode() {
    if (_editingMessageId == null && _messageController.text.isEmpty) return;
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
    unawaited(_restoreComposerDraft());
  }

  bool _messageIsEditable(Message message) {
    if (message.isDeleted == true) return false;
    if (message.isVisiblyEdited) return false;
    if (message.messageType.toLowerCase() != 'text') return false;
    final atts = message.attachments;
    if (atts != null && atts.isNotEmpty) return false;
    return true;
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSendingMessage) return;

    final editingId = _editingMessageId;
    if (editingId != null) {
      final idx = _messages.indexWhere((m) => m.id == editingId);
      if (idx < 0) {
        setState(() => _editingMessageId = null);
        return;
      }
      final original = _messages[idx].content.trim();
      if (content == original) {
        _messageFocusNode.unfocus();
        _clearComposerEditMode();
        return;
      }
      setState(() => _isSendingMessage = true);
      _messageFocusNode.unfocus();
      context.read<MessagingBloc>().add(
            EditMessage(messageId: editingId, newContent: content),
          );
      return;
    }

    // Block re-adding a listing card that is already in this group discussion.
    // The backend is authoritative (and handles races), but this gives instant
    // feedback and avoids a wasted round-trip for the common case.
    if (_isGroupChat) {
      final payload = ListingShareMessageCodec.parse(content);
      if (payload != null && _listingAlreadyShared(payload.listingId)) {
        ToastTheme.showInfo(
          context,
          message: L10n.get("group_shortlist_already_in_discussion"),
        );
        return;
      }
    }

    setState(() {
      _isSendingMessage = true;
    });

    final replyToMessageId = _replyingToMessage?.id;
    _messageController.clear();
    _clearReplyMode();
    ChatComposerDraftState().clearDraft(widget.conversationId);

    // Dismiss the keyboard once the message has been submitted so the user
    // sees the freshly sent message instead of the composer obscuring the list.
    _messageFocusNode.unfocus();

    // Haptic + sound feedback on send (same as splash - always fires, bypasses app setting)
    HapticFeedback.mediumImpact();
    SendSoundUtils.playSendSound();

    getIt<AppAnalyticsService>().logMessageSent(
      conversationId: widget.conversationId,
    );
    context.read<MessagingBloc>().add(
          SendMessage(
            conversationId: widget.conversationId,
            content: content,
            replyToMessageId: replyToMessageId,
          ),
        );
  }

  Future<void> _setMessageReaction(Message message, String reactionId) async {
    try {
      await getIt<IMessagingService>().setMessageReaction(
        messageId: message.id,
        reaction: reactionId,
      );
      if (!mounted) {
        return;
      }
      context.read<MessagingBloc>().add(
            RefreshMessages(conversationId: widget.conversationId),
          );
    } catch (e) {
      if (!mounted) {
        return;
      }
      if (e.toString().contains("USER_BLOCKED")) {
        ToastTheme.showError(
          context,
          message: L10n.get("user_blocked_violation_message"),
        );
        return;
      }
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic"),
      );
    }
  }

  Future<void> _clearMessageReaction(Message message) async {
    try {
      await getIt<IMessagingService>().removeMessageReaction(
        messageId: message.id,
      );
      if (!mounted) {
        return;
      }
      context.read<MessagingBloc>().add(
            RefreshMessages(conversationId: widget.conversationId),
          );
    } catch (e) {
      if (!mounted) {
        return;
      }
      if (e.toString().contains("USER_BLOCKED")) {
        ToastTheme.showError(
          context,
          message: L10n.get("user_blocked_violation_message"),
        );
        return;
      }
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic"),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      if (_showScrollToBottomButton) {
        setState(() => _showScrollToBottomButton = false);
      }
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onQuestionTap(String question, String questionKey) {
    getIt<AppAnalyticsService>().logQuickQuestionTapped(
      conversationId: widget.conversationId,
      listingId: widget.listingId,
      listingTypeId: widget.listingTypeId,
      isViewerListingOwner: _isViewerListingOwner,
      isViewerServiceOfferer: _isViewerServiceOfferer,
      questionKey: questionKey,
    );
    // Add appropriate greeting based on current language
    final greeting = _getGreetingForCurrentLanguage();
    // Lowercase the first letter of the question
    final lowercasedQuestion = question.isEmpty
        ? question
        : question[0].toLowerCase() + question.substring(1);
    _messageController.text = "$greeting $lowercasedQuestion";
    setState(() {
      _editingMessageId = null;
      _replyingToMessage = null;
    });
    // Don't steal focus / open keyboard when tapping a quick question.
    // If keyboard is already open, tapping a chip should dismiss it.
    FocusScope.of(context).unfocus();
  }

  /// True when the signed-in user owns the backing listing (or gig row author
  /// for `gig_offer` / `gig_booking` where inbox passes the same id here).
  bool get _isViewerListingOwner {
    final currentId = _currentUserId;
    final ownerId = widget.listingOwnerUserId;
    if (currentId == null || ownerId == null) return false;
    return currentId == ownerId;
  }

  /// True when quick chips should address the **client** (viewer is offerer).
  bool get _isViewerServiceOfferer {
    final uid = _currentUserId;
    if (uid == null) return false;

    final ctx = widget.conversationContextType?.trim().toLowerCase();
    final part = widget.conversationParticipantId;

    if (ctx == "gig_request" && part != null) {
      return uid != part;
    }
    if ((ctx == "gig_offer" || ctx == "gig_booking") && part != null) {
      return uid == part;
    }

    return _isViewerListingOwner;
  }

  String _getGreetingForCurrentLanguage() {
    // Get current language using the same method as the app
    final language = LanguageState().currentLanguage;
    switch (language) {
      case "ru":
        return "Привет,";
      case "uz":
        return "Salom,";
      default:
        return "Hi,";
    }
  }

  void _navigateToListingDetail() {
    if (widget.listingId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    ListingDetailBloc(getIt<IListingService>()),
              ),
              BlocProvider(create: (_) => ListingDetailPageBloc()),
            ],
            child: ListingDetailScreen(listingId: widget.listingId!),
          ),
        ),
      );
    }
  }

  void _navigateToGigRequestDetail() {
    final id = widget.gigRequestId;
    if (id == null) return;
    UiFeedbackUtils.selection();
    if (widget.gigRequestDetailRouteBelow) {
      Navigator.of(context).pop();
      return;
    }
    context.pushGigRequestDetail(id);
  }

  Future<void> _openGroupParticipantsSheet() async {
    if (!_isGroupChat || _groupParticipants.isEmpty) return;
    UiFeedbackUtils.selection();

    final listingId = widget.listingId;
    if (listingId == null) return;

    final detail = _groupListingDetail;
    final ownerUserId = detail?.user.id ??
        widget.listingOwnerUserId ??
        _groupParticipants.first.userId;
    final isOwner = _groupChatIsOwner ||
        (_currentUserId != null && _currentUserId == ownerUserId);

    if (_groupListingDetail == null) {
      unawaited(_loadGroupHousingContext());
    }

    final leftGroup = await showListingGroupMemberProfilesSheet(
      context: context,
      listingId: listingId,
      members: _groupParticipants,
      ownerUserId: ownerUserId,
      currentUserId: _currentUserId,
      isOwner: isOwner,
      groupProgress: detail == null
          ? null
          : ListingGroupProgress.fromListingDetail(detail),
      memberCompatibility: _groupMemberCompatibility,
      groupListingDetail: detail,
      onMemberTap: _navigateToProfile,
      onChanged: () {
        setState(() => _groupMemberCompatibility = {});
        unawaited(_loadGroupParticipants());
        unawaited(_loadGroupHousingContext());
      },
    );
    if (leftGroup && mounted) {
      _navigateHomeAfterLeavingGroup();
    }
  }

  void _navigateHomeAfterLeavingGroup() {
    context.read<ConversationsBloc>().add(const ConversationsRefresh());

    final mainState = mainNavigationKey.currentState;
    if (mainState != null) {
      mainState.navigateToIndex(0);
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    context.pushMainNavigationAndRemoveUntil();
  }

  void _navigateToProfile(int userId) {
    UiFeedbackUtils.selection();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ListingOwnerProfileBloc(
            getIt<IUserProfileService>(),
            getIt<IFollowService>(),
          ),
          child: ListingOwnerProfileScreen(userId: userId),
        ),
      ),
    );
  }

  void _navigateToUserProfile() {
    // Prefer widget.otherUserId, fall back to deriving from messages
    final otherUserId = widget.otherUserId ?? _getOtherUserIdFromMessages();
    if (otherUserId != null) {
      _navigateToProfile(otherUserId);
    }
  }

  Future<void> _createComplaint() async {
    if (widget.listingId == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<ComplaintBloc>(
          create: (context) => ComplaintBloc(getIt<IComplaintService>()),
          child: CreateComplaintScreen(listingId: widget.listingId!),
        ),
      ),
    );

    if (result == true && context.mounted) {
      ToastTheme.showSuccess(
        context,
        message: L10n.get("complaint_created_success"),
      );
    }
  }

  Widget _buildInviteToBookAppBarButton(BuildContext context) {
    return IgnorePointer(
      ignoring: _inviteBookingInFlight,
      child: Opacity(
        opacity: _inviteBookingInFlight ? 0.45 : 1,
        child: ThreeDAppBarIconButton(
          iconData: Icons.how_to_reg_outlined,
          onPressed: () => unawaited(_inviteCounterpartyFromTaskToBook()),
          semanticsLabel: L10n.get("gigs_chat_menu_invite_provider_to_book"),
        ),
      ),
    );
  }

  Widget _buildProfileMenuIcon() {
    final resolvedAvatarUrl = resolveAvatarUrl(_peerAvatarUrl);
    if (resolvedAvatarUrl != null) {
      const iconSize = 24.0;
      final fallback = const Center(
        child: ThemeIcon(Icons.person, size: 20),
      );
      return ClipOval(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: NetworkAvatarImage(
            imageUrl: resolvedAvatarUrl,
            size: iconSize,
            fallback: fallback,
          ),
        ),
      );
    }
    return const ThemeIcon(Icons.person, size: 20);
  }

  int? _getOtherUserIdFromMessages() {
    if (_currentUserId == null || _messages.isEmpty) return null;

    // Find the first message from someone other than the current user
    for (final message in _messages) {
      if (message.senderId != _currentUserId) {
        return message.senderId;
      }
    }

    return null;
  }

  Future<void> _inviteCounterpartyFromTaskToBook() async {
    final rid = widget.gigRequestId;
    final otherId = widget.otherUserId ?? _getOtherUserIdFromMessages();
    if (rid == null || otherId == null) {
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("gigs_request_contact_failed"),
        );
      }
      return;
    }
    if (_inviteBookingInFlight) return;
    setState(() => _inviteBookingInFlight = true);
    try {
      final req = await getIt<IGigService>().getRequest(rid);
      if (!mounted) return;
      final me = _currentUserId ?? await SessionManager.getUserId();
      if (me == null || me != req.clientUserId) {
        ToastTheme.showError(
          context,
          message: L10n.get("gigs_invite_provider_owner_only"),
        );
        return;
      }
      if (req.status != GigRequestStatus.open) {
        ToastTheme.showError(
          context,
          message: L10n.get("gigs_invite_provider_not_open_task"),
        );
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (_) => _InviteProviderBookingDialog(
          snackParentContext: context,
          gigRequest: req,
          providerUserId: otherId,
        ),
      );
    } catch (_) {
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("gigs_invite_provider_failed_toast"),
        );
      }
    } finally {
      if (mounted) setState(() => _inviteBookingInFlight = false);
    }
  }

  List<ActionMenuItem> _buildActionMenuItems() {
    final items = <ActionMenuItem>[];
    final otherUserId = widget.otherUserId ?? _getOtherUserIdFromMessages();

    items.add(
      ActionMenuItem(
        value: "refresh",
        icon: Icons.refresh,
        textKey: "refresh",
        onPressed: _refreshMessagesWithSkeleton,
      ),
    );

    // Profile option - show when other user ID is available
    if (!_isGroupChat && otherUserId != null) {
      items.add(
        ActionMenuItem(
          value: "profile",
          icon: Icons.person,
          textKey: "profile_interlocutor",
          onPressed: _navigateToUserProfile,
          iconWidget: _buildProfileMenuIcon(),
        ),
      );
    }

    // View listing/group option - only show when listingId is available
    if (widget.listingId != null) {
      items.add(
        ActionMenuItem(
          value: "view_listing",
          icon: Icons.article,
          textKey: _isGroupChat ? "view_group" : "view_listing",
          onPressed: _navigateToListingDetail,
        ),
      );
    }

    // View task option - the gig-conversation analogue of "View listing".
    // Mutually exclusive with the listing branch above in practice (a
    // conversation belongs to exactly one context), but we don't enforce
    // that here so future contexts (gig_offer/gig_booking) can co-exist.
    if (widget.gigRequestId != null) {
      items.add(
        ActionMenuItem(
          value: "view_task",
          icon: Icons.assignment_outlined,
          textKey: "gigs_request_detail_title",
          onPressed: _navigateToGigRequestDetail,
        ),
      );
    }

    // Translation controls. Both items are always visible: it's hard to know
    // up front whether a chat will contain translations (incoming async), and
    // hiding them until a translation arrives makes the controls feel
    // unreliable. Tapping with no translations is a harmless no-op.
    items.add(
      ActionMenuItem(
        value: "translate_to",
        icon: Icons.translate,
        textKey: "chat_menu_translate_to",
        onPressed: _openTranslateLanguagePicker,
      ),
    );
    items.add(
      ActionMenuItem(
        value: "show_original",
        icon: _showOriginalAll ? Icons.translate : Icons.text_fields,
        textKey: _showOriginalAll
            ? "chat_menu_show_translated"
            : "chat_menu_show_original",
        onPressed: _toggleShowOriginalAll,
      ),
    );

    // Complain option - only show when listingId is available
    if (widget.listingId != null) {
      items.add(
        ActionMenuItem(
          value: "complain",
          icon: CupertinoIcons.exclamationmark_circle_fill,
          textKey: "complain",
          onPressed: _createComplaint,
          iconColor: Colors.red,
          textColor: Colors.red,
        ),
      );
    }

    if (_isAdmin) {
      items.add(
        ActionMenuItem(
          value: "admin_delete_conversation",
          icon: Icons.delete_forever_outlined,
          textKey: "admin_delete_conversation",
          onPressed: _showAdminDeleteConversationConfirmation,
          iconColor: Colors.red,
          textColor: Colors.red,
          enabled: !_adminDeleteBusy,
          labelFontWeight: FontWeight.w600,
        ),
      );
    }

    return items;
  }

  void _showAdminDeleteConversationConfirmation() {
    unawaited(
      DestructiveActionFlow.runAfterDeleteConfirmed(
        context: context,
        titleKey: "admin_delete_conversation",
        messageKey: "admin_delete_conversation_confirmation",
        errorToastKey: "admin_delete_conversation_error",
        onConfirmed: () async {
          if (_adminDeleteBusy || !mounted) return;
          setState(() => _adminDeleteBusy = true);
          try {
            await getIt<IMessagingService>()
                .deleteConversation(widget.conversationId);
            if (!mounted) return;
            ToastReporting.successKey(
              context,
              "admin_delete_conversation_success",
            );
            context.read<ConversationsBloc>().add(const ConversationsRefresh());
            Navigator.of(context).pop();
          } finally {
            if (mounted) setState(() => _adminDeleteBusy = false);
          }
        },
      ),
    );
  }
}

class _ComposerReplyPreview extends StatelessWidget {
  const _ComposerReplyPreview({
    required this.senderName,
    required this.preview,
    required this.isCurrentUser,
    required this.blendWithGlassBackdrop,
    required this.onCancel,
    this.avatarUrl,
    this.initials,
  });

  final String senderName;
  final String preview;
  final String? avatarUrl;
  final String? initials;
  final bool isCurrentUser;
  final bool blendWithGlassBackdrop;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final accent = theme.colorScheme.primary;
    final borderColor = themeState.borderColor;
    final isDark = theme.brightness == Brightness.dark;
    final replyLabelColor =
        themeState.isLightTheme ? Colors.black : Colors.white;
    final tileTint = theme.colorScheme.surface;
    final tileFill = blendWithGlassBackdrop
        ? tileTint.withValues(alpha: isDark ? 0.18 : 0.34)
        : tileTint.withValues(alpha: isDark ? 0.78 : 0.86);
    final enableBackdropBlur = LiquidGlassRendering.effectsEnabled(context);

    Widget maybeBlurReplyPreview(Widget child) {
      return LiquidGlassRendering.backdropBlur(
        enabled: enableBackdropBlur,
        sigma: blendWithGlassBackdrop ? 12 : 6,
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: blendWithGlassBackdrop
            ? Colors.transparent
            : themeState.chatInputBarBackgroundColor,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: maybeBlurReplyPreview(
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tileFill,
                  Color.lerp(tileFill, accent, isDark ? 0.12 : 0.06)!,
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 4, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ReplyOwnerAvatar(
                    avatarUrl: avatarUrl,
                    initials: initials,
                    isCurrentUser: isCurrentUser,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 3,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            ThemeIcon(
                              Icons.reply_rounded,
                              size: 15,
                              color: replyLabelColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                L10n.getWithParams(
                                  "chat_replying_to",
                                  params: {"name": senderName},
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: replyLabelColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.74,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: L10n.get("chat_reply_cancel"),
                    onPressed: onCancel,
                    icon: const ThemeIcon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyOwnerAvatar extends StatelessWidget {
  const _ReplyOwnerAvatar({
    required this.isCurrentUser,
    this.avatarUrl,
    this.initials,
    this.size = 24,
  });

  final bool isCurrentUser;
  final String? avatarUrl;
  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = resolveAvatarUrl(avatarUrl);
    final theme = Theme.of(context);
    final hasInitials = initials != null && initials!.trim().isNotEmpty;
    final base = isCurrentUser
        ? Color.lerp(
            theme.colorScheme.surface,
            theme.colorScheme.onSurface,
            0.06,
          )!
        : Color.lerp(
            theme.colorScheme.surface,
            theme.colorScheme.onSurface,
            0.02,
          )!;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: base,
      child: hasInitials
          ? Text(
              initials!.trim(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
              ),
            )
          : ThemeIcon(
              Icons.person_rounded,
              size: size * 0.56,
              color: theme.colorScheme.onSurface,
            ),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: resolvedAvatarUrl == null
            ? fallback
            : NetworkAvatarImage(
                imageUrl: resolvedAvatarUrl,
                size: size,
                fallback: fallback,
              ),
      ),
    );
  }
}

class _ReplySwipeWrapper extends StatefulWidget {
  const _ReplySwipeWrapper({
    required this.child,
    required this.onReply,
  });

  final Widget child;
  final VoidCallback onReply;

  @override
  State<_ReplySwipeWrapper> createState() => _ReplySwipeWrapperState();
}

class _ReplySwipeWrapperState extends State<_ReplySwipeWrapper> {
  static const double _triggerDistance = 54;
  static const double _maxOffset = 82;

  double _dragOffset = 0;
  bool _animateBack = false;
  bool _armed = false;

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final next = (_dragOffset + delta).clamp(-_maxOffset, _maxOffset);
    final armed = next.abs() >= _triggerDistance;
    if (armed && !_armed) {
      HapticFeedbackUtils.lightImpact();
    }
    setState(() {
      _animateBack = false;
      _dragOffset = next.toDouble();
      _armed = armed;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldReply =
        _dragOffset.abs() >= _triggerDistance || velocity.abs() >= 650;
    setState(() {
      _animateBack = true;
      _dragOffset = 0;
      _armed = false;
    });
    if (shouldReply) {
      widget.onReply();
    }
  }

  void _handleDragCancel() {
    setState(() {
      _animateBack = true;
      _dragOffset = 0;
      _armed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction = _dragOffset == 0 ? 1.0 : _dragOffset.sign;
    final progress = (_dragOffset.abs() / _triggerDistance).clamp(0.0, 1.0);
    final iconAlignment = direction < 0
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart;
    final iconPadding = direction < 0
        ? const EdgeInsetsDirectional.only(end: 20)
        : const EdgeInsetsDirectional.only(start: 20);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragCancel: _handleDragCancel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: iconAlignment,
                child: Padding(
                  padding: iconPadding,
                  child: Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      scale: 0.82 + (0.18 * progress),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.14 + (0.10 * progress),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ThemeIcon(
                          Icons.reply_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: _animateBack
                ? const Duration(milliseconds: 180)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _GroupParticipantsFooterPill extends StatelessWidget {
  const _GroupParticipantsFooterPill({
    required this.participants,
    required this.currentUserId,
    required this.semanticsLabel,
    required this.showDot,
    required this.dotTrigger,
    required this.onTap,
  });

  final List<ConversationMemberSummary> participants;
  final int? currentUserId;
  final String semanticsLabel;
  final bool showDot;
  final int dotTrigger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : theme.colorScheme.onSurface;
    final radius = BorderRadius.circular(999);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Semantics(
          button: true,
          enabled: onTap != null,
          label: semanticsLabel,
          child: Tooltip(
            message: semanticsLabel,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Ink(
                  height: 38,
                  padding: const EdgeInsetsDirectional.only(start: 8, end: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(
                      alpha: ThemeState().isBlueTheme ? 0.16 : 0.10,
                    ),
                    borderRadius: radius,
                    border: isDark
                        ? Border.all(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.10,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatParticipantAvatarStack(
                        participants: participants,
                        currentUserId: currentUserId,
                        avatarSize: 22,
                        maxVisible: 4,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        semanticsLabel,
                        style: TextStyle(
                          color: foreground.withValues(
                              alpha: onTap == null ? 0.55 : 1),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            right: 1,
            top: -2,
            child: PulseThenBlinkDotWidget(
              trigger: dotTrigger,
              color: ThemeState().unreadIndicatorColor,
              size: 10,
              blinkDuration: const Duration(milliseconds: 750),
              borderColor: theme.colorScheme.surface,
              borderWidth: 1.5,
            ),
          ),
      ],
    );
  }
}

/// Confirms invite-to-book amounts for gig task chats from the ChatScreen app bar.
class _InviteProviderBookingDialog extends StatefulWidget {
  const _InviteProviderBookingDialog({
    required this.snackParentContext,
    required this.gigRequest,
    required this.providerUserId,
  });

  final BuildContext snackParentContext;
  final GigRequest gigRequest;
  final int providerUserId;

  @override
  State<_InviteProviderBookingDialog> createState() =>
      _InviteProviderBookingDialogState();
}

class _InviteProviderBookingDialogState
    extends State<_InviteProviderBookingDialog> {
  /// Wheel slots are `index * step` (0 … [_inviteAmountSpinnerMaxIndex] * step).
  /// At 1.000 UZS per slot, the wheel reaches 10M UZS; higher amounts can still
  /// be typed.
  static const int _inviteAmountSpinnerMaxIndex = 10000;

  late final TextEditingController _amountController;
  late final FixedExtentScrollController _amountSpinnerController;
  late int _amountSpinnerSelectedIndex;
  bool _sending = false;
  bool _inviteAmountWheelMute = false;

  /// Normalized code from [GigRequest.currencyCode] — the same column set when
  /// the task was created (`POST /gigs/requests`). The dialog is only shown
  /// after [IGigService.getRequest], so this matches the posted gig price row.
  String get _taskCurrencyCode {
    final raw = widget.gigRequest.currencyCode.trim();
    if (raw.isEmpty) return "UZS";
    return raw.toUpperCase();
  }

  bool get _needsExplicitAmount =>
      widget.gigRequest.budgetType == GigRequestBudgetType.open ||
      widget.gigRequest.budgetAmount == null ||
      widget.gigRequest.budgetAmount! <= 0;

  @override
  void initState() {
    super.initState();
    final amt = widget.gigRequest.budgetAmount;
    final initial =
        amt != null && amt > 0 ? IntFormatUtils.withDotThousands(amt) : "";
    _amountController = TextEditingController(text: initial);
    final step = CurrencyDisplayUtils.amountNudgeStep(_taskCurrencyCode);
    final parsed = IntFormatUtils.parseAmountInput(initial);
    final initialSlot = _spinnerIndexForAmount(parsed, step);
    _amountSpinnerController = FixedExtentScrollController(
      initialItem: initialSlot,
    );
    _amountSpinnerSelectedIndex = initialSlot;
    _amountController.addListener(_syncInviteAmountSpinnerFromText);
  }

  int _spinnerIndexForAmount(int? parsedAmount, int step) {
    if (parsedAmount == null || parsedAmount <= 0 || step <= 0) return 0;
    return (parsedAmount / step).round().clamp(0, _inviteAmountSpinnerMaxIndex);
  }

  void _syncInviteAmountSpinnerFromText() {
    if (_inviteAmountWheelMute || _sending) return;
    if (!_amountSpinnerController.hasClients) return;
    final step = CurrencyDisplayUtils.amountNudgeStep(_taskCurrencyCode);
    final parsed = IntFormatUtils.parseAmountInput(_amountController.text);
    final idx = _spinnerIndexForAmount(parsed, step);
    final current = _amountSpinnerController.selectedItem;
    if (current == idx) {
      if (_amountSpinnerSelectedIndex != idx) {
        setState(() => _amountSpinnerSelectedIndex = idx);
      }
      return;
    }
    _inviteAmountWheelMute = true;
    _amountSpinnerController.jumpToItem(idx);
    _inviteAmountWheelMute = false;
    setState(() => _amountSpinnerSelectedIndex = idx);
  }

  void _onInviteAmountSpinnerIndexChanged(int index) {
    if (_sending) return;
    if (_inviteAmountWheelMute) return;
    setState(() => _amountSpinnerSelectedIndex = index);
    final step = CurrencyDisplayUtils.amountNudgeStep(_taskCurrencyCode);
    final amount = index * step;
    final text = amount <= 0 ? "" : IntFormatUtils.withDotThousands(amount);
    SendSoundUtils.playCupertinoWheelSound();
    _inviteAmountWheelMute = true;
    _amountController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _inviteAmountWheelMute = false;
  }

  @override
  void dispose() {
    _amountController.removeListener(_syncInviteAmountSpinnerFromText);
    _amountController.dispose();
    _amountSpinnerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;

    final parsed = IntFormatUtils.parseAmountInput(_amountController.text);
    if (_needsExplicitAmount && (parsed == null || parsed <= 0)) {
      ToastTheme.showError(
        widget.snackParentContext,
        message: L10n.get("gigs_invite_provider_amount_required"),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await getIt<IGigService>().inviteProviderFromRequest(
        requestId: widget.gigRequest.id,
        providerUserId: widget.providerUserId,
        agreedAmount: parsed,
        currencyCode: _taskCurrencyCode,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ToastTheme.showSuccess(
          widget.snackParentContext,
          message: L10n.get("gigs_invite_provider_success_toast"),
        );
      }
    } catch (_) {
      if (mounted) {
        ToastTheme.showError(
          widget.snackParentContext,
          message: L10n.get("gigs_invite_provider_failed_toast"),
        );
      }
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final listingFieldStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ThemeState().isLightTheme ? Colors.black : scheme.onSurfaceVariant,
    );
    final listingHintStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: theme.brightness == Brightness.dark
          ? scheme.onSurfaceVariant.withValues(alpha: 0.7)
          : Colors.grey[400]!,
    );
    final bodyStyle = TextStyle(
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface.withValues(alpha: 0.92),
    );
    final dividerColor = scheme.onSurface.withValues(alpha: 0.18);
    final currencyChipColor =
        ThemeState().isLightTheme ? Colors.black : scheme.onSurface;
    final currencyCode = _taskCurrencyCode;
    final step = CurrencyDisplayUtils.amountNudgeStep(currencyCode);
    final plateDecoration = UydoshPlateFieldDecoration.forHint(
      context,
      hintText: L10n.get("gigs_invite_provider_dialog_field_hint"),
      hintStyle: listingHintStyle,
      contentPadding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
    );

    return UydoshAlertDialog(
      scrollable: true,
      title: Text(
        L10n.get("gigs_invite_provider_dialog_title"),
        style: listingFieldStyle,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            L10n.get("gigs_invite_provider_dialog_body"),
            style: bodyStyle,
          ),
          const SizedBox(height: 16),
          LabeledFieldOverlay(
            label: L10n.get("gigs_post_request_field_amount"),
            child: IgnorePointer(
              ignoring: _sending,
              child: Opacity(
                opacity: _sending ? 0.45 : 1,
                child: WheelPickerPlateContainer(
                  theme: theme,
                  child: SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  CurrencyDisplayUtils.flagEmoji(currencyCode),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currencyCode,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: currencyChipColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 1,
                            height: 44,
                            color: dividerColor,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: false,
                                  signed: false,
                                ),
                                inputFormatters: [
                                  DotThousandsDigitsInputFormatter(),
                                ],
                                decoration: plateDecoration.copyWith(
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    10,
                                    12,
                                    6,
                                    12,
                                  ),
                                ),
                                style: listingFieldStyle,
                                textAlignVertical: TextAlignVertical.center,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 1,
                            height: 52,
                            color: dividerColor,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              Expanded(
                                child: CupertinoPicker(
                                  backgroundColor: Colors.transparent,
                                  changeReportingBehavior:
                                      ChangeReportingBehavior.onScrollEnd,
                                  scrollController: _amountSpinnerController,
                                  itemExtent: 40,
                                  onSelectedItemChanged:
                                      _onInviteAmountSpinnerIndexChanged,
                                  children: List.generate(
                                    _inviteAmountSpinnerMaxIndex + 1,
                                    (i) {
                                      final n = i * step;
                                      final isFocusedSlot =
                                          i == _amountSpinnerSelectedIndex;
                                      // Omit the centered label so the wheel
                                      // does not duplicate the text field; keep
                                      // neighbors as drag context only.
                                      final label = isFocusedSlot
                                          ? ""
                                          : (n <= 0
                                              ? "—"
                                              : IntFormatUtils.withDotThousands(
                                                  n));
                                      return Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: ThemeState().isLightTheme
                                                ? Colors.black
                                                : scheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: 24,
                                decoration: BoxDecoration(
                                  color: scheme.outline.withValues(alpha: 0.1),
                                  borderRadius: ThreeDSurfaceStyle
                                      .wheelPickerPlateArrowStripBorderRadius,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ThemeIcon(
                                      Icons.keyboard_arrow_up,
                                      color: scheme.onSurfaceVariant,
                                      size: 16,
                                    ),
                                    ThemeIcon(
                                      Icons.keyboard_arrow_down,
                                      color: scheme.onSurfaceVariant,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: scheme.onSurfaceVariant,
          ),
          child: Text(L10n.get("cancel")),
        ),
        TextButton(
          onPressed: _sending ? null : () => unawaited(_submit()),
          child: _sending
              ? UydoshInlineSpinner(color: scheme.primary, dimension: 20)
              : Text(L10n.get("gigs_invite_provider_confirm")),
        ),
      ],
    );
  }
}
