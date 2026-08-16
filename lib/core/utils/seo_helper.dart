import 'seo_helper_stub.dart'
    if (dart.library.js_interop) 'seo_helper_web.dart' as impl;

class SEOHelper {
  static void updateSEO({
    required String title,
    required String description,
    List<String>? keywords,
    String? author,
  }) {
    impl.updateSEOImpl(
      title: title,
      description: description,
      keywords: keywords,
      author: author,
    );
  }
}
