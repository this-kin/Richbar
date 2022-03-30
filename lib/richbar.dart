library richflushbar;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:richflushbar/richbar_route.dart' as routes;

typedef RichbarStatusCallback = void Function(RichbarStatus? richbarStatus);
typedef OnTap = void Function(Richbar richbar);

class Richbar<T> extends StatefulWidget {
  ///
  final RichbarStatusCallback? onStatusChanged;

  /// The message to be displayed to the user
  final String? title;

  /// message text size
  final double? titleFontSize;

  /// message text weight default will be normal w400
  final FontWeight titleFontWeight;

  /// message text color default color will be white
  final Color? titleTextColor;

  /// action text to be displayed to the user default text will be dismissed
  final String? text;

  /// action text size
  final double? textFontSize;

  /// action text color
  final Color? textColor;

  /// action text font weight will be bold w700-800
  final FontWeight? textFontWeight;

  /// Widget tray background color default color will be purple
  final Color? backgroundColor;

  /// action button color
  final Color? actionColor;

  /// a callback function that registers when user clikcs the widget / tray
  final OnTap? onPanDown;

  ///
  final bool? showPulse;

  // a callback functiom that registers when user clicks the button
  final VoidCallback? onPressed;

  /// time frame for the whole thing to come up and display and hide
  final Duration? duration;

  /// whether user can dismiss while animating
  final bool? isDismissible;

  /// use to control the width of the bar especially on big screens
  final double? maxWidth;

  /// custom marging on bar
  final EdgeInsets margin;

  /// custom padding on bar
  final EdgeInsets padding;

  /// adds border radius  to the action button
  final BorderRadius? borderRadius;

  /// Richbar can be set on [RichbarPosition.top] or [RichbarPosition.bottom]
  final RichbarPosition richbarPosition;

  /// dismiss direction horizontal swipe or vertical
  final RichbarDimissibleDirection richbarDimissibleDirection;

  /// Richbar can be floating or be grounded to the edge of the screen.
  final RicharStyle richbarStyle;

  /// Curve animation applied when show() is called Curves.easeIn will be default
  final Curve showCurve;

  /// Curve animation applied when dismiss() is called Curves.easeIn will be default
  final Curve dismissCurve;

  /// action button blur 0.4 will be default
  final double blur;

  /// whether user can interact with screen when bar is displaying
  final bool enableBackgroundInteraction;

  routes.RichbarRoute<T?>? richbarRoute;

  Richbar({
    Key? key,
    this.title,
    this.titleFontSize,
    this.titleFontWeight = FontWeight.w400,
    this.titleTextColor = Colors.white,
    this.text = "Dismiss",
    this.textFontSize,
    this.showPulse = true,
    this.textColor,
    this.onPressed,
    this.textFontWeight,
    this.backgroundColor = const Color(0xFF753FF6),
    this.actionColor,
    this.onPanDown,
    this.duration,
    this.isDismissible = false,
    this.maxWidth,
    this.margin = const EdgeInsets.symmetric(),
    this.padding = const EdgeInsets.all(15),
    this.borderRadius,
    this.richbarPosition = RichbarPosition.top,
    this.richbarDimissibleDirection = RichbarDimissibleDirection.vertical,
    this.richbarStyle = RicharStyle.floating,
    this.showCurve = Curves.easeOutCirc,
    this.dismissCurve = Curves.easeOutCirc,
    this.blur = 0.5,
    this.enableBackgroundInteraction = false,
    RichbarStatusCallback? onStatusChanged,
    this.richbarRoute,
    // ignore: prefer_initializing_formals
  })  : onStatusChanged = onStatusChanged,
        super(key: key) {
    onStatusChanged = onStatusChanged ?? (status) {};
  }

  Future<T?> show(BuildContext context) async {
    richbarRoute = routes.showRichbar<T>(
      context: context,
      richbar: this,
    ) as routes.RichbarRoute<T?>;

    return await Navigator.of(context, rootNavigator: false)
        .push(richbarRoute as Route<T>);
  }

  Future<T?> dismiss([T? result]) async {
    // If route was never initialized, do nothing
    if (richbarRoute == null) {
      return null;
    }

    if (richbarRoute!.isCurrent) {
      richbarRoute!.navigator!.pop(result);
      return richbarRoute!.completed;
    } else if (richbarRoute!.isActive) {
      // removeRoute is called every time you dismiss a Flushbar that is not the top route.
      // It will not animate back and listeners will not detect FlushbarStatus.IS_HIDING or FlushbarStatus.DISMISSED
      // To avoid this, always make sure that Flushbar is the top route when it is being dismissed
      richbarRoute!.navigator!.removeRoute(richbarRoute!);
    }
    return null;
  }

  bool showing() {
    if (richbarRoute == null) {
      return false;
    }
    // ignore: unrelated_type_equality_checks
    return richbarRoute!.isCurrent == RichbarStatus.showing;
  }

