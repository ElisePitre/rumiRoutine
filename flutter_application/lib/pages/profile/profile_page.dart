import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 34)),
            const SizedBox(height: 12),
            const Text('Profile Page Skeleton'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onLogout,
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
