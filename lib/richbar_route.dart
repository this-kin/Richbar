import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:richflushbar/constants/string_constant.dart';
import 'package:richflushbar/richbar.dart';

class RichbarRoute<T> extends OverlayRoute<T> {
  final Richbar richbar;
  final Builder builder;
  final Completer<T> completer = Completer<T>();
  final RichbarStatusCallback? onStatusChanged;

  Animation<double>? _filterBlur;
  Animation<Color?>? _filterColor;
  Alignment? _startAlignment;
  Alignment? _endAlignment;
  bool _isDismissible = false;
  Timer? _t;
  T? _result;
  RichbarStatus? richbarStatus;

  RichbarRoute({
    required this.richbar,
    RouteSettings? routeSettings,
  })  : builder = Builder(builder: (BuildContext context) {
          return GestureDetector(
            onTap: richbar.onTap != null ? () => richbar.onTap!(richbar) : null,
            child: richbar,
          );
        }),
        onStatusChanged = richbar.onStatusChanged,
        super(settings: routeSettings) {
    _configAlignment(richbar.richbarPosition);
  }

  void _configAlignment(RichbarPosition richbarPosition) {
    switch (richbar.richbarPosition) {
      case RichbarPosition.top:
        {
          _startAlignment = const Alignment(-1.0, -2.0);
          _endAlignment = const Alignment(-1.0, -1.0);
          break;
        }
      case RichbarPosition.bottom:
        {
          _startAlignment = const Alignment(-1.0, -2.0);
          _endAlignment = const Alignment(-1.0, -1.0);
          break;
        }
    }
  }

  Future<T> get completed => completer.future;
  bool get opaque => false;

  // WILL POP
  @override
  Future<RoutePopDisposition> willPop() {
    if (richbar.isDismissible!) {
      return Future.value(RoutePopDisposition.doNotPop);
    }
    return Future.value(RoutePopDisposition.pop);
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    final overlays = <OverlayEntry>[];

    if (richbar.enableBackgroundInteraction) {
      overlays.add(
        OverlayEntry(
          builder: (BuildContext context) {
            return Listener(
              onPointerDown:
                  richbar.isDismissible! ? (_) => richbar.dismiss() : null,
              child: _bgOverlay(),
            );
          },
          maintainState: false,
          opaque: opaque,
        ),
      );
    }
    overlays.add(
      OverlayEntry(
        builder: (BuildContext context) {
          final Widget annotatedWidget = Semantics(
            focused: false,
            container: true,
            explicitChildNodes: true,
            child: AlignTransition(
              alignment: _animation!,
              child:
                  richbar.isDismissible! ? dimissible(builder) : _getRichbar(),
            ),
          );
          return annotatedWidget;
        },
        maintainState: false,
        opaque: opaque,
      ),
    );

    return overlays;
  }

