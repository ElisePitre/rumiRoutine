import 'package:flutter/foundation.dart';

class RumiBackgroundStore {
  static final ValueNotifier<String?> selectedBackground =
      ValueNotifier<String?>(null);

  static void toggleBackground(String backgroundKey) {
    if (selectedBackground.value == backgroundKey) {
      selectedBackground.value = null;
      return;
    }

    selectedBackground.value = backgroundKey;
  }
}
