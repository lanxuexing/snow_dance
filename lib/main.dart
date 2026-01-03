import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/core/theme/app_theme.dart';
import 'package:snow_dance/models/article.dart';
import 'package:snow_dance/widgets/app_header.dart';
import 'package:snow_dance/widgets/frosted_background.dart';
import 'package:snow_dance/widgets/markdown_viewer.dart';
import 'package:snow_dance/widgets/search_overlay.dart';
import 'package:snow_dance/widgets/toc_widget.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:snow_dance/core/config/app_config.dart';
import 'package:snow_dance/widgets/app_drawer.dart';
import 'package:snow_dance/widgets/responsive_layout.dart';
import 'package:snow_dance/core/theme/theme_provider.dart';
import 'package:snow_dance/widgets/premium_loader.dart';
import 'package:snow_dance/widgets/article_card.dart';
import 'package:snow_dance/widgets/sidebar_item.dart';
import 'package:snow_dance/widgets/category_redirect_page.dart';
import 'package:snow_dance/widgets/main_layout.dart';
import 'package:snow_dance/widgets/article_skeleton.dart';

void main() {
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(child: HomePage()),
    ),
    GoRoute(path: '/blog', builder: (context, state) => const CategoryRedirectPage(category: 'Blog')),
    GoRoute(path: '/guide', builder: (context, state) => const CategoryRedirectPage(category: 'Guide')),
    GoRoute(path: '/docs', builder: (context, state) => const CategoryRedirectPage(category: 'Docs')),
    GoRoute(path: '/ecosystem', builder: (context, state) => const CategoryRedirectPage(category: 'Ecosystem')),
    _buildArticleRoute('/blog/:id'),
    _buildArticleRoute('/guide/:id'),
    _buildArticleRoute('/docs/:id'),
    _buildArticleRoute('/ecosystem/:id'),
  ],
);

