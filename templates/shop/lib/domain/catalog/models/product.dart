import 'package:equatable/equatable.dart';

import 'review.dart';
import 'variant_group.dart';

/// Something for sale.
class Product extends Equatable {
  /// Creates a product.
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.ratingCount,
    required this.imageAsset,
    required this.description,
    this.compareAtPrice,
    this.isNew = false,
    this.stock = 20,
    this.details = const <String>[],
    this.variantGroups = const <VariantGroup>[],
    this.reviews = const <Review>[],
  });

  /// Stable key used by the cart and the saved list.
  final String id;

  /// Display name.
  final String name;

  /// One of the categories in `ProductCategories`, other than `all`.
  final String category;

  /// Unit price in dollars.
  final double price;

  /// The price before a markdown, or `null` when the product is not on sale.
  final double? compareAtPrice;

  /// Average rating out of five.
  final double rating;

  /// How many ratings it averages.
  final int ratingCount;

  /// Bundled asset path of the photograph.
  final String imageAsset;

  /// A sentence or two for the product page.
  final String description;

  /// Whether to flag it as a new arrival.
  final bool isNew;

  /// Units available.
  final int stock;

  /// Bullet points for the Details section.
  final List<String> details;

  /// The choices to make before buying. May be empty.
  final List<VariantGroup> variantGroups;

  /// Some of the written reviews, newest first.
  final List<Review> reviews;

  /// Whether it is marked down.
  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;

  /// The markdown as a whole percent, or 0 when not on sale.
  int get discountPercent =>
      isOnSale ? ((1 - price / compareAtPrice!) * 100).round() : 0;

  /// Whether any units are left.
  bool get inStock => stock > 0;

  /// Whether stock is low enough to warn about.
  bool get isLowStock => stock > 0 && stock <= 5;

  /// The first value of every group, keyed by the group's label.
  Map<String, String> get defaultSelection => <String, String>{
    for (final VariantGroup g in variantGroups) g.label: g.values.first,
  };

  /// A short, stable description of [selection], e.g. `42 / Black`.
  ///
  /// Empty when the product has no variants. This is what the cart stores.
  String variantLabel(Map<String, String> selection) => <String>[
    for (final VariantGroup g in variantGroups)
      selection[g.label] ?? g.values.first,
  ].join(' / ');

  @override
  List<Object?> get props => <Object?>[id];
}
