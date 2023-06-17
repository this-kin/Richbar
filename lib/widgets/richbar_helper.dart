import 'package:flutter/material.dart';
import 'package:richbar/constants/color_constant.dart';
import 'package:richbar/constants/enum_constant.dart';
import 'package:richbar/widgets/richbar_widget.dart';

class RichbarHelper {
  RichbarHelper._();

  static const _kDuration = Duration(seconds: 2);

  static showSuccess({message, required BuildContext context}) {
    return Richbar(
      message,
      duration: _kDuration,
      backgroundColor: kBlueColor,
      richbarPosition: RichbarPosition.top,
      leading: const Icon(
        Icons.check_circle_rounded,
        color: Colors.lightBlueAccent,
      ),
    ).show(context);
  }

  static showError({message, required BuildContext context}) {
    return Richbar(
      message,
      duration: _kDuration,
      backgroundColor: kRedColor,
      richbarPosition: RichbarPosition.top,
      leading: const Icon(
        Icons.cancel_rounded,
        color: kRedColor,
      ),
    ).show(context);
  }

  static showMessage({message, required BuildContext context}) {
    return Richbar(
      message,
      duration: _kDuration,
      backgroundColor: kBlueColor,
      richbarPosition: RichbarPosition.top,
    ).show(context);
  }
}
