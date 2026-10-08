import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../app/site_theme.dart';
import '../widgets/code_block.dart';
import '../widgets/preview_pane.dart';
import '../widgets/surfaces.dart';
import '../widgets/syntax.dart';

/// The project starter.
///
/// Every other page on this site answers "what does this component look like".
/// This one answers the question that comes before it: *what do I paste into an
/// empty project to get Cairn set up the way I want it?*
///
/// The controls on the left are the four decisions worth making up front —
/// package name, base radius, default theme mode, accent — and the right-hand
/// side is the consequence: a live composition rendered under exactly those
/// tokens, and three copyable files that agree with it. Nothing here is a
/// template with holes punched in it; the generated Dart is assembled from the
/// same values the preview is rendered with, so what you see and what you copy
/// cannot drift apart.
class CreatePage extends StatefulWidget {
  /// Creates the page.
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

/// One accent preset.
///
/// Cairn's default `--primary` is a neutral — near-black in light mode, near-
/// white in dark — which is the right default for a component library and a
/// dull one for an app. Each preset overrides three tokens (`primary`, its
/// foreground, and the focus `ring`, which tracks the accent so keyboard focus
/// reads as part of the brand rather than as a stray blue halo).
@immutable
class _Accent {
  const _Accent(this.name, this.primary, this.onPrimary);

  /// The neutral default — no token overrides at all.
  const _Accent.neutral() : name = 'Neutral', primary = null, onPrimary = null;

  final String name;
  final Color? primary;
  final Color? onPrimary;

