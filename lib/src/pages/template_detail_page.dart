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
import '../widgets/site_icons.dart';
import '../widgets/surfaces.dart';
import '../widgets/syntax.dart';

/// One template's page: the live app in a phone or browser frame, what it is
/// built from, its architecture, every screenshot, and links to its HTML
/// documentation and source.
class TemplateDetailPage extends StatelessWidget {
  /// Creates the page for [entry].
  const TemplateDetailPage({super.key, required this.entry});

  /// The template to show.
  final TemplateEntry entry;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int index = templateCatalog.indexOf(entry);
    final TemplateEntry? previous = index > 0
        ? templateCatalog[index - 1]
        : null;
    final TemplateEntry? next = index < templateCatalog.length - 1
        ? templateCatalog[index + 1]
        : null;
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CairnBreadcrumb(
            crumbs: <CairnCrumb>[
              CairnCrumb(label: 'Home', onTap: () => context.go(Routes.home)),
              CairnCrumb(
                label: 'Templates',
                onTap: () => context.go(Routes.templates),
              ),
              CairnCrumb.current(label: entry.name),
            ],
          ),
          const SizedBox(height: CairnSpacing.s6),
          PageHeading(
            title: entry.name,
            lead: entry.description,
            trailing: Wrap(
              spacing: CairnSpacing.s2,
              children: <Widget>[
                CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text(entry.kind.label),
                ),
                if (entry.serverRendered)
                  const CairnBadge(
                    variant: CairnBadgeVariant.outline,
                    label: Text('Jaspr'),
                  ),
                CairnBadge(
                  variant: CairnBadgeVariant.outline,
                  label: Text('${entry.screens.length} screens'),
                ),
              ],
            ),
          ),
          const SizedBox(height: CairnSpacing.s10),
          // Keyed so moving to another template starts its app afresh.
          KeyedSubtree(
            key: ValueKey<String>(entry.slug),
            child: _TemplateView(entry: entry),
          ),
          const SizedBox(height: CairnSpacing.s16),
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s10),
          _Screenshots(entry: entry),
          const SizedBox(height: CairnSpacing.s12),
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s5),
          Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: previous == null
                      ? const SizedBox.shrink()
                      : CairnButton(
                          variant: CairnButtonVariant.ghost,
                          onPressed: () =>
                              context.go(Routes.template(previous.slug)),
                          leading: const CairnIcon(
                            CairnIconData.chevronLeft,
                            size: 15,
                          ),
                          child: Text(previous.name),
                        ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: next == null
                      ? const SizedBox.shrink()
                      : CairnButton(
                          variant: CairnButtonVariant.ghost,
                          onPressed: () =>
                              context.go(Routes.template(next.slug)),
                          trailing: const CairnIcon(
                            CairnIconData.chevronRight,
                            size: 15,
                          ),
                          child: Text(next.name),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s6),
          Center(
            child: CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () => context.go(Routes.templates),
              leading: const SiteIcon(SiteIconData.layers, size: 15),
              child: Text(
                'Back to all ${templateCatalog.length} templates',
                style: TextStyle(color: theme.foreground),
              ),
            ),
          ),
        ],
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

/// Every captured screen of the template, in the current theme.
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
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            // Phone shots are narrow; full-page server shots are tall.
            final int columns = mobile
                ? (width >= 900
                      ? 4
                      : width >= 560
                      ? 3
                      : 2)
                : entry.serverRendered
                ? (width >= 900
                      ? 3
                      : width >= 560
                      ? 2
                      : 1)
                : (width >= 680 ? 2 : 1);
            const double gap = CairnSpacing.s5;
            final double cell = (width - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: CairnSpacing.s8,
              children: <Widget>[
                for (final TemplateShot shot in entry.shots)
                  SizedBox(
                    width: cell,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: CairnSpacing.s2,
                      children: <Widget>[
                        DecoratedBox(
                          position: DecorationPosition.foreground,
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
                              width: cell,
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
            );
          },
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
