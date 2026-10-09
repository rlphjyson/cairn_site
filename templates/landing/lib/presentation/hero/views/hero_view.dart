import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_actions.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../domain/hero/models/hero_content.dart';
import '../widgets/product_mockup.dart';
import '../widgets/social_proof_line.dart';

/// The hero: announcement, headline, calls to action, social proof and the
/// product in a browser frame.
class HeroView extends StatelessWidget {
  /// Creates the view.
  const HeroView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<HeroContent>(
    loadingHeight: 720,
    builder: (BuildContext context, HeroContent hero) => _Hero(hero: hero),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.hero});

  final HeroContent hero;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final LandingViewport viewport = LandingViewport.of(context);
    final ValueChanged<String> open = LandingActions.of(context).open;
    final double headlineSize = switch (viewport.breakpoint) {
      LandingBreakpoint.compact => 38,
      LandingBreakpoint.medium => 52,
      LandingBreakpoint.expanded => 64,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            theme.muted.withValues(alpha: 0.7),
            theme.background.withValues(alpha: 0),
          ],
        ),
      ),
      child: SectionFrame(
        verticalPadding: viewport.isCompact ? 40 : 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Reveal(
              child: Semantics(
                button: true,
                child: CairnLink(
                  onPressed: () => open(hero.announcement.href),
                  child: CairnBadge(
                    variant: CairnBadgeVariant.outline,
                    label: Text(hero.announcement.label),
                    trailing: const Icon(Icons.arrow_forward, size: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: CairnSpacing.s6),
            Reveal(
              delay: const Duration(milliseconds: 60),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Semantics(
                  header: true,
                  child: Text(
                    hero.headline,
                    textAlign: TextAlign.center,
                    style: landingText(
                      theme,
                      CairnTypography.xl4,
                      size: headlineSize,
                      height: 1.08,
                      weight: CairnTypography.semibold,
                      tight: true,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: CairnSpacing.s6),
            Reveal(
              delay: const Duration(milliseconds: 120),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: Text(
                  hero.subcopy,
                  textAlign: TextAlign.center,
                  style: landingText(
                    theme,
                    viewport.isCompact
                        ? CairnTypography.base
                        : CairnTypography.xl,
                    color: theme.mutedForeground,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: CairnSpacing.s8),
            Reveal(
              delay: const Duration(milliseconds: 180),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: CairnSpacing.s3,
                runSpacing: CairnSpacing.s3,
                children: <Widget>[
                  CairnButton(
                    size: CairnButtonSize.lg,
                    onPressed: () => open(hero.primaryCta.href),
                    child: Text(hero.primaryCta.label),
                  ),
                  CairnButton(
                    size: CairnButtonSize.lg,
                    variant: CairnButtonVariant.outline,
                    onPressed: () => open(hero.secondaryCta.href),
                    child: Text(hero.secondaryCta.label),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CairnSpacing.s8),
            Reveal(
              delay: const Duration(milliseconds: 240),
              child: SocialProofLine(proof: hero.proof),
            ),
            SizedBox(height: viewport.isCompact ? 40 : 64),
            Reveal(
              delay: const Duration(milliseconds: 300),
              offset: 32,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: ProductMockup(visual: hero.visual),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
