import "package:flutter/foundation.dart";

/// Global state for whether Home's inline-search ribbon is active.
///
/// This is used by the main shell AppBar to decide whether to show the
/// listings result count next to the Home title. When the user closes the
/// ribbon (X), the title should return to normal.
class HomeInlineSearchState extends ChangeNotifier {
  factory HomeInlineSearchState() => _instance;
  HomeInlineSearchState._internal();
  static final HomeInlineSearchState _instance =
      HomeInlineSearchState._internal();

  bool _isActive = false;

  bool get isActive => _isActive;

  void setActive(bool v) {
    if (_isActive == v) return;
    _isActive = v;
    notifyListeners();
  }
}

