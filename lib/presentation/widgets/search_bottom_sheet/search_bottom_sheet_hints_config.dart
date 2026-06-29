/// Compile-time / developer toggles for search bottom sheet hints.
///
/// These are not user-facing settings; change in code when testing layout.
class SearchBottomSheetHintsConfig {
  SearchBottomSheetHintsConfig._();

  /// Metro “search all stations on this line” explainer bubble (“all 14 stations”).
  ///
  /// Disabled — re-enable by setting [metroAllStationsHintEnabled] to true.
  static const bool metroAllStationsHintEnabled = false;

  /// Layout when [metroAllStationsHintEnabled] is true:
  /// - **false** (default): Hint floats via [OverlayPortal] over the overlay
  ///   stack (does **not** add height to bottom sheet scroll content).
  /// - **true** ([metroAllStationsHintUsesInlineColumn]): Hint is inlined in the metro [Column] above the pickers —
  ///   taller sheet; use if you must avoid overlays on a particular route.
  static bool metroAllStationsHintUsesInlineColumn = false;
}
