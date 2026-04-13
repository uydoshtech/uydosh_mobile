import "package:flutter/material.dart";

class ThreeDTextField extends StatefulWidget {
  const ThreeDTextField({
    required this.controller,
    super.key,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.backgroundColor,
  });

  final TextEditingController controller;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsets contentPadding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;

  @override
  State<ThreeDTextField> createState() => _ThreeDTextFieldState();
}

class _ThreeDTextFieldState extends State<ThreeDTextField> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ThreeDTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgBase = widget.backgroundColor ?? scheme.surfaceContainerHighest;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rim = BorderRadius.lerp(widget.borderRadius, BorderRadius.circular(999), 0.25)!;
    final focused = _focusNode.hasFocus;

    // Match reference (img1):
    // - overall control reads "sunken" into the page (use inset-like shadows, no drop shadow)
    // - soft outer rim + slightly deeper inner track
    // - absolutely no hard outline on focus
    final outerBg = Color.lerp(bgBase, scheme.onSurface, isDark ? 0.06 : 0.02)!;
    final innerBg = Color.lerp(outerBg, scheme.onSurface, isDark ? 0.10 : 0.03)!;

    final outerDarkA = isDark ? (focused ? 0.18 : 0.24) : (focused ? 0.08 : 0.12);
    final outerLightA = isDark ? 0.05 : 0.75;
    final innerDarkA = isDark ? (focused ? 0.16 : 0.22) : (focused ? 0.06 : 0.10);
    final innerLightA = isDark ? 0.05 : 0.78;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: rim,
        color: outerBg,
        boxShadow: [
          // Outer rim (inset illusion via negative spread).
          BoxShadow(
            color: Colors.black.withValues(alpha: outerDarkA),
            offset: const Offset(3, 3),
            blurRadius: 14,
            spreadRadius: -10,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: outerLightA),
            offset: const Offset(-3, -3),
            blurRadius: 14,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: innerBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: innerDarkA),
                offset: const Offset(3.5, 3.5),
                blurRadius: 14,
                spreadRadius: -9,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: innerLightA),
                offset: const Offset(-3.5, -3.5),
                blurRadius: 14,
                spreadRadius: -9,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              children: [
                // Subtle top highlight like the reference.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: isDark ? 0.04 : 0.35),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55],
                        ),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: widget.contentPadding,
                  ),
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  textCapitalization: widget.textCapitalization,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

