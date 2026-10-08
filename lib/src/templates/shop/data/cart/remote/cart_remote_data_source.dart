/// Stores cart quantities by product id.
abstract interface class CartRemoteDataSource {
  /// Reads the quantities, in insertion order.
  Map<String, int> read();

  /// Replaces the quantities.
  void write(Map<String, int> quantities);
}

/// Keeps the cart in memory for the life of the template.
class InMemoryCartRemoteDataSource implements CartRemoteDataSource {
  Map<String, int> _quantities = <String, int>{};

  @override
  Map<String, int> read() => <String, int>{..._quantities};

  @override
  void write(Map<String, int> quantities) =>
      _quantities = <String, int>{...quantities};
}
