import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";

/// ToastTheme provides a centralized way to show toast messages throughout the app.
///
/// Toast positioning:
/// - Rolling toasts (with animation) appear right below the app header
/// - Traditional SnackBars appear at the bottom of the screen
/// - All toasts automatically dismiss after a configurable duration
///
/// Usage examples:
/// - ToastTheme.showSuccess(context, message: "Operation completed!")
/// - ToastTheme.showError(context, message: "Something went wrong")
/// - ToastTheme.showWarning(context, message: "Please check your input")
/// - ToastTheme.showInfo(context, message: "Here"s some information")
class ToastTheme {
  static const Duration _defaultDuration = Duration(
    milliseconds: 2000,
  ); // 2 seconds

  // Keep track of current toast overlay
  static OverlayEntry? _currentToastOverlay;

  /// Dismisses the current toast if one is showing
  static void dismissCurrent() {
    if (_currentToastOverlay != null) {
      _currentToastOverlay!.remove();
      _currentToastOverlay = null;
    }
  }

  /// Shows a success toast with green background and rolling animation
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration? duration,
    bool useRollingAnimation = true,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: AppColors.statusActive,
        duration: duration ?? _defaultDuration,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: AppColors.statusActive,
        duration: duration ?? _defaultDuration,
      );
    }
  }

  /// Shows a success toast without rolling animation (traditional style)
  static void showSuccessSimple(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.statusActive,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows an error toast with red background and rolling animation
  static void showError(
    BuildContext context, {
    required String message,
    Duration? duration,
    bool useRollingAnimation = true,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: AppColors.error,
        duration: duration ?? _defaultDuration,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: AppColors.error,
        duration: duration ?? _defaultDuration,
      );
    }
  }

  /// Shows an error toast without rolling animation (traditional style)
  static void showErrorSimple(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.error,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows a warning toast with orange background and rolling animation
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration? duration,
    bool useRollingAnimation = true,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: AppColors.warning,
        duration: duration ?? _defaultDuration,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: AppColors.warning,
        duration: duration ?? _defaultDuration,
      );
    }
  }

  /// Shows a warning toast without rolling animation (traditional style)
  static void showWarningSimple(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows an info toast with blue background and rolling animation
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration? duration,
    bool useRollingAnimation = true,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: BlueThemeColors.primaryLight,
        duration: duration ?? _defaultDuration,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: BlueThemeColors.primaryLight,
        duration: duration ?? _defaultDuration,
      );
    }
  }

  /// Shows an info toast without rolling animation (traditional style)
  static void showInfoSimple(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: BlueThemeColors.primaryLight,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows a custom toast with specified background color and rolling animation
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Duration? duration,
    bool useRollingAnimation = true,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: backgroundColor,
        duration: duration ?? _defaultDuration,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: backgroundColor,
        duration: duration ?? _defaultDuration,
      );
    }
  }

  /// Shows a custom toast without rolling animation (traditional style)
  static void showCustomSimple(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows a rolling toast with slide down and roll up animation
  static void _showRollingToast(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    if (!context.mounted) return;

    // Remove any existing toasts
    dismissCurrent();

    // Show the custom top-positioned toast
    _showTopToast(
      context,
      message: message,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }

  /// Shows a custom toast at the top of the screen
  static void _showTopToast(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    // Dismiss any existing toast
    dismissCurrent();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _TopToastOverlay(
            message: message,
            backgroundColor: backgroundColor,
            onDismiss: () {
              overlayEntry.remove();
              _currentToastOverlay = null;
            },
          ),
    );

    _currentToastOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        _currentToastOverlay = null;
      }
    });
  }

  /// Internal method to show the SnackBar (legacy method)
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

/// Custom animated toast content with rolling animation
class _RollingToastContent extends StatefulWidget {

  const _RollingToastContent({
    required this.message,
    required this.backgroundColor,
  });
  final String message;
  final Color backgroundColor;

  @override
  State<_RollingToastContent> createState() => _RollingToastContentState();
}

class _RollingToastContentState extends State<_RollingToastContent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for slide and scale animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Slide down animation with bounce
    _slideAnimation = Tween<double>(
      begin: -120.0, // Start from above the toast position
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Scale animation for bounce effect
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Start the slide down animation
    _slideController.forward();

    // Schedule the roll up animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _startRollUp();
      }
    });
  }

  void _startRollUp() {
    _slideController.reverse();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                    decorationThickness: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Top-positioned toast overlay with slide down animation
///
/// This toast appears right below the app header (AppBar) with a small buffer space
/// to ensure it doesn"t overlap with the header content.
class _TopToastOverlay extends StatefulWidget {

  const _TopToastOverlay({
    required this.message,
    required this.backgroundColor,
    required this.onDismiss,
  });
  final String message;
  final Color backgroundColor;
  final VoidCallback onDismiss;

  @override
  State<_TopToastOverlay> createState() => _TopToastOverlayState();
}

class _TopToastOverlayState extends State<_TopToastOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for slide and scale animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Slide down animation with bounce
    _slideAnimation = Tween<double>(
      begin: -120.0, // Start from above the toast position
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Scale animation for bounce effect
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Start the slide down animation
    _slideController.forward();

    // Schedule the slide up animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _startSlideUp();
      }
    });
  }

  void _startSlideUp() {
    _slideController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top:
          kToolbarHeight +
          MediaQuery.of(context).padding.top +
          8, // Position below AppBar with small buffer
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
                      decorationThickness: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
