/// Turns heading text into a URL-safe anchor id: `Retry & back-off` becomes
/// `retry-back-off`.
String slugify(String text) {
  final String slug = text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'section' : slug;
}
