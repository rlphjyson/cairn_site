import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../domain/shared/models/app_screen.dart';
import '../app_landing_icons.dart';
import '../app_landing_text.dart';

/// One mock app screen, drawn from Cairn widgets.
///
/// It is laid out at [designSize], the inner size of a [CairnMockupPhone]
/// 280 wide, and meant to be scaled down by a `FittedBox` (see `MockPhone`).
/// To add a screen: add a [ScreenKind], write a `_Body` widget for it below
/// and add it to the switch in [build]. Everything it shows comes from the
/// [AppScreen], so the copy stays in the content JSON.
class AppScreenView extends StatelessWidget {
  /// Creates the screen.
  const AppScreenView({super.key, required this.screen});

  /// What to draw.
  final AppScreen screen;

  /// The size the screen is laid out at.
  static const Size designSize = Size(260, 587);

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool goals = screen.kind == ScreenKind.goals;
    return DefaultTextStyle(
      style: theme.defaultTextStyle,
      child: ColoredBox(
        color: theme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Room for the phone's notch and status bar.
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    screen.title,
                    maxLines: 2,
                    style: appLandingText(
                      theme,
                      CairnTypography.xl2,
                      size: goals ? 21 : 24,
                      weight: CairnTypography.semibold,
                      height: 1.15,
                      tight: true,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    screen.subtitle,
                    maxLines: 2,
                    style: appLandingText(
                      theme,
                      CairnTypography.xs,
                      color: theme.mutedForeground,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: switch (screen.kind) {
                  ScreenKind.today => _TodayBody(screen: screen),
                  ScreenKind.progress => _ProgressBody(screen: screen),
                  ScreenKind.calendar => _CalendarBody(screen: screen),
                  ScreenKind.settings => _SettingsBody(screen: screen),
                  ScreenKind.goals => _GoalsBody(screen: screen),
                },
              ),
            ),
            CairnDock(
              height: 56,
              index: screen.tab,
              onChanged: (int _) {},
              items: <CairnDockItem>[
                CairnDockItem(
                  icon: const Icon(Icons.check_circle_outline),
                  label: screen.dock[0],
                ),
                CairnDockItem(
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: screen.dock[1],
                ),
                CairnDockItem(
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: screen.dock[2],
                ),
                CairnDockItem(
                  icon: const Icon(Icons.settings_outlined),
                  label: screen.dock[3],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded square holding a glyph, used as a row's leading slot.
class _IconTile extends StatelessWidget {
  const _IconTile(this.name, {this.active = false});

  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? theme.primary : theme.muted,
        borderRadius: BorderRadius.circular(theme.radiusScale.md),
      ),
      child: SizedBox.square(
        dimension: 30,
        child: Icon(
          AppLandingIcons.byName(name),
          size: 16,
          color: active ? theme.primaryForeground : theme.mutedForeground,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: appLandingText(
        theme,
        CairnTypography.sm,
        weight: CairnTypography.medium,
        height: 1.3,
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: appLandingText(
        theme,
        CairnTypography.xs,
        color: theme.mutedForeground,
        height: 1.3,
      ),
    );
  }
}

/// A list row sized for the phone screen.
class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.title,
    required this.detail,
    required this.trailing,
  });

  final Widget leading;
  final String title;
  final String detail;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    child: Row(
      spacing: 10,
      children: <Widget>[
        leading,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_Title(title), _Caption(detail)],
          ),
        ),
        trailing,
      ],
    ),
  );
}

