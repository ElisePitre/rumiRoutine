import 'package:flutter/foundation.dart';

class HouseholdXpStore {
  static final ValueNotifier<int> householdXp = ValueNotifier<int>(3150);

  static void update(int value) {
    householdXp.value = value;
  }
}