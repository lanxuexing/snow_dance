import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/widgets/premium_loader.dart';
import 'package:snow_dance/widgets/main_layout.dart';
import 'package:snow_dance/models/article.dart';

class CategoryRedirectPage extends StatefulWidget {
  final String category;

  const CategoryRedirectPage({super.key, required this.category});

  @override
  State<CategoryRedirectPage> createState() => _CategoryRedirectPageState();
}

class _CategoryRedirectPageState extends State<CategoryRedirectPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRedirect();
    });
  }

  void _checkAndRedirect() {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    if (!provider.isLoading) {
      _performRedirect(provider);
    }
  }

  void _performRedirect(ArticleProvider provider) {
    final categoryArticles = provider.articles.where((a) => 
      a.category.toLowerCase() == widget.category.toLowerCase()
    ).toList();

    if (categoryArticles.isNotEmpty) {
      final latest = categoryArticles.first;
      context.go('/${widget.category.toLowerCase()}/${latest.id}');
    } else {
      // If no articles, maybe just stay or show 404. For now go home.
       if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _performRedirect(provider);
      });
    }

    // Reuse MainLayout from main.dart if possible, but circular import might be issue.
    // main.dart imports widgets, widgets import main.dart?
    // MainLayout is in main.dart.
    // To avoid circular dependency, I should move MainLayout to separate file or duplicate layout.
    // Moving MainLayout is best. But for now I'll just return PremiumLoader directly?
    // MainLayout adds Header. Using just Loader might be jarring.
    // I can stick to Scaffold logic here or move MainLayout.
    // I'll move MainLayout to lib/widgets/main_layout.dart first?
    // Too many changes.
    // I'll just use simple Scaffold with PremiumLoader here.
    return MainLayout(
      child: PremiumLoader(isDark: isDark),
    );
  }
}
