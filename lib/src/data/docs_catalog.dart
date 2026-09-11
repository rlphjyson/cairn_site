import 'package:flutter/widgets.dart';

import '../widgets/syntax.dart';
import 'component_previews.dart';

/// One renderable piece of a documentation page.
sealed class DocNode {
  /// Base constructor.
  const DocNode();
}

/// A section heading. Becomes an anchor target and a "On this page" entry.
class DocHeading extends DocNode {
  /// Creates a heading.
  const DocHeading(this.text, {this.level = 2});

  /// The heading text.
  final String text;

  /// 2 for `h2`, 3 for `h3`.
  final int level;

  /// The slug used as the fragment identifier.
  String get id => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
}

/// A paragraph of prose.
class DocParagraph extends DocNode {
  /// Creates a paragraph.
  const DocParagraph(this.text);

  /// The body copy.
  final String text;
}

/// A fenced code block.
class DocCode extends DocNode {
  /// Creates a code block.
  const DocCode(this.code, {this.language = CodeLanguage.dart, this.filename});

  /// The source.
  final String code;

  /// Which grammar to highlight with.
  final CodeLanguage language;

  /// Shown in the block header.
  final String? filename;
}

/// A bulleted or numbered list.
class DocList extends DocNode {
  /// Creates a list.
  const DocList(this.items, {this.ordered = false});

  /// The entries.
  final List<String> items;

  /// Whether to number them.
  final bool ordered;
}

/// A highlighted aside.
class DocCallout extends DocNode {
  /// Creates a callout.
  const DocCallout({
    required this.title,
    required this.body,
    this.destructive = false,
  });

  /// The bold first line.
  final String title;

  /// The body.
  final String body;

  /// Renders in the destructive palette.
  final bool destructive;
}

/// A two- or three-column reference table.
class DocTable extends DocNode {
  /// Creates a table.
  const DocTable({required this.headers, required this.rows});

  /// Column headings.
  final List<String> headers;

  /// Row cells, each the same length as [headers].
  final List<List<String>> rows;
}

/// A live widget embedded in the prose.
class DocPreview extends DocNode {
  /// Creates an embedded preview.
  const DocPreview(this.builder, {this.caption});

  /// Builds the widget.
  final WidgetBuilder builder;

  /// A line under the preview.
  final String? caption;
}

/// One documentation page.
@immutable
class DocPage {
  /// Creates a page.
  const DocPage({
    required this.title,
    required this.slug,
    required this.group,
    required this.summary,
    required this.nodes,
  });

  /// The `h1` and the sidebar label.
  final String title;

  /// The URL segment.
  final String slug;

  /// The sidebar group heading.
  final String group;

  /// The lead paragraph under the title.
  final String summary;

  /// The page body.
  final List<DocNode> nodes;

  /// The route for this page.
  String get path => '/docs/$slug';

  /// The headings that should appear in "On this page".
  List<DocHeading> get outline => nodes
      .whereType<DocHeading>()
      .where((DocHeading h) => h.level == 2)
      .toList();
}

/// Looks up a page by slug.
DocPage? findDoc(String slug) {
  for (final DocPage page in docsCatalog) {
    if (page.slug == slug) return page;
  }
  return null;
}

/// The sidebar groups, in order.
const List<String> docGroups = <String>[
  'Get started',
  'Customisation',
  'Quality',
];

