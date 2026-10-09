import '../../../common/constants/blog_config.dart';
import '../../../common/utils/format.dart';
import '../../authors/models/author.dart';
import '../models/content_block.dart';
import '../models/post.dart';
import 'content_block_mapper.dart';

/// Remote JSON -> [Post].
///
/// A post references its author by id; [fromJson] resolves it against
/// `authors`. The reading time is computed from the body unless the JSON
/// carries `readingMinutes`.
abstract final class PostMapper {
  /// Maps one post. Throws [FormatException] if a field is missing or the
  /// author is unknown.
  static Post fromJson(Map<String, Object?> json, Map<String, Author> authors) {
    final String authorId = _string(json, 'author');
    final Author? author = authors[authorId];
    if (author == null) {
      throw FormatException('Unknown author "$authorId"', json);
    }
    final Object? rawBody = json['body'];
    if (rawBody is! List<Object?>) {
      throw FormatException('Post is missing "body"', json);
    }
    final List<ContentBlock> body = <ContentBlock>[
      for (final Object? b in rawBody)
        ContentBlockMapper.fromJson((b! as Map<Object?, Object?>).cast()),
    ];
    final Object? rawTags = json['tags'];
    final Object? minutes = json['readingMinutes'];

    return Post(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      excerpt: _string(json, 'excerpt'),
      category: _string(json, 'category'),
      tags: rawTags is List<Object?>
          ? <String>[for (final Object? t in rawTags) '$t']
          : const <String>[],
      author: author,
      publishedAt: DateTime.parse(_string(json, 'publishedAt')),
      cover: _string(json, 'cover'),
      coverAlt: json['coverAlt'] as String? ?? _string(json, 'title'),
      body: body,
      readingMinutes: minutes is int && minutes > 0
          ? minutes
          : readingMinutes(body),
      featured: json['featured'] == true,
    );
  }

  /// Minutes needed to read [body], at least 1.
  static int readingMinutes(List<ContentBlock> body) {
    final int words = body.fold<int>(
      0,
      (int sum, ContentBlock b) => sum + wordCount(b.plainText),
    );
    final int minutes = (words / BlogConfig.wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  static String _string(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Post is missing "$key"', json);
  }
}
