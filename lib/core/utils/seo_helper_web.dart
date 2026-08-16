// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

void updateSEOImpl({
  required String title,
  required String description,
  List<String>? keywords,
  String? author,
}) {
  // 1. Update document Title
  web.document.title = title;

  // Helper to find or create standard meta tags
  void updateMeta(String name, String content) {
    var element = web.document.querySelector('meta[name="$name"]');
    if (element == null) {
      element = web.document.createElement('meta');
      element.setAttribute('name', name);
      web.document.head?.append(element);
    }
    element.setAttribute('content', content);
  }

  // Helper to find or create Open Graph meta tags
  void updateOGMeta(String property, String content) {
    var element = web.document.querySelector('meta[property="$property"]');
    if (element == null) {
      element = web.document.createElement('meta');
      element.setAttribute('property', property);
      web.document.head?.append(element);
    }
    element.setAttribute('content', content);
  }

  // 2. Update description tag & og:description
  updateMeta('description', description);
  updateOGMeta('og:description', description);

  // 3. Update keywords meta
  if (keywords != null && keywords.isNotEmpty) {
    updateMeta('keywords', keywords.join(', '));
  }

  // 4. Update author meta
  if (author != null) {
    updateMeta('author', author);
  }

  // 5. Update Open Graph details
  updateOGMeta('og:title', title);
  updateOGMeta('og:type', 'article');
}
