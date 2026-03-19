import 'package:flutter/foundation.dart';

class RumiAccessoryStore {
  static final ValueNotifier<String?> selectedAccessory = ValueNotifier<String?>(null);

  static String get currentRumiImagePath {
    switch (selectedAccessory.value) {
      case 'flatHat':
        return 'assets/rumiNormalFlatHat.png';
      case 'witchHat':
        return 'assets/rumiNormalWitchHat.png';
      default:
        return 'assets/rumiNormalNoHat.png';
    }
  }

  static void toggleAccessory(String accessoryKey) {
    if (selectedAccessory.value == accessoryKey) {
      selectedAccessory.value = null;
      return;
    }

    selectedAccessory.value = accessoryKey;
  }
}
