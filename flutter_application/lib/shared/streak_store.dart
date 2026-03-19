import 'package:flutter/foundation.dart';

class StreakStore {
  static final ValueNotifier<int> count = ValueNotifier<int>(4);

  static void update(int value) {
    count.value = value;
  }
}
