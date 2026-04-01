import 'package:flutter/foundation.dart';

class RumiEmotionStore {
  static final ValueNotifier<String> emotion = ValueNotifier<String>('normal');

  static void update(String value) {
    emotion.value = value;
  }
}
