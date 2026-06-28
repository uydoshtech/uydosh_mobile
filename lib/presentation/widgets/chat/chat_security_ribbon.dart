import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ChatSecurityRibbon extends StatelessWidget {
  const ChatSecurityRibbon({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final ts = ThemeState();
        final scheme = Theme.of(context).colorScheme;
        final useGlass = ts.isBlueTheme && ts.usesLiquidGlassChrome;
        final bg = Color.lerp(scheme.primary, ts.cardColor, 0.86)!;
        final border = useGlass
            ? Colors.white.withValues(alpha: 0.18)
            : scheme.primary.withValues(alpha: 0.18);
        final titleColor = ts.isBlueTheme ? Colors.white : ts.textColor;
        final bodyColor = ts.isBlueTheme ? Colors.white : ts.secondaryTextColor;
        final shieldColor = ts.isBlueTheme ? Colors.white : scheme.primary;

        final ribbonContent = Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: border)),
            gradient: useGlass
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  )
                : null,
            color: useGlass ? null : bg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ThemeIcon(
                Icons.shield,
                size: 23, // 18 * 1.25 ≈ 23
                color: shieldColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.get("chat_security_ribbon_title"),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      L10n.get("chat_security_ribbon_body"),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        color: bodyColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onClose,
                tooltip: L10n.get("close"),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  foregroundColor: titleColor,
                ),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
        );

        if (!useGlass) {
          return Material(
            color: bg,
            child: ribbonContent,
          );
        }

        final enableGlass = LiquidGlassRendering.effectsEnabled(context);

        final ribbon = Material(
          color: Colors.transparent,
          child: ribbonContent,
        );

        return ClipRect(
          child: LiquidGlassRendering.backdropBlur(
            enabled: enableGlass,
            sigma: LiquidGlassRendering.switchGlassBlurSigma,
            child: ribbon,
          ),
        );
      },
    );
  }
}
