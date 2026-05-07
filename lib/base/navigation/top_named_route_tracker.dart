import "package:flutter/widgets.dart";

/// Mirrors [Route.settings.name] for the root [MaterialApp] [Navigator].
///
/// `ModalRoute.of(navigatorState.context)` is unreliable here: the navigator
/// element is not a descendant of the top [ModalRoute], so the top route must
/// be observed via [NavigatorObserver] instead.
final TopNamedRouteTracker topNamedRouteTracker = TopNamedRouteTracker();

class TopNamedRouteTracker extends NavigatorObserver {
  final List<String?> _names = <String?>[];

  /// Name of the route on top of the stack, if any.
  String? get topName => _names.isEmpty ? null : _names.last;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _names.add(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_names.isNotEmpty) {
      _names.removeLast();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final removedName = route.settings.name;
    for (var i = _names.length - 1; i >= 0; i--) {
      if (_names[i] == removedName) {
        _names.removeAt(i);
        break;
      }
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (_names.isEmpty || newRoute == null) return;
    _names[_names.length - 1] = newRoute.settings.name;
  }
}
