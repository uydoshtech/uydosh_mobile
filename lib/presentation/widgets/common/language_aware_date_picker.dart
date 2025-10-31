import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class LanguageAwareDatePicker {
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return LanguageAwareDatePickerDialog(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          helpText: helpText,
          cancelText: cancelText,
          confirmText: confirmText,
        );
      },
    );
  }
}

class LanguageAwareDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;

  const LanguageAwareDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.helpText,
    this.cancelText,
    this.confirmText,
  });

  @override
  State<LanguageAwareDatePickerDialog> createState() =>
      _LanguageAwareDatePickerDialogState();
}

class _LanguageAwareDatePickerDialogState
    extends State<LanguageAwareDatePickerDialog> {
  late DateTime selectedDate;
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentMonth = DateTime(selectedDate.year, selectedDate.month);
  }

  String _getMonthName(int month) {
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );

    switch (month) {
      case 1:
        return LanguageAwareStringHelper.getCurrent(context, "january");
      case 2:
        return LanguageAwareStringHelper.getCurrent(context, "february");
      case 3:
        return LanguageAwareStringHelper.getCurrent(context, "march");
      case 4:
        return LanguageAwareStringHelper.getCurrent(context, "april");
      case 5:
        return LanguageAwareStringHelper.getCurrent(context, "may");
      case 6:
        return LanguageAwareStringHelper.getCurrent(context, "june");
      case 7:
        return LanguageAwareStringHelper.getCurrent(context, "july");
      case 8:
        return LanguageAwareStringHelper.getCurrent(context, "august");
      case 9:
        return LanguageAwareStringHelper.getCurrent(context, "september");
      case 10:
        return LanguageAwareStringHelper.getCurrent(context, "october");
      case 11:
        return LanguageAwareStringHelper.getCurrent(context, "november");
      case 12:
        return LanguageAwareStringHelper.getCurrent(context, "december");
      default:
        return "";
    }
  }

  String _getDayName(int weekday) {
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );

    switch (weekday) {
      case 1:
        return LanguageAwareStringHelper.getCurrent(context, "monday");
      case 2:
        return LanguageAwareStringHelper.getCurrent(context, "tuesday");
      case 3:
        return LanguageAwareStringHelper.getCurrent(context, "wednesday");
      case 4:
        return LanguageAwareStringHelper.getCurrent(context, "thursday");
      case 5:
        return LanguageAwareStringHelper.getCurrent(context, "friday");
      case 6:
        return LanguageAwareStringHelper.getCurrent(context, "saturday");
      case 7:
        return LanguageAwareStringHelper.getCurrent(context, "sunday");
      default:
        return "";
    }
  }

  String _getDayAbbreviation(int weekday) {
    final dayName = _getDayName(weekday);
    return dayName.substring(0, 1).toUpperCase();
  }

  void _previousMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedDate = date;
    });
  }

  void _confirm() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(selectedDate);
  }

  void _cancel() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;

    List<DateTime> days = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstDayOfWeek; i++) {
      days.add(DateTime(month.year, month.month, 0 - (firstDayOfWeek - 1 - i)));
    }

    // Add all days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final daysInMonth = _getDaysInMonth(currentMonth);

    // Use a contrasting background color for the blue theme
    Color getDialogBackgroundColor() {
      if (themeState.isBlueTheme) {
        return BlueThemeColors.card; // Use card color for better contrast
      }
      return theme.colorScheme.surface;
    }

    return Dialog(
      backgroundColor: getDialogBackgroundColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            if (widget.helpText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.helpText!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        themeState.isBlueTheme
                            ? Colors.white
                            : theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),

            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed:
                      currentMonth.isAfter(
                            DateTime(
                              widget.firstDate.year,
                              widget.firstDate.month,
                            ),
                          )
                          ? _previousMonth
                          : null,
                  icon: Icon(
                    Icons.chevron_left,
                    color:
                        currentMonth.isAfter(
                              DateTime(
                                widget.firstDate.year,
                                widget.firstDate.month,
                              ),
                            )
                            ? (themeState.isBlueTheme
                                ? Colors.white
                                : theme.colorScheme.onSurface)
                            : (themeState.isBlueTheme
                                    ? Colors.white
                                    : theme.colorScheme.onSurface)
                                .withOpacity(0.3),
                  ),
                ),
                Text(
                  "${_getMonthName(currentMonth.month)}, ${currentMonth.year}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        themeState.isBlueTheme
                            ? Colors.white
                            : theme.textTheme.titleMedium?.color,
                  ),
                ),
                IconButton(
                  onPressed:
                      currentMonth.isBefore(
                            DateTime(
                              widget.lastDate.year,
                              widget.lastDate.month,
                            ),
                          )
                          ? _nextMonth
                          : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color:
                        currentMonth.isBefore(
                              DateTime(
                                widget.lastDate.year,
                                widget.lastDate.month,
                              ),
                            )
                            ? (themeState.isBlueTheme
                                ? Colors.white
                                : theme.colorScheme.onSurface)
                            : (themeState.isBlueTheme
                                    ? Colors.white
                                    : theme.colorScheme.onSurface)
                                .withOpacity(0.3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Day headers
            Row(
              children: List.generate(7, (index) {
                final weekday = index + 1;
                return Expanded(
                  child: Center(
                    child: Text(
                      _getDayAbbreviation(weekday),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            themeState.isBlueTheme
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                final date = daysInMonth[index];
                final isCurrentMonth = date.month == currentMonth.month;
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isToday =
                    date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final isSelectable =
                    date.isAfter(
                      widget.firstDate.subtract(const Duration(days: 1)),
                    ) &&
                    date.isBefore(widget.lastDate.add(const Duration(days: 1)));

                return GestureDetector(
                  onTap: isSelectable ? () => _selectDate(date) : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : isToday
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              isSelected
                                  ? theme.colorScheme.onPrimary
                                  : isCurrentMonth
                                  ? (themeState.isBlueTheme
                                      ? Colors.white
                                      : theme.colorScheme.onSurface)
                                  : (themeState.isBlueTheme
                                          ? Colors.white
                                          : theme.colorScheme.onSurface)
                                      .withOpacity(0.3),
                          fontWeight:
                              isSelected || isToday
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _cancel,
                    child: Text(
                      widget.cancelText ??
                          LanguageAwareStringHelper.getCurrent(
                            context,
                            "cancel",
                          ),
                      style: TextStyle(
                        color:
                            themeState.isBlueTheme
                                ? MessagingThemeColors.textOnCardSecondary
                                : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeState.isBlueTheme
                              ? BlueThemeColors.primary
                              : null,
                      foregroundColor:
                          themeState.isBlueTheme
                              ? BlueThemeColors.textPrimary
                              : null,
                    ),
                    child: Text(
                      widget.confirmText ??
                          LanguageAwareStringHelper.getCurrent(context, "ok"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
