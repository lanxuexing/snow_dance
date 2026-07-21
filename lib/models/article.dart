/// Dart 3.3+ Extension Type: Zero-cost type wrapper for article IDs
extension type const ArticleId(String raw) implements String {
  bool get isValid => raw.isNotEmpty;
}

/// Immutable Article Domain Model using Dart 3 Class Modifier
final class Article {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String date;
  final String category;
  final String path;

  const Article({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.category,
    required this.path,
  });

  String get categoryPath => category.toLowerCase();

  Article copyWith({
    String? id,
    String? title,
    String? excerpt,
    String? content,
    String? date,
    String? category,
    String? path,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      date: date ?? this.date,
      category: category ?? this.category,
      path: path ?? this.path,
    );
  }
}

