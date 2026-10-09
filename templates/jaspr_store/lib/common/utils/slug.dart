/// URL slug helpers.
library;

final RegExp _nonSlug = RegExp(r'[^a-z0-9]+');
final RegExp _slugShape = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

/// `"Stride Knit — Sneaker!"` -> `stride-knit-sneaker`.
String slugify(String input) {
  final lower = input.toLowerCase();
  final slug = lower.replaceAll(_nonSlug, '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return slug;
}

/// Whether [value] is already a canonical slug. Used to reject junk before it
/// reaches a repository lookup.
bool isValidSlug(String value) => value.length <= 120 && _slugShape.hasMatch(value);
