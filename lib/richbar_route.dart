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
            onTap: richbar.onPanDown != null
                ? () => richbar.onPanDown!(richbar)
                : null,
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
          _startAlignment = const Alignment(-1.0, 2.0);
          _endAlignment = const Alignment(-1.0, 1.0);
          break;
        }
    }
  }

  Future<T> get completed => completer.future;
  bool get opaque => false;

  // Dismissble
  @override
  Future<RoutePopDisposition> willPop() {
    if (richbar.isDismissible! == false) {
      return Future.value(RoutePopDisposition.doNotPop);
    }
    return Future.value(RoutePopDisposition.pop);
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    final entrys = <OverlayEntry>[];
    if (richbar.enableBackgroundInteraction) {
      entrys.add(
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
    } else {
      entrys.add(
        OverlayEntry(
          builder: (BuildContext context) {
            final Widget annotatedWidget = Semantics(
              focused: false,
              container: true,
              explicitChildNodes: true,
              child: AlignTransition(
                alignment: _animation!,
                child: richbar.isDismissible!
                    ? dimissible(builder)
                    : Container(margin: richbar.margin, child: builder),
              ),
            );
            return annotatedWidget;
          },
          maintainState: false,
          opaque: opaque,
        ),
      );
    }
    return entrys;
  }

  Widget _bgOverlay() {
    if (_filterBlur != null && _filterColor != null) {
      return AnimatedBuilder(
        animation: _filterBlur!,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _filterBlur!.value,
              sigmaY: _filterBlur!.value,
            ),
            child: Container(
              constraints: const BoxConstraints.expand(),
              color: _filterColor!.value,
            ),
          );
        },
      );
    } else if (_filterBlur != null) {
      return AnimatedBuilder(
        animation: _filterBlur!,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _filterBlur!.value,
              sigmaY: _filterBlur!.value,
            ),
            child: Container(
              constraints: const BoxConstraints.expand(),
              color: Colors.transparent,
            ),
          );
        },
      );
    } else if (_filterColor != null) {
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
  int customKey = 0;

  Widget dimissible(Widget child) {
    return Dismissible(
      key: Key(customKey.toString()),
      direction: richbar.richbarDimissibleDirection ==
              RichbarDimissibleDirection.horizontal
          ? DismissDirection.horizontal
          : DismissDirection.vertical,
      resizeDuration: null,
      confirmDismiss: (_) {
        if (richbarStatus == RichbarStatus.init ||
            richbarStatus == RichbarStatus.hidden) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      onDismissed: (_) {
        customKey += 1;
        _cancel();
        _isDismissible = true;
        isCurrent ? navigator!.pop() : navigator!.removeRoute(this);
      },
      child: Container(margin: richbar.margin, child: builder),
    );
  }

  //
  @override
  bool get finishedWhenPopped =>
      _animationController!.status == AnimationStatus.dismissed;

  // GETTERS
  Animation<Alignment>? get animation => _animation;
  Animation<Alignment>? _animation;

  // PROTECTED
  @protected
  AnimationController? get animationController => _animationController;
  AnimationController? _animationController;

  AnimationController createAnimationController() {
    return AnimationController(
      duration: richbar.duration,
      debugLabel: debugLabel,
      vsync: navigator!,
    );
  }

  Animation<Alignment> createAnimation() {
    return AlignmentTween(begin: _startAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: richbar.showCurve,
        reverseCurve: richbar.dismissCurve,
      ),
    );
  }

  Animation<double>? createBlurFilterAnimation() {
    // ignore: unnecessary_null_comparison
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
    // ignore: unnecessary_null_comparison
    if (richbar.blur == null) return null;
    return ColorTween(
            begin: Colors.transparent, end: richbar.blockInteractionColor)
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
        richbarStatus = RichbarStatus.hidden;
        if (onStatusChanged != null) onStatusChanged!(richbarStatus);
        if (overlayEntries.isNotEmpty) overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        assert(!overlayEntries.first.opaque);
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
    super.install();
    _animationController = createAnimationController();
    _filterBlur = createBlurFilterAnimation();
    _filterColor = createColorFilterAnimation();
    _animation = createAnimation();
  }

  @override
  TickerFuture didPush() {
    super.didPush();
    _animation!.addStatusListener(_handleStatusChanged);
    _configureTimer();
    return _animationController!.forward();
  }

  @override
  void didReplace(Route<dynamic>? oldRoute) {
    super.didReplace(oldRoute);
    if (oldRoute is RichbarRoute) {
      _animationController!.value = oldRoute._animationController!.value;
    }
    _animation!.addStatusListener(_handleStatusChanged);
  }

  @override
  bool didPop(T? result) {
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

  bool canTransitionTo(RichbarRoute<dynamic> nextRoute) => true;
  bool canTransitionFrom(RichbarRoute<dynamic> previousRoute) => true;
  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    completer.complete(_result);
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
    routeSettings: const RouteSettings(name: richbarroute),
  );

  
}
