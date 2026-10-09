/// Reads the catalogue as decoded JSON, exactly as a REST client would.
abstract interface class ProductRemoteDataSource {
  /// Every product as a JSON object. See `ProductMapper` for the fields.
  Future<List<Map<String, Object?>>> fetchProducts();
}

/// A bundled catalogue. Photographs are from Pexels, used under the Pexels
/// licence (see `NOTICE.md`).
///
/// [latency] simulates a network round trip so the storefront's skeletons are
/// visible; it is skipped entirely when zero, which keeps tests free of timers.
class InMemoryProductRemoteDataSource implements ProductRemoteDataSource {
  /// Creates the data source.
  const InMemoryProductRemoteDataSource({this.latency = Duration.zero});

  /// How long [fetchProducts] takes.
  final Duration latency;

  @override
  Future<List<Map<String, Object?>>> fetchProducts() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return _products;
  }

  static Map<String, Object?> _review(
    String author,
    num rating,
    String text,
    String date,
  ) => <String, Object?>{
    'author': author,
    'rating': rating,
    'text': text,
    'date': date,
  };

  static Map<String, Object?> _variant(String label, List<String> values) =>
      <String, Object?>{'label': label, 'values': values};

  static const List<String> _shoeSizes = <String>['40', '41', '42', '43', '44'];

  static final List<Map<String, Object?>> _products = <Map<String, Object?>>[
    <String, Object?>{
      'id': 'court-low',
      'name': 'Court Low Sneaker',
      'category': 'Shoes',
      'price': 89,
      'compareAtPrice': 119,
      'rating': 4.5,
      'ratingCount': 214,
      'image': 'assets/images/sneaker-lineup.jpg',
      'isNew': false,
      'stock': 24,
      'blurb':
          'A clean leather low-top with a soft collar and a rubber cupsole '
          'that wears in rather than out.',
      'details': <String>[
        'Full-grain leather upper',
        'Vulcanised rubber cupsole',
        'Cushioned removable insole',
        'Runs true to size',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Size', _shoeSizes),
        _variant('Colour', <String>['Red', 'Cream']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Maya R.',
          5,
          'Comfortable from the first wear and the red is a proper red.',
          '2026-09-18',
        ),
        _review(
          'Tom H.',
          4,
          'Great leather for the price. Size up if you wear thick socks.',
          '2026-08-30',
        ),
        _review(
          'Priya N.',
          5,
          'My daily pair. Wiped clean after a rainy week, still looks new.',
          '2026-07-11',
        ),
      ],
    },
    <String, Object?>{
      'id': 'street-low',
      'name': 'Street Low Sneaker',
      'category': 'Shoes',
      'price': 120,
      'rating': 4.0,
      'ratingCount': 98,
      'image': 'assets/images/sneaker-black.jpg',
      'isNew': true,
      'stock': 3,
      'blurb':
          'Panelled suede and leather in a skate-shop colourway, with a '
          'padded tongue built for long days.',
      'details': <String>[
        'Suede and leather panels',
        'Padded tongue and collar',
        'Grippy gum outsole',
      ],
      'variants': <Map<String, Object?>>[_variant('Size', _shoeSizes)],
      'reviews': <Map<String, Object?>>[
        _review(
          'Jonas K.',
          4,
          'Grippy and stylish. The suede needs a protector spray.',
          '2026-10-02',
        ),
        _review(
          'Aisha B.',
          4,
          'Looks better in person. Slightly narrow through the toe.',
          '2026-09-25',
        ),
      ],
    },
    <String, Object?>{
      'id': 'classic-white',
      'name': 'Classic White Low',
      'category': 'Shoes',
      'price': 95,
      'rating': 5.0,
      'ratingCount': 531,
      'image': 'assets/images/sneaker-white.jpg',
      'isNew': false,
      'stock': 40,
      'blurb':
          'The all-white leather sneaker that goes with everything. Ships in '
          'a recycled box with spare laces.',
      'details': <String>[
        'Smooth white leather',
        'Spare laces in the box',
        'Recycled packaging',
        'Runs true to size',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Size', _shoeSizes),
        _variant('Laces', <String>['White', 'Black']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Elena V.',
          5,
          'Exactly what I wanted. Goes with everything in my wardrobe.',
          '2026-10-05',
        ),
        _review(
          'Marcus L.',
          5,
          'Third pair I have bought. They just last.',
          '2026-09-14',
        ),
        _review(
          'Sofia D.',
          5,
          'The spare laces are a lovely touch.',
          '2026-08-02',
        ),
      ],
    },
    <String, Object?>{
      'id': 'cloud-runner',
      'name': 'Cloud Runner Trainer',
      'category': 'Shoes',
      'price': 74,
      'compareAtPrice': 99,
      'rating': 4.0,
      'ratingCount': 67,
      'image': 'assets/images/sneaker-white.jpg',
      'isNew': false,
      'stock': 15,
      'blurb':
          'A featherweight trainer with a springy foam midsole, made for '
          'errands that turn into long walks.',
      'details': <String>[
        'Breathable knit upper',
        'Responsive foam midsole',
        'Machine washable',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Size', _shoeSizes),
        _variant('Colour', <String>['White', 'Grey']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Dan P.',
          4,
          'Light and soft. Not for rain, but great for city days.',
          '2026-09-01',
        ),
        _review(
          'Lucia F.',
          4,
          'Very comfortable. The knit picks up dirt, but it washes out.',
          '2026-07-22',
        ),
      ],
    },
    <String, Object?>{
      'id': 'studio-air',
      'name': 'Studio Air Headphones',
      'category': 'Audio',
      'price': 129,
      'compareAtPrice': 159,
      'rating': 4.0,
      'ratingCount': 187,
      'image': 'assets/images/headphones-white.jpg',
      'isNew': false,
      'stock': 18,
      'blurb':
          'Lightweight on-ear Bluetooth headphones with thirty hours of '
          'battery and a fold-flat hinge.',
      'details': <String>[
        '30 hours of battery',
        'Bluetooth 5.3 with multipoint',
        'Fold-flat hinge',
        'USB-C fast charge',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Bundle', <String>['Headphones', 'With case']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Chris W.',
          4,
          'Battery is as good as promised. Bass is a little soft.',
          '2026-09-20',
        ),
        _review(
          'Hana S.',
          5,
          'So light I forget I am wearing them on long flights.',
          '2026-08-17',
        ),
        _review(
          'Omar J.',
          3,
          'Good for the price, but the pads could be thicker.',
          '2026-06-29',
        ),
      ],
    },
    <String, Object?>{
      'id': 'monitor-pro',
      'name': 'Pastel Studio Over-ear',
      'category': 'Audio',
      'price': 249,
      'rating': 4.5,
      'ratingCount': 342,
      'image': 'assets/images/headphones-black.jpg',
      'isNew': true,
      'stock': 12,
      'blurb':
          'Closed-back studio monitors tuned flat, with a detachable cable '
          'and replaceable ear pads.',
      'details': <String>[
        '40mm beryllium-coated drivers',
        'Detachable 3m cable, 3.5mm and 6.3mm',
        'Replaceable memory-foam pads',
        'Folds into the included pouch',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Cable', <String>['Straight', 'Coiled']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Ivan T.',
          5,
          'Flat and honest. I mix on these every day.',
          '2026-10-06',
        ),
        _review(
          'Grace O.',
          4,
          'Excellent isolation. A touch heavy after four hours.',
          '2026-09-09',
        ),
        _review(
          'Leo M.',
          5,
          'Replacing the pads took thirty seconds. Great design.',
          '2026-08-12',
        ),
      ],
    },
    <String, Object?>{
      'id': 'chrono-rose',
      'name': 'Slim Rose Watch',
      'category': 'Watches',
      'price': 199,
      'rating': 4.5,
      'ratingCount': 76,
      'image': 'assets/images/watch-classic.jpg',
      'isNew': false,
      'stock': 7,
      'blurb':
          'A stainless chronograph with rose-gold accents and a 100m water '
          'rating. Heavier than it looks.',
      'details': <String>[
        'Stainless steel case',
        'Sapphire-coated crystal',
        '100m water resistance',
        'Quartz chronograph movement',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Case', <String>['42mm', '45mm']),
        _variant('Strap', <String>['Steel', 'Leather']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Noah G.',
          5,
          'Looks far more expensive than it is.',
          '2026-09-28',
        ),
        _review(
          'Imani C.',
          4,
          'The 42mm is perfect on a smaller wrist.',
          '2026-08-08',
        ),
      ],
    },
    <String, Object?>{
      'id': 'wheel-dial',
      'name': 'Wheel Dial Watch',
      'category': 'Watches',
      'price': 159,
      'compareAtPrice': 189,
      'rating': 4.0,
      'ratingCount': 63,
      'image': 'assets/images/watch-sport.jpg',
      'isNew': false,
      'stock': 4,
      'blurb':
          'A skeleton dial styled after a performance wheel, on a leather '
          'strap that softens fast.',
      'details': <String>[
        'Skeleton dial',
        'Genuine leather strap',
        '50m water resistance',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Strap', <String>['Black', 'Tan']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Ben A.',
          4,
          'A real conversation starter. Strap breaks in within a week.',
          '2026-09-03',
        ),
        _review(
          'Yuki T.',
          4,
          'Love the dial. Wish the crown were a little easier to pull.',
          '2026-07-19',
        ),
        _review(
          'Rosa E.',
          5,
          'Bought it as a gift and it was a hit.',
          '2026-06-05',
        ),
      ],
    },
    <String, Object?>{
      'id': 'round-frames',
      'name': 'Round Frame Set',
      'category': 'Eyewear',
      'price': 79,
      'rating': 5.0,
      'ratingCount': 129,
      'image': 'assets/images/sunglasses-bag.jpg',
      'isNew': false,
      'stock': 33,
      'blurb':
          'Three metal-rimmed frames: tinted, tortoiseshell and clear. UV400 '
          'lenses throughout.',
      'details': <String>[
        'UV400 lenses',
        'Spring hinges',
        'Includes a hard case and cloth',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Frame', <String>['Rose', 'Tortoise', 'Clear']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Clara M.',
          5,
          'Light, sturdy and flattering. Fit my face first time.',
          '2026-09-12',
        ),
        _review(
          'Reza F.',
          5,
          'The tortoiseshell is gorgeous in the sun.',
          '2026-08-21',
        ),
        _review(
          'Alba R.',
          5,
          'Great quality for under a hundred.',
          '2026-07-03',
        ),
      ],
    },
    <String, Object?>{
      'id': 'aviator-duo',
      'name': 'Golden Hour Duo',
      'category': 'Eyewear',
      'price': 64,
      'compareAtPrice': 85,
      'rating': 4.5,
      'ratingCount': 52,
      'image': 'assets/images/sunglasses-bag.jpg',
      'isNew': true,
      'stock': 9,
      'blurb':
          'Two pairs of slim gold-wire sunglasses, one tinted brown and one '
          'smoke grey, for bright days and brighter evenings.',
      'details': <String>[
        'Gold-tone metal wire',
        'Polarised lenses',
        'Two pairs in one box',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Lens', <String>['Brown', 'Smoke']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Pia K.',
          5,
          'Two pairs for the price of one decent pair. Smart.',
          '2026-10-04',
        ),
        _review(
          'Sam D.',
          4,
          'Lenses are crisp. Wire is thin, so I treat them gently.',
          '2026-09-16',
        ),
      ],
    },
    <String, Object?>{
      'id': 'weekender-duffel',
      'name': 'Weekender Duffel',
      'category': 'Bags',
      'price': 149,
      'compareAtPrice': 189,
      'rating': 4.5,
      'ratingCount': 88,
      'image': 'assets/images/bag-duffel.jpg',
      'isNew': true,
      'stock': 11,
      'blurb':
          'A roomy leather duffel with a zip-top opening, a padded handle '
          'and a shoulder strap. Ages beautifully.',
      'details': <String>[
        'Vegetable-tanned leather',
        'Brass hardware and a YKK zip',
        'Fits under most airline seats',
        '28L capacity',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Colour', <String>['Chestnut', 'Espresso']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Victor L.',
          5,
          'Took it on three trips already. It is getting better looking.',
          '2026-10-01',
        ),
        _review(
          'Dina H.',
          4,
          'Smells wonderful and holds more than it looks.',
          '2026-09-07',
        ),
        _review('Kofi A.', 5, 'Solid build, comfortable strap.', '2026-08-14'),
      ],
    },
    <String, Object?>{
      'id': 'city-satchel',
      'name': 'City Satchel',
      'category': 'Bags',
      'price': 175,
      'rating': 4.5,
      'ratingCount': 41,
      'image': 'assets/images/bag-satchels.jpg',
      'isNew': false,
      'stock': 5,
      'blurb':
          'A structured leather satchel with a brass twist lock, sized for a '
          '14-inch laptop and a lunch.',
      'details': <String>[
        'Smooth full-grain leather',
        'Brass lock closure',
        'Padded 14-inch laptop sleeve',
        'Removable shoulder strap',
      ],
      'variants': <Map<String, Object?>>[
        _variant('Colour', <String>['Tan', 'Black']),
      ],
      'reviews': <Map<String, Object?>>[
        _review(
          'Nora S.',
          5,
          'Looks sharp in meetings and carries everything I need.',
          '2026-09-22',
        ),
        _review(
          'Hugo B.',
          4,
          'The lock is a little stiff at first, otherwise perfect.',
          '2026-08-05',
        ),
      ],
    },
  ];
}
