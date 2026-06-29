import "package:flutter/material.dart";

/// Marks modal bottom-sheet content where nested [LiquidGlassPlate] widgets
/// should skip per-control backdrop blur (the sheet surface already blurs once).
class ModalSheetGlassScope extends InheritedWidget {
  const ModalSheetGlassScope({
    required this.nestedPlateBlurEnabled,
    required super.child,
    super.key,
  });

  final bool nestedPlateBlurEnabled;

  static bool nestedPlateBlurEnabledOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ModalSheetGlassScope>()
            ?.nestedPlateBlurEnabled ??
        true;
  }

  @override
  bool updateShouldNotify(ModalSheetGlassScope oldWidget) {
    return nestedPlateBlurEnabled != oldWidget.nestedPlateBlurEnabled;
  }
}
