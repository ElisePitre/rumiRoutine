import 'package:flutter/material.dart';
import '../home/add_chore.dart';
import '../home/edit_chore.dart';

enum CategoryType {
    completed,  
    dueToday,   
    myChores,    
  }
final List<Map<String, String>> overdueChores = [
  {'name': 'Wash dishes', 'assigned': 'Silvia'},
  {'name': 'Take out trash', 'assigned': 'Caitlin'},
];
List<Map<String, dynamic>> chores = [
  {
    'name': 'Wash dishes',
    'assigned': 'Alex',
    'xp': 20,
    'completed': false,
    'dueDate': DateTime.now(), // due today
  },
  {
    'name': 'Take out trash',
    'assigned': 'Sam',
    'xp': 15,
    'completed': true,
    'dueDate': DateTime.now().add(const Duration(days: 2)), // future
  },
  {
    'name': 'Vacuum',
    'assigned': 'Jordan',
    'xp': 25,
    'completed': false,
    'dueDate': DateTime.now().add(const Duration(days: 1)),
  },
];
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CategoryType? categoryType;

  @override
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
                builder: (context) => AddChoreScreen(),
              ),
            );
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
          children: [
            getAppBarUI(),
            getCategoryUI(),
          ],
        ),
        ),
      ),
    );
  }
  List<Map<String, dynamic>> getFilteredChores() {
    final today = DateTime.now();

    if (categoryType == null) {
      List<Map<String, dynamic>> allChores = List.from(chores);

      allChores.sort((a, b) {
        if (a['completed'] == b['completed']) return 0;
        return a['completed'] ? 1 : -1;
      });

      return allChores;
    }

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
      return chores.where((c) => c['assigned'] == 'Alex').toList();
    }
  }
  Widget getOverdueChoresUI() {
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
          height: 120, // controls card height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: overdueChores.length,
            itemBuilder: (context, index) {
              final chore = overdueChores[index];

              return Container(
                width: 160,
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    Text(
                      chore['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center, 
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${chore['assigned']}',
                      style: const TextStyle(fontSize: 14),
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
          ),
          getOverdueChoresUI(),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                getButtonUI(CategoryType.completed, categoryType == CategoryType.completed),
                const SizedBox(
                  width: 16,
                ),
                getButtonUI(
                    CategoryType.dueToday, categoryType == CategoryType.dueToday),
                const SizedBox(
                  width: 16,
                ),
                getButtonUI(
                    CategoryType.myChores, categoryType == CategoryType.myChores),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          getChoreListUI(),
        ],
      );
    }
  Widget getAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 25, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hello User!',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 25,
                    letterSpacing: 0.2,
                    color: Colors.grey,
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
              ],
            ),
          ),
          SizedBox(
            width: 150,
            height: 150,
            // TODO: replace with (dynamic) Rumi image
            child: Image.asset('assets/smiski1.jpg'),
          )
        ],
      ),
    );
  }
  Widget getChoreListUI() {
    final filteredChores = getFilteredChores();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredChores.length,
      itemBuilder: (context, index) {
        final chore = filteredChores[index];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditChoreScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
            padding: const EdgeInsets.all(16), 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), 
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: chore['completed'],
                  onChanged: (value) {
                    setState(() {
                      chore['completed'] = value;
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chore['name'],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          decoration: chore['completed']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: chore['completed']
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Assigned to: ${chore['assigned']}'),
                      Text('XP: ${chore['xp']}'),
                      Text(
                        'Due: ${(chore['dueDate'] as DateTime).toString().split(' ')[0]}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      chores.remove(chore);
                    });
                  },
                ),
              ],
            ),
          ),
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