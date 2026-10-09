import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../core/presentation/app_landing_actions.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/store_buttons.dart';
import '../../../domain/hero/models/hero_content.dart';
import '../widgets/hero_phones.dart';
import '../widgets/rating_line.dart';

/// The hero: headline, store buttons, the rating line and two overlapping
/// phones showing live screens of the app.
class HeroView extends StatelessWidget {
  /// Creates the view.
  const HeroView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<HeroContent>(
    loadingHeight: 760,
    builder: (BuildContext context, HeroContent content) =>
        _Hero(content: content),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.content});

  final HeroContent content;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AppLandingViewport viewport = AppLandingViewport.of(context);
    final bool wide = viewport.isExpanded;
    final bool compact = viewport.isCompact;
    final ValueChanged<String> open = AppLandingActions.of(context).open;

    final double headlineSize = compact ? 42 : (wide ? 64 : 56);
    final CrossAxisAlignment align = wide
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final TextAlign textAlign = wide ? TextAlign.start : TextAlign.center;

    final Widget copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: <Widget>[
        Reveal(
          child: CairnBadge(
            variant: CairnBadgeVariant.secondary,
            leading: const Icon(Icons.auto_awesome, size: 12),
            label: Text(content.badge),
          ),
        ),
        const SizedBox(height: CairnSpacing.s5),
        Reveal(
          delay: const Duration(milliseconds: 60),
          child: Semantics(
            header: true,
            child: Text(
              content.headline,
              textAlign: textAlign,
              style: appLandingText(
                theme,
                CairnTypography.xl4,
                size: headlineSize,
                height: 1.04,
                weight: CairnTypography.semibold,
                tight: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s5),
        Reveal(
          delay: const Duration(milliseconds: 120),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              content.subcopy,
              textAlign: textAlign,
              style: appLandingText(
                theme,
                compact ? CairnTypography.base : CairnTypography.lg,
                color: theme.mutedForeground,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s8),
        Reveal(
          delay: const Duration(milliseconds: 180),
          child: StoreButtons(
            alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          ),
        ),
        const SizedBox(height: CairnSpacing.s3),
        Reveal(
          delay: const Duration(milliseconds: 220),
          child: CairnLink(
            onPressed: () => open(content.secondaryCta.href),
            child: Text(content.secondaryCta.label),
          ),
        ),
        const SizedBox(height: CairnSpacing.s8),
        Reveal(
          delay: const Duration(milliseconds: 260),
          child: RatingLine(content: content, centered: !wide),
        ),
      ],
    );

    final Widget phones = HeroPhones(
      front: content.frontScreen,
      back: content.backScreen,
    );

    return SectionFrame(
      verticalPadding: compact ? 40 : (wide ? 72 : 64),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: CairnSpacing.s8,
              children: <Widget>[
                Expanded(flex: 6, child: copy),
                Expanded(flex: 5, child: phones),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                copy,
                SizedBox(height: compact ? 40 : 56),
                phones,
              ],
            ),
    );
  }
}
