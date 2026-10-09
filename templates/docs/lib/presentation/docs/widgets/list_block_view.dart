import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/docs_text.dart';
import '../../../domain/docs/models/doc_block.dart';
import 'rich_inline.dart';

/// A bulleted or numbered list with a hanging indent.
class ListBlockView extends StatelessWidget {
  /// Creates a list.
  const ListBlockView({super.key, required this.block});

  /// The list to show.
  final ListBlock block;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle body = docsText(
      theme,
      theme.textStyle(CairnTypography.base),
      height: 1.7,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < block.items.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i < block.items.length - 1 ? 8 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 28,
                  child: block.ordered
                      ? Text(
                          '${i + 1}.',
                          style: body.copyWith(color: theme.mutedForeground),
                        )
                      : Padding(
                          // Centre the dot on the first line's x-height.
                          padding: EdgeInsets.only(
                            top: (body.fontSize! * body.height!) / 2 - 3,
                            left: 8,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.mutedForeground,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox.square(dimension: 5),
                          ),
                        ),
                ),
                Expanded(child: RichInline(block.items[i], style: body)),
              ],
            ),
          ),
      ],
    );
  }
}
