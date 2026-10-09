import '../../../common/utils/json.dart';

/// Reads the features section as decoded JSON.
abstract interface class FeaturesRemoteDataSource {
  /// The features section.
  Future<JsonMap> fetchFeatures();
}

/// The demo features: six cards and three spotlights.
///
/// `icon` is a name from `LandingIcons`; `image` is a bundled asset path.
class InMemoryFeaturesRemoteDataSource implements FeaturesRemoteDataSource {
  /// Creates the data source.
  const InMemoryFeaturesRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'eyebrow': 'Features',
    'title': 'Everything a project needs, in one place',
    'subtitle':
        'Stop stitching together spreadsheets, chat threads and slide decks. '
        'Kestrel keeps plans, people and progress in a single source of truth.',
    'items': <Object?>[
      <String, Object?>{
        'icon': 'roadmap',
        'title': 'Roadmaps that stay honest',
        'description':
            'Drag work onto a timeline and watch dependencies shift with it. '
            'Everyone sees the same dates, always.',
        'tag': 'New',
      },
      <String, Object?>{
        'icon': 'bolt',
        'title': 'Automations',
        'description':
            'Move tasks, ping owners and update statuses without lifting a '
            'finger.',
      },
      <String, Object?>{
        'icon': 'insights',
        'title': 'Live reporting',
        'description':
            'Throughput, cycle time and workload charts that update as your '
            'team works.',
      },
      <String, Object?>{
        'icon': 'groups',
        'title': 'Workload view',
        'description':
            'Spot overloaded teammates before a deadline slips and rebalance '
            'in one drag.',
      },
      <String, Object?>{
        'icon': 'extension',
        'title': 'Integrations that just work',
        'description':
            'Connect the tools you already use, from chat and calendars to '
            'code hosting and support desks, in a couple of clicks.',
      },
      <String, Object?>{
        'icon': 'shield',
        'title': 'Secure by default',
        'description':
            'Single sign-on, audit logs and granular permissions on every '
            'paid plan.',
      },
    ],
    'spotlights': <Object?>[
      <String, Object?>{
        'eyebrow': 'Plan together',
        'title': 'One plan, shared by everyone',
        'description':
            'Planning is a team sport. Kestrel gives product, design and '
            'engineering the same live view, so the weekly sync can be about '
            'decisions instead of status.',
        'bullets': <Object?>[
          'Comment on any task, milestone or goal',
          'Share read-only roadmaps with stakeholders',
          'See who is working on what, right now',
        ],
        'image': 'assets/images/team-meeting.jpg',
        'imageAlt': 'A team planning together around a table with laptops',
        'cta': <String, Object?>{
          'label': 'Explore planning',
          'href': '#how-it-works',
        },
      },
      <String, Object?>{
        'eyebrow': 'Stay in flow',
        'title': 'Less status chasing, more shipping',
        'description':
            'Updates write themselves from the work your team already does. '
            'Reviewers get the context they need in one glance, not a long '
            'thread.',
        'bullets': <Object?>[
          'Automatic progress from linked pull requests',
          'Daily digests that people actually read',
          'Review queues with clear owners and due dates',
        ],
        'image': 'assets/images/team-review.jpg',
        'imageAlt': 'Two colleagues reviewing work together on a laptop',
        'cta': <String, Object?>{
          'label': 'See automations',
          'href': '#pricing',
        },
      },
      <String, Object?>{
        'eyebrow': 'Know where you stand',
        'title': 'Reports leaders trust',
        'description':
            'Turn the data your team already generates into clear reports. '
            'Share a link, export a PDF or schedule it to land in inboxes '
            'every Monday.',
        'bullets': <Object?>[
          'Portfolio views across every project',
          'Forecasts based on real throughput',
          'Scheduled and on-demand exports',
        ],
        'image': 'assets/images/team-analytics.jpg',
        'imageAlt': 'A team gathered around a laptop reviewing printed charts',
        'cta': <String, Object?>{'label': 'View reports', 'href': '#stats'},
      },
    ],
  };

  @override
  Future<JsonMap> fetchFeatures() async => _json;
}
