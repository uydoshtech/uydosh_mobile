import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class UyDoshIcon extends ThemeIcon {
  const UyDoshIcon(
    super.icon, {
    super.key,
    super.size,
    super.color,
    super.useThemeColor,
    super.semanticLabel,
    super.textDirection,
  });
}

@Deprecated("Use UyDoshIcon instead.")
class UydoshIcon extends UyDoshIcon {
  const UydoshIcon(
    super.icon, {
    super.key,
    super.size,
    super.color,
    super.useThemeColor,
    super.semanticLabel,
    super.textDirection,
  });
}
