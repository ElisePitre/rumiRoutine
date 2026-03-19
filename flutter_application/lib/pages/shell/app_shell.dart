import 'package:flutter/material.dart';

import '../auth/login_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../progress/progress_page.dart';
import '../rumi/rumi_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  int _rumiAgeDays = 7;
  String _rumiEmotion = 'normal';

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
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
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
