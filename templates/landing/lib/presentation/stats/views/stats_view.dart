import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../domain/stats/models/stats_content.dart';

/// The numbers band: four figures in one bordered strip, two by two on a
/// phone.
class StatsView extends StatelessWidget {
  /// Creates the view.
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<StatsContent>(
    loadingHeight: 240,
    builder: (BuildContext context, StatsContent content) {
      final CairnTheme theme = CairnTheme.of(context);
      final bool compact = LandingViewport.of(context).isCompact;

      CairnStat stat(StatItem s) => CairnStat(
        title: Text(s.label),
        value: Text(s.value),
        description: Text(s.description),
      );

      final Widget band;
      if (compact) {
        final List<StatItem> items = content.stats;
        band = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: CairnSpacing.s3,
          children: <Widget>[
            for (int i = 0; i < items.length; i += 2)
              CairnStats(
                children: <Widget>[
                  for (int j = i; j < i + 2 && j < items.length; j++)
                    stat(items[j]),
                ],
              ),
          ],
        );
      } else {
        band = CairnStats(children: <Widget>[...content.stats.map(stat)]);
      }

      return SectionFrame(
        verticalPadding: compact ? 56 : 88,
        child: Reveal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: landingText(
                    theme,
                    CairnTypography.sm,
                    color: theme.mutedForeground,
                    weight: CairnTypography.medium,
                  ),
                ),
              ),
              const SizedBox(height: CairnSpacing.s6),
              band,
            ],
          ),
        ),
      );
    },
  );
}
