import '../models/storage_usage.dart';

/// Turns the storage JSON into models.
///
/// ```json
/// { "capacity": 5368709120,
///   "categories": [ { "id": "media", "label": "Photos and media", "bytes": 912261120 } ] }
/// ```
abstract final class StorageMapper {
  /// The usage in [json].
  static StorageUsage usageFromJson(Map<String, Object?> json) {
    final Object? raw = json['categories'];
    return StorageUsage(
      capacityBytes: (json['capacity'] as num?)?.toInt() ?? 0,
      categories: <StorageCategory>[
        if (raw is List<Object?>)
          for (final Object? e in raw)
            if (e is Map<String, Object?>)
              StorageCategory(
                id: e['id'] as String? ?? '',
                label: e['label'] as String? ?? '',
                bytes: (e['bytes'] as num?)?.toInt() ?? 0,
              ),
      ],
    );
  }

  /// The bytes reclaimed in `{ "ok": true, "reclaimed": 88080384 }`.
  static int reclaimedFromJson(Map<String, Object?> json) =>
      (json['reclaimed'] as num?)?.toInt() ?? 0;
}
