import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_actions.dart';
import '../../../core/presentation/landing_image.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../domain/features/models/features_content.dart';
import '../../../domain/shared/models/link.dart';

/// An image beside its copy; [imageFirst] picks the side. Below the desktop
/// breakpoint the image always comes first, above the copy.
class SpotlightRow extends StatelessWidget {
  /// Creates the row.
  const SpotlightRow({
    super.key,
    required this.spotlight,
    required this.imageFirst,
  });

  /// The content.
  final Spotlight spotlight;

  /// Whether the image sits at the leading edge on desktop.
  final bool imageFirst;

  @override
  Widget build(BuildContext context) {
    final bool wide = LandingViewport.of(context).isExpanded;
    final Widget image = _SpotlightImage(spotlight: spotlight, wide: wide);
    final Widget copy = _SpotlightCopy(spotlight: spotlight);

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s8,
        children: <Widget>[image, copy],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: CairnSpacing.s16,
      children: <Widget>[
        Expanded(child: imageFirst ? image : copy),
        Expanded(child: imageFirst ? copy : image),
      ],
    );
  }
}

class _SpotlightImage extends StatelessWidget {
  const _SpotlightImage({required this.spotlight, required this.wide});

  final Spotlight spotlight;

  /// Whether the image shares a row with the copy.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = LandingViewport.of(context).isCompact;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusScale.xl2),
        border: Border.all(color: theme.border),
        boxShadow: CairnShadows.lg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.xl2 - 1),
        child: AspectRatio(
          aspectRatio: compact || wide ? 4 / 3 : 16 / 9,
          child: LandingPhoto(
            spotlight.image,
            semanticLabel: spotlight.imageAlt,
          ),
        ),
      ),
    );
  }
}

class _SpotlightCopy extends StatelessWidget {
  const _SpotlightCopy({required this.spotlight});

  final Spotlight spotlight;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = LandingViewport.of(context).isCompact;
    final ValueChanged<String> open = LandingActions.of(context).open;
    final Link? cta = spotlight.cta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CairnBadge(
          variant: CairnBadgeVariant.outline,
          label: Text(spotlight.eyebrow),
        ),
        const SizedBox(height: CairnSpacing.s4),
        Semantics(
          header: true,
          child: Text(
            spotlight.title,
            style: landingText(
              theme,
              CairnTypography.xl3,
              size: compact ? 28 : 34,
              height: 1.2,
              weight: CairnTypography.semibold,
              tight: true,
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s4),
        Text(
          spotlight.description,
          style: landingText(
            theme,
            CairnTypography.base,
            color: theme.mutedForeground,
            height: 1.65,
          ),
        ),
        const SizedBox(height: CairnSpacing.s6),
        for (final String bullet in spotlight.bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: CairnSpacing.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s3,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 20,
                    child: Center(
                      child: CairnIcon(
                        CairnIconData.check,
                        size: 12,
                        color: theme.primaryForeground,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    bullet,
                    style: landingText(
                      theme,
                      CairnTypography.base,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (cta != null) ...<Widget>[
          const SizedBox(height: CairnSpacing.s2),
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => open(cta.href),
            trailing: const Icon(Icons.arrow_forward, size: 16),
            child: Text(cta.label),
          ),
        ],
      ],
    );
  }
}
