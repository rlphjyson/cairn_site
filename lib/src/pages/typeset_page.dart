import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../app/site_theme.dart';
import '../widgets/code_block.dart';
import '../widgets/surfaces.dart';

/// The typography style guide.
///
/// shadcn/ui's Typeset is a single CSS file that styles rendered HTML and
/// markdown — headings, paragraphs, lists, tables — through three rhythm
/// variables: `--typeset-size`, `--typeset-leading` and `--typeset-flow`.
/// Flutter has no cascade and no unstyled HTML to inherit, so a literal port
/// would be meaningless. What carries over is the idea: a type system that is
/// controlled by a small number of knobs rather than dozens of variables, and
/// a specimen you can look at while you turn them.
class TypesetPage extends StatefulWidget {
  /// Creates the page.
  const TypesetPage({super.key});

  @override
  State<TypesetPage> createState() => _TypesetPageState();
}

class _TypesetPageState extends State<TypesetPage> {
  double _size = 1.0;
  double _leading = 1.0;
  double _flow = 1.0;

  static const List<(String, TextStyle, String)> _scale =
      <(String, TextStyle, String)>[
        ('text-xs', CairnTypography.xs, '12 / 16 · ratio 1.333'),
        ('text-sm', CairnTypography.sm, '14 / 20 · ratio 1.429'),
        ('text-base', CairnTypography.base, '16 / 24 · ratio 1.5'),
        ('text-lg', CairnTypography.lg, '18 / 28 · ratio 1.556'),
        ('text-xl', CairnTypography.xl, '20 / 28 · ratio 1.4'),
        ('text-2xl', CairnTypography.xl2, '24 / 32 · ratio 1.333'),
        ('text-3xl', CairnTypography.xl3, '30 / 36 · ratio 1.2'),
        ('text-4xl', CairnTypography.xl4, '36 / 40 · ratio 1.111'),
      ];

  static const List<(String, FontWeight, String)> _weights =
      <(String, FontWeight, String)>[
        ('font-normal', CairnTypography.normal, 'Body copy, descriptions'),
        (
          'font-medium',
          CairnTypography.medium,
          'Button labels, Label, Alert titles',
        ),
        (
          'font-semibold',
          CairnTypography.semibold,
          'Card, Dialog and Sheet titles',
        ),
        (
          'font-bold',
          CairnTypography.bold,
          'Reserved; Cairn uses it sparingly',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'Style guide',
            title: 'Typeset',
            lead:
                'Cairn\'s type scale, live. Every size, line height, weight '
                'and tracking value on this page is read from '
                'CairnTypography — nothing here is hardcoded for the '
                'specimen\'s benefit.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          const _MappingNote(),

          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'The scale',
            subtitle:
                'Tailwind pairs a font size with an absolute line height. '
                'Flutter\'s TextStyle.height is a multiple of the font size, '
                'not a length, so every step is stored as the ratio — which is '
                'what keeps intrinsic heights correct when a user scales text.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          for (final (String name, TextStyle style, String note) in _scale)
            _ScaleRow(name: name, style: style, note: note),

          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Weights',
            subtitle:
                'Four weights, and Geist ships a real face for each — no '
                'synthetic bolding, which is what you get when a variable font '
                'is unavailable and the renderer fakes it.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          for (final (String name, FontWeight weight, String use) in _weights)
            _WeightRow(name: name, weight: weight, use: use),

          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Tracking',
            subtitle:
                'CSS letter-spacing in em is relative to the font size; '
                'Flutter\'s is absolute. CairnTypography.trackingTight(size) '
                'does the multiplication so a display heading tightens '
                'proportionally instead of by a fixed amount.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          const _TrackingDemo(),

          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Rhythm',
            subtitle:
                'Three knobs — size, leading and flow — over a prose specimen '
                'built from the same tokens. This is the part of shadcn/ui\'s '
                'Typeset that survives the translation to Flutter.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          Container(
            padding: const EdgeInsets.all(CairnSpacing.s6),
            decoration: BoxDecoration(
              color: theme.subtleSurface,
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(theme.radiusScale.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Wrap(
                  spacing: CairnSpacing.s8,
                  runSpacing: CairnSpacing.s5,
                  children: <Widget>[
                    _Knob(
                      label: 'size',
                      value: _size,
                      min: 0.85,
                      max: 1.35,
                      onChanged: (double v) => setState(() => _size = v),
                    ),
                    _Knob(
                      label: 'leading',
                      value: _leading,
                      min: 0.85,
                      max: 1.4,
                      onChanged: (double v) => setState(() => _leading = v),
                    ),
                    _Knob(
                      label: 'flow',
                      value: _flow,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (double v) => setState(() => _flow = v),
                    ),
                  ],
                ),
                const SizedBox(height: CairnSpacing.s6),
                const CairnSeparator(),
                const SizedBox(height: CairnSpacing.s6),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.background,
                    border: Border.all(color: theme.border),
                    borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(CairnSpacing.s8),
                    child: _Specimen(
                      size: _size,
                      leading: _leading,
                      flow: _flow,
                    ),
                  ),
                ),
                const SizedBox(height: CairnSpacing.s5),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'size × ${_size.toStringAsFixed(2)}   ·   '
                        'leading × ${_leading.toStringAsFixed(2)}   ·   '
                        'flow × ${_flow.toStringAsFixed(2)}',
                        style: theme
                            .textStyle(CairnTypography.xs)
                            .copyWith(
                              fontFamily: 'monospace',
                              fontFamilyFallback: SiteTokens.monoFallback,
                              color: theme.mutedForeground,
                            ),
                      ),
                    ),
                    CairnButton(
                      variant: CairnButtonVariant.ghost,
                      size: CairnButtonSize.sm,
                      onPressed: () => setState(() {
                        _size = 1.0;
                        _leading = 1.0;
                        _flow = 1.0;
                      }),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'The font',
            subtitle:
                'Cairn\'s typography tokens leave fontFamily null, exactly as '
                'shadcn/ui\'s components only ever say font-sans. One copyWith '
                'sets it for the whole app.',
          ),
          const SizedBox(height: CairnSpacing.s5),
          const CodeBlock('''
// This site, in full. Geist is bundled under fonts/ and registered in
// pubspec.yaml; nothing else needs to know about it.
static ThemeData themeData(Brightness brightness) {
  final CairnTheme base = brightness == Brightness.dark
      ? CairnTheme.dark
      : CairnTheme.light;
  return CairnTheme.materialTheme(base.copyWith(fontFamily: 'Geist'));
}'''),
          const SizedBox(height: CairnSpacing.s5),
          const Prose(
            'Geist is the typeface shadcn/ui\'s own site ships, and the one '
            'Cairn pins its golden tests to. That last part matters more than '
            'it sounds: flutter test loads no real font by default, so text '
            'lays out with a placeholder where every glyph is an identical '
            'box. Bundling the font in the repository is what makes a golden '
            'image reproducible on someone else\'s machine.',
          ),
        ],
      ),
    );
  }
}