  Widget _bgOverlay() {
    if (_filterBlur != null && _filterColor != null) {
      return AnimatedBuilder(
        animation: _filterBlur!,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: _filterBlur!.value, sigmaY: _filterBlur!.value),
            child: Container(
              constraints: const BoxConstraints.expand(),
              color: _filterColor!.value,
            ),
          );
        },
      );
    }
    if (_filterBlur != null) {
      return AnimatedBuilder(
        animation: _filterBlur!,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: _filterBlur!.value, sigmaY: _filterBlur!.value),
            child: Container(
              constraints: const BoxConstraints.expand(),
              color: Colors.transparent,
            ),
          );
        },
      );
    }

    if (_filterColor != null) {
      return AnimatedBuilder(
        animation: _filterColor!,
        builder: (builder, child) {
          return Container(
            constraints: const BoxConstraints.expand(),
            color: _filterColor!.value,
          );
        },
      );
    }
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.transparent,
    );
  }

  //
  String customKey = "";

  dimissible(Widget child) {
    return Dismissible(
      key: Key(customKey),
      child: _getRichbar(),
      direction: _getDirection(),
      resizeDuration: null,
      confirmDismiss: (_) {
        if (richbarStatus == RichbarStatus.init ||
            richbarStatus == RichbarStatus.hidden) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      onDismissed: (_) {
        customKey += "1";
        _cancel();
        _isDismissible = true;

        if (isCurrent) {
          navigator!.pop();
        } else {
          navigator!.removeRoute(this);
        }
      },
    );
  }

  DismissDirection _getDirection() {
    if (richbar.richbarDimissibleDirection ==
        RichbarDimissibleDirection.horizontal) {
      return DismissDirection.horizontal;
    } else {
      if (richbar.richbarDimissibleDirection ==
          RichbarDimissibleDirection.vertical) {
        return DismissDirection.up;
      } else {
        return DismissDirection.down;
      }
    }
  }

  Widget _getRichbar() {
    return Container(
      margin: richbar.margin,
      child: builder,
    );
  }

  @override
  bool get finishedPopped =>
      _animationController!.status == AnimationStatus.dismissed;

  Animation<Alignment>? get animation => _animation;
  Animation<Alignment>? _animation;

  @protected
  AnimationController? get animationController => _animationController;
  AnimationController? _animationController;

  AnimationController createAnimationController() {
    assert(!completer.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    assert(richbar.duration! >= Duration.zero);
    return AnimationController(
      duration: richbar.duration,
      debugLabel: debugLabel,
      vsync: navigator!,
    );
  }

  Animation<Alignment> createAnimation() {
    assert(!completer.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    assert(_animationController != null);
    return AlignmentTween(begin: _startAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: richbar.showCurve,
        reverseCurve: richbar.dismissCurve,
      ),
    );
  }

  Animation<double>? createBlurFilterAnimation() {
    if (richbar.blur == null) return null;
    return Tween(begin: 0.0, end: richbar.blur).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Animation<Color?>? createColorFilterAnimation() {
    if (richbar.backgroundColor == null) return null;
    return ColorTween(begin: Colors.transparent, end: richbar.backgroundColor)
        .animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        richbarStatus = RichbarStatus.showing;
        if (onStatusChanged != null) onStatusChanged!(richbarStatus);
        if (overlayEntries.isNotEmpty) overlayEntries.first.opaque = opaque;

        break;
      case AnimationStatus.forward:
        richbarStatus = RichbarStatus.init;
        if (onStatusChanged != null) onStatusChanged!(richbarStatus);
        break;
      case AnimationStatus.reverse:
        richbarStatus = RichbarStatus.showing;
        if (onStatusChanged != null) onStatusChanged!(richbarStatus);
        if (overlayEntries.isNotEmpty) overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        assert(!overlayEntries.first.opaque);
        // We might still be the current route if a subclass is controlling the
        // the transition and hits the dismissed status. For example, the iOS
        // back gesture drives this animation to the dismissed status before
        // popping the navigator.
        richbarStatus = RichbarStatus.dismissed;
        if (onStatusChanged != null) onStatusChanged!(richbarStatus);

        if (!isCurrent) {
          navigator!.finalizeRoute(this);
          if (overlayEntries.isNotEmpty) {
            overlayEntries.clear();
          }
          assert(overlayEntries.isEmpty);
        }
        break;
    }
    changedInternalState();
  }

  @override
  void install() {
    assert(!completer.isCompleted,
        'Cannot install a $runtimeType after disposing it.');
    _animationController = createAnimationController();
    assert(_animationController != null,
        '$runtimeType.createAnimationController() returned null.');
    _filterBlur = createBlurFilterAnimation();
    _filterColor = createColorFilterAnimation();
    _animation = createAnimation();
    assert(_animation != null, '$runtimeType.createAnimation() returned null.');
    super.install();
  }

  @override
  TickerFuture didPush() {
    assert(_animationController != null,
        '$runtimeType.didPush called before calling install() or after calling dispose().');
    assert(!completer.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    _animation!.addStatusListener(_handleStatusChanged);
    _configureTimer();
    super.didPush();
    return _animationController!.forward();
  }

  @override
  void didReplace(Route<dynamic>? oldRoute) {
    assert(_animationController != null,
        '$runtimeType.didReplace called before calling install() or after calling dispose().');
    assert(!completer.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    if (oldRoute is RichbarRoute) {
      _animationController!.value = oldRoute._animationController!.value;
    }
    _animation!.addStatusListener(_handleStatusChanged);
    super.didReplace(oldRoute);
  }

  @override
  bool didPop(T? result) {
    assert(_animationController != null,
        '$runtimeType.didPop called before calling install() or after calling dispose().');
    assert(!completer.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');

    _result = result;
    _cancel();

    if (_isDismissible) {
      Timer(const Duration(milliseconds: 200), () {
        _animationController!.reset();
      });

      _isDismissible = false;
    } else {
      _animationController!.reverse();
    }

    return super.didPop(result);
  }

  void _configureTimer() {
    if (richbar.duration != null) {
      if (_t != null && _t!.isActive) {
        _t!.cancel();
      }
      _t = Timer(richbar.duration!, () {
        if (isCurrent) {
          navigator!.pop();
        } else if (isActive) {
          navigator!.removeRoute(this);
        }
      });
    } else {
      if (_t != null) {
        _t!.cancel();
      }
    }
  }

  void _cancel() {
    if (_t != null && _t!.isActive) {
      _t!.cancel();
    }
  }

  /// Whether this route can perform a transition to the given route.
  ///
  /// Subclasses can override this method to restrict the set of routes they
  /// need to coordinate transitions with.
  bool canTransitionTo(RichbarRoute<dynamic> nextRoute) => true;

  /// Whether this route can perform a transition from the given route.
  ///
  /// Subclasses can override this method to restrict the set of routes they
  /// need to coordinate transitions with.
  bool canTransitionFrom(RichbarRoute<dynamic> previousRoute) => true;

  @override
  void dispose() {
    assert(!completer.isCompleted, 'Cannot dispose a $runtimeType twice.');
    _animationController?.dispose();
    completer.complete(_result);
    super.dispose();
  }

  /// A short description of this route useful for debugging.
  String get debugLabel => '$runtimeType';

  @override
  String toString() => '$runtimeType(animation: $_animationController)';
}

RichbarRoute showRichbar<T>(
    {required BuildContext context, required Richbar richbar}) {
  return RichbarRoute<T>(
    richbar: richbar,
    routeSettings: const RouteSettings(name: RICHFLUSHBAR_ROUTE),
  );
}
