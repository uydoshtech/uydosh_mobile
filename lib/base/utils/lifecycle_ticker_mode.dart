import "dart:async" show unawaited;

import "package:flutter/material.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";

/// Wraps [child] in a [TickerMode] that disables tickers — so every
/// [AnimationController] using `TickerProviderStateMixin` (or any other
/// `vsync`-bound `Ticker`) below this point pauses — whenever the app is not
/// in [AppLifecycleState.resumed].
///
/// Why this exists: Flutter's [SchedulerBinding] only stops scheduling frame
/// callbacks for the `paused`/`detached` lifecycle states. The `inactive` and
/// `hidden` states (notification shade pulled down, Control Center, incoming
/// call UI, brief app-switch peeks, system permission prompt, screen
/// fade-to-black before the app goes to background, etc.) still receive
/// frames — and any infinite `controller.repeat()` keeps burning CPU/GPU even
/// though the user isn't actively looking at our app.
///
/// Mounted once near the root of the widget tree (inside `MaterialApp.builder`
/// so it's an ancestor of the [Navigator] subtree but a descendant of the
/// localization/theme providers), this widget cuts that drain to zero with no
/// per-screen edits.
///
/// Note that because [TickerMode] is consulted by `TickerProviderStateMixin`
/// via an inherited-widget dependency, every existing animation controller in
/// the app picks this up automatically the next time
/// `didChangeDependencies()` runs after this widget rebuilds.
class LifecycleTickerMode extends StatefulWidget {
  const LifecycleTickerMode({required this.child, super.key});

  final Widget child;

  @override
  State<LifecycleTickerMode> createState() => _LifecycleTickerModeState();
}

class _LifecycleTickerModeState extends State<LifecycleTickerMode>
    with WidgetsBindingObserver {
  bool _resumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initial = WidgetsBinding.instance.lifecycleState;
    // `lifecycleState` is null on cold start until the platform reports the
    // first state. Default to `resumed` in that window so the very first
    // frame doesn't paint with all animations frozen.
    _resumed = initial == null || initial == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Survive simulator stops / background kills: flush search filters that
      // may still be sitting in the prefs write chain or remote debounce.
      unawaited(SearchFiltersState().flushPendingLocalAndRemotePersist());
    }
    final isResumed = state == AppLifecycleState.resumed;
    if (isResumed != _resumed) {
      setState(() => _resumed = isResumed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(enabled: _resumed, child: widget.child);
  }
}
