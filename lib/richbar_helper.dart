import 'package:richbar/richbar.dart';
import 'package:flutter/material.dart';

class RichbarHelper {
  static Richbar showSuccess({String? title, String? action}) {
    return Richbar(
      title: title!,
      text: action,
      backgroundColor: const Color(0XFF1DA64D),
      duration: const Duration(seconds: 2),
      richbarPosition: RichbarPosition.top,
    );
  }

  static Richbar showError({String? err, String? action}) {
    return Richbar(
      title: err!,
      text: action,
      backgroundColor: const Color(0XFFE24057),
      duration: const Duration(seconds: 2),
      richbarPosition: RichbarPosition.top,
    );
  }

  static Richbar showInformation({String? information, String? action}) {
    return Richbar(
      title: information!,
      text: action!,
      isDismissible: false,
      richbarPosition: RichbarPosition.top,
      duration: const Duration(seconds: 5),
    );
  }
}
