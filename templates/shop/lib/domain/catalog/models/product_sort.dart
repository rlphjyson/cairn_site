/// How the storefront orders products.
enum ProductSort {
  /// Most-rated first.
  popular('Popular'),

  /// Cheapest first.
  priceLowHigh('Price: low to high'),

  /// Dearest first.
  priceHighLow('Price: high to low'),

  /// Best-rated first.
  topRated('Top rated');

  const ProductSort(this.label);

  /// The label shown in the sort control.
  final String label;
}
