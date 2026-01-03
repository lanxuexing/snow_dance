class Article {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String date;
  final String category;

  Article({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.category,
  });

  String get categoryPath => category.toLowerCase();
}
