import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';

class AddChoreScreen extends StatefulWidget {
  final VoidCallback? onRumiTap;

  const AddChoreScreen({Key? key, this.onRumiTap}) : super(key: key);

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController       = TextEditingController();
  final dueDateController     = TextEditingController();
  final xpController          = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedRoommate;
  bool isRecurring = false;
  bool isRotation  = false;

  final List<String> roommates = [
    'Alex', 'Sam', 'Jordan', 'Silvia', 'Caitlin'
  ];

  @override
  void dispose() {
    titleController.dispose();
    dueDateController.dispose();
    xpController.dispose();
    descriptionController.dispose();
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

  void _submit() {
    if (formKey.currentState!.validate()) {
      final newChore = {
        'name':        titleController.text,
        'assigned':    selectedRoommate ?? '',
        'xp':          int.tryParse(xpController.text) ?? 0,
        'completed':   false,
        'dueDate':     DateTime.tryParse(dueDateController.text) ?? DateTime.now(),
        'description': descriptionController.text,
        'recurring':   isRecurring,
        'rotation':    isRotation,
      };
      Navigator.pop(context, newChore);
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
                buildTopIconsUI(),

                const Padding(
                  padding: EdgeInsets.only(left: 25, right: 18, bottom: 12),
                  child: Text(
                    'Add Chore',
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
                        buildTextField(
                          controller: xpController,
                          hint: '*XP Weight',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        buildRoommateDropdown(),
                        const SizedBox(height: 10),
                        buildDescriptionField(),
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
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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

  Widget buildDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      maxLines: 4,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      decoration: inputDecoration('Description').copyWith(
        contentPadding: const EdgeInsets.all(14),
      ),
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