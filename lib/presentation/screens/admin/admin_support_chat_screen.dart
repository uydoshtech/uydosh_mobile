import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/support_chat_message.dart";
import "package:uy_dosh/domain/models/support_chat_thread.dart";
import "package:uy_dosh/domain/services/support_chat_service.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class AdminSupportChatScreen extends StatefulWidget {
  const AdminSupportChatScreen({super.key});

  @override
  State<AdminSupportChatScreen> createState() => _AdminSupportChatScreenState();
}

class _AdminSupportChatScreenState extends State<AdminSupportChatScreen> {
  final List<SupportChatThread> _threads = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _pageNumber = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchThreads();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _fetchThreads(loadMore: true);
    }
  }

  Future<void> _fetchThreads({bool loadMore = false}) async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response = await getIt<ISupportChatService>().getThreads(
        page: loadMore ? _pageNumber : 1,
        limit: _pageSize,
        status: _statusFilter,
      );

      if (!mounted) return;
      setState(() {
        if (loadMore) {
          _threads.addAll(response.threads);
        } else {
          _threads.clear();
          _threads.addAll(response.threads);
        }
        _hasMore = response.threads.length >= _pageSize;
        if (_hasMore) {
          _pageNumber = (loadMore ? _pageNumber : 1) + 1;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    _pageNumber = 1;
    _hasMore = true;
    await _fetchThreads();
  }

  void _onStatusFilterChanged(String? status) {
    setState(() => _statusFilter = status);
    _refresh();
  }

  void _openThread(SupportChatThread thread) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AdminSupportChatThreadScreen(thread: thread),
      ),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_support_chat_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(context),
          Expanded(
            child: _isLoading
                ? CenteredHouseLoadingIndicator(
                    text: L10n.get("admin_support_chat_loading"),
                  )
                : _hasError
                    ? _buildErrorState(context)
                    : _buildThreadsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(context, null, "admin_support_chat_filter_all"),
            const SizedBox(width: 8),
            _buildFilterChip(context, "open", "admin_support_chat_filter_open"),
            const SizedBox(width: 8),
            _buildFilterChip(context, "closed", "admin_support_chat_filter_closed"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String? status,
    String labelKey,
  ) {
    final isSelected = _statusFilter == status;
    final isBlueTheme = ThemeState().isBlueTheme;
    final selectedColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = isSelected
        ? selectedColor
        : (isBlueTheme ? BlueThemeColors.card : Colors.grey[200]);
    final borderColor = isSelected
        ? selectedColor
        : (isBlueTheme ? BlueThemeColors.cardBorder : Colors.grey[400]!);
    final textColor = isSelected
        ? Colors.white
        : (isBlueTheme ? BlueThemeColors.textPrimary : Colors.grey[700]!);
    return InkWell(
      onTap: () => _onStatusFilterChanged(status),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Text(
          L10n.get(labelKey),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
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
            L10n.get("admin_support_chat_error"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            child: Text(L10n.get("admin_support_chat_retry")),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadsList(BuildContext context) {
    if (_threads.isEmpty) {
      return Center(
        child: Text(
          L10n.get("admin_support_chat_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _threads.length,
      itemBuilder: (context, index) {
        final thread = _threads[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _openThread(thread),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.displayTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusChip(context, thread.status),
                    ],
                  ),
                  if (thread.user != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      thread.user!.name ?? thread.user!.email ?? "User #${thread.userId}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (thread.lastMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      thread.lastMessage!.body,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (thread.messageCount != null)
                        Text(
                          "${thread.messageCount} ${L10n.get("admin_support_chat_messages")}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        _formatDate(thread.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      showRefreshIndicator: true,
      onRefresh: _refresh,
      showLoadMoreIndicator: _isLoadingMore,
      hasMore: _isLoadingMore,
      loadMoreIndicator: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    if (diff.inDays == 1) return L10n.get("admin_support_chat_yesterday");
    if (diff.inDays < 7) return "${diff.inDays} ${L10n.get("admin_support_chat_days_ago")}";
    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }
}

class _AdminSupportChatThreadScreen extends StatefulWidget {
  const _AdminSupportChatThreadScreen({required this.thread});

  final SupportChatThread thread;

  @override
  State<_AdminSupportChatThreadScreen> createState() =>
      _AdminSupportChatThreadScreenState();
}

class _AdminSupportChatThreadScreenState
    extends State<_AdminSupportChatThreadScreen> {
  final List<SupportChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
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
      final response = await getIt<ISupportChatService>().getMessages(
        widget.thread.id,
        page: 1,
        limit: 100,
      );
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _messages.addAll(response.messages);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final message = await getIt<ISupportChatService>().sendMessage(
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
            forceFromSupport: true,
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
      _messageController.text = body;
    } finally {
      if (!mounted) return;
      setState(() => _isSending = false);
    }
  }

  Future<void> _toggleStatus() async {
    final newStatus = widget.thread.status == "open" ? "closed" : "open";
    try {
      final updated = await getIt<ISupportChatService>().updateThreadStatus(
        widget.thread.id,
        newStatus,
      );
      if (!mounted) return;
      if (updated != null) {
        ToastTheme.showSuccess(
          context,
          message: newStatus == "closed"
              ? L10n.get("admin_support_chat_closed")
              : L10n.get("admin_support_chat_reopened"),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ToastTheme.showError(context, message: e.toString());
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
              widget.thread.displayTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeState.textColor,
              ),
            ),
            backgroundColor: themeState.appBarBackgroundColor,
            foregroundColor: themeState.textColor,
            actions: [
              IconButton(
                icon: ThemeIcon(
                  widget.thread.status == "open" ? Icons.check_circle_outline : Icons.lock_open,
                  color: widget.thread.status == "open" ? Colors.green.shade700 : null,
                ),
                onPressed: _toggleStatus,
                tooltip: widget.thread.status == "open"
                    ? L10n.get("admin_support_chat_close_thread")
                    : L10n.get("admin_support_chat_reopen_thread"),
              ),
            ],
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
    final isSupport = msg.isFromSupport;
    final themeState = ThemeState();
    final textColor = isSupport
        ? Colors.black
        : (themeState.isBlueTheme ? Colors.white : Colors.black);
    final senderInitials = msg.sender != null
        ? StringUtils.extractInitials(msg.sender!.name)
        : null;

    return ChatMessageRow(
      isFromCurrentUser: isSupport,
      leftAvatarInitials: isSupport ? null : senderInitials,
      rightAvatarInitials: isSupport ? senderInitials : null,
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
              if (isSupport) ...[
                const SizedBox(width: 4),
                ThemeIcon(Icons.check, size: 12, color: Colors.green.shade700),
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
        final inputFieldBg = themeState.inputBackgroundColor;
        final inputFieldBrightness = ThemeData.estimateBrightnessForColor(inputFieldBg);
        final inputFieldTextColor =
            inputFieldBrightness == Brightness.dark ? Colors.white : Colors.black;
        final inputFieldHintColor = inputFieldTextColor.withValues(alpha: 0.6);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: themeState.chatInputBarBackgroundColor,
            border: Border(top: BorderSide(color: themeState.borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ThreeDTextField(
                  controller: _messageController,
                  hintText: L10n.get("admin_support_chat_reply_hint"),
                  backgroundColor: inputFieldBg,
                  textColor: inputFieldTextColor,
                  hintColor: inputFieldHintColor,
                  cursorColor: inputFieldTextColor,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
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
                    : ThemeIcon(Icons.send, color: themeState.sendButtonColor),
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
