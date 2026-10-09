import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_image.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../domain/hero/models/hero_content.dart';

/// A stack of customer avatars, a star rating and one sentence of proof.
class SocialProofLine extends StatelessWidget {
  /// Creates the line.
  const SocialProofLine({super.key, required this.proof});

  /// What to show.
  final SocialProof proof;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: CairnSpacing.s4,
      runSpacing: CairnSpacing.s3,
      children: <Widget>[
        CairnAvatarGroup(
          children: <Widget>[
            for (final String asset in proof.avatars)
              CairnAvatar(image: landingImage(asset)),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: CairnSpacing.s1,
          children: <Widget>[
            CairnRating(
              value: proof.rating,
              allowHalf: true,
              size: 16,
              semanticLabel: proof.ratingLabel,
            ),
            Text(
              proof.text,
              style: landingText(
                theme,
                CairnTypography.sm,
                color: theme.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
