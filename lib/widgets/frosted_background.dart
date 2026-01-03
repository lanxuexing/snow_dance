import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedBackground extends StatelessWidget {
  final Widget child;

  const FrostedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background Gradients
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF020420) : const Color(0xFFF9FAFB),
          ),
        ),
        // Decorative Blurs (Mesh segments)
        if (isDark) ...[
          _buildBlob(
            top: -100,
            left: -100,
            color: const Color(0xFF00DC82).withOpacity(0.15),
            size: 400,
          ),
          _buildBlob(
            bottom: -50,
            right: -50,
            color: const Color(0xFF36E4DA).withOpacity(0.1),
            size: 500,
          ),
          _buildBlob(
            top: 200,
            right: 100,
            color: const Color(0xFF16171D).withOpacity(0.5),
            size: 300,
          ),
        ] else ...[
          _buildBlob(
            top: -100,
            left: -100,
            color: const Color(0xFF00DC82).withOpacity(0.05),
            size: 400,
          ),
          _buildBlob(
            bottom: -50,
            right: -50,
            color: const Color(0xFF36E4DA).withOpacity(0.05),
            size: 500,
          ),
        ],
        // The child content
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _buildBlob({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 120,
              spreadRadius: 80,
            ),
          ],
        ),
      ),
    );
  }
}
