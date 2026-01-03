import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumLoader extends StatelessWidget {
  final bool isDark;
  
  const PremiumLoader({super.key, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme context if available, otherwise fallback
    final primaryColor = const Color(0xFF00DC82);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing Logo Container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1, 1),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          )
          .boxShadow(
             begin: BoxShadow(
               color: primaryColor.withOpacity(0.7),
               blurRadius: 20,
               spreadRadius: 2,
             ),
             end: BoxShadow(
               color: primaryColor.withOpacity(0),
               blurRadius: 30,
               spreadRadius: 20,
             ),
             duration: 1000.ms, 
             curve: Curves.easeInOut,
          ),
          
          const SizedBox(height: 32),
          
          // Loading Text
          Text(
            'SNOWDANCE',
            style: TextStyle(
              fontFamily: 'Inter',
              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
              fontSize: 14,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w500,
            ),
          )
          .animate()
          .fadeIn(duration: 800.ms, curve: Curves.easeOut)
          .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
