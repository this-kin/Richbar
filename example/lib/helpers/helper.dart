import 'package:flutter/material.dart';
import 'package:richflushbar/richbar_helper.dart';

richbarWidget(String? message, BuildContext context) {
  return RichbarHelper.showError(
    err: message,
    action: "Cancel",
  )..show(context);
}

