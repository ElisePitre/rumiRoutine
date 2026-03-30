import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // for users
  Future<void> createUser(String uid, String name, String email) {
    return _db.collection('users').doc(uid).set({
      'displayName': name,
      'email': email,
      'xp': 0,
      'householdId': null,
    });
  }

  // for households
  Future<String> createHousehold(String name, String userId) async {
    DocumentReference ref = await _db.collection('household').add({
      'members': [userId],
      'streak': 0,
    });

    return ref.id;
  }
}