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

  // For Chores
  Future<void> addChore(Map<String, dynamic> chore) async {
    await _db.collection('chores').add({
      ...chore,
      'dueDate': Timestamp.fromDate(chore['dueDate'] as DateTime),
    });
  }

  Stream<List<Map<String, dynamic>>> streamChores() {
    return _db.collection('chores').orderBy('dueDate').snapshots().map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id':      doc.id,
              'dueDate': (data['dueDate'] as Timestamp).toDate(),
            };
          }).toList(),
        );
  }

  Future<void> updateChore(String choreId, Map<String, dynamic> updated) async {
    await _db.collection('chores').doc(choreId).update({
      ...updated,
      'dueDate': Timestamp.fromDate(updated['dueDate'] as DateTime),
    });
  }

  Future<void> deleteChore(String choreId) async {
    await _db.collection('chores').doc(choreId).delete();
  }

  Future<void> markChoreComplete(String choreId) async {
    await _db.collection('chores').doc(choreId).update({'completed': true});
  }
}
