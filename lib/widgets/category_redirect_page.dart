import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/widgets/premium_loader.dart';

class CategoryRedirectPage extends StatefulWidget {
  final String category;

  const CategoryRedirectPage({super.key, required this.category});

  @override
  State<CategoryRedirectPage> createState() => _CategoryRedirectPageState();
}

class _CategoryRedirectPageState extends State<CategoryRedirectPage> {
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRedirect();
    });
  }

  void _checkAndRedirect() {
    if (_hasRedirected) return;
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    if (!provider.isLoading) {
      _performRedirect(provider);
    }
  }

  void _performRedirect(ArticleProvider provider) {
    if (_hasRedirected || !mounted) return;
    _hasRedirected = true;

    final categoryArticles = provider.articles.where((a) =>
      a.category.toLowerCase() == widget.category.toLowerCase()
    ).toList();

    if (categoryArticles.isNotEmpty) {
      final latest = categoryArticles.first;
      context.go('/${widget.category.toLowerCase()}/${latest.id}');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!provider.isLoading && !_hasRedirected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _performRedirect(provider);
      });
    }

    return PremiumLoader(isDark: isDark);
  }
}
