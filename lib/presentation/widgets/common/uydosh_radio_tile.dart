import "package:flutter/material.dart";

/// A reusable selection row with Radio and title.
/// Used for single-choice forms (e.g. complaint category selection).
class UydoshRadioTile<T> extends StatelessWidget {
  const UydoshRadioTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    super.key,
    this.margin,
    this.selectedTileColor,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget title;
  final EdgeInsetsGeometry? margin;
  final Color? selectedTileColor;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: title,
        leading: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        onTap: () => onChanged(value),
        selected: isSelected,
        selectedTileColor: selectedTileColor,
      ),
    );
  }
}
