import 'package:equatable/equatable.dart';

/// Every stored setting value at one moment, keyed by definition id.
///
/// The persisted shape is `{ "schema": 1, "values": { "<id>": <value> } }`; see
/// `SettingsMapper`. Values are `bool`, `String` or `int`, so the JSON is plain
/// and survives any storage.
class SettingsSnapshot extends Equatable {
  /// Creates a snapshot. [values] is copied.
  SettingsSnapshot(Map<String, Object?> values)
    : values = Map<String, Object?>.unmodifiable(values);

  /// The values.
  final Map<String, Object?> values;

  /// The toggle [id], or `false` when it is missing.
  bool flag(String id) => values[id] == true;

  /// The choice [id], or an empty string when it is missing.
  String choice(String id) {
    final Object? v = values[id];
    return v is String ? v : '';
  }

  /// The slider [id]'s step, or `0` when it is missing.
  int step(String id) {
    final Object? v = values[id];
    return v is int ? v : 0;
  }

  /// A copy with [id] set to [value].
  SettingsSnapshot set(String id, Object? value) =>
      SettingsSnapshot(<String, Object?>{...values, id: value});

  @override
  List<Object?> get props => <Object?>[values];
}
