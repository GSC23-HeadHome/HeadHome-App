import 'dart:async';
import 'package:flutter/material.dart';

/// Debounces an [action] callback by [seconds].
/// [For more information on debouncing](https://www.geeksforgeeks.org/debouncing-in-javascript/)
class Debouncer {
  Debouncer({required this.seconds});

  final int seconds;
  Timer? _timer;

  /// Runs the [action] callback after [seconds], cancelling any pending callbacks.
  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }

    _timer = Timer(Duration(seconds: seconds), action);
  }
}
