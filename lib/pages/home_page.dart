import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/models/article.dart';
import 'package:snow_dance/widgets/article_card.dart';
import 'package:snow_dance/widgets/app_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 120),
          _buildHero(context),
          _buildArticleGrid(context, provider.articles),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5), // Border width
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF42D392), Color(0xFF647EFF)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF42D392), Color(0xFF647EFF)],
                    ).createShader(bounds),
                    child: const Icon(Icons.rocket_launch_rounded, size: 16, color: Colors.white),
                   ),
                   const SizedBox(width: 8),
                   Text(
                    'Introducing SnowDance v1.0',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF42D392), Color(0xFF647EFF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'Build Beautiful Blogs\nwith Flutter Web',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 56, // Increased size for impact
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1.5,
                color: Colors.white, // Required for ShaderMask
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'A premium, high-performance blog engine with frosted glass aesthetics\nand modern technical writing features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildArticleGrid(BuildContext context, List<Article> allArticles) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;
    
    // Limit to 6 articles for homepage
    final displayArticles = allArticles.take(6).toList();

    Widget content;
    if (isMobile) {
      content = ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayArticles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => ArticleCard(article: displayArticles[index]),
      );
    } else {
      content = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600,
          childAspectRatio: 2.5,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        itemCount: displayArticles.length,
        itemBuilder: (context, index) => ArticleCard(article: displayArticles[index]),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          content,
          if (allArticles.length > 6) ...[
            const SizedBox(height: 48),
            Center(
              child: OutlinedButton(
                onPressed: () => context.go('/blog'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all articles',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
