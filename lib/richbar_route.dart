import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:richflushbar/richbar.dart';

class RichbarRoute<T> extends OverlayRoute<T> {
  final Richbar richbar;
  final Builder builder;
  final Completer<T> completer = Completer<T>();
  final RichbarStatusCallback? onStatusChanged;
  
  @override
  Iterable<OverlayEntry> createOverlayEntries() {}
}
