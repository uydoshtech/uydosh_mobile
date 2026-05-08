/// Compile-time / developer toggles for search bottom sheet hints.
///
/// These are not user-facing settings; change in code when testing layout.
class SearchBottomSheetHintsConfig {
  SearchBottomSheetHintsConfig._();

  /// Metro “search all stations on this line” explainer bubble.
  ///
  /// - **true** (default): Hint is a [Column] child above the line / station
  ///   pickers. Slightly taller sheet, but reliable (no [Overlay] / [LayerLink]
  ///   issues inside modal bottom sheets).
  /// - **false**: Hint is drawn in an [Overlay] anchored to the station wheel
  ///   (does not grow sheet height; can fail to composite on some platforms).
  static bool metroAllStationsHintUsesInlineColumn = true;
}
