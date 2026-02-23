import "package:flutter/material.dart";
import "package:uy_dosh/l10n/app_localizations.dart" as gen;

/// Extension for easy access to ARB-based localizations.
///
/// Use this when you have a [BuildContext] (e.g. in a widget's build method):
/// ```dart
/// Text(context.l10n.home)
/// Text(context.l10n.compatibility_match_percentage("75"))
/// ```
///
/// For context-less usage (e.g. in blocs, callbacks), continue using [L10n].
/// Gradually migrate from [L10n.get] to [context.l10n] when touching files.
extension AppLocalizationsExtension on BuildContext {
  /// Returns the ARB-based localizations for the current locale.
  gen.AppLocalizations get l10n => gen.AppLocalizations.of(this)!;
}
