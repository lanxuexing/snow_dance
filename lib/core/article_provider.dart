import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snow_dance/models/article.dart';

class ArticleProvider extends ChangeNotifier {
  static const List<Article> _initialArticles = [
    Article(
      id: 'flutter-3-44-migration',
      title: 'Flutter 3.44.6 & Dart 3.12 性能飞跃：从 GPU 图层隔离、零开销 Extension Types 到 Slivers 懒加载实战',
      excerpt: '深入剖析 Flutter 3.44.6 & Dart 3.12 最佳性能调优实战：从 GPU 光栅化磨砂玻璃 RepaintBoundary 图层隔离，到 CustomScrollView Slivers 响应式懒加载，以及零成本 Extension Types 与 WebAssembly (WASM) 极致加载速度。',
      content: '',
      date: '2026-07-21',
      category: 'Docs',
      path: 'assets/articles/docs/flutter-3-44-migration.md',
    ),
    Article(
      id: 'angular-signals-deep-dive',
      title: '深度剖析 Angular Signals：解密高效响应式的底层设计与 Push/Pull 算法',
      excerpt: '在现代前端开发中，管理复杂的用户界面（UI）状态是一项极富挑战的任务。UI 状态往往不是孤立的，而是一个由复杂依赖关系交织而成的派生状态网。',
      content: '',
      date: '2026-07-11',
      category: 'Blog',
      path: 'assets/articles/blog/angular-signals-deep-dive.md',
    ),
    Article(
      id: 'angular-seo-scully',
      title: 'Angular SEO 终极优化指南：利用 Scully 进行静态预渲染与社交网络定制',
      excerpt: '在现代 Web 开发中，单页应用（SPA）凭借卓越的用户体验和敏捷的页面内局部刷新成为了行业主流。但 SPA 有一个致命的弱点——对搜索引擎优化（SEO）和社交媒体分享极其不友好。',
      content: '',
      date: '2026-07-11',
      category: 'Blog',
      path: 'assets/articles/blog/angular-seo-scully.md',
    ),
    Article(
      id: 'angular-guards-resolvers',
      title: '深入 Angular 路由控制：守卫（Guards）与解析器（Resolvers）的极致探索',
      excerpt: '在现代 Web 应用的开发中，路由系统（Routing）是组织应用架构和控制用户导航流的核心枢纽。但在 Angular 中，守卫（Guards）与解析器（Resolvers）则是路由系统的两大关键机制。',
      content: '',
      date: '2026-07-11',
      category: 'Blog',
      path: 'assets/articles/blog/angular-guards-resolvers.md',
    ),
    Article(
      id: 'angular-v22-hostdirectives-dedup',
      title: 'Angular v22 特性解析：hostDirectives（宿主指令）去重机制详解',
      excerpt: '在 Angular 中，指令组合 API（Directive Composition API）是一项极具革命性的特性。它允许我们通过 hostDirectives 属性，将一个或多个指令的行为什么直接“继承”或“拼装”到另一个指令/组件上。',
      content: '',
      date: '2026-07-11',
      category: 'Blog',
      path: 'assets/articles/blog/angular-v22-hostdirectives-dedup.md',
    ),
    Article(
      id: 'git-delete',
      title: 'git删除操作',
      excerpt: 'git删除操作常见实用技巧。',
      content: '',
      date: '2026-07-01',
      category: 'Blog',
      path: 'assets/articles/blog/git-delete.md',
    ),
  ];

  List<Article> _articles = List.from(_initialArticles);
  bool _isLoading = false;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  ArticleProvider() {
    loadArticles();
  }

