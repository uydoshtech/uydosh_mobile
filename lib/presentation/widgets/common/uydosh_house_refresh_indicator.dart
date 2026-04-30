import "dart:async";
import "dart:math" as math;

import "package:flutter/foundation.dart" show clampDouble;
import "package:flutter/material.dart";

/// Custom Material-style "swipe to refresh" indicator that renders a rotating
/// house icon inside the same circular badge as Flutter's [RefreshIndicator],
/// while keeping all of its drag/snap/refresh state machine semantics.
///
/// The state machine is a faithful adaptation of Flutter's built-in
/// `RefreshIndicator` so that pull-to-refresh feels identical; only the inner
/// progress widget is replaced with a small rotating [Icons.home] glyph.

const double _kDragContainerExtentPercentage = 0.25;
const double _kDragSizeFactorLimit = 1.5;
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// Continuous rotation duration during the active refresh state. Matches
/// `AppConfig.defaultHouseRotationDuration` so the spinner feels consistent
/// with other in-app house loaders.
const Duration _kHouseSpinDuration = Duration(milliseconds: 600);

typedef HouseRefreshCallback = Future<void> Function();

enum _HouseRefreshStatus { drag, armed, snap, refresh, done, canceled }

/// Pull-to-refresh widget visually identical to [RefreshIndicator], but with
/// a rotating house icon inside the circle.
class UydoshHouseRefreshIndicator extends StatefulWidget {
  const UydoshHouseRefreshIndicator({
    required this.onRefresh,
    required this.child,
    super.key,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.elevation = 2.0,
  }) : assert(elevation >= 0.0);

  final Widget child;
  final double displacement;
  final double edgeOffset;
  final HouseRefreshCallback onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final ScrollNotificationPredicate notificationPredicate;
  final String? semanticsLabel;
  final String? semanticsValue;
  final RefreshIndicatorTriggerMode triggerMode;
  final double elevation;

  @override
  State<UydoshHouseRefreshIndicator> createState() =>
      _UydoshHouseRefreshIndicatorState();
}

