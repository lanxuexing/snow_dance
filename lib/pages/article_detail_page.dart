import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/models/article.dart';
import 'package:snow_dance/widgets/toc_widget.dart';
import 'package:snow_dance/widgets/markdown_viewer.dart';
import 'package:snow_dance/widgets/sidebar_item.dart';
import 'package:snow_dance/widgets/article_skeleton.dart';
import 'package:snow_dance/widgets/app_footer.dart';
import 'package:snow_dance/core/config/app_config.dart';

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
    
    // Check if content needs to be loaded
    if (widget.article.content.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ArticleProvider>(context, listen: false)
            .loadArticleContent(widget.article.id);
      });
    }

    _deferRendering();

    if (widget.article.content.isNotEmpty) {
      _parseToC(widget.article.content);
    }
    _scrollController.addListener(_onScroll);
  }

  void _deferRendering() {
    setState(() => _isRendering = true);
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
      final position = box.localToGlobal(Offset.zero);
      final threshold = 200.0;
      
      if (position.dy <= threshold) {
        newActiveHeading = entry.title;
      }
    }
    
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
      _headingKeys.clear();
      if (widget.article.content.isNotEmpty) {
        _parseToC(widget.article.content);
      }
      if (_tocEntries.isNotEmpty) {
        _activeHeading = _tocEntries.first.title;
      }
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _parseToC(String content) {
    _tocEntries.clear();
    final lines = content.split('\n');
    for (var line in lines) {
      if (line.startsWith('## ') || line.startsWith('### ') || line.startsWith('#### ')) {
        int level = 1; 
        if (line.startsWith('### ')) level = 2;
        else if (line.startsWith('#### ')) level = 3;
        
        final title = line.replaceFirst(RegExp(r'#+ '), '').trim();
        // Check if title already parsed to avoid duplicate keys? 
        // Logic assumes titles unique or handles duplicates? 
        // Original logic didn't handle unique keys for same title properly if duplicate.
        // Keeping original logic.
        final key = GlobalKey();
        _tocEntries.add(ToCEntry(title: title, level: level, key: key));
        _headingKeys[title] = key;
      }
    }
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
        alignment: 0.1, 
      );
      setState(() => _activeHeading = entry.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final provider = Provider.of<ArticleProvider>(context);
    // Resolve the up-to-date article from provider to get loaded content
    final currentArticle = provider.articles.firstWhere(
      (a) => a.id == widget.article.id, 
      orElse: () => widget.article
    );

    if (currentArticle.content.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Re-parse ToC if content changed (e.g. just loaded)
    if (_tocEntries.isEmpty && currentArticle.content.isNotEmpty) {
       _parseToC(currentArticle.content);
    }

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
                              content: currentArticle.content,
                              headingKeys: _headingKeys,
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                      const AppFooter(),
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
