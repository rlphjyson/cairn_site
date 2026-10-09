library;

import 'package:meta/meta.dart';

import '../../reviews/models/review.dart';

/// A responsive image that exists on disk as `<base>-350.webp`,
/// `<base>-700.webp` and a `<base>.jpg` fallback (see the docs for the
/// generation script). Width and height are the intrinsic size of the largest
/// file; they exist so the browser can reserve space and avoid layout shift.
@immutable
class ProductImage {
  const ProductImage({
    required this.base,
    required this.alt,
    this.width = 700,
    this.height = 700,
    this.folder = '/images/products',
    this.widths = const [350, 700],
  });

  final String base;
  final String alt;
  final int width;
  final int height;
  final String folder;
  final List<int> widths;

  String get fallbackUrl => '$folder/$base.jpg';
  String urlAt(int w) => '$folder/$base-$w.webp';
  String get srcset => widths.map((w) => '${urlAt(w)} ${w}w').join(', ');
}

@immutable
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.sku,
    required this.stock,
    this.priceCents,
  });

  final String id;

  /// Human label, e.g. `White / 42` or `Black`.
  final String label;
  final String sku;
  final int stock;

  /// Overrides the product price when set.
  final int? priceCents;

  bool get inStock => stock > 0;
  ProductVariant withStock(int value) =>
      ProductVariant(id: id, label: label, sku: sku, stock: value, priceCents: priceCents);
}

@immutable
class ProductDetail {
  const ProductDetail(this.title, this.body);
  final String title;
  final String body;
}

@immutable
class Category {
  const Category({
    required this.slug,
    required this.name,
    required this.description,
    required this.image,
    this.headline,
  });

  final String slug;
  final String name;
  final String description;
  final ProductImage image;
  final String? headline;
}

enum Availability {
  inStock('https://schema.org/InStock', 'In stock'),
  lowStock('https://schema.org/LimitedAvailability', 'Low stock'),
  outOfStock('https://schema.org/OutOfStock', 'Sold out');

  const Availability(this.schemaUrl, this.label);
  final String schemaUrl;
  final String label;
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.brand,
    required this.categorySlug,
    required this.summary,
    required this.description,
    required this.priceCents,
    required this.sku,
    required this.gtin,
    required this.images,
    required this.variants,
    required this.createdAt,
    required this.updatedAt,
    this.variantLabel = 'Option',
    this.compareAtCents,
    this.details = const [],
    this.tags = const [],
    this.featured = false,
    this.previousSlugs = const [],
    this.rating = RatingSummary.empty,
  });

  final String id;
  final String slug;
  final String name;
  final String brand;
  final String categorySlug;

  /// One or two sentences. Used for cards and as the meta-description seed.
  final String summary;

  /// Long-form paragraphs.
  final List<String> description;
  final int priceCents;
  final int? compareAtCents;
  final String sku;

  /// GTIN-13 / EAN style identifier (Google Merchant Center and `Product.gtin13`).
  final String gtin;
  final List<ProductImage> images;
  final List<ProductVariant> variants;

  /// `Size`, `Colour`, ... shown above the variant picker.
  final String variantLabel;
  final List<ProductDetail> details;
  final List<String> tags;
  final bool featured;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Slugs this product used to live at. A request for one answers 301.
  final List<String> previousSlugs;
  final RatingSummary rating;

  ProductImage get primaryImage => images.first;
  int get totalStock => variants.fold(0, (sum, v) => sum + v.stock);
  bool get inStock => totalStock > 0;
  bool get onSale => compareAtCents != null && compareAtCents! > priceCents;

  /// `schema.org` availability. "Low" means the whole product is nearly gone.
  Availability get availability => totalStock <= 0
      ? Availability.outOfStock
      : totalStock <= 5
      ? Availability.lowStock
      : Availability.inStock;

  ProductVariant? variantById(String id) {
    for (final v in variants) {
      if (v.id == id) return v;
    }
    return null;
  }

  ProductVariant get defaultVariant => variants.firstWhere((v) => v.inStock, orElse: () => variants.first);

  int priceFor(ProductVariant variant) => variant.priceCents ?? priceCents;

  Product copyWith({List<ProductVariant>? variants, RatingSummary? rating}) => Product(
    id: id,
    slug: slug,
    name: name,
    brand: brand,
    categorySlug: categorySlug,
    summary: summary,
    description: description,
    priceCents: priceCents,
    compareAtCents: compareAtCents,
    sku: sku,
    gtin: gtin,
    images: images,
    variants: variants ?? this.variants,
    variantLabel: variantLabel,
    details: details,
    tags: tags,
    featured: featured,
    createdAt: createdAt,
    updatedAt: updatedAt,
    previousSlugs: previousSlugs,
    rating: rating ?? this.rating,
  );
}
