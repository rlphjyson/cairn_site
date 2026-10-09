import '../models/post.dart';

/// The distinct categories of [posts], most used first, then alphabetical.
class GetCategories {
  /// Creates the use case.
  const GetCategories();

  /// Runs it.
  List<String> call(List<Post> posts) {
    final Map<String, int> counts = <String, int>{};
    for (final Post p in posts) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }
    final List<String> names = counts.keys.toList()
      ..sort((String a, String b) {
        final int byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });
    return names;
  }
}