GoRoute _buildArticleRoute(String path) {
  return GoRoute(
    path: path,
    builder: (context, state) {
      final id = state.pathParameters['id'];
      final provider = Provider.of<ArticleProvider>(context);
      
      if (provider.isLoading) {
        return MainLayout(
          child: PremiumLoader(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        );
      }
      
      if (provider.articles.isEmpty) {
        return const MainLayout(child: Center(child: Text('No articles found.')));
      }

      final article = provider.articles.cast<Article?>().firstWhere(
        (a) => a?.id == id,
        orElse: () => null,
      );

      if (article == null) {
        return const MainLayout(child: Center(child: Text('Article not found. Please restart the app if you just added it.')));
      }
      return MainLayout(child: ArticleDetailPage(article: article!));
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'SnowDance Blog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}


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
          _buildFooter(context),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Text(
              'Introducing SnowDance v1.0',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Build Beautiful Blogs\nwith Flutter Web',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  height: 1.1,
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

class ArticleDetailPage extends StatefulWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final List<ToCEntry> _tocEntries = [];
  final Map<String, GlobalKey> _headingKeys = {};
  final ScrollController _scrollController = ScrollController();
  String? _activeHeading;
  bool _isRendering = true;

  @override
  void initState() {
    super.initState();
    _deferRendering();
    _parseToC();
    _scrollController.addListener(_onScroll);
  }

  void _deferRendering() {
    setState(() => _isRendering = true);
    // Add a small delay to allow the page transition to complete
    // and show the skeleton before the heavy Markdown rendering blocks the UI thread.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isRendering = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    String? newActiveHeading;

    for (var entry in _tocEntries) {
      final key = entry.key;
      final context = key.currentContext;
      if (context == null) continue;
      
      final RenderBox box = context.findRenderObject() as RenderBox;
      // Get position relative to viewport
      final position = box.localToGlobal(Offset.zero);
      
      // We want the heading that is closest to the top (e.g. 100px offset)
      // but still "active" (meaning we are reading its content).
      // Standard logic: The last heading that is above a certain threshold (meaning we scrolled past it).
      final threshold = 200.0; // Top padding + Header + buffer
      
      if (position.dy <= threshold) {
        // This heading is above the threshold, so it might be the active one.
        // Since we iterate in order, the last one meeting this criteria is the current section.
        newActiveHeading = entry.title;
      }
    }
    
    // If we are at the very top and no heading is above threshold yet, first one is active.
    if (newActiveHeading == null && _tocEntries.isNotEmpty) {
      newActiveHeading = _tocEntries.first.title;
    }

    if (newActiveHeading != _activeHeading) {
      setState(() {
        _activeHeading = newActiveHeading;
      });
    }
  }

  @override
  void didUpdateWidget(ArticleDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.id != widget.article.id) {
      _deferRendering();
      _tocEntries.clear();
      _headingKeys.clear();
      _parseToC();
      if (_tocEntries.isNotEmpty) {
        _activeHeading = _tocEntries.first.title;
      }
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  // ... _parseToC and _scrollToHeading (unchanged) ...
  
  // Need to verify where to insert the changes. I will match up to _scrollToHeading and replace build.

  void _parseToC() {
    final lines = widget.article.content.split('\n');
    for (var line in lines) {
      if (line.startsWith('## ') || line.startsWith('### ') || line.startsWith('#### ')) {
        int level = 1; // Default to H2 style
        if (line.startsWith('### ')) level = 2;
        else if (line.startsWith('#### ')) level = 3;
        
        final title = line.replaceFirst(RegExp(r'#+ '), '').trim();
        final key = GlobalKey();
        _tocEntries.add(ToCEntry(title: title, level: level, key: key));
        _headingKeys[title] = key;
      }
    }
    // Set initial active heading
    if (_activeHeading == null && _tocEntries.isNotEmpty) {
      _activeHeading = _tocEntries.first.title;
    }
  }

  void _scrollToHeading(ToCEntry entry) {
    final context = entry.key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // Align slightly below top
      );
      // Manually set active to prevent flicker during scroll
      setState(() => _activeHeading = entry.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) _buildSidebar(context),
        Expanded(
          child: _isRendering
              ? ArticleSkeleton(isDark: isDark)
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAuthorSection(context),
                            if (isMobile && _tocEntries.isNotEmpty) ...[
                              const SizedBox(height: 32),
                              _buildMobileToC(context),
                            ],
                            const SizedBox(height: 40),
                            MarkdownViewer(
                              content: widget.article.content,
                              headingKeys: _headingKeys,
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                      _buildFooter(context),
                    ],
                  ),
                ),
        ),
        if (!isMobile) _buildToCSidebar(context),
      ],
    );
  }

  Widget _buildMobileToC(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          collapsedIconColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            '本页总览',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          children: _tocEntries.map((entry) {
            final isSelect = entry.title == _activeHeading;
            return InkWell(
              onTap: () {
                _scrollToHeading(entry);
              },
              child: Container(
                 width: double.infinity,
                 padding: EdgeInsets.only(
                   left: 16.0 + (entry.level - 1) * 12,
                   right: 16,
                   top: 10,
                   bottom: 10
                 ),
                 child: Text(
                   entry.title,
                   style: TextStyle(
                     fontSize: 14,
                     height: 1.4,
                     color: isSelect 
                         ? Theme.of(context).colorScheme.primary 
                         : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                     fontWeight: isSelect ? FontWeight.w600 : FontWeight.normal,
                   ),
                 ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: NetworkImage(AppConfig.authorAvatar),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppConfig.authorName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  widget.article.title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    
    // Filter articles by category
    final categoryArticles = provider.articles
        .where((a) => a.category == widget.article.category)
        .toList();
    
    // Group articles by year
    final Map<String, List<Article>> groupedArticles = {};
    for (var article in categoryArticles) {
      final year = article.date.split('-').first;
      groupedArticles.putIfAbsent(year, () => []).add(article);
    }
    final sortedYears = groupedArticles.keys.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(
            right: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sortedYears.map((year) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...groupedArticles[year]!.map((a) => SidebarItem(
                  article: a,
                  isSelected: a.id == widget.article.id,
                  onTap: () => context.go('/${a.categoryPath}/${a.id}'),
                )),
                const SizedBox(height: 24),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildToCSidebar(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border(
            left: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 8, right: 12, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableOfContents(
              entries: _tocEntries,
              onTap: _scrollToHeading,
              activeId: _activeHeading,
            ),
            if (_tocEntries.isNotEmpty) ...[
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward_rounded, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(
                        'Back to the top',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildFooter(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
    margin: const EdgeInsets.only(top: 100),
    decoration: BoxDecoration(
      border: Border(
          top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1))),
    ),
    child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const Text('© 2026 SnowDance Engine. Built with Flutter Web.'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFooterItem('Twitter'),
                _buildFooterItem('GitHub'),
                _buildFooterItem('Discord'),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Widget _buildFooterItem(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Text(title,
        style: const TextStyle(fontSize: 14, color: Colors.grey)),
  );
}
