import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/cache/university_cache.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/domain/models/auth/update_profile_request.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/widgets/common/pressable_transform.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/base/services/mapkit_locale_sync_service.dart";
import "package:uy_dosh/base/services/native_language_service.dart";

// Utility class for language display names
class LanguageDisplayHelper {
  /// Native display name (e.g. "🇷🇺 Русский").
  /// Use for the language switcher / picker UI so users can recognize
  /// their language regardless of the current app locale.
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case "en":
        return "🇺🇸 English";
      case "ru":
        return "🇷🇺 Русский";
      case "uz":
        return "🇺🇿 O'zbekcha";
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Localized display name in the current app language.
  /// Use when describing another user's language (e.g. compatibility
  /// section, profile fields) so the label reads in the viewer's language.
  static String getLocalizedLanguageName(String languageCode) {
    final flag = _flagFor(languageCode);
    final name = L10n.get(_nameKeyFor(languageCode));
    return flag.isEmpty ? name : "$flag $name";
  }

  static String _flagFor(String languageCode) {
    switch (languageCode) {
      case "en":
        return "🇺🇸";
      case "ru":
        return "🇷🇺";
      case "uz":
        return "🇺🇿";
      default:
        return "";
    }
  }

  static String _nameKeyFor(String languageCode) {
    switch (languageCode) {
      case "en":
        return "language_name_english";
      case "ru":
        return "language_name_russian";
      case "uz":
        return "language_name_uzbek";
      default:
        return languageCode.toUpperCase();
    }
  }
}

// Global language state with ChangeNotifier for reactivity
class LanguageState extends ChangeNotifier {
  factory LanguageState() => _instance;
  LanguageState._internal();
  static final LanguageState _instance = LanguageState._internal();

  String _currentLanguage = "uz"; // Default language
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;

  static const Set<String> _supportedLanguageCodes = {"uz", "ru", "en"};

  String _pickDeviceLanguageCode() {
    try {
      // Prefer the full list of preferred locales (Android can return multiple).
      final locales = WidgetsBinding.instance.platformDispatcher.locales;
      for (final locale in locales) {
        final code = locale.languageCode.toLowerCase();
        if (_supportedLanguageCodes.contains(code)) return code;
      }

      // Fallback to the single "current" locale if locales is empty.
      final code =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode
              .toLowerCase();
      if (_supportedLanguageCodes.contains(code)) return code;
    } catch (_) {
      // Ignore and fall back to default.
    }

    return _currentLanguage;
  }

