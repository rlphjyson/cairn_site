/// The version list, and each version's sidebar tree.
///
/// A sidebar item is a page slug, or `{'slug': ..., 'title': ...}` to show a
/// different title in the sidebar than on the page. The order here is the
/// reading order and the order of the previous / next links.
const Map<String, dynamic> docsManifest = <String, dynamic>{
  'versions': <Map<String, dynamic>>[
    <String, dynamic>{'id': 'v2.0', 'label': 'v2.0', 'latest': true},
    <String, dynamic>{
      'id': 'v1.x',
      'label': 'v1.x',
      'notice':
          'You are reading the documentation for v1.x, which only receives '
          'security fixes. Switch to v2.0 for the current API.',
    },
  ],
};

/// The v2.0 sidebar.
const List<Map<String, dynamic>> v2Sidebar = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'getting-started',
    'title': 'Getting started',
    'items': <dynamic>['introduction', 'installation', 'quick-start'],
  },
  <String, dynamic>{
    'id': 'guides',
    'title': 'Guides',
    'items': <dynamic>[
      'configuration',
      'authentication',
      'error-handling',
      'pagination',
      'testing',
    ],
  },
  <String, dynamic>{
    'id': 'api-reference',
    'title': 'API reference',
    'items': <dynamic>[
      <String, dynamic>{'slug': 'api-client', 'title': 'AcmeClient'},
      <String, dynamic>{'slug': 'api-projects', 'title': 'Projects'},
      <String, dynamic>{'slug': 'api-events', 'title': 'Events'},
    ],
  },
  <String, dynamic>{
    'id': 'resources',
    'title': 'Resources',
    'items': <dynamic>['changelog', 'faq'],
  },
];

/// The v1.x sidebar: a smaller set, so switching version visibly changes it.
const List<Map<String, dynamic>> v1Sidebar = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'getting-started',
    'title': 'Getting started',
    'items': <dynamic>['introduction', 'installation', 'quick-start'],
  },
  <String, dynamic>{
    'id': 'guides',
    'title': 'Guides',
    'items': <dynamic>['configuration', 'error-handling'],
  },
  <String, dynamic>{
    'id': 'resources',
    'title': 'Resources',
    'items': <dynamic>['changelog'],
  },
];
