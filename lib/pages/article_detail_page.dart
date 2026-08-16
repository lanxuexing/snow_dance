import 'package:flutter/gestures.dart';
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
import 'package:snow_dance/core/utils/seo_helper.dart';


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
  DateTime _lastScrollCheck = DateTime.now();
  bool _showBackToTop = false;

  void _forwardScroll(PointerScrollEvent event) {
    if (_scrollController.hasClients) {
      final newOffset = (_scrollController.offset + event.scrollDelta.dy)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(newOffset);
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Check if content needs to be loaded
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    final current = provider.findById(widget.article.id) ?? widget.article;

    if (current.content.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ArticleProvider>(context, listen: false)
            .loadArticleContent(widget.article.id);
      });
    } else {
      _parseToC(current.content);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final now = DateTime.now();
    if (now.difference(_lastScrollCheck).inMilliseconds < 40) return;
    _lastScrollCheck = now;

    if (_scrollController.hasClients) {
      final showTop = _scrollController.offset > 350;
      if (showTop != _showBackToTop && mounted) {
        setState(() {
          _showBackToTop = showTop;
        });
      }
    }

    String? newActiveHeading;

    for (var entry in _tocEntries) {
      final context = entry.key.currentContext;
      if (context == null || !context.mounted) continue;

      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox) continue;

      final position = renderObject.localToGlobal(Offset.zero);
      const threshold = 200.0;

      if (position.dy <= threshold) {
        newActiveHeading = entry.id;
      }
    }

    if (newActiveHeading == null && _tocEntries.isNotEmpty) {
      newActiveHeading = _tocEntries.first.id;
    }

    if (newActiveHeading != _activeHeading && mounted) {
      setState(() {
        _activeHeading = newActiveHeading;
      });
    }
  }

  @override
  void didUpdateWidget(ArticleDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.id != widget.article.id) {
      _tocEntries.clear();
      _headingKeys.clear();
      
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      final current = provider.findById(widget.article.id) ?? widget.article;

      if (current.content.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<ArticleProvider>(context, listen: false)
              .loadArticleContent(widget.article.id);
        });
      } else {
        _parseToC(current.content);
      }
      if (_tocEntries.isNotEmpty) {
        _activeHeading = _tocEntries.first.id;
      }
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _parseToC(String content) {
    _tocEntries.clear();
    _headingKeys.clear();
    final lines = content.split('\n');
    final headingRegex = RegExp(r'^(#{1,6})\s+(.+)$');
    final Map<String, int> counts = {};

    bool isInCodeBlock = false;
    bool isInFrontmatter = false;
    int lineIndex = 0;

    for (final line in lines) {
      lineIndex++;
      final trimmed = line.trim();

      // Ignore YAML frontmatter at file start
      if (lineIndex == 1 && trimmed == '---') {
        isInFrontmatter = true;
        continue;
      }
      if (isInFrontmatter) {
        if (trimmed == '---') {
          isInFrontmatter = false;
        }
        continue;
      }

      // Ignore contents inside code blocks
      if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
        isInCodeBlock = !isInCodeBlock;
        continue;
      }
      if (isInCodeBlock) {
        continue;
      }

      final match = headingRegex.firstMatch(trimmed);
      if (match != null) {
        final hashes = match.group(1)!;
        final title = match.group(2)!.trim();
        final level = hashes.length;

        final count = counts[title] = (counts[title] ?? 0) + 1;
        final uniqueId = '${title}_$count';

        final key = GlobalKey();
        _tocEntries.add(ToCEntry(title: title, id: uniqueId, level: level, key: key));
        _headingKeys[uniqueId] = key;
        if (count == 1) {
          _headingKeys[title] = key;
        }
      }
    }
    if (_activeHeading == null && _tocEntries.isNotEmpty) {
      _activeHeading = _tocEntries.first.id;
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
      setState(() => _activeHeading = entry.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 1000;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final provider = Provider.of<ArticleProvider>(context);
    final currentArticle = provider.findById(widget.article.id) ?? widget.article;
    final isContentEmpty = currentArticle.content.isEmpty;

    // Re-parse ToC if content changed / just loaded
    if (!isContentEmpty && _tocEntries.isEmpty) {
      _parseToC(currentArticle.content);
    }

    if (!isContentEmpty) {
      SEOHelper.updateSEO(
        title: '${currentArticle.title} - SnowDance',
        description: currentArticle.excerpt,
        keywords: [currentArticle.category, 'SnowDance', 'Blog', 'Docs'],
        author: AppConfig.authorName,
      );
    }

    return SelectionArea(
      child: Stack(
        children: [
          // 1. Full-width, Page-level SingleChildScrollView (Scrollbar rendered at far right window edge)
          SingleChildScrollView(
            controller: _scrollController,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) const SizedBox(width: 280),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 880),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          _buildAuthorSection(context),
                          if (isMobile && _tocEntries.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            _buildMobileToC(context),
                          ],
                          const SizedBox(height: 40),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: isContentEmpty
                                ? ArticleSkeleton(isDark: isDark)
                                : MarkdownViewer(
                                    key: ValueKey('article_content_${currentArticle.id}'),
                                    content: currentArticle.content,
                                    headingKeys: _headingKeys,
                                  ),
                          ),
                          const SizedBox(height: 80),
                          const AppFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isMobile) const SizedBox(width: 240),
              ],
            ),
          ),

          // 2. Fixed Left Sidebar (Sticky on the left with pointer scroll forwarding)
          if (!isMobile)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 280,
              child: Listener(
                onPointerSignal: (signal) {
                  if (signal is PointerScrollEvent) {
                    _forwardScroll(signal);
                  }
                },
                child: _buildSidebar(context),
              ),
            ),

          // 3. Fixed Right TOC (Sticky on the right with pointer scroll forwarding)
          if (!isMobile)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 240,
              child: Listener(
                onPointerSignal: (signal) {
                  if (signal is PointerScrollEvent) {
                    _forwardScroll(signal);
                  }
                },
                child: isContentEmpty ? const SizedBox(width: 240) : _buildToCSidebar(context),
              ),
            ),

          // 4. Floating Back-to-Top Button
          Positioned(
            bottom: isMobile ? 24 : 36,
            right: isMobile ? 20 : 36,
            child: AnimatedScale(
              scale: _showBackToTop ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _showBackToTop ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: _FloatingBackToTopButton(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileToC(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.05),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          collapsedIconColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
            final isSelect = entry.id == _activeHeading || entry.title == _activeHeading;
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
                         : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConfig.authorName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.article.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
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
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: SingleChildScrollView(
        key: const PageStorageKey('sidebar_scroll'),
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
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
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
                      Icon(Icons.arrow_upward_rounded, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Text(
                        'Back to the top',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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

class _FloatingBackToTopButton extends StatefulWidget {
  final VoidCallback onTap;
  const _FloatingBackToTopButton({required this.onTap});

  @override
  State<_FloatingBackToTopButton> createState() => _FloatingBackToTopButtonState();
}

class _FloatingBackToTopButtonState extends State<_FloatingBackToTopButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : (_isHovered ? 1.08 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF1E1E1E).withValues(alpha: 0.85) 
                  : Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isHovered 
                    ? primaryColor.withValues(alpha: 0.6) 
                    : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered 
                      ? primaryColor.withValues(alpha: isDark ? 0.35 : 0.25) 
                      : Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 24,
              color: _isHovered ? primaryColor : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

