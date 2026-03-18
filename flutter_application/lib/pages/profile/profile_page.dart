import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 34)),
            const SizedBox(height: 12),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 42, 
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: Column(
                children: [
                  Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                  child:TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  ),
                  Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  ),
                  Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
                  child: TextFormField(
                    maxLines: 5, // Max height in lines before scrolling
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Household members',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ),
                  const NotificationsSwitch(),
                  // Row(
                  //   children: [
                  //     Text(
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: Colors.black

                  //       ),
                  //     'Notifications'
                  //     //TODO: Add swtich toogle for notifications
                  //     ),
                  //   ]
                  // ),
                  
                  Padding(
                  padding: const EdgeInsets.all(18),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      //backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      fixedSize: Size(160,45),
                    ),
                    onPressed: () {
                      // TODO: Implement leave household functionality
                    },
                    child: const Text('Leave household'),
                  ),
                  )

                ],
              )
            ),

            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                //backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                fixedSize: Size(100,45),
              ),
              onPressed: onLogout,
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsSwitch extends StatefulWidget {
  const NotificationsSwitch({super.key});

  @override
  State<NotificationsSwitch> createState() => _NotificationsSwitchState();
}

class _NotificationsSwitchState extends State<NotificationsSwitch> {
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Notifications'),
      value: _notifications,
      onChanged: (bool value) {
        setState(() {
          _notifications = value;
        });
      },
    );
  }
}
