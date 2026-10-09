import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_icons.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../domain/logos/models/logo_cloud.dart';

/// The trusted-by strip: invented companies drawn as a glyph and a wordmark
/// set in text, so no real brand marks are involved.
class LogosView extends StatelessWidget {
  /// Creates the view.
  const LogosView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<LogoCloud>(
    loadingHeight: 160,
    builder: (BuildContext context, LogoCloud cloud) {
      final CairnTheme theme = CairnTheme.of(context);
      final bool compact = LandingViewport.of(context).isCompact;
      return SectionFrame(
        verticalPadding: compact ? 40 : 56,
        child: Reveal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                cloud.heading,
                textAlign: TextAlign.center,
                style: landingText(
                  theme,
                  CairnTypography.sm,
                  color: theme.mutedForeground,
                  weight: CairnTypography.medium,
                ),
              ),
              SizedBox(height: compact ? CairnSpacing.s6 : CairnSpacing.s8),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: compact ? CairnSpacing.s8 : CairnSpacing.s12,
                runSpacing: CairnSpacing.s6,
                children: <Widget>[
                  for (final CompanyLogo logo in cloud.logos)
                    _Wordmark(logo: logo),
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
  const _Wordmark({required this.logo});

  final CompanyLogo logo;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = theme.mutedForeground;
    final TextStyle base = landingText(
      theme,
      CairnTypography.xl,
      color: color,
      height: 1.2,
    );
    final TextStyle style = switch (logo.style) {
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
        fontSize: 17,
      ),
    };
    return Semantics(
      label: logo.name,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s2,
        children: <Widget>[
          Icon(LandingIcons.byName(logo.icon), size: 24, color: color),
          Text(logo.name, style: style),
        ],
      ),
    );
  }
}
