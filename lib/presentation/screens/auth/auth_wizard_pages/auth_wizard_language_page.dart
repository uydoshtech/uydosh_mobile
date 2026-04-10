import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

class AuthWizardLanguagePage extends StatelessWidget {
  const AuthWizardLanguagePage({
    required this.selectedLanguage, required this.onLanguageSelected, super.key,
  });

  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  Color _getOnboardingTextSecondaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _buildLanguageOption(
                        context,
                        "uz",
                        "🇺🇿",
                        "O'zbekcha",
                        "Uzbek",
                      ),
                      const SizedBox(height: 20),
                      _buildLanguageOption(
                        context,
                        "ru",
                        "🇷🇺",
                        "Русский",
                        "Russian",
                      ),
                      const SizedBox(height: 20),
                      _buildLanguageOption(
                        context,
                        "en",
                        "🇺🇸",
                        "English",
                        "English",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String flag,
    String nativeName,
    String englishName,
  ) {
    final isSelected = selectedLanguage == languageCode;
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    const borderRadius = BorderRadius.all(Radius.circular(16));

    return GestureDetector(
      onTap: () => onLanguageSelected(languageCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
          boxShadow: isSelected
              ? ThreeDSurfaceStyle.elevatedShadows(context)
              : ThreeDSurfaceStyle.pressedShadows(context),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: TextStyle(
                fontSize: 32,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    englishName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? _getOnboardingTextSecondaryColor(context)
                          : scheme.onSurfaceVariant.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              ThemeIcon(
                Icons.check_circle,
                color: scheme.onSurface,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
