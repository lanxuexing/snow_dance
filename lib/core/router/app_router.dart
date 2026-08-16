import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/widgets/main_layout.dart';
import 'package:snow_dance/widgets/category_redirect_page.dart';
import 'package:snow_dance/widgets/premium_loader.dart';
import 'package:snow_dance/pages/home_page.dart';
import 'package:snow_dance/pages/article_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/blog',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryRedirectPage(category: 'Blog'),
          ),
        ),
        GoRoute(
          path: '/docs',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryRedirectPage(category: 'Docs'),
          ),
        ),
        GoRoute(
          path: '/guide',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryRedirectPage(category: 'Guide'),
          ),
        ),
        GoRoute(
          path: '/ecosystem',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryRedirectPage(category: 'Ecosystem'),
          ),
        ),
        _buildArticleRoute('/blog/:id'),
        _buildArticleRoute('/guide/:id'),
        _buildArticleRoute('/docs/:id'),
        _buildArticleRoute('/ecosystem/:id'),
      ],
    ),
  ],
);

GoRoute _buildArticleRoute(String path) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id'];
      final provider = Provider.of<ArticleProvider>(context);

      Widget content;
      if (provider.isLoading) {
        content = const PremiumLoader();
      } else {
        final article = provider.findById(id);
        if (article == null) {
          content = const Center(child: Text('404: Article not found'));
        } else {
          content = ArticleDetailPage(article: article);
        }
      }

      return CustomTransitionPage(
        key: state.pageKey,
        child: content,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 120),
      );
    },
  );
}
