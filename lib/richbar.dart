library richbar;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:richbar/constants/color_constant.dart';
import 'package:richbar/constants/double_constants.dart';
import 'package:richbar/richbar_route.dart' as routes;

//
typedef RichbarStatusCallback = void Function(RichbarStatus? richbarStatus);

//
typedef OnTap = void Function(Richbar richbar);

// ignore: must_be_immutable
class Richbar<T> extends StatefulWidget {
  /// to listen to richbar events
  final RichbarStatusCallback? onStatusChanged;

  /// message text size
  final double? messageSize;

  final Alignment? titleAlignment;

  final Icon? leading;

  /// message text weight default will be normal w400
  final FontWeight? messageFontWeight;

  /// message text color default color will be white
  final Color? messageColor;

  /// action text to be displayed to the user default text will be dismissed
  final String? message;

  final Color? blockInteractionColor;

  /// Widget tray background color default color will be purple
  final Color? backgroundColor;

  /// action button color
  final Color? actionColor;

  /// a callback function that registers when user clikcs the widget / tray
  final OnTap? onPanDown;

  /// Slow down animation
  final bool? showPulse;

  // a callback functiom that registers when user clicks the button
  final VoidCallback? onPressed;

  /// time frame for the whole thing to come up and display and hide
  final Duration? duration;

  /// whether user can dismiss the widget
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

  Richbar({
    Key? key,
    this.messageSize,
    this.leading,
    this.titleAlignment = Alignment.topLeft,
    this.messageFontWeight = FontWeight.w300,
    this.messageColor = defaultTextColor,
    this.message,
    this.showPulse = true,
    this.onPressed,
    this.blockInteractionColor = Colors.transparent,
    this.backgroundColor = defaultBackgroundColor,
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

  routes.RichbarRoute<T?>? richbarRoute;

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
  late Animation<double> fadeAnimation;
  late bool _isLeadingPresent;

  late Completer<Size> _boxHeightCompleter;
  late GlobalKey? _globalKey;
  @override
  void initState() {
    super.initState();
    _globalKey = GlobalKey();
    _boxHeightCompleter = Completer<Size>();
    _isLeadingPresent = widget.leading!.size == null;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getCompleterSize();
    });
    if (widget.showPulse!) {
      _configurePulseAnimation();
    }
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  void getCompleterSize() {
    final box = _globalKey!.currentContext;
    final size = box!.size;
    _boxHeightCompleter.complete(size);
  }

  void _configurePulseAnimation() {
    _fadeController =
        AnimationController(vsync: this, duration: _pulseAnimationDuration);
    fadeAnimation = Tween(begin: _initialOpacity, end: _finalOpacity).animate(
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
                : const SizedBox();
          },
        ),
        richbar,
      ],
    );
  }

  Widget richbarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        key: _globalKey,
        height: height,
        constraints: widget.maxWidth != null
            ? BoxConstraints(maxWidth: widget.maxWidth! - widthPadding)
            : null,
        decoration: BoxDecoration(
          color: widget.backgroundColor!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: widget.backgroundColor!),
        ),
        padding: widget.padding,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _isLeadingPresent
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: widget.titleAlignment!,
                          child: widget.leading,
                        )
                      : const SizedBox(),
                  _isLeadingPresent
                      ? const SizedBox(width: widthSpacing)
                      : const SizedBox(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.message!,
                      style: TextStyle(
                        fontSize: widget.messageSize ?? 15,
                        color: widget.actionColor ?? Colors.white,
                        fontWeight: widget.messageFontWeight ?? FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///
enum RichbarPosition { top, bottom }

enum RichbarDimissibleDirection { vertical, horizontal }

enum RicharStyle { grounded, floating }

enum RichbarStatus { showing, init, dismissed, hidden }
