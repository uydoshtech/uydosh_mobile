import "package:flutter/widgets.dart";

extension SafeStateX<T extends StatefulWidget> on State<T> {
  /// Calls `setState` only if the State is still mounted.
  ///
  /// This is the most common guard we need after async work completes.
  void setStateIfMounted(VoidCallback fn) {
    if (!mounted) return;
    // ignore: invalid_use_of_protected_member
    setState(fn);
  }

  /// Convenience for "finish async work → update UI" paths.
  ///
  /// Example:
  /// `await something(); if (!mounted) return; ...`
  /// becomes:
  /// `await something(); return ifMounted(() { ... });`
  R? ifMounted<R>(R Function() fn) {
    if (!mounted) return null;
    return fn();
  }
}

