/// Where the onboarding's content is fetched from.
///
/// It returns decoded JSON, exactly what an HTTP client or a remote-config SDK
/// would hand you. `FlowMapper` turns it into the domain model.
abstract interface class FlowRemoteDataSource {
  /// Fetches the flow's content. See `doc/index.html` for every key.
  Future<Map<String, Object?>> fetchFlow();
}

/// Serves the demo content from memory.
///
/// **This is the place to change the content**: the pages, the permission
/// cards, the interests, goals and reminder options, and which steps appear
/// and in what order. To load it from your backend or remote config instead,
/// write a data source that returns the same JSON and register it in place of
/// this one (or pass it as `OnboardingApp.flowDataSource`).
class InMemoryFlowRemoteDataSource implements FlowRemoteDataSource {
  /// Creates the data source. [latency] simulates a network round trip.
  const InMemoryFlowRemoteDataSource({this.latency = Duration.zero});

  /// How long [fetchFlow] takes to answer.
  final Duration latency;

  @override
  Future<Map<String, Object?>> fetchFlow() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return content;
  }

  /// The demo content. Images are paths inside this package's `assets/images`.
  static const Map<String, Object?> content = <String, Object?>{
    // The steps, in order. Leave one out to remove it; `done` is always last.
    'steps': <Object?>[
      <String, Object?>{'kind': 'welcome', 'skippable': true},
      <String, Object?>{
        'kind': 'permissions',
        'title': 'Stay in the loop',
        'body': 'Allow what helps. You can change any of this later.',
        'skippable': true,
      },
      <String, Object?>{
        'kind': 'personalise',
        'title': 'Make it yours',
        'body': 'Three quick questions, then you are in.',
      },
      <String, Object?>{
        'kind': 'account',
        'title': 'Keep your routine safe',
        'body':
            'An account saves your progress across devices. Or look around '
            'first and decide later.',
        'skippable': true,
      },
      <String, Object?>{
        'kind': 'done',
        'title': 'You are all set',
        'body': 'Here is what Daybreak will be tuned to.',
      },
    ],
    'pages': <Object?>[
      <String, Object?>{
        'id': 'morning',
        'title': 'Start the day on your terms',
        'body':
            'Daybreak turns the things you mean to do into a calm, simple '
            'routine.',
        'image': 'assets/images/welcome-morning.jpg',
        'imageLabel': 'A cup of tea on a sunlit wooden windowsill',
      },
      <String, Object?>{
        'id': 'focus',
        'title': 'Make room for what matters',
        'body':
            'Plan each day around a few priorities, not an endless list of '
            'tasks.',
        'image': 'assets/images/focus-workspace.jpg',
        'imageLabel': 'A tidy desk with an open notebook beside a window',
      },
      <String, Object?>{
        'id': 'together',
        'title': 'Better with people',
        'body':
            'Share a streak with a friend and keep each other going, one '
            'day at a time.',
        'image': 'assets/images/together-friends.jpg',
        'imageLabel': 'Two friends smiling together by a lake at dusk',
      },
      <String, Object?>{
        'id': 'explore',
        'title': 'Go further, gently',
        'body': 'Small steps add up. Watch your progress grow week after week.',
        'image': 'assets/images/explore-ridge.jpg',
        'imageLabel': 'A hiker with raised arms on a green mountain ridge',
      },
    ],
    // Add a camera card with {'kind': 'camera', ...}.
    'permissions': <Object?>[
      <String, Object?>{
        'kind': 'notifications',
        'title': 'Notifications',
        'benefit':
            'Gentle reminders at the times you choose. Never noisy, never '
            'more than you ask for.',
        'deniedHelp':
            'Notifications are off. To turn them on, open your device '
            'settings, choose Daybreak, then Notifications.',
      },
      <String, Object?>{
        'kind': 'location',
        'title': 'Location',
        'benefit':
            'Suggest walks and outdoor habits near you, and keep reminders '
            'on time when you travel.',
        'deniedHelp':
            'Location is off. To turn it on, open your device settings, '
            'choose Daybreak, then Location.',
      },
    ],
    'personalise': <String, Object?>{
      'minInterests': 3,
      'defaultReminder': 'morning',
      'interests': <Object?>[
        <String, Object?>{'id': 'focus', 'label': 'Focus'},
        <String, Object?>{'id': 'fitness', 'label': 'Fitness'},
        <String, Object?>{'id': 'reading', 'label': 'Reading'},
        <String, Object?>{'id': 'sleep', 'label': 'Sleep'},
        <String, Object?>{'id': 'mindfulness', 'label': 'Mindfulness'},
        <String, Object?>{'id': 'cooking', 'label': 'Cooking'},
        <String, Object?>{'id': 'learning', 'label': 'Learning'},
        <String, Object?>{'id': 'money', 'label': 'Money'},
        <String, Object?>{'id': 'outdoors', 'label': 'Outdoors'},
        <String, Object?>{'id': 'music', 'label': 'Music'},
      ],
      'goals': <Object?>[
        <String, Object?>{
          'id': 'routine',
          'label': 'Build a routine',
          'hint': 'Do the same few things every day.',
        },
        <String, Object?>{
          'id': 'calm',
          'label': 'Feel calmer',
          'hint': 'Make a little room to breathe.',
        },
        <String, Object?>{
          'id': 'focus',
          'label': 'Stay focused',
          'hint': 'Protect time for the work that counts.',
        },
        <String, Object?>{
          'id': 'move',
          'label': 'Move more',
          'hint': 'Add gentle activity to every day.',
        },
      ],
      'reminders': <Object?>[
        <String, Object?>{'id': 'morning', 'label': 'Every morning, 8:00'},
        <String, Object?>{'id': 'weekdays', 'label': 'Weekdays, 9:00'},
        <String, Object?>{'id': 'evening', 'label': 'Every evening, 20:00'},
        <String, Object?>{'id': 'weekly', 'label': 'Once a week, Sunday'},
        <String, Object?>{'id': 'none', 'label': 'No reminders'},
      ],
    },
  };
}
