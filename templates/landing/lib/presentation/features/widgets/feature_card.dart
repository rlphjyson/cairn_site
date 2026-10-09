import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_icons.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../domain/features/models/features_content.dart';

/// One card in the feature grid: an icon tile, a title and a description.
class FeatureCard extends StatelessWidget {
  /// Creates the card.
  const FeatureCard({super.key, required this.item});

  /// The feature.
  final FeatureItem item;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnCard(
      gap: CairnSpacing.s4,
      children: <Widget>[
        CairnCardContent(
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.muted,
                  borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                  border: Border.all(color: theme.border),
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    LandingIcons.byName(item.icon),
                    size: 22,
                    color: theme.foreground,
                  ),
                ),
              ),
              const Spacer(),
              if (item.tag != null)
                CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text(item.tag!),
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
                child: Text(
                  item.title,
                  style: landingText(
                    theme,
                    CairnTypography.lg,
                    weight: CairnTypography.semibold,
                    tight: true,
                  ),
                ),
              ),
              const SizedBox(height: CairnSpacing.s2),
              Text(
                item.description,
                style: landingText(
                  theme,
                  CairnTypography.sm,
                  color: theme.mutedForeground,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
