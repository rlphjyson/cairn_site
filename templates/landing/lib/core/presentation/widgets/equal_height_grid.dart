import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Lays [children] out in rows of equal-height cells.
///
/// [columnsFor] picks the column count from the width available, so the grid
/// follows the space it is given rather than the screen. The last row is
/// padded with empty cells so every cell keeps the same width.
class EqualHeightGrid extends StatelessWidget {
  /// Creates a grid.
  const EqualHeightGrid({
    super.key,
    required this.children,
    required this.columnsFor,
    this.gap = CairnSpacing.s6,
  });

  /// The cells.
  final List<Widget> children;

  /// The number of columns for a given width.
  final int Function(double width) columnsFor;

  /// The gap between cells, both ways.
  final double gap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final int columns = columnsFor(constraints.maxWidth);
      if (columns <= 1) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: children,
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: <Widget>[
          for (int start = 0; start < children.length; start += columns)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: gap,
                children: <Widget>[
                  for (int i = start; i < start + columns; i++)
                    Expanded(
                      child: i < children.length
                          ? children[i]
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

/// Lays [children] out in rows with explicit flex ratios, for a bento rhythm.
///
/// [pattern] lists the flex of each cell, row by row (`[[7, 5], [5, 7]]`).
/// Below [minWidth] the grid collapses to two equal columns when there is room
/// (600 and up) and [fallbackColumns] otherwise.
class BentoGrid extends StatelessWidget {
  /// Creates a bento grid.
  const BentoGrid({
    super.key,
    required this.children,
    required this.pattern,
    this.minWidth = 960,
    this.fallbackColumns = 1,
    this.gap = CairnSpacing.s6,
  });

  /// The cells.
  final List<Widget> children;

  /// The flex of each cell in each row.
  final List<List<int>> pattern;

  /// The width at and above which [pattern] is used.
  final double minWidth;

  /// The column count below [minWidth].
  final int fallbackColumns;

  /// The gap between cells, both ways.
  final double gap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < minWidth) {
        return EqualHeightGrid(
          columnsFor: (double w) => w >= 600 ? 2 : fallbackColumns,
          gap: gap,
          children: children,
        );
      }
      int next = 0;
      final List<Widget> rows = <Widget>[];
      for (final List<int> row in pattern) {
        final List<Widget> cells = <Widget>[];
        for (final int flex in row) {
          if (next >= children.length) break;
          cells.add(Expanded(flex: flex, child: children[next++]));
        }
        if (cells.isNotEmpty) {
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: gap,
                children: cells,
              ),
            ),
          );
        }
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: rows,
      );
    },
  );
}
