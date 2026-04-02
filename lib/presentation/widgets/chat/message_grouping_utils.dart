import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";

/// Represents a single item in the grouped message list for lazy building
sealed class MessageGroupListItem {}

class DateHeaderListItem extends MessageGroupListItem {
  DateHeaderListItem(this.date);
  final DateTime date;
}

class MessageListItem extends MessageGroupListItem {
  MessageListItem(this.message, this.isCurrentUser, this.isLatest);
  final Message message;
  final bool isCurrentUser;
  final bool isLatest;
}

class MessageGroupingUtils {
  /// Groups messages by date and returns a list of widgets that can be displayed
  /// in a ListView. Each group contains a date header followed by the messages for that date.
  static List<Widget> groupMessagesByDate(
    List<Message> messages,
    Widget Function(
      Message message,
      bool isCurrentUser,
      bool isLatest,
      VoidCallback? onAnimationComplete,
    )
    messageBuilder,
    int? currentUserId,
    Set<int> newMessageIds,
    VoidCallback? Function(int messageId) onAnimationComplete,
    BuildContext context,
  ) {
    if (messages.isEmpty) return [];

    // Group messages by date
    final groupedMessages = <String, List<Message>>{};

    for (final message in messages) {
      final messageDate = DateTime.parse(message.createdAt).toLocal();
      final dateKey = _getDateKey(messageDate);

      if (!groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey] = [];
      }
      groupedMessages[dateKey]!.add(message);
    }

    // Sort dates (oldest first since we're using reverse ListView)
    final sortedDates =
        groupedMessages.keys.toList()
          ..sort((a, b) => a.compareTo(b)); // Oldest first

    final widgets = <Widget>[];

    for (final dateKey in sortedDates) {
      final messagesForDate = groupedMessages[dateKey]!;

      // Sort messages within each date group by time (oldest first)
      messagesForDate.sort(
        (a, b) => DateTime.parse(
          a.createdAt,
        ).toLocal().compareTo(DateTime.parse(b.createdAt).toLocal()),
      );

      // Add date header
      final firstMessageDate =
          DateTime.parse(messagesForDate.first.createdAt).toLocal();
      widgets.add(
        DateHeaderWidget(
          dateString: formatDateHeader(firstMessageDate, context),
          date: firstMessageDate,
        ),
      );

      // Add messages for this date
      for (final message in messagesForDate) {
        final isCurrentUser =
            currentUserId != null && currentUserId == message.senderId;
        final isNewMessage = newMessageIds.contains(message.id);

        widgets.add(
          messageBuilder(
            message,
            isCurrentUser,
            isNewMessage,
            () => onAnimationComplete(message.id),
          ),
        );
      }
    }

    return widgets;
  }

  /// Groups messages by date and returns a list of items for lazy building.
  /// Use with ListView.builder to build widgets on demand.
  static List<MessageGroupListItem> groupMessagesAsItems(
    List<Message> messages,
    int? currentUserId,
    Set<int> newMessageIds,
  ) {
    if (messages.isEmpty) return [];

    final groupedMessages = <String, List<Message>>{};

    for (final message in messages) {
      final messageDate = DateTime.parse(message.createdAt).toLocal();
      final dateKey = _getDateKey(messageDate);

      if (!groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey] = [];
      }
      groupedMessages[dateKey]!.add(message);
    }

    final sortedDates =
        groupedMessages.keys.toList()
          ..sort((a, b) => a.compareTo(b));

    final items = <MessageGroupListItem>[];

    for (final dateKey in sortedDates) {
      final messagesForDate = groupedMessages[dateKey]!;

      messagesForDate.sort(
        (a, b) => DateTime.parse(a.createdAt)
            .toLocal()
            .compareTo(DateTime.parse(b.createdAt).toLocal()),
      );

      final firstMessageDate =
          DateTime.parse(messagesForDate.first.createdAt).toLocal();
      items.add(DateHeaderListItem(firstMessageDate));

      for (final message in messagesForDate) {
        final isCurrentUser =
            currentUserId != null && currentUserId == message.senderId;
        final isLatest = newMessageIds.contains(message.id);

        items.add(MessageListItem(message, isCurrentUser, isLatest));
      }
    }

    return items;
  }

  /// Creates a date key for grouping messages (YYYY-MM-DD format)
  static String _getDateKey(DateTime date) {
    // Convert to local timezone for proper date grouping
    final localDate = date.toLocal();
    return DateFormat("yyyy-MM-dd").format(localDate);
  }

  /// Formats a date for display in the date header (public for lazy building)
  static String formatDateHeader(DateTime date, BuildContext context) {
    // Convert server date to local timezone for proper comparison
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    if (messageDate == today) {
      return L10n.get("today");
    } else if (messageDate == yesterday) {
      return L10n.get("yesterday");
    } else {
      // For all other dates, show "DayOfWeek, dd Month YYYY" format
      final dayName = _getLocalizedDayName(localDate.weekday, context);
      final monthName = _getLocalizedMonthName(localDate.month, context);
      return "$dayName, ${localDate.day} $monthName ${localDate.year}";
    }
  }

  /// Gets localized day name based on weekday number
  static String _getLocalizedDayName(int weekday, BuildContext context) {
    switch (weekday) {
      case 1:
        return L10n.get("monday");
      case 2:
        return L10n.get("tuesday");
      case 3:
        return L10n.get("wednesday");
      case 4:
        return L10n.get("thursday");
      case 5:
        return L10n.get("friday");
      case 6:
        return L10n.get("saturday");
      case 7:
        return L10n.get("sunday");
      default:
        return L10n.get("monday");
    }
  }

  /// Gets localized month name based on month number
  static String _getLocalizedMonthName(int month, BuildContext context) {
    switch (month) {
      case 1:
        return L10n.get("january");
      case 2:
        return L10n.get("february");
      case 3:
        return L10n.get("march");
      case 4:
        return L10n.get("april");
      case 5:
        return L10n.get("may");
      case 6:
        return L10n.get("june");
      case 7:
        return L10n.get("july");
      case 8:
        return L10n.get("august");
      case 9:
        return L10n.get("september");
      case 10:
        return L10n.get("october");
      case 11:
        return L10n.get("november");
      case 12:
        return L10n.get("december");
      default:
        return L10n.get("january");
    }
  }

  /// Groups messages by date and returns a map of date keys to message lists
  static Map<String, List<Message>> groupMessagesByDateKey(
    List<Message> messages,
  ) {
    final groupedMessages = <String, List<Message>>{};

    for (final message in messages) {
      final messageDate = DateTime.parse(message.createdAt).toLocal();
      final dateKey = _getDateKey(messageDate);

      if (!groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey] = [];
      }
      groupedMessages[dateKey]!.add(message);
    }

    // Sort messages within each date group by time (oldest first)
    groupedMessages.forEach((dateKey, messages) {
      messages.sort(
        (a, b) => DateTime.parse(
          a.createdAt,
        ).toLocal().compareTo(DateTime.parse(b.createdAt).toLocal()),
      );
    });

    return groupedMessages;
  }
}
