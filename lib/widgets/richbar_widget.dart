library richbar;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:richbar/constants/color_constant.dart';
import 'package:richbar/constants/double_constants.dart';
import 'package:richbar/constants/enum_constant.dart';
import 'package:richbar/widgets/richbar_route.dart' as routes;
import 'package:richbar/typedefs/richbar_typedef.dart';

// ignore: must_be_immutable
class Richbar<T> extends StatefulWidget {
  //
  /// The text to be displayed
  final String? text;

  /// A widget to display before the text.
  ///
  ///Typically an [Icon] or a [SvgPicture] widget.
  final Icon? leading;

  /// Configures how an [AnimationController] behaves when animation starts.
  ///
  /// When [showPulse] is true, the device is asking Flutter to reduce or disable animations as much as possible.
  /// To honor this, we reduce the duration and the corresponding number of frames for animations.
  final bool? showPulse;

  /// Curve animation applied when show() is called Curves.easeIn will be default
  final Curve showCurve;

  /// Defines the width of the [Richbar] especially on big screens
  ///
  /// like iPads, macOs, Windows,Linux and Web
  final double? maxWidth;

  /// The size to use when painting the text.
  ///
  ///  default size will be to [16]
  final double? textSize;

  /// The length of time this animation should last.
  final Duration? duration;

  // final OnTap? onPanDown;

  /// The color to use when painting the text
  ///
  /// default color will be set to [Colors.white] or [kTextColor]
  final Color? textColor;

  /// Empty space to surround the [Border] and [content].
  final EdgeInsetsGeometry? margin;

  /// Defines whether the Richbar widget can be swiped
  ///
  /// when swiped [left] or [right] the Richbar widget dismisses
  final bool? isDismissible;

  /// Defines the background color of Richbar widget
  ///
  /// default color will be set to [defaultBackgroundColor]
  final Color? backgroundColor;

  /// Called when the user taps this Richbar widget
  final VoidCallback? onPressed;

  /// How the text should be aligned horizontally
  ///
  /// default alignment will be set to [TextAlign.left], right after your leading widget
  final TextAlign? textAlignment;

  /// The typeface thickness to use when painting the text (e.g., bold, FontWeight.w100).
  ///
  /// default fontWeight will be set to [FontWeight.normal]
  final FontWeight? textFontWeight;

  /// An immutable set of offsets in each of the four cardinal directions.
  /// Typically used for an offset from each of the four sides of a box.
  /// For example, the padding inside a box can be represented using this class.
  /// The [EdgeInsets] class specifies offsets in terms of visual edges, left, top,
  /// right, and bottom. These values are not affected by the [TextDirection].
  /// To support both left-to-right and right-to-left layouts, consider using [EdgeInsetsDirectional],
  /// which is expressed in terms of start, top, end, and bottom, where start and end are resolved in terms
  ///  of a [TextDirection] (typically obtained from the ambient [Directionality]).
  final EdgeInsetsGeometry? padding;

  /// Defines the z-coordinate at which to place this Richbar relative to its parent.
  ///
  /// Richbar can be [RichbarStyle.floating] or be [RichbarStyle.grounded] to the edge of the screen.
  final RichbarStyle richbarStyle;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].

  /// Applies only to boxes with rectangular shapes; ignored if
  /// [shape] is not [BoxShape.rectangle]
  final BorderRadius? borderRadius;

  // final Color? blockInteractionColor;

  /// Richbar can be set on [RichbarPosition.top] or [RichbarPosition.bottom]
  final RichbarPosition richbarPosition;

  ///
  /// Calls listener every time the status of the richbar changes.
  final RichbarStatusCallback? onStatusChanged;

  /// dismiss direction horizontal swipe or vertical
  final RichbarDimissibleDirection richbarDimissibleDirection;

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
    this.messageAlignment = TextAlign.left,
    this.messageFontWeight = FontWeight.w500,
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
                          child: widget.leading,
                        )
                      : const SizedBox(),
                  _isLeadingPresent
                      ? const SizedBox(width: widthSpacing)
                      : const SizedBox(),
                  Expanded(
                    child: Text(
                      widget.message!,
                      textAlign: widget.messageAlignment,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.messageSize ?? 16,
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
