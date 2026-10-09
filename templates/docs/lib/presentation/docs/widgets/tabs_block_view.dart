import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/docs/models/doc_block.dart';
import 'block_column.dart';

/// Alternative content behind a [CairnTabs] bar, such as one install command
/// per package manager.
class TabsBlockView extends StatefulWidget {
  /// Creates a tabs block.
  const TabsBlockView({super.key, required this.block});

  /// The tabs to show.
  final TabsBlock block;

  @override
  State<TabsBlockView> createState() => _TabsBlockViewState();
}

class _TabsBlockViewState extends State<TabsBlockView> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final List<TabItem> tabs = widget.block.tabs;
    if (tabs.isEmpty) return const SizedBox.shrink();
    final int index = _selected.clamp(0, tabs.length - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: CairnTabs<int>(
            value: index,
            onChanged: (int v) => setState(() => _selected = v),
            tabs: <CairnTab<int>>[
              for (int i = 0; i < tabs.length; i++)
                CairnTab<int>(value: i, label: Text(tabs[i].label)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BlockColumn(
          // A key per tab so a tab's own state (a nested tabs block) resets.
          key: ValueKey<int>(index),
          blocks: tabs[index].blocks,
        ),
      ],
    );
  }
}
