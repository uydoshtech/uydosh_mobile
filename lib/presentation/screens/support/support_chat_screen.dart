import "dart:async";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/support_unread_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/support_chat_message.dart";
import "package:uy_dosh/domain/models/support_chat_thread.dart";
import "package:uy_dosh/domain/services/support_chat_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final List<SupportChatThread> _threads = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _creatingThread = false;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "support_chat_list");
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    if (_isLoading) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final response = await getIt<ISupportChatService>().getUserThreads(
        page: 1,
        limit: 50,
      );

      setStateIfMounted(() {
        _threads.clear();
        _threads.addAll(response.threads);
        _isLoading = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewThread() async {
    if (_creatingThread) return;

    setState(() => _creatingThread = true);

    try {
      final thread = await getIt<ISupportChatService>().createThread();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => _UserSupportChatThreadScreen(thread: thread),
        ),
      ).then((_) => _fetchThreads());
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
    } finally {
      setStateIfMounted(() => _creatingThread = false);
    }
  }

  void _openThread(SupportChatThread thread) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _UserSupportChatThreadScreen(thread: thread),
      ),
    ).then((_) => _fetchThreads());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        return Scaffold(
          backgroundColor: themeState.backgroundColor,
          appBar: UydoshAppBar(
            leading: ThreeDAppBarIconButton.backLeading(context),
            title: Text(
              L10n.get("contact_support_title"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeState.textColor,
              ),
            ),
            backgroundColor: themeState.appBarBackgroundColor,
            foregroundColor: themeState.textColor,
          ),
          body: _isLoading
              ? CenteredHouseLoadingIndicator(
                  text: L10n.get("contact_support_loading"),
                )
              : _hasError
                  ? _buildErrorState(context)
                  : _buildContent(context),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemeIcon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              L10n.get("contact_support_error"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () {
                HapticFeedbackUtils.impact();
                _fetchThreads();
              },
              child: Text(L10n.get("retry")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final itemCount = _threads.isEmpty ? 1 : 1 + _threads.length;
    return UydoshRefreshIndicator(
      onRefresh: _fetchThreads,
      child: CommonListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemSpacing: 12,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (_threads.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Column(
                children: [
                  ThemeIcon(
                    Icons.support_agent,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    L10n.get("contact_support_empty"),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: ThemeState().secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _buildNewThreadButton(context),
                ],
              ),
            );
          }
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildNewThreadButton(context),
            );
          }
          final thread = _threads[index - 1];
          return _buildThreadCard(context, thread);
        },
      ),
    );
  }

  Widget _buildNewThreadButton(BuildContext context) {
    final ts = ThemeState();
    return SizedBox(
      width: double.infinity,
      child: ThreeDPillButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        backgroundColor: ts.cardColor,
        onPressed: _creatingThread
            ? null
            : () {
                HapticFeedbackUtils.impact();
                _createNewThread();
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_creatingThread)
              UydoshInlineSpinner(color: ts.textColor, dimension: 22)
            else ...[
              ThemeIcon(Icons.add, color: ts.textColor, size: 22),
              const SizedBox(width: 10),
              Text(
                L10n.get("contact_support_new"),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ts.textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThreadCard(BuildContext context, SupportChatThread thread) {
    final ts = ThemeState();
    const tileRadius = BorderRadius.all(Radius.circular(16));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: tileRadius,
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          ts.cardColor,
        ),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: tileRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openThread(thread),
          borderRadius: tileRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        thread.displayTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ts.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusChip(context, thread.status),
                  ],
                ),
                if (thread.lastMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    thread.lastMessage!.body,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: ts.secondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: thread.lastMessage != null ? 10 : 8),
                Text(
                  AppDateUtils.formatRelativePastDate(thread.updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: ts.secondaryTextColor.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final isOpen = status == "open";
    final color = isOpen ? Colors.orange : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOpen
            ? L10n.get("admin_support_chat_status_open")
            : L10n.get("admin_support_chat_status_closed"),
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

}

class _UserSupportChatThreadScreen extends StatefulWidget {
  const _UserSupportChatThreadScreen({required this.thread});

  final SupportChatThread thread;

  @override
  State<_UserSupportChatThreadScreen> createState() =>
      _UserSupportChatThreadScreenState();
}

class _UserSupportChatThreadScreenState
    extends State<_UserSupportChatThreadScreen> {
  final List<SupportChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isSending = false;
  String? _currentUserInitials;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "support_chat_thread");
    _loadMessages();
    _loadCurrentUserInitials();
  }

  Future<void> _loadCurrentUserInitials() async {
    try {
      final profile = await getIt<IUserProfileService>().getCurrentUserProfile();
      setStateIfMounted(() {
        _currentUserInitials = StringUtils.extractInitials(profile.name);
      });
    } catch (_) {
      // Ignore - avatar will show person icon fallback
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final response = await getIt<ISupportChatService>().getUserMessages(
        widget.thread.id,
        page: 1,
        limit: 100,
      );
      setStateIfMounted(() {
        _messages.clear();
        _messages.addAll(response.messages);
        _isLoading = false;
      });
      if (_messages.isNotEmpty) {
        unawaited(
          SupportUnreadState().markThreadSeen(
            widget.thread.id,
            _messages.last.createdAt,
          ),
        );
      }
      _scrollToBottom();
    } catch (e) {
      setStateIfMounted(() => _isLoading = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _messages.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final body = _messageController.text.trim();
    if (body.isEmpty || _isSending) return;

    HapticFeedbackUtils.impact();
    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final message = await getIt<ISupportChatService>().userSendMessage(
        widget.thread.id,
        body,
      );
      if (!mounted) return;
      if (message != null) {
        setState(() {
          _messages.add(SupportChatMessage(
            id: message.id,
            threadId: message.threadId,
            senderUserId: message.senderUserId,
            body: message.body,
            createdAt: message.createdAt,
            sender: message.sender,
            forceFromSupport: false,
          ));
        });
        unawaited(
          SupportUnreadState().markThreadSeen(
            widget.thread.id,
            message.createdAt,
          ),
        );
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
      _messageController.text = body;
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        return Scaffold(
          backgroundColor: themeState.backgroundColor,
          appBar: UydoshAppBar(
            leading: ThreeDAppBarIconButton.backLeading(context),
            title: Text(
              L10n.get("contact_support_title"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeState.textColor,
              ),
            ),
            backgroundColor: themeState.appBarBackgroundColor,
            foregroundColor: themeState.textColor,
          ),
          body: Column(
            children: [
              Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          L10n.get("admin_support_chat_no_messages"),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _buildMessageBubble(context, msg);
                        },
                      ),
              ),
              if (widget.thread.status == "open")
                _buildInputBar(context)
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    L10n.get("admin_support_chat_thread_closed"),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, SupportChatMessage msg) {
    final isUser = !msg.isFromSupport;
    final themeState = ThemeState();
    final textColor = isUser
        ? Colors.black
        : (themeState.isBlueTheme ? Colors.white : Colors.black);
    final supportInitials = msg.sender != null && !isUser
        ? StringUtils.extractInitials(msg.sender!.name)
        : null;

    return ChatMessageRow(
      isFromCurrentUser: isUser,
      leftAvatarInitials: supportInitials,
      rightAvatarInitials: _currentUserInitials,
      bubbleChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg.body,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(
                Icons.access_time,
                size: 10,
                color: textColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 2),
              Text(
                _formatTime(msg.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 4),
                ThemeIcon(
                  Icons.check,
                  size: 14,
                  color: textColor.withValues(alpha: 0.45),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final scheme = Theme.of(context).colorScheme;
        // `padding.bottom` is often 0 on Flutter web/desktop; keep a minimum gutter.
        final bottomInset = math.max(
          MediaQuery.viewPaddingOf(context).bottom,
          16.0,
        );
        final inputFieldBg = themeState.chatComposerFieldBackground(context);
        final inputFieldTextColor =
            themeState.chatComposerFieldTextColor(context);
        final inputFieldHintColor =
            themeState.chatComposerFieldHintColor(context);
        final sendButtonBase = Color.lerp(
          scheme.surface,
          scheme.onSurface,
          themeState.isBlueTheme ? 0.06 : 0.02,
        )!;
        return Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
          decoration: BoxDecoration(
            color: themeState.chatInputBarBackgroundColor,
            border: Border(top: BorderSide(color: themeState.borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ThreeDTextField(
                  controller: _messageController,
                  hintText: L10n.get("contact_support_message_hint"),
                  backgroundColor: inputFieldBg,
                  textColor: inputFieldTextColor,
                  hintColor: inputFieldHintColor,
                  cursorColor: inputFieldTextColor,
                  borderRadius:
                      themeState.isBlueTheme
                          ? ThreeDSurfaceStyle.wheelPickerPlateRadius
                          : const BorderRadius.all(Radius.circular(24)),
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              ThreeDPillButton(
                onPressed: _isSending ? null : _sendMessage,
                padding: const EdgeInsets.all(10),
                backgroundColor: sendButtonBase,
                borderSide: BorderSide(
                  color: scheme.onSurface.withValues(alpha: 0.06),
                  width: 1,
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child:
                        _isSending
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  themeState.sendButtonColor,
                                ),
                              ),
                            )
                            : ThemeIcon(
                              Icons.send,
                              color: themeState.sendButtonColor,
                            ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
