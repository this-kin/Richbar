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
  final String? message;

  /// message text size
  final double? messageSize;

  /// message text weight default will be normal w400
  final FontWeight messageWeight;

  /// message text color default color will be white
  final Color? messageColor;

  /// replaces the message
  final Widget? messageText;

  /// action text to be displayed to the user default text will be dismissed
  final String? actionText;

  /// action text size
  final double? actionTextSize;

  /// action text color
  final Color? actionTextColor;

  /// action text font weight will be bold w700-800
  final FontWeight? actionTextWeight;

  /// Widget tray background color default color will be purple
  final Color? backgroundColor;

  /// action button color
  final Color? actionColor;

  /// a callback function that registers user's click
  final OnTap? onTap;

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
    this.onStatusChanged,
    this.message,
    this.messageSize,
    this.messageWeight = FontWeight.w400,
    this.messageColor = Colors.white,
    this.messageText,
    this.actionText = "Dismiss",
    this.actionTextSize,
    this.actionTextColor,
    this.actionTextWeight,
    this.backgroundColor = const Color(0xFF753FF6),
    this.actionColor,
    this.onTap,
    this.duration,
    this.isDismissible,
    this.maxWidth,
    this.margin = const EdgeInsets.symmetric(),
    this.padding = const EdgeInsets.all(24),
    this.borderRadius,
    this.richbarPosition = RichbarPosition.top,
    this.richbarDimissibleDirection = RichbarDimissibleDirection.vertical,
    this.richbarStyle = RicharStyle.floating,
    this.showCurve = Curves.easeIn,
    this.dismissCurve = Curves.easeIn,
    this.blur = 0.5,
    this.enableBackgroundInteraction = false,
    this.richbarRoute,
    // ignore: prefer_initializing_formals
  }); //: onStatusChanged = onStatusChanged,
  //       super(key: key) {
  //  // onStatusChanged = onStatusChanged ?? (status) {};
  // }

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
  final Widget _emptyWidget = const SizedBox();
  final double _initialOpacity = 1.0;
  final double _finalOpacity = 0.4;

  GlobalKey? _backgroundBoxKey;
  RichbarStatus? richbarStatus;
  AnimationController? _fadeController;
  late Animation<double> _fadeAnimation;
  late bool _isTitlePresent;
  late double _messageTopMargin;
  late FocusAttachment _focusAttachment;
  late Completer<Size> _boxHeightCompleter;

  CurvedAnimation? _progressAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundBoxKey = GlobalKey();
    _boxHeightCompleter = Completer<Size>();

    _isTitlePresent = (widget.message != null || widget.messageText != null);
    _messageTopMargin = _isTitlePresent ? 6.0 : widget.padding.top;

    _configureLeftBarFuture();
  }

  void _configureLeftBarFuture() {
    SchedulerBinding.instance!.addPostFrameCallback(
      (_) {
        final keyContext = _backgroundBoxKey!.currentContext;

        if (keyContext != null) {
          final box = keyContext.findRenderObject() as RenderBox;
          _boxHeightCompleter.complete(box.size);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: 1.0,
      child: Material(
        color: widget.richbarStyle == RicharStyle.floating
            ? Colors.transparent
            : widget.backgroundColor,
        child: SafeArea(
          minimum: widget.richbarPosition == RichbarPosition.bottom
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)
              : EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
          bottom: widget.richbarPosition == RichbarPosition.bottom,
          top: widget.richbarPosition == RichbarPosition.top,
          left: false,
          right: false,
          child: Stack(
            children: [
              FutureBuilder(
                future: _boxHeightCompleter.future,
                builder: (context, AsyncSnapshot<Size> snapshot) {
                  return snapshot.hasData
                      ? BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: widget.blur, sigmaY: widget.blur),
                          child: Container(
                            height: snapshot.data!.height,
                            width: snapshot.data!.width,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                          ),
                        )
                      : _emptyWidget;
                },
              )
              //   richbar,
            ],
          ),
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
