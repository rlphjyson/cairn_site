/// The demo's people, conversations and history, as decoded JSON.
///
/// Everything is built relative to `now`, so "Today" and "Yesterday" always
/// appear in the thread and the conversation list looks lived in whenever the
/// app is opened. Older history is generated deterministically (no randomness)
/// so tests see the same data every run.
class ChatSeed {
  /// Creates a seed from your own data: contacts (one of them the signed-in
  /// user), conversations and messages by conversation id, all as decoded JSON
  /// in the shapes documented on `ContactMapper`, `ConversationMapper` and
  /// `MessageMapper`.
  ChatSeed({
    required this.contacts,
    this.conversations = const <Map<String, Object?>>[],
    this.messages = const <String, List<Map<String, Object?>>>{},
  });

  /// Builds the seed for a user called [currentUserId].
  factory ChatSeed.build({
    required DateTime now,
    required String currentUserId,
  }) {
    final _SeedBuilder b = _SeedBuilder(now, currentUserId);
    b.build();
    return ChatSeed(
      contacts: b.contacts,
      conversations: b.conversations,
      messages: b.messages,
    );
  }

  /// Everyone, including the signed-in user.
  final List<Map<String, Object?>> contacts;

  /// The conversation entries (without `lastMessage`, `unread` is stored).
  final List<Map<String, Object?>> conversations;

  /// Messages by conversation id, oldest first.
  final Map<String, List<Map<String, Object?>>> messages;
}

const List<String> _directChatter = <String>[
  'Did you get my last message?',
  'Running a few minutes late',
  'Can you send me that link again?',
  'Just got out of the meeting',
  'That was hilarious',
  'I will call you in a bit',
  'Sounds good to me',
  'Let me check my calendar',
  'Thanks for the heads up',
  'Be there in 10',
  'Have you eaten yet?',
  'Okay, I am on it',
  'Send me the address',
  'Long day, honestly',
  'Same time next week?',
  'I saw it, great work',
  'Can we move it to tomorrow?',
  'On my way',
  'Ha! Classic',
  'I need a coffee',
  'What time works for you?',
  'Back at my desk now',
  'Did you see the news?',
  'Let us do it',
  'I will bring the notes',
  'Just finished, finally',
  'Good call',
  'That makes sense',
  'I forgot my charger',
  'Typing this from the train',
];

const List<String> _groupChatter = <String>[
  'Who is driving?',
  'I can pick up snacks',
  'Weather looks fine for Saturday',
  'Anyone have a spare headlamp?',
  'Count me in',
  'Running ten minutes behind',
  'Let us vote: early start or brunch first?',
  'Early start gets my vote',
  'Sending the route in a sec',
  'Remember to charge your phones',
  'I will bring the speaker',
  'Great, see you all there',
  'Hold on, the group list is wrong',
  'Can someone share the playlist?',
  'Done, added everyone',
  'That view was worth it',
  'Does anyone need a lift?',
  'Perfect, thanks all',
];

// Gaps (in minutes) between generated messages: a mix of quick back-and-forth
// and long silences, so runs, date separators and quiet days all occur.
const List<int> _gaps = <int>[
  2,
  3,
  1,
  95,
  4,
  240,
  2,
  380,
  3,
  18,
  610,
  2,
  5,
  1,
  160,
  3,
  2,
  720,
];

class _SeedBuilder {
  _SeedBuilder(this.now, this.me);

  final DateTime now;
  final String me;

  final List<Map<String, Object?>> contacts = <Map<String, Object?>>[];
  final List<Map<String, Object?>> conversations = <Map<String, Object?>>[];
  final Map<String, List<Map<String, Object?>>> messages =
      <String, List<Map<String, Object?>>>{};

  final Map<String, Map<String, Object?>> _byId =
      <String, Map<String, Object?>>{};
  final Map<String, int> _counters = <String, int>{};

  String _ago(int minutes) =>
      now.subtract(Duration(minutes: minutes)).toIso8601String();

