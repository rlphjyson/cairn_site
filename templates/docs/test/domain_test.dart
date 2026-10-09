import 'package:cairn_template_docs/common/constants/docs_brand.dart';
import 'package:cairn_template_docs/common/utils/inline_markup.dart';
import 'package:cairn_template_docs/common/utils/slugify.dart';
import 'package:cairn_template_docs/data/docs/remote/docs_remote_data_source.dart';
import 'package:cairn_template_docs/domain/docs/mappers/docs_mapper.dart';
import 'package:cairn_template_docs/domain/docs/models/doc_block.dart';
import 'package:cairn_template_docs/domain/docs/models/doc_page.dart';
import 'package:cairn_template_docs/domain/docs/models/doc_version.dart';
import 'package:cairn_template_docs/domain/docs/models/docs_site.dart';
import 'package:cairn_template_docs/domain/docs/models/toc_entry.dart';
import 'package:cairn_template_docs/domain/docs/use_cases/extract_headings.dart';
import 'package:cairn_template_docs/domain/docs/use_cases/get_page_neighbours.dart';
import 'package:cairn_template_docs/domain/search/models/search_hit.dart';
import 'package:cairn_template_docs/domain/search/use_cases/search_docs.dart';
import 'package:flutter_test/flutter_test.dart';

const DocsMapper mapper = DocsMapper();
const InMemoryDocsRemoteDataSource remote = InMemoryDocsRemoteDataSource(
  latency: Duration.zero,
);

Future<DocsSite> loadSite(String version) async =>
    mapper.site(version, await remote.fetchSite(version));

Map<String, dynamic> pageWith(List<dynamic> blocks) => <String, dynamic>{
  'slug': 'p',
  'title': 'P',
  'updated': '2026-01-02',
  'blocks': blocks,
};

