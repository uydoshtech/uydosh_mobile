import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "dart:math" as math;
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

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
      builder: (context) {
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

  const LanguageAwareDatePickerDialog({
    required this.initialDate, required this.firstDate, required this.lastDate, super.key,
    this.helpText,
    this.cancelText,
    this.confirmText,
  });
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;

  @override
  State<LanguageAwareDatePickerDialog> createState() =>
      _LanguageAwareDatePickerDialogState();
}

class _LanguageAwareDatePickerDialogState
    extends State<LanguageAwareDatePickerDialog> {
  late DateTime selectedDate;
  late DateTime currentMonth;
  int _selectionPulseTick = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentMonth = DateTime(selectedDate.year, selectedDate.month);
  }

  String _getMonthName(int month) {
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
        return "";
    }
  }

  String _getDayName(int weekday) {
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
        return "";
    }
  }

  String _getDayAbbreviation(int weekday) {
    final dayName = _getDayName(weekday);
    return dayName.substring(0, 1).toUpperCase();
  }

  void _previousMonth() {
    HapticFeedbackUtils.impact();
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    HapticFeedbackUtils.impact();
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    HapticFeedbackUtils.impact();
    setState(() {
      selectedDate = date;
      _selectionPulseTick++;
    });
  }

  void _confirm() {
    HapticFeedbackUtils.impact();
    Navigator.of(context).pop(selectedDate);
  }

  void _cancel() {
    HapticFeedbackUtils.impact();
    Navigator.of(context).pop();
  }

  /// Matches listing detail owner toolbar pill labels (views / promote).
  Color _pillAccentColor(BuildContext context) {
    final themeState = ThemeState();
    if (themeState.isLightTheme) return Colors.black;
    if (themeState.isBlueTheme) return Colors.white;
    return AppColors.primary;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;

    final days = <DateTime>[];

    // Add empty cells for days before the first day of the month
    for (var i = 1; i < firstDayOfWeek; i++) {
      days.add(DateTime(month.year, month.month, 0 - (firstDayOfWeek - 1 - i)));
    }

    // Add all days of the month
    for (var day = 1; day <= lastDayOfMonth.day; day++) {
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

            // Month navigation + calendar (swipeable)
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                const swipeThreshold = 100.0;
                if (velocity > swipeThreshold) {
                  // Swipe left -> previous month
                  if (currentMonth.isAfter(
                    DateTime(widget.firstDate.year, widget.firstDate.month),
                  )) {
                    _previousMonth();
                  }
                } else if (velocity < -swipeThreshold) {
                  // Swipe right -> next month
                  if (currentMonth.isBefore(
                    DateTime(widget.lastDate.year, widget.lastDate.month),
                  )) {
                    _nextMonth();
                  }
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  icon: ThemeIcon(
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
                  icon: ThemeIcon(
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

                Widget buildDayCell({required bool selected, double pulse = 0.0}) {
                  final t = pulse.clamp(0.0, 1.0);
                  final pulseAmount = (t <= 0) ? 0.0 : math.sin(math.pi * t);
                  final scale = selected ? (1.0 + 0.18 * pulseAmount) : 1.0;

                  final baseShadows =
                      selected ? ThreeDSurfaceStyle.elevatedShadows(context) : const <BoxShadow>[];
                  final glowShadows = selected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(
                              (themeState.isBlueTheme ? 0.45 : 0.30) * pulseAmount,
                            ),
                            blurRadius: 18 * pulseAmount,
                            spreadRadius: 2.5 * pulseAmount,
                          ),
                        ]
                      : const <BoxShadow>[];

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: selected
                            ? null
                            : isToday
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                        gradient: selected
                            ? ThreeDSurfaceStyle.surfaceGradient(
                                context,
                                theme.colorScheme.primary,
                              )
                            : null,
                        boxShadow: selected ? [...baseShadows, ...glowShadows] : null,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: selected
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
                                selected || isToday ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: isSelectable ? () => _selectDate(date) : null,
                  child: isSelected
                      ? TweenAnimationBuilder<double>(
                          key: ValueKey<String>(
                            "${date.year}-${date.month}-${date.day}-$_selectionPulseTick",
                          ),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutCubic,
                          builder: (context, t, child) {
                            return buildDayCell(selected: true, pulse: t);
                          },
                        )
                      : buildDayCell(selected: false),
                );
              },
            ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons (same pill style as listing detail views / promote)
            Row(
              children: [
                Expanded(
                  child: ThreeDPillButton(
                    onPressed: _cancel,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ThemeIcon(
                            CupertinoIcons.xmark,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: themeState.isBlueTheme ? 0.85 : 0.7,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.cancelText ?? L10n.get("cancel"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: themeState.isBlueTheme ? 0.9 : 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ThreeDPillButton(
                    onPressed: _confirm,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ThemeIcon(
                            CupertinoIcons.checkmark,
                            size: 16,
                            color: _pillAccentColor(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.confirmText ?? L10n.get("ok"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _pillAccentColor(context),
                            ),
                          ),
                        ],
                      ),
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
