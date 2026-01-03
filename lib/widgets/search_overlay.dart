import 'package:flutter/material.dart';
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

  void _onSearch(String query) {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    final articles = provider.articles;

    setState(() {
      if (query.isEmpty) {
        _results = [];
      } else {
        _results = articles
            .where((a) =>
                a.title.toLowerCase().contains(query.toLowerCase()) ||
                a.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 600,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ESC', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (_results.isNotEmpty) {
                      context.push('/${_results.first.categoryPath}/${_results.first.id}');
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              if (Provider.of<ArticleProvider>(context).isLoading)
                const LinearProgressIndicator(minHeight: 2),
              if (_results.isNotEmpty) ...[
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final article = _results[index];
                      return ListTile(
                        leading: const Icon(Icons.article_outlined, size: 20),
                        title: Text(article.title),
                        subtitle: Text(
                          article.excerpt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          context.push('/${article.categoryPath}/${article.id}');
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
