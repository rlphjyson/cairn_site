import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/catalog/models/product_sort.dart';

/// The sort-order dropdown.
class SortSelect extends StatelessWidget {
  /// Creates the control.
  const SortSelect({super.key, required this.value, required this.onChanged});

  /// The current order.
  final ProductSort value;

  /// Called with the chosen order.
  final ValueChanged<ProductSort> onChanged;

  @override
  Widget build(BuildContext context) => CairnSelect<ProductSort>(
    size: CairnSelectSize.sm,
    width: 176,
    semanticLabel: 'Sort products',
    value: value,
    onChanged: onChanged,
    options: <CairnSelectOption<ProductSort>>[
      for (final ProductSort s in ProductSort.values)
        CairnSelectOption<ProductSort>(value: s, label: s.label),
    ],
  );
}
