// In-Class Activity 06 — Drawing with Flutter
// Student: Muhammad Mustufa
// Date: September 30, 2026

import 'dart:math' show Random, pi;

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

enum FaceType {
  classic,
  sleepy,
  surprised,
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  double mood = 0.8;

  FaceType faceType = FaceType.classic;

  Color faceColor = Colors.orange.shade400;

  final Random random = Random();

  Color _colorForMood(double value) {
    if (value < 0.35) {
      return Colors.lightBlue.shade300;
    } else if (value <= 0.70) {
      return Colors.yellow.shade600;
    } else {
      return Colors.orange.shade400;
    }
  }

  void _changeMood(double value) {
    setState(() {
      mood = value;
      faceColor = _colorForMood(value);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _cycleFace() {
    setState(() {
      final nextIndex = (faceType.index + 1) % FaceType.values.length;
      faceType = FaceType.values[nextIndex];
    });

    _showMessage('Face changed to ${faceType.name}');
  }

  void _randomizeFace() {
    final randomColors = <Color>[
      Colors.pink.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
      Colors.orange.shade300,
      Colors.amber.shade400,
      Colors.lightBlue.shade300,
    ];

    setState(() {
      mood = random.nextDouble();
      faceColor = randomColors[random.nextInt(randomColors.length)];
    });

    _showMessage(
      'Randomized mood to ${mood.toStringAsFixed(2)} and changed color',
    );
  }

  Widget _drawingArea() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: GestureDetector(
          onTap: _cycleFace,
          onLongPress: _randomizeFace,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: SmileyPainter(
                mood: mood,
                faceType: faceType,
                faceColor: faceColor,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mood: ${mood.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            min: 0,
            max: 1,
            divisions: 100,
            value: mood,
            label: mood.toStringAsFixed(2),
            onChanged: _changeMood,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<FaceType>(
            value: faceType,
            decoration: const InputDecoration(
              labelText: 'Face style',
              border: OutlineInputBorder(),
            ),
            items: FaceType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type.name[0].toUpperCase() + type.name.substring(1),
                ),
              );
            }).toList(),
            onChanged: (FaceType? value) {
              if (value == null) return;

              setState(() {
                faceType = value;
              });
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Tap the face to cycle styles • Long-press to randomize',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Smiley Lab'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscape = constraints.maxWidth > constraints.maxHeight;

            if (landscape) {
              return Row(
                children: [
                  Expanded(child: _drawingArea()),
                  SizedBox(
                    width: 340,
                    child: SingleChildScrollView(
                      child: _controls(),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(child: _drawingArea()),
                _controls(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceType,
    required this.faceColor,
  });

  final double mood;
  final FaceType faceType;
  final Color faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.40;

    // ------------------------------------------------------------
    // 1. FACE
    // ------------------------------------------------------------

    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius,
      facePaint,
    );

    // ------------------------------------------------------------
    // 2. FACE BORDER
    // ------------------------------------------------------------

    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035;

    canvas.drawCircle(
      center,
      radius,
      borderPaint,
    );

    // ------------------------------------------------------------
    // 3. EYES
    // ------------------------------------------------------------

    final eyeY = center.dy - radius * 0.20;
    final eyeGap = radius * 0.35;

    final leftEye = Offset(
      center.dx - eyeGap,
      eyeY,
    );

    final rightEye = Offset(
      center.dx + eyeGap,
      eyeY,
    );

    if (faceType == FaceType.sleepy) {
      final sleepyPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.045
        ..strokeCap = StrokeCap.round;

      final eyeRadius = radius * 0.13;

      final leftEyeRect = Rect.fromCircle(
        center: leftEye,
        radius: eyeRadius,
      );

      final rightEyeRect = Rect.fromCircle(
        center: rightEye,
        radius: eyeRadius,
      );

      canvas.drawArc(
        leftEyeRect,
        0.15 * pi,
        0.70 * pi,
        false,
        sleepyPaint,
      );

      canvas.drawArc(
        rightEyeRect,
        0.15 * pi,
        0.70 * pi,
        false,
        sleepyPaint,
      );
    } else {
      final eyePaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      final eyeRadius = faceType == FaceType.surprised
          ? radius * 0.12
          : radius * 0.075;

      canvas.drawCircle(
        leftEye,
        eyeRadius,
        eyePaint,
      );

      canvas.drawCircle(
        rightEye,
        eyeRadius,
        eyePaint,
      );

      if (faceType == FaceType.surprised) {
        final pupilPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          leftEye - Offset(
            radius * 0.025,
            radius * 0.025,
          ),
          radius * 0.035,
          pupilPaint,
        );

        canvas.drawCircle(
          rightEye - Offset(
            radius * 0.025,
            radius * 0.025,
          ),
          radius * 0.035,
          pupilPaint,
        );
      }
    }

    // ------------------------------------------------------------
    // 4. MOUTH
    // ------------------------------------------------------------

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.05
      ..strokeCap = StrokeCap.round;

    if (faceType == FaceType.surprised) {
      final mouthCenter = Offset(
        center.dx,
        center.dy + radius * 0.32,
      );

      final mouthRect = Rect.fromCenter(
        center: mouthCenter,
        width: radius * 0.36,
        height: radius * (0.35 + (1 - mood) * 0.22),
      );

      final surprisedMouth = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        mouthRect,
        surprisedMouth,
      );

      return;
    }

    if (faceType == FaceType.sleepy) {
      final mouthRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.27,
        ),
        width: radius * 0.70,
        height: radius * 0.28,
      );

      canvas.drawArc(
        mouthRect,
        0.18 * pi,
        0.64 * pi,
        false,
        mouthPaint,
      );

      return;
    }

    // Classic face:
    // Mood controls both mouth direction and curvature.

    if (mood < 0.35) {
      final frownRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.40,
        ),
        width: radius * 1.05,
        height: radius * (0.45 + (0.35 - mood)),
      );

      canvas.drawArc(
        frownRect,
        1.15 * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
    } else if (mood <= 0.70) {
      final softSmileRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.18,
        ),
        width: radius * 0.90,
        height: radius * 0.30,
      );

      canvas.drawArc(
        softSmileRect,
        0.15 * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
    } else {
      final bigSmileRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.12,
        ),
        width: radius * 1.15,
        height: radius * (0.55 + mood * 0.20),
      );

      canvas.drawArc(
        bigSmileRect,
        0.15 * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
    }
  }

  @override
bool shouldRepaint(covariant SmileyPainter oldDelegate) {
  return true;
}
}