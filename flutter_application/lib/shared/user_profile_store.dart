import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';


class UserProfileStore {
  //String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  //static String defaultName =  name.value;//'Suraj';
  // static List<String> defaultHouseholdMembers = <String>[
  //   'Silvia',
  //   'Caitlin',
  //   'Alina',
  //   'Elise',
  //   FirebaseAuth.instance.currentUser?.displayName ?? '',
  // ];
  static List<String> defaultHouseholdMembers = <String>[
    FirebaseAuth.instance.currentUser?.displayName ?? '',
  ];
  //get household members from firestore based on householdId in user document
  //List<String> defaultHouseholdMembers = await FirestoreService().getHouseholdMembers(uid);
  static Future<void> fetchAndSetHouseholdMembers(String householdCode) async {
    final members = await FirestoreService().getHouseholdMembers(householdCode);
    householdMembers.value = List<String>.from(members);
  }

  static final ValueNotifier<String> name =
      ValueNotifier<String>(FirebaseAuth.instance.currentUser?.displayName ?? '');
  static final ValueNotifier<String> email = 
      ValueNotifier<String>(FirebaseAuth.instance.currentUser?.email ?? '');
  // static final ValueNotifier<String> householdCode = 
  //     ValueNotifier<String>();
      //ValueNotifier<String>('fakeEmail@gmail.com');
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
