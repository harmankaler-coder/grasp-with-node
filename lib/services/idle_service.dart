import 'dart:async';
import 'dart:ui';

class IdleService {
  static Timer? timer;

  static void start(VoidCallback onTimeout,
      {Duration duration = const Duration(minutes: 15)}) {
    timer?.cancel();
    timer = Timer(duration, onTimeout);
  }

  static void reset(VoidCallback onTimeout,
      {Duration duration = const Duration(minutes: 15)}) {
    start(onTimeout, duration: duration);
  }

  static void stop() {
    timer?.cancel();
  }
}