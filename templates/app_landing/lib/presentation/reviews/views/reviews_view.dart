import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/equal_height_grid.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/reviews/models/reviews_content.dart';
import '../widgets/rating_summary.dart';
import '../widgets/review_card.dart';

/// Ratings and reviews, App Store style: a summary with a bar per star count
/// beside review cards, and a "Write a review" button that opens a toast.
class ReviewsView extends StatelessWidget {
  /// Creates the view.
  const ReviewsView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<ReviewsContent>(
    loadingHeight: 900,
    builder: (BuildContext context, ReviewsContent content) {
      final AppLandingViewport viewport = AppLandingViewport.of(context);
      final bool wide = viewport.isExpanded;

      final Widget summary = RatingSummary(
        distribution: content.distribution,
        prompt: content.writeReview,
        onWrite: () => CairnToast.show(
          context,
          CairnToast(
            title: content.writeReview.toastTitle,
            description: content.writeReview.toastMessage,
            variant: CairnToastVariant.info,
          ),
        ),
      );

      final Widget cards = EqualHeightGrid(
        columnsFor: (double w) => w >= 560 ? 2 : 1,
        children: <Widget>[
          for (int i = 0; i < content.reviews.length; i++)
            Reveal(
              delay: Duration(milliseconds: 60 * (i % 4)),
              child: ReviewCard(review: content.reviews[i]),
            ),
        ],
      );

      return SectionFrame(
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
            SizedBox(height: viewport.isCompact ? 32 : 56),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s8,
                children: <Widget>[
                  Expanded(flex: 4, child: Reveal(child: summary)),
                  Expanded(flex: 8, child: cards),
                ],
              )
            else ...<Widget>[
              Reveal(child: summary),
              const SizedBox(height: CairnSpacing.s6),
              cards,
            ],
          ],
        ),
      );
    },
  );
}
