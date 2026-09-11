import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import 'surfaces.dart';

/// One cell of a [BentoGrid].
@immutable
class BentoTile {
  /// Creates a tile.
  const BentoTile({
    required this.label,
    required this.child,
    this.span = 1,
    this.height = 220.0,
    this.caption,
    this.alignment = Alignment.center,
    // Top padding clears the absolutely-positioned corner label.
    this.padding = const EdgeInsets.fromLTRB(
      CairnSpacing.s6,
      CairnSpacing.s12,
      CairnSpacing.s6,
      CairnSpacing.s6,
    ),
    this.minContentWidth = 0.0,
  });

  /// The small label in the tile's top-left corner.
  final String label;

  /// The live component.
  final Widget child;

  /// How many columns this tile occupies.
  final int span;

  /// The tile's fixed height.
  final double height;

  /// An optional note under the label.
  final String? caption;

  /// Where the content sits.
  final Alignment alignment;

  /// Padding around the content.
  final EdgeInsets padding;

  /// The narrowest the content is laid out at before the tile scrolls it.
  ///
  /// Zero — the default — means "whatever the tile is", which is what lets a
  /// `Wrap` of badges actually wrap. Tiles holding something with a fixed
  /// natural width, such as the 560px data table, raise it.
  final double minContentWidth;
}

/// A responsive bento grid of live component previews.
///
/// Flutter has no CSS-grid equivalent, and `GridView` insists on uniform
/// extents, so the layout is computed by hand: pick a column count for the
/// available width, then give each tile `span` columns plus the gutters it
/// swallows. A `Wrap` does the flowing. That is about thirty lines and behaves
/// exactly like `grid-template-columns` with `col-span-2`, without dragging in
/// a layout package.
class BentoGrid extends StatelessWidget {
  /// Creates a grid.
  const BentoGrid({super.key, required this.tiles, this.gap = CairnSpacing.s4});

  /// The cells, in order.
  final List<BentoTile> tiles;

  /// The gutter between cells.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 1100
            ? 4
            : width >= 760
            ? 2
            : 1;
        final double columnWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final BentoTile tile in tiles)
              SizedBox(
                width: _tileWidth(tile.span, columns, columnWidth),
                height: tile.height,
                child: _BentoCell(tile: tile),
              ),
          ],
        );
      },
    );
  }

  double _tileWidth(int span, int columns, double columnWidth) {
    final int effective = span.clamp(1, columns);
    return columnWidth * effective + gap * (effective - 1);
  }
}

class _BentoCell extends StatelessWidget {
  const _BentoCell({required this.tile});

  final BentoTile tile;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return HoverLift(
      lift: 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.card,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radiusScale.xl),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: DotGrid(spacing: 18, child: SizedBox.expand()),
              ),
              Positioned.fill(
                child: Padding(
                  padding: tile.padding,
                  // The vertical scroller is never scrollable — it exists so a
                  // tile taller than its cell is clipped by the ClipRRect
                  // above rather than painting overflow stripes. The
                  // horizontal one is real, for the wide previews on a phone.
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: MinWidthScroller(
                      minWidth: tile.minContentWidth,
                      alignment: tile.alignment,
                      child: tile.child,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: CairnSpacing.s4,
                top: CairnSpacing.s3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tile.label,
                      style: theme
                          .textStyle(CairnTypography.xs)
                          .copyWith(
                            color: theme.mutedForeground,
                            fontWeight: CairnTypography.medium,
                          ),
                    ),
                    if (tile.caption != null)
                      Text(
                        tile.caption!,
                        style: theme
                            .textStyle(CairnTypography.xs)
                            .copyWith(
                              color: theme.mutedForeground.withValues(
                                alpha: 0.7,
                              ),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
