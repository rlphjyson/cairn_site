import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/date_format.dart';
import '../../../core/presentation/app_landing_image.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../domain/reviews/models/reviews_content.dart';

/// One review in the style of an app store: stars and date, a title, the text
/// and who wrote it.
class ReviewCard extends StatelessWidget {
  /// Creates the card.
  const ReviewCard({super.key, required this.review});

  /// The review.
  final Review review;

  String get _initials {
    final List<String> parts = review.author
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((String p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String? avatar = review.avatar;
    return Semantics(
      container: true,
      label:
          '${review.rating} out of 5 stars. ${review.title}. '
          '${review.author}, ${formatDate(review.date)}',
      child: CairnCard(
        gap: CairnSpacing.s3,
        children: <Widget>[
          CairnCardContent(
            child: Row(
              children: <Widget>[
                ExcludeSemantics(
                  child: CairnRating(
                    value: review.rating.toDouble(),
                    size: 16,
                    semanticLabel: '${review.rating} out of 5 stars',
                  ),
                ),
                const Spacer(),
                Text(
                  formatDate(review.date),
                  style: appLandingText(
                    theme,
                    CairnTypography.xs,
                    color: theme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          CairnCardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: CairnSpacing.s1p5,
              children: <Widget>[
                Text(
                  review.title,
                  style: appLandingText(
                    theme,
                    CairnTypography.base,
                    weight: CairnTypography.semibold,
                    height: 1.35,
                    tight: true,
                  ),
                ),
                Text(
                  review.body,
                  style: appLandingText(
                    theme,
                    CairnTypography.sm,
                    color: theme.mutedForeground,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          CairnCardContent(
            child: Row(
              spacing: CairnSpacing.s2p5,
              children: <Widget>[
                CairnAvatar(
                  image: avatar == null ? null : appLandingImage(avatar),
                  fallback: Text(_initials),
                  semanticLabel: review.author,
                ),
                Expanded(
                  child: Text(
                    review.author,
                    style: appLandingText(
                      theme,
                      CairnTypography.sm,
                      weight: CairnTypography.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
