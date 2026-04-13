import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Reusable chat avatar with initials or person icon.
/// Used in user messaging (chat) and support chat screens.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    required this.isCurrentUser,
    this.initials,
    super.key,
  });

  /// Whether this is the current user's avatar (black bg) vs other user (white bg).
  final bool isCurrentUser;

  /// User initials to display (e.g. "AM"). If null or empty, shows person icon.
  final String? initials;

  List<BoxShadow> _chromeShadows({required bool isDark}) {
    // Neumorphic-ish shadows to sell a 3D "button" effect.
    // Kept subtle so it works on both light and dark chat backgrounds.
    final darkA = isDark ? 0.40 : 0.22;
    final lightA = isDark ? 0.10 : 0.85;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: darkA),
        offset: const Offset(2.5, 3),
        blurRadius: 10,
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: lightA),
        offset: const Offset(-2.5, -3),
        blurRadius: 10,
        spreadRadius: 0.5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diameter = 32.0;
    final hasInitials = initials != null && initials!.trim().isNotEmpty;

    // Slight tint difference so current user feels distinct,
    // while still reading as "chrome".
    final base = isCurrentUser
        ? (isDark ? const Color(0xFFCBD5E1) : const Color(0xFFE6E8EE))
        : (isDark ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6));
    final textColor = Colors.black;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: _chromeShadows(isDark: isDark),
        ),
        child: ClipOval(
          child: Stack(
            children: [
              // Base chrome gradient.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(base, Colors.white, isDark ? 0.08 : 0.22)!,
                        base,
                        Color.lerp(base, Colors.black, isDark ? 0.12 : 0.04)!,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // Specular highlight (top-left), like a chrome button.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.65, -0.7),
                        radius: 0.95,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.28 : 0.75),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6],
                      ),
                    ),
                  ),
                ),
              ),
              // Inner rim to reinforce 3D.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: isDark ? 0.10 : 0.08),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: hasInitials
                    ? Text(
                        initials!.trim(),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      )
                    : const ThemeIcon(Icons.person, size: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
