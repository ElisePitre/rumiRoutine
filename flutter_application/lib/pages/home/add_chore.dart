import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/user_profile_store.dart';
import '../../services/firestore_service.dart';

class AddChoreScreen extends StatefulWidget {
  final VoidCallback? onRumiTap;
  final String householdId;
  
  const AddChoreScreen({
    Key? key,
    this.onRumiTap,
    required this.householdId,
  }) : super(key: key);

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
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
  static const double _sizedbox_width_small = 4;
  static const double _sizedbox_height_small = 6;
  static const double _content_padding_horizontal = 14;
  static const double _content_padding_vertical = 12;
  static const List<int> xpOptions = [15, 25, 50];

  // ==================== Fields ====================
  final formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final titleController       = TextEditingController();
  final dueDateController     = TextEditingController();
  final xpController          = TextEditingController();

  String? selectedRoommate;
  int?    selectedXp;

  // ==================== Getters ====================
  List<String> get roommates => UserProfileStore.householdMembers.value;

  @override
  void dispose() {
    titleController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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

  Future<void> _submit() async {               
    if (!formKey.currentState!.validate()) return;

    final newChore = {
      'name':      titleController.text,
      'assigned':  selectedRoommate ?? '',
      'xp':        selectedXp ?? 0,
      'completed': false,
      'dueDate':   DateTime.tryParse(dueDateController.text) ?? DateTime.now(),
      'householdId': widget.householdId, 
    };

    await _firestoreService.addChore(newChore);  
    if (mounted) Navigator.pop(context);
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

                const Padding(
                  padding: EdgeInsets.only(left: _header_padding_left, right: _header_padding_right, bottom: 12),
                  child: Text(
                    'Add Chore',
                    style: TextStyle(
                      fontSize: _header_font_size,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
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
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_button_border_radius),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add Chore',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
}