import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import 'variant_sample.dart';

/// Live previews for the Extended components, the ones added in cairn_ui
/// 0.2.0.
///
/// Kept apart from `Previews` only to keep that file readable; the rules in its
/// header apply unchanged. Every snippet is a complete expression that
/// reproduces the widget beside it, and every preview sizes itself.
abstract final class ExtendedPreviews {
  /// A stats group.
  static VariantSet stat(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Stats group',
        code: '''
const CairnStats(
  children: <Widget>[
    CairnStat(
      title: Text('Total revenue'),
      value: Text(r'\$31,200'),
      description: Text('+12% from last month'),
    ),
    CairnStat(
      title: Text('Active users'),
      value: Text('4,200'),
      description: Text('+180 this week'),
    ),
    CairnStat(
      title: Text('Error rate'),
      value: Text('0.4%'),
      description: Text('Within budget'),
    ),
  ],
)''',
        child: CairnStats(
          children: <Widget>[
            CairnStat(
              title: Text('Total revenue'),
              value: Text(r'$31,200'),
              description: Text('+12% from last month'),
            ),
            CairnStat(
              title: Text('Active users'),
              value: Text('4,200'),
              description: Text('+180 this week'),
            ),
            CairnStat(
              title: Text('Error rate'),
              value: Text('0.4%'),
              description: Text('Within budget'),
            ),
          ],
        ),
      ),
      VariantSample(
        label: 'Single stat',
        code: '''
const CairnStat(
  title: Text('Active users'),
  value: Text('4,200'),
  description: Text('+180 this week'),
)''',
        child: CairnStat(
          title: Text('Active users'),
          value: Text('4,200'),
          description: Text('+180 this week'),
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s6,
    width: 640,
  );

  /// Every [CairnTone] as a fill with its on-fill label.
  ///
  /// Reads the colours through `CairnToneColors.resolve`, so the swatches are
  /// the live token values for the current light or dark theme.
  static VariantSet tones(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        for (final CairnTone tone in CairnTone.values)
          VariantSample(
            label: tone.name,
            code:
                'final CairnToneColor c = '
                'CairnToneColors.resolve(theme, CairnTone.${tone.name});',
            child: _ToneSwatch(tone: tone),
          ),
      ], spacing: CairnSpacing.s2);

