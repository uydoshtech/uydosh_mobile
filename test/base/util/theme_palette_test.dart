import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/util/theme_helper.dart";

void main() {
  group("ThemePalette screen canvas", () {
    test("light theme uses neutral surface (matches AppBar theme in app_theme)", () {
      const palette = ThemePalette(isLightTheme: true, isBlueTheme: false);
      expect(palette.screenCanvasColor, LightThemeColors.surface);
    });

    test("blue theme uses blue background", () {
      const palette = ThemePalette(isLightTheme: false, isBlueTheme: true);
      expect(palette.screenCanvasColor, BlueThemeColors.background);
    });

    test("non-light non-blue fallback matches light surface (safe default)", () {
      const palette = ThemePalette(isLightTheme: false, isBlueTheme: false);
      expect(palette.screenCanvasColor, LightThemeColors.surface);
    });
  });
}