  void _contact(
    String id,
    String name,
    String about,
    String presence, {
    String? avatar,
    int? lastSeenMinutesAgo,
  }) {
    contacts.add(<String, Object?>{
      'id': id,
      'name': name,
      'about': about,
      'avatar': avatar,
      'presence': presence,
      'lastSeen': lastSeenMinutesAgo == null ? null : _ago(lastSeenMinutesAgo),
      'blocked': false,
    });
  }

  void _conversation(
    String id,
    String type,
    String title,
    List<String> members, {
    String? peerId,
    bool pinned = false,
    bool muted = false,
    bool archived = false,
    int unread = 0,
    required int createdMinutesAgo,
  }) {
    conversations.add(<String, Object?>{
      'id': id,
      'type': type,
      'title': title,
      'avatar': null,
      'peerId': peerId,
      'memberIds': members,
      'pinned': pinned,
      'muted': muted,
      'archived': archived,
      'markedUnread': false,
      'unread': unread,
      'createdAt': _ago(createdMinutesAgo),
    });
    messages[id] = <Map<String, Object?>>[];
  }

  Map<String, Object?> _msg(
    String conversation,
    String sender,
    String text,
    int minutesAgo, {
    String status = 'read',
    String? replyTo,
    Map<String, Object?>? attachment,
    List<Map<String, Object?>> reactions = const <Map<String, Object?>>[],
    String? idOverride,
  }) {
    final int n = _counters[conversation] = (_counters[conversation] ?? 0) + 1;
    final String id = idOverride ?? '${conversation}_h$n';
    final Map<String, Object?>? quoted = replyTo == null
        ? null
        : _byId[replyTo];
    final Map<String, Object?> message = <String, Object?>{
      'id': id,
      'conversationId': conversation,
      'senderId': sender,
      'text': text,
      'sentAt': _ago(minutesAgo),
      'status': status,
      'replyTo': quoted == null
          ? null
          : <String, Object?>{
              'messageId': quoted['id'],
              'senderId': quoted['senderId'],
              'text': (quoted['text'] as String).isEmpty
                  ? 'Photo'
                  : quoted['text'],
            },
      'attachment': attachment,
      'reactions': reactions,
    };
    messages[conversation]!.add(message);
    _byId[id] = message;
    return message;
  }

  Map<String, Object?> _photo(String name) => <String, Object?>{
    'type': 'image',
    'asset': 'assets/images/photo-$name.jpg',
    'url': null,
    'name': null,
    'size': null,
    'aspectRatio': 4 / 3,
  };

  List<Map<String, Object?>> _react(String emoji, List<String> users) =>
      <Map<String, Object?>>[
        <String, Object?>{'emoji': emoji, 'userIds': users},
      ];

  /// Generated history ending [before] minutes ago, oldest first once sorted.
  void _backlog(
    String conversation,
    int count,
    int before,
    List<String> speakers, {
    required List<String> phrases,
    int salt = 0,
  }) {
    int minutes = before;
    for (int k = 0; k < count; k++) {
      minutes += _gaps[(k + salt) % _gaps.length];
      final String sender = speakers[(k * 5 + salt + k ~/ 3) % speakers.length];
      final String text = phrases[(k * 7 + salt) % phrases.length];
      messages[conversation]!.add(<String, Object?>{
        'id': '${conversation}_b$k',
        'conversationId': conversation,
        'senderId': sender,
        'text': text,
        'sentAt': _ago(minutes),
        'status': 'read',
        'replyTo': null,
        'attachment': null,
        'reactions': <Map<String, Object?>>[],
      });
    }
  }

