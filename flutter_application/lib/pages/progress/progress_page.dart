import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore_service.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/rumi_emotion_store.dart';
import '../../shared/streak_store.dart';

const List<Map<String, dynamic>> _achievements = [
  {
    'icon': Icons.local_fire_department,
    'color': Color(0xFFE8E872),
    'title': 'On Fire',
    'desc': '4-week streak',
    'unlocked': true,
  },
  {
    'icon': Icons.cleaning_services,
    'color': Color(0xFF90CAF9),
    'title': 'Spotless',
    'desc': '10 cleans done',
    'unlocked': true,
  },
  {
    'icon': Icons.star,
    'color': Color(0xFFBDBDBD),
    'title': 'MVP',
    'desc': 'Top XP in a week',
    'unlocked': false,
  },
];

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.onRumiTap});

  final VoidCallback onRumiTap;

  DateTime _startOfWeek(DateTime date) {
    final localDate = DateTime(date.year, date.month, date.day);
    final daysFromMonday = localDate.weekday - DateTime.monday;
    return localDate.subtract(Duration(days: daysFromMonday));
  }

  DateTime _endOfWeek(DateTime date) {
    final start = _startOfWeek(date);
    return start.add(const Duration(days: 7));
  }

  bool _isDueThisWeek(DateTime dueDate, DateTime now) {
    final start = _startOfWeek(now);
    final endExclusive = _endOfWeek(now);
    return !dueDate.isBefore(start) && dueDate.isBefore(endExclusive);
  }

  List<Map<String, dynamic>> _normalizedLeaderboard(
    List<Map<String, dynamic>> users,
  ) {
    final leaderboard = users
        .map(
          (user) => {
            'name': (user['displayName'] ?? 'Unknown').toString(),
            'xp': (user['xp'] as num?)?.toInt() ?? 0,
          },
        )
        .toList();

    while (leaderboard.length < 3) {
      leaderboard.add({'name': '-', 'xp': 0});
    }

    return leaderboard.take(3).toList();
  }

  String _feedbackFor({
    required String currentUser,
    required int rank,
    required int userXp,
    required int householdXp,
  }) {
    final safeUser = currentUser.isEmpty ? 'You' : currentUser;
    if (householdXp == 0) {
      return 'No household XP yet. Start completing chores to build momentum, $safeUser!';
    }
    if (rank == 1) {
      return 'Great job, $safeUser! You are currently leading your household in XP.';
    }
    return 'Nice work, $safeUser. You are rank #$rank in your household. Keep going to climb the leaderboard.';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view progress.')),
      );
    }

    final firestore = FirestoreService();

    return StreamBuilder<Map<String, dynamic>?>(
      stream: firestore.streamUserProfile(uid),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data ?? <String, dynamic>{};
        final currentUser = (userData['displayName'] ?? 'You').toString();
        final householdId = (userData['householdId'] ?? '').toString();
        final userXp = (userData['xp'] as num?)?.toInt() ?? 0;

        if (householdId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No household found for this account.')),
          );
        }

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: firestore.streamUsersByHousehold(householdId),
          builder: (context, usersSnapshot) {
            if (!usersSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final users = usersSnapshot.data ?? const <Map<String, dynamic>>[];
            final leaderboard = _normalizedLeaderboard(users);
            final rankIndex = users.indexWhere(
              (user) => (user['displayName'] ?? '').toString() == currentUser,
            );
            final rank = rankIndex == -1 ? users.length + 1 : rankIndex + 1;

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore.streamChores(householdId),
              builder: (context, choresSnapshot) {
                if (!choresSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final chores = choresSnapshot.data ?? const <Map<String, dynamic>>[];
                final householdXp = firestore.computeHouseholdXpWithChores(users, chores);
                final now = DateTime.now();
                final choresDueThisWeek = chores.where((chore) {
                  final dueDate = chore['dueDate'];
                  if (dueDate is! DateTime) {
                    return false;
                  }
                  return _isDueThisWeek(dueDate, now);
                }).toList();
                final completedDueThisWeek = choresDueThisWeek
                    .where((chore) => chore['completed'] == true)
                    .length;
                final weeklyProgress = choresDueThisWeek.isEmpty
                    ? 0.0
                    : (completedDueThisWeek / choresDueThisWeek.length).clamp(0.0, 1.0);

                return StreamBuilder<Map<String, dynamic>?>(
                  stream: firestore.streamHousehold(householdId),
                  builder: (context, householdSnapshot) {
                    final householdData = householdSnapshot.data;
                    final streak = (householdData?['streak'] as num?)?.toInt() ?? 0;

                    final feedback = _feedbackFor(
                      currentUser: currentUser,
                      rank: rank,
                      userXp: userXp,
                      householdXp: householdXp,
                    );

                    return Scaffold(
                      backgroundColor: Colors.white,
                      body: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
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
                                                onPressed: onRumiTap,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: ValueListenableBuilder<String>(
                                                  valueListenable: RumiEmotionStore.emotion,
                                                  builder: (context, emotion, _) =>
                                                      ValueListenableBuilder<String?>(
                                                        valueListenable: RumiAccessoryStore.selectedAccessory,
                                                        builder: (context, _, __) => Image.asset(
                                                          RumiAccessoryStore.currentRumiImagePathForEmotion(emotion),
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
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Progress',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Household Leaderboard',
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 20),
                                    _PodiumWidget(
                                      leaderboard: leaderboard,
                                      currentUser: currentUser,
                                    ),
                                    const SizedBox(height: 24),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Your stats:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black26, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _StatRow(label: 'XP:', value: '$userXp pts'),
                                          const SizedBox(height: 4),
                                          _StatRow(
                                            label: 'Household XP:',
                                            value: '$householdXp pts',
                                          ),
                                          const SizedBox(height: 4),
                                          _StatRow(
                                            label: 'Streak:',
                                            value: '$streak week(s)',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Household chores due this week:',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: LinearProgressIndicator(
                                              value: weeklyProgress,
                                              minHeight: 12,
                                              backgroundColor: Colors.grey.shade300,
                                              valueColor: const AlwaysStoppedAnimation<Color>(
                                                Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${(weeklyProgress * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black26, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        feedback,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Achievements',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: _achievements
                                          .map(
                                            (a) => _AchievementCard(
                                              color: a['color'] as Color,
                                              icon: a['icon'] as IconData,
                                              title: a['title'] as String,
                                              desc: a['desc'] as String,
                                              unlocked: a['unlocked'] as bool,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  const _PodiumWidget({
    required this.leaderboard,
    required this.currentUser,
  });

  final List<Map<String, dynamic>> leaderboard;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PodiumBlock(
            rank: 2,
            height: 80,
            name: leaderboard[1]['name'] as String,
            xp: leaderboard[1]['xp'] as int,
            isCurrentUser: leaderboard[1]['name'] == currentUser,
          ),
          const SizedBox(width: 4),
          _PodiumBlock(
            rank: 1,
            height: 110,
            name: leaderboard[0]['name'] as String,
            xp: leaderboard[0]['xp'] as int,
            isCurrentUser: leaderboard[0]['name'] == currentUser,
          ),
          const SizedBox(width: 4),
          _PodiumBlock(
            rank: 3,
            height: 60,
            name: leaderboard[2]['name'] as String,
            xp: leaderboard[2]['xp'] as int,
            isCurrentUser: leaderboard[2]['name'] == currentUser,
          ),
        ],
      ),
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  final int rank;
  final double height;
  final String name;
  final int xp;
  final bool isCurrentUser;

  const _PodiumBlock({
    required this.rank,
    required this.height,
    required this.name,
    required this.xp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: isCurrentUser ? Colors.orange : Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 75,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(
              color: isCurrentUser ? Colors.orange : Colors.black87,
              width: isCurrentUser ? 2 : 1.5,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            color: isCurrentUser ? Colors.orange.withValues(alpha: 0.08) : Colors.white,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$xp XP',
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String desc;
  final bool unlocked;

  const _AchievementCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.desc,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: unlocked ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 28,
            color: unlocked ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Text(
          desc,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }
}
