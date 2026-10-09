import '../models/product.dart';
import '../models/review.dart';
import '../models/variant_group.dart';

/// Turns decoded JSON into the domain [Product].
///
/// The remote shape and the domain shape are allowed to differ (here `image`
/// becomes `imageAsset`, `blurb` becomes `description` and `variants` becomes
/// `variantGroups`); this is the one place that knows how. Optional fields
/// fall back to sensible defaults, so a thinner backend still works.
abstract final class ProductMapper {
  /// Maps [json] to a [Product].
  static Product fromJson(Map<String, Object?> json) => Product(
    id: json['id']! as String,
    name: json['name']! as String,
    category: json['category']! as String,
    price: (json['price']! as num).toDouble(),
    compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
    rating: (json['rating']! as num).toDouble(),
    ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    imageAsset: json['image']! as String,
    description: json['blurb']! as String,
    isNew: json['isNew'] as bool? ?? false,
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    details: ((json['details'] as List<Object?>?) ?? const <Object?>[])
        .cast<String>(),
    variantGroups: ((json['variants'] as List<Object?>?) ?? const <Object?>[])
        .cast<Map<String, Object?>>()
        .map(variantFromJson)
        .toList(),
    reviews: ((json['reviews'] as List<Object?>?) ?? const <Object?>[])
        .cast<Map<String, Object?>>()
        .map(reviewFromJson)
        .toList(),
  );

  /// Maps one entry of `variants`.
  static VariantGroup variantFromJson(Map<String, Object?> json) =>
      VariantGroup(
        label: json['label']! as String,
        values: (json['values']! as List<Object?>).cast<String>(),
      );

  /// Maps one entry of `reviews`. `date` is an ISO-8601 string.
  static Review reviewFromJson(Map<String, Object?> json) => Review(
    author: json['author']! as String,
    rating: (json['rating']! as num).toDouble(),
    text: json['text']! as String,
    date: DateTime.parse(json['date']! as String),
  );
}
