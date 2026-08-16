import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snow_dance/models/article.dart';

class ArticleProvider extends ChangeNotifier {
  List<Article> _articles = [];
  bool _isLoading = true;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  ArticleProvider() {
    loadArticles();
  }

  Article? findById(String? id) {
    if (id == null) return null;
    return _articles.where((a) => a.id == id).firstOrNull;
  }

  Future<void> loadArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Primary: Fast load from generated index.json
      try {
        final indexContent = await rootBundle.loadString('assets/articles/index.json');
        final List<dynamic> jsonList = jsonDecode(indexContent);

        final indexedArticles = jsonList.map((json) => Article(
          id: json['id'],
          title: json['title'],
          excerpt: json['excerpt'] ?? '',
          content: '',
          date: json['date'] ?? '',
          category: json['category'] ?? 'Blog',
          path: json['path'] ?? '',
        )).toList();

        if (indexedArticles.isNotEmpty) {
          indexedArticles.sort((a, b) => b.date.compareTo(a.date));
          _articles = indexedArticles;
          _isLoading = false;
          notifyListeners();

          // Preload markdown content in background so detail navigation is 100% instantaneous
          for (final a in indexedArticles) {
            loadArticleContent(a.id);
          }
          return;
        }
      } catch (e) {
        debugPrint('index.json loading fallback: $e');
      }

      // 2. Fallback: Scan AssetManifest if index.json is missing or failed
      await _loadArticlesFromManifest();
    } catch (e) {
      debugPrint('Error during article loading: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadArticlesFromManifest() async {
    try {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      final articlePaths = allAssets
          .where((String key) =>
              (key.contains('assets/articles/') || key.startsWith('articles/')) &&
              key.endsWith('.md'))
          .toList();

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
      final loadedArticles = results.whereType<Article>().toList();

      if (loadedArticles.isNotEmpty) {
        loadedArticles.sort((a, b) => b.date.compareTo(a.date));
        _articles = loadedArticles;
      }
    } catch (e) {
      debugPrint('Error loading from AssetManifest: $e');
    }
  }

  Future<void> loadArticleContent(String id) async {
    final index = _articles.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final article = _articles[index];
    if (article.content.isNotEmpty) return; // Already loaded

    try {
      var path = article.path;
      if (path.isEmpty) {
        path = 'assets/articles/${article.category.toLowerCase()}/$id.md';
      }

      final content = await rootBundle.loadString(path);
      final fullArticle = _parseArticle(path, content);

      _articles[index] = fullArticle;
      notifyListeners();
    } catch (e) {
      debugPrint('Error lazy loading article content for $id: $e');
      notifyListeners();
    }
  }

  Article _parseArticle(String path, String content) {
    final fileName = path.split('/').last.replaceAll('.md', '');

    String title = fileName;
    String date = '2026-01-01';

    // Detect default category from folder name
    final parts = path.split('/');
    String category = 'Blog';
    if (parts.length >= 3) {
      final folderName = parts[parts.length - 2];
      category = folderName[0].toUpperCase() + folderName.substring(1).toLowerCase();
    }

    String excerpt = '';
    String cleanContent = content;

    // 1. Try parsing YAML Frontmatter
    final frontmatterRegex = RegExp(r'^---\s*\n([\s\S]*?)\n---\s*\n');
    final match = frontmatterRegex.firstMatch(content);

    if (match != null) {
      final yamlContent = match.group(1) ?? '';
      cleanContent = content.substring(match.end);

      final yamlLines = yamlContent.split('\n');
      for (final line in yamlLines) {
        if (line.contains(':')) {
          final pair = line.split(':');
          final key = pair[0].trim().toLowerCase();
          final value = pair.sublist(1).join(':').trim();

          if (key == 'title') {
            title = value;
          } else if (key == 'date') {
            date = value;
          } else if (key == 'category') {
            category = value;
          } else if (key == 'excerpt') {
            excerpt = value;
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
        if (!isHeaderSection) {
          filteredLines.add(line);
          continue;
        }

        if (line.trim().isEmpty) continue;

        if (line.startsWith('# ') && !titleFound) {
          title = line.replaceFirst('# ', '').trim();
          titleFound = true;
        } else if (line.startsWith('> Date:')) {
          date = line.replaceFirst('> Date:', '').trim();
        } else if (line.startsWith('> Category:')) {
          category = line.replaceFirst('> Category:', '').trim();
        } else {
          isHeaderSection = false;
          filteredLines.add(line);
        }
      }
      cleanContent = filteredLines.join('\n').trim();
    }

    if (excerpt.isEmpty) {
      excerpt = _extractExcerpt(cleanContent);
    }

    if (excerpt.isEmpty) {
      excerpt = title;
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

  static String _extractExcerpt(String content) {
    final lines = content.split('\n');
    bool inCodeBlock = false;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Toggle code blocks
      if (line.startsWith('```') || line.startsWith('~~~')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) continue;

      // Skip headers, blockquotes, horizontal rules, images, html tags
      if (line.startsWith('#') ||
          line.startsWith('>') ||
          line.startsWith('---') ||
          line.startsWith('***') ||
          line.startsWith('___') ||
          line.startsWith('![') ||
          line.startsWith('<')) {
        continue;
      }

      // Clean inline markdown formatting
      final cleaned = line
          .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
          .replaceAll(RegExp(r'[*_~`]+'), '')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();

      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return '';
  }
}