class _Bordered extends StatelessWidget {
  const _Bordered({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0)
                ColoredBox(
                  color: theme.border,
                  child: const SizedBox(height: 1),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayBody extends StatelessWidget {
  const _TodayBody({required this.screen});

  final AppScreen screen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int done = screen.items.where((ScreenItem i) => i.done).length;
    final int total = screen.items.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          spacing: 14,
          children: <Widget>[
            CairnRadialProgress(
              value: total == 0 ? 0 : done / total,
              size: 62,
              thickness: 7,
              child: Text(
                '${(total == 0 ? 0 : done * 100 / total).round()}%',
                style: appLandingText(
                  theme,
                  CairnTypography.xs,
                  weight: CairnTypography.semibold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    screen.headline,
                    style: appLandingText(
                      theme,
                      CairnTypography.xl2,
                      weight: CairnTypography.semibold,
                      tight: true,
                      height: 1.1,
                    ),
                  ),
                  _Caption(screen.caption),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Bordered(
          children: <Widget>[
            for (final ScreenItem item in screen.items)
              _Row(
                leading: _IconTile(item.icon, active: item.done),
                title: item.label,
                detail: item.detail,
                trailing: item.done
                    ? CairnIcon(
                        CairnIconData.circleCheck,
                        size: 20,
                        color: theme.primary,
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.input, width: 1.5),
                        ),
                        child: const SizedBox.square(dimension: 20),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.screen});

  final AppScreen screen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    const double chartHeight = 92;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Bordered(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    spacing: 8,
                    children: <Widget>[
                      Icon(
                        Icons.local_fire_department,
                        size: 24,
                        color: theme.primary,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              screen.headline,
                              style: appLandingText(
                                theme,
                                CairnTypography.lg,
                                weight: CairnTypography.semibold,
                                tight: true,
                                height: 1.15,
                              ),
                            ),
                            _Caption(screen.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: chartHeight + 18,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 6,
                      children: <Widget>[
                        for (int i = 0; i < screen.bars.length; i++)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: screen.bars[i] >= 0.99
                                        ? theme.primary
                                        : theme.primary.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(
                                      theme.radiusScale.sm,
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: (chartHeight * screen.bars[i])
                                        .clamp(4.0, chartHeight),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 14,
                                  child: Text(
                                    i < screen.barLabels.length
                                        ? screen.barLabels[i]
                                        : '',
                                    style: appLandingText(
                                      theme,
                                      CairnTypography.xs,
                                      color: theme.mutedForeground,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Bordered(
          children: <Widget>[
            for (final ScreenItem item in screen.items)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: _Title(item.label)),
                        _Caption(item.detail),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CairnProgress(value: item.value, height: 6),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CalendarBody extends StatelessWidget {
  const _CalendarBody({required this.screen});

  final AppScreen screen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    const List<String> weekdays = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final int lead = screen.startWeekday - 1;
    final int weeks = ((lead + screen.daysInMonth) / 7).ceil();

    Widget cell(int day) {
      if (day < 1 || day > screen.daysInMonth) return const SizedBox.shrink();
      final bool active = screen.activeDays.contains(day);
      final bool today = day == screen.today;
      return Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? theme.primary : null,
            border: today && !active
                ? Border.all(color: theme.primary, width: 1.5)
                : null,
          ),
          child: SizedBox.square(
            dimension: 28,
            child: Center(
              child: Text(
                '$day',
                style: appLandingText(
                  theme,
                  CairnTypography.xs,
                  color: active
                      ? theme.primaryForeground
                      : today
                      ? theme.foreground
                      : theme.mutedForeground,
                  weight: active || today
                      ? CairnTypography.semibold
                      : CairnTypography.normal,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Bordered(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: theme.mutedForeground,
                      ),
                      Expanded(
                        child: Text(
                          screen.monthLabel,
                          textAlign: TextAlign.center,
                          style: appLandingText(
                            theme,
                            CairnTypography.sm,
                            weight: CairnTypography.semibold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.mutedForeground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      for (final String d in weekdays)
                        Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: appLandingText(
                                theme,
                                CairnTypography.xs,
                                color: theme.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  for (int w = 0; w < weeks; w++)
                    SizedBox(
                      height: 32,
                      child: Row(
                        children: <Widget>[
                          for (int d = 0; d < 7; d++)
                            Expanded(child: cell(w * 7 + d - lead + 1)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Bordered(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 10,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 12),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Title(screen.headline),
                        _Caption(screen.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The first letters of the first two words: `Alex Morgan` -> `AM`.
String _initials(String name) => name
    .split(RegExp(r's+'))
    .where((String p) => p.isNotEmpty)
    .take(2)
    .map((String p) => p[0].toUpperCase())
    .join();

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.screen});

  final AppScreen screen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Bordered(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 10,
                children: <Widget>[
                  CairnAvatar(
                    fallback: Text(_initials(screen.headline)),
                    size: CairnAvatarSize.lg,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Title(screen.headline),
                        _Caption(screen.caption),
                      ],
                    ),
                  ),
                  CairnBadge(label: Text(screen.badge)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Bordered(
          children: <Widget>[
            for (final ScreenItem item in screen.items)
              _Row(
                leading: _IconTile(item.icon, active: item.on),
                title: item.label,
                detail: item.detail,
                trailing: CairnSwitch(
                  value: item.on,
                  size: CairnSwitchSize.sm,
                  onChanged: (bool _) {},
                ),
              ),
          ],
        ),
        const Spacer(),
        Center(
          child: Text(
            screen.footnote,
            style: appLandingText(
              theme,
              CairnTypography.xs,
              color: theme.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _GoalsBody extends StatelessWidget {
  const _GoalsBody({required this.screen});

  final AppScreen screen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    Widget chip(ScreenItem item) => DecoratedBox(
      decoration: BoxDecoration(
        color: item.done ? theme.accent : theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(
          color: item.done ? theme.primary : theme.border,
          width: item.done ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _IconTile(item.icon, active: item.done),
                if (item.done)
                  CairnIcon(
                    CairnIconData.circleCheck,
                    size: 18,
                    color: theme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _Title(item.label),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < screen.items.length; i += 2) ...<Widget>[
          Row(
            spacing: 10,
            children: <Widget>[
              Expanded(child: chip(screen.items[i])),
              Expanded(
                child: i + 1 < screen.items.length
                    ? chip(screen.items[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        const Spacer(),
        CairnButton(
          expand: true,
          onPressed: () {},
          child: Text(screen.headline),
        ),
        const SizedBox(height: 6),
        Center(child: _Caption(screen.caption)),
        const SizedBox(height: 10),
      ],
    );
  }
}
