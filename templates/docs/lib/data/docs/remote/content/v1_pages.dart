/// The v1.x content set: smaller, and visibly different from v2.0, so the
/// version selector has something to switch between.
const List<Map<String, dynamic>> v1Pages = <Map<String, dynamic>>[
  <String, dynamic>{
    'slug': 'introduction',
    'title': 'Introduction',
    'description': 'Acme SDK 1.x: a singleton client for the Acme Cloud API.',
    'updated': '2025-06-20',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            '**Acme SDK 1.x** talks to the Acme Cloud API through a single, '
            'global `Acme` instance. It is in maintenance mode.',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'warning',
        'title': 'Maintenance mode',
        'text':
            'Version 1 receives security fixes only. Plan your move to '
            'v2.0 using the [changelog](changelog).',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'What is in v1'},
      <String, dynamic>{
        'type': 'list',
        'items': <String>[
          'A global `Acme.instance` configured once at start-up.',
          'Error codes on every response, such as `error.code`.',
          'Manual pagination with `nextCursor`.',
        ],
      },
    ],
  },
  <String, dynamic>{
    'slug': 'installation',
    'title': 'Installation',
    'description': 'Add acme_sdk 1.x to a Dart or Flutter project.',
    'updated': '2025-06-20',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Add the package',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'yaml',
        'title': 'pubspec.yaml',
        'code': '''
dependencies:
  acme_sdk: ^1.8.0
''',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text': 'v1 needs Dart **2.19** or newer.',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'quick-start',
    'title': 'Quick start',
    'description': 'Initialise Acme once and fetch a project.',
    'updated': '2025-06-20',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'steps',
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'title': 'Initialise',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'dart',
                'code': 'Acme.initialize(apiKey: key);',
              },
            ],
          },
          <String, dynamic>{
            'title': 'Fetch a project',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'dart',
                'code': '''
final res = await Acme.instance.getProject('prj_8f3k2n');
if (res.error != null) print(res.error!.code);''',
              },
            ],
          },
        ],
      },
    ],
  },
  <String, dynamic>{
    'slug': 'configuration',
    'title': 'Configuration',
    'description': 'The options Acme.initialize accepts in 1.x.',
    'updated': '2025-05-02',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Option', 'Default'],
        'rows': <List<String>>[
          <String>['`timeoutSeconds`', '`30`'],
          <String>['`retries`', '`3`'],
          <String>['`baseUrl`', '`https://api.acme.example`'],
        ],
      },
    ],
  },
  <String, dynamic>{
    'slug': 'error-handling',
    'title': 'Error handling',
    'description': 'Check the error code on every response.',
    'updated': '2025-05-02',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'In v1 calls return a response with an `error` field instead of '
            'throwing. Check it every time.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
final res = await Acme.instance.getProject(id);
switch (res.error?.code) {
  case 'auth_failed':
    signOut();
  case 'rate_limited':
    wait();
}''',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'changelog',
    'title': 'Changelog',
    'description': 'Releases in the 1.x line.',
    'updated': '2025-06-20',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': '1.8.2'},
      <String, dynamic>{
        'type': 'list',
        'items': <String>[
          'Fixed a crash when `Retry-After` was an HTTP date.',
          'Redacted API keys in debug logs.',
        ],
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': '1.8.0'},
      <String, dynamic>{
        'type': 'list',
        'items': <String>[
          'Added optional request logging.',
          'Added the `userAgentSuffix` option.',
        ],
      },
    ],
  },
];
