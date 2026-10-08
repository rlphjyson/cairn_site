import 'package:equatable/equatable.dart';

/// Something for sale.
class Product extends Equatable {
  /// Creates a product.
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imageAsset,
    required this.description,
    required this.optionLabel,
    required this.options,
  });

  /// Stable key used by the cart and the saved list.
  final String id;

  /// Display name.
  final String name;

  /// One of the categories in `ProductCategories`, other than `all`.
  final String category;

  /// Unit price in dollars.
  final double price;

  /// Average rating out of five.
  final double rating;

  /// How many ratings it averages.
  final int reviews;

  /// Bundled asset path of the photograph.
  final String imageAsset;

  /// A sentence or two for the product page.
  final String description;

  /// What [options] choose between, e.g. `Size`.
  final String optionLabel;

  /// The selectable variants. Never empty.
  final List<String> options;

  @override
  List<Object?> get props => <Object?>[id];
}