  bool get isNeutral => primary == null;
}

const List<_Accent> _accents = <_Accent>[
  _Accent.neutral(),
  _Accent('Blue', Color(0xFF2563EB), Color(0xFFF8FAFC)),
  _Accent('Emerald', Color(0xFF059669), Color(0xFFF0FDF4)),
  _Accent('Amber', Color(0xFFD97706), Color(0xFF1C1917)),
  _Accent('Rose', Color(0xFFE11D48), Color(0xFFFFF1F2)),
  _Accent('Violet', Color(0xFF7C3AED), Color(0xFFF5F3FF)),
];

/// The radius presets offered next to the slider.
const List<(String, double)> _radiusPresets = <(String, double)>[
  ('Square', 0),
  ('Tight', 6),
  ('Default', CairnRadius.base),
  ('Round', 16),
];

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _name = TextEditingController(text: 'my_app');
  double _radius = CairnRadius.base;
  ThemeMode _mode = ThemeMode.dark;
  _Accent _accent = _accents.first;
  String _tab = 'main';

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    super.dispose();
  }

  void _onNameChanged() => setState(() {});

  /// The package name, reduced to something `pubspec.yaml` would accept.
  String get _package {
    final String raw = _name.text.trim().toLowerCase();
    final String cleaned = raw
        .replaceAll(RegExp('[^a-z0-9_]+'), '_')
        .replaceAll(RegExp('^_+|_+\$'), '');
    if (cleaned.isEmpty || RegExp('^[0-9]').hasMatch(cleaned)) return 'my_app';
    return cleaned;
  }

  /// `my_app` -> `MyApp`.
  String get _className => _package
      .split('_')
      .where((String part) => part.isNotEmpty)
      .map((String part) => part[0].toUpperCase() + part.substring(1))
      .join();

  /// `my_app` -> `myApp`, the prefix for the generated theme variables.
  String get _varPrefix {
    final String pascal = _className;
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// The radius, trimmed of a pointless trailing `.0` in the emitted code.
  String get _radiusLiteral => _radius.toStringAsFixed(1);

  /// The theme the preview renders under, and the one the generated code
  /// describes.
  CairnTheme _themeFor(Brightness brightness) {
    final CairnTheme base = brightness == Brightness.dark
        ? CairnTheme.dark
        : CairnTheme.light;
    return base.copyWith(
      radius: _radius,
      fontFamily: SiteTokens.fontFamily,
      primary: _accent.primary,
      primaryForeground: _accent.onPrimary,
      ring: _accent.primary,
    );
  }

  /// Which brightness the preview shows: the chosen mode, or — for `system` —
  /// whatever the site itself is currently in.
  Brightness get _previewBrightness => switch (_mode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => Theme.of(context).brightness,
  };

  String get _modeLiteral => switch (_mode) {
    ThemeMode.light => 'ThemeMode.light',
    ThemeMode.dark => 'ThemeMode.dark',
    ThemeMode.system => 'ThemeMode.system',
  };

  String get _installCode =>
      '''
flutter create --org com.example $_package
cd $_package
flutter pub add cairn_ui
''';

  String get _pubspecCode =>
      '''
name: $_package

environment:
  sdk: ^3.9.0

dependencies:
  flutter:
    sdk: flutter
  # One dependency, no code generation and no build_runner step.
  cairn_ui: ^0.2.0
''';

  String get _themeCode {
    final CairnRadiusScale scale = CairnRadiusScale(_radius);
    final StringBuffer buffer = StringBuffer()
      ..writeln("import 'package:cairn_ui/cairn_ui.dart';");
    if (!_accent.isNeutral) {
      buffer.writeln("import 'package:flutter/material.dart';");
    }
    buffer
      ..writeln()
      ..writeln('/// The base radius for $_package.')
      ..writeln('///')
      ..writeln(
        '/// Cairn derives the whole corner scale from this one number: '
        'sm = base * 0.6,',
      )
      ..writeln(
        '/// md = base * 0.8, lg = base, xl = base * 1.4, 2xl = base * 1.8. '
        'At $_radiusLiteral',
      )
      ..writeln(
        '/// that is sm ${_px(scale.sm)}, md ${_px(scale.md)}, '
        'lg ${_px(scale.lg)}, xl ${_px(scale.xl)}, 2xl ${_px(scale.xl2)}.',
      )
      ..writeln('const double kBaseRadius = $_radiusLiteral;')
      ..writeln();

    for (final (String suffix, String source) in <(String, String)>[
      ('Light', 'CairnTheme.light'),
      ('Dark', 'CairnTheme.dark'),
    ]) {
      buffer
        ..writeln('/// The $_package ${suffix.toLowerCase()} theme.')
        ..writeln('final CairnTheme $_varPrefix$suffix = $source.copyWith(')
        ..writeln('  radius: kBaseRadius,');
      if (!_accent.isNeutral) {
        buffer
          ..writeln('  primary: const Color($_accentHex),')
          ..writeln('  primaryForeground: const Color($_onAccentHex),')
          ..writeln('  ring: const Color($_accentHex),');
      }
      buffer
        ..writeln(');')
        ..writeln();
    }
    return buffer.toString().trimRight();
  }

  String get _accentHex => _hex(_accent.primary!);
  String get _onAccentHex => _hex(_accent.onPrimary!);

  String get _mainCode =>
      '''
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

void main() => runApp(const $_className());

/// The application root.
class $_className extends StatelessWidget {
  /// Creates the app.
  const $_className({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$_package',
      debugShowCheckedModeBanner: false,
      // materialTheme() registers the CairnTheme extension and aligns
      // Material's own defaults with the Cairn tokens.
      theme: CairnTheme.materialTheme(${_varPrefix}Light),
      darkTheme: CairnTheme.materialTheme(${_varPrefix}Dark),
      themeMode: $_modeLiteral,
      // CairnToaster hosts the toast overlay above the Navigator, so a toast
      // outlives the route that fired it.
      builder: (BuildContext context, Widget? child) =>
          CairnToaster(child: child ?? const SizedBox.shrink()),
      home: const HomeScreen(),
    );
  }
}

/// The first screen.
class HomeScreen extends StatelessWidget {
  /// Creates the screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Scaffold(
      backgroundColor: theme.background,
      body: Center(
        child: CairnCard(
          width: 360,
          children: <Widget>[
            const CairnCardHeader(
              title: Text('$_package'),
              description: Text('Built with Cairn UI.'),
            ),
            const CairnCardContent(
              child: CairnInput(placeholder: 'you@example.com'),
            ),
            CairnCardFooter(
              children: <Widget>[
                CairnButton(
                  onPressed: () => CairnToast.show(
                    context,
                    const CairnToast(title: 'You are set up.'),
                  ),
                  child: const Text('Get started'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
''';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= SiteTokens.desktopBreakpoint;

    final Widget controls = _ControlsCard(
      name: _name,
      radius: _radius,
      onRadius: (double value) => setState(() => _radius = value),
      mode: _mode,
      onMode: (ThemeMode value) => setState(() => _mode = value),
      accent: _accent,
      onAccent: (_Accent value) => setState(() => _accent = value),
    );

    final Widget output = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _PreviewCard(theme: _themeFor(_previewBrightness), package: _package),
        const SizedBox(height: CairnSpacing.s6),
        CairnTabs<String>(
          value: _tab,
          onChanged: (String value) => setState(() => _tab = value),
          tabs: const <CairnTab<String>>[
            CairnTab<String>(value: 'install', label: Text('Install')),
            CairnTab<String>(value: 'main', label: Text('main.dart')),
            CairnTab<String>(value: 'theme', label: Text('theme.dart')),
          ],
        ),
        const SizedBox(height: CairnSpacing.s4),
        switch (_tab) {
          'install' => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CodeBlock(
                _installCode,
                language: CodeLanguage.shell,
                filename: 'Terminal',
              ),
              const SizedBox(height: CairnSpacing.s4),
              CodeBlock(
                _pubspecCode,
                language: CodeLanguage.yaml,
                filename: 'pubspec.yaml',
              ),
            ],
          ),
          'theme' => CodeBlock(_themeCode, filename: 'lib/theme.dart'),
          _ => CodeBlock(_mainCode, filename: 'lib/main.dart', maxHeight: 620),
        },
      ],
    );

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'Start here',
            title: 'Create',
            lead:
                'Pick the handful of things worth deciding before the first '
                'commit — name, corner radius, default theme mode, accent — '
                'and take away a project that already looks like yours. The '
                'preview and the code below are generated from the same '
                'values, so they cannot disagree.',
          ),
          const SizedBox(height: CairnSpacing.s10),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 360, child: controls),
                const SizedBox(width: CairnSpacing.s8),
                Expanded(child: output),
              ],
            )
          else ...<Widget>[
            controls,
            const SizedBox(height: CairnSpacing.s8),
            output,
          ],
          const SizedBox(height: CairnSpacing.s16),
        ],
      ),
    );
  }
}

