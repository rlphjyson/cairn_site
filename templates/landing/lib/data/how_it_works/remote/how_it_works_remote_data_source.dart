import '../../../common/utils/json.dart';

/// Reads the how-it-works section as decoded JSON.
abstract interface class HowItWorksRemoteDataSource {
  /// The how-it-works section.
  Future<JsonMap> fetchHowItWorks();
}

/// The demo steps. Add or remove steps; the layout adapts.
class InMemoryHowItWorksRemoteDataSource implements HowItWorksRemoteDataSource {
  /// Creates the data source.
  const InMemoryHowItWorksRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'eyebrow': 'How it works',
    'title': 'From first idea to shipped in three steps',
    'subtitle':
        'Set up in an afternoon. Most teams are running their first real '
        'sprint by the end of the day.',
    'steps': <Object?>[
      <String, Object?>{
        'icon': 'folder',
        'title': 'Bring your work in',
        'description':
            'Import from a spreadsheet or another tool, or start from a '
            'template built for product, design or operations.',
      },
      <String, Object?>{
        'icon': 'timeline',
        'title': 'Plan on a shared timeline',
        'description':
            'Set goals, assign owners and map dependencies. Kestrel flags '
            'conflicts before they become delays.',
      },
      <String, Object?>{
        'icon': 'rocket',
        'title': 'Ship and report with confidence',
        'description':
            'Track progress automatically and share live reports with the '
            'people who need them. No slide deck required.',
      },
    ],
  };

  @override
  Future<JsonMap> fetchHowItWorks() async => _json;
}
