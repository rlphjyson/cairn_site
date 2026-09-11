import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../app/site_theme.dart';
import '../data/variant_sample.dart';

/// Makes one rendered instance selectable without taking its interactivity
/// away.
///
/// The subtle part is the gesture wiring. A [GestureDetector] here would enter
/// the arena and fight every component it wraps — a Slider drag, a Carousel
/// swipe, a Tabs tap would all have to win against it. A [Listener] does not
/// compete: it observes the raw pointer stream on its way down, so the wrapped
/// widget keeps behaving exactly as it does anywhere else while selection still
/// registers on the first pointer-down.
///
/// The treatments are Cairn's own: [SiteColors.hoverTint] for hover, and a real
/// ring in `theme.ring` at `theme.radiusScale.md` for the active variant, so
/// the interaction reads as part of the same language as the components inside
/// it.
class ClickableVariant extends StatefulWidget {
  /// Wraps [sample]'s child.
  const ClickableVariant({
    super.key,
    required this.sample,
    required this.selected,
    required this.onSelected,
  });

  /// Padding between the ring and the wrapped widget.
  static const double gap = CairnSpacing.s1p5;

  /// The ring's thickness. Always painted — transparent when unselected — so
  /// selecting a variant never shifts the layout.
  static const double ringWidth = 2.0;

  /// How much larger the clickable box is than the widget it wraps, per side.
  static const double inset = gap + ringWidth;

  /// The instance being wrapped.
  final VariantSample sample;

  /// Whether this is the variant whose code is showing.
  final bool selected;

  /// Called on pointer-down anywhere in the box.
  final VoidCallback onSelected;

  @override
  State<ClickableVariant> createState() => _ClickableVariantState();
}

class _ClickableVariantState extends State<ClickableVariant> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    const Color transparent = Color(0x00000000);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (PointerEnterEvent _) => setState(() => _hovered = true),
      onExit: (PointerExitEvent _) => setState(() => _hovered = false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (PointerDownEvent _) => widget.onSelected(),
        child: AnimatedContainer(
          duration: CairnMotion.d150,
          curve: CairnMotion.standard,
          padding: const EdgeInsets.all(ClickableVariant.gap),
          decoration: BoxDecoration(
            color: widget.selected || _hovered ? theme.hoverTint : transparent,
            border: Border.all(
              color: widget.selected ? theme.ring : transparent,
              width: ClickableVariant.ringWidth,
            ),
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
          ),
          child: widget.sample.child,
        ),
      ),
    );
  }
}

/// Lays a [VariantSet] out, interactively or not.
///
/// Interactive when [onSelected] is non-null — the detail pages. The catalogue
/// grid passes null and gets exactly the tree the preview used to return, with
/// no wrappers, no insets and no hit-test changes, because a 190px card scaled
/// down by a `FittedBox` is not somewhere a selection ring earns its keep.
class VariantSetView extends StatelessWidget {
  /// Renders [set].
  const VariantSetView({
    super.key,
    required this.set,
    this.selectedIndex,
    this.onSelected,
  });

  /// What to render.
  final VariantSet set;

  /// The index, in [VariantSet.samples] order, currently showing its code.
  final int? selectedIndex;

  /// Reports a new selection. Null renders the set read-only.
  final ValueChanged<int>? onSelected;

  bool get _interactive => onSelected != null;

  @override
  Widget build(BuildContext context) {
    int index = 0;
    final List<Widget> rows = <Widget>[];

    for (final VariantGroup group in set.groups) {
      final List<Widget> children = <Widget>[];
      for (final VariantSample sample in group.samples) {
        children.add(_slot(sample, index));
        index++;
      }
      rows.add(_arrange(group, children));
    }

    final Widget body = rows.length == 1
        ? rows.single
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _gap(set.groupSpacing),
            children: rows,
          );

    if (set.width == null) return body;
    return SizedBox(width: set.width, child: body);
  }

  Widget _slot(VariantSample sample, int index) {
    if (!_interactive) return sample.child;
    return ClickableVariant(
      sample: sample,
      selected: index == selectedIndex,
      onSelected: () => onSelected!(index),
    );
  }

  /// Shrinks a declared gap by the inset the selection affordance adds, so the
  /// distance between the rendered widgets stays close to what it was.
  double _gap(double declared) {
    if (!_interactive) return declared;
    final double reduced = declared - ClickableVariant.inset * 2;
    return reduced < 0 ? 0 : reduced;
  }

  Widget _arrange(VariantGroup group, List<Widget> children) {
    final double spacing = _gap(group.spacing);
    switch (group.layout) {
      case VariantLayout.wrap:
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        );
      case VariantLayout.column:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: group.crossAxisAlignment,
          spacing: spacing,
          children: children,
        );
      case VariantLayout.row:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: group.crossAxisAlignment,
          spacing: spacing,
          children: children,
        );
    }
  }
}
