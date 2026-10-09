/// Getting started: introduction, installation and quick start (v2.0).
const List<Map<String, dynamic>> v2StartPages = <Map<String, dynamic>>[
  <String, dynamic>{
    'slug': 'introduction',
    'title': 'Introduction',
    'description':
        'Acme SDK is a typed Dart client for the Acme Cloud API. Learn what '
        'it does and how this documentation is organised.',
    'updated': '2026-03-04',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            '**Acme SDK** is a typed client for the Acme Cloud API, written '
            'in Dart and designed for Flutter apps and server-side Dart. It '
            'handles authentication, retries and pagination so your code can '
            'stay about your product.',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'tip',
        'text':
            'In a hurry? Jump to the [quick start](quick-start) and have a '
            'working request in about five minutes.',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Why Acme SDK'},
      <String, dynamic>{
        'type': 'list',
        'items': <String>[
          '**Typed end to end.** Every request and response is a Dart class, '
              'so the analyzer catches a wrong field before your users do.',
          '**Safe by default.** Requests retry with exponential back-off, and '
              'secrets never appear in logs.',
          '**Small.** One dependency, no code generation, and it tree-shakes '
              'well for Flutter web.',
          '**Testable.** A fake transport ships in the box, so tests never '
              'touch the network.',
        ],
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'How these docs are organised',
      },
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Section', 'Read it when you want to'],
        'rows': <List<String>>[
          <String>[
            'Getting started',
            'Install the package and make a request.',
          ],
          <String>[
            'Guides',
            'Configure the client, sign in, handle errors, page through '
                'results and write tests.',
          ],
          <String>[
            'API reference',
            'Look up a class, a method or a parameter.',
          ],
          <String>['Resources', 'See what changed, or find a quick answer.'],
        ],
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Versions'},
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'These pages describe **v2.0**. Upgrading from v1? Read the '
            '[changelog](changelog#2-0-0) first; the breaking changes are '
            'listed there. Use the version menu in the top bar to read the '
            'v1.x documentation.',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'installation',
    'title': 'Installation',
    'description':
        'Add acme_sdk to a Dart or Flutter project and check that it works.',
    'updated': '2026-02-18',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Requirements'},
      <String, dynamic>{
        'type': 'list',
        'items': <String>[
          'Dart **3.4** or newer (Flutter **3.22** or newer).',
          'An Acme account and an API key. Create one in the '
              '[dashboard](https://acme.example/dashboard/keys).',
          'Any platform Dart supports: mobile, desktop, web and server.',
        ],
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Add the package',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text': 'Use whichever tool your project already uses.',
      },
      <String, dynamic>{
        'type': 'tabs',
        'tabs': <Map<String, dynamic>>[
          <String, dynamic>{
            'label': 'Dart',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'bash',
                'code': 'dart pub add acme_sdk',
              },
            ],
          },
          <String, dynamic>{
            'label': 'Flutter',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'bash',
                'code': 'flutter pub add acme_sdk',
              },
            ],
          },
          <String, dynamic>{
            'label': 'pubspec.yaml',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'yaml',
                'title': 'pubspec.yaml',
                'code': '''
dependencies:
  acme_sdk: ^2.0.0
''',
              },
              <String, dynamic>{
                'type': 'paragraph',
                'text': 'Then run `dart pub get`.',
              },
            ],
          },
        ],
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Verify the install',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Import the package and print its version. If this compiles, the '
            'install worked.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'title': 'bin/check.dart',
        'code': '''
import 'package:acme_sdk/acme_sdk.dart';

void main() {
  print('Acme SDK \$acmeSdkVersion');
}
''',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'warning',
        'title': 'Web builds',
        'text':
            'Browsers block cross-origin requests that lack CORS headers. Use '
            'a publishable key (`pk_...`) in client code, never a secret key.',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Next steps'},
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Continue with the [quick start](quick-start), or read about '
            '[configuration](configuration) if you need a proxy or custom '
            'timeouts.',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'quick-start',
    'title': 'Quick start',
    'description':
        'Make your first authenticated request and read a project back.',
    'updated': '2026-03-01',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'This walkthrough creates a project and reads it back. It '
            'assumes you have [installed](installation) the package.',
      },
      <String, dynamic>{
        'type': 'steps',
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'title': 'Create a client',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'paragraph',
                'text':
                    'Pass your API key. Read it from the environment rather '
                    'than committing it.',
              },
              <String, dynamic>{
                'type': 'code',
                'language': 'dart',
                'code': '''
final acme = AcmeClient(
  apiKey: Platform.environment['ACME_API_KEY']!,
);''',
              },
            ],
          },
          <String, dynamic>{
            'title': 'Create a project',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'dart',
                'code': '''
final project = await acme.projects.create(
  name: 'Hello, Acme',
  region: Region.euWest,
);
print(project.id); // prj_8f3k2n''',
              },
            ],
          },
          <String, dynamic>{
            'title': 'Read it back',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'code',
                'language': 'dart',
                'code': '''
final fetched = await acme.projects.get(project.id);
assert(fetched.name == 'Hello, Acme');''',
              },
              <String, dynamic>{
                'type': 'paragraph',
                'text': 'That is a complete round trip.',
              },
            ],
          },
          <String, dynamic>{
            'title': 'Close the client',
            'blocks': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'paragraph',
                'text':
                    'Call `close()` when you are done so open connections are '
                    'released. In Flutter, do it in `dispose`.',
              },
            ],
          },
        ],
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'The whole program',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'title': 'bin/main.dart',
        'code': '''
import 'dart:io';

import 'package:acme_sdk/acme_sdk.dart';

Future<void> main() async {
  final acme = AcmeClient(apiKey: Platform.environment['ACME_API_KEY']!);
  try {
    final project = await acme.projects.create(name: 'Hello, Acme');
    final fetched = await acme.projects.get(project.id);
    print('Created \${fetched.name} (\${fetched.id})');
  } on AcmeException catch (e) {
    stderr.writeln('Request failed: \${e.message}');
    exitCode = 1;
  } finally {
    acme.close();
  }
}
''',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'info',
        'text':
            'Every call can throw an [AcmeException](error-handling). The '
            'guide on error handling shows how to react to each kind.',
      },
    ],
  },
];
