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
  bool _isUserScrolling = false;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is UserScrollNotification) {
      final next = notification.direction != ScrollDirection.idle;
      if (next != _isUserScrolling) {
        setState(() => _isUserScrolling = next);
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
      child: FeedScrollScope(
        isUserScrolling: _isUserScrolling,
        child: widget.child,
      ),
    );
  }
}
