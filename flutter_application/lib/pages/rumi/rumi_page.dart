import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/rumi_background_store.dart';

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

  String get _formattedEmotion {
    if (widget.currentEmotion.isEmpty) {
      return 'Unknown';
    }
    return widget.currentEmotion[0].toUpperCase() +
        widget.currentEmotion.substring(1);
  }

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
      'unlocked': true,
      'previewAsset': 'assets/witchHat.png',},
    {'key': 'sunglasses', 'name': 'Sunglasses', 'xp': 200, 'unlocked': false},
    {'key': 'scarf', 'name': 'Scarf', 'xp': 300, 'unlocked': false},
    {'key': 'crown', 'name': 'Crown', 'xp': 500, 'unlocked': false},
  ];

  final List<Map<String, Object>> _backgrounds = const [
    {
      'key': 'sunny',
      'name': 'Sunny Sky',
      'xp': 50,
      'unlocked': true,
      'preview': Color(0xFFEAF4FF),
      'color': Color(0xFFEAF4FF),
    },
    {
      'key': 'mint',
      'name': 'Mint Garden',
      'xp': 120,
      'unlocked': false,
      'preview': Color(0xFFDDF6E8),
      'color': Color(0xFFDDF6E8),
    },
    {
      'key': 'sunset',
      'name': 'Sunset Glow',
      'xp': 220,
      'unlocked': false,
      'preview': Color(0xFFFFE5D6),
      'gradient': <Color>[Color(0xFFFFE5D6), Color(0xFFFFC8B2)],
    },
    {
      'key': 'aurora',
      'name': 'Aurora Night',
      'xp': 360,
      'unlocked': false,
      'preview': Color(0xFFE7E1FF),
      'gradient': <Color>[Color(0xFFD4CCFF), Color(0xFFB2F1FF)],
    },
    {
      'key': 'galaxy',
      'name': 'Galaxy Party',
      'xp': 520,
      'unlocked': false,
      'preview': Color(0xFF2A2440),
      'gradient': <Color>[Color(0xFF2A2440), Color(0xFF5B3A8A)],
    },
  ];

  Map<String, Object>? _currentBackgroundConfig(String? key) {
    if (key == null) {
      return null;
    }

    for (final item in _backgrounds) {
      if (item['key'] == key) {
        return item;
      }
    }
    return null;
  }

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
                child: ValueListenableBuilder<String?>(
                  valueListenable: RumiBackgroundStore.selectedBackground,
                  builder: (context, selectedBackground, __) {
                    final backgroundConfig =
                        _currentBackgroundConfig(selectedBackground);
                    final backgroundColor =
                        backgroundConfig?['color'] as Color? ?? Colors.white;
                    final gradientColors =
                        backgroundConfig?['gradient'] as List<Color>?;

                    return Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: gradientColors == null ? backgroundColor : null,
                        gradient: gradientColors == null
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradientColors,
                              ),
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Emotion: $_formattedEmotion',
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
                      final backgroundKey = item['key'] as String;
                      final name = item['name'] as String;
                      final xp = item['xp'] as int;
                      final previewColor = item['preview'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 18),
                        child: Column(
                          children: [
                            ValueListenableBuilder<String?>(
                              valueListenable: RumiBackgroundStore.selectedBackground,
                              builder: (context, selectedBackground, _) {
                                final isSelected =
                                    unlocked && selectedBackground == backgroundKey;

                                return InkWell(
                                  onTap: unlocked
                                      ? () {
                                          RumiBackgroundStore.toggleBackground(
                                            backgroundKey,
                                          );
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
                                              horizontal: 10,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 64,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color: previewColor,
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 1.2,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  unlocked ? name : '<locked_$name>',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: unlocked
                                                        ? Colors.black
                                                        : Colors.grey,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
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
