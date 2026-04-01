import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // for users
  Future<void> createUser(String uid, String name, String email, String householdId) {
    return _db.collection('users').doc(uid).set({
      'displayName': name,
      'email': email,
      'xp': 0,
      'householdId': householdId,
    });
  }
  // for authentication 
  Future<void> signUp(String email, String password, String name, String householdId) async {
    final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    final String uid = userCredential.user!.uid;
    await FirestoreService().createUser(uid, name, email, householdId);
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
  }
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userData.data() as Map<String, dynamic>;
  }

  Future<void> login(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  // for households
  Future<List<String>> getHouseholdMembers(String householdId) async {
    //print('Fetching household members for user: $uid');
    //DocumentSnapshot userData = await _db.collection('users').doc(uid).get();
    //String householdId = userData['householdId'];
    //print('User $uid belongs to household: $householdId');
    DocumentSnapshot householdData = await _db.collection('household').doc(householdId).get();
    List<dynamic> members = householdData['members'] ?? [];
    return members.cast<String>();
  }

  
  Future<String> createHousehold(String name) async {
    DocumentReference ref = await _db.collection('household').add({
      'members': [name],
      'streak': 0,
    });

    return ref.id;
  }

  Future<String> getCurrentHouseholdId(String uid) async {
    DocumentSnapshot userData = await _db.collection('users').doc(uid).get();
    return userData['householdId'];
  }

   Future<void> addMemberToHousehold(String householdId, String uid) async {
    DocumentSnapshot userData = await _db.collection('users').doc(uid).get();
    String displayName = userData['displayName'];
    await _db.collection('household').doc(householdId).update({
      'members': FieldValue.arrayUnion([displayName]), 
    });
  }
  
  Future<void> removeMemberFromHousehold(String householdId, String uid) async {
    await _db.collection('household').doc(householdId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
    await _db.collection('users').doc(uid).delete();
    final User? user = FirebaseAuth.instance.currentUser;
    await user?.delete();
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
      final chores = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          ...data,
          'dueDate': (data['dueDate'] as Timestamp?)?.toDate(),
        };
      }).toList();

      chores.sort((a, b) {
        final aDate = a['dueDate'] as DateTime?;
        final bDate = b['dueDate'] as DateTime?;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1; 
        if (bDate == null) return -1;

        return aDate.compareTo(bDate); 
      });
      return chores;
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
