import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/widgets/article_card.dart';
import 'package:snow_dance/widgets/app_footer.dart';
import 'package:snow_dance/core/utils/seo_helper.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);

    SEOHelper.updateSEO(
      title: 'SnowDance - Premium Tech Blog Engine built with Flutter',
      description: 'SnowDance is a premium, high-performance tech blog engine built with Flutter Web, featuring frosted glass aesthetics and modern technical writing features.',
      keywords: ['Flutter', 'Flutter Web', 'Blog Engine', 'Tech Blog', 'SnowDance', 'Premium UI'],
      author: 'lanxuexing',
    );


    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    final double horizontalPadding = screenWidth > 1200
        ? (screenWidth - 1200) / 2 + 24
        : (isMobile ? 16.0 : 24.0);
    final displayArticles = provider.articles.take(6).toList();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
        SliverToBoxAdapter(child: _buildHero(context)),
        SliverToBoxAdapter(child: const SizedBox(height: 40)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: isMobile
              ? SliverList.separated(
                  itemCount: displayArticles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => ArticleCard(article: displayArticles[index])
                      .animate(delay: (40 * index).ms)
                      .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                      .moveY(begin: 12, end: 0, curve: Curves.easeOutCubic),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ArticleCard(article: displayArticles[index])
                        .animate(delay: (40 * index).ms)
                        .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                        .moveY(begin: 12, end: 0, curve: Curves.easeOutCubic),
                    childCount: displayArticles.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 600,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                ),
        ),
        if (provider.articles.length > 6)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 48, bottom: 40),
              child: Center(
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
            ),
          ),
        const SliverToBoxAdapter(child: AppFooter()),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
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
                fontSize: 56,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1.5,
                color: Colors.white,
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
        ],
      ),
    );
  }
}

