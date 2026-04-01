import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== User Management ====================

  Future<void> createUser(
    String uid,
    String name,
    String email,
    String householdId,
  ) {
    return _db.collection('users').doc(uid).set({
      'displayName': name,
      'email': email,
      'xp': 0,
      'householdId': householdId,
    });
  }

  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    final userData = await _db.collection('users').doc(uid).get();
    return userData.data() as Map<String, dynamic>;
  }

  // ==================== Authentication ====================

  Future<void> signUp(
    String email,
    String password,
    String name,
    String householdId,
  ) async {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCredential.user!.uid;
    await createUser(uid, name, email, householdId);
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
  }

  Future<String> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'OK';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    return 'Error';
  }

  // ==================== Real-time Streams ====================

  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (snapshot) => snapshot.data(),
        );
  }

  Stream<Map<String, dynamic>?> streamHousehold(String householdId) {
    return _db.collection('household').doc(householdId).snapshots().map(
          (snapshot) => snapshot.data(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamUsersByHousehold(
    String householdId,
  ) {
    return _db
        .collection('users')
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      // Sort by XP descending
      users.sort((a, b) {
        final aXp = (a['xp'] as num?)?.toInt() ?? 0;
        final bXp = (b['xp'] as num?)?.toInt() ?? 0;
        return bXp.compareTo(aXp);
      });

      return users;
    });
  }

  Stream<List<Map<String, dynamic>>> streamChores(String householdId) {
    return _db
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

      // Sort by due date ascending
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

  // ==================== Household Management ====================

  Future<String> getCurrentHouseholdId(String uid) async {
    final userData = await _db.collection('users').doc(uid).get();
    return userData['householdId'] as String;
  }

  Future<List<String>> getHouseholdMembers(String householdId) async {
    final householdData =
        await _db.collection('household').doc(householdId).get();
    final members = householdData['members'] as List<dynamic>? ?? [];
    return members.cast<String>();
  }

  Future<String> createHousehold(String name) async {
    final ref = await _db.collection('household').add({
      'members': [name],
      'streak': 0,
    });
    return ref.id;
  }

  Future<void> addMemberToHousehold(String householdId, String uid) async {
    final userData = await _db.collection('users').doc(uid).get();
    final displayName = userData['displayName'] as String;
    await _db.collection('household').doc(householdId).update({
      'members': FieldValue.arrayUnion([displayName]),
    });
  }

  Future<void> removeMemberFromHousehold(
    String householdId,
    String uid,
  ) async {
    await _db.collection('household').doc(householdId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
    await _db.collection('users').doc(uid).delete();
    await FirebaseAuth.instance.currentUser?.delete();
  } 
  // ==================== Chore Management ====================

  Future<void> addChore(Map<String, dynamic> chore) async {
    await _db.collection('chores').add({
      ...chore,
      'dueDate': Timestamp.fromDate(chore['dueDate'] as DateTime),
    });
  }

  Future<void> updateChore(
    String choreId,
    Map<String, dynamic> updated,
  ) async {
    final data = Map<String, dynamic>.from(updated);

    if (data['dueDate'] != null && data['dueDate'] is DateTime) {
      data['dueDate'] = Timestamp.fromDate(data['dueDate'] as DateTime);
    }

    await _db.collection('chores').doc(choreId).update(data);
  }

  Future<void> deleteChore(String choreId) async {
    await _db.collection('chores').doc(choreId).delete();
  }

  Future<void> markChoreComplete(String choreId) async {
    await _db.collection('chores').doc(choreId).update({
      'completed': true,
    });
  }

  // ==================== Chore XP Management ====================

  int countOverdueChores(List<Map<String, dynamic>> chores) {
    final now = DateTime.now();
    return chores
        .where(
          (c) => !c['completed'] && (c['dueDate'] as DateTime).isBefore(now),
        )
        .length;
  }

  int computeHouseholdXpWithChores(
    List<Map<String, dynamic>> users,
    List<Map<String, dynamic>> chores,
  ) {
    final completedChoresXp = chores
        .where((chore) => chore['completed'] == true)
        .fold<int>(
          0,
          (sum, chore) => sum + ((chore['xp'] as num?)?.toInt() ?? 0),
        );
    return completedChoresXp;
  }

  int computeUserXpFromCompletedChores(
    String assignedUserName,
    List<Map<String, dynamic>> chores,
  ) {
    return chores
        .where(
          (chore) =>
              chore['completed'] == true &&
              (chore['assigned'] ?? '').toString() == assignedUserName,
        )
        .fold<int>(
          0,
          (sum, chore) => sum + ((chore['xp'] as num?)?.toInt() ?? 0),
        );
  }

  Future<void> syncHouseholdUserXpFromCompletedChores(
    List<Map<String, dynamic>> users,
    List<Map<String, dynamic>> chores,
  ) async {
    final xpByName = <String, int>{};

    // Calculate total XP per user
    for (final chore in chores) {
      if (chore['completed'] != true) continue;
      final assigned = (chore['assigned'] ?? '').toString();
      if (assigned.isEmpty) continue;
      final xp = (chore['xp'] as num?)?.toInt() ?? 0;
      xpByName[assigned] = (xpByName[assigned] ?? 0) + xp;
    }

    // Batch update users if XP has changed
    final batch = _db.batch();
    var hasUpdates = false;

    for (final user in users) {
      final uid = (user['id'] ?? '').toString();
      if (uid.isEmpty) continue;

      final name = (user['displayName'] ?? '').toString();
      final computedXp = xpByName[name] ?? 0;
      final currentXp = (user['xp'] as num?)?.toInt() ?? 0;

      if (currentXp != computedXp) {
        batch.update(_db.collection('users').doc(uid), {'xp': computedXp});
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }

  Future<void> updateUserXpFromCompletedChores(
    String uid,
    String displayName,
    String householdId,
  ) async {
    final choresSnapshot = await _db
        .collection('chores')
        .where('householdId', isEqualTo: householdId)
        .get();

    final chores = choresSnapshot.docs.map((doc) => doc.data()).toList();
    final userXp = computeUserXpFromCompletedChores(displayName, chores);

    await _db.collection('users').doc(uid).update({'xp': userXp});
  }

  Future<String?> getUserUidByDisplayName(
    String displayName,
    String householdId,
  ) async {
    final usersSnapshot = await _db
        .collection('users')
        .where('householdId', isEqualTo: householdId)
        .where('displayName', isEqualTo: displayName)
        .limit(1)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      return null;
    }

    return usersSnapshot.docs.first.id;
  }

  // ==================== Household Streak Management ====================

  Future<void> updateHouseholdStreakIfNeeded(
    String householdId,
    List<Map<String, dynamic>> chores,
  ) async {
    final householdDoc =
        await _db.collection('household').doc(householdId).get();
    final data = householdDoc.data() ?? <String, dynamic>{};
    final lastStreakUpdate =
        (data['lastStreakUpdate'] as Timestamp?)?.toDate() ??
            DateTime(2000);
    final today = DateTime.now();

    // Check if we already updated today
    final isSameDay = lastStreakUpdate.year == today.year &&
        lastStreakUpdate.month == today.month &&
        lastStreakUpdate.day == today.day;

    if (isSameDay) return; // Already updated today

    // Only increment if no overdue chores
    final hasOverdue = chores.any(
      (c) => !c['completed'] && (c['dueDate'] as DateTime).isBefore(today),
    );

    if (!hasOverdue) {
      final currentStreak = (data['streak'] as num?)?.toInt() ?? 0;
      await _db.collection('household').doc(householdId).update({
        'streak': currentStreak + 1,
        'lastStreakUpdate': Timestamp.now(),
      });
    }
  }

}
