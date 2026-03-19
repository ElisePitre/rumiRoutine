import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/user_profile_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.onLogout,
    required this.onRumiTap,
  });

  final VoidCallback onLogout;
  final VoidCallback onRumiTap;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final List<TextEditingController> _memberControllers;
  bool _isEditingName = false;
  bool _isEditingEmail = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserProfileStore.name.value);
    _emailController = TextEditingController(text: UserProfileStore.email.value);
    _memberControllers = UserProfileStore.householdMembers.value
        .map((member) => TextEditingController(text: member))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    for (final controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveProfile() {
    if (!_isEditingName && !_isEditingEmail) {
      return;
    }

    final updatedMembers = _memberControllers
        .map((controller) => controller.text.trim())
        .where((member) => member.isNotEmpty)
        .toList();

    UserProfileStore.saveProfile(
      updatedName: _nameController.text.trim().isEmpty
        ? UserProfileStore.defaultName
          : _nameController.text.trim(),
      updatedEmail: _emailController.text.trim().isEmpty
          ? 'fakeEmail@gmail.com'
          : _emailController.text.trim(),
      updatedMembers: updatedMembers.isEmpty
        ? List<String>.from(UserProfileStore.defaultHouseholdMembers)
          : updatedMembers,
    );

    setState(() {
      _isEditingName = false;
      _isEditingEmail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color panelBackground = Colors.white;
    final Color panelText = Colors.black;
    final Color panelMutedText = Colors.grey.shade700;
    final Color inputBackground = Colors.white;
    final Color panelBorderColor = Colors.black;

    InputDecoration buildInputDecoration({
      required String label,
      String? hint,
      double radius = 24,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: panelMutedText),
        hintStyle: TextStyle(color: panelMutedText),
        filled: true,
        fillColor: inputBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: panelBorderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: panelBorderColor, width: 1.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: panelBorderColor, width: 1.2),
        ),
      );
    }

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
                              valueListenable:
                                  RumiAccessoryStore.selectedAccessory,
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
                  color: Colors.black,
                ),
              ),
              Card(
                color: panelBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: BorderSide(
                    color: panelBorderColor,
                    width: 1.0,
                  ),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                      child: TextFormField(
                        controller: _nameController,
                        readOnly: !_isEditingName,
                        onTap: () {
                          if (!_isEditingName) {
                            setState(() {
                              _isEditingName = true;
                            });
                          }
                        },
                        style: TextStyle(color: panelText),
                        decoration: buildInputDecoration(label: 'Name').copyWith(
                          fillColor:
                              _isEditingName ? Colors.orange.shade100 : Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color:
                                  _isEditingName ? Colors.orange : panelBorderColor,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color:
                                  _isEditingName ? Colors.orange : panelBorderColor,
                              width: 1.8,
                            ),
                          ),
                          suffixIcon: IconButton(
                            tooltip: _isEditingName
                                ? 'Stop editing name'
                                : 'Edit name',
                            icon: const Icon(Icons.edit, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _isEditingName = !_isEditingName;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                      child: TextFormField(
                        controller: _emailController,
                        readOnly: !_isEditingEmail,
                        onTap: () {
                          if (!_isEditingEmail) {
                            setState(() {
                              _isEditingEmail = true;
                            });
                          }
                        },
                        style: TextStyle(color: panelText),
                        decoration:
                            buildInputDecoration(label: 'Email').copyWith(
                          fillColor:
                              _isEditingEmail ? Colors.orange.shade100 : Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: _isEditingEmail
                                  ? Colors.orange
                                  : panelBorderColor,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: _isEditingEmail
                                  ? Colors.orange
                                  : panelBorderColor,
                              width: 1.8,
                            ),
                          ),
                          suffixIcon: IconButton(
                            tooltip: _isEditingEmail
                                ? 'Stop editing email'
                                : 'Edit email',
                            icon: const Icon(Icons.edit, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _isEditingEmail = !_isEditingEmail;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Household members',
                          style: TextStyle(
                            color: panelText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: inputBackground,
                        border: Border.all(
                          color: panelBorderColor,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SizedBox(
                        height: 168,
                        child: ListView.separated(
                          itemCount: _memberControllers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return TextFormField(
                              controller: _memberControllers[index],
                              readOnly: true,
                              style: TextStyle(color: panelText),
                              decoration: buildInputDecoration(
                                label: '',
                                hint: 'Household member',
                                radius: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const NotificationsSwitch(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: panelText,
                                side: const BorderSide(color: Colors.black),
                                minimumSize: const Size(0, 45),
                              ),
                              onPressed: () {
                                // TODO: Implement leave household functionality
                              },
                              child: const Text('Leave household'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: panelText,
                                side: const BorderSide(color: Colors.black),
                                minimumSize: const Size(0, 45),
                              ),
                              onPressed:
                                  (_isEditingName || _isEditingEmail)
                                      ? _saveProfile
                                      : null,
                              child: const Text('Save changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  fixedSize: const Size(100, 45),
                ),
                onPressed: widget.onLogout,
                child: const Text('Log out'),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
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
