import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.onLogout,
    required this.onRumiTap,
  });

  final VoidCallback onLogout;
  final VoidCallback onRumiTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
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
                              size: 28,
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
            ),
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
