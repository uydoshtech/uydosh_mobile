import "package:flutter/rendering.dart" show ScrollDirection;
import "package:flutter/widgets.dart";
import "package:uy_dosh/presentation/widgets/animated_featured_border.dart";

/// Tracks whether the home (or similar) feed is actively being scrolled by the
/// user. Feed tiles read this to drop expensive effects (backdrop blur, animated
/// featured rings) while the list is moving.
class FeedScrollScope extends InheritedWidget {
  const FeedScrollScope({
    required this.isUserScrolling,
    required super.child,
    super.key,
  });

  final bool isUserScrolling;

  static bool isUserScrollingOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<FeedScrollScope>()
            ?.isUserScrolling ??
        false;
  }

  @override
  bool updateShouldNotify(FeedScrollScope oldWidget) {
    return oldWidget.isUserScrolling != isUserScrolling;
  }
}

/// Wraps a vertical feed [child] and publishes [FeedScrollScope].
class FeedScrollScopeHost extends StatefulWidget {
  const FeedScrollScopeHost({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<FeedScrollScopeHost> createState() => _FeedScrollScopeHostState();
}

class _FeedScrollScopeHostState extends State<FeedScrollScopeHost> {
  final ValueNotifier<bool> _isUserScrolling = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isUserScrolling.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is UserScrollNotification) {
      final next = notification.direction != ScrollDirection.idle;
      if (next != _isUserScrolling.value) {
        _isUserScrolling.value = next;
        if (next) {
          SharedFeaturedSweep.instance.pauseForUserScroll();
        } else {
          SharedFeaturedSweep.instance.resumeFromUserScroll();
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      // Important: pass [widget.child] as ValueListenableBuilder.child so the
      // scrollable subtree is NOT rebuilt when scroll start/stop toggles.
      // A setState()-based host used to rebuild the entire CustomScrollView,
      // which remounted PlatformViews (mini 3D SceneKit / WebView) on every
      // fling — looking like a full scene reload.
      child: ValueListenableBuilder<bool>(
        valueListenable: _isUserScrolling,
        builder: (context, scrolling, child) {
          return FeedScrollScope(
            isUserScrolling: scrolling,
            child: child!,
          );
        },
        child: widget.child,
      ),
    );
  }
}
