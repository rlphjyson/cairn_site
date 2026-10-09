import '../../../common/constants/confirmation_phrases.dart';
import 'settings_data_source.dart';

/// A [SettingsDataSource] that keeps everything in memory.
///
/// It is the demo backend: realistic seed data, a small artificial [latency] so
/// loading and saving states are visible, and a few rules that exercise the
/// error paths (the username `admin` is taken, the current password
/// `wrong-password` is rejected, the two-factor code is `123456`).
///
/// Extend it and override only the calls you replace:
///
/// ```dart
/// class MyDataSource extends InMemorySettingsDataSource {
///   @override
///   Future<Map<String, Object?>> loadSettings() async =>
///       jsonDecode(prefs.getString('settings') ?? '{}') as Map<String, Object?>;
/// }
/// ```
class InMemorySettingsDataSource implements SettingsDataSource {
  /// Creates the data source.
  ///
  /// [latency] is how long each call takes; use [Duration.zero] in tests.
  /// [now] supplies the clock, so session times are deterministic in tests.
  InMemorySettingsDataSource({
    this.latency = const Duration(milliseconds: 300),
    DateTime Function()? now,
    Map<String, Object?>? settings,
    Map<String, Object?>? profile,
    List<Map<String, Object?>>? blockedUsers,
    Map<String, Object?>? appInfo,
  }) : _now = now ?? DateTime.now,
       _settings = settings ?? <String, Object?>{},
       _profile =
           profile ??
           <String, Object?>{
             'name': 'Ada Lovelace',
             'username': 'ada',
             'email': 'ada@example.com',
             'bio': 'Writing the first programs.',
             'avatar': 'initials',
           },
       _blocked =
           blockedUsers ??
           <Map<String, Object?>>[
             <String, Object?>{
               'id': 'u1',
               'name': 'Charles Babbage',
               'username': 'cbabbage',
             },
             <String, Object?>{
               'id': 'u2',
               'name': 'Mary Somerville',
               'username': 'msomerville',
             },
           ],
       _appInfo = appInfo ?? _defaultAppInfo {
    final DateTime t = _now();
    _sessions = <Map<String, Object?>>[
      _session('s1', 'This phone', 'Lisbon, Portugal', t, current: true),
      _session(
        's2',
        'MacBook Pro',
        'Lisbon, Portugal',
        t.subtract(const Duration(hours: 3)),
      ),
      _session(
        's3',
        'iPad Air',
        'Porto, Portugal',
        t.subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// How long each call takes.
  final Duration latency;

  final DateTime Function() _now;
  Map<String, Object?> _settings;
  Map<String, Object?> _profile;
  final List<Map<String, Object?>> _blocked;
  final Map<String, Object?> _appInfo;
  late List<Map<String, Object?>> _sessions;
  int _cache = 92274688;
  int _exports = 0;
  bool _twoFactorPending = false;

  /// Usernames that are always taken.
  static const Set<String> reservedUsernames = <String>{
    'admin',
    'root',
    'support',
    'cairn',
  };

  static const Map<String, Object?> _defaultAppInfo = <String, Object?>{
    'name': 'Cairn Demo',
    'version': '2.4.1',
    'build': 241,
    'licences': <Object?>[
      <String, Object?>{
        'name': 'cairn_ui',
        'licence': 'MIT',
        'summary': 'The component library every screen is built from.',
      },
      <String, Object?>{
        'name': 'flutter_bloc',
        'licence': 'MIT',
        'summary': 'State management with cubits.',
      },
      <String, Object?>{
        'name': 'get_it',
        'licence': 'MIT',
        'summary': 'Dependency injection.',
      },
      <String, Object?>{
        'name': 'equatable',
        'licence': 'MIT',
        'summary': 'Value equality for models and states.',
      },
      <String, Object?>{
        'name': 'Flutter',
        'licence': 'BSD-3-Clause',
        'summary': 'The framework.',
      },
    ],
  };

  static Map<String, Object?> _session(
    String id,
    String device,
    String location,
    DateTime lastActive, {
    bool current = false,
  }) => <String, Object?>{
    'id': id,
    'device': device,
    'location': location,
    'lastActive': lastActive.toUtc().toIso8601String(),
    'current': current,
  };

  Future<void> _wait() => latency == Duration.zero
      ? Future<void>.value()
      : Future<void>.delayed(latency);

  static const Map<String, Object?> _ok = <String, Object?>{'ok': true};

  @override
  Future<Map<String, Object?>> loadSettings() async {
    await _wait();
    return <String, Object?>{..._settings};
  }

  @override
  Future<void> saveSettings(Map<String, Object?> json) async {
    await _wait();
    _settings = <String, Object?>{...json};
  }

  @override
  Future<Map<String, Object?>> loadAppInfo() async {
    await _wait();
    return _appInfo;
  }

  @override
  Future<Map<String, Object?>> loadProfile() async {
    await _wait();
    return <String, Object?>{..._profile};
  }

  @override
  Future<Map<String, Object?>> saveProfile(Map<String, Object?> json) async {
    await _wait();
    _profile = <String, Object?>{...json};
    return <String, Object?>{..._profile};
  }

  @override
  Future<Map<String, Object?>> checkUsername(String username) async {
    await _wait();
    return <String, Object?>{
      'available': !reservedUsernames.contains(username.toLowerCase()),
    };
  }

  @override
  Future<Map<String, Object?>> loadSessions() async {
    await _wait();
    return <String, Object?>{
      'sessions': <Object?>[..._sessions],
    };
  }

  @override
  Future<Map<String, Object?>> revokeSession(String sessionId) async {
    await _wait();
    final int before = _sessions.length;
    _sessions.removeWhere(
      (Map<String, Object?> s) => s['id'] == sessionId && s['current'] != true,
    );
    return _sessions.length == before
        ? <String, Object?>{
            'ok': false,
            'error': 'That session no longer exists.',
          }
        : _ok;
  }

  @override
  Future<Map<String, Object?>> revokeOtherSessions() async {
    await _wait();
    _sessions.removeWhere((Map<String, Object?> s) => s['current'] != true);
    return _ok;
  }

  @override
  Future<Map<String, Object?>> changePassword({
    required String current,
    required String next,
  }) async {
    await _wait();
    if (current == demoWrongPassword) {
      return <String, Object?>{
        'ok': false,
        'error': 'Your current password is not right.',
      };
    }
    return _ok;
  }

  @override
  Future<Map<String, Object?>> beginTwoFactor() async {
    await _wait();
    _twoFactorPending = true;
    return <String, Object?>{'secret': 'JBSWY3DPEHPK3PXP'};
  }

  @override
  Future<Map<String, Object?>> verifyTwoFactor(String code) async {
    await _wait();
    if (!_twoFactorPending || code != demoTwoFactorCode) {
      return <String, Object?>{
        'ok': false,
        'error': 'That code is not right. Try the next one.',
      };
    }
    _twoFactorPending = false;
    return _ok;
  }

  @override
  Future<Map<String, Object?>> disableTwoFactor() async {
    await _wait();
    return _ok;
  }

  @override
  Future<Map<String, Object?>> requestExport() async {
    await _wait();
    _exports++;
    return <String, Object?>{
      'id': 'exp_$_exports',
      'requestedAt': _now().toUtc().toIso8601String(),
    };
  }

  @override
  Future<Map<String, Object?>> loadBlockedUsers() async {
    await _wait();
    return <String, Object?>{
      'blocked': <Object?>[..._blocked],
    };
  }

  @override
  Future<Map<String, Object?>> unblockUser(String userId) async {
    await _wait();
    _blocked.removeWhere((Map<String, Object?> u) => u['id'] == userId);
    return _ok;
  }

  @override
  Future<Map<String, Object?>> deactivateAccount() async {
    await _wait();
    return _ok;
  }

  @override
  Future<Map<String, Object?>> deleteAccount() async {
    await _wait();
    return _ok;
  }

  @override
  Future<Map<String, Object?>> loadStorage() async {
    await _wait();
    return <String, Object?>{
      'capacity': 5368709120,
      'categories': <Object?>[
        <String, Object?>{
          'id': 'media',
          'label': 'Photos and media',
          'bytes': 1288490189,
        },
        <String, Object?>{
          'id': 'documents',
          'label': 'Documents',
          'bytes': 440401920,
        },
        <String, Object?>{
          'id': 'downloads',
          'label': 'Downloads',
          'bytes': 671088640,
        },
        <String, Object?>{'id': 'cache', 'label': 'Cache', 'bytes': _cache},
      ],
    };
  }

  @override
  Future<Map<String, Object?>> clearCache() async {
    await _wait();
    final int reclaimed = _cache;
    _cache = 0;
    return <String, Object?>{'ok': true, 'reclaimed': reclaimed};
  }

  @override
  Future<Map<String, Object?>> submitSupportRequest(
    Map<String, Object?> json,
  ) async {
    await _wait();
    return <String, Object?>{'ok': true, 'message': 'SUP-4821'};
  }
}
