part of "../search_results_map_screen.dart";

class _CenteredMapStatus extends StatelessWidget {
  const _CenteredMapStatus({
    required this.icon,
    required this.title,
    this.loading = false,
    this.loaderColor,
  });

  final IconData icon;
  final String title;
  final bool loading;
  final Color? loaderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              HouseLoadingIndicator(
                size: 40,
                color: loaderColor,
              )
            else
              ThemeIcon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
