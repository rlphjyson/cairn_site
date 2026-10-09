import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/app_landing_icons.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/equal_height_grid.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/how_it_works/models/how_it_works_content.dart';

/// The numbered steps: setting up, planning, shipping.
class HowItWorksView extends StatelessWidget {
  /// Creates the view.
  const HowItWorksView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<HowItWorksContent>(
    loadingHeight: 520,
    builder: (BuildContext context, HowItWorksContent content) {
      final bool compact = AppLandingViewport.of(context).isCompact;
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
              columnsFor: (double w) =>
                  w >= 900 ? content.steps.length.clamp(1, 3) : 1,
              children: <Widget>[
                for (int i = 0; i < content.steps.length; i++)
                  Reveal(
                    delay: Duration(milliseconds: 80 * i),
                    child: _StepCard(index: i, step: content.steps[i]),
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step});

  final int index;
  final StepItem step;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnCard(
      gap: CairnSpacing.s5,
      children: <Widget>[
        CairnCardContent(
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 40,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: appLandingText(
                        theme,
                        CairnTypography.lg,
                        color: theme.primaryForeground,
                        weight: CairnTypography.semibold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                AppLandingIcons.byName(step.icon),
                size: 28,
                color: theme.mutedForeground,
              ),
            ],
          ),
        ),
        CairnCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Semantics(
                header: true,
                label: 'Step ${index + 1}: ${step.title}',
                excludeSemantics: true,
                child: Text(
                  step.title,
                  style: appLandingText(
                    theme,
                    CairnTypography.xl,
                    weight: CairnTypography.semibold,
                    tight: true,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: CairnSpacing.s2p5),
              Text(
                step.description,
                style: appLandingText(
                  theme,
                  CairnTypography.sm,
                  color: theme.mutedForeground,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
