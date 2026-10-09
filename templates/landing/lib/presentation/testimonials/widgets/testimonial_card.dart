import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_image.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../domain/testimonials/models/testimonials_content.dart';

/// One customer quote: who said it, their rating, and what they said.
class TestimonialCard extends StatelessWidget {
  /// Creates the card.
  const TestimonialCard({super.key, required this.testimonial});

  /// The quote.
  final Testimonial testimonial;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Testimonial t = testimonial;
    return Semantics(
      container: true,
      child: CairnCard(
        gap: CairnSpacing.s4,
        children: <Widget>[
          CairnCardContent(
            child: Row(
              spacing: CairnSpacing.s3,
              children: <Widget>[
                CairnAvatar(
                  size: CairnAvatarSize.lg,
                  image: landingImage(t.avatar),
                  semanticLabel: t.name,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        t.name,
                        style: landingText(
                          theme,
                          CairnTypography.sm,
                          weight: CairnTypography.semibold,
                        ),
                      ),
                      Text(
                        '${t.role}, ${t.company}',
                        style: landingText(
                          theme,
                          CairnTypography.xs,
                          color: theme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CairnCardContent(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: CairnRating(
                value: t.rating,
                allowHalf: true,
                size: 16,
                semanticLabel: 'Rated ${t.rating} out of 5',
              ),
            ),
          ),
          CairnCardContent(
            child: Text(
              '“${t.quote}”',
              style: landingText(theme, CairnTypography.base, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
