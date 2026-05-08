import "dart:async";
import "dart:ui" show ImageFilter;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/scam_trigger.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/models/message_translation.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/complaint/create_complaint_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/screens/profile/ai_premium_placeholder_screen.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_header.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_input.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_messages_skeleton.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_security_ribbon.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_safety_warning_ribbon.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/message_bubble.dart";
import "package:uy_dosh/presentation/widgets/chat/message_grouping_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/quick_questions_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/suspicious_message_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/gemini_quota_exceeded_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/labeled_field_overlay.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class ChatScreen extends StatefulWidget {
  /// Root [Navigator] route name for this conversation. Push with
  /// `RouteSettings(name: routeName(conversationId))` so deep links / push
  /// handling can pop back to an existing chat instead of stacking another.
  static String routeName(int conversationId) => "/chat/$conversationId";

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
  Timer? _incomingRefreshDebounce;
  late final VoidCallback _unreadMessagesListener;
  int _lastObservedUnreadCount = 0;
  int? _lastIncomingSoundMessageId;
  ListingAiQuotaSnapshot? _listingAiQuotaRibbon;

  static const Duration _minSkeletonDuration = Duration(milliseconds: 450);

  /// Reserve space so the last messages clear the stacked glass composer (blue theme).
  static const double _glassComposerEstimatedHeight = 196;

  /// Memoized output of [MessageGroupingUtils.groupMessagesAsItems] — invalidated when
  /// [messages] reference, [_currentUserId], or [_newMessageIds] meaningfully change.
  List<MessageGroupListItem>? _cachedGroupedItems;
  List<Message>? _groupedCacheMessagesRef;
  int? _groupedCacheCurrentUserId;
  int _groupedCacheNewMessageIdsFingerprint = 0;

  int _fingerprintNewMessageIds(Set<int> ids) {
    if (ids.isEmpty) return 0;
    final sorted = ids.toList()..sort();
    return Object.hashAll(sorted);
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
    _scrollController = ScrollController();
    _messageFocusNode = FocusNode(onKeyEvent: _messageComposerOnKeyEvent);
    _peerAvatarUrl = widget.otherUserAvatar;

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

  @override
  void dispose() {
    if (UnreadMessagesState().activeConversationId == widget.conversationId) {
      UnreadMessagesState().setActiveConversationId(null);
    }
    UnreadMessagesState().removeListener(_unreadMessagesListener);
    _incomingRefreshDebounce?.cancel();
    _messageController.dispose();
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
      _refreshPeerAvatarIfPossible();
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
    final picked = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Text(
                    L10n.get("chat_translate_picker_title"),
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                ),
                _buildTranslateLanguageTile(
                  sheetContext: sheetContext,
                  label: L10n.get("chat_translate_picker_auto"),
                  selected: _targetLanguageOverride == null,
                  onTap: () => Navigator.of(sheetContext).pop(""),
                ),
                _buildTranslateLanguageTile(
                  sheetContext: sheetContext,
                  label: LanguageDisplayHelper.getLanguageDisplayName("uz"),
                  selected: _targetLanguageOverride == "uz",
                  onTap: () => Navigator.of(sheetContext).pop("uz"),
                ),
                _buildTranslateLanguageTile(
                  sheetContext: sheetContext,
                  label: LanguageDisplayHelper.getLanguageDisplayName("ru"),
                  selected: _targetLanguageOverride == "ru",
                  onTap: () => Navigator.of(sheetContext).pop("ru"),
                ),
                _buildTranslateLanguageTile(
                  sheetContext: sheetContext,
                  label: LanguageDisplayHelper.getLanguageDisplayName("en"),
                  selected: _targetLanguageOverride == "en",
                  onTap: () => Navigator.of(sheetContext).pop("en"),
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

  Widget _buildTranslateLanguageTile({
    required BuildContext sheetContext,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? ThemeIcon(
              Icons.check,
              size: 20,
              color: Theme.of(sheetContext).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
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
    final name = widget.otherUserName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return L10n.get("chat");
  }

  EdgeInsets _messagesListPadding(BuildContext context) {
    const base = EdgeInsets.all(16);
    if (!ThemeState().isBlueTheme) return base;
    final extra = _glassComposerEstimatedHeight +
        MediaQuery.viewPaddingOf(context).bottom;
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
          messagesMarkedAsRead: (conversationId, markedCount) {},
          error: (message) {
            setState(() {
              _isSendingMessage = false;
            });
            if (message.contains("USER_BLOCKED")) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      },
      child: ChatMessageInput(
        controller: _messageController,
        focusNode: _messageFocusNode,
        onSend: _sendMessage,
        isSendingMessage: _isSendingMessage,
        blendWithGlassBackdrop: blendWithGlassBackdrop,
      ),
    );
  }

  Widget _blueGlassComposerPanel() {
    const topRadius = BorderRadius.vertical(top: Radius.circular(20));
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableGlass =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;
    return ClipRRect(
      borderRadius: topRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: enableGlass ? 18 : 0,
          sigmaY: enableGlass ? 18 : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: topRadius,
            color: BlueThemeColors.background.withValues(alpha: 0.44),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _chatComposerWithListener(blendWithGlassBackdrop: true),
              QuickQuestionsWidget(
                onQuestionTap: _onQuestionTap,
                listingTypeId: widget.listingTypeId,
                isViewerServiceOfferer: _isViewerServiceOfferer,
                blendWithGlassBackdrop: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _chatLeadingRibbonWidgets() {
    return [
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
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
        ],
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
          extendBodyBehindAppBar: themeState.isBlueTheme,
          backgroundColor: backgroundColor,
          appBar: ChatHeader(
            displayName: _getPeerDisplayName(context),
            subtitle: _chatHeaderSubtitle(),
            peerAvatarUrl: _peerAvatarUrl,
            peerInitials: widget.otherUserInitials,
            onPeerAvatarTap: _navigateToUserProfile,
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
            child: themeState.isBlueTheme
                ? Stack(
                    fit: StackFit.expand,
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
                      _chatComposerWithListener(
                        blendWithGlassBackdrop: false,
                      ),
                      QuickQuestionsWidget(
                        onQuestionTap: _onQuestionTap,
                        listingTypeId: widget.listingTypeId,
                        isViewerServiceOfferer: _isViewerServiceOfferer,
                      ),
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

    return CommonListView(
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
          DateHeaderListItem(:final date) => DateHeaderWidget(
              dateString: MessageGroupingUtils.formatDateHeader(date, context),
              date: date,
            ),
          MessageListItem(
            :final message,
            :final isCurrentUser,
            :final isLatest,
          ) =>
            MessageBubble(
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
              otherUserInitials: widget.otherUserInitials,
              otherUserAvatarUrl: _peerAvatarUrl,
              translation: _translationsById[message.id],
              isTranslating: _translationInFlightIds.contains(message.id),
              // The global "Show original messages" mode flips the default
              // for every translated bubble; the per-message set acts as
              // exceptions so taps on the in-bubble toggle still work.
              showOriginal: _showOriginalAll ^
                  _showOriginalMessageIds.contains(message.id),
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
            ),
        };
      },
      showRefreshIndicator: true,
      onRefresh: () async {
        await _refreshMessagesWithSkeleton();
      },
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

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSendingMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    _messageController.clear();

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
          SendMessage(conversationId: widget.conversationId, content: content),
        );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
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
    HapticFeedbackUtils.selection();
    if (widget.gigRequestDetailRouteBelow) {
      Navigator.of(context).pop();
      return;
    }
    context.pushGigRequestDetail(id);
  }

  void _navigateToUserProfile() {
    // Prefer widget.otherUserId, fall back to deriving from messages
    final otherUserId = widget.otherUserId ?? _getOtherUserIdFromMessages();
    if (otherUserId != null) {
      HapticFeedbackUtils.selection();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) =>
                ListingOwnerProfileBloc(getIt<IUserProfileService>()),
            child: ListingOwnerProfileScreen(userId: otherUserId),
          ),
        ),
      );
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
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: resolvedAvatarUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          memCacheWidth: 48,
          memCacheHeight: 48,
          placeholder: (context, url) =>
              const ThemeIcon(Icons.person, size: 20),
          errorWidget: (context, url, error) =>
              const ThemeIcon(Icons.person, size: 20),
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
    if (otherUserId != null) {
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

    // View listing option - only show when listingId is available
    if (widget.listingId != null) {
      items.add(
        ActionMenuItem(
          value: "view_listing",
          icon: Icons.article,
          textKey: "view_listing",
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
        ),
      );
    }

    return items;
  }

  void _showAdminDeleteConversationConfirmation() {
    CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "admin_delete_conversation",
      messageKey: "admin_delete_conversation_confirmation",
      onConfirm: () => _performAdminDeleteConversation(),
    );
  }

  Future<void> _performAdminDeleteConversation() async {
    if (_adminDeleteBusy || !mounted) return;
    setState(() => _adminDeleteBusy = true);
    try {
      await getIt<IMessagingService>()
          .deleteConversation(widget.conversationId);
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_delete_conversation_success"),
      );
      context.read<MessagingBloc>().add(RefreshConversations());
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("admin_delete_conversation_error"),
      );
    } finally {
      if (mounted) setState(() => _adminDeleteBusy = false);
    }
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
    final plateDecoration = InputDecoration(
      hintText: L10n.get("gigs_invite_provider_dialog_field_hint"),
      hintStyle: listingHintStyle,
      border: OutlineInputBorder(
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
    );

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      title: Text(
        L10n.get("gigs_invite_provider_dialog_title"),
        style: listingFieldStyle,
      ),
      content: SingleChildScrollView(
        child: Column(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    CurrencyDisplayUtils.flagEmoji(
                                        currencyCode),
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
                                                : IntFormatUtils
                                                    .withDotThousands(n));
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
                                    color:
                                        scheme.outline.withValues(alpha: 0.1),
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
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                )
              : Text(L10n.get("gigs_invite_provider_confirm")),
        ),
      ],
    );
  }
}
