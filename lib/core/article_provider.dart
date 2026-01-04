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

  Future<void> loadArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try loading pre-generated index.json (Optimization for Web)
      try {
        final indexContent = await rootBundle.loadString('assets/articles/index.json');
        final List<dynamic> jsonList = jsonDecode(indexContent);
        
        _articles = jsonList.map((json) => Article(
          id: json['id'],
          title: json['title'],
          excerpt: json['excerpt'] ?? '',
          content: '', // Lazy load content
          date: json['date'],
          category: json['category'],
        )).toList();

        debugPrint('Loaded ${_articles.length} articles from index.json');
      } catch (e) {
        debugPrint('index.json not found, falling back to asset scanning: $e');
        await _loadArticlesFromManifest();
      }
    } catch (e) {
      debugPrint('Major error loading articles: $e');
      _articles = [];
    }

    _isLoading = false;
    notifyListeners();
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

  Future<void> loadArticleContent(String id) async {
    final index = _articles.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final article = _articles[index];
    if (article.content.isNotEmpty) return; // Already loaded

    try {
      // Re-construct path (Assuming standard structure or we should store path in Article)
      // Since we don't store path in Article model yet, let's search manifest or guess
      // But for index.json, we didn't store path in Article.
      // Simplification: We need path to load content.
      // Let's first try to find the path from manifest if needed, or assume standard structure.
      // Improve: Store 'path' in Article model? But Article is immutable final.
      
      // Workaround: We will use AssetManifest to find the file matching ID.
      // This is slow but only happens once per article click.
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      final path = allAssets.firstWhere(
        (key) => key.endsWith('/$id.md'),
        orElse: () => '',
      );

      if (path.isNotEmpty) {
        final content = await rootBundle.loadString(path);
        // We need to parse content again to strip frontmatter? 
        // Yes, _parseArticle does that.
        final fullArticle = _parseArticle(path, content);
        
        // Update the article in the list
        _articles[index] = fullArticle;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error lazy loading article content: $e');
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
      for (var line in yamlLines) {
        if (line.contains(':')) {
          final parts = line.split(':');
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();
          
          if (key == 'title') title = value;
          else if (key == 'date') date = value;
          else if (key == 'category') category = value;
        }
      }
    } else {
      // 2. Fallback to legacy "> Key: Value" format
      final lines = content.split('\n');
      final filteredLines = <String>[];
      bool titleFound = false;
      bool isHeaderSection = true;
      
      for (var line in lines) {
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
    for (var line in contentLines) {
      if (excerpt.isEmpty && line.trim().isNotEmpty && !line.startsWith('#') && !line.startsWith('---') && !line.startsWith('>')) {
        excerpt = line.trim();
        break;
      }
    }

    if (excerpt.length > 150) {
      excerpt = excerpt.substring(0, 147) + '...';
    }

    return Article(
      id: fileName,
      title: title,
      excerpt: excerpt,
      content: cleanContent,
      date: date,
      category: category,
    );
  }
}
