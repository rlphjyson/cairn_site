import 'package:equatable/equatable.dart';

/// One slice of the device storage the app uses.
class StorageCategory extends Equatable {
  /// Creates a category.
  const StorageCategory({
    required this.id,
    required this.label,
    required this.bytes,
  });

  /// A stable id. `cache` is the one `ClearCache` empties.
  final String id;

  /// What the person reads.
  final String label;

  /// How much it uses.
  final int bytes;

  @override
  List<Object?> get props => <Object?>[id, label, bytes];
}

/// What the app stores on the device, by category.
class StorageUsage extends Equatable {
  /// Creates a usage report.
  const StorageUsage({required this.categories, required this.capacityBytes});

  /// The id of the category that can be cleared.
  static const String cacheId = 'cache';

  /// The slices, in the order they are drawn.
  final List<StorageCategory> categories;

  /// How much the app may use in total.
  final int capacityBytes;

  /// The bytes used across every category.
  int get usedBytes =>
      categories.fold(0, (int sum, StorageCategory c) => sum + c.bytes);

  /// The bytes left.
  int get freeBytes => (capacityBytes - usedBytes).clamp(0, capacityBytes);

  /// The bytes the cache holds.
  int get cacheBytes {
    for (final StorageCategory c in categories) {
      if (c.id == cacheId) return c.bytes;
    }
    return 0;
  }

  /// A copy with the cache emptied.
  StorageUsage withoutCache() => StorageUsage(
    capacityBytes: capacityBytes,
    categories: <StorageCategory>[
      for (final StorageCategory c in categories)
        if (c.id == cacheId)
          StorageCategory(id: c.id, label: c.label, bytes: 0)
        else
          c,
    ],
  );

  @override
  List<Object?> get props => <Object?>[categories, capacityBytes];
}
