import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';

class UserProfileStore {
  static final List<String> defaultHouseholdMembers = <String>[
    FirebaseAuth.instance.currentUser?.displayName ?? '',
  ];

  static final ValueNotifier<String> name = ValueNotifier<String>(
    FirebaseAuth.instance.currentUser?.displayName ?? '',
  );

  static final ValueNotifier<String> email = ValueNotifier<String>(
    FirebaseAuth.instance.currentUser?.email ?? '',
  );

  static final ValueNotifier<List<String>> householdMembers =
      ValueNotifier<List<String>>(
    List<String>.from(defaultHouseholdMembers),
  );

  static Future<void> fetchAndSetHouseholdMembers(
    String householdCode,
  ) async {
    final members =
        await FirestoreService().getHouseholdMembers(householdCode);
    householdMembers.value = List<String>.from(members);
  }

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