  /// Tone dots.
  static VariantSet status(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Neutral',
          code: 'const CairnStatus(tone: CairnTone.neutral)',
          child: CairnStatus(tone: CairnTone.neutral),
        ),
        VariantSample(
          label: 'Success · ping',
          code: 'const CairnStatus(tone: CairnTone.success, ping: true)',
          child: CairnStatus(tone: CairnTone.success, ping: true),
        ),
        VariantSample(
          label: 'Warning',
          code: 'const CairnStatus(tone: CairnTone.warning)',
          child: CairnStatus(tone: CairnTone.warning),
        ),
        VariantSample(
          label: 'Info',
          code: 'const CairnStatus(tone: CairnTone.info)',
          child: CairnStatus(tone: CairnTone.info),
        ),
        VariantSample(
          label: 'Destructive',
          code: 'const CairnStatus(tone: CairnTone.destructive)',
          child: CairnStatus(tone: CairnTone.destructive),
        ),
      ], spacing: CairnSpacing.s6);

  /// A checkout flow.
  static VariantSet steps(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Horizontal',
          code: '''
const CairnSteps(
  current: 1,
  steps: <CairnStep>[
    CairnStep(label: 'Cart', description: 'Review items'),
    CairnStep(label: 'Shipping', description: 'Where to?'),
    CairnStep(label: 'Payment', description: 'Pay securely'),
    CairnStep(label: 'Done'),
  ],
)''',
          child: CairnSteps(
            current: 1,
            steps: <CairnStep>[
              CairnStep(label: 'Cart', description: 'Review items'),
              CairnStep(label: 'Shipping', description: 'Where to?'),
              CairnStep(label: 'Payment', description: 'Pay securely'),
              CairnStep(label: 'Done'),
            ],
          ),
        ),
      ], width: 520);

  /// A vertical event rail.
  static VariantSet timeline(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Release history',
          code: '''
const CairnTimeline(
  items: <CairnTimelineItem>[
    CairnTimelineItem(
      tone: CairnTone.success,
      icon: CairnIcon(CairnIconData.check),
      title: Text('Deployed to production'),
      description: Text('Build 482 passed all checks.'),
      time: Text('2m ago'),
    ),
    CairnTimelineItem(
      tone: CairnTone.info,
      title: Text('Review approved'),
      time: Text('1h ago'),
    ),
    CairnTimelineItem(
      title: Text('Pull request opened'),
      description: Text('Add the extended components.'),
      time: Text('Yesterday'),
    ),
  ],
)''',
          child: CairnTimeline(
            items: <CairnTimelineItem>[
              CairnTimelineItem(
                tone: CairnTone.success,
                icon: CairnIcon(CairnIconData.check),
                title: Text('Deployed to production'),
                description: Text('Build 482 passed all checks.'),
                time: Text('2m ago'),
              ),
              CairnTimelineItem(
                tone: CairnTone.info,
                title: Text('Review approved'),
                time: Text('1h ago'),
              ),
              CairnTimelineItem(
                title: Text('Pull request opened'),
                description: Text('Add the extended components.'),
                time: Text('Yesterday'),
              ),
            ],
          ),
        ),
      ], width: 380);

  /// Received and sent bubbles.
  static VariantSet chatBubble(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Received',
        code: '''
const CairnChatBubble(
  author: Text('Ada'),
  footer: Text('10:02'),
  child: Text('Did the release go out?'),
)''',
        child: CairnChatBubble(
          author: Text('Ada'),
          footer: Text('10:02'),
          child: Text('Did the release go out?'),
        ),
      ),
      VariantSample(
        label: 'Sent',
        code: '''
const CairnChatBubble(
  side: CairnChatSide.sent,
  footer: Text('Delivered'),
  child: Text('Shipped. Watching the dashboards now.'),
)''',
        child: CairnChatBubble(
          side: CairnChatSide.sent,
          footer: Text('Delivered'),
          child: Text('Shipped. Watching the dashboards now.'),
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s2,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 420,
  );

  /// Interactive and read-only ratings.
  static VariantSet rating(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Interactive · half steps',
        code: '''
CairnRating(
  value: _rating,
  allowHalf: true,
  onChanged: (double v) => setState(() => _rating = v),
)''',
        child: _RatingSample(),
      ),
      VariantSample(
        label: 'Read-only',
        code: 'const CairnRating(value: 4.5)',
        child: CairnRating(value: 4.5),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s3,
  );

  /// Rings.
  static VariantSet radialProgress(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Value',
        code: 'const CairnRadialProgress(value: 0.25, showValue: true)',
        child: CairnRadialProgress(value: 0.25, showValue: true),
      ),
      VariantSample(
        label: 'Success tone',
        code: '''
const CairnRadialProgress(
  value: 0.7,
  tone: CairnTone.success,
  showValue: true,
)''',
        child: CairnRadialProgress(
          value: 0.7,
          tone: CairnTone.success,
          showValue: true,
        ),
      ),
      VariantSample(
        label: 'Custom child',
        code: '''
const CairnRadialProgress(
  value: 1,
  size: 80,
  tone: CairnTone.info,
  child: CairnIcon(CairnIconData.check, size: 24),
)''',
        child: CairnRadialProgress(
          value: 1,
          size: 80,
          tone: CairnTone.info,
          child: CairnIcon(CairnIconData.check, size: 24),
        ),
      ),
    ],
    spacing: CairnSpacing.s5,
    crossAxisAlignment: CrossAxisAlignment.center,
  );

  /// A live countdown.
  static VariantSet countdown(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Days and hours',
        code:
            'const CairnCountdown(duration: Duration(hours: 26, minutes: 14))',
        child: CairnCountdown(duration: Duration(hours: 26, minutes: 14)),
      ),
      VariantSample(
        label: 'Minutes only',
        code: 'const CairnCountdown(duration: Duration(minutes: 5))',
        child: CairnCountdown(duration: Duration(minutes: 5)),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s5,
  );

  /// Badges pinned to a corner.
  static VariantSet indicator(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Badge',
          code: '''
const CairnIndicator(
  indicator: CairnBadge(label: Text('3')),
  child: CairnAvatar(fallback: Text('RB')),
)''',
          child: CairnIndicator(
            indicator: CairnBadge(label: Text('3')),
            child: CairnAvatar(fallback: Text('RB')),
          ),
        ),
        VariantSample(
          label: 'Status dot',
          code: '''
const CairnIndicator(
  placement: CairnIndicatorPlacement.bottomEnd,
  offset: Offset(-4, -4),
  indicator: CairnStatus(tone: CairnTone.success, size: 10),
  child: CairnAvatar(fallback: Text('AL')),
)''',
          child: CairnIndicator(
            placement: CairnIndicatorPlacement.bottomEnd,
            offset: Offset(-4, -4),
            indicator: CairnStatus(tone: CairnTone.success, size: 10),
            child: CairnAvatar(fallback: Text('AL')),
          ),
        ),
      ], spacing: CairnSpacing.s8);

  /// Overlapping layers.
  static VariantSet stack(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Cards',
          code: '''
CairnStack(
  children: <Widget>[
    for (int i = 0; i < 3; i++)
      CairnCard(
        children: <Widget>[CairnCardHeader(title: Text('Card \${i + 1}'))],
      ),
  ],
)''',
          child: CairnStack(
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                CairnCard(
                  children: <Widget>[
                    CairnCardHeader(title: Text('Card ${i + 1}')),
                  ],
                ),
            ],
          ),
        ),
      ], width: 220);

  /// Two-face toggles.
  static VariantSet swap(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        for (final CairnSwapEffect effect in CairnSwapEffect.values)
          VariantSample(
            label: 'Effect · ${effect.name}',
            code:
                '''
CairnSwap(
  effect: CairnSwapEffect.${effect.name},
  value: _on,
  onChanged: (bool v) => setState(() => _on = v),
  semanticLabel: 'Swap ${effect.name}',
  on: const CairnBadge(label: Text('${effect.name}: on')),
  off: const CairnBadge(
    variant: CairnBadgeVariant.outline,
    label: Text('${effect.name}: off'),
  ),
)''',
            child: _SwapSample(effect: effect),
          ),
      ], spacing: CairnSpacing.s6);

  /// A top bar.
  static VariantSet navbar(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return VariantSet.one(<VariantSample>[
      VariantSample(
        label: 'Start, centre and end',
        code: '''
CairnNavbar(
  start: const Text('Cairn'),
  center: const CairnBadge(
    variant: CairnBadgeVariant.secondary,
    label: Text('v0.2'),
  ),
  end: CairnButton(
    size: CairnButtonSize.sm,
    onPressed: () {},
    child: const Text('Sign in'),
  ),
)''',
        child: _Framed(
          child: CairnNavbar(
            start: Text(
              'Cairn',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.foreground,
              ),
            ),
            center: const CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text('v0.2'),
            ),
            end: CairnButton(
              size: CairnButtonSize.sm,
              onPressed: () {},
              child: const Text('Sign in'),
            ),
          ),
        ),
      ),
    ], width: 640);
  }

  /// A mobile bottom bar.
  static VariantSet dock(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Three items · badge',
          code: '''
CairnDock(
  index: _tab,
  onChanged: (int i) => setState(() => _tab = i),
  items: const <CairnDockItem>[
    CairnDockItem(icon: CairnIcon(CairnIconData.search), label: 'Search'),
    CairnDockItem(
      icon: CairnIcon(CairnIconData.info),
      label: 'Inbox',
      badge: CairnStatus(tone: CairnTone.destructive),
    ),
    CairnDockItem(
      icon: CairnIcon(CairnIconData.moreHorizontal),
      label: 'More',
    ),
  ],
)''',
          child: _DockSample(),
        ),
      ], width: 360);

  /// A landing-page header block.
  static VariantSet hero(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Muted',
          code: '''
CairnHero(
  muted: true,
  eyebrow: const CairnBadge(label: Text('New')),
  title: const Text('Build interfaces that hold together'),
  description: const Text(
    'Tokens first, widgets second — so a theme change is one edit, not a hunt.',
  ),
  actions: <Widget>[
    CairnButton(onPressed: () {}, child: const Text('Get started')),
    CairnButton(
      variant: CairnButtonVariant.outline,
      onPressed: () {},
      child: const Text('Browse components'),
    ),
  ],
)''',
          child: CairnHero(
            muted: true,
            eyebrow: const CairnBadge(label: Text('New')),
            title: const Text('Build interfaces that hold together'),
            description: const Text(
              'Tokens first, widgets second — so a theme change is one edit, '
              'not a hunt.',
            ),
            actions: <Widget>[
              CairnButton(onPressed: () {}, child: const Text('Get started')),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () {},
                child: const Text('Browse components'),
              ),
            ],
          ),
        ),
      ], width: 640);

  /// A before/after comparison.
  static VariantSet diff(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return VariantSet.one(<VariantSample>[
      VariantSample(
        label: 'Draggable divider',
        code: '''
CairnDiff(
  aspectRatio: 16 / 9,
  before: ColoredBox(
    color: theme.muted,
    child: Center(
      child: Text('Before', style: TextStyle(color: theme.mutedForeground)),
    ),
  ),
  after: ColoredBox(
    color: theme.primary,
    child: Center(
      child: Text('After', style: TextStyle(color: theme.primaryForeground)),
    ),
  ),
)''',
        child: CairnDiff(
          aspectRatio: 16 / 9,
          before: ColoredBox(
            color: theme.muted,
            child: Center(
              child: Text(
                'Before',
                style: TextStyle(color: theme.mutedForeground),
              ),
            ),
          ),
          after: ColoredBox(
            color: theme.primary,
            child: Center(
              child: Text(
                'After',
                style: TextStyle(color: theme.primaryForeground),
              ),
            ),
          ),
        ),
      ),
    ], width: 420);
  }

  /// A file picker control.
  static VariantSet fileInput(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Browse and clear',
        code: '''
CairnFileInput(
  fileName: _file,
  onBrowse: () => setState(() => _file = 'quarterly-report.pdf'),
  onClear: () => setState(() => _file = null),
)''',
        child: _FileInputSample(),
      ),
      VariantSample(
        label: 'Invalid',
        code: 'CairnFileInput(invalid: true, onBrowse: () {})',
        child: _InvalidFileInput(),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s4,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 360,
  );

  /// A bordered list.
  static VariantSet list(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Bordered',
          code: '''
CairnList(
  bordered: true,
  children: <Widget>[
    CairnListItem(
      leading: const CairnAvatar(fallback: Text('RB')),
      title: const Text('Ralph'),
      subtitle: const Text('Owner'),
      trailing: const CairnBadge(label: Text('Admin')),
      onTap: () {},
    ),
    CairnListItem(
      leading: const CairnAvatar(fallback: Text('AL')),
      title: const Text('Ada'),
      subtitle: const Text('Maintainer'),
      trailing: const CairnBadge(
        variant: CairnBadgeVariant.secondary,
        label: Text('Member'),
      ),
      onTap: () {},
    ),
  ],
)''',
          child: CairnList(
            bordered: true,
            children: <Widget>[
              CairnListItem(
                leading: const CairnAvatar(fallback: Text('RB')),
                title: const Text('Ralph'),
                subtitle: const Text('Owner'),
                trailing: const CairnBadge(label: Text('Admin')),
                onTap: () {},
              ),
              CairnListItem(
                leading: const CairnAvatar(fallback: Text('AL')),
                title: const Text('Ada'),
                subtitle: const Text('Maintainer'),
                trailing: const CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text('Member'),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ], width: 420);

  /// Text links.
  static VariantSet link(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Default',
          code: '''
CairnLink(
  onPressed: () {},
  child: const Text('Read the docs'),
)''',
          child: CairnLink(
            onPressed: () {},
            child: const Text('Read the docs'),
          ),
        ),
        VariantSample(
          label: 'Muted · underlined',
          code: '''
CairnLink(
  onPressed: () {},
  muted: true,
  underline: true,
  child: const Text('Privacy policy'),
)''',
          child: CairnLink(
            onPressed: () {},
            muted: true,
            underline: true,
            child: const Text('Privacy policy'),
          ),
        ),
        const VariantSample(
          label: 'Disabled',
          code: '''
const CairnLink(
  onPressed: null,
  child: Text('Disabled'),
)''',
          child: CairnLink(onPressed: null, child: Text('Disabled')),
        ),
      ], spacing: CairnSpacing.s6);

  /// Floating action buttons.
  static VariantSet fab(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'Single action',
        code: '''
CairnFab(
  icon: const CairnIcon(CairnIconData.plus),
  semanticLabel: 'Create',
  onPressed: () {},
)''',
        child: CairnFab(
          icon: const CairnIcon(CairnIconData.plus),
          semanticLabel: 'Create',
          onPressed: () {},
        ),
      ),
      VariantSample(
        label: 'Speed dial',
        code: '''
CairnFab(
  icon: const CairnIcon(CairnIconData.plus),
  semanticLabel: 'Create',
  actions: <CairnFabAction>[
    CairnFabAction(
      icon: const CairnIcon(CairnIconData.search),
      label: 'Document',
      onPressed: () {},
    ),
    CairnFabAction(
      icon: const CairnIcon(CairnIconData.info),
      label: 'Folder',
      onPressed: () {},
    ),
  ],
)''',
        child: CairnFab(
          icon: const CairnIcon(CairnIconData.plus),
          semanticLabel: 'Create',
          actions: <CairnFabAction>[
            CairnFabAction(
              icon: const CairnIcon(CairnIconData.search),
              label: 'Document',
              onPressed: () {},
            ),
            CairnFabAction(
              icon: const CairnIcon(CairnIconData.info),
              label: 'Folder',
              onPressed: () {},
            ),
          ],
        ),
      ),
    ],
    spacing: CairnSpacing.s12,
    crossAxisAlignment: CrossAxisAlignment.end,
  );

  /// Window, browser, code and phone frames.
  static VariantSet mockup(BuildContext context) =>
      const VariantSet(<VariantGroup>[
        VariantGroup(
          <VariantSample>[
            VariantSample(
              label: 'Browser',
              code: '''
CairnMockupBrowser(
  url: 'https://cairn.dev',
  child: SizedBox(height: 96),
)''',
              child: CairnMockupBrowser(
                url: 'https://cairn.dev',
                child: SizedBox(height: 96),
              ),
            ),
            VariantSample(
              label: 'Window',
              code: '''
CairnMockupWindow(
  title: Text('Terminal'),
  child: SizedBox(height: 56),
)''',
              child: CairnMockupWindow(
                title: Text('Terminal'),
                child: SizedBox(height: 56),
              ),
            ),
            VariantSample(
              label: 'Code',
              code: '''
CairnMockupCode(
  lines: <String>['flutter pub add cairn_ui', 'flutter run'],
  highlight: <int>{0},
)''',
              child: CairnMockupCode(
                lines: <String>['flutter pub add cairn_ui', 'flutter run'],
                highlight: <int>{0},
              ),
            ),
          ],
          layout: VariantLayout.column,
          spacing: CairnSpacing.s4,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
        VariantGroup(<VariantSample>[
          VariantSample(
            label: 'Phone',
            code: '''
CairnMockupPhone(
  width: 200,
  child: Center(child: Text('Your app')),
)''',
            child: CairnMockupPhone(
              width: 200,
              child: Center(child: Text('Your app')),
            ),
          ),
        ]),
      ], width: 360);
}

