import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/links.dart';
import '../app/routes.dart';
import '../app/site_theme.dart';
import '../data/components_catalog.dart';
import '../data/templates_catalog.dart';
import '../widgets/code_block.dart';
import '../widgets/surfaces.dart';
import '../widgets/syntax.dart';

/// Full-app templates, built from Cairn components and nothing else.
///
/// Blocks are single screens; a template is a whole app you can click through.
/// Each one is a standalone package under `templates/`, mounted here live in a
/// phone or browser frame, with screenshots, an architecture note and a link
/// to its HTML documentation.
class TemplatesPage extends StatefulWidget {
  /// Creates the page, optionally opening on [initialSlug].
  const TemplatesPage({super.key, this.initialSlug});

  /// The template to show first; falls back to the first in the catalogue.
  final String? initialSlug;

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  late String _slug =
      findTemplate(widget.initialSlug ?? '')?.slug ??
      templateCatalog.first.slug;

  TemplateEntry get _entry => findTemplate(_slug)!;

  @override
  void didUpdateWidget(TemplatesPage old) {
    super.didUpdateWidget(old);
    final String? next = widget.initialSlug;
    if (next != null && next != old.initialSlug && findTemplate(next) != null) {
      _slug = next;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TemplateEntry entry = _entry;
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'Templates',
            title: 'Whole apps, not just screens',
            lead:
                'Blocks compose one screen. Templates compose an app you can '
                'click through, themed only through CairnTheme, with light '
                'and dark for free. Each is its own package with its own '
                'assets, tests and HTML documentation.',
          ),
          const SizedBox(height: CairnSpacing.s8),
          _Picker(
            selected: _slug,
            onSelected: (String s) => setState(() => _slug = s),
          ),
          const SizedBox(height: CairnSpacing.s8),
          KeyedSubtree(
            key: ValueKey<String>(_slug),
            child: _TemplateView(entry: entry),
          ),
          const SizedBox(height: CairnSpacing.s16),
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s10),
          _Screenshots(entry: entry),
        ],
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: CairnSpacing.s3,
        children: <Widget>[
          for (final TemplateEntry t in templateCatalog)
            _PickerCard(
              entry: t,
              selected: t.slug == selected,
              onTap: () => onSelected(t.slug),
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.entry,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final TemplateEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final CairnTheme theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${entry.name} template, ${entry.kind.label}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: CairnMotion.d150,
            width: 232,
            padding: const EdgeInsets.all(CairnSpacing.s4),
            decoration: BoxDecoration(
              color: selected ? theme.card : Colors.transparent,
              borderRadius: BorderRadius.circular(theme.radiusScale.xl),
              border: Border.all(
                color: selected ? theme.foreground : theme.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        entry.name,
                        style: theme
                            .textStyle(CairnTypography.base)
                            .copyWith(
                              color: theme.foreground,
                              fontWeight: CairnTypography.semibold,
                            ),
                      ),
                    ),
                    CairnBadge(
                      variant: CairnBadgeVariant.secondary,
                      label: Text(entry.kind.label),
                    ),
                  ],
                ),
                const SizedBox(height: CairnSpacing.s1p5),
                Text(
                  entry.summary,
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(color: theme.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The live template and everything about it.
class _TemplateView extends StatelessWidget {
  const _TemplateView({required this.entry});

  final TemplateEntry entry;

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.sizeOf(context).width >= SiteTokens.tabletBreakpoint;
    final Widget info = _Info(entry: entry);

    if (entry.kind == TemplateKind.mobile) {
      final Widget phone = Center(
        child: CairnMockupPhone(
          width: 360,
          child: Builder(builder: entry.preview!),
        ),
      );
      if (!wide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            phone,
            const SizedBox(height: CairnSpacing.s10),
            info,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          phone,
          const SizedBox(width: CairnSpacing.s12),
          Expanded(child: info),
        ],
      );
    }

    // Web templates: a browser frame across the full width, details below.
    final WidgetBuilder? preview = entry.preview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CairnMockupBrowser(
          url: 'https://${entry.slug.replaceAll('_', '-')}.example.com',
          child: preview == null
              ? _StaticPreview(entry: entry)
              : SizedBox(height: 680, child: Builder(builder: preview)),
        ),
        const SizedBox(height: CairnSpacing.s10),
        info,
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.entry});

  final TemplateEntry entry;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle muted = theme
        .textStyle(CairnTypography.sm)
        .copyWith(color: theme.mutedForeground, height: 1.55);
    final TextStyle heading = theme
        .textStyle(CairnTypography.base)
        .copyWith(
          color: theme.foreground,
          fontWeight: CairnTypography.semibold,
        );

    Widget screen((String, String) s) => Padding(
      padding: const EdgeInsets.only(bottom: CairnSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 3, right: CairnSpacing.s3),
            child: CairnStatus(tone: CairnTone.success, size: 8),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '${s.$1}  ',
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(
                          color: theme.foreground,
                          fontWeight: CairnTypography.medium,
                        ),
                  ),
                  TextSpan(text: s.$2, style: muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Widget overview = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          spacing: CairnSpacing.s3,
          children: <Widget>[
            Flexible(
              child: Text(
                entry.name,
                style: theme
                    .textStyle(CairnTypography.xl2)
                    .copyWith(
                      color: theme.foreground,
                      fontWeight: CairnTypography.semibold,
                    ),
              ),
            ),
            const CairnBadge(label: Text('Available')),
            CairnBadge(
              variant: CairnBadgeVariant.outline,
              label: Text(entry.kind.label),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s2),
        Text(entry.description, style: muted),
        const SizedBox(height: CairnSpacing.s6),
        Text('Screens', style: heading),
        const SizedBox(height: CairnSpacing.s3),
        for (final (String, String) s in entry.screens) screen(s),
        const SizedBox(height: CairnSpacing.s3),
        Text('Built from', style: heading),
        const SizedBox(height: CairnSpacing.s3),
        Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            for (final String name in entry.uses) _UseChip(name: name),
          ],
        ),
      ],
    );

    final Widget architecture = entry.serverRendered
        ? _ServerArchitecture(entry: entry, muted: muted, heading: heading)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Architecture', style: heading),
              const SizedBox(height: CairnSpacing.s2),
              Text(
                'Clean architecture, organised by layer and then by feature: '
                'presentation depends on domain, data depends on domain, and the '
                'domain depends on nothing. State is flutter_bloc cubits, wired '
                'with get_it and written out by hand, so there is no code '
                'generation.',
                style: muted,
              ),
              const SizedBox(height: CairnSpacing.s3),
              const Wrap(
                spacing: CairnSpacing.s2,
                runSpacing: CairnSpacing.s2,
                children: <Widget>[
                  CairnBadge(label: Text('Clean architecture')),
                  CairnBadge(label: Text('flutter_bloc')),
                  CairnBadge(label: Text('get_it')),
                  CairnBadge(label: Text('View models')),
                  CairnBadge(label: Text('Own package')),
                ],
              ),
              const SizedBox(height: CairnSpacing.s4),
              const CairnMockupCode(
                lines: <String>[
                  'templates/<name>/',
                  '  pubspec.yaml   its own package',
                  '  assets/        its own images',
                  '  doc/           HTML documentation',
                  '  lib/',
                  '    core/        DI, navigation, shared widgets',
                  '    common/      constants and utils',
                  '    data/<feature>/          remote, repositories',
                  '    domain/<feature>/        models, mappers,',
                  '                             repositories, use_cases',
                  '    presentation/<feature>/  bloc, view_models,',
                  '                             views, widgets',
                ],
              ),
              const SizedBox(height: CairnSpacing.s6),
              Wrap(
                spacing: CairnSpacing.s2,
                runSpacing: CairnSpacing.s2,
                children: <Widget>[
                  CairnButton(
                    onPressed: () => openExternal(templateDocsUrl(entry.slug)),
                    leading: const Icon(Icons.menu_book_outlined, size: 16),
                    child: const Text('Read the documentation'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.outline,
                    onPressed: () => openExternal(
                      '${SiteLinks.siteRepo}/tree/main/${entry.packagePath}',
                    ),
                    child: const Text('Browse the source'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.ghost,
                    onPressed: () => context.go(Routes.blocks),
                    child: const Text('Single-screen blocks'),
                  ),
                ],
              ),
              const SizedBox(height: CairnSpacing.s4),
              Text(
                'Photographs from Pexels, used under the Pexels licence. The '
                'documentation walks through changing the content, theming, '
                'connecting a real backend and migrating.',
                style: theme
                    .textStyle(CairnTypography.xs)
                    .copyWith(color: theme.mutedForeground),
              ),
            ],
          );

    final bool wide =
        MediaQuery.sizeOf(context).width >= SiteTokens.tabletBreakpoint;
    if (entry.kind == TemplateKind.mobile || !wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          overview,
          const SizedBox(height: CairnSpacing.s8),
          architecture,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: overview),
        const SizedBox(width: CairnSpacing.s12),
        Expanded(child: architecture),
      ],
    );
  }
}

