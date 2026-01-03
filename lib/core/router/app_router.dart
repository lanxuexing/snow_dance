import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/widgets/main_layout.dart';
import 'package:snow_dance/widgets/category_redirect_page.dart';
import 'package:snow_dance/pages/home_page.dart';
import 'package:snow_dance/pages/article_detail_page.dart';
import 'package:snow_dance/models/article.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(child: HomePage()),
    ),
    GoRoute(
      path: '/blog',
      builder: (context, state) => const MainLayout(child: CategoryRedirectPage(category: 'Blog')),
    ),
    GoRoute(
      path: '/docs',
      builder: (context, state) => const MainLayout(child: CategoryRedirectPage(category: 'Docs')),
    ),
    GoRoute(
      path: '/guide',
      builder: (context, state) => const MainLayout(child: CategoryRedirectPage(category: 'Guide')),
    ),
    GoRoute(
      path: '/ecosystem',
      builder: (context, state) => const MainLayout(child: CategoryRedirectPage(category: 'Ecosystem')),
    ),
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
      
      // We need to access the provider to find the article
      // Since GoRouter is defined globally, we can't easily get 'context' unless inside builder
      // Luckily, builder provides context.
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      
      Article? article;
      try {
        article = provider.articles.firstWhere((a) => a.id == id);
      } catch (e) {
        article = null;
      }

      if (article == null) {
        return const MainLayout(
          child: Center(child: Text('404: Article not found')),
        );
      }

      return MainLayout(
        child: ArticleDetailPage(article: article),
      );
    },
  );
}
