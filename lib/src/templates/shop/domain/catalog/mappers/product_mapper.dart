import '../models/product.dart';

/// Turns one decoded JSON product into the domain [Product].
///
/// The remote shape and the domain shape are allowed to differ (here `image`
/// becomes `imageAsset` and `blurb` becomes `description`); this is the one
/// place that knows how.
abstract final class ProductMapper {
  /// Maps [json] to a [Product].
  static Product fromJson(Map<String, Object?> json) => Product(
    id: json['id']! as String,
    name: json['name']! as String,
    category: json['category']! as String,
    price: (json['price']! as num).toDouble(),
    rating: (json['rating']! as num).toDouble(),
    reviews: json['reviews']! as int,
    imageAsset: json['image']! as String,
    description: json['blurb']! as String,
    optionLabel: json['optionLabel']! as String,
    options: (json['options']! as List<Object?>).cast<String>(),
  );
}
