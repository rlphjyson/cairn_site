/// Stores the cart as decoded JSON.
///
/// The shape is `{'lines': [{'productId', 'variant', 'quantity'}],
/// 'promoCode': String?}`; see `CartMapper`.
abstract interface class CartRemoteDataSource {
  /// Reads the stored cart.
  Map<String, Object?> read();

  /// Replaces the stored cart.
  void write(Map<String, Object?> cart);
}

/// Keeps the cart in memory for the life of the template.
class InMemoryCartRemoteDataSource implements CartRemoteDataSource {
  Map<String, Object?> _cart = <String, Object?>{
    'lines': <Map<String, Object?>>[],
    'promoCode': null,
  };

  @override
  Map<String, Object?> read() => <String, Object?>{
    'lines': <Map<String, Object?>>[
      for (final Map<String, Object?> l
          in (_cart['lines']! as List<Object?>).cast<Map<String, Object?>>())
        <String, Object?>{...l},
    ],
    'promoCode': _cart['promoCode'],
  };

  @override
  void write(Map<String, Object?> cart) => _cart = cart;
}
