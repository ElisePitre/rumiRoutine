import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../progress/progress_page.dart';
import '../rumi/rumi_page.dart';
import '../../services/firestore_service.dart';
import '../../shared/household_xp_store.dart';
import '../../shared/streak_store.dart';
import '../../shared/user_profile_store.dart';
import '../../shared/rumi_emotion_store.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _firestore = FirestoreService();

  int _selectedIndex = 0;
  int _rumiAgeDays = 7;
  String _rumiEmotion = 'normal';
  String _boundHouseholdId = '';

  StreamSubscription<Map<String, dynamic>?>? _userSubscription;
  StreamSubscription<Map<String, dynamic>?>? _householdSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _householdUsersSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _choresSubscription;

  @override
  void initState() {
    super.initState();
    _bindRealtimeData();
  }

  void _bindRealtimeData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _userSubscription = _firestore.streamUserProfile(uid).listen((userData) {
      if (userData == null) return;

      final name = (userData['displayName'] ?? '').toString();
      final email = (userData['email'] ?? '').toString();
      final householdId = (userData['householdId'] ?? '').toString();

      if (name.isNotEmpty && UserProfileStore.name.value != name) {
        UserProfileStore.name.value = name;
      }
      if (email.isNotEmpty && UserProfileStore.email.value != email) {
        UserProfileStore.email.value = email;
      }

      if (householdId.isEmpty || householdId == _boundHouseholdId) {
        return;
      }

      _boundHouseholdId = householdId;
      _householdSubscription?.cancel();
      _householdUsersSubscription?.cancel();
      _choresSubscription?.cancel();

      _householdSubscription =
          _firestore.streamHousehold(householdId).listen((householdData) {
        final streak = (householdData?['streak'] as num?)?.toInt() ?? 0;
        if (StreakStore.count.value != streak) {
          StreakStore.update(streak);
        }
      });

      // Combine users and chores streams to calculate total household XP and emotion
      _householdUsersSubscription =
          _firestore.streamUsersByHousehold(householdId).listen((users) {
        _choresSubscription?.cancel();
        _choresSubscription = _firestore.streamChores(householdId).listen((chores) async {
          await _firestore.syncHouseholdUserXpFromCompletedChores(users, chores);

          // Calculate household XP with completed chore bonuses
          final householdXp = _firestore.computeHouseholdXpWithChores(users, chores);

          if (HouseholdXpStore.householdXp.value != householdXp) {
            HouseholdXpStore.update(householdXp);
          }

          // Update streak if no overdue chores
          _firestore.updateHouseholdStreakIfNeeded(householdId, chores);

          // Calculate rumi emotion based on overdue chores
          final overdueCount = _firestore.countOverdueChores(chores);
          final newEmotion = _calculateRumiEmotion(chores, overdueCount);

          if (_rumiEmotion != newEmotion) {
            setState(() {
              _rumiEmotion = newEmotion;
            });
            RumiEmotionStore.update(newEmotion);
          }

          final members = users
              .map((user) => (user['displayName'] ?? '').toString())
              .where((name) => name.isNotEmpty)
              .toList();

          if (!listEquals(UserProfileStore.householdMembers.value, members)) {
            UserProfileStore.householdMembers.value = members;
          }
        });
      });
    });
  }

  String _calculateRumiEmotion(
    List<Map<String, dynamic>> chores,
    int overdueCount,
  ) {
    // Count uncompleted chores
    final uncompletedCount = chores.where((c) => !c['completed']).length;

    // If no incomplete chores at all, rumi is blissful
    if (uncompletedCount == 0) {
      return 'blissful';
    }

    // If 2 or more overdue, rumi is angry
    if (overdueCount >= 2) {
      return 'angry';
    }

    // If 1 overdue, rumi is sad
    if (overdueCount == 1) {
      return 'sad';
    }

    // Default: normal
    return 'normal';
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _householdSubscription?.cancel();
    _householdUsersSubscription?.cancel();
    _choresSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onRumiTap: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
      ),
      ProgressPage(
        onRumiTap: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
      ),
      ProfilePage(
        onRumiTap: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
        onLogout: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
      ),
      RumiPage(
        rumiAgeDays: _rumiAgeDays,
        currentEmotion: _rumiEmotion,
      ),
    ];

    return Scaffold(
      body: SafeArea (
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outlined),
            selectedIcon: Icon(Icons.favorite),
            label: '',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
