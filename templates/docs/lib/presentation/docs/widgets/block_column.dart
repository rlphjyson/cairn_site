import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/docs_text.dart';
import '../../../domain/docs/models/doc_block.dart';
import 'callout_view.dart';
import 'code_block_view.dart';
import 'heading_view.dart';
import 'list_block_view.dart';
import 'rich_inline.dart';
import 'steps_block_view.dart';
import 'table_block_view.dart';
import 'tabs_block_view.dart';

/// Renders a list of blocks as a vertical rhythm: 20 px between blocks, more
/// above a heading.
///
/// At the top level the page passes [keyFor] so every heading can be measured
/// and scrolled to; nested lists (inside tabs and steps) leave it null.
class BlockColumn extends StatelessWidget {
  /// Creates the column.
  const BlockColumn({super.key, required this.blocks, this.keyFor});

  /// What to render.
  final List<DocBlock> blocks;

  /// Looks up the key for a heading id, or `null` to leave headings unkeyed.
  final GlobalKey Function(String headingId)? keyFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  i == blocks.length - 1 ||
                      blocks[i] is HeadingBlock ||
                      blocks[i + 1] is HeadingBlock
                  ? 0
                  : 20,
            ),
            child: _BlockView(
              block: blocks[i],
              isFirst: i == 0,
              keyFor: keyFor,
            ),
          ),
      ],
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({
    required this.block,
    required this.isFirst,
    required this.keyFor,
  });

  final DocBlock block;
  final bool isFirst;
  final GlobalKey Function(String headingId)? keyFor;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return switch (block) {
      final HeadingBlock b => HeadingView(
        block: b,
        isFirst: isFirst,
        anchorKey: keyFor?.call(b.id) ?? GlobalKey(),
      ),
      final ParagraphBlock b => RichInline(
        b.text,
        style: docsText(
          theme,
          theme.textStyle(CairnTypography.base),
          height: 1.7,
        ),
      ),
      final CodeBlock b => CodeBlockView(block: b),
      final CalloutBlock b => CalloutView(block: b),
      final TabsBlock b => TabsBlockView(block: b),
      final StepsBlock b => StepsBlockView(block: b),
      final TableBlock b => TableBlockView(block: b),
      final ListBlock b => ListBlockView(block: b),
    };
  }
}
