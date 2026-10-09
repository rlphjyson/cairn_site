import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/inline_markup.dart';
import '../../../core/presentation/docs_text.dart';
import '../../../domain/docs/models/doc_block.dart';
import 'rich_inline.dart';

/// A [CairnTable] of inline-markup cells in a bordered frame.
///
/// Column widths follow the content (a column of long descriptions gets more
/// room than a column of names), and a table that cannot fit its columns at a
/// readable width scrolls sideways instead of crushing them.
class TableBlockView extends StatelessWidget {
  /// Creates a table.
  const TableBlockView({super.key, required this.block});

  /// The table to show.
  final TableBlock block;

  static const double _minColumn = 140;

  int _flexFor(int column) {
    if (block.rows.isEmpty) return 1;
    final int total = block.rows.fold<int>(
      0,
      (int sum, List<String> r) =>
          sum + (column < r.length ? plainText(r[column]).length : 0),
    );
    final int average = total ~/ block.rows.length;
    return (average / 14).round().clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle cell = docsText(
      theme,
      theme.textStyle(CairnTypography.sm),
      height: 1.5,
    );
    final List<CairnColumn<List<String>>> columns = <CairnColumn<List<String>>>[
      for (int c = 0; c < block.headers.length; c++)
        CairnColumn<List<String>>(
          label: block.headers[c],
          flex: _flexFor(c),
          alignment: Alignment.topLeft,
          cell: (List<String> row) => RichInline(
            c < row.length ? row[c] : '',
            style: c == 0
                ? cell.copyWith(fontWeight: CairnTypography.medium)
                : cell.copyWith(
                    color: c == block.headers.length - 1
                        ? theme.mutedForeground
                        : theme.foreground,
                  ),
          ),
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg - 1),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final double minWidth = _minColumn * block.headers.length;
            final bool scrolls = box.maxWidth < minWidth;
            final Widget table = CairnTable<List<String>>(
              columns: columns,
              rows: block.rows,
            );
            if (!scrolls) return table;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: minWidth, child: table),
            );
          },
        ),
      ),
    );
  }
}
