import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../common/utils/date_format.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../domain/reviews/models/reviews_content.dart';

/// The big average, the stars, the total and a bar for each star count.
class RatingSummary extends StatelessWidget {
  /// Creates the summary.
  const RatingSummary({
    super.key,
    required this.distribution,
    required this.prompt,
    required this.onWrite,
  });

  /// The counts everything here is derived from.
  final RatingDistribution distribution;

  /// The "Write a review" button copy.
  final WriteReviewPrompt prompt;

  /// Called when the visitor asks to write a review.
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String average = distribution.averageLabel;
    final String total = formatCount(distribution.total);

    return CairnCard(
      gap: CairnSpacing.s5,
      children: <Widget>[
        CairnCardContent(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: CairnSpacing.s4,
            children: <Widget>[
              Semantics(
                header: true,
                label: 'Average rating $average out of 5',
                excludeSemantics: true,
                child: Text(
                  average,
                  style: appLandingText(
                    theme,
                    CairnTypography.xl4,
                    size: 56,
                    height: 1,
                    weight: CairnTypography.semibold,
                    tight: true,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: CairnSpacing.s1p5,
                    children: <Widget>[
                      CairnRating(
                        value: distribution.average,
                        allowHalf: true,
                        size: 18,
                        semanticLabel:
                            'Rated $average out of 5 from '
                            '${distribution.total} ratings',
                      ),
                      Text(
                        '$total ratings',
                        style: appLandingText(
                          theme,
                          CairnTypography.sm,
                          color: theme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        CairnCardContent(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: CairnSpacing.s2p5,
            children: <Widget>[
              for (final int star in RatingDistribution.stars)
                _BarRow(star: star, distribution: distribution),
            ],
          ),
        ),
        CairnCardContent(
          child: CairnButton(
            variant: CairnButtonVariant.outline,
            expand: true,
            leading: const Icon(Icons.edit_outlined, size: 16),
            onPressed: onWrite,
            child: Text(prompt.label),
          ),
        ),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.star, required this.distribution});

  final int star;
  final RatingDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double share = distribution.shareFor(star);
    final int percent = (share * 100).round();
    final TextStyle small = appLandingText(
      theme,
      CairnTypography.xs,
      color: theme.mutedForeground,
      height: 1,
    );
    return Semantics(
      container: true,
      label:
          '$star ${star == 1 ? 'star' : 'stars'}: '
          '${distribution.countFor(star)} ratings, $percent percent',
      excludeSemantics: true,
      child: Row(
        spacing: CairnSpacing.s3,
        children: <Widget>[
          SizedBox(
            width: 28,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: <Widget>[
                Text('$star', style: small),
                Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: theme.mutedForeground,
                ),
              ],
            ),
          ),
          Expanded(child: CairnProgress(value: share, height: 8)),
          SizedBox(
            width: 44,
            child: Text(
              formatCount(distribution.countFor(star)),
              textAlign: TextAlign.end,
              style: small,
            ),
          ),
        ],
      ),
    );
  }
}
