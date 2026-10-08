/// Reads the catalogue as decoded JSON, exactly as a REST client would.
abstract interface class ProductRemoteDataSource {
  /// Every product model.
  Future<List<Map<String, Object?>>> fetchProducts();
}

/// A bundled catalogue. Photographs are from Pexels, used under the Pexels
/// licence.
class InMemoryProductRemoteDataSource implements ProductRemoteDataSource {
  /// Creates the data source.
  const InMemoryProductRemoteDataSource();

  @override
  Future<List<Map<String, Object?>>> fetchProducts() async => _products;

  static const List<Map<String, Object?>> _products = <Map<String, Object?>>[
    <String, Object?>{
      'id': 'court-low',
      'name': 'Court Low Sneaker',
      'category': 'Shoes',
      'price': 89,
      'rating': 4.5,
      'reviews': 214,
      'image': 'assets/images/sneaker-red.jpg',
      'blurb':
          'A clean leather low-top with a soft collar and a rubber cupsole '
          'that wears in rather than out.',
      'optionLabel': 'Size',
      'options': <String>['40', '41', '42', '43', '44'],
    },
    <String, Object?>{
      'id': 'street-low',
      'name': 'Street Low Sneaker',
      'category': 'Shoes',
      'price': 120,
      'rating': 4.0,
      'reviews': 98,
      'image': 'assets/images/sneaker-nike.jpg',
      'blurb':
          'Panelled suede and leather in a skate-shop colourway, with a '
          'padded tongue built for long days.',
      'optionLabel': 'Size',
      'options': <String>['40', '41', '42', '43', '44'],
    },
    <String, Object?>{
      'id': 'classic-white',
      'name': 'Classic White Low',
      'category': 'Shoes',
      'price': 95,
      'rating': 5.0,
      'reviews': 531,
      'image': 'assets/images/sneaker-box.jpg',
      'blurb':
          'The all-white leather sneaker that goes with everything. Ships in '
          'a recycled box with spare laces.',
      'optionLabel': 'Size',
      'options': <String>['40', '41', '42', '43', '44'],
    },
    <String, Object?>{
      'id': 'studio-air',
      'name': 'Studio Air Headphones',
      'category': 'Audio',
      'price': 129,
      'rating': 4.0,
      'reviews': 187,
      'image': 'assets/images/headphones-white.jpg',
      'blurb':
          'Lightweight on-ear Bluetooth headphones with thirty hours of '
          'battery and a fold-flat hinge.',
      'optionLabel': 'Bundle',
      'options': <String>['Headphones', 'With case'],
    },
    <String, Object?>{
      'id': 'monitor-pro',
      'name': 'Monitor Pro Over-ear',
      'category': 'Audio',
      'price': 249,
      'rating': 4.5,
      'reviews': 342,
      'image': 'assets/images/headphones-black.jpg',
      'blurb':
          'Closed-back studio monitors tuned flat, with a detachable cable '
          'and replaceable ear pads.',
      'optionLabel': 'Cable',
      'options': <String>['Straight', 'Coiled'],
    },
    <String, Object?>{
      'id': 'chrono-rose',
      'name': 'Chrono Rose Watch',
      'category': 'Watches',
      'price': 199,
      'rating': 4.5,
      'reviews': 76,
      'image': 'assets/images/watch-classic.jpg',
      'blurb':
          'A stainless chronograph with rose-gold accents and a 100m water '
          'rating. Heavier than it looks.',
      'optionLabel': 'Case',
      'options': <String>['42mm', '45mm'],
    },
    <String, Object?>{
      'id': 'wheel-dial',
      'name': 'Wheel Dial Watch',
      'category': 'Watches',
      'price': 159,
      'rating': 4.0,
      'reviews': 63,
      'image': 'assets/images/watch-sport.jpg',
      'blurb':
          'A skeleton dial styled after a performance wheel, on a leather '
          'strap that softens fast.',
      'optionLabel': 'Strap',
      'options': <String>['Black', 'Tan'],
    },
    <String, Object?>{
      'id': 'round-frames',
      'name': 'Round Frame Set',
      'category': 'Eyewear',
      'price': 79,
      'rating': 5.0,
      'reviews': 129,
      'image': 'assets/images/sunglasses-bag.jpg',
      'blurb':
          'Three metal-rimmed frames: tinted, tortoiseshell and clear. UV400 '
          'lenses throughout.',
      'optionLabel': 'Frame',
      'options': <String>['Rose', 'Tortoise', 'Clear'],
    },
  ];
}
