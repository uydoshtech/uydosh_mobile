import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";

/// Shared visuals and keyed feedback for listing / gig **description assistant**
/// affordances: AI enhance, dictate, template toolbar, etc.
///
/// Keeps [ToastReporting] + message keys in one place instead of scattering
/// [ToastTheme.showError] calls across widgets.
abstract final class ListingDescriptionAssistant {
  static Color accentColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Shown beside labels while dictate transcribes or AI enhance runs.
  static Widget inlineProgress(
    BuildContext context, {
    double size = 18,
    double strokeWidth = 2,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: UydoshInlineSpinner(
        color: accentColor(context),
        dimension: size,
        strokeWidth: strokeWidth,
      ),
    );
  }

  static void toastSignInRequired(BuildContext context) {
    ToastReporting.errorKey(context, "listing_translation_sign_in_required");
  }

  static void toastDictateMicDenied(BuildContext context) {
    ToastReporting.errorKey(context, "listing_description_dictate_mic_denied");
  }

  static void toastDictateFailed(BuildContext context) {
    ToastReporting.errorKey(context, "listing_description_dictate_failed");
  }

  static void toastDictateNotConfigured(BuildContext context) {
    ToastReporting.errorKey(
      context,
      "listing_description_dictate_not_configured",
    );
  }

  static void toastAiEnhanceEmpty(BuildContext context) {
    ToastReporting.errorKey(context, "listing_ai_enhance_empty");
  }

  static void toastAiEnhanceUnavailable(BuildContext context) {
    ToastReporting.errorKey(context, "listing_ai_enhance_unavailable");
  }

  static void toastAiEnhanceFailed(
    BuildContext context, {
    String errorKey = "listing_ai_enhance_error",
  }) {
    ToastReporting.errorKey(context, errorKey);
  }
}
