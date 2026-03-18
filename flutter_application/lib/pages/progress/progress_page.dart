import 'package:flutter/material.dart';

const String _currentUser = 'Alex';

const List<Map<String, dynamic>> _leaderboard = [
  {'name': 'Jordan', 'xp': 1340},
  {'name': 'Alex', 'xp': 980},
  {'name': 'Sam', 'xp': 760},
];

const int _userXP = 980;
const int _householdXP = 3080;
const int _streakWeeks = 4;
const double _weeklyProgress = 0.67;

const String _feedback =
    'Great job this week, Alex! You\'re leading in dish duty and took out the trash twice. '
    'Keep it up to close the gap with Jordan!';

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
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top row: streak + mood icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.local_fire_department,
                                color: Colors.orange, size: 22),
                            SizedBox(width: 4),
                            Text(
                              '$_streakWeeks',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black87, width: 1.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          // Todo: Needs to be changed to the rumi icon
                          child: const Icon(Icons.mood_bad,
                              size: 22, color: Colors.black87),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Progress',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Household Leaderboard',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),

                    const SizedBox(height: 20),

                    // Podium
                    const _PodiumWidget(),

                    const SizedBox(height: 24),

                    // Your stats box
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your stats:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatRow(label: 'XP:', value: '$_userXP pts'),
                          SizedBox(height: 4),
                          _StatRow(
                              label: 'Household XP:',
                              value: '$_householdXP pts'),
                          SizedBox(height: 4),
                          _StatRow(
                              label: 'Streak:',
                              value: '$_streakWeeks week(s)'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress for the week
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Progress for the week:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _weeklyProgress,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(_weeklyProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Personalized feedback box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        _feedback,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Achievements
                    const Text(
                      'Achievements',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _achievements
                          .map((a) => _AchievementCard(
                                color: a['color'] as Color,
                                icon: a['icon'] as IconData,
                                title: a['title'] as String,
                                desc: a['desc'] as String,
                                unlocked: a['unlocked'] as bool,
                              ))
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
  }
}

class _PodiumWidget extends StatelessWidget {
  const _PodiumWidget();

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
            name: _leaderboard[1]['name'] as String,
            xp: _leaderboard[1]['xp'] as int,
            isCurrentUser: _leaderboard[1]['name'] == _currentUser,
          ),
          const SizedBox(width: 4),
          _PodiumBlock(
            rank: 1,
            height: 110,
            name: _leaderboard[0]['name'] as String,
            xp: _leaderboard[0]['xp'] as int,
            isCurrentUser: _leaderboard[0]['name'] == _currentUser,
          ),
          const SizedBox(width: 4),
          _PodiumBlock(
            rank: 3,
            height: 60,
            name: _leaderboard[2]['name'] as String,
            xp: _leaderboard[2]['xp'] as int,
            isCurrentUser: _leaderboard[2]['name'] == _currentUser,
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
            color: isCurrentUser
                ? Colors.orange.withOpacity(0.08)
                : Colors.white,
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
                    color: Colors.black87),
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
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(width: 6),
        Text(value,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
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
        Text(title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text(desc,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

