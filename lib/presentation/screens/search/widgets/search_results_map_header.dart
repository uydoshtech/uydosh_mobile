part of "../search_results_map_screen.dart";

class _MapHeaderTitle extends StatelessWidget {
  const _MapHeaderTitle({
    required this.title,
    required this.loading,
  });

  final String title;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ) ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        );
    final spinnerColor = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: style),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: loading
              ? Padding(
                  key: const ValueKey("map-header-loading"),
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: spinnerColor,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey("map-header-idle")),
        ),
      ],
    );
  }
}

class _MapHeaderSearchButton extends StatelessWidget {
  const _MapHeaderSearchButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.search, size: 18, color: foregroundColor),
      label: Text(
        L10n.get("search"),
        style: theme.textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