  void build() {
    _contact(
      me,
      'Alex Rivera',
      'Building things with Cairn',
      'online',
      avatar: 'assets/images/avatar-me.jpg',
    );
    _contact(
      'u_mina',
      'Mina Park',
      'Hiking this weekend',
      'online',
      avatar: 'assets/images/avatar-mina.jpg',
    );
    _contact(
      'u_omar',
      'Omar Haddad',
      'Designing in the dark',
      'away',
      avatar: 'assets/images/avatar-omar.jpg',
    );
    _contact(
      'u_tasha',
      'Tasha Brown',
      'Out of office until Monday',
      'offline',
      avatar: 'assets/images/avatar-tasha.jpg',
      lastSeenMinutesAgo: 180,
    );
    _contact(
      'u_diego',
      'Diego Alvarez',
      'Busy: ship day',
      'dnd',
      avatar: 'assets/images/avatar-diego.jpg',
    );
    _contact(
      'u_lena',
      'Lena Fischer',
      'Coffee first, then code',
      'online',
      avatar: 'assets/images/avatar-lena.jpg',
    );
    _contact(
      'u_theo',
      'Theo Marsh',
      'On a train, somewhere',
      'offline',
      avatar: 'assets/images/avatar-theo.jpg',
      lastSeenMinutesAgo: 1380,
    );
    _contact(
      'u_amara',
      'Amara Okafor',
      'Fourteen books deep',
      'offline',
      avatar: 'assets/images/avatar-amara.jpg',
      lastSeenMinutesAgo: 2900,
    );
    _contact(
      'u_rafa',
      'Rafa Souza',
      'Football and film',
      'away',
      avatar: 'assets/images/avatar-rafa.jpg',
    );
    _contact('u_priya', 'Priya Nair', 'Available', 'online');
    _contact(
      'u_jonas',
      'Jonas Weber',
      'At the gym',
      'offline',
      lastSeenMinutesAgo: 40,
    );
    _contact(
      'u_hana',
      'Hana Kimura',
      'New here',
      'offline',
      lastSeenMinutesAgo: 7300,
    );

    _mina();
    _omar();
    _hike();
    _tasha();
    _diego();
    _lena();
    _crit();
    _theo();
    _amara();
    _rafa();
    _priya();

    for (final List<Map<String, Object?>> list in messages.values) {
      list.sort(
        (Map<String, Object?> a, Map<String, Object?> b) =>
            (a['sentAt']! as String).compareTo(b['sentAt']! as String),
      );
    }
  }

  void _mina() {
    _conversation(
      'c_mina',
      'direct',
      'Mina Park',
      <String>[me, 'u_mina'],
      peerId: 'u_mina',
      pinned: true,
      createdMinutesAgo: 20000,
    );
    _msg('c_mina', 'u_mina', 'Did you see the forecast for Saturday?', 1520);
    _msg('c_mina', me, 'Clear skies all day, I checked', 1516);
    _msg('c_mina', 'u_mina', 'Perfect. I will bring the good thermos', 1500);
    _msg(
      'c_mina',
      me,
      'Legend. I am bringing snacks',
      1498,
      reactions: _react('\u{2764}\u{FE0F}', <String>['u_mina']),
    );
    _msg('c_mina', 'u_mina', 'Morning! Sent you the trail map', 205);
    final Map<String, Object?> lake = _msg(
      'c_mina',
      'u_mina',
      'The lake at the halfway point',
      203,
      attachment: _photo('lake'),
    );
    _msg(
      'c_mina',
      me,
      'Wow. That is the one!',
      190,
      replyTo: lake['id']! as String,
    );
    final Map<String, Object?> dinner = _msg(
      'c_mina',
      'u_mina',
      'Are we still on for dinner at 8 on Friday? Menu: https://example.com/menu.',
      60,
    );
    _msg(
      'c_mina',
      me,
      'Yes! See you there',
      22,
      replyTo: dinner['id']! as String,
    );
    _msg('c_mina', 'u_mina', 'Sounds good, see you there!', 18);
    _backlog('c_mina', 72, 1520, <String>[
      'u_mina',
      me,
    ], phrases: _directChatter);
  }

