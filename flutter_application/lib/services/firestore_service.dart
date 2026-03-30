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
  // to do delete a chore
  Future deleteChore(String uid) async {
    return _db.collection('chores').doc(uid).delete();
  }
  Stream<QuerySnapshot> getChores(String householdId) {
    return _db
        .collection('chores')
        .where('householdId', isEqualTo: householdId)
        .snapshots();
  }
  Future<void> addChore(Map<String, dynamic> choreData) {
    return _db.collection('chores').add(choreData);
  }
  Future<void> completeChore(String choreId, String userId) {
    return _db.collection('chores').doc(choreId).update({
      'completed': true,
      'completedBy': userId,
    });
  }
}