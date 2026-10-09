import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_icons.dart';
import '../../../core/presentation/landing_image.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../domain/hero/models/hero_content.dart';

/// The product in a browser frame: a small project dashboard assembled from
/// Cairn widgets and the content's own data, so there is no screenshot to
/// keep in sync and it follows light and dark.
class ProductMockup extends StatelessWidget {
  /// Creates the mockup.
  const ProductMockup({super.key, required this.visual});

  /// What the dashboard shows.
  final ProductVisual visual;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        boxShadow: CairnShadows.xl2,
      ),
      child: Semantics(
        label: 'Preview of the ${visual.project} project dashboard',
        container: true,
        child: CairnMockupBrowser(
          url: visual.url,
          child: _Dashboard(visual: visual),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.visual});

  final ProductVisual visual;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final bool sidebar = width >= 760;
        final bool twoColumns = width >= 640;
        final double pad = width < 480 ? CairnSpacing.s3 : CairnSpacing.s5;

        final Widget chart = _ChartTile(visual: visual);
        final Widget tasks = _TasksTile(visual: visual);

        return ColoredBox(
          color: theme.muted.withValues(alpha: 0.35),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (sidebar) _Sidebar(entries: visual.sidebar),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      spacing: pad,
                      children: <Widget>[
                        _Header(visual: visual, showTeam: width >= 480),
                        Row(
                          spacing: width < 480
                              ? CairnSpacing.s2
                              : CairnSpacing.s3,
                          children: <Widget>[
                            for (final VisualMetric m in visual.metrics)
                              Expanded(child: _MetricTile(metric: m)),
                          ],
                        ),
                        if (twoColumns)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: pad,
                              children: <Widget>[
                                Expanded(flex: 5, child: chart),
                                Expanded(flex: 6, child: tasks),
                              ],
                            ),
                          )
                        else ...<Widget>[chart, tasks],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.entries});

  final List<SidebarEntry> entries;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      width: 184,
      padding: const EdgeInsets.all(CairnSpacing.s3),
      decoration: BoxDecoration(
        color: theme.card,
        border: Border(right: BorderSide(color: theme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: CairnSpacing.s1,
        children: <Widget>[
          for (final SidebarEntry e in entries)
            DecoratedBox(
              decoration: BoxDecoration(
                color: e.active ? theme.accent : null,
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CairnSpacing.s2p5,
                  vertical: CairnSpacing.s2,
                ),
                child: Row(
                  spacing: CairnSpacing.s2p5,
                  children: <Widget>[
                    Icon(
                      LandingIcons.byName(e.icon),
                      size: 16,
                      color: e.active
                          ? theme.accentForeground
                          : theme.mutedForeground,
                    ),
                    Expanded(
                      child: Text(
                        e.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: landingText(
                          theme,
                          CairnTypography.sm,
                          weight: e.active
                              ? CairnTypography.medium
                              : CairnTypography.normal,
                          color: e.active
                              ? theme.accentForeground
                              : theme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.visual, required this.showTeam});

  final ProductVisual visual;

  /// Whether there is room for the team avatars next to the title.
  final bool showTeam;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      spacing: CairnSpacing.s3,
      children: <Widget>[
        Expanded(
          child: Row(
            spacing: CairnSpacing.s3,
            children: <Widget>[
              Flexible(
                child: Text(
                  visual.project,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: landingText(
                    theme,
                    CairnTypography.xl,
                    weight: CairnTypography.semibold,
                    tight: true,
                  ),
                ),
              ),
              CairnBadge(
                variant: CairnBadgeVariant.secondary,
                label: Text(visual.status),
              ),
            ],
          ),
        ),
        if (showTeam)
          CairnAvatarGroup(
            size: CairnAvatarSize.sm,
            children: <Widget>[
              for (final String asset in visual.team)
                CairnAvatar(
                  size: CairnAvatarSize.sm,
                  image: landingImage(asset),
                ),
            ],
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        border: Border.all(color: theme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CairnSpacing.s3p5),
        child: child,
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final VisualMetric metric;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color good = CairnToneColors.resolve(theme, CairnTone.success).fill;
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: landingText(
              theme,
              CairnTypography.xs,
              color: theme.mutedForeground,
            ),
          ),
          const SizedBox(height: CairnSpacing.s1),
          Text(
            metric.value,
            style: landingText(
              theme,
              CairnTypography.xl2,
              weight: CairnTypography.semibold,
              tight: true,
            ),
          ),
          Text(
            metric.delta,
            style: landingText(
              theme,
              CairnTypography.xs,
              color: good,
              weight: CairnTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartTile extends StatelessWidget {
  const _ChartTile({required this.visual});

  final ProductVisual visual;

  static const double _barArea = 96;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<double> bars = visual.bars;
    int peak = 0;
    for (int i = 1; i < bars.length; i++) {
      if (bars[i] > bars[peak]) peak = i;
    }
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            visual.chartTitle,
            style: landingText(
              theme,
              CairnTypography.sm,
              weight: CairnTypography.medium,
            ),
          ),
          const SizedBox(height: CairnSpacing.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: CairnSpacing.s2,
            children: <Widget>[
              for (int i = 0; i < bars.length; i++)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: _barArea,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: bars[i],
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: i == peak
                                    ? theme.primary
                                    : theme.primary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(theme.radiusScale.sm),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: CairnSpacing.s1p5),
                      Text(
                        i < visual.barLabels.length ? visual.barLabels[i] : '',
                        style: landingText(
                          theme,
                          CairnTypography.xs,
                          color: theme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasksTile extends StatelessWidget {
  const _TasksTile({required this.visual});

  final ProductVisual visual;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            visual.tasksTitle,
            style: landingText(
              theme,
              CairnTypography.sm,
              weight: CairnTypography.medium,
            ),
          ),
          for (final VisualTask t in visual.tasks) ...<Widget>[
            const SizedBox(height: CairnSpacing.s3),
            Row(
              spacing: CairnSpacing.s2p5,
              children: <Widget>[
                CairnAvatar(
                  size: CairnAvatarSize.sm,
                  image: landingImage(t.owner),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    spacing: CairnSpacing.s1p5,
                    children: <Widget>[
                      Text(
                        t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: landingText(
                          theme,
                          CairnTypography.xs,
                          weight: CairnTypography.medium,
                        ),
                      ),
                      CairnProgress(
                        value: t.progress,
                        height: 4,
                        semanticLabel:
                            '${t.title}, ${(t.progress * 100).round()}% done',
                      ),
                    ],
                  ),
                ),
                CairnBadge(
                  variant: CairnBadgeVariant.outline,
                  label: Text(t.status),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
