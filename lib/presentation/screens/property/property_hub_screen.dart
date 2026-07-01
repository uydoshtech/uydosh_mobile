import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// Buy/sell property feed host. Embedded in [MainNavigation] tab 1 when
/// [AppConfig.propertyFeatureEnabled] is true.
class PropertyHubScreen extends StatelessWidget {
  const PropertyHubScreen({
    super.key,
    this.embedded = false,
    this.tabVisible = true,
  });

  final bool embedded;
  final bool tabVisible;

  @override
  Widget build(BuildContext context) {
    final body = _PropertyHubPlaceholder(
      visible: !embedded || tabVisible,
    );

    if (embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get("nav_property")),
      ),
      body: body,
    );
  }
}

class _PropertyHubPlaceholder extends StatelessWidget {
  const _PropertyHubPlaceholder({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment_outlined,
              size: 56,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              L10n.get("property_hub_empty_title"),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              L10n.get("property_hub_empty_subtitle"),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
