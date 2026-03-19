import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';

class RumiPage extends StatefulWidget {
  const RumiPage({
    super.key,
    required this.rumiAgeDays,
    required this.currentEmotion,
  });

  final int rumiAgeDays;
  final String currentEmotion;

  @override
  State<RumiPage> createState() => _RumiPageState();
}

class _RumiPageState extends State<RumiPage> {
  bool _showAccessories = true;

  final List<Map<String, Object>> _accessories = const [
    {
      'key': 'flatHat',
      'name': 'flatHat.png',
      'xp': 50,
      'unlocked': true,
      'previewAsset': 'assets/flatHat.png',
    },
    {
      'key': 'witchHat',
      'name': 'witchHat.png',
      'xp': 100,
      'unlocked': false,
      'previewAsset': 'assets/witchHat.png',},
    {'key': 'sunglasses', 'name': 'Sunglasses', 'xp': 200, 'unlocked': false},
    {'key': 'scarf', 'name': 'Scarf', 'xp': 300, 'unlocked': false},
    {'key': 'crown', 'name': 'Crown', 'xp': 500, 'unlocked': false},
  ];

  final List<Map<String, Object>> _backgrounds = const [
    {'name': 'Pink', 'xp': 50, 'unlocked': true},
    {'name': 'Blue', 'xp': 100, 'unlocked': false},
    {'name': 'Green', 'xp': 200, 'unlocked': false},
    {'name': 'Yellow', 'xp': 300, 'unlocked': false},
    {'name': 'Purple', 'xp': 500, 'unlocked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
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
                  ],
                ),
              ),
              const Center(
                child: Text(
                  'Rumi',
                  style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  'Age: ${widget.rumiAgeDays} days',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: RumiAccessoryStore.selectedAccessory,
                      builder: (context, _, __) => Image.asset(
                        RumiAccessoryStore.currentRumiImagePath,
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Rumi is currently ${widget.currentEmotion}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _showAccessories ? Colors.black : Colors.white,
                      foregroundColor: _showAccessories ? Colors.white : Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(160, 52),
                    ),
                    onPressed: () {
                      setState(() {
                        _showAccessories = true;
                      });
                    },
                    child: const Text('Accessories', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _showAccessories ? Colors.white : Colors.black,
                      foregroundColor: _showAccessories ? Colors.black : Colors.white,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(160, 52),
                    ),
                    onPressed: () {
                      setState(() {
                        _showAccessories = false;
                      });
                    },
                    child: const Text('Backgrounds', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_showAccessories)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _accessories.map((item) {
                      final unlocked = item['unlocked'] as bool;
                      final accessoryKey = item['key'] as String;
                      final name = item['name'] as String;
                      final xp = item['xp'] as int;
                      final previewAsset = item['previewAsset'] as String?;

                      return Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 18),
                        child: Column(
                          children: [
                            ValueListenableBuilder<String?>(
                              valueListenable: RumiAccessoryStore.selectedAccessory,
                              builder: (context, selectedAccessory, _) {
                                final isSelected =
                                    unlocked && selectedAccessory == accessoryKey;

                                return InkWell(
                                  onTap: unlocked
                                      ? () {
                                          RumiAccessoryStore.toggleAccessory(
                                              accessoryKey);
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    width: 140,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: unlocked
                                          ? (isSelected
                                              ? Colors.orange.shade100
                                              : Colors.white)
                                          : Colors.grey.shade300,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.black,
                                        width: isSelected ? 4 : 3,
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: previewAsset != null
                                                ? Image.asset(
                                                    previewAsset,
                                                    width: 85,
                                                    height: 85,
                                                    fit: BoxFit.contain,
                                                  )
                                                : Text(
                                                    unlocked ? name : '<locked_$name>',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: unlocked
                                                          ? Colors.black
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        if (!unlocked) _buildLockedStripesOverlay(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$xp XP',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _backgrounds.map((item) {
                      final unlocked = item['unlocked'] as bool;
                      final name = item['name'] as String;
                      final xp = item['xp'] as int;

                      return Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 18),
                        child: Column(
                          children: [
                            Container(
                              width: 140,
                              height: 120,
                              decoration: BoxDecoration(
                                color: unlocked ? Colors.white : Colors.grey.shade300,
                                border: Border.all(color: Colors.black, width: 3),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        unlocked ? name : '<locked_$name>',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: unlocked ? Colors.black : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!unlocked) _buildLockedStripesOverlay(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$xp XP',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedStripesOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: IgnorePointer(
          child: CustomPaint(
            painter: _LockedStripesPainter(),
          ),
        ),
      ),
    );
  }
}

class _LockedStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = Colors.grey.withOpacity(0.40)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    const double stripeSpacing = 14;
    final double diagonalLength = size.width + size.height;

    for (double offset = -size.height; offset < size.width; offset += stripeSpacing) {
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset + diagonalLength, diagonalLength),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
