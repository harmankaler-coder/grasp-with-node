import 'dart:async';
import 'dart:ui';

class IdleService {
  static Timer? timer;

  static void start(VoidCallback onTimeout) {
    timer?.cancel();
    timer = Timer(const Duration(minutes: 10), onTimeout);
  }

  static void reset(VoidCallback onTimeout) {
    start(onTimeout);
  }

  static void stop() {
    timer?.cancel();
  }
}
