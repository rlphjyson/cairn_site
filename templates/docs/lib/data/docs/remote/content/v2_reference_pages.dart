/// API reference, changelog and FAQ (v2.0).
const List<Map<String, dynamic>> v2ReferencePages = <Map<String, dynamic>>[
  <String, dynamic>{
    'slug': 'api-client',
    'title': 'AcmeClient',
    'description': 'The entry point: constructors, properties and lifecycle.',
    'updated': '2026-03-09',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            '`AcmeClient` owns the HTTP connection and exposes one property '
            'per resource. Create one per app and share it.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
class AcmeClient {
  AcmeClient({
    required String apiKey,
    AcmeConfig config = const AcmeConfig(),
    AcmeTransport? transport,
  });

  factory AcmeClient.withTokens({
    required TokenProvider tokens,
    AcmeConfig config = const AcmeConfig(),
  });

  ProjectsApi get projects;
  EventsApi get events;

  void signOut();
  void close();
}''',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Constructors'},
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Constructor', 'Use it for'],
        'rows': <List<String>>[
          <String>['`AcmeClient(apiKey: ...)`', 'Servers and scripts.'],
          <String>[
            '`AcmeClient.withTokens(tokens: ...)`',
            'Apps that sign users in. See [authentication](authentication).',
          ],
        ],
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Parameters'},
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Name', 'Type', 'Description'],
        'rows': <List<String>>[
          <String>['`apiKey`', '`String`', 'A secret or publishable key.'],
          <String>[
            '`config`',
            '`AcmeConfig`',
            'Timeouts and retries. See [configuration](configuration).',
          ],
          <String>[
            '`transport`',
            '`AcmeTransport?`',
            'Replaces the HTTP layer; used by tests.',
          ],
        ],
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Lifecycle'},
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            '`close()` releases sockets and cancels in-flight requests, which '
            'then throw an `AcmeNetworkException`. Using a closed client '
            'throws a `StateError`.',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'warning',
        'text':
            'Do not create a client per request. Each one opens its own '
            'connection pool.',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'api-projects',
    'title': 'Projects',
    'description': 'Create, read, update, list and delete projects.',
    'updated': '2026-03-09',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'A project groups your resources and billing. All methods live on '
            '`acme.projects` and need the `projects:read` or `projects:write` '
            '[scope](authentication#scopes).',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Methods'},
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Method', 'Returns', 'Description'],
        'rows': <List<String>>[
          <String>[
            '`create({name, region})`',
            '`Future<Project>`',
            'Creates a project.',
          ],
          <String>['`get(id)`', '`Future<Project>`', 'Fetches one project.'],
          <String>[
            '`list({limit, cursor})`',
            '`Future<Page<Project>>`',
            'Lists projects, newest first. See [pagination](pagination).',
          ],
          <String>[
            '`update(id, {name})`',
            '`Future<Project>`',
            'Renames a project.',
          ],
          <String>['`delete(id)`', '`Future<void>`', 'Deletes a project.'],
        ],
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'The Project class',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
class Project {
  final String id;        // prj_...
  final String name;
  final Region region;
  final DateTime createdAt;
  final bool archived;
}''',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Example'},
      <String, dynamic>{
        'type': 'tabs',
        'tabs': <Map<String, dynamic>>[
          <String, dynamic>{
            'label': 'Dart',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'dart',
                'code': '''
final project = await acme.projects.update(
  'prj_8f3k2n',
  name: 'Renamed',
);''',
              },
            ],
          },
          <String, dynamic>{
            'label': 'curl',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'bash',
                'code': '''
curl -X PATCH https://api.acme.example/v2/projects/prj_8f3k2n \\
  -H "Authorization: Bearer \$ACME_API_KEY" \\
  -d '{"name": "Renamed"}\'''',
              },
            ],
          },
        ],
      },
    ],
  },
  <String, dynamic>{
    'slug': 'api-events',
    'title': 'Events',
    'description': 'Read the activity log and subscribe to live events.',
    'updated': '2026-02-22',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Everything that happens in a project is recorded as an event. '
            'Read the log with `list`, or follow it live with `subscribe`.',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Event types'},
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Type', 'Fired when'],
        'rows': <List<String>>[
          <String>['`project.created`', 'A project is created.'],
          <String>['`project.updated`', 'A project is renamed or archived.'],
          <String>['`project.deleted`', 'A project is deleted.'],
          <String>['`key.revoked`', 'An API key is revoked.'],
        ],
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Subscribing'},
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
final sub = acme.events.subscribe(types: {'project.created'}).listen(
  (event) => print('New project: \${event.data['id']}'),
  onError: (Object e) => print('Stream error: \$e'),
);

// Later:
await sub.cancel();''',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'info',
        'text':
            'The stream reconnects on its own and resumes from the last event '
            'it saw, so a dropped connection does not lose events.',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Event shape'},
      <String, dynamic>{
        'type': 'code',
        'language': 'json',
        'code': '''
{
  "id": "evt_41b9",
  "type": "project.created",
  "created_at": "2026-03-09T10:14:03Z",
  "data": { "id": "prj_8f3k2n", "name": "Hello, Acme" }
}''',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'changelog',
    'title': 'Changelog',
    'description': 'What changed in each release, and how to upgrade.',
    'updated': '2026-03-12',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Acme SDK follows semantic versioning. Breaking changes only '
            'happen in a major release and are listed first.',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': '2.0.0'},
      <String, dynamic>{
        'type': 'paragraph',
        'text': '**Released March 2026.** A new, smaller, typed API.',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'warning',
        'title': 'Breaking changes',
        'text':
            'Errors are now a sealed `AcmeException` hierarchy instead of '
            'error codes, and `Acme.initialize` is replaced by `AcmeClient`.',
      },
      <String, dynamic>{
        'type': 'list',
        'items': <String>[
          'Added `acme.events.subscribe` for live events.',
          'Added `listAll()` streams for every list endpoint.',
          'Added `FakeAcmeTransport` in `acme_sdk/testing.dart`.',
          'Removed the global `Acme.instance`. Create an `AcmeClient` and '
              'pass it where it is needed.',
          'Raised the minimum Dart version to 3.4.',
        ],
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 3,
        'text': 'Upgrading from 1.x',
      },
      <String, dynamic>{
        'type': 'steps',
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'title': 'Update the dependency',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'bash',
                'code': 'dart pub upgrade acme_sdk --major-versions',
              },
            ],
          },
          <String, dynamic>{
            'title': 'Replace the singleton',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'dart',
                'code': '''
// Before
Acme.initialize(apiKey: key);
final p = await Acme.instance.getProject(id);

// After
final acme = AcmeClient(apiKey: key);
final p = await acme.projects.get(id);''',
              },
            ],
          },
          <String, dynamic>{
            'title': 'Catch the new exceptions',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'paragraph',
                'text':
                    'Replace checks on `error.code` with a `switch` over '
                    '[AcmeException](error-handling#the-exception-types).',
              },
            ],
          },
        ],
      },
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
  <String, dynamic>{
    'slug': 'faq',
    'title': 'FAQ',
    'description': 'Quick answers to the questions we hear most.',
    'updated': '2026-03-02',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Does it work on the web?',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Yes. Use a publishable key or a token in browser code, and make '
            'sure your site origin is on the allow-list in the '
            '[dashboard](https://acme.example/dashboard/origins).',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Can I use it without Flutter?',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Yes. The package depends only on Dart, so it runs in command-line '
            'tools and servers too.',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'How do I raise a rate limit?',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Limits are per key. Spread work across keys, or ask for a higher '
            'limit from the dashboard. See '
            '[errors](error-handling) for how a limit surfaces.',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Where do I report a bug?',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Open an issue on [GitHub](https://github.com/acme/acme-sdk/'
            'issues) and include the `request_id` from the error.',
      },
    ],
  },
];
