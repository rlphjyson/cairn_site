/// Guides: configuration, authentication, error handling, pagination and
/// testing (v2.0).
const List<Map<String, dynamic>> v2GuidesPages = <Map<String, dynamic>>[
  <String, dynamic>{
    'slug': 'configuration',
    'title': 'Configuration',
    'description':
        'Tune timeouts, retries, the base URL and logging for AcmeClient.',
    'updated': '2026-02-27',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Every option has a default that suits most apps. Pass an '
            '`AcmeConfig` to the client only when you need to change one.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
final acme = AcmeClient(
  apiKey: key,
  config: const AcmeConfig(
    timeout: Duration(seconds: 20),
    maxRetries: 4,
    logLevel: LogLevel.warning,
  ),
);''',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Options'},
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Option', 'Default', 'Description'],
        'rows': <List<String>>[
          <String>[
            '`timeout`',
            '`30s`',
            'How long to wait for a response before failing.',
          ],
          <String>[
            '`maxRetries`',
            '`3`',
            'Attempts after the first for idempotent requests.',
          ],
          <String>[
            '`baseUrl`',
            '`https://api.acme.example`',
            'Point at a proxy or a sandbox.',
          ],
          <String>[
            '`logLevel`',
            '`LogLevel.none`',
            'Set to `debug` to print requests. Secrets are redacted.',
          ],
          <String>[
            '`userAgentSuffix`',
            '`null`',
            'Appended to the User-Agent header for your own tracing.',
          ],
        ],
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Environments'},
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Keep one config per environment and choose it at start-up. The '
            'sandbox base URL never touches production data.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
AcmeConfig configFor(String env) => switch (env) {
  'production' => const AcmeConfig(),
  _ => const AcmeConfig(baseUrl: 'https://sandbox.acme.example'),
};''',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'tip',
        'text':
            'Lower `maxRetries` on user-facing requests. Three retries with '
            'back-off can add several seconds to a failure the user is '
            'waiting on.',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Retries and back-off',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'The client retries network failures and `429` / `5xx` responses. '
            'The wait doubles each attempt (200 ms, 400 ms, 800 ms) with a '
            'random jitter, and honours a `Retry-After` header when the server '
            'sends one. `POST` requests are only retried when you pass an '
            '`idempotencyKey`.',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'authentication',
    'title': 'Authentication',
    'description':
        'Use API keys on the server and short-lived tokens in client apps.',
    'updated': '2026-03-09',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Acme supports two ways to prove who you are. Pick by where the '
            'code runs: **API keys** on servers you control, **tokens** in '
            'apps you ship to users.',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'API keys'},
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'A key is a long-lived secret. Secret keys start with `sk_` and '
            'can do anything your account can; publishable keys start with '
            '`pk_` and can only read public data.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': "final acme = AcmeClient(apiKey: 'sk_live_...');",
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'warning',
        'title': 'Never ship a secret key',
        'text':
            'Anything in a mobile or web bundle can be extracted. If a secret '
            'key leaks, revoke it in the [dashboard](https://acme.example/'
            'dashboard/keys) straight away.',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Short-lived tokens',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Your server mints a token for a signed-in user; the app uses it '
            'until it expires. Give the client a `TokenProvider` and it asks '
            'for a fresh token when the old one is about to lapse.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
final acme = AcmeClient.withTokens(
  tokens: TokenProvider(() async {
    final res = await myBackend.post('/acme-token');
    return AcmeToken.fromJson(res.json);
  }),
);''',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 3,
        'text': 'Token lifetime',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Tokens last 15 minutes. The provider is called at most once per '
            'expiry, however many requests are in flight.',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 3,
        'text': 'Revoking access',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Call `acme.signOut()` to forget the cached token. Requests made '
            'afterwards ask the provider again.',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Scopes'},
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Scope', 'Grants'],
        'rows': <List<String>>[
          <String>['`projects:read`', 'List and fetch projects.'],
          <String>['`projects:write`', 'Create, update and delete projects.'],
          <String>['`events:read`', 'Read and stream events.'],
        ],
      },
    ],
  },
  <String, dynamic>{
    'slug': 'error-handling',
    'title': 'Error handling',
    'description':
        'Every failure is an AcmeException. Catch the subtype you can act on.',
    'updated': '2026-03-12',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'The SDK never returns an error code for you to check. Failures '
            'are thrown as a sealed `AcmeException`, so a `switch` over it is '
            'exhaustive and the analyzer tells you when a new kind appears.',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'The exception types',
      },
      <String, dynamic>{
        'type': 'table',
        'headers': <String>['Type', 'When', 'Retried'],
        'rows': <List<String>>[
          <String>[
            '`AcmeAuthException`',
            'The key or token was rejected.',
            'No',
          ],
          <String>[
            '`AcmeRateLimitException`',
            'Too many requests. Has `retryAfter`.',
            'Yes',
          ],
          <String>[
            '`AcmeNetworkException`',
            'No connection, or the request timed out.',
            'Yes',
          ],
          <String>[
            '`AcmeApiException`',
            'The API refused the request. Has `code` and `message`.',
            'No',
          ],
        ],
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'Handling them'},
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
try {
  await acme.projects.delete(id);
} on AcmeException catch (e) {
  switch (e) {
    case AcmeAuthException():
      await signOut();
    case AcmeRateLimitException(:final retryAfter):
      showSnack('Slow down. Try again in \${retryAfter.inSeconds}s.');
    case AcmeNetworkException():
      showSnack('You appear to be offline.');
    case AcmeApiException(:final code):
      log.warning('Acme refused the request: \$code');
  }
}''',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'info',
        'text':
            'Retries happen inside the client before an exception reaches '
            'you. See [retries and back-off](configuration#retries-and-back-off).',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Error payloads',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'An `AcmeApiException` carries the raw response body in `body`, '
            'which is useful in bug reports.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'json',
        'title': 'Example error body',
        'code': '''
{
  "error": {
    "code": "project_name_taken",
    "message": "A project named \\"Hello\\" already exists.",
    "request_id": "req_91ac02"
  }
}''',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Quote the `request_id` when you contact support; it lets us find '
            'the request.',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'pagination',
    'title': 'Pagination',
    'description':
        'Walk through long lists a page at a time, or as a single stream.',
    'updated': '2026-01-30',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'List endpoints return a `Page<T>`. A page holds up to `limit` '
            'items (default 25, maximum 100) and a cursor for the next one.',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'One page at a time',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
var page = await acme.projects.list(limit: 50);
while (true) {
  for (final project in page.items) {
    print(project.name);
  }
  if (!page.hasNext) break;
  page = await page.next();
}''',
      },
      <String, dynamic>{'type': 'heading', 'level': 2, 'text': 'As a stream'},
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            '`listAll()` fetches pages lazily as you consume it, so stopping '
            'early costs nothing.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
await for (final project in acme.projects.listAll()) {
  if (project.archived) continue;
  print(project.name);
}''',
      },
      <String, dynamic>{
        'type': 'callout',
        'kind': 'tip',
        'text':
            'Cursors do not expire for an hour, so it is safe to store one '
            'and resume a long export later.',
      },
    ],
  },
  <String, dynamic>{
    'slug': 'testing',
    'title': 'Testing',
    'description': 'Test code that uses Acme without touching the network.',
    'updated': '2026-02-10',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'The `acme_sdk/testing.dart` library ships a `FakeAcmeTransport` '
            'that answers requests from a script you control. Nothing leaves '
            'your machine.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'title': 'test/projects_test.dart',
        'code': '''
import 'package:acme_sdk/acme_sdk.dart';
import 'package:acme_sdk/testing.dart';
import 'package:test/test.dart';

void main() {
  test('lists projects', () async {
    final transport = FakeAcmeTransport()
      ..on('GET', '/v2/projects', respond: {
        'items': [
          {'id': 'prj_1', 'name': 'Demo'},
        ],
      });
    final acme = AcmeClient(apiKey: 'sk_test', transport: transport);

    final page = await acme.projects.list();

    expect(page.items.single.name, 'Demo');
    expect(transport.requests, hasLength(1));
  });
}''',
      },
      <String, dynamic>{
        'type': 'heading',
        'level': 2,
        'text': 'Simulating failures',
      },
      <String, dynamic>{
        'type': 'paragraph',
        'text':
            'Make the fake fail to check your error handling. The retry '
            'policy still applies, so set `maxRetries: 0` for a fast test.',
      },
      <String, dynamic>{
        'type': 'code',
        'language': 'dart',
        'code': '''
transport.on('GET', '/v2/projects', status: 429, headers: {
  'retry-after': '2',
});''',
      },
    ],
  },
];
