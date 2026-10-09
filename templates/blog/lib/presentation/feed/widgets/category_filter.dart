import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// The category chips: "All" plus one per category.
///
/// Each chip is a [CairnButton], so it is focusable, shows the focus ring and
/// activates on Enter and Space. The selected chip is filled.
class CategoryFilter extends StatelessWidget {
  /// Creates the filter.
  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  /// The category names.
  final List<String> categories;

  /// The active one, or `null` for "All".
  final String? selected;

  /// Called with a category, or `null` for "All".
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String? value) {
      final bool active = selected == value;
      return Semantics(
        selected: active,
        child: CairnButton(
          size: CairnButtonSize.sm,
          variant: active
              ? CairnButtonVariant.primary
              : CairnButtonVariant.outline,
          semanticLabel: active ? '$label, selected' : 'Filter by $label',
          onPressed: () => onSelected(value),
          child: Text(label),
        ),
      );
    }

    return Wrap(
      spacing: CairnSpacing.s2,
      runSpacing: CairnSpacing.s2,
      children: <Widget>[
        chip('All', null),
        for (final String c in categories) chip(c, c),
      ],
    );
  }
}
