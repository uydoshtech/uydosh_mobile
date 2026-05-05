import "package:flutter/material.dart";
import "dart:ui";
import "package:uy_dosh/base/constants/app_colors.dart";

enum ToastDismissReason { completed, preempted }

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
    milliseconds: 3000,
  ); // 6 seconds

  static Color _foregroundOn(Color backgroundColor) => Colors.white;

  static const double _toastCornerRadius = 12;
  static const double _toastBlurSigma = 16;
  static const double _toastFillOpacity = 0.82;

  static Widget _glassySurface({
    required Color baseColor,
    required Widget child,
    BorderRadius? borderRadius,
  }) {
    final r = borderRadius ?? BorderRadius.circular(_toastCornerRadius);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _toastBlurSigma,
          sigmaY: _toastBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: baseColor.withOpacity(_toastFillOpacity),
            borderRadius: r,
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 18,
                offset: const Offset(0, 10),
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Keep track of current toast overlay
  static OverlayEntry? _currentToastOverlay;
  static VoidCallback? _currentToastOnDismissed;
  static void Function(ToastDismissReason reason)? _currentToastOnClosed;

  /// Dismisses the current toast if one is showing
  static void dismissCurrent() {
    if (_currentToastOverlay != null) {
      _currentToastOverlay!.remove();
      _currentToastOverlay = null;
      final cb = _currentToastOnDismissed;
      _currentToastOnDismissed = null;
      cb?.call();
      final closed = _currentToastOnClosed;
      _currentToastOnClosed = null;
      closed?.call(ToastDismissReason.preempted);
    }
  }

  /// Shows a success toast with green background and rolling animation
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration? duration,
    bool useRollingAnimation = true,
    VoidCallback? onDismissed,
    void Function(ToastDismissReason reason)? onClosed,
    IconData? leadingIcon,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: AppColors.statusActive,
        duration: duration ?? _defaultDuration,
        onDismissed: onDismissed,
        onClosed: onClosed,
        leadingIcon: leadingIcon,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: AppColors.statusActive,
        duration: duration ?? _defaultDuration,
        leadingIcon: leadingIcon,
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
    VoidCallback? onDismissed,
    void Function(ToastDismissReason reason)? onClosed,
    IconData? leadingIcon,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: AppColors.error,
        duration: duration ?? _defaultDuration,
        onDismissed: onDismissed,
        onClosed: onClosed,
        leadingIcon: leadingIcon,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: AppColors.error,
        duration: duration ?? _defaultDuration,
        leadingIcon: leadingIcon,
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
    VoidCallback? onDismissed,
    void Function(ToastDismissReason reason)? onClosed,
    IconData? leadingIcon,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: AppColors.warning,
        duration: duration ?? _defaultDuration,
        onDismissed: onDismissed,
        onClosed: onClosed,
        leadingIcon: leadingIcon,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: AppColors.warning,
        duration: duration ?? _defaultDuration,
        leadingIcon: leadingIcon,
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
    VoidCallback? onDismissed,
    void Function(ToastDismissReason reason)? onClosed,
    IconData? leadingIcon,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: BlueThemeColors.primaryLight,
        duration: duration ?? _defaultDuration,
        onDismissed: onDismissed,
        onClosed: onClosed,
        leadingIcon: leadingIcon,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: BlueThemeColors.primaryLight,
        duration: duration ?? _defaultDuration,
        leadingIcon: leadingIcon,
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
    VoidCallback? onDismissed,
    void Function(ToastDismissReason reason)? onClosed,
    IconData? leadingIcon,
  }) {
    if (useRollingAnimation) {
      _showRollingToast(
        context,
        message: message,
        backgroundColor: backgroundColor,
        duration: duration ?? _defaultDuration,
        onDismissed: onDismissed,
        onClosed: onClosed,
        leadingIcon: leadingIcon,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: backgroundColor,
        duration: duration ?? _defaultDuration,
        leadingIcon: leadingIcon,
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
    VoidCallback? onDismissed,
    void Function(ToastDismissReason reason)? onClosed,
    IconData? leadingIcon,
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
      onDismissed: onDismissed,
      onClosed: onClosed,
      leadingIcon: leadingIcon,
    );
  }

  /// Shows a custom toast at the top of the screen
  static void _showTopToast(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
    VoidCallback? onDismissed,
    void Function(ToastDismissReason reason)? onClosed,
    IconData? leadingIcon,
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
            duration: duration,
            leadingIcon: leadingIcon,
            onDismiss: () {
              overlayEntry.remove();
              _currentToastOverlay = null;
              final cb = _currentToastOnDismissed;
              _currentToastOnDismissed = null;
              cb?.call();
              final closed = _currentToastOnClosed;
              _currentToastOnClosed = null;
              closed?.call(ToastDismissReason.completed);
            },
          ),
    );

    _currentToastOverlay = overlayEntry;
    _currentToastOnDismissed = onDismissed;
    _currentToastOnClosed = onClosed;
    overlay.insert(overlayEntry);
  }

  /// Internal method to show the SnackBar (legacy method)
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
    IconData? leadingIcon,
  }) {
    if (context.mounted) {
      final foreground = _foregroundOn(backgroundColor);
      final textWidget = Text(
        message,
        style: TextStyle(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: _glassySurface(
            baseColor: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: leadingIcon == null
                  ? textWidget
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(leadingIcon, color: foreground, size: 18),
                        const SizedBox(width: 8),
                        Flexible(child: textWidget),
                      ],
                    ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
    final foregroundColor = ToastTheme._foregroundOn(widget.backgroundColor);
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: ToastTheme._glassySurface(
                baseColor: widget.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
                      decorationThickness: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
    required this.duration,
    required this.onDismiss,
    this.leadingIcon,
  });
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDismiss;
  final IconData? leadingIcon;

  @override
  State<_TopToastOverlay> createState() => _TopToastOverlayState();
}

class _TopToastOverlayState extends State<_TopToastOverlay>
    with TickerProviderStateMixin {
  static const Duration _animDuration = Duration(milliseconds: 800);
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for slide and scale animations
    _slideController = AnimationController(
      duration: _animDuration,
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
    final visibleFor = widget.duration - _animDuration;
    Future.delayed(visibleFor.isNegative ? Duration.zero : visibleFor, () {
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

  Widget _buildContent(Color foregroundColor) {
    final text = Text(
      widget.message,
      style: TextStyle(
        color: foregroundColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0,
      ),
      textAlign: TextAlign.center,
    );
    if (widget.leadingIcon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.leadingIcon, color: foregroundColor, size: 18),
        const SizedBox(width: 8),
        Flexible(child: text),
      ],
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = ToastTheme._foregroundOn(widget.backgroundColor);
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ToastTheme._glassySurface(
                    baseColor: widget.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: _buildContent(foregroundColor),
                    ),
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
