import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/user_profile_store.dart';
import '../../services/firestore_service.dart';

class EditChoreScreen extends StatefulWidget {
  final Map<String, dynamic>? chore;
  final VoidCallback? onRumiTap;

  const EditChoreScreen({Key? key, this.chore, this.onRumiTap})
      : super(key: key);

  @override
  State<EditChoreScreen> createState() => _EditChoreScreenState();
}

class _EditChoreScreenState extends State<EditChoreScreen> {
  // ==================== Constants ====================
  static const double _streak_icon_size = 35;
  static const double _back_icon_size = 24;
  static const double _rumi_image_size = 90;
  static const double _input_border_radius = 12;
  static const double _button_height = 54;
  static const double _button_border_radius = 30;
  static const double _header_padding_left = 25;
  static const double _header_padding_right = 18;
  static const double _header_font_size = 36;
  static const double _hint_font_size = 13;
  static const double _input_font_size = 14;
  static const double _streak_font_size = 16;
  static const double _delete_icon_size = 28;
  static const double _sizedbox_width_small = 4;
  static const double _sizedbox_height_small = 6;
  static const double _content_padding_horizontal = 14;
  static const double _content_padding_vertical = 12;
  static const List<int> xpOptions = [15, 25, 50];

  // ==================== Fields ====================
  final formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late final TextEditingController titleController;
  late final TextEditingController dueDateController;
  late final TextEditingController xpController;

  String? selectedRoommate;
  int?    selectedXp;
  bool _isLoading  = false;

  // ==================== Getters ====================
  List<String> get roommates => UserProfileStore.householdMembers.value;

  @override
  void initState() {
    super.initState();
    final c = widget.chore;

    titleController       = TextEditingController(text: c?['name'] ?? '');

    final existingXp = c?['xp'];
    if (existingXp != null && xpOptions.contains(existingXp)) {
      selectedXp = existingXp as int;
    }

    final assigned = c?['assigned'];
    
    selectedRoommate =
        (assigned != null &&
        assigned is String &&
        assigned.isNotEmpty &&
        UserProfileStore.householdMembers.value.contains(assigned))
            ? assigned
            : null;

    final due = c?['dueDate'];
    if (due is DateTime) {
      dueDateController = TextEditingController(
        text:
            '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
      );
    } else {
      dueDateController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final initial =
        DateTime.tryParse(dueDateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dueDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updated = {
      'name':        titleController.text,
      'assigned':    selectedRoommate ?? '',
      'xp':          selectedXp ?? 0,
      'completed':   widget.chore?['completed'] ?? false,
      'dueDate':     DateTime.tryParse(dueDateController.text) ?? DateTime.now(),
      'description': widget.chore?['description'] ?? '',
    };

     try {
      final choreId = widget.chore?['id'] as String?;
      if (choreId != null) {
        await _firestoreService.updateChore(choreId, updated);  // ← ADD THIS
      }
      if (mounted) Navigator.pop(context, updated);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Future<void> deleteChore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Chore',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${titleController.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
     try {
      final choreId = widget.chore?['id'] as String?;
      if (choreId != null) {
        await _firestoreService.deleteChore(choreId);  // ← ADD THIS
      }
      if (mounted) Navigator.pop(context, {'deleted': true});
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopIconsUI(),

                // const Padding(
                //   padding: EdgeInsets.only(left: 25, right: 18, bottom: 12),
                //   child: Text(
                //     'Edit Chore',
                //     style: TextStyle(
                //       fontSize: 36,
                //       fontWeight: FontWeight.w900,
                //       color: Colors.black,
                //       letterSpacing: -0.5,
                //     ),
                //   ),
                // ),

                Padding(
                  padding: const EdgeInsets.only(left: _header_padding_left, right: _header_padding_right, bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Chore',
                        style: TextStyle(
                          fontSize: _header_font_size,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : deleteChore,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: _delete_icon_size),
                        tooltip: 'Delete chore',
                      ),
                    ],
                  ),
                ),


                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: titleController,
                          hint: '*Title',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: dueDateController,
                          hint: '*Due Date',
                          readOnly: true,
                          onTap: pickDate,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        _buildXpDropdown(),
                        const SizedBox(height: 10),
                        _buildRoommateDropdown(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: _button_height,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_button_border_radius),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update Chore',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),

                // Padding(
                //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 54,
                //     child: ElevatedButton(
                //       onPressed: submit,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.black,
                //         foregroundColor: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(30),
                //         ),
                //         elevation: 0,
                //       ),
                //       child: const Text(
                //         'Update Chore',
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontWeight: FontWeight.w700,
                //           letterSpacing: 0.3,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildXpDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedXp,
      hint: Text('*XP Weight',
          style: TextStyle(fontSize: _hint_font_size, color: Colors.grey[500])),
      decoration: _inputDecoration('').copyWith(hintText: null),
      style: const TextStyle(fontSize: _input_font_size, color: Colors.black),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
      items: xpOptions
          .map((xp) => DropdownMenuItem(
                value: xp,
                child: Text('$xp XP'),
              ))
          .toList(),
      onChanged: (val) => setState(() => selectedXp = val),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildTopIconsUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 12),
      child: SizedBox(
        height: 100,
        child: Stack(
          children: [
            // Streak — top left
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: _streak_icon_size,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: _sizedbox_width_small),
                        ValueListenableBuilder<int>(
                          valueListenable: StreakStore.count,
                          builder: (context, streak, _) => Text(
                            '$streak',
                            style: const TextStyle(
                              fontSize: _streak_font_size,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _sizedbox_height_small),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back to home',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: _back_icon_size,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Rumi — top right
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: IconButton(
                  onPressed: widget.onRumiTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: ValueListenableBuilder<String?>(
                    valueListenable: RumiAccessoryStore.selectedAccessory,
                    builder: (context, _, __) => Image.asset(
                      RumiAccessoryStore.currentRumiImagePath,
                      width: _rumi_image_size,
                      height: _rumi_image_size,
                      fit: BoxFit.contain,
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


  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: _hint_font_size, color: Colors.grey[500]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: _content_padding_horizontal, vertical: _content_padding_vertical),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_input_border_radius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_input_border_radius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_input_border_radius),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_input_border_radius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_input_border_radius),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: _input_font_size, color: Colors.black),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildRoommateDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRoommate,
      hint: Text('*Roommate',
          style: TextStyle(fontSize: _hint_font_size, color: Colors.grey[500])),
      decoration: _inputDecoration('').copyWith(hintText: null),
      style: const TextStyle(fontSize: _input_font_size, color: Colors.black),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
      items: roommates
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: (val) => setState(() => selectedRoommate = val),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}