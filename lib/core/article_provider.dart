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
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      debugPrint('Total assets found: ${allAssets.length}');
      
      // More flexible matching to catch any md articles in our target directory
      final articlePaths = allAssets
          .where((String key) => 
              (key.contains('assets/articles/') || key.startsWith('articles/')) && 
              key.endsWith('.md'))
          .toList();

      debugPrint('Filtered article paths: $articlePaths');

      List<Article> loadedArticles = [];

      for (String path in articlePaths) {
        try {
          final content = await rootBundle.loadString(path);
          final article = _parseArticle(path, content);
          loadedArticles.add(article);
        } catch (e) {
          debugPrint('Error loading article at \$path: \$e');
        }
      }

      if (loadedArticles.isEmpty) {
        debugPrint('No articles found in assets.');
        _articles = [];
      } else {
        // Sort by date descending
        loadedArticles.sort((a, b) => b.date.compareTo(a.date));
        _articles = loadedArticles;
      }
    } catch (e) {
      debugPrint('Major error loading articles: \$e');
      _articles = [];
    }

    _isLoading = false;
    notifyListeners();
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
