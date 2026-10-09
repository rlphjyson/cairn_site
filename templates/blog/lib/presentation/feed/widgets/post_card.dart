import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../../core/presentation/widgets/blog_image.dart';
import '../../../core/presentation/widgets/pressable.dart';
import '../../../domain/posts/models/post.dart';
import 'post_meta.dart';

/// A post in the grid: a cropped cover, category, title, excerpt and meta.
///
/// The whole card is one tab stop that opens the article. It lifts its border
/// and zooms the photo slightly on hover.
class PostCard extends StatelessWidget {
  /// Creates a card.
  const PostCard(this.post, {super.key});

  /// The post it shows.
  final Post post;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double radius = theme.radiusScale.xl;

    return Pressable(
      semanticLabel: '${post.title}, ${post.category}, by ${post.author.name}',
      borderRadius: BorderRadius.circular(radius),
      onTap: () => context.read<BlogNavigationCubit>().openPost(post.id),
      builder: (BuildContext context, PressState state) {
        return AnimatedContainer(
          duration: CairnMotion.d200,
          curve: CairnMotion.standard,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: state.hovered || state.focused
                  ? theme.mutedForeground.withValues(alpha: 0.5)
                  : theme.border,
            ),
            boxShadow: state.hovered ? CairnShadows.md : CairnShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 10,
                child: ClipRect(
                  child: AnimatedScale(
                    scale: state.hovered ? 1.04 : 1,
                    duration: CairnMotion.d500,
                    curve: CairnMotion.easeOut,
                    child: BlogImage(post.cover, semanticLabel: post.coverAlt),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(CairnSpacing.s5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CairnBadge(
                        variant: CairnBadgeVariant.secondary,
                        label: Text(post.category),
                      ),
                      const SizedBox(height: CairnSpacing.s3),
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: blogText(
                          theme,
                          CairnTypography.lg,
                          weight: CairnTypography.semibold,
                          height: 1.35,
                          tight: true,
                        ),
                      ),
                      const SizedBox(height: CairnSpacing.s2),
                      Text(
                        post.excerpt,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: blogText(
                          theme,
                          CairnTypography.sm,
                          muted: true,
                          height: 1.55,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: CairnSpacing.s5),
                      PostMeta(post),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
