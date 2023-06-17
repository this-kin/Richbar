import 'package:richbar/richbar.dart';
import 'package:flutter/material.dart';

class RichbarHelper {
  RichbarHelper._();

  static const _kDuration = Duration(seconds: 2);

  static success({String? message, required BuildContext context}) {
    return Richbar(
      message: message,
      backgroundColor: const Color(0xff00ACEE),
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      leading: const Icon(
        Icons.check_circle_rounded,
        color: Colors.lightBlueAccent,
      ),
    ).show(context);
  }

  static error({String? message, required BuildContext context}) {
    return Richbar(
      message: message,
      backgroundColor: const Color(0xffFF0000),
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      leading: const Icon(
        Icons.cancel_rounded,
        color: Colors.red,
      ),
    ).show(context);
  }

  static information({String? message, required BuildContext context}) {
    return Richbar(
      message: message,
      backgroundColor: const Color(0xff00ACEE),
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      // leading: const CustomIcon(icon: ConstanceImage.cancel),
    ).show(context);
  }
}
