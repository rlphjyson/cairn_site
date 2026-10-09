/// Stores and lists orders as decoded JSON.
///
/// The shape is described by `OrderMapper`.
abstract interface class OrderRemoteDataSource {
  /// Every order, newest first.
  Future<List<Map<String, Object?>>> fetchOrders();

  /// Stores a new order and returns it with its `id` and `status` added.
  Future<Map<String, Object?>> createOrder(Map<String, Object?> order);
}

/// Keeps orders in memory, seeded with two earlier ones so a returning
/// customer has a history.
class InMemoryOrderRemoteDataSource implements OrderRemoteDataSource {
  /// Creates the data source. New orders are numbered from [start].
  InMemoryOrderRemoteDataSource({int start = 2048}) : _next = start;

  int _next;

  static const Map<String, Object?> _ada = <String, Object?>{
    'fullName': 'Ada Lovelace',
    'email': 'ada@example.com',
    'phone': '+44 20 7946 0958',
    'address': '12 Analytical Row',
    'city': 'London',
    'postalCode': 'N1 9GU',
  };

  final List<Map<String, Object?>> _orders = <Map<String, Object?>>[
    <String, Object?>{
      'id': 'CR-2041',
      'status': 'shipped',
      'placedAt': '2026-10-05T10:12:00',
      'estimatedDelivery': '2026-10-12T00:00:00',
      'cardLast4': '4242',
      'promoCode': null,
      'shipping': _ada,
      'totals': <String, Object?>{
        'itemCount': 1,
        'subtotal': 159,
        'discount': 0,
        'shipping': 0,
        'delivery': 'standard',
      },
      'lines': <Map<String, Object?>>[
        <String, Object?>{
          'productId': 'wheel-dial',
          'variant': 'Tan',
          'quantity': 1,
        },
      ],
    },
    <String, Object?>{
      'id': 'CR-1987',
      'status': 'delivered',
      'placedAt': '2026-08-21T16:40:00',
      'estimatedDelivery': '2026-08-28T00:00:00',
      'cardLast4': '4242',
      'promoCode': 'CAIRN10',
      'shipping': _ada,
      'totals': <String, Object?>{
        'itemCount': 3,
        'subtotal': 253,
        'discount': 25.3,
        'shipping': 0,
        'delivery': 'standard',
      },
      'lines': <Map<String, Object?>>[
        <String, Object?>{
          'productId': 'classic-white',
          'variant': '41 / White',
          'quantity': 1,
        },
        <String, Object?>{
          'productId': 'round-frames',
          'variant': 'Tortoise',
          'quantity': 2,
        },
      ],
    },
  ];

  @override
  Future<List<Map<String, Object?>>> fetchOrders() async =>
      List<Map<String, Object?>>.of(_orders);

  @override
  Future<Map<String, Object?>> createOrder(Map<String, Object?> order) async {
    final Map<String, Object?> stored = <String, Object?>{
      ...order,
      'id': 'CR-${_next++}',
      'status': 'processing',
    };
    _orders.insert(0, stored);
    return stored;
  }
}