/// The left-hand column: four decisions, each a real Cairn control.
class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.name,
    required this.radius,
    required this.onRadius,
    required this.mode,
    required this.onMode,
    required this.accent,
    required this.onAccent,
  });

  final TextEditingController name;
  final double radius;
  final ValueChanged<double> onRadius;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onMode;
  final _Accent accent;
  final ValueChanged<_Accent> onAccent;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CairnRadiusScale scale = CairnRadiusScale(radius);

    return CairnCard(
      children: <Widget>[
        const CairnCardHeader(
          title: Text('Configuration'),
          description: Text(
            'Every change re-renders the preview and the code.',
          ),
        ),
        CairnCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Field(
                label: 'Package name',
                hint: 'Used for the app class and the theme variables.',
                child: CairnInput(
                  controller: name,
                  placeholder: 'my_app',
                  semanticLabel: 'Package name',
                ),
              ),
              _Field(
                label: 'Base radius · ${_px(radius)}',
                hint:
                    'sm ${_px(scale.sm)} · md ${_px(scale.md)} · '
                    'lg ${_px(scale.lg)} · xl ${_px(scale.xl)} · '
                    '2xl ${_px(scale.xl2)}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CairnSlider(
                      value: radius,
                      min: 0,
                      max: 24,
                      step: 1,
                      onChanged: onRadius,
                      semanticLabel: 'Base radius',
                    ),
                    const SizedBox(height: CairnSpacing.s3),
                    Wrap(
                      spacing: CairnSpacing.s2,
                      runSpacing: CairnSpacing.s2,
                      children: <Widget>[
                        for (final (String label, double value)
                            in _radiusPresets)
                          CairnButton(
                            size: CairnButtonSize.xs,
                            variant: radius == value
                                ? CairnButtonVariant.secondary
                                : CairnButtonVariant.outline,
                            onPressed: () => onRadius(value),
                            child: Text(label),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              _Field(
                label: 'Default theme mode',
                hint: 'What a first-time user lands on.',
                child: CairnRadioGroup<ThemeMode>(
                  value: mode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) onMode(value);
                  },
                  semanticLabel: 'Default theme mode',
                  children: const <CairnRadioItem<ThemeMode>>[
                    CairnRadioItem<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Light'),
                    ),
                    CairnRadioItem<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                    ),
                    CairnRadioItem<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('Follow the system'),
                    ),
                  ],
                ),
              ),
              _Field(
                label: 'Accent',
                hint: accent.isNeutral
                    ? 'Cairn ships neutral. No token overrides are emitted.'
                    : 'Overrides primary, its foreground and the focus ring.',
                child: CairnSelect<_Accent>(
                  value: accent,
                  onChanged: (_Accent? value) {
                    if (value != null) onAccent(value);
                  },
                  semanticLabel: 'Accent',
                  options: <CairnSelectOption<_Accent>>[
                    for (final _Accent option in _accents)
                      CairnSelectOption<_Accent>(
                        value: option,
                        label: option.name,
                        leading: _Swatch(
                          color: option.primary ?? theme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A labelled control with a hint line under it.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.hint, required this.child});

  final String label;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CairnSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CairnLabel(label),
          const SizedBox(height: CairnSpacing.s2),
          child,
          const SizedBox(height: CairnSpacing.s2),
          Text(
            hint,
            style: theme
                .textStyle(CairnTypography.xs)
                .copyWith(color: theme.mutedForeground),
          ),
        ],
      ),
    );
  }
}

