import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore_service.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/rumi_emotion_store.dart';
import '../../shared/streak_store.dart';
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
  static const double _profileIconRadius = 34;
  static const double _titleFontSize = 42;
  static const double _cardHorizontalMargin = 25;
  static const double _cardVerticalMargin = 8;
  static const double _cardBorderRadius = 32;
  static const double _inputBorderRadius = 24;
  static const double _householdListHeight = 168;
  static const double _memberListBorderRadius = 14;

  static const Color _panelBackground = Colors.white;
  static const Color _panelText = Colors.black;
  static const Color _panelBorderColor = Colors.black;
  static const Color _highlightColor = Colors.orange;
  static const double _highlightBorderWidth = 1.8;
  static const double _normalBorderWidth = 1.2;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  List<TextEditingController> _memberControllers = [];
  String? _householdId;

  bool _isEditingName = false;
  bool _isEditingEmail = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadHouseholdData();
  }

  void _initializeControllers() {
    _nameController =
        TextEditingController(text: UserProfileStore.name.value);
    _emailController =
        TextEditingController(text: UserProfileStore.email.value);
    _memberControllers = UserProfileStore.householdMembers.value
        .map((member) => TextEditingController(text: member))
        .toList();
  }

  void _loadHouseholdData() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirestoreService().getCurrentHouseholdId(currentUser.uid).then(
      (householdId) {
        if (!mounted) return;
        setState(() {
          _householdId = householdId;
        });

        UserProfileStore.fetchAndSetHouseholdMembers(householdId)
            .then((_) {
          if (!mounted) return;
          _disposeMemberControllers();
          setState(() {
            _memberControllers = UserProfileStore.householdMembers.value
                .map((member) => TextEditingController(text: member))
                .toList();
          });
        });
      },
    );
  }

  void _disposeMemberControllers() {
    for (final controller in _memberControllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _disposeMemberControllers();
    super.dispose();
  }

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
              _buildTopIconsUI(),
              _buildProfileHeader(),
              _buildProfileCard(),
              _buildLogoutButton(),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== UI Builders ====================

  Widget _buildTopIconsUI() {
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
                  icon: ValueListenableBuilder<String>(
                    valueListenable: RumiEmotionStore.emotion,
                    builder: (context, emotion, _) =>
                        ValueListenableBuilder<String?>(
                          valueListenable:
                              RumiAccessoryStore.selectedAccessory,
                          builder: (context, _, __) => Image.asset(
                            RumiAccessoryStore
                                .currentRumiImagePathForEmotion(emotion),
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
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: _profileIconRadius,
          child: Icon(Icons.person, size: _profileIconRadius),
        ),
        const SizedBox(height: 12),
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: _titleFontSize,
            fontWeight: FontWeight.bold,
            color: _panelText,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: _panelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        side: const BorderSide(
          color: _panelBorderColor,
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: _cardHorizontalMargin,
        vertical: _cardVerticalMargin,
      ),
      child: Column(
        children: [
          _buildNameField(),
          _buildEmailField(),
          _buildHouseholdCodeField(),
          _buildHouseholdMembersSection(),
          const NotificationsSwitch(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
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
        style: const TextStyle(color: _panelText),
        decoration: _buildInputDecoration('Name').copyWith(
          fillColor: _isEditingName
              ? Colors.orange.shade100
              : _panelBackground,
          enabledBorder: _buildBorder(
            _isEditingName ? _highlightColor : _panelBorderColor,
            _normalBorderWidth,
          ),
          focusedBorder: _buildBorder(
            _isEditingName ? _highlightColor : _panelBorderColor,
            _highlightBorderWidth,
          ),
          suffixIcon: IconButton(
            tooltip:
                _isEditingName ? 'Stop editing name' : 'Edit name',
            icon: const Icon(Icons.edit, color: _panelText),
            onPressed: () {
              setState(() {
                _isEditingName = !_isEditingName;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
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
        style: const TextStyle(color: _panelText),
        decoration: _buildInputDecoration('Email').copyWith(
          fillColor: _isEditingEmail
              ? Colors.orange.shade100
              : _panelBackground,
          enabledBorder: _buildBorder(
            _isEditingEmail ? _highlightColor : _panelBorderColor,
            _normalBorderWidth,
          ),
          focusedBorder: _buildBorder(
            _isEditingEmail ? _highlightColor : _panelBorderColor,
            _highlightBorderWidth,
          ),
          suffixIcon: IconButton(
            tooltip:
                _isEditingEmail ? 'Stop editing email' : 'Edit email',
            icon: const Icon(Icons.edit, color: _panelText),
            onPressed: () {
              setState(() {
                _isEditingEmail = !_isEditingEmail;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHouseholdCodeField() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Household code',
              style: TextStyle(
                color: _panelText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _panelBackground,
              border: Border.all(
                color: _panelBorderColor,
                width: _normalBorderWidth,
              ),
              borderRadius: BorderRadius.circular(_inputBorderRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _householdId ?? 'Unavailable',
                    style: const TextStyle(
                      color: _panelText,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _copyHouseholdCode,
                  icon: const Icon(Icons.copy, color: _panelText),
                  tooltip: 'Copy code',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseholdMembersSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Household members',
              style: TextStyle(
                color: _panelText,
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
            color: _panelBackground,
            border: Border.all(
              color: _panelBorderColor,
              width: _normalBorderWidth,
            ),
            borderRadius: BorderRadius.circular(_memberListBorderRadius),
          ),
          child: SizedBox(
            height: _householdListHeight,
            child: ValueListenableBuilder<List<String>>(
              valueListenable: UserProfileStore.householdMembers,
              builder: (context, members, _) {
                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return TextFormField(
                      controller: TextEditingController(
                        text: members[index],
                      ),
                      readOnly: true,
                      style: const TextStyle(color: _panelText),
                      decoration: _buildInputDecoration(
                        '',
                        hint: 'Household member',
                        radius: _memberListBorderRadius,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _panelText,
                side: const BorderSide(color: _panelBorderColor),
                minimumSize: const Size(0, 45),
              ),
              onPressed: _handleLeaveHousehold,
              child: const Text('Leave household'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _panelText,
                side: const BorderSide(color: _panelBorderColor),
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
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _panelText,
          fixedSize: const Size(100, 45),
        ),
        onPressed: _handleLogout,
        child: const Text('Log out'),
      ),
    );
  }

  // ==================== Helper Methods ====================

  InputDecoration _buildInputDecoration(
    String label, {
    String? hint,
    double radius = _inputBorderRadius,
  }) {
    final muteColor = Colors.grey.shade700;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: muteColor),
      hintStyle: TextStyle(color: muteColor),
      filled: true,
      fillColor: _panelBackground,
      enabledBorder: _buildBorder(_panelBorderColor, _normalBorderWidth, radius),
      focusedBorder: _buildBorder(_panelBorderColor, _highlightBorderWidth, radius),
      border: _buildBorder(_panelBorderColor, _normalBorderWidth, radius),
    );
  }

  OutlineInputBorder _buildBorder(
    Color color,
    double width, [
    double radius = _inputBorderRadius,
  ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
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
          ? UserProfileStore.name.value
          : _nameController.text.trim(),
      updatedEmail: _emailController.text.trim().isEmpty
          ? 'fakeEmail@gmail.com'
          : _emailController.text.trim(),
      updatedMembers: updatedMembers.isEmpty
          ? List<String>.from(
              UserProfileStore.defaultHouseholdMembers,
            )
          : updatedMembers,
    );

    setState(() {
      _isEditingName = false;
      _isEditingEmail = false;
    });
  }

  void _copyHouseholdCode() {
    if (_householdId != null && _householdId!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _householdId!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Household code copied!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleLeaveHousehold() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Household?'),
        content: const Text(
          'Are you sure you want to leave the household? '
          'Doing so will delete your account!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final householdId =
            await FirestoreService().getCurrentHouseholdId(uid);
        await FirestoreService()
            .removeMemberFromHousehold(householdId, uid);
        await FirebaseAuth.instance.signOut();
        widget.onLogout();
      }
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    widget.onLogout();
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

