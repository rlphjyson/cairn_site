import 'product_categories.dart';

/// One slide of the storefront's promotional carousel.
class PromoSlide {
  /// Creates a slide.
  const PromoSlide({
    required this.tag,
    required this.title,
    required this.action,
    required this.asset,
    required this.category,
  });

  /// The small badge above the title.
  final String tag;

  /// The headline.
  final String title;

  /// The button label.
  final String action;

  /// Bundled image path.
  final String asset;

  /// The category the button opens.
  final String category;
}

/// The carousel's slides, in order.
abstract final class PromoSlides {
  /// Every slide.
  static const List<PromoSlide> values = <PromoSlide>[
    PromoSlide(
      tag: 'New season',
      title: 'Up to 30% off\nsneakers',
      action: 'Shop shoes',
      asset: 'assets/images/sneaker-lineup.jpg',
      category: 'Shoes',
    ),
    PromoSlide(
      tag: 'Code CAIRN10',
      title: '10% off your\nnext listen',
      action: 'Shop audio',
      asset: 'assets/images/headphones-black.jpg',
      category: 'Audio',
    ),
    PromoSlide(
      tag: 'Just in',
      title: 'Bags built for\nthe weekend',
      action: 'Shop bags',
      asset: 'assets/images/bag-duffel.jpg',
      category: 'Bags',
    ),
  ];

  /// The category a slide opens when none applies.
  static const String fallback = ProductCategories.all;
}
