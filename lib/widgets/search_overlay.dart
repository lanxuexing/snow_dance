import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/models/article.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  List<Article> _results = [];
  int _focusedIndex = 0;

  void _onSearch(String query) {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    final articles = provider.articles;

    setState(() {
      if (query.isEmpty) {
        _results = [];
        _focusedIndex = 0;
      } else {
        _results = articles
            .where((a) =>
                a.title.toLowerCase().contains(query.toLowerCase()) ||
                a.excerpt.toLowerCase().contains(query.toLowerCase()) ||
                a.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _focusedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() {
                  if (_results.isNotEmpty) {
                    _focusedIndex = (_focusedIndex + 1) % _results.length;
                  }
                });
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() {
                  if (_results.isNotEmpty) {
                    _focusedIndex = (_focusedIndex - 1 + _results.length) % _results.length;
                  }
                });
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                Navigator.pop(context);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Container(
            width: 600,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search articles...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      suffixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('ESC', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (_results.isNotEmpty && _focusedIndex >= 0 && _focusedIndex < _results.length) {
                        final article = _results[_focusedIndex];
                        context.go('/${article.categoryPath}/${article.id}');
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                if (Provider.of<ArticleProvider>(context).isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                
                // Results List
                if (_results.isNotEmpty) ...[
                  const Divider(height: 1),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final article = _results[index];
                        return _SearchResultItem(
                          article: article,
                          isFocused: index == _focusedIndex,
                          onHover: () {
                            setState(() {
                              _focusedIndex = index;
                            });
                          },
                          onTap: () {
                            context.go('/${article.categoryPath}/${article.id}');
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ] else if (_controller.text.isNotEmpty && !Provider.of<ArticleProvider>(context).isLoading) ...[
                  const Divider(height: 1),
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No results found.', style: TextStyle(color: Colors.grey)),
                  ),
                ],
                
                // Keyboard Shortcuts Footer (Matching Algolia design!)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MediaQuery.of(context).size.width >= 600 
                        ? MainAxisAlignment.start 
                        : MainAxisAlignment.center,
                    children: [
                      if (MediaQuery.of(context).size.width >= 600) ...[
                        _buildKeyHint(context, '↵', 'to select'),
                        const SizedBox(width: 16),
                        _buildKeyHint(context, '↓↑', 'to navigate'),
                        const SizedBox(width: 16),
                        _buildKeyHint(context, 'esc', 'to close'),
                        const Spacer(),
                      ],
                      Text(
                        'Search by SnowDance',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyHint(BuildContext context, String key, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            key,
            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _SearchResultItem extends StatefulWidget {
  final Article article;
  final bool isFocused;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _SearchResultItem({
    required this.article,
    required this.isFocused,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final bool showHighlight = widget.isFocused || _isHovered;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHover();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: showHighlight
                ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: showHighlight
                  ? primaryColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: showHighlight 
                      ? primaryColor.withValues(alpha: 0.15) 
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 20,
                  color: showHighlight ? primaryColor : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.article.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: showHighlight 
                            ? primaryColor 
                            : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.article.excerpt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.article.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSearchOverlay(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const SearchOverlay(),
  );
}