  // Initialize and load saved language from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasUserSelectedLanguage =
          prefs.getBool(StorageKeys.hasUserSelectedLanguage) ?? false;
      final savedLanguage = prefs.getString(StorageKeys.selectedLanguage);
      if (hasUserSelectedLanguage &&
          savedLanguage != null &&
          savedLanguage.isNotEmpty &&
          _supportedLanguageCodes.contains(savedLanguage)) {
        _currentLanguage = savedLanguage;
      } else {
        // Until the user explicitly selects a language, we follow the device locale.
        final deviceLanguage = _pickDeviceLanguageCode();
        _currentLanguage = deviceLanguage;
        await prefs.setString(StorageKeys.selectedLanguage, deviceLanguage);
      }
    } catch (e) {
      // If there"s an error loading, keep the default language
    }

    // Best-effort: set iOS preferred language on startup so native UI (RoomPlan)
    // is created under the same locale as the app.
    await NativeLanguageService.setPreferredLanguage(_currentLanguage);
    await MapKitLocaleSyncService.sync(_currentLanguage);

    _isInitialized = true;
    notifyListeners();
  }

  /// Updates the in-memory + on-device language and (by default) syncs the
  /// new value to the user's profile on the backend.
  ///
  /// Pass [persistToServer]=`false` from contexts where the change is purely
  /// local — e.g. the auth wizard's language page (we don't yet know if the
  /// user is new or returning, and a returning user's server-side
  /// `preferred_language` should win at sign-in) or post-login reconciliation
  /// from the server's value (we'd otherwise echo the value we just read).
  Future<void> setLanguage(
    String language, {
    bool persistToServer = true,
  }) async {
    if (_currentLanguage != language) {
      final fromLanguage = _currentLanguage;
      _currentLanguage = language;
      getIt<AppAnalyticsService>().logLanguageChanged(
        fromLanguage: fromLanguage,
        toLanguage: language,
      );

      // Invalidate university cache so next fetch uses new language
      UniversityCache.clearCache();

      // Save to local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.selectedLanguage, language);
        await prefs.setBool(StorageKeys.hasUserSelectedLanguage, true);
      } catch (e) {
        // Handle error silently
      }

      // Best-effort: keep iOS native UI (e.g. RoomPlan) in sync with the in-app language.
      await NativeLanguageService.setPreferredLanguage(language);
      await MapKitLocaleSyncService.sync(language);

      // Sync to user profile so other users can see what language they speak
      if (persistToServer) {
        try {
          if (await SessionManager.isAuthenticated()) {
            final profileService = getIt<IUserProfileService>();
            await profileService.updateProfile(
              UpdateProfileRequest(preferredLanguage: language),
            );
          }
        } catch (e) {
          // Handle error silently - profile sync is best-effort
        }
      }

      notifyListeners();
    }
  }

  // Clear saved language and reset to default
  Future<void> clearSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.selectedLanguage);
      await prefs.remove(StorageKeys.hasUserSelectedLanguage);
      _currentLanguage = "uz"; // Reset to default
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }
}

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({required this.child, super.key});

  final Widget child;

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  final LanguageState _languageState = LanguageState();

  void _changeLanguage(String languageCode) {
    _languageState.setLanguage(
      languageCode,
    ); // This is now async but we don"t need to await it
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          "Language Test",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.inversePrimary,
        actions: [
          ListenableBuilder(
            listenable: AnimationSettingsState(),
            builder: (context, _) {
              final enableMotion = AnimationSettingsState().uiAnimationsEnabled;
              final style =
                  enableMotion
                      ? null
                      : const AnimationStyle(
                          duration: Duration.zero,
                          reverseDuration: Duration.zero,
                        );

              return PopupMenuButton<String>(
                onOpened: UiFeedbackUtils.tap,
                onSelected: (code) {
                  UiFeedbackUtils.tap();
                  _changeLanguage(code);
                },
                popUpAnimationStyle: style,
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: "uz",
                        child: Text(
                          LanguageDisplayHelper.getLanguageDisplayName("uz"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "ru",
                        child: Text(
                          LanguageDisplayHelper.getLanguageDisplayName("ru"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "en",
                        child: Text(
                          LanguageDisplayHelper.getLanguageDisplayName("en"),
                        ),
                      ),
                    ],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ThemeIcon(CupertinoIcons.globe),
                      const SizedBox(width: 8),
                      ListenableBuilder(
                        listenable: _languageState,
                        builder: (context, child) {
                          return Text(
                            LanguageDisplayHelper.getLanguageDisplayName(
                              _languageState.currentLanguage,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: widget.child,
    );
  }
}

/// Returns the unicode flag emoji for one of the app's supported languages.
String languageFlagForCode(String code) {
  return switch (code) {
    "en" => "🇺🇸",
    "ru" => "🇷🇺",
    "uz" => "🇺🇿",
    _ => "🌐",
  };
}

/// Returns the localization key for the human-readable name of a language.
String languageNameKeyForCode(String code) {
  return switch (code) {
    "en" => "language_english",
    "ru" => "language_russian",
    "uz" => "language_uzbek",
    _ => "menu_language",
  };
}

/// Compact rounded segment matching profile header language / currency chips.
class PreferenceSegmentTile extends StatelessWidget {
  const PreferenceSegmentTile({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.label,
    this.tooltip,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String label;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    const borderRadius = BorderRadius.all(Radius.circular(12));

    final tile = PressableTransform(
      feedback: PressableFeedback.selection,
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
          boxShadow: selected
              ? ThreeDSurfaceStyle.insetRecessedShadows(context)
              : ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
          border: Border.all(
            color: selected
                ? preferenceSegmentSelectedBorderColor(context)
                : scheme.outline.withValues(alpha: 0.4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  height: 1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.2,
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    final tip = tooltip?.trim();
    if (tip != null && tip.isNotEmpty) {
      return Tooltip(message: tip, child: tile);
    }
    return tile;
  }
}

/// Opens the standard "select language" dialog. Used by both the settings
/// screen and the profile-header flag chip so the picker behaves identically
/// (theming, analytics, server sync, success toast) wherever it is invoked.
///
/// The dialog itself is rendered with the app's neumorphic "soft UI" chrome
/// — a recessed plate carrying raised language tiles — so it matches the
/// rest of the surface system (auth wizard language page, settings cards).
Future<void> showLanguagePickerDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (dialogContext) => const _NeumorphicLanguagePickerDialog(),
  );
}

class _NeumorphicLanguagePickerDialog extends StatelessWidget {
  const _NeumorphicLanguagePickerDialog();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    const borderRadius = BorderRadius.all(Radius.circular(24));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10n.get("select_language"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),
              const LanguagePickerOptionTile(code: "uz"),
              const SizedBox(height: 12),
              const LanguagePickerOptionTile(code: "ru"),
              const SizedBox(height: 12),
              const LanguagePickerOptionTile(code: "en"),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single language row for pickers and preference sheets.
///
/// When shown inside a [Dialog], pass the default [popNavigatorOnSelect]
/// so choosing a language closes the dialog. When embedded in a persistent
/// surface such as a bottom sheet, set [popNavigatorOnSelect] to false.
///
/// Use [dense] for tighter rows (e.g. profile preferences bottom sheet).
///
/// Use [segmentSlot] when the tile sits in an [Expanded] inside a [Row]
/// (compact flag / symbol + short code).
class LanguagePickerOptionTile extends StatelessWidget {
  const LanguagePickerOptionTile({
    required this.code,
    this.popNavigatorOnSelect = true,
    this.dense = false,
    this.segmentSlot = false,
    super.key,
  });

  final String code;

  /// Whether to pop the current route (e.g. dialog) after a successful choice.
  final bool popNavigatorOnSelect;

  /// Smaller padding and type for bottom sheets and tight layouts.
  final bool dense;

  /// Compact cell for a horizontal segment row (profile preferences sheet).
  final bool segmentSlot;

  @override
  Widget build(BuildContext context) {
    if (segmentSlot) {
      return _buildSegmentSlot(context);
    }
    final isCurrent = LanguageState().currentLanguage == code;
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    final nameKey = languageNameKeyForCode(code);
    final radius = dense ? 12.0 : 14.0;
    final borderRadius = BorderRadius.circular(radius);
    final hPad = dense ? 12.0 : 16.0;
    final vPad = dense ? 8.0 : 14.0;
    final flagGap = dense ? 10.0 : 14.0;
    final flagSize = dense ? 20.0 : 26.0;
    final titleSize = dense ? 14.0 : 16.0;

    final flagWidget = Text(
      languageFlagForCode(code),
      style: TextStyle(fontSize: flagSize, height: 1.1),
    );

    return PressableTransform(
      feedback: PressableFeedback.selection,
      onTap: () {
        if (popNavigatorOnSelect) Navigator.pop(context);
        LanguageState().setLanguage(code);
        ToastTheme.showSuccess(
          context,
          message: AppStrings.getWithParams(
            "language_changed_to",
            LanguageState().currentLanguage,
            params: {"language": L10n.get(nameKey)},
          ),
        );
      },
      borderRadius: borderRadius,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
          boxShadow: isCurrent
              ? ThreeDSurfaceStyle.insetRecessedShadows(context)
              : ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
        ),
        child: Row(
          children: [
            if (dense)
              SizedBox(
                width: 28,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: flagWidget,
                ),
              )
            else
              flagWidget,
            SizedBox(width: flagGap),
            Expanded(
              child: L10n.text(
                nameKey,
                style: TextStyle(
                  fontSize: titleSize,
                  height: 1.2,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentSlot(BuildContext context) {
    final isCurrent = LanguageState().currentLanguage == code;
    final nameKey = languageNameKeyForCode(code);

    return PreferenceSegmentTile(
      selected: isCurrent,
      tooltip: L10n.get(nameKey),
      onTap: () {
        if (popNavigatorOnSelect) Navigator.pop(context);
        LanguageState().setLanguage(code);
        ToastTheme.showSuccess(
          context,
          message: AppStrings.getWithParams(
            "language_changed_to",
            LanguageState().currentLanguage,
            params: {"language": L10n.get(nameKey)},
          ),
        );
      },
      leading: Text(
        languageFlagForCode(code),
        style: const TextStyle(fontSize: 18, height: 1),
      ),
      label: code.toUpperCase(),
    );
  }
}
