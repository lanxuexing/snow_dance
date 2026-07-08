import 'dart:math';
import 'package:flutter/material.dart';

class SnowflakeLogo extends StatefulWidget {
  final double size;
  final List<Color>? gradientColors;

  const SnowflakeLogo({
    super.key,
    this.size = 24.0,
    this.gradientColors,
  });

  @override
  State<SnowflakeLogo> createState() => _SnowflakeLogoState();
}

class _SnowflakeLogoState extends State<SnowflakeLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Ultra-slow rotation (45 seconds per full turn) to create a drifting feel
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default premium gradient colors if none provided
    final colors = widget.gradientColors ??
        const [
          Color(0xFF00DC82), // Green/Emerald
          Color(0xFF36E4DA), // Cyan
          Color(0xFF007A5E), // Teal
        ];

    return RotationTransition(
      turns: _rotationController,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: SnowflakePainter(colors: colors),
        ),
      ),
    );
  }
}

class SnowflakePainter extends CustomPainter {
  final List<Color> colors;

  SnowflakePainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Thicker stroke for excellent visibility on small screens
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.8, size.width / 9) 
      ..strokeCap = StrokeCap.round;

    // Shader for modern gradient look
    final gradientShader = LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    paint.shader = gradientShader;

    // Create central hexagon path
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * pi / 180;
      final point = Offset(
        center.dx + radius * 0.25 * cos(angle),
        center.dy + radius * 0.25 * sin(angle),
      );
      if (i == 0) {
        hexPath.moveTo(point.dx, point.dy);
      } else {
        hexPath.lineTo(point.dx, point.dy);
      }
    }
    hexPath.close();

    // 1. Draw central translucent hexagon (Glassmorphic fill)
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: colors.map((c) => c.withValues(alpha: 0.15)).toList(),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(hexPath, fillPaint);

    // 2. Draw central hexagon outline
    canvas.drawPath(hexPath, paint);

    // Draw inner tiny circle for geometric detail
    final centerDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradientShader;
    canvas.drawCircle(center, radius * 0.08, centerDotPaint);

    // Draw 6 main branches with sub-arms
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * pi / 180;
      
      // Main arm ending slightly before border
      final tip = Offset(
        center.dx + radius * 0.90 * cos(angle),
        center.dy + radius * 0.90 * sin(angle),
      );
      canvas.drawLine(center, tip, paint);

      // Branch tips - small elegant circular dots
      canvas.drawCircle(tip, max(1.2, size.width / 14), centerDotPaint);

      // Inner sub-arms (diagonal needles)
      final innerStart = Offset(
        center.dx + radius * 0.42 * cos(angle),
        center.dy + radius * 0.42 * sin(angle),
      );
      final innerV1 = Offset(
        innerStart.dx + radius * 0.22 * cos(angle + 40 * pi / 180),
        innerStart.dy + radius * 0.22 * sin(angle + 40 * pi / 180),
      );
      final innerV2 = Offset(
        innerStart.dx + radius * 0.22 * cos(angle - 40 * pi / 180),
        innerStart.dy + radius * 0.22 * sin(angle - 40 * pi / 180),
      );
      canvas.drawLine(innerStart, innerV1, paint);
      canvas.drawLine(innerStart, innerV2, paint);

      // Outer sub-arms (diagonal needles)
      final outerStart = Offset(
        center.dx + radius * 0.66 * cos(angle),
        center.dy + radius * 0.66 * sin(angle),
      );
      final outerV1 = Offset(
        outerStart.dx + radius * 0.16 * cos(angle + 40 * pi / 180),
        outerStart.dy + radius * 0.16 * sin(angle + 40 * pi / 180),
      );
      final outerV2 = Offset(
        outerStart.dx + radius * 0.16 * cos(angle - 40 * pi / 180),
        outerStart.dy + radius * 0.16 * sin(angle - 40 * pi / 180),
      );
      canvas.drawLine(outerStart, outerV1, paint);
      canvas.drawLine(outerStart, outerV2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
