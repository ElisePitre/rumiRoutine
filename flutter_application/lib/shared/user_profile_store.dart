import 'package:flutter/foundation.dart';

class UserProfileStore {
  static const String defaultName = 'Suraj';
  static const List<String> defaultHouseholdMembers = <String>[
    'Silvia',
    'Caitlin',
    'Alina',
    'Elise',
    defaultName,
  ];

  static final ValueNotifier<String> name =
      ValueNotifier<String>(defaultName);
  static final ValueNotifier<String> email =
      ValueNotifier<String>('fakeEmail@gmail.com');
  static final ValueNotifier<List<String>> householdMembers =
      ValueNotifier<List<String>>(
    List<String>.from(defaultHouseholdMembers),
  );

  static void saveProfile({
    required String updatedName,
    required String updatedEmail,
    required List<String> updatedMembers,
  }) {
    name.value = updatedName;
    email.value = updatedEmail;
    householdMembers.value = List<String>.from(updatedMembers);
  }
}
