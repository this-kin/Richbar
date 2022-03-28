library richflushbar;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:richflushbar/richbar_route.dart' as route;

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

  ///
  final Offset offset;

  const Richbar({
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
    this.offset = const Offset(0, 0),
  }) : super(key: key);

  @override
  State<Richbar> createState() => _RichbarState();
}

class _RichbarState extends State<Richbar> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

///
enum RichbarPosition { top, bottom }
enum RichbarDimissibleDirection { vertical, horizontal }
enum RicharStyle { grounded, floating }
enum RichbarStatus { showing, init, dismissed, hidden }
