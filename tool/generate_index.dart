import 'dart:io';
import 'dart:convert';

void main() async {
  final articlesDir = Directory('assets/articles');
  if (!articlesDir.existsSync()) {
    print('Error: assets/articles directory not found.');
    exit(1);
  }

  final List<Map<String, String>> articles = [];
  final files = articlesDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.md'));

  print('Found ${files.length} markdown files.');

  for (final file in files) {
    final content = await file.readAsString();
    final metadata = _parseMetadata(file.path, content);
    articles.add(metadata);
  }

  // Sort by date descending
  articles.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

  final indexFile = File('assets/articles/index.json');
  await indexFile.writeAsString(jsonEncode(articles));
  print('Generated assets/articles/index.json with ${articles.length} articles.');
}

Map<String, String> _parseMetadata(String path, String content) {
  // Normalized path for web asset loading (forward slashes)
  String assetPath = path.replaceAll('\\', '/');
  
  final fileName = assetPath.split('/').last.replaceAll('.md', '');
  
  String title = fileName;
  String date = '2024-01-01';
  String category = 'Blog';
  String excerpt = '';

  // Infer category from folder structure if possible
  final parts = assetPath.split('/');
  if (parts.length >= 2) {
      // e.g. assets/articles/blog/foo.md -> parts: [assets, articles, blog, foo.md]
      // category folder is parts[parts.length - 2]
      final folder = parts[parts.length - 2];
      // Use the immediate parent folder name as category
      if (folder.isNotEmpty && folder.toLowerCase() != 'articles') {
          category = folder[0].toUpperCase() + folder.substring(1).toLowerCase();
      }
  }

  // Parse Frontmatter
  final frontmatterRegex = RegExp(r'^---\s*\n([\s\S]*?)\n---\s*\n');
  final match = frontmatterRegex.firstMatch(content);
  String cleanContent = content;

  if (match != null) {
    final yamlContent = match.group(1) ?? '';
    cleanContent = content.substring(match.end);
    
    final yamlLines = yamlContent.split('\n');
    for (var line in yamlLines) {
      if (line.contains(':')) {
        final keyParts = line.split(':');
        final key = keyParts[0].trim().toLowerCase();
        final value = keyParts.sublist(1).join(':').trim();
        
        if (key == 'title') title = value;
        else if (key == 'date') date = value;
        else if (key == 'category') category = value;
      }
    }
  } else {
     // Check for legacy headers
     final lines = content.split('\n');
     for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('# ') && !title.contains(line.replaceFirst('# ', ''))) title = line.replaceFirst('# ', '').trim();
        else if (line.startsWith('> Date:')) date = line.replaceFirst('> Date:', '').trim();
        else if (line.startsWith('> Category:')) category = line.replaceFirst('> Category:', '').trim();
     }
  }

  // Generate Excerpt
  final contentLines = cleanContent.split('\n');
  for (var line in contentLines) {
    line = line.trim();
    if (line.isNotEmpty && !line.startsWith('#') && !line.startsWith('---') && !line.startsWith('>')) {
      excerpt = line;
      break;
    }
  }
  if (excerpt.length > 200) {
    excerpt = excerpt.substring(0, 197) + '...';
  }

  // Ensure ID is unique and simple
  return {
    'id': fileName,
    'title': title,
    'date': date,
    'category': category,
    'excerpt': excerpt,
    'path': assetPath, // usage for fetch
  };
}