/// Every documentation page, in sidebar order.
const List<DocPage> docsCatalog = <DocPage>[
  // =========================================================================
  DocPage(
    title: 'Introduction',
    slug: 'introduction',
    group: 'Get started',
    summary:
        'Cairn is a modern, accessible component library for Flutter, built on '
        'one design-token layer: spacing, radii, OKLCH colour, a type scale, '
        'shadows and a focus-ring treatment, all specified once and held in '
        'place by golden tests.',
    nodes: <DocNode>[
      DocHeading('What this is'),
      DocParagraph(
        'Forty-five components, no runtime dependencies beyond Flutter itself, '
        'and a token layer where every value records the source string it was '
        'converted from. It is a widget package: no backend, no network layer, '
        'no platform channels, no native code.',
      ),
      DocParagraph(
        'The site you are reading is built with it. The navigation bar, the '
        'search trigger, the code block copy buttons, the preview/code tabs, '
        'the mobile navigation sheet and the command palette behind Ctrl+K are '
        'all Cairn widgets doing a real job, not demonstrations sitting in a '
        'grid. If a component regresses upstream, this site breaks.',
      ),

      DocHeading('What "token-driven" means here'),
      DocParagraph(
        'Plenty of libraries describe themselves as token-driven and still '
        'hardcode a 13 somewhere inside a widget. Cairn treats that as a bug, '
        'and the claim it makes is narrow enough to be checkable:',
      ),
      DocList(<String>[
        'No component hardcodes a value that belongs in a token file. Padding, '
            'height, gap, radius, font size, shadow, ring width and transition '
            'all resolve to a named token.',
        'Every conversion between CSS semantics and Flutter semantics is '
            'explicit and documented where the two disagree — of which there '
            'are more than you would expect.',
        'Golden tests lock the rendered result down, so the implementation '
            'cannot drift once it is right.',
      ], ordered: true),

      DocHeading('How the values are specified'),
      DocParagraph(
        'The design system is written in CSS terms — the notation this kind of '
        'system is normally expressed in — and converted into Flutter once, in '
        'the token layer, rather than ad hoc at each call site.',
      ),
      DocTable(
        headers: <String>['Written as', 'Becomes'],
        rows: <List<String>>[
          <String>[
            'Tailwind-style utility strings (h-9, px-4, gap-2, text-sm)',
            'Per-component padding, height, gap, font size, shadow, ring and '
                'transition constants',
          ],
          <String>[
            'oklch() custom properties, light and dark',
            'The nineteen semantic colour slots plus the five-step chart ramp',
          ],
          <String>[
            'A multiplier formula over a single --radius base',
            'The rounded-* radius scale, rescalable from one number',
          ],
          <String>[
            'Tailwind CSS v4\'s published scales',
            'The 0.25rem spacing base, the type scale and the box-shadow values',
          ],
        ],
      ),
      DocParagraph(
        'Each token file records the source string next to the converted '
        'value, so the provenance of any number is one click away in the '
        'source:',
      ),
      DocCode(
        '''
/// `--primary: oklch(0.205 0 0)` — `#171717` (neutral-900).
static const Color lightPrimary = Color(0xFF171717);''',
        filename: 'lib/src/tokens/colors.dart',
      ),

      DocHeading('Four conversions that are easy to get wrong'),
      DocParagraph(
        'CSS and Flutter agree on far less than they appear to. These are the '
        'four places where a literal reading of a value produces something '
        'visibly wrong, and they are the reason the conversions live in one '
        'documented layer rather than being repeated per component:',
      ),
      DocList(<String>[
        'Colour is defined in OKLCH, not HSL. OKLCH is perceptually uniform, '
            'so a lightness step means the same thing at every hue — which is '
            'what makes an achromatic ramp stay neutral. Anything that '
            'round-trips the palette through HSL loses that.',
        'The radius scale is multiplier-based, not offset-based. Every step is '
            '--radius × a factor (0.6, 0.8, 1.0, 1.4, 1.8), so setting one '
            'number rescales a whole app proportionally. Fixed ± 4px offsets '
            'agree at the default and diverge the moment --radius is '
            'customised.',
        'A CSS blur radius is not a Flutter blur radius. CSS treats it as '
            'twice the Gaussian sigma; Flutter feeds it through Skia\'s '
            'radius × 0.57735 + 0.5. Pasting the number across draws a shadow '
            'roughly 50% too wide.',
        'An opacity modifier scales alpha, it does not set it. A token that '
            'already carries 15% alpha, taken to /30, lands at 4.5% — not 30%. '
            'Six times too strong is very visible on a dark-mode form control.',
      ]),
      DocCallout(
        title: 'A correctness check fell out of the conversion',
        body:
            'Every achromatic step lands exactly on Tailwind\'s published '
            'neutral hex ramp — oklch(0.145 0 0) → #0A0A0A = neutral-950, '
            'oklch(0.922 0 0) → #E5E5E5 = neutral-200, and so on. '
            'test/tokens/tokens_test.dart asserts this, which means a bug in '
            'the OKLCH → sRGB pipeline could not pass CI unnoticed.',
      ),

      DocHeading('What it deliberately does not do'),
      DocParagraph(
        'Cairn does not ship a form-validation engine — Flutter has Form and '
        'FormField, and competing with them would fight the framework. It does '
        'not ship a theme-builder UI, and it does not ship icon assets: the '
        'handful of glyphs components need are drawn from Lucide\'s geometry '
        'with a CustomPainter, so the package stays pure Dart.',
      ),
    ],
  ),

  // =========================================================================
  DocPage(
    title: 'Installation',
    slug: 'installation',
    group: 'Get started',
    summary:
        'Cairn is a normal Flutter package with no transitive dependencies. '
        'Add it, import one barrel, and register the theme extension.',
    nodes: <DocNode>[
      DocHeading('Add the dependency'),
      DocParagraph('From pub.dev, once published:'),
      DocCode(
        '''
dependencies:
  cairn_ui: ^0.1.0''',
        language: CodeLanguage.yaml,
        filename: 'pubspec.yaml',
      ),
      DocParagraph(
        'Or straight from git. Pin an exact commit rather than a branch — a '
        'floating ref means an upstream push can change what your app renders '
        'between two builds of the same source, which turns a visual '
        'regression into a mystery. This site\'s own pubspec does exactly '
        'this:',
      ),
      DocCode(
        '''
dependencies:
  cairn_ui:
    git:
      url: https://github.com/rlphjyson/cairn_ui.git
      ref: 7abb0cc70dea5daaeefda0a93ae94e0c0d2bf737''',
        language: CodeLanguage.yaml,
        filename: 'pubspec.yaml',
      ),
      DocCode('flutter pub get', language: CodeLanguage.shell),

      DocHeading('Import'),
      DocParagraph(
        'One barrel exports every component, token and theme type. There are '
        'no per-component imports to remember.',
      ),
      DocCode("import 'package:cairn_ui/cairn_ui.dart';"),

      DocHeading('Register the theme'),
      DocParagraph(
        'CairnTheme is a ThemeExtension, so it rides on ThemeData rather than '
        'introducing a second theme system. CairnTheme.materialTheme() builds '
        'a ThemeData whose Material defaults already agree with the Cairn '
        'tokens:',
      ),
      DocCode('''
MaterialApp(
  theme: CairnTheme.materialTheme(CairnTheme.light),
  darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
  themeMode: ThemeMode.dark,
  home: const HomeScreen(),
)'''),
      DocCallout(
        title: 'Components never throw for a missing theme',
        body:
            'CairnTheme.of(context) falls back to CairnTheme.light rather than '
            'asserting, so a Cairn widget dropped into an app that never '
            'registered the extension still renders with correct tokens. '
            'Register the extension to control which theme is used, not to '
            'make things work at all.',
      ),

      DocHeading('Fonts'),
      DocParagraph(
        'Cairn\'s typography tokens leave fontFamily null — the type scale is '
        'about size, line height, weight and tracking, not about which '
        'typeface you use. Whatever your app sets is inherited. To use the '
        'font this site and the golden tests use, bundle Geist and set it once '
        'on the theme:',
      ),
      DocCode('''
CairnTheme.materialTheme(
  CairnTheme.dark.copyWith(fontFamily: 'Geist'),
)'''),
      DocParagraph(
        'That is precisely what this site does — Geist is bundled under '
        'fonts/, registered in pubspec.yaml, and applied with a single '
        'copyWith at the theme root.',
      ),

      DocHeading('Platform support'),
      DocParagraph(
        'There is nothing platform-specific to break: no platform channels, '
        'no native code, no plugins. The package declares every target Flutter '
        'supports. This site is the Flutter web build.',
      ),
    ],
  ),

  // =========================================================================
  DocPage(
    title: 'Quick start',
    slug: 'quick-start',
    group: 'Get started',
    summary:
        'A complete, runnable app in about thirty lines, and the three '
        'patterns you will use constantly.',
    nodes: <DocNode>[
      DocHeading('A complete app'),
      DocCode('''
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CairnTheme.materialTheme(CairnTheme.light),
      darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
      themeMode: ThemeMode.dark,
      // The toast host sits above every route, so a toast outlives the
      // screen that fired it.
      builder: (BuildContext context, Widget? child) =>
          CairnToaster(child: child ?? const SizedBox.shrink()),
      home: Scaffold(
        body: Center(
          child: CairnCard(
            width: 360,
            children: <Widget>[
              const CairnCardHeader(
                title: Text('Deploy your project'),
                description: Text('Ship to production in one click.'),
              ),
              CairnCardFooter(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CairnButton(
                    variant: CairnButtonVariant.outline,
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                  CairnButton(onPressed: () {}, child: const Text('Deploy')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}''', filename: 'lib/main.dart'),
      DocPreview(Previews.card, caption: 'What that renders.'),

      DocHeading('Reading tokens'),
      DocParagraph(
        'Anywhere you need a colour, a radius or a type style in your own '
        'widgets, read it from the theme rather than hardcoding it. This is '
        'how everything on this site is built:',
      ),
      DocCode('''
final CairnTheme theme = CairnTheme.of(context);

Container(
  padding: const EdgeInsets.all(CairnSpacing.s4),
  decoration: BoxDecoration(
    color: theme.card,
    border: Border.all(color: theme.border),
    borderRadius: BorderRadius.circular(theme.radiusScale.lg),
  ),
  child: Text(
    'Custom surface, Cairn tokens',
    style: theme
        .textStyle(CairnTypography.sm)
        .copyWith(color: theme.mutedForeground),
  ),
)'''),
      DocCallout(
        title: 'Use theme.radiusScale, not CairnRadius, in app code',
        body:
            'CairnRadius.lg is the constant for the default --radius of 10px. '
            'theme.radiusScale.lg re-derives it from whatever --radius the '
            'active theme carries, so a themed app with a tighter radius keeps '
            'your own surfaces proportional instead of leaving them at 10.',
      ),

      DocHeading('Overlays'),
      DocParagraph(
        'Modal surfaces — Dialog, Alert Dialog, Sheet, Drawer — are opened '
        'with a show* function that pushes a PopupRoute, which is what gives '
        'you focus trapping, focus restore and back-gesture dismissal for '
        'free:',
      ),
      DocCode('''
await showCairnDialog<void>(
  context: context,
  builder: (BuildContext context) => CairnDialog(
    title: const Text('Edit profile'),
    content: const CairnFormField(label: 'Name', child: CairnInput()),
    actions: <Widget>[
      CairnButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
    ],
  ),
);'''),
      DocParagraph(
        'Anchored surfaces — Popover, Dropdown Menu, Tooltip, Hover Card — use '
        'OverlayPortal instead, so they stay out of the navigation stack. '
        'Those take a CairnOverlayController you own:',
      ),
      DocCode('''
final CairnOverlayController controller = CairnOverlayController();

@override
void dispose() {
  controller.dispose();
  super.dispose();
}

CairnPopover(
  controller: controller,
  content: const CairnPopoverTitle('Dimensions'),
  child: CairnButton(
    onPressed: controller.toggle,
    child: const Text('Open'),
  ),
)'''),
      DocPreview(Previews.popover),

      DocHeading('Toasts'),
      DocParagraph(
        'Install CairnToaster once in MaterialApp.builder, above the '
        'Navigator. Then any widget can fire a toast and it will survive that '
        'widget\'s route being popped.',
      ),
      DocCode('''
CairnToast.show(
  context,
  const CairnToast(
    variant: CairnToastVariant.success,
    title: 'Changes saved',
    description: 'Your profile is up to date.',
  ),
);'''),
      DocPreview(Previews.toast),
    ],
  ),

  // =========================================================================
  DocPage(
    title: 'Theming',
    slug: 'theming',
    group: 'Customisation',
    summary:
        'CairnTheme is a ThemeExtension carrying nineteen semantic colour '
        'slots, a radius base and a font family. Everything else is derived.',
    nodes: <DocNode>[
      DocHeading('Why a ThemeExtension'),
      DocParagraph(
        'This is a deliberate integration choice, not a shortcut. An inherited '
        'widget of Cairn\'s own would force host apps to nest two theme '
        'systems and would break any Material widget already in use. Riding on '
        'ThemeData.extensions instead means three things:',
      ),
      DocList(<String>[
        'Cairn composes inside an ordinary MaterialApp; nothing has to be '
            'abandoned or wrapped.',
        'Flutter animates theme changes for free, because ThemeExtension.lerp '
            'is driven by AnimatedTheme during a light/dark transition — the '
            'toggle in this site\'s header is a plain setState, and the '
            'crossfade you see is Flutter interpolating every token.',
        'Theme.of(context) stays the single lookup path developers already '
            'know.',
      ]),
      DocCode('''
MaterialApp(
  theme: CairnTheme.materialTheme(CairnTheme.light),
  darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
)'''),
      DocParagraph(
        'materialTheme() also aligns Material\'s own defaults with the Cairn '
        'tokens: scaffold and canvas colours, a matching ColorScheme, text '
        'selection colours, no ink splash — Cairn\'s interactions are colour '
        'and shadow transitions, not ripples — and Material 3\'s filled '
        'TextField default switched off, since Cairn inputs are '
        'transparent-backed with a border.',
      ),
      DocParagraph('If you would rather wire it yourself:'),
      DocCode('''
MaterialApp(
  theme: ThemeData(
    extensions: const <ThemeExtension<dynamic>>[CairnTheme.light],
  ),
)'''),

      DocHeading('The colour slots'),
      DocParagraph(
        'Nineteen semantic slots, each named for the CSS custom property it is '
        'specified as. They come in background/foreground pairs so that a '
        'surface and the text on it always move together.',
      ),
      DocTable(
        headers: <String>['Slot', 'CSS variable', 'What it is'],
        rows: <List<String>>[
          <String>[
            'background / foreground',
            '--background',
            'The page surface and default body text',
          ],
          <String>[
            'card / cardForeground',
            '--card',
            'Raised content surfaces',
          ],
          <String>[
            'popover / popoverForeground',
            '--popover',
            'Floating surfaces: Popover, Dropdown, Select, Tooltip, Command',
          ],
          <String>[
            'primary / primaryForeground',
            '--primary',
            'High-emphasis fills: default Button, checked Checkbox and Switch, Progress',
          ],
          <String>[
            'secondary / secondaryForeground',
            '--secondary',
            'Low-emphasis fills: secondary Button and Badge',
          ],
          <String>[
            'muted / mutedForeground',
            '--muted',
            'De-emphasised backgrounds and secondary text',
          ],
          <String>[
            'accent / accentForeground',
            '--accent',
            'Hover and keyboard-focus highlight for interactive rows',
          ],
          <String>[
            'destructive / destructiveForeground',
            '--destructive',
            'Danger fills and destructive text',
          ],
          <String>['border', '--border', 'Hairlines and component outlines'],
          <String>[
            'input',
            '--input',
            'The border colour of form controls specifically',
          ],
          <String>[
            'ring',
            '--ring',
            'The focus ring, drawn at 50% alpha and 3px',
          ],
        ],
      ),
      DocCallout(
        title: 'destructiveForeground is a real slot, not a hardcoded white',
        body:
            'The common convention is to paint white text onto a destructive '
            'fill and leave it at that, which stops working the moment someone '
            'themes destructive to a pale colour. Cairn keeps the foreground '
            'as its own themeable slot and merely defaults it to white.',
      ),

      DocHeading('The radius scale'),
      DocParagraph(
        'One base, --radius, defaults to 0.625rem = 10 logical pixels. Every '
        'other step is a multiplier of it rather than a fixed offset from it, '
        'which is what lets a single number rescale an entire app:',
      ),
      DocTable(
        headers: <String>['Step', 'Formula', 'Default', 'Used by'],
        rows: <List<String>>[
          <String>[
            'xs',
            'fixed 2px',
            '2',
            'Dialog and Sheet close affordances',
          ],
          <String>['sm', '--radius × 0.6', '6', 'Badge, small chips'],
          <String>[
            'md',
            '--radius × 0.8',
            '8',
            'Button, Input, Textarea, Select, Popover, Dropdown',
          ],
          <String>['lg', '--radius', '10', 'Dialog, Alert, Tabs list'],
          <String>['xl', '--radius × 1.4', '14', 'Card'],
          <String>['2xl', '--radius × 1.8', '18', ''],
          <String>['full', '9999', 'pill', 'Avatar, Switch, Pagination'],
        ],
      ),
      DocParagraph(
        'Change radius on the theme and every component\'s corners rescale '
        'proportionally. Read theme.radiusScale in your own widgets so they '
        'rescale too.',
      ),
      DocCode('''
final CairnTheme tight = CairnTheme.dark.copyWith(radius: 4.0);
// tight.radiusScale.md == 3.2, tight.radiusScale.xl == 5.6'''),

      DocHeading('Customising'),
      DocParagraph(
        'copyWith on either preset. Nothing else is needed — there is no '
        'builder, no config file and no code generation.',
      ),
      DocCode('''
final CairnTheme brand = CairnTheme.light.copyWith(
  primary: const Color(0xFF3B82F6),
  primaryForeground: const Color(0xFFFFFFFF),
  radius: 4.0,
  fontFamily: 'Inter',
);

MaterialApp(theme: CairnTheme.materialTheme(brand));'''),

      DocHeading('Derived values'),
      DocParagraph(
        'A few things are computed from the slots rather than stored, so they '
        'cannot drift out of sync:',
      ),
      DocTable(
        headers: <String>['Getter', 'What it returns'],
        rows: <List<String>>[
          <String>['ringMuted', 'ring at 50% alpha — Tailwind\'s ring-ring/50'],
          <String>[
            'focusRing',
            'The ring as a BoxShadow list: zero offset, zero blur, 3px spread, because Tailwind compiles ring-[3px] to box-shadow: 0 0 0 3px',
          ],
          <String>[
            'invalidRing',
            'The ring tinted destructive, at 20% in light and 40% in dark',
          ],
          <String>[
            'radiusScale',
            'The derived rounded-* scale for this theme\'s radius',
          ],
          <String>['defaultTextStyle', 'text-sm in foreground'],
        ],
      ),

      DocHeading('The opacity modifier trap'),
      DocParagraph(
        'Tailwind\'s /N modifier scales a colour\'s existing alpha; it does '
        'not set it. bg-input/30 compiles to color-mix(in oklab, var(--input) '
        '30%, transparent). For an opaque token that is the same as setting '
        'alpha to 0.30 — but Cairn\'s dark --input is already '
        'oklch(1 0 0 / 15%), so dark:bg-input/30 is white at 4.5%, not 30%. '
        'Six times too strong is very visible as a washed-out grey fill on '
        'every dark-mode form control.',
      ),
      DocCode('''
// The extension Cairn ships for exactly this.
extension CairnOpacityModifier on Color {
  Color withOpacityModifier(double factor) =>
      withValues(alpha: a * factor.clamp(0.0, 1.0));
}

theme.input.withOpacityModifier(0.3); // scales, does not replace'''),
    ],
  ),

  // =========================================================================
  DocPage(
    title: 'Design tokens',
    slug: 'tokens',
    group: 'Customisation',
    summary:
        'Seven token files, each recording where its numbers came from. No '
        'component hardcodes a value that should come from one of these.',
    nodes: <DocNode>[
      DocHeading('The files'),
      DocTable(
        headers: <String>['File', 'Contents'],
        rows: <List<String>>[
          <String>[
            'tokens/oklch.dart',
            'oklch() → Color conversion, following Björn Ottosson\'s OKLab specification',
          ],
          <String>[
            'tokens/colors.dart',
            'All 19 semantic slots plus the 5-step chart ramp, light and dark, each annotated with its source oklch() string',
          ],
          <String>['tokens/spacing.dart', 'Tailwind\'s 0.25rem scale'],
          <String>[
            'tokens/radius.dart',
            'The --radius scale and CairnRadiusScale for custom bases',
          ],
          <String>[
            'tokens/typography.dart',
            'Font sizes, line-height ratios, weights, tracking',
          ],
          <String>[
            'tokens/shadows.dart',
            'The shadow scale plus the CSS-blur conversion',
          ],
          <String>[
            'tokens/motion.dart',
            'Durations and Tailwind\'s easing curves',
          ],
        ],
      ),

      DocHeading('Spacing'),
      DocParagraph(
        'Tailwind v4 defines a single base — --spacing: 0.25rem — and every '
        'numeric spacing utility is a multiple of it. At the browser default '
        '16px root, that is 4px, and a Flutter logical pixel is the same unit '
        'as a CSS px at devicePixelRatio 1. The conversion is 1:1 with no '
        'scaling factor.',
      ),
      DocCode('''
CairnSpacing.s1;   //  4 — gap-1
CairnSpacing.s3;   // 12 — px-3
CairnSpacing.s6;   // 24 — p-6
CairnSpacing.step(3.5); // 14 — p-3.5'''),

      DocHeading('Typography'),
      DocParagraph(
        'Tailwind pairs a font size with an absolute line height: text-sm is '
        '0.875rem / 1.25rem. Flutter\'s TextStyle.height is a multiple of the '
        'font size, not a length, so the conversion is 20 / 14 = 1.4286. '
        'Baking the ratio rather than the pixel value is what keeps a '
        'component\'s intrinsic height correct when a user scales text.',
      ),
      DocCallout(
        title: 'leading-none is not Flutter\'s default',
        body:
            'Card, Dialog and Label titles use line-height: 1. Flutter\'s '
            'default when height is null comes from the font\'s own metrics, '
            'typically around 1.2, so these have to set height: 1.0 '
            'explicitly or titles sit visibly low in their box.',
      ),
      DocCode('''
CairnTypography.sm;       // 14px on a 20px line
CairnTypography.xl2;      // 24px on a 32px line
CairnTypography.semibold; // FontWeight.w600
CairnTypography.leadingNone;          // 1.0
CairnTypography.trackingTight(24);    // -0.6, because em is relative'''),

      DocHeading('Shadows and the blur conversion'),
      DocParagraph(
        'This is the conversion that is wrong if you copy the numbers across '
        'literally. CSS defines a shadow\'s blur as a Gaussian whose standard '
        'deviation is half the stated radius, so 0 1px 3px means sigma 1.5. '
        'Flutter converts BoxShadow.blurRadius to a sigma with '
        'radius × 0.57735 + 0.5, inherited from Skia\'s convertRadiusToSigma. '
        'Pasting CSS\'s 3 into blurRadius yields sigma 2.23 — roughly 50% '
        'wider than the browser draws.',
      ),
      DocCode('''
// Inverts Flutter's formula so the rendered sigma matches CSS's.
static double cssBlur(double cssBlurPx) {
  final double targetSigma = cssBlurPx / 2.0;
  if (targetSigma <= 0.5) return 0.0;
  return (targetSigma - 0.5) / 0.57735;
}'''),
      DocCallout(
        title: 'Outer shadows are clipped in CSS and not in Flutter',
        body:
            'CSS never paints an outer box-shadow through its element; Flutter '
            'paints a blurred filled copy of the shape behind the box with no '
            'clip. On Cairn\'s transparent-backed form controls that turns '
            'shadow-xs into a grey wash across the field — and turns '
            'focus-visible:ring-[3px], which compiles to box-shadow: 0 0 0 '
            '3px, into a solid fill over the entire control instead of a 3px '
            'outline. CairnShadowed paints shadows through a clip that removes '
            'the shape\'s interior.',
      ),

      DocHeading('Motion'),
      DocParagraph(
        'Tailwind\'s transition utilities default to 150ms with '
        'cubic-bezier(0.4, 0, 0.2, 1) — the curve Tailwind calls ease-in-out, '
        'which is not the CSS keyword ease-in-out (that is 0.42, 0, 0.58, 1). '
        'Flutter has no built-in Curve for it, so CairnMotion.standard '
        'constructs it with the exact control points.',
      ),
      DocCode('''
CairnMotion.d150;     // Tailwind's transition default
CairnMotion.d200;     // Dialog, Accordion, Popover
CairnMotion.d500;     // Sheet and Drawer opening (closing is d300)
CairnMotion.standard; // Cubic(0.4, 0.0, 0.2, 1.0)
CairnMotion.easeOut;  // Cubic(0.0, 0.0, 0.2, 1.0)'''),
      DocParagraph(
        'The hover lift on this site\'s cards, the theme toggle\'s icon '
        'rotation and the preview/code crossfade all read their duration and '
        'curve from these constants rather than picking numbers.',
      ),

      DocHeading('The chart ramp'),
      DocParagraph(
        'colors.dart also carries --chart-1 through --chart-5. In the Neutral '
        'base these are achromatic — #D4D4D4 through #262626 — which is why '
        'the Charts page on this site is monochrome by default rather than '
        'reaching for a palette Cairn does not define.',
      ),
    ],
  ),

  // =========================================================================
  DocPage(
    title: 'Dark mode',
    slug: 'dark-mode',
    group: 'Customisation',
    summary:
        'Both themes ship. Switching between them is one field on MaterialApp, '
        'and Flutter animates every token across the change.',
    nodes: <DocNode>[
      DocHeading('The two presets'),
      DocParagraph(
        'CairnTheme.light and CairnTheme.dark are Cairn\'s Neutral base — an '
        'achromatic palette specified in OKLCH, where every step lands exactly '
        'on a published neutral ramp. Hand both to MaterialApp and pick with '
        'themeMode:',
      ),
      DocCode('''
MaterialApp(
  theme: CairnTheme.materialTheme(CairnTheme.light),
  darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
  themeMode: _mode, // ThemeMode.dark, .light or .system
)'''),

      DocHeading('How this site does it'),
      DocParagraph(
        'The toggle in the header is a ChangeNotifier holding a ThemeMode, '
        'exposed through an InheritedNotifier. It defaults to ThemeMode.dark '
        'rather than ThemeMode.system, and it only ever moves between the two '
        'explicit modes — so a visitor whose OS is already dark still sees the '
        'control do something.',
      ),
      DocCode('''
class SiteThemeController extends ChangeNotifier {
  SiteThemeController({ThemeMode initial = ThemeMode.dark}) : _mode = initial;

  ThemeMode _mode;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}''', filename: 'lib/src/app/site_theme.dart'),
      DocParagraph(
        'There is one escape hatch: appending ?theme=light to any URL on this '
        'site boots into the light theme. That is not a preference store — it '
        'exists so a light-mode screenshot can be captured head-lessly and so '
        'a link can point at a specific treatment. Anyone who simply opens the '
        'site still gets dark.',
      ),
      DocCallout(
        title: 'The crossfade is free',
        body:
            'CairnTheme implements ThemeExtension.lerp, interpolating every '
            'colour slot and the radius. MaterialApp wraps its child in an '
            'AnimatedTheme, so flipping themeMode animates all nineteen slots '
            'over Flutter\'s default theme duration. There is no explicit '
            'animation anywhere in this site\'s toggle code.',
      ),

      DocHeading('Where dark is not just inverted light'),
      DocParagraph(
        'A handful of components genuinely branch on brightness rather than on '
        'a token, because the design calls for a dark-only treatment with no '
        'light counterpart. The outline Button gains a subtle fill in dark mode '
        'that simply does not exist in light mode; the invalid focus ring goes '
        'from 20% to 40% alpha, because a destructive tint that reads clearly '
        'on white disappears on near-black. CairnTheme carries brightness '
        'precisely so those branches can be honest about it.',
      ),
      DocParagraph(
        'The dark theme also switches borders from an opaque grey to a '
        'translucent white — --border is oklch(1 0 0 / 10%) — so that a '
        'hairline lifts correctly over both the page background and a raised '
        'card. That is why theme.border is not a flat colour you can blend '
        'against a known background.',
      ),
      DocPreview(
        Previews.button,
        caption:
            'Toggle the theme in the header and watch the outline variant '
            'pick up its dark-only fill.',
      ),
    ],
  ),

  // =========================================================================
  DocPage(
    title: 'Accessibility',
    slug: 'accessibility',
    group: 'Quality',
    summary:
        'Looking right is the easy half. Focus, keyboard operation and '
        'screen-reader semantics are part of each component\'s contract in '
        'Cairn, not a pass somebody makes later.',
    nodes: <DocNode>[
      DocHeading('Focus-visible, not focus'),
      DocParagraph(
        'Cairn draws its focus ring on focus-visible rather than focus: '
        'clicking a button must not show a ring, while tabbing to it must. '
        'Flutter\'s hasFocus cannot distinguish the two. CairnInteractive '
        'combines focus state with FocusManager.highlightMode and tracks '
        'whether the focus change came from a pointer press.',
      ),
      DocCallout(
        title: 'Try it',
        body:
            'Click the button below — no ring. Then press Tab to move focus '
            'to it — a 3px ring at 50% alpha appears. That distinction is the '
            'difference between a focus indicator that helps keyboard users '
            'and one that looks like a rendering bug to mouse users.',
      ),
      DocPreview(Previews.button),

      DocHeading('Keyboard'),
      DocList(<String>[
        'Space and Enter both activate, wired through ActivateIntent so it '
            'composes with a host app\'s own shortcuts.',
        'Roving focus in Radio Group and Tabs: one tab stop for the group, '
            'arrow keys to move within it.',
        'Slider supports arrow keys plus Home and End, and exposes '
            'increase/decrease actions with correct increasedValue and '
            'decreasedValue announcements.',
        'Escape dismisses every overlay — except Alert Dialog, which by '
            'design demands an explicit choice.',
        'The Command palette keeps focus in its input while arrow keys move a '
            'highlight through the list, so typing and navigating never '
            'compete for the same keystrokes.',
      ]),
      DocPreview(
        Previews.radioGroup,
        caption: 'Tab into the group, then use the arrow keys.',
      ),

      DocHeading('Focus trapping and restore'),
      DocParagraph(
        'Dialog, Alert Dialog, Sheet and Drawer push a PopupRoute, which gets '
        'Flutter\'s per-route FocusScope — so focus is trapped while they are '
        'open and restored to the trigger when they close. It also brings '
        'back-gesture dismissal, which a web implementation has no equivalent '
        'of. Anchored '
        'surfaces (Popover, Dropdown Menu) use OverlayPortal instead, so they '
        'stay out of the navigation stack and the system back gesture does not '
        'close them.',
      ),

      DocHeading('Pointer events and disabled state'),
      DocParagraph(
        'disabled:pointer-events-none genuinely removes the subtree from hit '
        'testing rather than just making the component itself inert. A '
        'disabled button with a tooltip wrapped around it will not show the '
        'tooltip, which is the correct web behaviour and is easy to get wrong '
        'in Flutter.',
      ),

      DocHeading('Reduced motion'),
      DocParagraph(
        'Skeleton, Spinner and the Input OTP caret honour '
        'MediaQuery.disableAnimations. That is also what makes golden tests '
        'possible: those components never stop scheduling frames, so the '
        'golden harness sets disableAnimations and captures one deterministic '
        'frame instead of timing out in pumpAndSettle.',
      ),
      DocPreview(Previews.spinner),

      DocHeading('Semantics'),
      DocParagraph(
        'Controls that have no visible label take a semanticLabel: icon '
        'buttons require one, and Switch, Slider, Progress and Avatar all '
        'accept one. Separator is decorative by default so screen readers skip '
        'it; pass decorative: false when the rule carries meaning. Breadcrumb '
        'announces its current crumb as the current page rather than rendering '
        'a dead link.',
      ),
    ],
  ),

  // =========================================================================
  DocPage(
    title: 'Testing',
    slug: 'testing',
    group: 'Quality',
    summary:
        'Token extraction makes the first implementation correct. Golden tests '
        'are what keep it correct.',
    nodes: <DocNode>[
      DocHeading('What is tested'),
      DocTable(
        headers: <String>['Directory', 'What it covers'],
        rows: <List<String>>[
          <String>[
            'test/tokens/',
            'The OKLCH pipeline, the neutral-ramp assertion, the radius formula',
          ],
          <String>[
            'test/components/',
            'Behaviour: focus, keyboard, dismissal, sizing',
          ],
          <String>[
            'test/goldens/',
            'Every component as a variant sheet, in both themes',
          ],
        ],
      ),
      DocCode('''
flutter test                 # 114 tests
flutter analyze --fatal-infos --fatal-warnings
dart format --set-exit-if-changed .''', language: CodeLanguage.shell),

      DocHeading('Why goldens are reliable here'),
      DocParagraph(
        'Two decisions make golden comparison a signal rather than a source of '
        'flakes.',
      ),
      DocParagraph(
        'Fonts are bundled, not borrowed from the OS. flutter test loads no '
        'real font by default — text lays out with a placeholder where every '
        'glyph is an identical box, which tells you nothing about typography. '
        'Cairn ships Geist under test/fonts/ and registers it in '
        'test/flutter_test_config.dart, so text shapes identically everywhere.',
      ),
      DocParagraph(
        'Goldens are generated and verified on one platform. Even with '
        'identical fonts, sub-pixel anti-aliasing differs between operating '
        'systems. Rather than weaken the comparison with a fuzzy threshold — '
        'which would let real regressions through — Cairn enforces goldens on '
        'Linux, which is what CI runs. On Windows and macOS the widgets are '
        'still built and pumped, so layout errors and exceptions are caught, '
        'but the pixel comparison is skipped.',
      ),
      DocCallout(
        title: 'Regenerating goldens',
        body:
            'Because references must come from the same platform that verifies '
            'them, do not run --update-goldens locally on Windows or macOS. '
            'Use the "Update goldens" workflow in Actions instead; it re-runs '
            'flutter test afterwards to prove the regenerated images actually '
            'pass.',
      ),

      DocHeading('A gotcha worth stealing'),
      DocParagraph(
        'Golden capture pumps a fixed number of frames rather than calling '
        'pumpAndSettle. Components with repeating animations — Spinner, the '
        'Skeleton pulse, the Input OTP caret, indeterminate Progress — never '
        'stop scheduling frames, so pumpAndSettle times out. The harness also '
        'sets MediaQueryData.disableAnimations, which those components honour, '
        'so they render as one deterministic frame.',
      ),

      DocHeading('This site\'s own tests'),
      DocParagraph(
        'cairn_site does not repeat the library\'s golden rigour — it is a '
        'marketing site, not the design-system source of truth. What it does '
        'test is that every route renders without throwing, that the dark '
        'theme is what a fresh visitor gets, that the toggle actually reaches '
        'the light theme, and that the catalogues are internally consistent: '
        'no duplicate slugs, no component whose detail route would 404.',
      ),
    ],
  ),
];
