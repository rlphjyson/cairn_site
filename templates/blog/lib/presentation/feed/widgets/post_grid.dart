import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/widgets/blog_layout.dart';
import '../../../domain/posts/models/post.dart';
import 'post_card.dart';

/// Lays [posts] out in rows of equal-height cards.
///
/// The column count follows the blog's own width (see [BlogLayout]): one,
/// two or three. A short last row keeps its cards at column width.
class PostGrid extends StatelessWidget {
  /// Creates a grid.
  const PostGrid({super.key, required this.posts, this.columns});

  /// What to show.
  final List<Post> posts;

  /// Overrides the column count, e.g. 3 for the related row.
  final int? columns;

  @override
  Widget build(BuildContext context) {
    final int cols =
        columns ?? BlogLayout.columnsFor(BlogLayout.sizeOf(context));
    final List<Widget> rows = <Widget>[];
    for (int start = 0; start < posts.length; start += cols) {
      final List<Post> slice = posts.skip(start).take(cols).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: CairnSpacing.s6,
            children: <Widget>[
              for (int i = 0; i < cols; i++)
                Expanded(
                  child: i < slice.length
                      ? PostCard(slice[i], key: ValueKey<String>(slice[i].id))
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s6,
      children: rows,
    );
  }
}
