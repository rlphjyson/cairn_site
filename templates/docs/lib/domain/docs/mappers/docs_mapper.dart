import '../../../common/utils/slugify.dart';
import '../models/doc_block.dart';
import '../models/doc_page.dart';
import '../models/doc_version.dart';
import '../models/docs_site.dart';

/// Turns the JSON a data source returns into domain models.
///
/// This is the one place that knows the content format, so it is also the
/// place to look when you replace the in-memory content with Markdown or a CMS:
/// either produce JSON of this shape, or write another mapper beside this one.
/// Malformed content throws a [FormatException] that names the page and the
/// block, so a typo in the content fails loudly instead of rendering wrong.
class DocsMapper {
  /// Creates a mapper.
  const DocsMapper();

  /// `{"versions": [{"id", "label", "latest"?, "notice"?}]}`.
  List<DocVersion> versions(Map<String, dynamic> json) {
    final List<dynamic> list = _list(json, 'versions', 'manifest');
    return <DocVersion>[
      for (final dynamic v in list)
        DocVersion(
          id: _string(_map(v, 'version'), 'id', 'version'),
          label: _string(_map(v, 'version'), 'label', 'version'),
          isLatest: _map(v, 'version')['latest'] == true,
          notice: _map(v, 'version')['notice'] as String?,
        ),
    ];
  }

  /// `{"sidebar": [...], "pages": [...]}` for one version.
  DocsSite site(String versionId, Map<String, dynamic> json) {
    final Map<String, DocPage> pages = <String, DocPage>{
      for (final dynamic p in _list(json, 'pages', 'site'))
        _string(_map(p, 'page'), 'slug', 'page'): page(_map(p, 'page')),
    };

    final List<SidebarSection> sidebar = <SidebarSection>[];
    for (final dynamic s in _list(json, 'sidebar', 'site')) {
      final Map<String, dynamic> section = _map(s, 'sidebar section');
      final String sectionId = _string(section, 'id', 'sidebar section');
      final List<SidebarItem> items = <SidebarItem>[];
      for (final dynamic i in _list(section, 'items', 'section "$sectionId"')) {
        // An item is a bare slug, or {"slug", "title"?} to override the title.
        final String slug = i is String
            ? i
            : _string(_map(i, 'sidebar item'), 'slug', 'sidebar item');
        final DocPage? target = pages[slug];
        if (target == null) {
          throw FormatException(
            'Section "$sectionId" lists "$slug", which has no page in '
            '$versionId.',
          );
        }
        final String? title = i is Map<String, dynamic>
            ? i['title'] as String?
            : null;
        items.add(SidebarItem(slug: slug, title: title ?? target.title));
      }
      sidebar.add(
        SidebarSection(
          id: sectionId,
          title: _string(section, 'title', 'sidebar section'),
          items: items,
        ),
      );
    }
    return DocsSite(versionId: versionId, sidebar: sidebar, pages: pages);
  }

  /// One page: `{"slug", "title", "description", "updated", "blocks"}`.
  DocPage page(Map<String, dynamic> json) {
    final String slug = _string(json, 'slug', 'page');
    final Set<String> usedIds = <String>{};
    return DocPage(
      slug: slug,
      title: _string(json, 'title', 'page "$slug"'),
      description: (json['description'] as String?) ?? '',
      updated: DateTime.parse(_string(json, 'updated', 'page "$slug"')),
      blocks: <DocBlock>[
        for (final dynamic b in _list(json, 'blocks', 'page "$slug"'))
          block(_map(b, 'block in "$slug"'), slug, usedIds),
      ],
    );
  }

  /// One block. [usedIds] keeps heading anchors unique within the page.
  DocBlock block(
    Map<String, dynamic> json,
    String pageSlug, [
    Set<String>? usedIds,
  ]) {
    final String where = 'page "$pageSlug"';
    final String type = _string(json, 'type', 'a block in $where');
    List<DocBlock> children(dynamic value) => <DocBlock>[
      for (final dynamic b in (value as List<dynamic>? ?? <dynamic>[]))
        block(_map(b, 'nested block in $where'), pageSlug),
    ];

    switch (type) {
      case 'heading':
        final int level = (json['level'] as int?) ?? 2;
        if (level != 2 && level != 3) {
          throw FormatException('Heading level must be 2 or 3 in $where.');
        }
        final String text = _string(json, 'text', 'heading in $where');
        String id = (json['id'] as String?) ?? slugify(text);
        if (usedIds != null) {
          final String base = id;
          int n = 2;
          while (!usedIds.add(id)) {
            id = '$base-${n++}';
          }
        }
        return HeadingBlock(level: level, id: id, text: text);
      case 'paragraph':
        return ParagraphBlock(_string(json, 'text', 'paragraph in $where'));
      case 'code':
        return CodeBlock(
          language: CodeLanguage.parse(json['language'] as String?),
          code: _string(json, 'code', 'code block in $where'),
          title: json['title'] as String?,
        );
      case 'callout':
        return CalloutBlock(
          kind: CalloutKind.parse(json['kind'] as String?),
          title: json['title'] as String?,
          text: _string(json, 'text', 'callout in $where'),
        );
      case 'tabs':
        return TabsBlock(<TabItem>[
          for (final dynamic t in _list(json, 'tabs', 'tabs block in $where'))
            TabItem(
              label: _string(_map(t, 'tab'), 'label', 'tab in $where'),
              blocks: children(_map(t, 'tab')['blocks']),
            ),
        ]);
      case 'steps':
        return StepsBlock(<StepItem>[
          for (final dynamic s in _list(json, 'steps', 'steps block in $where'))
            StepItem(
              title: _string(_map(s, 'step'), 'title', 'step in $where'),
              blocks: children(_map(s, 'step')['blocks']),
            ),
        ]);
      case 'table':
        final List<String> headers = <String>[
          for (final dynamic h in _list(json, 'headers', 'table in $where'))
            h as String,
        ];
        return TableBlock(
          headers: headers,
          rows: <List<String>>[
            for (final dynamic r in _list(json, 'rows', 'table in $where'))
              <String>[for (final dynamic c in r as List<dynamic>) c as String],
          ],
        );
      case 'list':
        return ListBlock(
          ordered: json['ordered'] == true,
          items: <String>[
            for (final dynamic i in _list(json, 'items', 'list in $where'))
              i as String,
          ],
        );
      default:
        throw FormatException('Unknown block type "$type" in $where.');
    }
  }

  static Map<String, dynamic> _map(dynamic value, String what) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Expected an object for $what, got $value.');
  }

  static List<dynamic> _list(
    Map<String, dynamic> json,
    String key,
    String what,
  ) {
    final dynamic value = json[key];
    if (value is List<dynamic>) return value;
    throw FormatException('Expected "$key" to be a list in $what.');
  }

  static String _string(Map<String, dynamic> json, String key, String what) {
    final dynamic value = json[key];
    if (value is String) return value;
    throw FormatException('Expected "$key" to be a string in $what.');
  }
}
