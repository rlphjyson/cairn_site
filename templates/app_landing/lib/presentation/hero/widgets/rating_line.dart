import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/app_landing_image.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../domain/hero/models/hero_content.dart';

/// A stack of user avatars, a star rating and `4.8 · 120K ratings`.
class RatingLine extends StatelessWidget {
  /// Creates the line.
  const RatingLine({super.key, required this.content, this.centered = false});

  /// What to show.
  final HeroContent content;

  /// Whether to centre the line when it wraps.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Wrap(
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: CairnSpacing.s4,
      runSpacing: CairnSpacing.s3,
      children: <Widget>[
        ExcludeSemantics(
          child: CairnAvatarGroup(
            children: <Widget>[
              for (final String asset in content.avatars)
                CairnAvatar(image: appLandingImage(asset)),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s2p5,
          children: <Widget>[
            CairnRating(
              value: content.rating,
              allowHalf: true,
              size: 18,
              semanticLabel: content.ratingLabel,
            ),
            Text(
              content.ratingText,
              style: appLandingText(
                theme,
                CairnTypography.sm,
                weight: CairnTypography.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