class _MappingNote extends StatelessWidget {
  const _MappingNote();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(CairnSpacing.s5),
      decoration: BoxDecoration(
        color: theme.subtleSurface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'How this differs from shadcn/ui\'s Typeset',
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: theme.foreground,
                  fontWeight: CairnTypography.semibold,
                ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              'shadcn/typeset is one CSS file that styles unstyled HTML and '
              'rendered markdown through a container class, with three rhythm '
              'variables: --typeset-size, --typeset-leading and --typeset-flow. '
              'It exists because the web hands you a stream of h1, p, ul and '
              'table elements you did not author. Flutter has no cascade and no '
              'unstyled markup — a Text widget has no style until you give it '
              'one — so there is nothing for a prose reset to reset. The idea '
              'that survives is the small control surface, which the Rhythm '
              'section below reproduces.',
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(
                    color: theme.mutedForeground,
                    height: CairnTypography.leadingRelaxed,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleRow extends StatelessWidget {
  const _ScaleRow({
    required this.name,
    required this.style,
    required this.note,
  });

  final String name;
  final TextStyle style;
  final String note;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 760;

    final Widget meta = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          name,
          style: theme
              .textStyle(CairnTypography.xs)
              .copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: SiteTokens.monoFallback,
                color: theme.foreground,
              ),
        ),
        Text(
          note,
          style: theme
              .textStyle(CairnTypography.xs)
              .copyWith(color: theme.mutedForeground),
        ),
      ],
    );

    final Widget specimen = Text(
      'The quick brown fox jumps over the lazy dog',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textStyle(style).copyWith(color: theme.foreground),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: CairnSpacing.s6),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 160, child: meta),
                Expanded(child: specimen),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                meta,
                const SizedBox(height: CairnSpacing.s2),
                specimen,
              ],
            ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({
    required this.name,
    required this.weight,
    required this.use,
  });

  final String name;
  final FontWeight weight;
  final String use;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CairnSpacing.s5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 160,
            child: Text(
              name,
              style: theme
                  .textStyle(CairnTypography.xs)
                  .copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: SiteTokens.monoFallback,
                    color: theme.mutedForeground,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              'Measured, not remembered',
              style: theme
                  .textStyle(CairnTypography.xl2)
                  .copyWith(color: theme.foreground, fontWeight: weight),
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 900)
            SizedBox(
              width: 260,
              child: Text(
                use,
                textAlign: TextAlign.right,
                style: theme
                    .textStyle(CairnTypography.xs)
                    .copyWith(color: theme.mutedForeground),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackingDemo extends StatelessWidget {
  const _TrackingDemo();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s5,
      children: <Widget>[
        for (final (String label, TextStyle style, double size)
            in <(String, TextStyle, double)>[
              ('default', CairnTypography.xl3, 30),
              ('tracking-tight', CairnTypography.xl3, 30),
            ])
          Row(
            children: <Widget>[
              SizedBox(
                width: 160,
                child: Text(
                  label,
                  style: theme
                      .textStyle(CairnTypography.xs)
                      .copyWith(
                        fontFamily: 'monospace',
                        fontFamilyFallback: SiteTokens.monoFallback,
                        color: theme.mutedForeground,
                      ),
                ),
              ),
              Expanded(
                child: Text(
                  'Display headings tighten proportionally',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme
                      .textStyle(style)
                      .copyWith(
                        color: theme.foreground,
                        fontWeight: CairnTypography.semibold,
                        letterSpacing: label == 'default'
                            ? null
                            : CairnTypography.trackingTight(size),
                      ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Knob extends StatelessWidget {
  const _Knob({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: CairnLabel('--typeset-$label')),
              Text(
                '× ${value.toStringAsFixed(2)}',
                style: theme
                    .textStyle(CairnTypography.xs)
                    .copyWith(
                      fontFamily: 'monospace',
                      fontFamilyFallback: SiteTokens.monoFallback,
                      color: theme.mutedForeground,
                    ),
              ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s3),
          CairnSlider(
            value: value,
            min: min,
            max: max,
            step: 0.05,
            semanticLabel: label,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A prose specimen whose rhythm is driven by three multipliers.
class _Specimen extends StatelessWidget {
  const _Specimen({
    required this.size,
    required this.leading,
    required this.flow,
  });

  final double size;
  final double leading;
  final double flow;

  TextStyle _style(CairnTheme theme, TextStyle base, {FontWeight? weight}) {
    final double fontSize = (base.fontSize ?? 14) * size;
    return theme
        .textStyle(base)
        .copyWith(
          fontSize: fontSize,
          height: (base.height ?? 1.4) * leading,
          fontWeight: weight,
          color: theme.foreground,
        );
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double gap = CairnSpacing.s4 * flow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'A stack of stones that marks a route',
          style: _style(
            theme,
            CairnTypography.xl3,
            weight: CairnTypography.semibold,
          ).copyWith(letterSpacing: CairnTypography.trackingTight(30 * size)),
        ),
        SizedBox(height: gap),
        Text(
          'Cairn reproduces shadcn/ui\'s measurements rather than its code. '
          'React and Flutter share no runtime, so there was nothing to copy '
          'even in principle — what transferred was padding, radii, colour '
          'values, durations, and the behavioural contracts Radix defines.',
          style: _style(
            theme,
            CairnTypography.sm,
          ).copyWith(color: theme.mutedForeground),
        ),
        SizedBox(height: gap * 1.5),
        Text(
          'Where the numbers come from',
          style: _style(
            theme,
            CairnTypography.xl,
            weight: CairnTypography.semibold,
          ),
        ),
        SizedBox(height: gap * 0.6),
        Text(
          'Tokens were extracted from the live registry and the component '
          'source, and each one records the string it came from:',
          style: _style(
            theme,
            CairnTypography.sm,
          ).copyWith(color: theme.mutedForeground),
        ),
        SizedBox(height: gap * 0.8),
        for (final String item in const <String>[
          'Per-component Tailwind class strings for padding, height and gap',
          'The canonical light and dark token values, in OKLCH',
          'The radius formula the CLI actually writes today',
        ])
          Padding(
            padding: EdgeInsets.only(bottom: gap * 0.4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 7 * size),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.mutedForeground,
                      borderRadius: CairnRadius.brFull,
                    ),
                  ),
                ),
                const SizedBox(width: CairnSpacing.s3),
                Expanded(
                  child: Text(
                    item,
                    style: _style(
                      theme,
                      CairnTypography.sm,
                    ).copyWith(color: theme.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: gap * 0.8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: CairnSpacing.s4,
            vertical: CairnSpacing.s3 * flow,
          ),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.border, width: 2)),
          ),
          child: Text(
            'Rounding a value to a nicer number is exactly the drift this '
            'library exists to avoid.',
            style: _style(
              theme,
              CairnTypography.sm,
            ).copyWith(color: theme.mutedForeground),
          ),
        ),
        SizedBox(height: gap),
        Text(
          'oklch(0.205 0 0) → #171717',
          style: _style(theme, CairnTypography.sm).copyWith(
            fontFamily: 'monospace',
            fontFamilyFallback: SiteTokens.monoFallback,
            color: theme.foreground,
          ),
        ),
      ],
    );
  }
}
