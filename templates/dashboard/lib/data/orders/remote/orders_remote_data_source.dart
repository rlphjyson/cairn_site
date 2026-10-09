/// Reads orders as decoded JSON.
abstract interface class OrdersRemoteDataSource {
  /// Every order, newest first.
  Future<List<Map<String, Object?>>> fetchOrders();
}

/// A fixed set of demo orders.
class InMemoryOrdersRemoteDataSource implements OrdersRemoteDataSource {
  /// Creates the data source.
  const InMemoryOrdersRemoteDataSource();

  static const List<(String, String)> _people = <(String, String)>[
    ('Olivia Martin', 'olivia.martin@example.com'),
    ('Jackson Lee', 'jackson.lee@example.com'),
    ('Isabella Nguyen', 'isabella.nguyen@example.com'),
    ('William Kim', 'will@example.com'),
    ('Sofia Davis', 'sofia.davis@example.com'),
    ('Liam Johnson', 'liam@example.com'),
    ('Emma Brown', 'emma.brown@example.com'),
    ('Noah Wilson', 'noah.wilson@example.com'),
  ];
  static const List<String> _statuses = <String>[
    'paid',
    'paid',
    'pending',
    'paid',
    'failed',
    'paid',
    'refunded',
    'paid',
  ];
  static const List<double> _amounts = <double>[
    250,
    129,
    89.5,
    399,
    42,
    175,
    64.9,
    320,
  ];

  @override
  Future<List<Map<String, Object?>>> fetchOrders() async {
    final DateTime newest = DateTime(2026, 10, 9);
    return <Map<String, Object?>>[
      for (int i = 0; i < 24; i++)
        <String, Object?>{
          'id': '#${3248 - i}',
          'customer': _people[i % _people.length].$1,
          'email': _people[i % _people.length].$2,
          'status': _statuses[(i * 3) % _statuses.length],
          'amount': _amounts[(i * 5) % _amounts.length],
          'date': newest.subtract(Duration(days: i ~/ 2)).toIso8601String(),
        },
    ];
  }
}
