import 'package:cairn_site/src/app/routes.dart';
import 'package:cairn_site/src/data/blocks_catalog.dart';
import 'package:cairn_site/src/data/components_catalog.dart';
import 'package:cairn_site/src/data/docs_catalog.dart';
import 'package:cairn_site/src/pages/directory_page.dart';
import 'package:flutter_test/flutter_test.dart';

/// Data-integrity checks.
///
/// A documentation site fails in a specific, embarrassing way: a link that goes
/// nowhere. These are cheap, run in milliseconds and catch the whole class.
void main() {
  group('component catalogue', () {
    test('slugs are unique', () {
      final Set<String> slugs = <String>{};
      for (final ComponentEntry entry in componentCatalog) {
        expect(
          slugs.add(entry.slug),
          isTrue,
          reason: 'duplicate ${entry.slug}',
        );
      }
    });

    test('slugs are URL safe', () {
      for (final ComponentEntry entry in componentCatalog) {
        expect(
          entry.slug,
          matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')),
          reason: entry.name,
        );
      }
    });

    test('covers the library\'s 45 modules', () {
      final int coLocated = componentCatalog
          .where((ComponentEntry e) => e.livesIn != null)
          .length;
      expect(
        componentCatalog.length - coLocated,
        45,
        reason:
            'cairn_ui ships 45 files under lib/src/components/. Every one '
            'should have a catalogue entry, and anything extra should declare '
            'the module it lives in.',
      );
    });

    test('every entry has a snippet and a description', () {
      for (final ComponentEntry entry in componentCatalog) {
        expect(entry.code.trim(), isNotEmpty, reason: entry.name);
        expect(entry.description.trim(), isNotEmpty, reason: entry.name);
        expect(
          entry.code,
          contains('Cairn'),
          reason: '${entry.name} snippet should show a real Cairn widget',
        );
      }
    });

    test('findComponent resolves every slug and rejects unknown ones', () {
      for (final ComponentEntry entry in componentCatalog) {
        expect(findComponent(entry.slug), same(entry));
      }
      expect(findComponent('not-a-component'), isNull);
    });
  });

  group('blocks', () {
    test('slugs are unique', () {
      final Set<String> slugs = <String>{};
      for (final BlockEntry block in blockCatalog) {
        expect(slugs.add(block.slug), isTrue, reason: block.slug);
      }
    });

    test('every "built from" chip names a real component', () {
      final Set<String> known = componentCatalog
          .map((ComponentEntry e) => e.name)
          .toSet();
      // `Icon` is CairnIcon, which is an internal export rather than a
      // catalogue entry; it is the one allowed exception.
      const Set<String> allowedExtras = <String>{'Icon'};
      for (final BlockEntry block in blockCatalog) {
        for (final String component in block.uses) {
          expect(
            known.contains(component) || allowedExtras.contains(component),
            isTrue,
            reason: '${block.slug} claims to use "$component"',
          );
        }
      }
    });
  });

  group('docs', () {
    test('slugs are unique', () {
      final Set<String> slugs = <String>{};
      for (final DocPage page in docsCatalog) {
        expect(slugs.add(page.slug), isTrue, reason: page.slug);
      }
    });

    test('every page belongs to a declared sidebar group', () {
      for (final DocPage page in docsCatalog) {
        expect(docGroups, contains(page.group), reason: page.slug);
      }
    });

    test('every group has at least one page', () {
      for (final String group in docGroups) {
        expect(
          docsCatalog.any((DocPage p) => p.group == group),
          isTrue,
          reason: group,
        );
      }
    });

    test('heading anchors are unique within a page', () {
      for (final DocPage page in docsCatalog) {
        final Set<String> ids = <String>{};
        for (final DocHeading heading in page.nodes.whereType<DocHeading>()) {
          expect(
            ids.add(heading.id),
            isTrue,
            reason: '${page.slug} repeats the anchor "${heading.id}"',
          );
          expect(heading.id, isNotEmpty, reason: heading.text);
        }
      }
    });

    test('every page has an outline the table of contents can render', () {
      for (final DocPage page in docsCatalog) {
        expect(page.outline, isNotEmpty, reason: page.slug);
      }
    });

    test('doc tables are rectangular', () {
      for (final DocPage page in docsCatalog) {
        for (final DocTable table in page.nodes.whereType<DocTable>()) {
          for (final List<String> row in table.rows) {
            expect(
              row.length,
              table.headers.length,
              reason: '${page.slug}: row ${row.first}',
            );
          }
        }
      }
    });

    test('the footer\'s hardcoded doc links exist', () {
      for (final String slug in <String>[
        'introduction',
        'installation',
        'quick-start',
        'theming',
        'accessibility',
      ]) {
        expect(findDoc(slug), isNotNull, reason: slug);
      }
    });
  });

  group('directory', () {
    test('every row points at a route the router serves', () {
      final Set<String> staticRoutes = <String>{
        Routes.home,
        Routes.components,
        Routes.blocks,
        Routes.charts,
        Routes.directory,
        Routes.typeset,
      };
      for (final DirectoryRow row in DirectoryPage.rows) {
        final bool valid =
            staticRoutes.contains(row.target) ||
            (row.target.startsWith('/components/') &&
                findComponent(row.target.split('/').last) != null) ||
            (row.target.startsWith('/docs/') &&
                findDoc(row.target.split('/').last) != null);
        expect(valid, isTrue, reason: '${row.name} -> ${row.target}');
      }
    });

    test('lists everything', () {
      final int expected =
          componentCatalog.length +
          componentCatalog.fold<int>(
            0,
            (int sum, ComponentEntry e) => sum + e.alsoExports.length,
          ) +
          blockCatalog.length +
          docsCatalog.length;
      expect(DirectoryPage.rows.length, expected);
    });
  });

  group('navigation', () {
    test('every nav destination matches its own path', () {
      for (final NavDestination destination in siteNav) {
        expect(destination.matches(destination.path), isTrue);
      }
    });

    test('home does not swallow every other route', () {
      const NavDestination home = NavDestination(
        label: 'Home',
        path: Routes.home,
        description: '',
      );
      expect(home.matches(Routes.components), isFalse);
      expect(home.matches(Routes.home), isTrue);
    });

    test('a section matches its children', () {
      const NavDestination docs = NavDestination(
        label: 'Docs',
        path: Routes.docs,
        description: '',
      );
      expect(docs.matches('/docs/theming'), isTrue);
      expect(docs.matches('/documents'), isFalse);
    });
  });
}
