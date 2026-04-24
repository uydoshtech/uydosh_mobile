import "package:flutter/material.dart";
import "package:flutter/widgets.dart";

/// Shared scrollable container for edit/create form screens.
///
/// Wraps [children] in a [SingleChildScrollView] with `onDrag` keyboard
/// dismissal, a symmetric horizontal padding of [horizontalPadding] (default
/// 16) and a stretching [Column]. The [topPadding] and [bottomPadding] let
/// callers account for app-bar insets (e.g. the liquid-glass overlay used by
/// create/edit listing screens).
class UydoshFormScrollBody extends StatelessWidget {
  const UydoshFormScrollBody({
    required this.children,
    super.key,
    this.topPadding = 16.0,
    this.bottomPadding = 16.0,
    this.horizontalPadding = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.controller,
  });

  final List<Widget> children;
  final double topPadding;
  final double bottomPadding;
  final double horizontalPadding;
  final CrossAxisAlignment crossAxisAlignment;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      keyboardDismissBehavior: keyboardDismissBehavior,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }
}
