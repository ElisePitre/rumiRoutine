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

  Stream<List<Map<String, dynamic>>> streamChores(String householdId) {
  return FirebaseFirestore.instance
      .collection('chores')
      .where('householdId', isEqualTo: householdId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
            'dueDate': (data['dueDate'] as Timestamp).toDate(),
          };
        }).toList();
      });
  } 

  Future<void> updateChore(String choreId, Map<String, dynamic> updated) async {
    final data = Map<String, dynamic>.from(updated);

    if (data['dueDate'] != null && data['dueDate'] is DateTime) {
      data['dueDate'] = Timestamp.fromDate(data['dueDate']);
    }

    await _db.collection('chores').doc(choreId).update(data);
  }

  Future<void> deleteChore(String choreId) async {
    await _db.collection('chores').doc(choreId).delete();
  }

  Future<void> markChoreComplete(String choreId) async {
    await _db.collection('chores').doc(choreId).update({'completed': true});
  }
}
