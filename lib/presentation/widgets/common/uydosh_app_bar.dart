import "package:flutter/material.dart";

/// Material [AppBar] with toolbar [Clip.none] by default so neumorphic
/// [BoxShadow]s on leading/actions are not clipped ([AppBar] defaults to
/// [Clip.hardEdge]). Pass [clipBehavior] to override.
class UydoshAppBar extends AppBar {
  UydoshAppBar({
    super.key,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.notificationPredicate = defaultScrollNotificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    super.forceMaterialTransparency = false,
    super.useDefaultSemanticsOrder = true,
    super.actionsPadding,
    super.animateColor = false,
    Clip? clipBehavior,
  }) : super(clipBehavior: clipBehavior ?? Clip.none);
}
