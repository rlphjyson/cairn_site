/// Joins [items] as natural prose: `a`, `a and b`, `a, b and c`.
String joinProse(List<String> items) {
  if (items.isEmpty) return '';
  if (items.length == 1) return items.first;
  return '${items.sublist(0, items.length - 1).join(', ')} and ${items.last}';
}
