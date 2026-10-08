import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/product_categories.dart';

/// A horizontally scrolling row of category filters.
class CategoryChips extends StatelessWidget {
  /// Creates the row.
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// The active category.
  final String selected;

  /// Called with the tapped category.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      spacing: 8,
      children: <Widget>[
        for (final String c in ProductCategories.values)
          CairnButton(
            size: CairnButtonSize.sm,
            variant: c == selected
                ? CairnButtonVariant.primary
                : CairnButtonVariant.outline,
            onPressed: () => onSelected(c),
            child: Text(c),
          ),
      ],
    ),
  );
}
