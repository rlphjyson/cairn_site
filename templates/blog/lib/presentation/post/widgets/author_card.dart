import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../../core/presentation/widgets/blog_image.dart';
import '../../../core/presentation/widgets/blog_layout.dart';
import '../../../domain/authors/models/author.dart';
import '../../feed/bloc/posts_feed_cubit.dart';

/// "Written by": the author's photo, role and bio, with a shortcut to their
/// other posts.
class AuthorCard extends StatelessWidget {
  /// Creates the card.
  const AuthorCard(this.author, {super.key});

  /// The author.
  final Author author;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = BlogLayout.sizeOf(context) == BlogSize.compact;

    final Widget details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: CairnSpacing.s1,
      children: <Widget>[
        Text(
          'WRITTEN BY',
          style: blogText(
            theme,
            CairnTypography.xs,
            muted: true,
            weight: CairnTypography.medium,
          ).copyWith(letterSpacing: 0.8),
        ),
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
        const SizedBox(height: CairnSpacing.s2),
        Text(
          author.bio,
          style: blogText(theme, CairnTypography.sm, height: 1.6),
        ),
        const SizedBox(height: CairnSpacing.s3),
        CairnButton(
          variant: CairnButtonVariant.outline,
          size: CairnButtonSize.sm,
          onPressed: () {
            context.read<PostsFeedCubit>()
              ..clearFilters()
              ..search(author.name);
            context.read<BlogNavigationCubit>().openHome();
          },
          child: Text('More from ${author.name.split(' ').first}'),
        ),
      ],
    );

    final Widget avatar = BlogAvatar(
      source: author.avatar,
      name: author.name,
      size: compact ? 64 : 88,
    );

    return CairnCard(
      gap: 0,
      children: <Widget>[
        CairnCardContent(
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: CairnSpacing.s4,
                  children: <Widget>[avatar, details],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: CairnSpacing.s6,
                  children: <Widget>[
                    avatar,
                    Expanded(child: details),
                  ],
                ),
        ),
      ],
    );
  }
}