/// Rounds and outlines a full-width bar so it reads as a component rather than
/// bleeding into the surface behind it.
class _Framed extends StatelessWidget {
  const _Framed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        border: Border.all(color: theme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        child: child,
      ),
    );
  }
}

class _RatingSample extends StatefulWidget {
  const _RatingSample();

  @override
  State<_RatingSample> createState() => _RatingSampleState();
}

class _RatingSampleState extends State<_RatingSample> {
  double _value = 3.5;

  @override
  Widget build(BuildContext context) => CairnRating(
    value: _value,
    allowHalf: true,
    onChanged: (double v) => setState(() => _value = v),
  );
}

class _SwapSample extends StatefulWidget {
  const _SwapSample({required this.effect});

  final CairnSwapEffect effect;

  @override
  State<_SwapSample> createState() => _SwapSampleState();
}

class _SwapSampleState extends State<_SwapSample> {
  bool _on = false;

  @override
  Widget build(BuildContext context) => CairnSwap(
    effect: widget.effect,
    value: _on,
    onChanged: (bool v) => setState(() => _on = v),
    semanticLabel: 'Swap ${widget.effect.name}',
    on: CairnBadge(label: Text('${widget.effect.name}: on')),
    off: CairnBadge(
      variant: CairnBadgeVariant.outline,
      label: Text('${widget.effect.name}: off'),
    ),
  );
}

