import 'package:flutter/foundation.dart';

class RumiAccessoryStore {
  static final ValueNotifier<String?> selectedAccessory = ValueNotifier<String?>(null);

  static String get currentRumiImagePath =>
      currentRumiImagePathForEmotion('normal');

  static String currentRumiImagePathForEmotion(String emotion) {
    final normalizedEmotion = _normalizeEmotion(emotion);
    final hatSuffix = _hatSuffix(selectedAccessory.value);
    return 'assets/rumi$normalizedEmotion$hatSuffix.png';
  }

  static String _normalizeEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'angry':
        return 'Angry';
      case 'blissful':
        return 'Blissful';
      case 'sad':
        return 'Sad';
      case 'suprised':
      case 'surprised':
        return 'Suprised';
      case 'normal':
      default:
        return 'Normal';
    }
  }

  static String _hatSuffix(String? accessoryKey) {
    switch (accessoryKey) {
      case 'flatHat':
        return 'FlatHat';
      case 'witchHat':
        return 'WitchHat';
      case 'partyHat':
        return 'PartyHat';
      case 'pirateHat':
        return 'PirateHat';
      case 'crown':
        return 'Crown';
      case 'jesterHat':
        return 'JesterHat';
      default:
        return 'NoHat';
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