class _UydoshHouseRefreshIndicatorState
    extends State<UydoshHouseRefreshIndicator>
    with TickerProviderStateMixin<UydoshHouseRefreshIndicator> {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late AnimationController _spinController;
  late Animation<double> _positionFactor;
  late Animation<double> _scaleFactor;
  late Animation<Color?> _valueColor;

  _HouseRefreshStatus? _status;
  late Future<void> _pendingRefreshFuture;
  bool? _isIndicatorAtTop;
  double? _dragOffset;
  late Color _effectiveValueColor =
      widget.color ?? Theme.of(context).colorScheme.primary;

  static final Animatable<double> _kDragSizeFactorLimitTween = Tween<double>(
    begin: 0.0,
    end: _kDragSizeFactorLimit,
  );

  static final Animatable<double> _oneToZeroTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);

    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);

    _spinController = AnimationController(
      vsync: this,
      duration: _kHouseSpinDuration,
    );
  }

  @override
  void didChangeDependencies() {
    _setupColorTween();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant UydoshHouseRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _setupColorTween();
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _setupColorTween() {
    _effectiveValueColor =
        widget.color ?? Theme.of(context).colorScheme.primary;
    final color = _effectiveValueColor;
    if (color.alpha == 0x00) {
      _valueColor = AlwaysStoppedAnimation<Color>(color);
    } else {
      _valueColor = _positionController.drive(
        ColorTween(
          begin: color.withAlpha(0),
          end: color.withAlpha(color.alpha),
        ).chain(
          CurveTween(curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit)),
        ),
      );
    }
  }

  bool _shouldStart(ScrollNotification notification) {
    return ((notification is ScrollStartNotification &&
                    notification.dragDetails != null) ||
                (notification is ScrollUpdateNotification &&
                    notification.dragDetails != null &&
                    widget.triggerMode ==
                        RefreshIndicatorTriggerMode.anywhere)) &&
            ((notification.metrics.axisDirection == AxisDirection.up &&
                    notification.metrics.extentAfter == 0.0) ||
                (notification.metrics.axisDirection == AxisDirection.down &&
                    notification.metrics.extentBefore == 0.0)) &&
        _status == null &&
        _start(notification.metrics.axisDirection);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }
    if (_shouldStart(notification)) {
      setState(() {
        _status = _HouseRefreshStatus.drag;
      });
      return false;
    }
    final bool? indicatorAtTopNow = switch (notification.metrics.axisDirection) {
      AxisDirection.down || AxisDirection.up => true,
      AxisDirection.left || AxisDirection.right => null,
    };
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_status == _HouseRefreshStatus.drag ||
          _status == _HouseRefreshStatus.armed) {
        _dismiss(_HouseRefreshStatus.canceled);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_status == _HouseRefreshStatus.drag ||
          _status == _HouseRefreshStatus.armed) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.scrollDelta!;
        } else if (notification.metrics.axisDirection == AxisDirection.up) {
          _dragOffset = _dragOffset! + notification.scrollDelta!;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
      if (_status == _HouseRefreshStatus.armed &&
          notification.dragDetails == null) {
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_status == _HouseRefreshStatus.drag ||
          _status == _HouseRefreshStatus.armed) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.overscroll;
        } else if (notification.metrics.axisDirection == AxisDirection.up) {
          _dragOffset = _dragOffset! + notification.overscroll;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_status) {
        case _HouseRefreshStatus.armed:
          if (_positionController.value < 1.0) {
            _dismiss(_HouseRefreshStatus.canceled);
          } else {
            _show();
          }
        case _HouseRefreshStatus.drag:
          _dismiss(_HouseRefreshStatus.canceled);
        case _HouseRefreshStatus.canceled:
        case _HouseRefreshStatus.done:
        case _HouseRefreshStatus.refresh:
        case _HouseRefreshStatus.snap:
        case null:
          break;
      }
    }
    return false;
  }

  bool _handleIndicatorNotification(
    OverscrollIndicatorNotification notification,
  ) {
    if (notification.depth != 0 || !notification.leading) {
      return false;
    }
    if (_status == _HouseRefreshStatus.drag) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_status == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
      case AxisDirection.up:
        _isIndicatorAtTop = true;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        return false;
    }
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(_status == _HouseRefreshStatus.drag ||
        _status == _HouseRefreshStatus.armed);
    var newValue =
        _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);
    if (_status == _HouseRefreshStatus.armed) {
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    }
    _positionController.value = clampDouble(newValue, 0.0, 1.0);
    if (_status == _HouseRefreshStatus.drag &&
        _valueColor.value!.alpha == _effectiveValueColor.alpha) {
      _status = _HouseRefreshStatus.armed;
    }
  }

  Future<void> _dismiss(_HouseRefreshStatus newMode) async {
    await Future<void>.value();
    assert(newMode == _HouseRefreshStatus.canceled ||
        newMode == _HouseRefreshStatus.done);
    setState(() {
      _status = newMode;
    });
    switch (_status!) {
      case _HouseRefreshStatus.done:
        await _scaleController.animateTo(
          1.0,
          duration: _kIndicatorScaleDuration,
        );
      case _HouseRefreshStatus.canceled:
        await _positionController.animateTo(
          0.0,
          duration: _kIndicatorScaleDuration,
        );
      case _HouseRefreshStatus.armed:
      case _HouseRefreshStatus.drag:
      case _HouseRefreshStatus.refresh:
      case _HouseRefreshStatus.snap:
        assert(false);
    }
    _spinController.stop();
    if (mounted && _status == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _status = null;
      });
    }
  }

  void _show() {
    assert(_status != _HouseRefreshStatus.refresh);
    assert(_status != _HouseRefreshStatus.snap);
    final completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _status = _HouseRefreshStatus.snap;
    _positionController
        .animateTo(
          1.0 / _kDragSizeFactorLimit,
          duration: _kIndicatorSnapDuration,
        )
        .then<void>((value) {
      if (mounted && _status == _HouseRefreshStatus.snap) {
        setState(() {
          _status = _HouseRefreshStatus.refresh;
        });
        _spinController
          ..value = 0
          ..repeat();
        final refreshResult = widget.onRefresh();
        refreshResult.whenComplete(() {
          if (mounted && _status == _HouseRefreshStatus.refresh) {
            completer.complete();
            _dismiss(_HouseRefreshStatus.done);
          }
        });
      }
    });
  }

  /// Programmatically show the indicator (mirrors `RefreshIndicatorState.show`).
  Future<void> show({bool atTop = true}) {
    if (_status != _HouseRefreshStatus.refresh &&
        _status != _HouseRefreshStatus.snap) {
      if (_status == null) {
        _start(atTop ? AxisDirection.down : AxisDirection.up);
      }
      _show();
    }
    return _pendingRefreshFuture;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleIndicatorNotification,
        child: widget.child,
      ),
    );
    final showSpinningIndicator = _status == _HouseRefreshStatus.refresh ||
        _status == _HouseRefreshStatus.done;

    return Stack(
      children: <Widget>[
        child,
        if (_status != null)
          Positioned(
            top: _isIndicatorAtTop! ? widget.edgeOffset : null,
            bottom: !_isIndicatorAtTop! ? widget.edgeOffset : null,
            left: 0.0,
            right: 0.0,
            child: SizeTransition(
              axisAlignment: _isIndicatorAtTop! ? 1.0 : -1.0,
              sizeFactor: _positionFactor,
              child: Padding(
                padding: _isIndicatorAtTop!
                    ? EdgeInsets.only(top: widget.displacement)
                    : EdgeInsets.only(bottom: widget.displacement),
                child: Align(
                  alignment: _isIndicatorAtTop!
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  child: ScaleTransition(
                    scale: _scaleFactor,
                    child: AnimatedBuilder(
                      animation: Listenable.merge(<Listenable>[
                        _positionController,
                        _spinController,
                      ]),
                      builder: (context, _) {
                        return _HouseRefreshBadge(
                          color: _valueColor.value ?? _effectiveValueColor,
                          backgroundColor: widget.backgroundColor ??
                              Theme.of(context).canvasColor,
                          elevation: widget.elevation,
                          rotationTurns: showSpinningIndicator
                              ? _spinController.value
                              // While dragging, give the icon a small
                              // pre-rotation that scales with pull progress so
                              // it feels alive (mirrors the original arrow
                              // animation).
                              : _positionController.value * 0.75,
                          semanticsLabel: widget.semanticsLabel ??
                              MaterialLocalizations.of(context)
                                  .refreshIndicatorSemanticLabel,
                          semanticsValue: widget.semanticsValue,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Visual badge: same outer dimensions as Flutter's `RefreshProgressIndicator`
/// (41 px circle inside a 4 px margin), housing a small rotating house icon
/// matching the original spinner footprint (~17 px).
class _HouseRefreshBadge extends StatelessWidget {
  const _HouseRefreshBadge({
    required this.color,
    required this.backgroundColor,
    required this.elevation,
    required this.rotationTurns,
    this.semanticsLabel,
    this.semanticsValue,
  });

  static const double _badgeSize = 41.0;
  static const EdgeInsets _badgeMargin = EdgeInsets.all(4.0);
  static const EdgeInsets _badgePadding = EdgeInsets.all(12.0);
  static const double _iconSize = 17.0; // _badgeSize - horizontal padding (24).

  final Color color;
  final Color backgroundColor;
  final double elevation;

  /// Full-turn fraction (0..1, can wrap). Used as the rotation angle.
  final double rotationTurns;

  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  Widget build(BuildContext context) {
    final opacity = (color.alpha / 255.0).clamp(0.0, 1.0);
    final solidColor = Color.fromARGB(
      255,
      color.red,
      color.green,
      color.blue,
    );

    return Semantics(
      label: semanticsLabel,
      value: semanticsValue,
      child: Padding(
        padding: _badgeMargin,
        child: SizedBox.fromSize(
          size: const Size.square(_badgeSize),
          child: Material(
            type: MaterialType.circle,
            color: backgroundColor,
            elevation: elevation,
            child: Padding(
              padding: _badgePadding,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotationTurns * 2 * math.pi,
                  child: Icon(
                    Icons.home,
                    size: _iconSize,
                    color: solidColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
