class Article {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String date;
  final String category;
  final String path;

  Article({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.category,
    required this.path,
  });

  String get categoryPath => category.toLowerCase();
}