void main() {
  group('inline markup', () {
    test('parses bold, code and links in order', () {
      expect(
        parseInline('Use **fast** `code` and [docs](intro#top) now'),
        const <InlineNode>[
          InlineText('Use '),
          InlineBold('fast'),
          InlineText(' '),
          InlineCode('code'),
          InlineText(' and '),
          InlineLink('docs', 'intro#top'),
          InlineText(' now'),
        ],
      );
    });

    test('leaves unmatched markers as text', () {
      expect(parseInline('2 * 3 and `open'), const <InlineNode>[
        InlineText('2 * 3 and `open'),
      ]);
    });

    test('classifies link targets', () {
      expect(const InlineLink('a', 'https://x.dev').isExternal, isTrue);
      expect(const InlineLink('a', 'mailto:a@b.c').isExternal, isTrue);
      expect(const InlineLink('a', 'quick-start').isExternal, isFalse);
      expect(const InlineLink('a', '#scopes').isExternal, isFalse);
    });

    test('plainText strips the markup', () {
      expect(plainText('**A** `b` [c](d)'), 'A b c');
    });
  });

  test('slugify makes URL-safe anchors', () {
    expect(slugify('Retries & back-off'), 'retries-back-off');
    expect(slugify('2.0.0'), '2-0-0');
    expect(slugify('***'), 'section');
  });

  group('mapper', () {
    test('maps every block type', () {
      final DocPage page = mapper.page(
        pageWith(<dynamic>[
          <String, dynamic>{'type': 'heading', 'text': 'Hello World'},
          <String, dynamic>{'type': 'paragraph', 'text': 'x'},
          <String, dynamic>{'type': 'code', 'language': 'sh', 'code': 'ls'},
          <String, dynamic>{'type': 'callout', 'kind': 'danger', 'text': 'y'},
          <String, dynamic>{
            'type': 'tabs',
            'tabs': <dynamic>[
              <String, dynamic>{
                'label': 'A',
                'blocks': <dynamic>[
                  <String, dynamic>{'type': 'paragraph', 'text': 'z'},
                ],
              },
            ],
          },
          <String, dynamic>{
            'type': 'steps',
            'steps': <dynamic>[
              <String, dynamic>{'title': 'One', 'blocks': <dynamic>[]},
            ],
          },
          <String, dynamic>{
            'type': 'table',
            'headers': <dynamic>['a'],
            'rows': <dynamic>[
              <dynamic>['1'],
            ],
          },
          <String, dynamic>{
            'type': 'list',
            'ordered': true,
            'items': <dynamic>['i'],
          },
        ]),
      );
      expect(page.updated, DateTime(2026, 1, 2));
      expect(page.blocks, const <DocBlock>[
        HeadingBlock(level: 2, id: 'hello-world', text: 'Hello World'),
        ParagraphBlock('x'),
        CodeBlock(language: CodeLanguage.bash, code: 'ls'),
        CalloutBlock(kind: CalloutKind.warning, text: 'y'),
        TabsBlock(<TabItem>[
          TabItem(label: 'A', blocks: <DocBlock>[ParagraphBlock('z')]),
        ]),
        StepsBlock(<StepItem>[StepItem(title: 'One', blocks: <DocBlock>[])]),
        TableBlock(
          headers: <String>['a'],
          rows: <List<String>>[
            <String>['1'],
          ],
        ),
        ListBlock(items: <String>['i'], ordered: true),
      ]);
    });

    test('de-duplicates heading ids within a page', () {
      final DocPage page = mapper.page(
        pageWith(<dynamic>[
          <String, dynamic>{'type': 'heading', 'text': 'Same'},
          <String, dynamic>{'type': 'heading', 'text': 'Same'},
          <String, dynamic>{'type': 'heading', 'text': 'Same', 'id': 'custom'},
        ]),
      );
      expect(
        page.blocks.cast<HeadingBlock>().map((HeadingBlock h) => h.id),
        <String>['same', 'same-2', 'custom'],
      );
    });

    test('fails loudly on unknown block types and bad levels', () {
      expect(
        () => mapper.page(
          pageWith(<dynamic>[
            <String, dynamic>{'type': 'video'},
          ]),
        ),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Unknown block type "video" in page "p"'),
          ),
        ),
      );
      expect(
        () => mapper.page(
          pageWith(<dynamic>[
            <String, dynamic>{'type': 'heading', 'level': 4, 'text': 'x'},
          ]),
        ),
        throwsFormatException,
      );
    });

    test('rejects a sidebar item with no page', () {
      expect(
        () => mapper.site('v', <String, dynamic>{
          'pages': <dynamic>[],
          'sidebar': <dynamic>[
            <String, dynamic>{
              'id': 's',
              'title': 'S',
              'items': <dynamic>['ghost'],
            },
          ],
        }),
        throwsFormatException,
      );
    });

    test('maps versions', () async {
      final List<DocVersion> versions = mapper.versions(
        await remote.fetchManifest(),
      );
      expect(versions.map((DocVersion v) => v.id), <String>['v2.0', 'v1.x']);
      expect(versions.first.isLatest, isTrue);
      expect(versions.last.notice, isNotNull);
    });
  });

  group('seed content', () {
    test('the default version is the latest one', () async {
      final List<DocVersion> versions = mapper.versions(
        await remote.fetchManifest(),
      );
      expect(
        versions.singleWhere((DocVersion v) => v.isLatest).id,
        DocsBrand.defaultVersionId,
      );
    });

    test('v2.0 has four sections and at least twelve pages', () async {
      final DocsSite site = await loadSite('v2.0');
      expect(site.sidebar, hasLength(4));
      expect(site.pages.length, greaterThanOrEqualTo(12));
      expect(site.pageFor(DocsBrand.homeSlug), isNotNull);
    });

    test('every internal link resolves to a page and heading', () async {
      for (final String v in <String>['v2.0', 'v1.x']) {
        final DocsSite site = await loadSite(v);
        final List<String> bad = <String>[];

        void check(String markup, String from) {
          for (final InlineNode n in parseInline(markup)) {
            if (n is! InlineLink || n.isExternal) continue;
            final List<String> parts = n.target.split('#');
            final String slug = parts.first.isEmpty ? from : parts.first;
            final DocPage? page = site.pageFor(slug);
            final bool ok =
                page != null &&
                (parts.length < 2 ||
                    page.blocks.whereType<HeadingBlock>().any(
                      (HeadingBlock h) => h.id == parts[1],
                    ));
            if (!ok) bad.add('$v $from -> ${n.target}');
          }
        }

        void walk(List<DocBlock> blocks, String from) {
          for (final DocBlock b in blocks) {
            switch (b) {
              case ParagraphBlock(:final String text):
                check(text, from);
              case CalloutBlock(:final String text):
                check(text, from);
              case ListBlock(:final List<String> items):
                for (final String i in items) {
                  check(i, from);
                }
              case TableBlock(:final List<List<String>> rows):
                for (final List<String> r in rows) {
                  for (final String c in r) {
                    check(c, from);
                  }
                }
              case TabsBlock(:final List<TabItem> tabs):
                for (final TabItem t in tabs) {
                  walk(t.blocks, from);
                }
              case StepsBlock(:final List<StepItem> steps):
                for (final StepItem s in steps) {
                  walk(s.blocks, from);
                }
              case HeadingBlock() || CodeBlock():
                break;
            }
          }
        }

        for (final DocPage p in site.pages.values) {
          walk(p.blocks, p.slug);
        }
        expect(bad, isEmpty);
      }
    });
  });

  group('heading extraction', () {
    test('lists h2 and h3 in order and ignores nested blocks', () {
      final DocPage page = DocPage(
        slug: 'p',
        title: 'P',
        description: '',
        updated: DateTime(2026),
        blocks: const <DocBlock>[
          ParagraphBlock('intro'),
          HeadingBlock(level: 2, id: 'a', text: 'A'),
          HeadingBlock(level: 3, id: 'b', text: 'B'),
          TabsBlock(<TabItem>[
            TabItem(
              label: 't',
              blocks: <DocBlock>[
                HeadingBlock(level: 2, id: 'hidden', text: 'Hidden'),
              ],
            ),
          ]),
        ],
      );
      expect(const ExtractHeadings()(page), const <TocEntry>[
        TocEntry(id: 'a', text: 'A', level: 2),
        TocEntry(id: 'b', text: 'B', level: 3),
      ]);
    });
  });

  group('previous / next', () {
    test('follows sidebar order across sections', () async {
      final DocsSite site = await loadSite('v2.0');
      final PageNeighbours mid = const GetPageNeighbours()(site, 'quick-start');
      expect(mid.previous?.slug, 'installation');
      expect(mid.next?.slug, 'configuration');
    });

    test('has no previous on the first page, no next on the last', () async {
      final DocsSite site = await loadSite('v2.0');
      const GetPageNeighbours neighbours = GetPageNeighbours();
      expect(neighbours(site, site.orderedSlugs.first).previous, isNull);
      expect(neighbours(site, site.orderedSlugs.last).next, isNull);
      expect(neighbours(site, 'nope'), const PageNeighbours());
    });
  });

  group('search', () {
    late DocsSite site;
    const SearchDocs search = SearchDocs();
    setUp(() async => site = await loadSite('v2.0'));

    test('an empty query returns pages then headings', () {
      final List<SearchHit> all = search(site);
      final int firstHeading = all.indexWhere(
        (SearchHit h) => h.kind == SearchHitKind.heading,
      );
      expect(
        all
            .take(firstHeading)
            .every((SearchHit h) => h.kind == SearchHitKind.page),
        isTrue,
      );
      expect(
        all.where((SearchHit h) => h.kind == SearchHitKind.page),
        hasLength(site.pages.length),
      );
    });

    test('finds a page by title and ranks it first', () {
      final List<SearchHit> hits = search(site, query: 'pagination');
      expect(hits.first.kind, SearchHitKind.page);
      expect(hits.first.pageSlug, 'pagination');
    });

    test('finds a heading and carries its anchor', () {
      final SearchHit hit = search(
        site,
        query: 'back-off',
      ).firstWhere((SearchHit h) => h.kind == SearchHitKind.heading);
      expect(hit.pageSlug, 'configuration');
      expect(hit.headingId, 'retries-and-back-off');
    });

    test('matches every word, in any order, and nothing else', () {
      expect(search(site, query: 'handling error'), isNotEmpty);
      expect(search(site, query: 'zzzz-nothing'), isEmpty);
    });
  });
}