  void _omar() {
    _conversation(
      'c_omar',
      'direct',
      'Omar Haddad',
      <String>[me, 'u_omar'],
      peerId: 'u_omar',
      pinned: true,
      unread: 2,
      createdMinutesAgo: 15000,
    );
    _msg('c_omar', me, 'Can you send the new onboarding mock?', 330);
    _msg('c_omar', 'u_omar', 'Almost done, fixing the empty states', 320);
    _msg('c_omar', me, 'No rush', 318);
    _msg(
      'c_omar',
      'u_omar',
      'Here it is',
      95,
      attachment: <String, Object?>{
        'type': 'file',
        'asset': null,
        'url': null,
        'name': 'onboarding-v3.pdf',
        'size': 482113,
        'aspectRatio': 1.0,
      },
    );
    _msg('c_omar', 'u_omar', 'Spoiler: I kept the blue', 94);
    _msg('c_omar', 'u_omar', '\u{1F602}', 93);
    _backlog(
      'c_omar',
      34,
      330,
      <String>['u_omar', me],
      phrases: _directChatter,
      salt: 3,
    );
  }

  void _hike() {
    _conversation(
      'c_hike',
      'group',
      'Weekend hike',
      <String>[me, 'u_mina', 'u_diego', 'u_theo'],
      unread: 3,
      createdMinutesAgo: 12000,
    );
    _msg('c_hike', 'u_theo', 'Meet at the trailhead car park at 7:30?', 1800);
    _msg('c_hike', 'u_mina', 'Works for me', 1795);
    _msg('c_hike', me, 'Same. I will drive, space for two more', 1790);
    _msg(
      'c_hike',
      'u_diego',
      '',
      1700,
      attachment: <String, Object?>{
        'type': 'location',
        'asset': null,
        'url': null,
        'name': 'Trailhead car park',
        'size': null,
        'aspectRatio': 1.0,
      },
    );
    _msg('c_hike', 'u_theo', 'Packing list: layers, snacks, headlamp', 130);
    _msg(
      'c_hike',
      me,
      'Adding a first aid kit',
      120,
      reactions: _react('\u{1F44D}', <String>['u_theo', 'u_mina']),
    );
    _msg(
      'c_hike',
      'u_diego',
      'Golden hour, last Saturday',
      40,
      attachment: _photo('sunset'),
    );
    _msg('c_hike', 'u_theo', '\u{1F64C}\u{1F64C}', 38);
    _msg(
      'c_hike',
      'u_mina',
      'Who has the route notes? https://example.com/route',
      12,
    );
    _backlog('c_hike', 56, 1800, <String>[
      'u_mina',
      'u_diego',
      me,
      'u_theo',
    ], phrases: _groupChatter);
  }

  void _tasha() {
    _conversation(
      'c_tasha',
      'direct',
      'Tasha Brown',
      <String>[me, 'u_tasha'],
      peerId: 'u_tasha',
      unread: 1,
      createdMinutesAgo: 9000,
    );
    _msg('c_tasha', me, 'Thanks for covering my shift', 2900);
    _msg('c_tasha', 'u_tasha', 'Anytime!', 2880);
    _msg(
      'c_tasha',
      'u_tasha',
      'Quick question about the invoice template. Have you got a minute tomorrow?',
      150,
    );
  }

  void _diego() {
    _conversation(
      'c_diego',
      'direct',
      'Diego Alvarez',
      <String>[me, 'u_diego'],
      peerId: 'u_diego',
      muted: true,
      unread: 4,
      createdMinutesAgo: 9000,
    );
    _msg('c_diego', me, 'Shipping the release tonight?', 600);
    _msg('c_diego', 'u_diego', 'If CI behaves', 590);
    _msg('c_diego', 'u_diego', 'CI did not behave', 400);
    _msg('c_diego', 'u_diego', 'Rerunning', 399);
    _msg('c_diego', 'u_diego', 'Green! Merging.', 280);
    _msg('c_diego', 'u_diego', 'Tag is up', 279);
  }

