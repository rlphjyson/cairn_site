import 'package:flutter/widgets.dart';

import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/equal_height_grid.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/testimonials/models/testimonials_content.dart';
import '../widgets/testimonial_card.dart';

/// Customer quotes in an equal-height grid: three across on desktop, two on a
/// tablet, one on a phone.
class TestimonialsView extends StatelessWidget {
  /// Creates the view.
  const TestimonialsView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<TestimonialsContent>(
    loadingHeight: 640,
    builder: (BuildContext context, TestimonialsContent content) {
      final bool compact = LandingViewport.of(context).isCompact;
      return SectionFrame(
        tinted: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Reveal(
              child: SectionHeader(
                eyebrow: content.eyebrow,
                title: content.title,
                subtitle: content.subtitle,
              ),
            ),
            SizedBox(height: compact ? 40 : 64),
            EqualHeightGrid(
              columnsFor: (double w) => w >= 900 ? 3 : (w >= 600 ? 2 : 1),
              children: <Widget>[
                for (int i = 0; i < content.items.length; i++)
                  Reveal(
                    delay: Duration(milliseconds: 60 * (i % 3)),
                    child: TestimonialCard(testimonial: content.items[i]),
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
