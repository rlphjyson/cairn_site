import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/blog_brand.dart';
import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/widgets/blog_layout.dart';
import '../../newsletter/widgets/newsletter_band.dart';
import '../bloc/posts_feed_cubit.dart';
import '../widgets/category_filter.dart';
import '../widgets/featured_hero.dart';
import '../widgets/feed_states.dart';
import '../widgets/post_grid.dart';

/// The home page: intro, featured post, filterable grid, pagination and the
/// newsletter band. Reads the session [PostsFeedCubit], so its filters and
/// page survive opening an article.
class FeedView extends StatefulWidget {
  /// Creates the view.
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final GlobalKey _gridKey = GlobalKey();

  void _goToPage(int page) {
    context.read<PostsFeedCubit>().goToPage(page);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? target = _gridKey.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(
          target,
          duration: CairnMotion.d300,
          curve: CairnMotion.standard,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final BlogSize size = BlogLayout.sizeOf(context);
    final bool compact = size == BlogSize.compact;
    final PostsFeedCubit cubit = context.read<PostsFeedCubit>();

    return BlocBuilder<PostsFeedCubit, PostsFeedState>(
      builder: (BuildContext context, PostsFeedState state) {
        final bool filtered = state.query.isFiltered;

        return PageContainer(
          padding: EdgeInsets.only(
            top: compact ? 32 : 56,
            bottom: compact ? 56 : 88,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!filtered) _Intro(compact: compact),
              if (state.showFeatured) ...<Widget>[
                SizedBox(height: compact ? 32 : 48),
                FeaturedHero(state.featured!),
              ],
              SizedBox(height: filtered ? 0 : (compact ? 48 : 80)),
              KeyedSubtree(
                key: _gridKey,
                child: _SectionHeader(state: state),
              ),
              const SizedBox(height: CairnSpacing.s6),
              switch (state.status) {
                FeedStatus.initial ||
                FeedStatus.loading => const PostGridSkeleton(),
                FeedStatus.failure => FeedError(onRetry: cubit.load),
                FeedStatus.ready when state.page.items.isEmpty => FeedEmpty(
                  onClear: cubit.clearFilters,
                  hasFilters: filtered,
                ),
                FeedStatus.ready => PostGrid(posts: state.page.items),
              },
              if (state.status == FeedStatus.ready &&
                  state.page.pageCount > 1) ...<Widget>[
                const SizedBox(height: CairnSpacing.s12),
                Center(
                  child: CairnPagination(
                    page: state.page.page,
                    pageCount: state.page.pageCount,
                    showLabels: !compact,
                    onChanged: _goToPage,
                  ),
                ),
              ],
              if (state.status == FeedStatus.ready) ...<Widget>[
                SizedBox(height: compact ? 56 : 88),
                const NewsletterBand(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: CairnHero(
          alignment: CrossAxisAlignment.start,
          padding: EdgeInsets.zero,
          eyebrow: const CairnBadge(
            variant: CairnBadgeVariant.outline,
            label: Text(BlogBrand.eyebrow),
          ),
          title: Semantics(
            header: true,
            child: Text(
              BlogBrand.headline,
              style: TextStyle(
                fontSize: compact ? 32 : 52,
                height: compact ? 1.15 : 1.08,
                fontWeight: CairnTypography.bold,
                letterSpacing: CairnTypography.trackingTight(compact ? 32 : 52),
              ),
            ),
          ),
          description: const Text(BlogBrand.lead),
        ),
      ),
    );
  }
}

/// The heading above the grid, with the category chips and, when filtered,
/// a result count.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.state});

  final PostsFeedState state;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final PostsFeedCubit cubit = context.read<PostsFeedCubit>();
    final bool stacked = BlogLayout.sizeOf(context) != BlogSize.expanded;
    final bool filtered = state.query.isFiltered;
    final String search = state.query.search.trim();

    final String title = search.isNotEmpty
        ? 'Results for “$search”'
        : state.query.category ?? 'Latest posts';
    final String? count = state.status == FeedStatus.ready && filtered
        ? '${state.page.total} ${state.page.total == 1 ? 'post' : 'posts'}'
        : null;

    final Widget heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s1,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            style: blogText(
              theme,
              CairnTypography.xl2,
              weight: CairnTypography.semibold,
              tight: true,
            ),
          ),
        ),
        if (count != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: CairnSpacing.s3,
            children: <Widget>[
              Text(
                count,
                style: blogText(theme, CairnTypography.sm, muted: true),
              ),
              CairnLink(
                onPressed: cubit.clearFilters,
                muted: true,
                underline: true,
                child: const Text('Clear filters'),
              ),
            ],
          ),
      ],
    );

    final Widget filter = CategoryFilter(
      categories: state.categories,
      selected: state.query.category,
      onSelected: cubit.selectCategory,
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: CairnSpacing.s4,
        children: <Widget>[heading, filter],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: CairnSpacing.s6,
      children: <Widget>[
        Expanded(child: heading),
        Flexible(
          child: Align(alignment: Alignment.centerRight, child: filter),
        ),
      ],
    );
  }
}