  bool dismissed() {
    if (richbarRoute == null) {
      return false;
    }
    // ignore: unrelated_type_equality_checks
    return richbarRoute!.isCurrent == RichbarStatus.dismissed;
  }

  bool init() {
    if (richbarRoute == null) {
      return false;
    }
    // ignore: unrelated_type_equality_checks
    return richbarRoute!.isCurrent == RichbarStatus.init;
  }

  bool hidden() {
    if (richbarRoute == null) {
      return false;
    }
    // ignore: unrelated_type_equality_checks
    return richbarRoute!.isCurrent == RichbarStatus.hidden;
  }

  @override
  State<Richbar> createState() => _RichbarState();
}

class _RichbarState<K extends Object?> extends State<Richbar<K>>
    with TickerProviderStateMixin {
  final Duration _pulseAnimationDuration = const Duration(seconds: 1);
  final double _initialOpacity = 1.0;
  final double _finalOpacity = 0.4;

  RichbarStatus? richbarStatus;
  AnimationController? _fadeController;
  late Animation<double> _fadeAnimation;
  late bool _isTitlePresent;

  late Completer<Size> _boxHeightCompleter;
  late GlobalKey? _globalKey;
  @override
  void initState() {
    super.initState();
    _globalKey = GlobalKey();
    _boxHeightCompleter = Completer<Size>();
    _isTitlePresent = (widget.title != null);
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      getCompleterSize();
    });
    if (widget.showPulse!) {
      _configurePulseAnimation();
    }
  }

  void getCompleterSize() {
    final box = _globalKey!.currentContext;
    final size = box!.size;
    _boxHeightCompleter.complete(size);
  }

  void _configurePulseAnimation() {
    _fadeController =
        AnimationController(vsync: this, duration: _pulseAnimationDuration);
    _fadeAnimation = Tween(begin: _initialOpacity, end: _finalOpacity).animate(
      CurvedAnimation(
        parent: _fadeController!,
        curve: Curves.linear,
      ),
    );

    _fadeController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeController!.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        _fadeController!.forward();
      }
    });

    _fadeController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context).viewInsets;
    return Align(
      alignment: widget.richbarPosition == RichbarPosition.top
          ? Alignment.topCenter
          : Alignment.bottomCenter,
      heightFactor: 1.0,
      child: Material(
        color: widget.richbarStyle == RicharStyle.floating
            ? Colors.transparent
            : widget.backgroundColor,
        child: SafeArea(
          minimum: widget.richbarPosition == RichbarPosition.bottom
              ? EdgeInsets.only(bottom: mediaquery.bottom)
              : EdgeInsets.only(top: mediaquery.top),
          bottom: widget.richbarPosition == RichbarPosition.bottom,
          top: true,
          left: false,
          right: false,
          child: _getRichar(),
        ),
      ),
    );
  }

  Widget _getRichar() {
    Widget richbar = richbarWidget();
    return Stack(
      children: [
        FutureBuilder(
          future: _boxHeightCompleter.future,
          builder: (context, AsyncSnapshot<Size> snapshot) {
            return snapshot.hasData
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur,
                      sigmaY: widget.blur,
                    ),
                    child: Container(
                      height: snapshot.data!.height,
                      width: snapshot.data!.width,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  )
                : _emptyWidget();
          },
        ),
        richbar,
      ],
    );
  }

  Widget richbarWidget() {
    return Container(
      key: _globalKey,
      height: 130,
      constraints: widget.maxWidth != null
          ? BoxConstraints(maxWidth: widget.maxWidth!)
          : null,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
      ),
      padding: widget.padding,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _isTitlePresent
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: widget.padding.top,
                          bottom: widget.padding.bottom,
                          left: widget.padding.left,
                          right: widget.padding.right,
                        ),
                        child: Text(
                          widget.title ?? "",
                          style: TextStyle(
                            fontSize: widget.titleFontSize ?? 14.0,
                            color: widget.titleTextColor ?? Colors.white,
                            fontWeight: widget.titleFontWeight,
                          ),
                        ),
                      )
                    : _emptyWidget(),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(50),
                    ),
                    alignment: Alignment.center,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: widget.onPressed,
                        borderRadius:
                            widget.borderRadius ?? BorderRadius.circular(50),
                        child: Center(
                          heightFactor: 3.8,
                          child: Text(
                            widget.text!,
                            style: TextStyle(
                              color: widget.actionColor ?? Colors.white,
                              fontWeight:
                                  widget.textFontWeight ?? FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  SizedBox _emptyWidget() {
    return const SizedBox();
  }
}

///
enum RichbarPosition { top, bottom }
enum RichbarDimissibleDirection { vertical, horizontal }
enum RicharStyle { grounded, floating }
enum RichbarStatus { showing, init, dismissed, hidden }
