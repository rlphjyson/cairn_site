import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/app_landing_image.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../domain/stats/models/stats_content.dart';

/// The numbers band: a photo with a caption beside four figures in bordered
/// strips, two by two.
class StatsView extends StatelessWidget {
  /// Creates the view.
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<StatsContent>(
    loadingHeight: 520,
    builder: (BuildContext context, StatsContent content) {
      final CairnTheme theme = CairnTheme.of(context);
      final AppLandingViewport viewport = AppLandingViewport.of(context);
      final bool wide = viewport.isExpanded;
      final bool compact = viewport.isCompact;

      CairnStat stat(StatItem s) => CairnStat(
        title: Text(s.label),
        value: Text(s.value),
        description: Text(s.description),
      );

      final List<StatItem> items = content.stats;
      final Widget figures = Column(
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

      final Widget photo = _PhotoCard(
        asset: content.photo,
        label: content.photoLabel,
        caption: content.caption,
        height: wide ? 440 : (compact ? 220 : 280),
      );

      final Widget heading = Semantics(
        header: true,
        child: Text(
          content.title,
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: appLandingText(
            theme,
            CairnTypography.xl2,
            size: compact ? 24 : 28,
            weight: CairnTypography.semibold,
            tight: true,
          ),
        ),
      );

      return SectionFrame(
        tinted: true,
        verticalPadding: compact ? 56 : 88,
        child: Reveal(
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: CairnSpacing.s8,
                  children: <Widget>[
                    Expanded(flex: 5, child: photo),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          heading,
                          const SizedBox(height: CairnSpacing.s6),
                          figures,
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    heading,
                    const SizedBox(height: CairnSpacing.s6),
                    photo,
                    const SizedBox(height: CairnSpacing.s6),
                    figures,
                  ],
                ),
        ),
      );
    },
  );
}

/// A photograph with a caption on a dark gradient at its foot.
///
/// The gradient and the caption's white are fixed rather than themed: they sit
/// on a photograph, not on the page, so they must read the same in light and
/// dark mode.
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.asset,
    required this.label,
    required this.caption,
    required this.height,
  });

  final String asset;
  final String label;
  final String caption;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(theme.radiusScale.xl3),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AppLandingPhoto(
            asset,
            semanticLabel: label,
            alignment: const Alignment(0, -0.35),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x00000000), Color(0xB3000000)],
                stops: <double>[0.45, 1],
              ),
            ),
          ),
          Positioned(
            left: CairnSpacing.s6,
            right: CairnSpacing.s6,
            bottom: CairnSpacing.s6,
            child: Text(
              caption,
              style: appLandingText(
                theme,
                CairnTypography.xl,
                color: const Color(0xFFFFFFFF),
                weight: CairnTypography.semibold,
                height: 1.3,
                tight: true,
              ),
            ),
          ),
        ],
      ),
    );
    return height == null ? card : SizedBox(height: height, child: card);
  }
}
