// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';


/// SnowDance Automated Article Index Generator
/// Run this script whenever you add or update Markdown articles:
///   dart run tool/generate_index.dart
void main() async {
  final articlesDir = Directory('assets/articles');
  if (!articlesDir.existsSync()) {
    print('Error: assets/articles directory not found.');
    return;
  }

  final List<Map<String, String>> articleList = [];

  final List<FileSystemEntity> files = articlesDir.listSync(recursive: true);
  for (final entity in files) {
    if (entity is File && entity.path.endsWith('.md')) {
      final relativePath = entity.path.replaceAll('\\', '/');
      final content = await entity.readAsString();
      final metadata = parseArticleMetadata(relativePath, content);
      articleList.add(metadata);
    }
  }

  // Sort articles by date descending
  articleList.sort((a, b) => b['date']!.compareTo(a['date']!));

  final outputFile = File('assets/articles/index.json');
  final jsonEncoder = JsonEncoder.withIndent('  ');
  await outputFile.writeAsString(jsonEncoder.convert(articleList));

  print('Successfully generated index.json with ${articleList.length} articles!');
}

Map<String, String> parseArticleMetadata(String path, String content) {
  final fileName = path.split('/').last.replaceAll('.md', '');
  String title = fileName;
  String date = '2026-01-01';
  
  final parts = path.split('/');
  String category = 'Blog';
  if (parts.length >= 3) {
    final folderName = parts[parts.length - 2];
    category = folderName[0].toUpperCase() + folderName.substring(1).toLowerCase();
  }

  String excerpt = '';
  String cleanContent = content;

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
    excerpt = extractExcerpt(cleanContent);
  }

  if (excerpt.isEmpty) {
    excerpt = title;
  }

  if (excerpt.length > 150) {
    excerpt = '${excerpt.substring(0, 147)}...';
  }

  return {
    'id': fileName,
    'title': title,
    'excerpt': excerpt,
    'date': date,
    'category': category,
    'path': path,
  };
}

String extractExcerpt(String content) {
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
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1') // [text](url) -> text
        .replaceAll(RegExp(r'[*_~`]+'), '') // strip bold/italic/code/strikethrough
        .replaceAll(RegExp(r'<[^>]*>'), '') // strip inline html
        .trim();

    if (cleaned.isNotEmpty) {
      return cleaned;
    }
  }
  return '';
}
