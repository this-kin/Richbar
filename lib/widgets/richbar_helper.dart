import 'package:flutter/material.dart';
import 'package:richbar/constants/color_constant.dart';
import 'package:richbar/constants/enum_constant.dart';
import 'package:richbar/widgets/richbar_widget.dart';

class RichbarHelper {
  RichbarHelper._();

  static const _kDuration = Duration(seconds: 2);

  static showSuccess({String? message, required BuildContext context}) {
    return Richbar(
      message: message,
      backgroundColor: kBlueColor,
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      leading: const Icon(
        Icons.check_circle_rounded,
        color: Colors.lightBlueAccent,
      ),
    ).show(context);
  }

  static showError({String? message, required BuildContext context}) {
    return Richbar(
      message: message,
      backgroundColor: kRedColor,
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      leading: const Icon(
        Icons.cancel_rounded,
        color: Colors.red,
      ),
    ).show(context);
  }

  static showMessage({String? message, required BuildContext context}) {
    return Richbar(
      message: message,
      backgroundColor: kBlueColor,
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
    ).show(context);
  }
}
