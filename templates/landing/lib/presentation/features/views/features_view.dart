import 'package:flutter/widgets.dart';

import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/equal_height_grid.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/features/models/features_content.dart';
import '../widgets/feature_card.dart';
import '../widgets/spotlight_row.dart';

/// The features section: a bento grid of cards, then image-led spotlights
/// that alternate sides.
class FeaturesView extends StatelessWidget {
  /// Creates the view.
  const FeaturesView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<FeaturesContent>(
    loadingHeight: 900,
    builder: (BuildContext context, FeaturesContent content) {
      final bool compact = LandingViewport.of(context).isCompact;
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
            SizedBox(height: compact ? 40 : 64),
            BentoGrid(
              pattern: const <List<int>>[
                <int>[7, 5],
                <int>[5, 7],
                <int>[6, 6],
              ],
              minWidth: 960,
              fallbackColumns: 1,
              children: <Widget>[
                for (int i = 0; i < content.items.length; i++)
                  Reveal(
                    delay: Duration(milliseconds: 60 * (i % 2)),
                    child: FeatureCard(item: content.items[i]),
                  ),
              ],
            ),
            for (int i = 0; i < content.spotlights.length; i++) ...<Widget>[
              SizedBox(height: compact ? 64 : 112),
              Reveal(
                child: SpotlightRow(
                  spotlight: content.spotlights[i],
                  imageFirst: i.isEven,
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