class _DockSample extends StatefulWidget {
  const _DockSample();

  @override
  State<_DockSample> createState() => _DockSampleState();
}

class _DockSampleState extends State<_DockSample> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => _Framed(
    child: CairnDock(
      index: _index,
      onChanged: (int i) => setState(() => _index = i),
      items: const <CairnDockItem>[
        CairnDockItem(icon: CairnIcon(CairnIconData.search), label: 'Search'),
        CairnDockItem(
          icon: CairnIcon(CairnIconData.info),
          label: 'Inbox',
          badge: CairnStatus(tone: CairnTone.destructive),
        ),
        CairnDockItem(
          icon: CairnIcon(CairnIconData.moreHorizontal),
          label: 'More',
        ),
      ],
    ),
  );
}

class _FileInputSample extends StatefulWidget {
  const _FileInputSample();

  @override
  State<_FileInputSample> createState() => _FileInputSampleState();
}

class _FileInputSampleState extends State<_FileInputSample> {
  String? _file;

  @override
  Widget build(BuildContext context) => CairnFileInput(
    fileName: _file,
    onBrowse: () => setState(() => _file = 'quarterly-report.pdf'),
    onClear: () => setState(() => _file = null),
  );
}

class _InvalidFileInput extends StatelessWidget {
  const _InvalidFileInput();

  @override
  Widget build(BuildContext context) =>
      CairnFileInput(invalid: true, onBrowse: () {});
}

class _ToneSwatch extends StatelessWidget {
  const _ToneSwatch({required this.tone});

  final CairnTone tone;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CairnToneColor colors = CairnToneColors.resolve(theme, tone);
    return Container(
      width: 96,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(theme.radiusScale.md),
      ),
      child: Text(
        tone.name,
        style: theme
            .textStyle(CairnTypography.sm)
            .copyWith(color: colors.onFill, fontWeight: CairnTypography.medium),
      ),
    );
  }
}