  void _lena() {
    _conversation(
      'c_lena',
      'direct',
      'Lena Fischer',
      <String>[me, 'u_lena'],
      peerId: 'u_lena',
      createdMinutesAgo: 9000,
    );
    _msg('c_lena', 'u_lena', 'Coffee tomorrow?', 3000);
    _msg('c_lena', me, 'Yes, the place by the river?', 2995);
    _msg('c_lena', 'u_lena', 'Perfect, 10am', 2990);
    _msg('c_lena', me, '\u{1F44D}', 2980);
    final Map<String, Object?> lunch = _msg(
      'c_lena',
      'u_lena',
      'Today\'s lunch, no regrets',
      700,
      attachment: _photo('lunch'),
    );
    _msg(
      'c_lena',
      me,
      'That looks incredible',
      690,
      replyTo: lunch['id']! as String,
    );
    _msg('c_lena', me, 'Recipe please?', 689, status: 'sent');
    _backlog(
      'c_lena',
      22,
      3000,
      <String>['u_lena', me],
      phrases: _directChatter,
      salt: 5,
    );
  }

  void _crit() {
    _conversation('c_crit', 'group', 'Design crit', <String>[
      me,
      'u_omar',
      'u_tasha',
      'u_lena',
      'u_amara',
    ], createdMinutesAgo: 9000);
    _msg('c_crit', 'u_omar', 'Crit moved to Thursday, same room', 4400);
    _msg('c_crit', 'u_lena', 'Bringing printouts', 4390);
    _msg('c_crit', 'u_tasha', 'I will present the settings flow', 4380);
    _msg('c_crit', me, 'I will go second, the chat flow', 4300);
    _msg(
      'c_crit',
      'u_amara',
      'Can I get 10 minutes at the end for the icon audit?',
      4290,
    );
    _msg('c_crit', 'u_omar', 'Sure, add it to the agenda', 4285);
    _msg('c_crit', me, 'Done', 4280);
  }

  void _theo() {
    _conversation(
      'c_theo',
      'direct',
      'Theo Marsh',
      <String>[me, 'u_theo'],
      peerId: 'u_theo',
      createdMinutesAgo: 9000,
    );
    _msg('c_theo', 'u_theo', 'Landed! Train in ten', 1700);
    _msg('c_theo', me, 'Safe travels', 1690);
    final Map<String, Object?> house = _msg(
      'c_theo',
      'u_theo',
      'Found a lighthouse between stations',
      1400,
      attachment: _photo('lighthouse'),
    );
    _msg(
      'c_theo',
      me,
      'Okay, that is a good detour',
      1390,
      replyTo: house['id']! as String,
    );
  }

  void _amara() {
    _conversation(
      'c_amara',
      'direct',
      'Amara Okafor',
      <String>[me, 'u_amara'],
      peerId: 'u_amara',
      archived: true,
      createdMinutesAgo: 12000,
    );
    _msg('c_amara', 'u_amara', 'Sending the reading list now', 9000);
    _msg('c_amara', me, 'Thanks!', 8990);
    _msg('c_amara', 'u_amara', 'Book 3 is the one to start with', 8900);
  }

  void _rafa() {
    _conversation(
      'c_rafa',
      'direct',
      'Rafa Souza',
      <String>[me, 'u_rafa'],
      peerId: 'u_rafa',
      createdMinutesAgo: 9000,
    );
    _msg('c_rafa', 'u_rafa', 'Match on Sunday, are you in?', 5600);
    _msg('c_rafa', me, 'Count me in', 5590);
    _msg('c_rafa', 'u_rafa', 'Great, bring a dark shirt', 5580);
  }

  void _priya() {
    _conversation(
      'c_priya',
      'direct',
      'Priya Nair',
      <String>[me, 'u_priya'],
      peerId: 'u_priya',
      createdMinutesAgo: 9000,
    );
    _msg('c_priya', 'u_priya', 'Welcome to the team!', 7200);
    _msg('c_priya', me, 'Thank you, glad to be here', 7190);
    _msg('c_priya', 'u_priya', 'Ask me anything, anytime', 7185);
  }
}
