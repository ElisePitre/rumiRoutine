import 'package:flutter/material.dart';
import '../home/add_chore.dart';
import '../home/edit_chore.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/user_profile_store.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoryType {
    completed,  
    dueToday,   
    myChores,    
  }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.onRumiTap}) : super(key: key);

  final VoidCallback onRumiTap;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirestoreService();
  final String householdId = "test-household"; // TEMP
  CategoryType? categoryType;

  @override
  void initState() {
    super.initState();

    // TODO: just to temporarily set the user for tests, should be based on the user logged in instead
    UserProfileStore.name.value = "User";
  }
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddChoreScreen(onRumiTap: widget.onRumiTap),
              ),
            );
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
          children: [
            getTopIconsUI(),
            getAppBarUI(),
            getCategoryUI(),
          ],
        ),
        ),
      ),
    );
  }
  List<Map<String, dynamic>> getOverdueChores(List<Map<String, dynamic>> chores) {
    final now = DateTime.now();

    return chores.where((c) =>
      !c['completed'] &&
      (c['dueDate'] as DateTime).isBefore(now)
    ).toList();
  }
  List<Map<String, dynamic>> applyFilter(List<Map<String, dynamic>> chores) {
    final today = DateTime.now();

    if (categoryType == null) return chores;

    if (categoryType == CategoryType.completed) {
      return chores.where((c) => c['completed'] == true).toList();
    } 
    else if (categoryType == CategoryType.dueToday) {
      return chores.where((c) =>
        !c['completed'] &&
        isSameDay(c['dueDate'], today)
      ).toList();
    } 
    else {
      return chores.where((c) =>
        c['assigned'] == UserProfileStore.name.value
      ).toList();
    }
  }
    Widget buildChoreTile(Map<String, dynamic> chore) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
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
            color: Colors.grey[200], // 👈 THIS is what you want
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Checkbox(
                value: chore['completed'],
                onChanged: (value) {
                  if (value == null) return;

                  Future.microtask(() async {
                    await _firestore.updateChore(chore['id'], {
                      ...chore,
                      'completed': value,
                    });
                  });
                },
              ),
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chore['name']),
                  Text('Assigned to: ${chore['assigned']}'),
                  Text('XP: ${chore['xp']}'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete chore?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _firestore.deleteChore(chore['id']);
                }
              },
            ),
          ]
        ),
      ),
    );
  }
  Widget getOverdueChoresUI(List<Map<String, dynamic>> chores) {
    final overdue = getOverdueChores(chores);

    if (overdue.isEmpty) {
      return const SizedBox(); // hide section if none
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16),
          child: Text(
            'Overdue Chores',
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chore['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chore['assigned'],
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
  Widget getCategoryUI() {
    return StreamBuilder(
      stream: _firestore.streamChores(householdId),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final firestoreChores = snapshot.data!;

        final filteredChores = applyFilter(firestoreChores);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getOverdueChoresUI(firestoreChores),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  getButtonUI(
                    CategoryType.completed,
                    categoryType == CategoryType.completed,
                  ),
                  const SizedBox(width: 16),

                  getButtonUI(
                    CategoryType.dueToday,
                    categoryType == CategoryType.dueToday,
                  ),
                  const SizedBox(width: 16),

                  getButtonUI(
                    CategoryType.myChores,
                    categoryType == CategoryType.myChores,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredChores.length,
              itemBuilder: (context, index) {
                return buildChoreTile(filteredChores[index]);
              },
            ),
          ],
        );
      },
    );
  }
  Widget getTopIconsUI() {
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
                  icon: ValueListenableBuilder<String?>(
                    valueListenable: RumiAccessoryStore.selectedAccessory,
                    builder: (context, _, __) => Image.asset(
                      RumiAccessoryStore.currentRumiImagePath,
                      width: 112,
                      height: 112,
                      fit: BoxFit.contain,
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
  Widget getAppBarUI() {
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
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 25,
                      letterSpacing: 0.2,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  'Chore Page',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                    letterSpacing: 0.27,
                    color: Colors.black,
                  ),
                ),
                
                /*ElevatedButton(
                  onPressed: testCreateUser,
                  child: const Text("Test Create User"),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget getChoreListUI() {
    return StreamBuilder(
      //stream: _firestore.getChores(householdId),
      stream: _firestore.streamChores(householdId),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        //final docs = snapshot.data!.docs;
        final firestoreChores = snapshot.data!;

        final filteredChores = applyFilter(firestoreChores);

        return Column(
          children: [
            getOverdueChoresUI(firestoreChores), 

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredChores.length,
              itemBuilder: (context, index) {
                return buildChoreTile(filteredChores[index]);
              },
            ),
          ],
        );
      },
    );
  }
  bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year &&
            a.month == b.month &&
            a.day == b.day;
  }
  Widget getButtonUI(CategoryType categoryTypeData, bool isSelected) {
    String txt = '';
    if (CategoryType.completed == categoryTypeData) {
      txt = 'Completed';
    } 
    else if (CategoryType.dueToday == categoryTypeData) {
      txt = 'Due Today';
    } 
    else if (CategoryType.myChores == categoryTypeData) {
      txt = 'My Chores';
    }
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: isSelected
                ? Colors.black
                : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            border: Border.all(color: Colors.black)),
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
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, left: 18, right: 18),
              child: Center(
                child: Text(
                  txt,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.27,
                    color: isSelected
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}