import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ArticleSkeleton extends StatelessWidget {
  final bool isDark;

  const ArticleSkeleton({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Define base colors based on theme
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(), // Prevent scrolling while loading
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60), // Match ArticleDetailPage top spacing
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author/Date Section mimic
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: baseColor,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120, height: 14, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 6),
                        Container(width: 80, height: 12, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Title mimic (H1)
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 40),

                // Content paragraphs mimic
                _buildParagraph(baseColor),
                _buildParagraph(baseColor),
                _buildCodeBlock(baseColor),
                _buildParagraph(baseColor),
                _buildParagraph(baseColor),
              ],
            ),
          ),
        ],
      )
      .animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 1200.ms, color: isDark ? Colors.white10 : Colors.black12),
    );
  }

  Widget _buildParagraph(Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 10),
          Container(width: 300, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(Color color) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
