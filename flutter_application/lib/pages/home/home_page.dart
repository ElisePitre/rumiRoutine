import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../home/add_chore.dart';
import '../home/edit_chore.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/rumi_emotion_store.dart';
import '../../shared/user_profile_store.dart';
import '../../services/firestore_service.dart';

enum CategoryType {
  completed,
  dueToday,
  myChores,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.onRumiTap,
  }) : super(key: key);

  final VoidCallback onRumiTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _overdueChoresTitle = 'Overdue Chores';
  static const String _completedButtonLabel = 'Completed';
  static const String _dueTodayButtonLabel = 'Due Today';
  static const String _myChoresButtonLabel = 'My Chores';
  static const double _choreCardCornerRadius = 16.0;

  final FirestoreService _firestore = FirestoreService();

  CategoryType? categoryType;
  String _householdId = '';

  @override
  void initState() {
    super.initState();
    UserProfileStore.name.value;
    _loadHouseholdId();
  }

  Future<void> _loadHouseholdId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final householdId = await _firestore.getCurrentHouseholdId(uid);
    if (!mounted) return;

    setState(() {
      _householdId = householdId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: _handleAddChore,
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopIconsUI(),
              _buildAppBarUI(),
              _buildCategoryUI(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Helper Methods ====================

  void _handleAddChore() {
    if (_householdId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChoreScreen(
          onRumiTap: widget.onRumiTap,
          householdId: _householdId,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Map<String, dynamic>> _getOverdueChores(
    List<Map<String, dynamic>> chores,
  ) {
    final now = DateTime.now();
    return chores
        .where(
          (c) => !c['completed'] && (c['dueDate'] as DateTime).isBefore(now),
        )
        .toList();
  }

  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> chores,
  ) {
    final today = DateTime.now();

    if (categoryType == null) return chores;

    switch (categoryType) {
      case CategoryType.completed:
        return chores.where((c) => c['completed'] == true).toList();
      case CategoryType.dueToday:
        return chores
            .where(
              (c) =>
                  !c['completed'] && _isSameDay(c['dueDate'], today),
            )
            .toList();
      case CategoryType.myChores:
        return chores
            .where(
              (c) => c['assigned'] == UserProfileStore.name.value,
            )
            .toList();
      default:
        return chores;
    }
  }

  List<Map<String, dynamic>> _sortChoresSmartly(
    List<Map<String, dynamic>> chores,
  ) {
    final List<Map<String, dynamic>> uncompleted = [];
    final List<Map<String, dynamic>> completed = [];

    // Separate uncompleted and completed chores
    for (final chore in chores) {
      if (chore['completed'] == true) {
        completed.add(chore);
      } else {
        uncompleted.add(chore);
      }
    }

    // Sort each group by date
    _sortByDate(uncompleted);
    _sortByDate(completed);

    return [...uncompleted, ...completed];
  }

  void _sortByDate(List<Map<String, dynamic>> chores) {
    chores.sort((a, b) {
      final aDate = a['dueDate'] as DateTime?;
      final bDate = b['dueDate'] as DateTime?;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return aDate.compareTo(bDate);
    });
  }

  // ==================== UI Builders ====================

  Widget _buildTopIconsUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 12),
      child: SizedBox(
        height: 120,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 35,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    ValueListenableBuilder<int>(
                      valueListenable: StreakStore.count,
                      builder: (context, streak, _) => Text(
                        '$streak',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: IconButton(
                  onPressed: widget.onRumiTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: ValueListenableBuilder<String>(
                    valueListenable: RumiEmotionStore.emotion,
                    builder: (context, emotion, _) =>
                        ValueListenableBuilder<String?>(
                          valueListenable:
                              RumiAccessoryStore.selectedAccessory,
                          builder: (context, _, __) => Image.asset(
                            RumiAccessoryStore
                                .currentRumiImagePathForEmotion(emotion),
                            width: 112,
                            height: 112,
                            fit: BoxFit.contain,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 25, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ValueListenableBuilder<String>(
                  valueListenable: UserProfileStore.name,
                  builder: (context, profileName, _) => Text(
                    'Hello $profileName!',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 25,
                      letterSpacing: 0.2,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Text(
                  'Chore Page',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                    letterSpacing: 0.27,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryUI() {
    if (_householdId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestore.streamChores(_householdId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final firestoreChores = snapshot.data!;
        final filteredChores = _applyFilter(firestoreChores);

        // Apply smart sorting when no category is selected
        final displayChores = categoryType == null
            ? _sortChoresSmartly(filteredChores)
            : filteredChores;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildOverdueChoresUI(firestoreChores),
            const SizedBox(height: 16),
            _buildCategoryButtonsUI(),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayChores.length,
              itemBuilder: (context, index) {
                return _buildChoreTile(displayChores[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryButtonsUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: <Widget>[
          _buildCategoryButton(
            CategoryType.completed,
            categoryType == CategoryType.completed,
            _completedButtonLabel,
          ),
          const SizedBox(width: 16),
          _buildCategoryButton(
            CategoryType.dueToday,
            categoryType == CategoryType.dueToday,
            _dueTodayButtonLabel,
          ),
          const SizedBox(width: 16),
          _buildCategoryButton(
            CategoryType.myChores,
            categoryType == CategoryType.myChores,
            _myChoresButtonLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    CategoryType categoryTypeData,
    bool isSelected,
    String label,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          border: Border.all(color: Colors.black),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onTap: () {
              setState(() {
                if (categoryType == categoryTypeData) {
                  categoryType = null; // deselect
                } else {
                  categoryType = categoryTypeData;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.27,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverdueChoresUI(List<Map<String, dynamic>> chores) {
    final overdue = _getOverdueChores(chores);

    if (overdue.isEmpty) {
      return const SizedBox(); // hide section if none
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16),
          child: Text(
            _overdueChoresTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: overdue.length,
            itemBuilder: (context, index) {
              final chore = overdue[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(_choreCardCornerRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chore['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chore['assigned'] as String? ?? 'Unassigned',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChoreTile(Map<String, dynamic> chore) {
    final dueDate = chore['dueDate'];
    DateTime? date;

    if (dueDate is Timestamp) {
      date = dueDate.toDate();
    } else if (dueDate is DateTime) {
      date = dueDate;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(_choreCardCornerRadius),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditChoreScreen(
              chore: chore,
              onRumiTap: widget.onRumiTap,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(_choreCardCornerRadius),
        ),
        child: Row(
          children: [
            Checkbox(
              value: chore['completed'] as bool? ?? false,
              onChanged: (value) async {
                if (value == null) return;

                final updatedChore =
                    Map<String, dynamic>.from(chore);
                updatedChore.remove('id');
                updatedChore['completed'] = value;

                await _firestore.updateChore(chore['id'] as String, {
                  ...updatedChore,
                });

                // Update assigned user's XP when chore completion changes
                final assignedUserName = chore['assigned'] as String?;
                if (assignedUserName != null &&
                    assignedUserName.isNotEmpty) {
                  final uid = await _firestore.getUserUidByDisplayName(
                    assignedUserName,
                    _householdId,
                  );
                  if (uid != null) {
                    await _firestore.updateUserXpFromCompletedChores(
                      uid,
                      assignedUserName,
                      _householdId,
                    );
                  }
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chore['name'] as String? ?? 'Unnamed Chore'),
                  Text('Assigned to: ${chore['assigned'] ?? 'Unassigned'}'),
                  Text('XP: ${chore['xp'] ?? 0}'),
                  Text(
                    date == null ? '' : DateFormat('MMM d').format(date),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete chore?'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _firestore.deleteChore(
                      chore['id'] as String);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}