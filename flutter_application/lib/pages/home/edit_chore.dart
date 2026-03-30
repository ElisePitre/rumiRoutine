import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/user_profile_store.dart';

class EditChoreScreen extends StatefulWidget {
  /// Pass the existing chore map from the home screen.
  /// Expected keys: 'name', 'assigned', 'xp', 'dueDate',
  ///                'description', 'recurring', 'rotation', 'completed'
  
  final Map<String, dynamic>? chore;
  final VoidCallback? onRumiTap;

  const EditChoreScreen({Key? key, this.chore, this.onRumiTap})
      : super(key: key);

  @override
  State<EditChoreScreen> createState() => _EditChoreScreenState();
}

class _EditChoreScreenState extends State<EditChoreScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController dueDateController;
  late final TextEditingController xpController;

  String? selectedRoommate;
  int?    selectedXp;
  bool isRecurring = false;
  bool isRotation  = false;

  static const List<int> xpOptions = [15, 25, 50];
  
  List<String> get roommates => UserProfileStore.householdMembers.value;

  @override
  void initState() {
    super.initState();
    final c = widget.chore;

    titleController       = TextEditingController(text: c?['name'] ?? '');
    //xpController          = TextEditingController(text: c?['xp']?.toString() ?? '');
    isRecurring           = c?['recurring'] ?? false;
    isRotation            = c?['rotation']  ?? false;

    selectedRoommate = (c?['assigned'] != null &&
            (c!['assigned'] as String).isNotEmpty)
        ? c['assigned'] as String
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
    //xpController.dispose();
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

  void submit() {
    if (formKey.currentState!.validate()) {
      final updated = {
        'name':        titleController.text,
        'assigned':    selectedRoommate ?? '',
        'xp':          selectedXp ?? 0,
        'completed':   widget.chore?['completed'] ?? false,
        'dueDate':     DateTime.tryParse(dueDateController.text) ?? DateTime.now(),
        'description': widget.chore?['description'] ?? '',
        'recurring':   isRecurring,
        'rotation':    isRotation,
      };
      Navigator.pop(context, updated);
    }
  }

  void deleteChore() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Chore',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${titleController.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, {'deleted': true});
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                buildTopIconsUI(),

                const Padding(
                  padding: EdgeInsets.only(left: 25, right: 18, bottom: 12),
                  child: Text(
                    'Edit Chore',
                    style: TextStyle(
                      fontSize: 36,
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
                        buildTextField(
                          controller: titleController,
                          hint: '*Title',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        buildTextField(
                          controller: dueDateController,
                          hint: '*Due Date',
                          readOnly: true,
                          onTap: pickDate,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        buildXpDropdown(),
                        const SizedBox(height: 10),
                        buildRoommateDropdown(),
                        const SizedBox(height: 16),

                        // ── Recurring? / Rotation? toggles ─────────
                        Row(
                          children: [
                            Expanded(
                              child: buildToggleButton(
                                label: 'Recurring?',
                                isActive: isRecurring,
                                onTap: () => setState(
                                    () => isRecurring = !isRecurring),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildToggleButton(
                                label: 'Rotation?',
                                isActive: isRotation,
                                onTap: () =>
                                    setState(() => isRotation = !isRotation),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildXpDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedXp,
      hint: Text('*XP Weight',
          style: TextStyle(fontSize: 13, color: Colors.grey[500])),
      decoration: inputDecoration('').copyWith(hintText: null),
      style: const TextStyle(fontSize: 14, color: Colors.black),
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

  Widget buildTopIconsUI() {
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
                    const SizedBox(height: 6),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back to home',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 24,
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
                      width: 90,
                      height: 90,
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


  InputDecoration inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  Widget buildTextField({
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
      style: const TextStyle(fontSize: 14, color: Colors.black),
      decoration: inputDecoration(hint),
    );
  }

  Widget buildRoommateDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRoommate,
      hint: Text('*Roommate',
          style: TextStyle(fontSize: 13, color: Colors.grey[500])),
      decoration: inputDecoration('').copyWith(hintText: null),
      style: const TextStyle(fontSize: 14, color: Colors.black),
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