  Future<void> loadArticles() async {
    try {
      // 1. Try loading index.json for fast indexing
      try {
        final indexContent = await rootBundle.loadString('assets/articles/index.json');
        final List<dynamic> jsonList = jsonDecode(indexContent);
        
        final indexedArticles = jsonList.map((json) => Article(
          id: json['id'],
          title: json['title'],
          excerpt: json['excerpt'] ?? '',
          content: '',
          date: json['date'],
          category: json['category'],
          path: json['path'] ?? '',
        )).toList();

        if (indexedArticles.isNotEmpty) {
          _articles = indexedArticles;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('index.json fallback: $e');
      }

      // 2. Automatically scan AssetManifest for newly added .md files with 0 commands needed
      await _loadArticlesFromManifest();
    } catch (e) {
      debugPrint('Error during background article loading: $e');
    }

    _isLoading = false;
    notifyListeners();
    
    // Background preloading of content
    _preloadAllArticleContents();
  }

  Future<void> _loadArticlesFromManifest() async {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      debugPrint('Total assets found: ${allAssets.length}');
      
      final articlePaths = allAssets
          .where((String key) => 
              (key.contains('assets/articles/') || key.startsWith('articles/')) && 
              key.endsWith('.md'))
          .toList();

      debugPrint('Filtered article paths: $articlePaths');

      List<Article> loadedArticles = [];

      // Parallelize downloads for faster dev startup
      final futures = articlePaths.map((path) async {
        try {
          final content = await rootBundle.loadString(path);
          return _parseArticle(path, content);
        } catch (e) {
          debugPrint('Error loading article at $path: $e');
          return null;
        }
      });

      final results = await Future.wait(futures);
      loadedArticles = results.whereType<Article>().toList();

      if (loadedArticles.isEmpty) {
        debugPrint('No articles found in assets.');
        _articles = [];
      } else {
        loadedArticles.sort((a, b) => b.date.compareTo(a.date));
        _articles = loadedArticles;
      }
  }

  Future<void> _preloadAllArticleContents() async {
    // Sequentially preload all article contents in the background
    // Using await inside the loop lets Flutter yield to frame rendering, keeping UI smooth
    for (int i = 0; i < _articles.length; i++) {
      final article = _articles[i];
      if (article.content.isEmpty && article.path.isNotEmpty) {
        try {
          final content = await rootBundle.loadString(article.path);
          final fullArticle = _parseArticle(article.path, content);
          _articles[i] = fullArticle;
        } catch (e) {
          debugPrint('Error preloading article content for ${article.id}: $e');
        }
      }
    }
    notifyListeners();
    debugPrint('Background preloading of all article contents completed.');
  }

  Future<void> loadArticleContent(String id) async {
    final index = _articles.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final article = _articles[index];
    if (article.content.isNotEmpty) return; // Already loaded

    try {
      // Use direct path from Article model, extremely fast!
      var path = article.path;
      if (path.isEmpty) {
        // Fallback to construction if empty
        path = 'assets/articles/${article.category.toLowerCase()}/$id.md';
      }

      final content = await rootBundle.loadString(path);
      final fullArticle = _parseArticle(path, content);
      
      _articles[index] = fullArticle;
      notifyListeners();
    } catch (e) {
      debugPrint('Error lazy loading article content for $id: $e');
      // Ensure UI doesn't hang forever if load fails
      notifyListeners();
    }
  }

  Article _parseArticle(String path, String content) {
    final fileName = path.split('/').last.replaceAll('.md', '');
    
    String title = fileName;
    String date = '2024-01-01';
    
    // Detect default category from folder name
    final parts = path.split('/');
    String category = 'Blog';
    if (parts.length >= 3) {
      final folderName = parts[parts.length - 2];
      category = folderName[0].toUpperCase() + folderName.substring(1).toLowerCase();
    }
    
    String excerpt = '';
    String cleanContent = content;

    // 1. Try parsing YAML Frontmatter (Standard)
    final frontmatterRegex = RegExp(r'^---\s*\n([\s\S]*?)\n---\s*\n');
    final match = frontmatterRegex.firstMatch(content);
    
    if (match != null) {
      final yamlContent = match.group(1) ?? '';
      cleanContent = content.substring(match.end);
      
      final yamlLines = yamlContent.split('\n');
      for (final line in yamlLines) {
        if (line.contains(':')) {
          final parts = line.split(':');
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();
          
          if (key == 'title') {
            title = value;
          } else if (key == 'date') {
            date = value;
          } else if (key == 'category') {
            category = value;
          }
        }
      }
    } else {
      // 2. Fallback to legacy "> Key: Value" format
      final lines = content.split('\n');
      final filteredLines = <String>[];
      bool titleFound = false;
      bool isHeaderSection = true;
      
      for (final line in lines) {
        // Once found a non-metadata block, treat everything else as content
        if (!isHeaderSection) {
          filteredLines.add(line);
          continue;
        }

        // Skip empty lines in the initial header section
        if (line.trim().isEmpty) {
          continue;
        }
        
        if (line.startsWith('# ') && !titleFound) {
          title = line.replaceFirst('# ', '').trim();
          titleFound = true;
        } else if (line.startsWith('> Date:')) {
          date = line.replaceFirst('> Date:', '').trim();
        } else if (line.startsWith('> Category:')) {
          category = line.replaceFirst('> Category:', '').trim();
        } else {
          // Encountered a line that is not metadata and not empty -> Content starts here
          isHeaderSection = false;
          filteredLines.add(line);
        }
      }
      cleanContent = filteredLines.join('\n').trim();
    }

    // Generate excerpt from clean content
    final contentLines = cleanContent.split('\n');
    for (final line in contentLines) {
      if (excerpt.isEmpty && line.trim().isNotEmpty && !line.startsWith('#') && !line.startsWith('---') && !line.startsWith('>')) {
        excerpt = line.trim();
        break;
      }
    }

    if (excerpt.length > 150) {
      excerpt = '${excerpt.substring(0, 147)}...';
    }

    return Article(
      id: fileName,
      title: title,
      excerpt: excerpt,
      content: cleanContent,
      date: date,
      category: category,
      path: path,
    );
  }
}
