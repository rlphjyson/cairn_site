/// Length-aware text helpers for titles and meta descriptions.
library;

/// Search engines truncate titles at roughly 60 characters and descriptions at
/// roughly 155-160. These helpers cut on a word boundary and add an ellipsis,
/// so a long product name never produces a mid-word chop in a result snippet.
String truncate(String text, int max) {
  final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.length <= max) return clean;
  final cut = clean.substring(0, max - 1);
  final lastSpace = cut.lastIndexOf(' ');
  final base = lastSpace > max ~/ 2 ? cut.substring(0, lastSpace) : cut;
  return '${base.replaceAll(RegExp(r'[\s,;:.\-–—]+$'), '')}…';
}

const int kMaxTitleLength = 60;
const int kMaxDescriptionLength = 158;

String title60(String text) => truncate(text, kMaxTitleLength);
String description158(String text) => truncate(text, kMaxDescriptionLength);

String pluralize(int count, String singular, [String? plural]) => count == 1 ? singular : (plural ?? '${singular}s');
