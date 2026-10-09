import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/blog_brand.dart';
import '../../../common/constants/blog_config.dart';
import '../../../common/utils/format.dart';
import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/blog_image.dart';
import '../../../core/presentation/widgets/blog_layout.dart';
import '../../../core/presentation/widgets/pressable.dart';
import '../../../domain/posts/models/post.dart';
import '../../feed/bloc/posts_feed_cubit.dart';
import '../../feed/widgets/post_grid.dart';
import '../../feed/widgets/post_meta.dart';
import '../bloc/post_detail_cubit.dart';
import '../view_models/post_detail_view_model.dart';
import '../widgets/author_card.dart';
import '../widgets/post_body.dart';

/// One article: breadcrumb, headline, author line, cover, body, tags, author
/// card and related posts.
class PostDetailView extends StatelessWidget {
  /// Creates the view for the post [postId].
  const PostDetailView({super.key, required this.postId});

  /// The post to show.
  final String postId;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PostDetailViewModel>(
      onCreate: (BuildContext context, PostDetailViewModel vm) =>
          vm.cubit.load(postId),
      builder: (BuildContext context, PostDetailViewModel vm) =>
          BlocBuilder<PostDetailCubit, PostDetailState>(
            bloc: vm.cubit,
            builder: (BuildContext context, PostDetailState state) {
              return switch (state.status) {
                PostDetailStatus.loading => const _Loading(),
                PostDetailStatus.notFound => const _NotFound(),
                PostDetailStatus.failure => _Failure(
                  onRetry: () => vm.cubit.load(postId),
                ),
                PostDetailStatus.ready => _Article(
                  post: state.post!,
                  related: state.related,
                ),
              };
            },
          ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({required this.post, required this.related});

  final Post post;
  final List<Post> related;

  void _copyLink(BuildContext context) {
    final String url = '${BlogBrand.postBaseUrl}/${post.id}';
    Clipboard.setData(ClipboardData(text: url));
    CairnToast.show(
      context,
      CairnToast(
        title: 'Link copied',
        description: url,
        variant: CairnToastVariant.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final BlogSize size = BlogLayout.sizeOf(context);
    final bool compact = size == BlogSize.compact;
    final BlogNavigationCubit nav = context.read<BlogNavigationCubit>();

    final Widget copyButton = CairnButton(
      variant: CairnButtonVariant.outline,
      size: CairnButtonSize.sm,
      semanticLabel: 'Copy link to this article',
      leading: const Icon(Icons.link, size: 16),
      onPressed: () => _copyLink(context),
      child: const Text('Copy link'),
    );

    final Widget header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CairnBreadcrumb(
          crumbs: <CairnCrumb>[
            CairnCrumb(label: 'Blog', onTap: nav.openHome),
            CairnCrumb(
              label: post.category,
              onTap: () {
                context.read<PostsFeedCubit>()
                  ..clearFilters()
                  ..selectCategory(post.category);
                nav.openHome();
              },
            ),
            CairnCrumb.current(label: truncate(post.title, 36)),
          ],
        ),
        SizedBox(height: compact ? 24 : 32),
        Semantics(
          header: true,
          child: Text(
            post.title,
            style: blogText(
              theme,
              CairnTypography.xl4,
              size: compact ? 32 : 46,
              weight: CairnTypography.bold,
              height: compact ? 1.15 : 1.1,
              tight: true,
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s4),
        Text(
          post.excerpt,
          style: blogText(
            theme,
            CairnTypography.xl,
            size: compact ? 18 : 20,
            muted: true,
            height: 1.6,
          ),
        ),
        const SizedBox(height: CairnSpacing.s8),
        if (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s4,
            children: <Widget>[
              PostMeta(post, avatarSize: CairnAvatarSize.lg),
              copyButton,
            ],
          )
        else
          Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PostMeta(post, avatarSize: CairnAvatarSize.lg),
                ),
              ),
              copyButton,
            ],
          ),
      ],
    );

    final Widget cover = ClipRRect(
      borderRadius: BorderRadius.circular(theme.radiusScale.xl2),
      child: AspectRatio(
        aspectRatio: compact ? 16 / 10 : 2,
        child: BlogImage(post.cover, semanticLabel: post.coverAlt),
      ),
    );

    final Widget tags = Wrap(
      spacing: CairnSpacing.s2,
      runSpacing: CairnSpacing.s2,
      children: <Widget>[
        for (final String tag in post.tags)
          Pressable(
            semanticLabel: 'Search posts tagged $tag',
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              context.read<PostsFeedCubit>()
                ..clearFilters()
                ..search(tag);
              nav.openHome();
            },
            builder: (BuildContext context, PressState s) => Opacity(
              opacity: s.hovered ? 0.7 : 1,
              child: CairnBadge(
                variant: CairnBadgeVariant.outline,
                label: Text('#$tag'),
              ),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageContainer(
          maxWidth: 960,
          padding: EdgeInsets.only(top: compact ? 24 : 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: BlogConfig.articleWidth,
                  ),
                  child: header,
                ),
              ),
              SizedBox(height: compact ? 32 : 48),
              cover,
              SizedBox(height: compact ? 32 : 56),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: BlogConfig.articleWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      PostBody(post.body),
                      const SizedBox(height: CairnSpacing.s10),
                      if (post.tags.isNotEmpty) tags,
                      const SizedBox(height: CairnSpacing.s8),
                      const CairnSeparator(),
                      const SizedBox(height: CairnSpacing.s6),
                      _ShareRow(onCopy: () => _copyLink(context)),
                      const SizedBox(height: CairnSpacing.s10),
                      AuthorCard(post.author),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (related.isNotEmpty)
          PageContainer(
            padding: EdgeInsets.only(top: compact ? 56 : 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: CairnSpacing.s6,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    'Related posts',
                    style: blogText(
                      theme,
                      CairnTypography.xl2,
                      weight: CairnTypography.semibold,
                      tight: true,
                    ),
                  ),
                ),
                PostGrid(posts: related),
              ],
            ),
          ),
        PageContainer(
          padding: EdgeInsets.symmetric(vertical: compact ? 48 : 72),
          child: Center(
            child: CairnButton(
              variant: CairnButtonVariant.outline,
              leading: const Icon(Icons.arrow_back, size: 16),
              onPressed: nav.back,
              child: const Text('Back to blog'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.onCopy});

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Enjoyed this? Share it with someone.',
            style: blogText(theme, CairnTypography.sm, muted: true),
          ),
        ),
        const SizedBox(width: CairnSpacing.s3),
        CairnButton(
          variant: CairnButtonVariant.secondary,
          size: CairnButtonSize.sm,
          semanticLabel: 'Copy link to share this article',
          leading: const Icon(Icons.ios_share, size: 16),
          onPressed: onCopy,
          child: const Text('Share'),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final bool compact = BlogLayout.sizeOf(context) == BlogSize.compact;
    return PageContainer(
      maxWidth: BlogConfig.articleWidth,
      padding: EdgeInsets.symmetric(vertical: compact ? 32 : 64),
      child: Semantics(
        label: 'Loading article',
        child: const ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s4,
            children: <Widget>[
              CairnSkeleton(width: 220, height: 16),
              SizedBox(height: CairnSpacing.s4),
              CairnSkeleton(height: 36),
              CairnSkeleton(width: 280, height: 36),
              SizedBox(height: CairnSpacing.s2),
              Row(
                spacing: CairnSpacing.s3,
                children: <Widget>[
                  CairnSkeleton.circle(size: 40),
                  CairnSkeleton(width: 160, height: 16),
                ],
              ),
              SizedBox(height: CairnSpacing.s6),
              CairnSkeleton(height: 280),
              SizedBox(height: CairnSpacing.s6),
              CairnSkeleton(height: 14),
              CairnSkeleton(height: 14),
              CairnSkeleton(width: 400, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return PageContainer(
      maxWidth: 720,
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: CairnEmpty(
        media: Icon(
          Icons.article_outlined,
          size: 28,
          color: theme.mutedForeground,
        ),
        title: 'We could not find that post',
        description: 'It may have been moved or removed.',
        actions: <Widget>[
          CairnButton(
            onPressed: context.read<BlogNavigationCubit>().openHome,
            child: const Text('Back to blog'),
          ),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      maxWidth: 720,
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: CairnSpacing.s4,
        children: <Widget>[
          const CairnAlert(
            variant: CairnAlertVariant.destructive,
            icon: CairnIcon(CairnIconData.alert),
            title: Text('We could not load this post'),
            description: Text('Check your connection and try again.'),
          ),
          Row(
            spacing: CairnSpacing.s2,
            children: <Widget>[
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
              CairnButton(
                variant: CairnButtonVariant.ghost,
                onPressed: context.read<BlogNavigationCubit>().back,
                child: const Text('Back to blog'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
