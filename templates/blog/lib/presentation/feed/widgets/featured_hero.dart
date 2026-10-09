import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../../core/presentation/widgets/blog_image.dart';
import '../../../core/presentation/widgets/blog_layout.dart';
import '../../../domain/posts/models/post.dart';
import 'post_meta.dart';

/// The featured post: a large photograph beside (or above) its title,
/// excerpt, author line and a "Read article" button.
class FeaturedHero extends StatefulWidget {
  /// Creates the hero.
  const FeaturedHero(this.post, {super.key});

  /// The post to feature.
  final Post post;

  @override
  State<FeaturedHero> createState() => _FeaturedHeroState();
}

class _FeaturedHeroState extends State<FeaturedHero> {
  bool _hovered = false;

  void _open() => context.read<BlogNavigationCubit>().openPost(widget.post.id);

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final BlogSize size = BlogLayout.sizeOf(context);
    final bool wide = size == BlogSize.expanded;
    final Post post = widget.post;

    // The photo is a mouse shortcut to the article; the button below is the
    // keyboard and screen-reader route, so the photo is not a second tab stop.
    final Widget photo = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _open,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusScale.xl2),
            border: Border.all(color: theme.border),
            boxShadow: CairnShadows.md,
          ),
          child: AspectRatio(
            aspectRatio: wide ? 4 / 3 : 16 / 10,
            child: ClipRect(
              child: AnimatedScale(
                scale: _hovered ? 1.03 : 1,
                duration: CairnMotion.d500,
                curve: CairnMotion.easeOut,
                child: BlogImage(post.cover, semanticLabel: post.coverAlt),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s2,
          children: <Widget>[
            const CairnBadge(label: Text('Featured')),
            CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text(post.category),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s4),
        Semantics(
          header: true,
          child: Text(
            post.title,
            style: blogText(
              theme,
              CairnTypography.xl3,
              size: wide ? 34 : 26,
              weight: CairnTypography.bold,
              tight: true,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s3),
        Text(
          post.excerpt,
          style: blogText(
            theme,
            CairnTypography.base,
            muted: true,
            height: 1.65,
          ),
        ),
        const SizedBox(height: CairnSpacing.s6),
        PostMeta(post),
        const SizedBox(height: CairnSpacing.s6),
        CairnButton(
          onPressed: _open,
          semanticLabel: 'Read article: ${post.title}',
          trailing: const CairnIcon(CairnIconData.chevronRight),
          child: const Text('Read article'),
        ),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: CairnSpacing.s6,
        children: <Widget>[photo, text],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 56,
      children: <Widget>[
        Expanded(flex: 6, child: photo),
        Expanded(flex: 5, child: text),
      ],
    );
  }
}
