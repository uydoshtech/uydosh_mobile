/// Compile-time / developer toggles for search bottom sheet hints.
///
/// These are not user-facing settings; change in code when testing layout.
class SearchBottomSheetHintsConfig {
  SearchBottomSheetHintsConfig._();

  /// Metro “search all stations on this line” explainer bubble.
  ///
  /// - **false** (default): Hint floats via [OverlayPortal] over the overlay
  ///   stack (does **not** add height to bottom sheet scroll content).
  /// - **true**: Hint is inlined in the metro [Column] above the pickers —
  ///   taller sheet; use if you must avoid overlays on a particular route.
  static bool metroAllStationsHintUsesInlineColumn = false;
}