/// A small colour chip, used inside the accent select.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: theme.border),
      ),
    );
  }
}

/// The live preview: a small composition rendered under the generated theme.
///
/// The whole subtree is wrapped in a real [Theme] carrying the configured
/// [CairnTheme], so the widgets inside resolve the chosen tokens exactly the
/// way they would in the generated app — this is not a mock-up drawn with the
/// site's own colours and a border radius painted on top.
class _PreviewCard extends StatefulWidget {
  const _PreviewCard({required this.theme, required this.package});

  final CairnTheme theme;
  final String package;

  @override
  State<_PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<_PreviewCard> {
  bool _notify = true;

  @override
  Widget build(BuildContext context) {
    return PreviewSurface(
      padding: EdgeInsets.zero,
      fillWidth: true,
      minContentWidth: 280,
      child: Theme(
        data: CairnTheme.materialTheme(widget.theme),
        child: Builder(
          builder: (BuildContext context) {
            final CairnTheme theme = CairnTheme.of(context);
            return ColoredBox(
              color: theme.background,
              child: Padding(
                padding: const EdgeInsets.all(CairnSpacing.s8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: CairnCard(
                      children: <Widget>[
                        CairnCardHeader(
                          title: Text(widget.package),
                          description: const Text(
                            'A live composition on your tokens.',
                          ),
                          action: const CairnBadge(
                            label: Text('Preview'),
                            variant: CairnBadgeVariant.secondary,
                          ),
                        ),
                        CairnCardContent(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const CairnInput(
                                placeholder: 'you@example.com',
                                semanticLabel: 'Email',
                              ),
                              const SizedBox(height: CairnSpacing.s4),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      'Email me about releases',
                                      style: theme.textStyle(
                                        CairnTypography.sm,
                                      ),
                                    ),
                                  ),
                                  CairnSwitch(
                                    value: _notify,
                                    semanticLabel: 'Email me about releases',
                                    onChanged: (bool value) =>
                                        setState(() => _notify = value),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CairnCardFooter(
                          children: <Widget>[
                            CairnButton(
                              onPressed: () {},
                              child: const Text('Create project'),
                            ),
                            CairnButton(
                              variant: CairnButtonVariant.outline,
                              onPressed: () {},
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Formats a derived radius the way the scale reads best: `9.6` not `9.600000`.
String _px(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0')
      ? '${text.substring(0, text.length - 2)}px'
      : '${text}px';
}

/// `Color(0xFF2563EB)` -> the literal, upper-cased, for the emitted code.
String _hex(Color color) {
  final int argb =
      ((color.a * 255).round() << 24) |
      ((color.r * 255).round() << 16) |
      ((color.g * 255).round() << 8) |
      (color.b * 255).round();
  return '0x${argb.toRadixString(16).toUpperCase().padLeft(8, '0')}';
}
