/// The storefront's filter chips.
///
/// Static catalogue data lives here rather than inline in a view, so a screen
/// never needs to know what the options are, only how to render them.
abstract final class ProductCategories {
  /// The "show everything" chip.
  static const String all = 'All';

  /// Every chip, in display order.
  static const List<String> values = <String>[
    all,
    'Shoes',
    'Audio',
    'Watches',
    'Eyewear',
    'Bags',
  ];
}
