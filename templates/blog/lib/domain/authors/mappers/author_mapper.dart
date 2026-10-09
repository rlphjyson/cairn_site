import '../models/author.dart';

/// Remote JSON -> [Author].
abstract final class AuthorMapper {
  /// Maps one author object. Throws [FormatException] if a field is missing.
  static Author fromJson(Map<String, Object?> json) => Author(
    id: _string(json, 'id'),
    name: _string(json, 'name'),
    role: _string(json, 'role'),
    bio: _string(json, 'bio'),
    avatar: _string(json, 'avatar'),
  );

  static String _string(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Author is missing "$key"', json);
  }
}