/// Where a template's HTML documentation is served.
///
/// The files live in `web/template-docs/<slug>/index.html` and are copied from
/// each package's `doc/` folder by `tool/sync_template_docs.sh`.
String templateDocsUrl(String slug) {
  const String production = 'https://rlphjyson.github.io/cairn_site/';
  if (kIsWeb && Uri.base.host != 'rlphjyson.github.io') {
    return Uri.base.resolve('/template-docs/$slug/').toString();
  }
  return '${production}template-docs/$slug/';
}

class _UseChip extends StatelessWidget {
  const _UseChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final ComponentEntry? match = componentCatalog
        .where((ComponentEntry e) => e.name == name)
        .firstOrNull;
    final Widget badge = CairnBadge(
      variant: CairnBadgeVariant.outline,
      label: Text(name),
    );
    if (match == null) return badge;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: () => context.go(match.path), child: badge),
    );
  }
}

/// Every captured screen of the selected template, in the current theme.
///
/// Regenerate with `CAPTURE_SCREENSHOTS=1 flutter test
/// test/capture_template_screenshots_test.dart`.
class _Screenshots extends StatelessWidget {
  const _Screenshots({required this.entry});

  final TemplateEntry entry;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String mode = theme.brightness == Brightness.dark ? 'dark' : 'light';
    final bool mobile = entry.kind == TemplateKind.mobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeading(
          '${entry.name} screenshots',
          subtitle:
              'Every screen, in the current theme. Toggle light and dark in '
              'the header to compare.',
        ),
        const SizedBox(height: CairnSpacing.s6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s5,
            children: <Widget>[
              for (final TemplateShot shot in entry.shots)
                SizedBox(
                  width: mobile ? 220 : 420,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: CairnSpacing.s2,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: mobile
                            ? const BoxDecoration()
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  theme.radiusScale.lg,
                                ),
                                border: Border.all(color: theme.border),
                              ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            mobile ? 0 : theme.radiusScale.lg,
                          ),
                          child: Image.asset(
                            'assets/screenshots/${entry.slug}-${shot.file}-$mode.${entry.shotExt}',
                            semanticLabel:
                                '${shot.caption} screen, $mode theme',
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      Text(
                        shot.caption,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              color: theme.mutedForeground,
                              fontWeight: CairnTypography.medium,
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

/// A server-rendered template cannot run inside this Flutter page, so the
/// browser frame shows its home page as captured from the running server.
class _StaticPreview extends StatelessWidget {
  const _StaticPreview({required this.entry});

  final TemplateEntry entry;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String mode = theme.brightness == Brightness.dark ? 'dark' : 'light';
    final TemplateShot first = entry.shots.first;
    return Image.asset(
      'assets/screenshots/${entry.slug}-${first.file}-$mode.${entry.shotExt}',
      semanticLabel: '${entry.name} home page, $mode theme',
      fit: BoxFit.fitWidth,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// The architecture note for a template that runs on the server.
class _ServerArchitecture extends StatelessWidget {
  const _ServerArchitecture({
    required this.entry,
    required this.muted,
    required this.heading,
  });

  final TemplateEntry entry;
  final TextStyle muted;
  final TextStyle heading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Server-rendered with Jaspr', style: heading),
        const SizedBox(height: CairnSpacing.s2),
        Text(
          'This one is not a Flutter package. It is a Jaspr app: Dart that '
          'renders real HTML on a server, so every page ships its own title, '
          'meta tags, Open Graph data and JSON-LD to crawlers, works with '
          'JavaScript switched off, and hydrates only three small islands. '
          'Cairn\'s design tokens are carried over as CSS variables, so it '
          'looks like the rest of the system. Flutter web cannot do this, '
          'because it paints to a canvas.',
          style: muted,
        ),
        const SizedBox(height: CairnSpacing.s3),
        const Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            CairnBadge(label: Text('Jaspr')),
            CairnBadge(label: Text('Server-side rendering')),
            CairnBadge(label: Text('SEO')),
            CairnBadge(label: Text('Works without JavaScript')),
            CairnBadge(label: Text('Clean architecture')),
          ],
        ),
        if (entry.runCommands != null) ...<Widget>[
          const SizedBox(height: CairnSpacing.s4),
          CodeBlock(entry.runCommands!, language: CodeLanguage.shell),
        ],
        const SizedBox(height: CairnSpacing.s6),
        Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            CairnButton(
              onPressed: () => openExternal(templateDocsUrl(entry.slug)),
              leading: const Icon(Icons.menu_book_outlined, size: 16),
              child: const Text('Read the documentation'),
            ),
            CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () => openExternal(
                '${SiteLinks.siteRepo}/tree/main/${entry.packagePath}',
              ),
              child: const Text('Browse the source'),
            ),
          ],
        ),
      ],
    );
  }
}
