import 'package:flutter/material.dart';
import '../../shared/streak_store.dart';
import '../../shared/rumi_accessory_store.dart';
import '../../shared/rumi_background_store.dart';
import '../../shared/household_xp_store.dart';

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
      'xp': 100,
      'previewAsset': 'assets/flatHat.png',
    },
    {
      'key': 'witchHat',
      'name': 'witchHat.png',
      'xp': 200,
      'previewAsset': 'assets/witchHat.png',
    },
    {
      'key': 'partyHat',
      'name': 'partyHat.png',
      'xp': 400,
      'previewAsset': 'assets/partyHat.png',
    },
    {
      'key': 'pirateHat',
      'name': 'pirateHat.png',
      'xp': 800,
      'previewAsset': 'assets/pirateHat.png',
    },
    {
      'key': 'crown',
      'name': 'crown.png',
      'xp': 1600,
      'previewAsset': 'assets/crown.png',
    },
    {
      'key': 'jesterHat',
      'name': 'jesterHat.png',
      'xp': 3200,
      'previewAsset': 'assets/jesterHat.png',
    },
  ];

  final List<Map<String, Object>> _backgrounds = const [
    {
      'key': 'sprinkleMeadow',
      'name': 'Sky Blue',
      'xp': 50,
      'gradient': <Color>[Color.fromARGB(255, 161, 191, 200), Color.fromARGB(255, 140, 178, 198)],
    },
    {
      'key': 'cottonCandy',
      'name': 'Neon Ribbons',
      'xp': 150,
      'gradient': <Color>[Color(0xFFFFE0B8), Color(0xFFF6C7FF)],
      'pattern': 'ribbons',
    },
    {
      'key': 'pixelDisco',
      'name': 'Pixel Disco',
      'xp': 300,
      'gradient': <Color>[Color(0xFFC6F0FF), Color(0xFFE2D1FF)],
      'pattern': 'tiles',
    },
    {
      'key': 'cometNight',
      'name': 'Polka Pop',
      'xp': 600,
      'gradient': <Color>[Color.fromARGB(255, 152, 158, 187), Color.fromARGB(255, 175, 191, 204)],
      'pattern': 'polkaDots',
    },
    {
      'key': 'laserLounge',
      'name': 'Laser Lounge',
      'xp': 1200,
      'gradient': <Color>[Color(0xFF101A42), Color(0xFF144B63)],
      'pattern': 'zigzag',
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

  Widget _buildBackgroundPatternOverlay(
    Map<String, Object>? backgroundConfig, {
    double borderRadius = 16,
  }) {
    if (backgroundConfig == null) {
      return const SizedBox.shrink();
    }

    final pattern = backgroundConfig['pattern'] as String?;
    if (pattern == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: IgnorePointer(
          child: CustomPaint(
            painter: _BackgroundPatternPainter(pattern: pattern),
          ),
        ),
      ),
    );
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
                child: ValueListenableBuilder<int>(
                  valueListenable: HouseholdXpStore.householdXp,
                  builder: (context, householdXp, __) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: RumiBackgroundStore.selectedBackground,
                      builder: (context, selectedBackground, __) {
                        final selectedConfig =
                            _currentBackgroundConfig(selectedBackground);
                        final selectedConfigXp = selectedConfig?['xp'] as int?;
                        final backgroundConfig =
                            selectedConfigXp != null && householdXp >= selectedConfigXp
                            ? selectedConfig
                            : null;
                        final gradientColors =
                            backgroundConfig?['gradient'] as List<Color>?;

                        return Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: gradientColors == null ? Colors.white : null,
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
                          child: Stack(
                            children: [
                              _buildBackgroundPatternOverlay(backgroundConfig),
                              Center(
                                child: ValueListenableBuilder<String?>(
                                  valueListenable: RumiAccessoryStore.selectedAccessory,
                                  builder: (context, _, __) => Image.asset(
                                    RumiAccessoryStore.currentRumiImagePathForEmotion(
                                      widget.currentEmotion,
                                    ),
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<int>(
                valueListenable: HouseholdXpStore.householdXp,
                builder: (context, householdXp, _) => Center(
                  child: Text(
                    'Household XP: $householdXp',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              ValueListenableBuilder<int>(
                valueListenable: HouseholdXpStore.householdXp,
                builder: (context, householdXp, _) {
                  if (_showAccessories) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _accessories.map((item) {
                          final accessoryKey = item['key'] as String;
                          final name = item['name'] as String;
                          final xp = item['xp'] as int;
                          final unlocked = householdXp >= xp;
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
                                                accessoryKey,
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
                                                child: previewAsset != null
                                                    ? Image.asset(
                                                        previewAsset,
                                                        width: 85,
                                                        height: 85,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Text(
                                                        unlocked
                                                            ? name
                                                            : '<locked_$name>',
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
                                            if (!unlocked)
                                              _buildLockedStripesOverlay(),
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
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _backgrounds.map((item) {
                        final backgroundKey = item['key'] as String;
                        final name = item['name'] as String;
                        final xp = item['xp'] as int;
                        final unlocked = householdXp >= xp;
                        final gradientColors = item['gradient'] as List<Color>?;

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
                                                      color: gradientColors == null
                                                          ? Colors.white
                                                          : null,
                                                      gradient:
                                                          gradientColors == null
                                                          ? null
                                                          : LinearGradient(
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                              colors: gradientColors,
                                                            ),
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        _buildBackgroundPatternOverlay(
                                                          item,
                                                          borderRadius: 12,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    unlocked
                                                        ? name
                                                        : '<locked_$name>',
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
                                          if (!unlocked)
                                            _buildLockedStripesOverlay(),
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
                  );
                },
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
      ..color = Colors.grey.withValues(alpha: 0.40)
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

class _BackgroundPatternPainter extends CustomPainter {
  _BackgroundPatternPainter({required this.pattern});

  final String pattern;

  @override
  void paint(Canvas canvas, Size size) {
    switch (pattern) {
      case 'flowers':
        _paintFlowers(canvas, size);
        break;
      case 'ribbons':
        _paintRibbons(canvas, size);
        break;
      case 'tiles':
        _paintTiles(canvas, size);
        break;
      case 'polkaDots':
        _paintPolkaDots(canvas, size);
        break;
      case 'zigzag':
        _paintZigZag(canvas, size);
        break;
      default:
        _paintFlowers(canvas, size);
        break;
    }
  }

  void _paintFlowers(Canvas canvas, Size size) {
    final petalPaint = Paint()..style = PaintingStyle.fill;
    final centerPaint = Paint()..style = PaintingStyle.fill;

    for (double y = 14; y < size.height; y += 24) {
      for (double x = 14; x < size.width; x += 26) {
        petalPaint.color = Colors.white;
        canvas.drawCircle(Offset(x - 4, y), 3, petalPaint);
        canvas.drawCircle(Offset(x + 4, y), 3, petalPaint);
        canvas.drawCircle(Offset(x, y - 4), 3, petalPaint);
        canvas.drawCircle(Offset(x, y + 4), 3, petalPaint);
        centerPaint.color = Colors.amber.withValues(alpha: 0.35);
        canvas.drawCircle(Offset(x, y), 2, centerPaint);
      }
    }
  }

  void _paintRibbons(Canvas canvas, Size size) {
    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    for (double y = 8; y < size.height + 20; y += 20) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width + 16; x += 16) {
        path.quadraticBezierTo(
          x + 8,
          y + ((x ~/ 16).isEven ? 8 : -8),
          x + 16,
          y,
        );
      }
      ribbonPaint.color = y % 40 == 8
          ? Colors.white.withValues(alpha: 0.45)
          : Colors.pink.shade100.withValues(alpha: 0.45);
      canvas.drawPath(path, ribbonPaint);
    }
  }

  void _paintTiles(Canvas canvas, Size size) {
    final tilePaint = Paint()..style = PaintingStyle.fill;
    const spacing = 16.0;
    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        final alt = ((x / spacing).round() + (y / spacing).round()).isEven;
        tilePaint.color = alt
            ? Colors.white.withValues(alpha: 0.26)
            : Colors.black.withValues(alpha: 0.08);
        canvas.drawRect(Rect.fromLTWH(x, y, spacing, spacing), tilePaint);
      }
    }
  }

  void _paintPolkaDots(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 22.0;
    for (double y = 10; y < size.height + spacing; y += spacing) {
      for (double x = 10; x < size.width + spacing; x += spacing) {
        final variant = (((x / spacing).round() * 3) + (y / spacing).round()) % 3;
        dotPaint.color = switch (variant) {
          0 => Colors.white.withValues(alpha: 0.45),
          1 => Colors.pink.shade100.withValues(alpha: 0.40),
          _ => Colors.pink.shade200.withValues(alpha: 0.38),
        };
        ringPaint.color = Colors.white.withValues(alpha: 0.25);
        canvas.drawCircle(Offset(x, y), 5.5, dotPaint);
        canvas.drawCircle(Offset(x, y), 5.5, ringPaint);
      }
    }
  }

  void _paintZigZag(Canvas canvas, Size size) {
    final zigPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.35)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    for (double y = 8; y < size.height; y += 18) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 16) {
        path.lineTo(x + 8, y + 6);
        path.lineTo(x + 16, y);
      }
      canvas.drawPath(path, zigPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern;
  }
}
