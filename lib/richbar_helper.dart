import 'package:richbar/constants/image_constant.dart';
import 'package:richbar/richbar.dart';
import 'package:flutter/material.dart';
import 'package:richbar/widgets/custom_icon_widget.dart';

class RichbarHelper {
  static const _kDuration = Duration(seconds: 2);

  static Richbar success({String? message}) {
    return Richbar(
      message: message,
      backgroundColor: const Color(0xff00ACEE),
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      leading: const CustomIcon(icon: ConstanceImage.check),
    );
  }

  static Richbar error({String? message}) {
    return Richbar(
      message: message,
      backgroundColor: const Color(0xffFF0000),
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      leading: const CustomIcon(icon: ConstanceImage.cancel),
    );
  }

  static Richbar information({String? message}) {
    return Richbar(
      message: message,
      backgroundColor: const Color(0xff00ACEE),
      duration: _kDuration,
      richbarPosition: RichbarPosition.top,
      // leading: const CustomIcon(icon: ConstanceImage.cancel),
    );
  }
}
