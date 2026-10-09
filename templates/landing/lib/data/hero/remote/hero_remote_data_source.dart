import '../../../common/utils/json.dart';

/// Reads the hero as decoded JSON.
abstract interface class HeroRemoteDataSource {
  /// The hero.
  Future<JsonMap> fetchHero();
}

/// The demo hero: headline, calls to action, social proof and the dashboard
/// drawn inside the browser mockup.
class InMemoryHeroRemoteDataSource implements HeroRemoteDataSource {
  /// Creates the data source.
  const InMemoryHeroRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'announcement': <String, Object?>{
      'label': 'New: Roadmaps 2.0 is here',
      'href': '#features',
    },
    'headline': 'Plan work your whole team can actually see.',
    'subcopy':
        'Kestrel brings roadmaps, tasks and reporting into one calm '
        'workspace, so every project ships on the date you promised.',
    'primaryCta': <String, Object?>{
      'label': 'Join the waitlist',
      'href': '#waitlist',
    },
    'secondaryCta': <String, Object?>{
      'label': 'See how it works',
      'href': '#how-it-works',
    },
    'proof': <String, Object?>{
      'text': 'Loved by 12,000+ teams',
      'rating': 4.9,
      'ratingLabel': 'Rated 4.9 out of 5 from 2,300 reviews',
      'avatars': <Object?>[
        'assets/images/avatar-maya.jpg',
        'assets/images/avatar-diego.jpg',
        'assets/images/avatar-amara.jpg',
        'assets/images/avatar-samuel.jpg',
      ],
    },
    'visual': <String, Object?>{
      'url': 'app.kestrel.example/launch',
      'project': 'Spring launch',
      'status': 'On track',
      'sidebar': <Object?>[
        <String, Object?>{
          'icon': 'dashboard',
          'label': 'Overview',
          'active': true,
        },
        <String, Object?>{'icon': 'folder', 'label': 'Projects'},
        <String, Object?>{'icon': 'roadmap', 'label': 'Roadmap'},
        <String, Object?>{'icon': 'bar_chart', 'label': 'Reports'},
        <String, Object?>{'icon': 'groups', 'label': 'Team'},
      ],
      'metrics': <Object?>[
        <String, Object?>{
          'label': 'Tasks done',
          'value': '128',
          'delta': '+12%',
        },
        <String, Object?>{'label': 'On time', 'value': '94%', 'delta': '+3%'},
        <String, Object?>{
          'label': 'Cycle time',
          'value': '3.2d',
          'delta': '-18%',
        },
      ],
      'chartTitle': 'Throughput',
      'barLabels': <Object?>['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      'bars': <Object?>[0.42, 0.58, 0.5, 0.74, 0.66, 0.9, 0.78],
      'tasksTitle': 'Up next',
      'tasks': <Object?>[
        <String, Object?>{
          'title': 'Finalise launch checklist',
          'owner': 'assets/images/avatar-claire.jpg',
          'status': 'In review',
          'progress': 0.8,
        },
        <String, Object?>{
          'title': 'Publish the changelog',
          'owner': 'assets/images/avatar-diego.jpg',
          'status': 'In progress',
          'progress': 0.45,
        },
        <String, Object?>{
          'title': 'Brief the support team',
          'owner': 'assets/images/avatar-elena.jpg',
          'status': 'To do',
          'progress': 0.1,
        },
      ],
      'team': <Object?>[
        'assets/images/avatar-maya.jpg',
        'assets/images/avatar-amara.jpg',
        'assets/images/avatar-samuel.jpg',
      ],
    },
  };

  @override
  Future<JsonMap> fetchHero() async => _json;
}
