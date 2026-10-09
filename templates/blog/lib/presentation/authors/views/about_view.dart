import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/blog_brand.dart';
import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/blog_image.dart';
import '../../../core/presentation/widgets/blog_layout.dart';
import '../../../domain/authors/models/author.dart';
import '../../feed/bloc/posts_feed_cubit.dart';
import '../bloc/authors_cubit.dart';
import '../view_models/authors_view_model.dart';

/// The About page: what the blog is, and who writes it.
class AboutView extends StatelessWidget {
  /// Creates the view.
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool compact = BlogLayout.sizeOf(context) == BlogSize.compact;
    return ViewModelBuilder<AuthorsViewModel>(
      onCreate: (BuildContext context, AuthorsViewModel vm) => vm.cubit.load(),
      builder: (BuildContext context, AuthorsViewModel vm) => PageContainer(
        padding: EdgeInsets.only(
          top: compact ? 32 : 56,
          bottom: compact ? 56 : 96,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Intro(compact: compact),
            SizedBox(height: compact ? 32 : 48),
            BlocBuilder<AuthorsCubit, AuthorsState>(
              bloc: vm.cubit,
              builder: (BuildContext context, AuthorsState state) {
                if (state.loading) return const _Skeleton();
                if (state.failed) {
                  return _Failed(onRetry: vm.cubit.load);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _Stats(
                      posts: state.totalPosts,
                      authors: state.profiles.length,
                    ),
                    SizedBox(height: compact ? 48 : 72),
                    const _SectionTitle('The people behind it'),
                    const SizedBox(height: CairnSpacing.s6),
                    _AuthorGrid(profiles: state.profiles),
                  ],
                );
              },
            ),
          ],
        ),
      ),
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
            label: Text('About'),
          ),
          title: Semantics(
            header: true,
            child: Text(
              'About ${BlogBrand.name}',
              style: TextStyle(
                fontSize: compact ? 32 : 52,
                height: compact ? 1.15 : 1.08,
                fontWeight: CairnTypography.bold,
                letterSpacing: CairnTypography.trackingTight(compact ? 32 : 52),
              ),
            ),
          ),
          description: const Text(BlogBrand.aboutLead),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: blogText(
        CairnTheme.of(context),
        CairnTypography.xl2,
        weight: CairnTypography.semibold,
        tight: true,
      ),
    ),
  );
}

class _Stats extends StatelessWidget {
  const _Stats({required this.posts, required this.authors});

  final int posts;
  final int authors;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    Widget stat(String title, String value, String description) => Expanded(
      child: CairnStat(
        title: Text(title),
        value: Text(value),
        description: Text(description),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            stat('Posts', '$posts', 'published so far'),
            const CairnSeparator(axis: Axis.vertical),
            stat('Writers', '$authors', 'on the team'),
          ],
        ),
      ),
    );
  }
}

class _AuthorGrid extends StatelessWidget {
  const _AuthorGrid({required this.profiles});

  final List<AuthorProfile> profiles;

  @override
  Widget build(BuildContext context) {
    final int cols = BlogLayout.sizeOf(context) == BlogSize.compact ? 1 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s6,
      children: <Widget>[
        for (int start = 0; start < profiles.length; start += cols)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: CairnSpacing.s6,
              children: <Widget>[
                for (int i = 0; i < cols; i++)
                  Expanded(
                    child: start + i < profiles.length
                        ? _AuthorTile(profiles[start + i])
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AuthorTile extends StatelessWidget {
  const _AuthorTile(this.profile);

  final AuthorProfile profile;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Author author = profile.author;
    final int count = profile.postCount;

    return Container(
      padding: const EdgeInsets.all(CairnSpacing.s6),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
        boxShadow: CairnShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: CairnSpacing.s4,
            children: <Widget>[
              BlogAvatar(source: author.avatar, name: author.name, size: 72),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: CairnSpacing.s1,
                  children: <Widget>[
                    Text(
                      author.name,
                      style: blogText(
                        theme,
                        CairnTypography.lg,
                        weight: CairnTypography.semibold,
                        tight: true,
                      ),
                    ),
                    Text(
                      author.role,
                      style: blogText(theme, CairnTypography.sm, muted: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s4),
          Text(
            author.bio,
            style: blogText(theme, CairnTypography.sm, height: 1.6),
          ),
          const Spacer(),
          const SizedBox(height: CairnSpacing.s5),
          Row(
            children: <Widget>[
              CairnBadge(
                variant: CairnBadgeVariant.secondary,
                label: Text('$count ${count == 1 ? 'post' : 'posts'}'),
              ),
              const Spacer(),
              CairnButton(
                variant: CairnButtonVariant.outline,
                size: CairnButtonSize.sm,
                semanticLabel: 'Read posts by ${author.name}',
                onPressed: () {
                  context.read<PostsFeedCubit>()
                    ..clearFilters()
                    ..search(author.name);
                  context.read<BlogNavigationCubit>().openHome();
                },
                child: const Text('Read posts'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading authors',
    child: const ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: CairnSpacing.s6,
        children: <Widget>[
          CairnSkeleton(height: 88),
          CairnSkeleton(height: 200),
        ],
      ),
    ),
  );
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: CairnSpacing.s4,
    children: <Widget>[
      const CairnAlert(
        variant: CairnAlertVariant.destructive,
        icon: CairnIcon(CairnIconData.alert),
        title: Text('We could not load the authors'),
        description: Text('Check your connection and try again.'),
      ),
      CairnButton(
        variant: CairnButtonVariant.outline,
        onPressed: onRetry,
        child: const Text('Try again'),
      ),
    ],
  );
}
