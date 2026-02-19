import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/base/localization/l10n.dart";

class CommonStateBuilder extends StatelessWidget {
  const CommonStateBuilder({
    required this.isLoading, required this.hasError, required this.isEmpty, required this.child, super.key,
    this.errorMessage,
    this.emptyMessage,
    this.emptySubtitle,
    this.emptyIcon,
    this.emptyAction,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.useHouseLoader,
    this.loadingText,
  });

  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool isEmpty;
  final String? emptyMessage;
  final String? emptySubtitle;
  final IconData? emptyIcon;
  final Widget? emptyAction;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final bool? useHouseLoader;
  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? _buildDefaultLoadingState(context);
    }

    if (hasError) {
      return errorWidget ??
          _buildDefaultErrorState(context, errorMessage ?? "An error occurred");
    }

    if (isEmpty) {
      return emptyWidget ??
          _buildDefaultEmptyState(
            context,
            emptyMessage ?? "No items found",
            emptySubtitle,
            emptyIcon ?? Icons.inbox_outlined,
            emptyAction,
          );
    }

    return child;
  }

  Widget _buildDefaultLoadingState(BuildContext context) {
    final effectiveUseHouseLoader =
        useHouseLoader ?? AppConfig.useHouseLoaderByDefault;

    // Use theme-aware colors for proper contrast
    final textColor = AppColors.getThemeAwareTextColor(context);
    final brightness = Theme.of(context).brightness;

    // Use provided loading text or fall back to localized translation
    final effectiveLoadingText = loadingText ?? _getDefaultLoadingText(context);

    // Debug information
    logger.d("🔍 CommonStateBuilder: Theme brightness: $brightness");
    logger.d(
      "🔍 CommonStateBuilder: Using house loader: $effectiveUseHouseLoader",
    );
    logger.d("🔍 CommonStateBuilder: Text color: $textColor");
    logger.d("🔍 CommonStateBuilder: Loading text: $effectiveLoadingText");

    // Always use house loader for consistency
    return CenteredHouseLoadingIndicator(
      text: effectiveLoadingText,
      rotationDuration: AppConfig.defaultHouseRotationDuration,
    );
  }

  /// Get appropriate loading text based on context
  String _getDefaultLoadingText(BuildContext context) {
    // Try to determine context from the widget tree
    // For now, use generic loading text
    return L10n.get("loading");
  }

  Widget _buildDefaultErrorState(BuildContext context, String message) {
    // Sanitize the error message to remove technical details
    final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(message);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.warning, AppColors.favoriteActive],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Error",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getThemeAwareTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            sanitizedMessage,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getThemeAwareTextColor(context).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultEmptyState(
    BuildContext context,
    String message,
    String? subtitle,
    IconData icon,
    Widget? action,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textGrey400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getThemeAwareTextColor(context).withOpacity(0.8),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getThemeAwareTextColor(
                  context,
                ).withOpacity(0.6),
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 24), action],
        ],
      ),
    );
  }
}
