import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/services/admin_area_price_cache_service.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Rebuilds server-side area price (MSRP-style) aggregates for listing detail.
class AdminAreaPriceCacheScreen extends StatefulWidget {
  const AdminAreaPriceCacheScreen({super.key});

  @override
  State<AdminAreaPriceCacheScreen> createState() =>
      _AdminAreaPriceCacheScreenState();
}

class _AdminAreaPriceCacheScreenState extends State<AdminAreaPriceCacheScreen> {
  final IAdminAreaPriceCacheService _service =
      getIt<IAdminAreaPriceCacheService>();

  bool _running = false;
  String? _resultText;
  String? _errorText;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _errorText = null;
      _resultText = null;
    });
    try {
      final r = await _service.refreshCache();
      if (!mounted) return;
      setState(() {
        _resultText =
            "durationMs=${r.durationMs}, cache_rows=${r.rowCount}, source_listings=${r.listingCount}";
        _running = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _running = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlue = ThemeState().isBlueTheme;
    final primaryFullWidthStyle = isBlue
        ? FilledButton.styleFrom(
            backgroundColor: BlueThemeColors.buttonPrimary,
            foregroundColor: BlueThemeColors.textPrimary,
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          )
        : FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          );

    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_area_price_cache_section_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            L10n.get("admin_area_price_cache_screen_body"),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: primaryFullWidthStyle,
            onPressed: _running ? null : _run,
            icon: _running
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isBlue
                          ? BlueThemeColors.textPrimary
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : const ThemeIcon(Icons.analytics_outlined),
            label: Text(
              _running
                  ? L10n.get("admin_area_price_cache_running")
                  : L10n.get("admin_area_price_cache_run"),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 20),
            SelectableText(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_resultText != null) ...[
            const SizedBox(height: 24),
            Text(
              L10n.get("admin_telegram_sync_result_header"),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SelectableText(_resultText!),
          ],
        ],
      ),
    );
  }
}
