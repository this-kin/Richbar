library richbar;

import 'dart:ui';
import 'dart:async';
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

  /// With an opacity of 1.0, Richbar is fully opaque.
  ///
  /// With an opacity of 0.0, Richbar is fully transparent (i.e., invisible).
  /// Default will be set to [kOpaque] or [0.5] slightly see through
  final double opacity;

  /// With an opacity of 1.0, background is fully opaque.
  ///
  /// With an opacity of 0.0, background is fully transparent (i.e., invisible).
  /// Default will be set to [kOpaque] or [0.5] slightly see through
  final double backgroundOpaque;

  /// Configures how an [AnimationController] behaves when animation starts.
  ///
  /// When [showPulse] is true, the device is asking Flutter to reduce or disable animations as much as possible.
  /// To honor this, we reduce the duration and the corresponding number of frames for animations.
  /// Default will be set to true
  final bool? showPulse;

  /// Curve animation applied when [Richbar.show()] is called
  ///
  /// Default curve will be set to [Curves.easeIn]
  final Curve showCurve;

  /// Curve animation applied when [Richbar.dismiss(context)] is called
  ///
  /// Default curve will be set to [Curves.easeOut]
  final Curve dismissCurve;

  /// Defines the width of the [Richbar] especially on big screens
  ///
  /// Like iPads, macOs, Windows,Linux and Web
  final double? maxWidth;

  /// The size to use when painting the text.
  ///
  /// Default size will be to [kfontSize] or [16.0]
  final double? textSize;

  /// The length of time this animation should last.
  ///
  /// Default will be set to [kDuration] or [2 seconds]
  final Duration? duration;

  // final OnTap? onPanDown;

  /// The color to use when painting the text
  ///
  /// Default color will be set to [Colors.white] or [kTextColor]
  final Color? textColor;

  /// Empty space to surround the [Border] and [content].
  final EdgeInsetsGeometry? margin;

  /// Defines whether the Richbar widget can be swiped horizontally or vertically
  ///
  /// When set to [true] the Richbar widget dismisses when swiped
  final bool? isDismissible;

  /// Defines the background color of Richbar widget
  ///
  /// Default color will be set to [Colors.purple] or[kBackgroundColor]
  final Color? backgroundColor;

  /// Called when the user taps this Richbar widget
  final OnTap? onPressed;

  /// How the text should be aligned horizontally
  ///
  /// Default alignment will be set to [TextAlign.left], after your leading widget
  final TextAlign? textAlignment;

  /// The typeface thickness to use when painting the text (e.g., bold, FontWeight.w100).
  ///
  /// Default fontWeight will be set to [FontWeight.normal]
  final FontWeight? textFontWeight;

  /// An immutable set of offsets in each of the four cardinal directions.
  /// Typically used for an offset from each of the four sides of a box.
  /// For example, the padding inside a box can be represented using this class.
  /// The [EdgeInsets] class specifies offsets in terms of visual edges, left, top,
  /// right, and bottom. These values are not affected by the [TextDirection].
  /// To support both left-to-right and right-to-left layouts, consider using [EdgeInsetsDirectional],
  /// which is expressed in terms of start, top, end, and bottom, where start and end are resolved in terms
  /// of a [TextDirection] (typically obtained from the ambient [Directionality]).
  final EdgeInsetsGeometry? padding;

  /// Defines the z-coordinate at which to place this Richbar relative to its parent.
  ///
  /// Richbar can be [RichbarStyle.floating] or be [RichbarStyle.grounded] to the edge of the screen.
  /// Default will be set to [RichbarStyle.floating]
  final RichbarStyle richbarStyle;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  ///
  /// Applies only to Richbar with rectangular shapes; ignored if [shape] is not [BoxShape.rectangle]
  final BorderRadius? borderRadius;

  ///
  ///
  /// Default will be set to [Colors.transparent] or [kTransparentColor]

  final Color? blockInteractionColor;

  /// Defines the entry position of the Richbar widget either top or bottom
  ///
  /// Richbar can be set on [RichbarPosition.top] or [RichbarPosition.bottom]
  final RichbarPosition richbarPosition;

  /// Calls listener every time the status of the richbar changes.
  RichbarStatusCallback? onStatusChanged;

  ///  Defines whether the Richbar widget can be swiped horizontally or vertically
  ///
  /// When set to [DismissableDirection.horizontal] the Richbar widget can be dismissed
  /// When wiped on from Left or Right, When set to [DismissableDirection.vertical].
  /// The Richbar widget can be swiped on from Top to Bottom
  final DismissableDirection? dismissableDirection;

  /// Defines if user can interact with screen when Richbar is been displayed
  /// on screen
  ///
  /// Default value will be set to false
  final bool enableBackgroundInteraction;

  Richbar(
    String this.text, {
    Key? key,
    this.leading,
    this.opacity = 0.5,
    this.maxWidth,
    this.onPressed,
    this.borderRadius,
    this.showPulse = true,
    this.textSize = kfontSize,
    this.duration = kDuration,
    this.textColor = kTextColor,
    this.isDismissible = false,
    this.backgroundOpaque = 0.5,
    this.showCurve = Curves.easeIn,
    this.dismissCurve = Curves.easeInOut,
    this.textAlignment = TextAlign.left,
    this.backgroundColor = kBackgroundColor,
    this.textFontWeight = FontWeight.normal,
    this.blockInteractionColor = kTransparentColor,
    this.margin = const EdgeInsets.symmetric(),
    this.padding = const EdgeInsets.all(8),
    this.richbarStyle = RichbarStyle.floating,
    this.enableBackgroundInteraction = false,
    this.richbarPosition = RichbarPosition.top,
    this.dismissableDirection = DismissableDirection.horizontal,
    this.onStatusChanged,
    this.richbarRoute,
  }) : super(key: key) {
    this.onStatusChanged = onStatusChanged ?? (status) {};
  }

  routes.RichbarRoute<T?>? richbarRoute;

  /// Displays a Richbar widget above the current contents of the app,
  /// With Material entrance and exit animations
  ///
  /// Modal barrier behavior (Richbar is dismissible with a slide horizontally or vertically depending on the [dismissableDirection]).
  Future<T?> show(BuildContext context) async {
    richbarRoute = routes.showRichbar<T>(
      context: context,
      richbar: this,
    ) as routes.RichbarRoute<T?>;
    return await Navigator.of(context, rootNavigator: false)
        .push(richbarRoute as Route<T>);
  }

  /// Closes the Richbar widget above the current contents of the app,
  /// With Material entrance and exit animations
  ///
  Future<T?> close([T? result]) async {
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
    final alignment = widget.richbarPosition == RichbarPosition.top
        ? Alignment.topCenter
        : Alignment.bottomCenter;
    final mediaQuery = MediaQuery.of(context).viewInsets;
    return Align(
      alignment: alignment,
      heightFactor: 1.0,
      child: Material(
        color: widget.richbarStyle == RichbarStyle.floating
            ? Colors.transparent
            : widget.backgroundColor,
        child: SafeArea(
          minimum: widget.richbarPosition == RichbarPosition.bottom
              ? EdgeInsets.only(bottom: mediaQuery.bottom)
              : EdgeInsets.only(top: mediaQuery.top),
          bottom: widget.richbarPosition == RichbarPosition.bottom,
          top: true,
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
                      sigmaX: widget.backgroundOpaque,
                      sigmaY: widget.backgroundOpaque,
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
          color: widget.backgroundColor!.withOpacity(widget.opacity),
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
                      widget.text!,
                      maxLines: 8,
                      textAlign: widget.textAlignment,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.textSize,
                        fontWeight: widget.textFontWeight,
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
