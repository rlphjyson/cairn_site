/// A decoded JSON object.
typedef JsonMap = Map<String, Object?>;

/// Typed reads over a decoded JSON object, used by the mappers.
///
/// A missing or mistyped required key throws a [FormatException] that names
/// the key, so a typo in the content fails loudly instead of rendering blank.
extension JsonReader on JsonMap {
  /// A required string.
  String string(String key) {
    final Object? v = this[key];
    if (v is String) return v;
    throw FormatException('Expected a string at "$key", got $v');
  }

  /// An optional string.
  String? maybeString(String key) {
    final Object? v = this[key];
    return v is String ? v : null;
  }

  /// A required number.
  double number(String key) {
    final Object? v = this[key];
    if (v is num) return v.toDouble();
    throw FormatException('Expected a number at "$key", got $v');
  }

  /// An optional number.
  double? maybeNumber(String key) {
    final Object? v = this[key];
    return v is num ? v.toDouble() : null;
  }

  /// An optional boolean, `false` when absent.
  bool flag(String key) => this[key] == true;

  /// A required nested object.
  JsonMap object(String key) {
    final Object? v = this[key];
    if (v is Map) return v.cast<String, Object?>();
    throw FormatException('Expected an object at "$key", got $v');
  }

  /// A required list of objects.
  List<JsonMap> objects(String key) {
    final Object? v = this[key];
    if (v is List) {
      return <JsonMap>[for (final Object? e in v) (e! as Map).cast()];
    }
    throw FormatException('Expected a list at "$key", got $v');
  }

  /// A list of objects, empty when absent.
  List<JsonMap> maybeObjects(String key) =>
      this[key] == null ? const <JsonMap>[] : objects(key);

  /// A list of strings, empty when absent.
  List<String> strings(String key) {
    final Object? v = this[key];
    if (v == null) return const <String>[];
    if (v is List) return <String>[for (final Object? e in v) e! as String];
    throw FormatException('Expected a list of strings at "$key", got $v');
  }
}
