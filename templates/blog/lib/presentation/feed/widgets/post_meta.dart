import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/format.dart';
import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/widgets/blog_image.dart';
import '../../../domain/authors/models/author.dart';
import '../../../domain/posts/models/post.dart';

/// A small round author photo that falls back to initials.
class AuthorAvatar extends StatelessWidget {
  /// Creates an avatar.
  const AuthorAvatar(this.author, {super.key, this.size = CairnAvatarSize.md});

  /// Who it shows.
  final Author author;

  /// `sm` 24, `md` 32, `lg` 40.
  final CairnAvatarSize size;

  @override
  Widget build(BuildContext context) => CairnAvatar(
    image: blogImageProvider(author.avatar),
    fallback: Text(initials(author.name)),
    size: size,
    semanticLabel: author.name,
  );
}

/// The author and date line shown on cards and above articles: an avatar,
/// the author's name, and the date with the reading time underneath.
class PostMeta extends StatelessWidget {
  /// Creates the line.
  const PostMeta(
    this.post, {
    super.key,
    this.avatarSize = CairnAvatarSize.md,
    this.showRole = false,
  });

  /// The post whose author and date are shown.
  final Post post;

  /// The avatar's size.
  final CairnAvatarSize avatarSize;

  /// Shows the author's role after the name (article header).
  final bool showRole;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AuthorAvatar(post.author, size: avatarSize),
        const SizedBox(width: CairnSpacing.s3),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                showRole
                    ? '${post.author.name}  ·  ${post.author.role}'
                    : post.author.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: blogText(
                  theme,
                  CairnTypography.sm,
                  weight: CairnTypography.medium,
                ),
              ),
              Text(
                '${formatDate(post.publishedAt)}  ·  '
                '${formatReadingTime(post.readingMinutes)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: blogText(theme, CairnTypography.xs, muted: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
