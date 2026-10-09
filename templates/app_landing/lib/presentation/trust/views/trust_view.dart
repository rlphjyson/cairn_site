import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/app_landing_icons.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../domain/trust/models/trust_content.dart';

/// The press and awards strip: publication names set as text wordmarks (no
/// real brand marks) over a row of award badges.
class TrustView extends StatelessWidget {
  /// Creates the view.
  const TrustView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<TrustContent>(
    loadingHeight: 280,
    builder: (BuildContext context, TrustContent content) {
      final CairnTheme theme = CairnTheme.of(context);
      final bool compact = AppLandingViewport.of(context).isCompact;
      return SectionFrame(
        tinted: true,
        verticalPadding: compact ? 40 : 56,
        child: Reveal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  content.heading,
                  textAlign: TextAlign.center,
                  style: appLandingText(
                    theme,
                    CairnTypography.sm,
                    color: theme.mutedForeground,
                    weight: CairnTypography.medium,
                  ),
                ),
              ),
              SizedBox(height: compact ? CairnSpacing.s6 : CairnSpacing.s8),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: compact ? CairnSpacing.s8 : CairnSpacing.s12,
                runSpacing: CairnSpacing.s5,
                children: <Widget>[
                  for (final PressMention m in content.press)
                    _Wordmark(mention: m),
                ],
              ),
              SizedBox(height: compact ? CairnSpacing.s8 : CairnSpacing.s10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: CairnSpacing.s3,
                runSpacing: CairnSpacing.s3,
                children: <Widget>[
                  for (final Award a in content.awards) _AwardBadge(award: a),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.mention});

  final PressMention mention;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle base = appLandingText(
      theme,
      CairnTypography.xl,
      color: theme.mutedForeground,
      height: 1.2,
    );
    final TextStyle style = switch (mention.style) {
      WordmarkStyle.bold => base.copyWith(
        fontWeight: CairnTypography.bold,
        letterSpacing: -0.4,
      ),
      WordmarkStyle.light => base.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: 1.6,
      ),
      WordmarkStyle.italic => base.copyWith(
        fontWeight: CairnTypography.semibold,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.2,
      ),
      WordmarkStyle.spaced => base.copyWith(
        fontWeight: CairnTypography.medium,
        letterSpacing: 2.4,
        fontSize: 15,
      ),
    };
    return Semantics(
      label: '${mention.name}: ${mention.quote}',
      excludeSemantics: true,
      child: Text(mention.name, style: style),
    );
  }
}

class _AwardBadge extends StatelessWidget {
  const _AwardBadge({required this.award});

  final Award award;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      label: '${award.title}, ${award.issuer}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(theme.radiusScale.xl),
          border: Border.all(color: theme.border),
          boxShadow: CairnShadows.xs,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CairnSpacing.s4,
            vertical: CairnSpacing.s3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: CairnSpacing.s3,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.muted,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 36,
                  child: Icon(
                    AppLandingIcons.byName(award.icon),
                    size: 20,
                    color: theme.foreground,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    award.title,
                    style: appLandingText(
                      theme,
                      CairnTypography.sm,
                      weight: CairnTypography.semibold,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    award.issuer,
                    style: appLandingText(
                      theme,
                      CairnTypography.xs,
                      color: theme.mutedForeground,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
