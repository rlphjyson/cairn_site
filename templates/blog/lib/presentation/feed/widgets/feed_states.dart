import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../../core/presentation/widgets/blog_layout.dart';

/// Placeholder cards shown while posts load, shaped like [PostCard].
class PostGridSkeleton extends StatelessWidget {
  /// Creates the skeleton.
  const PostGridSkeleton({super.key, this.count = 6});

  /// How many cards to draw.
  final int count;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int cols = BlogLayout.columnsFor(BlogLayout.sizeOf(context));
    final int shown = cols == 1 ? 2 : count;

    Widget card() => Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(aspectRatio: 16 / 10, child: _FillSkeleton()),
          Padding(
            padding: EdgeInsets.all(CairnSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s3,
              children: <Widget>[
                CairnSkeleton(width: 84, height: 20),
                CairnSkeleton(width: 220, height: 20),
                CairnSkeleton(height: 14),
                CairnSkeleton(width: 180, height: 14),
                SizedBox(height: CairnSpacing.s2),
                Row(
                  spacing: CairnSpacing.s3,
                  children: <Widget>[
                    CairnSkeleton.circle(size: 32),
                    CairnSkeleton(width: 120, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: 'Loading posts',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: CairnSpacing.s6,
          children: <Widget>[
            for (int start = 0; start < shown; start += cols)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s6,
                children: <Widget>[
                  for (int i = 0; i < cols; i++) Expanded(child: card()),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FillSkeleton extends StatelessWidget {
  const _FillSkeleton();

  @override
  Widget build(BuildContext context) => const LayoutBuilder(builder: _build);

  static Widget _build(BuildContext context, BoxConstraints c) => CairnSkeleton(
    width: c.maxWidth,
    height: c.maxHeight,
    borderRadius: BorderRadius.zero,
  );
}

/// Shown when no post matches the category and search.
class FeedEmpty extends StatelessWidget {
  /// Creates the empty state.
  const FeedEmpty({super.key, required this.onClear, this.hasFilters = true});

  /// Removes the category and search.
  final VoidCallback onClear;

  /// Whether there is anything to clear.
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnEmpty(
      media: Icon(Icons.search_off, size: 28, color: theme.mutedForeground),
      title: hasFilters ? 'No posts match your search' : 'No posts yet',
      description: hasFilters
          ? 'Try a different word, or clear the filters to see everything.'
          : 'Check back soon.',
      actions: <Widget>[
        if (hasFilters)
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: onClear,
            child: const Text('Clear filters'),
          ),
      ],
    );
  }
}

/// Shown when the data source fails.
class FeedError extends StatelessWidget {
  /// Creates the error state.
  const FeedError({super.key, required this.onRetry});

  /// Tries loading again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s4,
      children: <Widget>[
        const CairnAlert(
          variant: CairnAlertVariant.destructive,
          icon: CairnIcon(CairnIconData.alert),
          title: Text('We could not load the posts'),
          description: Text(
            'Something went wrong while fetching the latest posts. Check '
            'your connection and try again.',
          ),
        ),
        CairnButton(
          variant: CairnButtonVariant.outline,
          onPressed: onRetry,
          child: const Text('Try again'),
        ),
      ],
    );
  }
}
