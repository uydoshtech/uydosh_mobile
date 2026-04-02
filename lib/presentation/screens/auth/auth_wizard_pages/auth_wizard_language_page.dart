import "package:flutter/material.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";

class AuthWizardLanguagePage extends StatelessWidget {
  const AuthWizardLanguagePage({
    required this.selectedLanguage, required this.onLanguageSelected, super.key,
  });

  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  Color _getOnboardingTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

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
    return GestureDetector(
      onTap: () => onLanguageSelected(languageCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AuthWizardTheme.getSelectedButtonBackgroundColor()
              : AuthWizardTheme.getUnselectedButtonBackgroundColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AuthWizardTheme.getSelectedButtonBorderColor()
                : AuthWizardTheme.getUnselectedButtonBorderColor(),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: TextStyle(
                fontSize: 32,
                color: isSelected
                    ? _getOnboardingTextColor(context)
                    : AuthWizardTheme.getUnselectedButtonTextColor(),
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
                      color: isSelected
                          ? _getOnboardingTextColor(context)
                          : AuthWizardTheme.getUnselectedButtonTextColor(),
                    ),
                  ),
                  Text(
                    englishName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? _getOnboardingTextSecondaryColor(context)
                          : AuthWizardTheme.getUnselectedButtonTextColor()
                              .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: _getOnboardingTextColor(context),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
