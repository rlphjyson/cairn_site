import 'package:cairn_template_chat/common/utils/dates.dart';
import 'package:cairn_template_chat/common/utils/emoji.dart';
import 'package:cairn_template_chat/common/utils/links.dart';
import 'package:cairn_template_chat/data/chat/remote/chat_seed.dart';
import 'package:cairn_template_chat/data/chat/remote/demo_bot.dart';
import 'package:cairn_template_chat/domain/contacts/mappers/contact_mapper.dart';
import 'package:cairn_template_chat/domain/contacts/models/contact.dart';
import 'package:cairn_template_chat/domain/contacts/models/presence.dart';
import 'package:cairn_template_chat/domain/contacts/repositories/contact_repository.dart';
import 'package:cairn_template_chat/domain/contacts/use_cases/get_contacts.dart';
import 'package:cairn_template_chat/domain/contacts/use_cases/group_contacts.dart';
import 'package:cairn_template_chat/domain/contacts/use_cases/search_contacts.dart';
import 'package:cairn_template_chat/domain/contacts/use_cases/update_profile.dart';
import 'package:cairn_template_chat/domain/conversations/mappers/conversation_mapper.dart';
import 'package:cairn_template_chat/domain/conversations/models/conversation.dart';
import 'package:cairn_template_chat/domain/conversations/models/conversation_inbox.dart';
import 'package:cairn_template_chat/domain/conversations/repositories/conversation_repository.dart';
import 'package:cairn_template_chat/domain/conversations/use_cases/create_group.dart';
import 'package:cairn_template_chat/domain/conversations/use_cases/format_relative_time.dart';
import 'package:cairn_template_chat/domain/conversations/use_cases/get_conversations.dart';
import 'package:cairn_template_chat/domain/conversations/use_cases/search_conversations.dart';
import 'package:cairn_template_chat/domain/messages/mappers/chat_event_mapper.dart';
import 'package:cairn_template_chat/domain/messages/mappers/message_mapper.dart';
import 'package:cairn_template_chat/domain/messages/models/attachment.dart';
import 'package:cairn_template_chat/domain/messages/models/chat_event.dart';
import 'package:cairn_template_chat/domain/messages/models/message.dart';
import 'package:cairn_template_chat/domain/messages/models/message_page.dart';
import 'package:cairn_template_chat/domain/messages/models/message_status.dart';
import 'package:cairn_template_chat/domain/messages/models/outgoing_message.dart';
import 'package:cairn_template_chat/domain/messages/models/reaction.dart';
import 'package:cairn_template_chat/domain/messages/models/reply_preview.dart';
import 'package:cairn_template_chat/domain/messages/models/thread_item.dart';
import 'package:cairn_template_chat/domain/messages/repositories/message_repository.dart';
import 'package:cairn_template_chat/domain/messages/use_cases/delete_message.dart';
import 'package:cairn_template_chat/domain/messages/use_cases/get_messages.dart';
import 'package:cairn_template_chat/domain/messages/use_cases/group_messages.dart';
import 'package:cairn_template_chat/domain/messages/use_cases/mark_read.dart';
import 'package:cairn_template_chat/domain/messages/use_cases/react_to_message.dart';
import 'package:cairn_template_chat/domain/messages/use_cases/send_message.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime now = DateTime(2026, 10, 9, 12);

Message msg(
  String id,
  String sender,
  DateTime at, {
  String text = 'hi',
  MessageStatus status = MessageStatus.sent,
}) => Message(
  id: id,
  conversationId: 'c',
  senderId: sender,
  sentAt: at,
  text: text,
  status: status,
);

Conversation conv(
  String id, {
  String title = 'T',
  int minutesAgo = 0,
  bool pinned = false,
  bool archived = false,
  bool muted = false,
  int unread = 0,
  bool markedUnread = false,
  String? last,
}) => Conversation(
  id: id,
  kind: ConversationKind.direct,
  title: title,
  memberIds: const <String>['me', 'x'],
  updatedAt: now.subtract(Duration(minutes: minutesAgo)),
  pinned: pinned,
  archived: archived,
  muted: muted,
  unread: unread,
  markedUnread: markedUnread,
  lastMessage: last == null
      ? null
      : msg(
          'm_$id',
          'x',
          now.subtract(Duration(minutes: minutesAgo)),
          text: last,
        ),
);

/// A message repository over a fixed list, to test paging without a backend.
class _ListMessages implements MessageRepository {
  _ListMessages(this.all);

  final List<Message> all;
  final List<String> deleted = <String>[];
  final List<OutgoingMessage> sent = <OutgoingMessage>[];
  final List<String> read = <String>[];

  @override
  Future<MessagePage> getMessages(
    String conversationId, {
    String? beforeId,
    int limit = 30,
  }) async {
    final int end = beforeId == null
        ? all.length
        : all.indexWhere((Message m) => m.id == beforeId);
    final int start = (end - limit).clamp(0, end);
    // Deliberately newest first and with a duplicate, as a sloppy backend might.
    final List<Message> page = all.sublist(start, end).reversed.toList();
    if (page.isNotEmpty) page.add(page.first);
    return MessagePage(messages: page, hasMore: start > 0);
  }

  @override
  Future<Message> sendMessage(OutgoingMessage message) async {
    sent.add(message);
    return Message(
      id: 'srv-${sent.length}',
      conversationId: message.conversationId,
      senderId: 'me',
      sentAt: now,
      text: message.text,
      replyTo: message.replyTo,
      attachment: message.attachment,
    );
  }

  @override
  Future<void> markRead(String conversationId) async =>
      read.add(conversationId);

  @override
  Future<Message> toggleReaction(
    String conversationId,
    String messageId,
    String emoji,
  ) async => all.firstWhere((Message m) => m.id == messageId);

  @override
  Future<void> deleteForMe(String conversationId, String messageId) async =>
      deleted.add(messageId);

  @override
  Future<List<Message>> getMedia(String conversationId) async => <Message>[];

  @override
  Stream<ChatEvent> watchConversation(String conversationId) =>
      const Stream<ChatEvent>.empty();
}

class _Contacts implements ContactRepository {
  _Contacts(this.all);

  final List<Contact> all;
  String? lastName;
  String? lastAbout;
  Presence? lastPresence;

  @override
  Future<List<Contact>> getContacts() async => all;

  @override
  Future<Contact> getCurrentUser() async => const Contact(id: 'me', name: 'Me');

  @override
  Future<Contact> updateProfile({
    String? name,
    String? about,
    Presence? presence,
  }) async {
    lastName = name;
    lastAbout = about;
    lastPresence = presence;
    return const Contact(id: 'me', name: 'Me');
  }

  @override
  Future<void> block(String contactId) async {}

  @override
  Stream<Contact> watchPresence() => const Stream<Contact>.empty();
}

class _ConversationsOf implements ConversationRepository {
  _ConversationsOf(this.all);

  final List<Conversation> all;
  String? createdName;
  List<String>? createdMembers;

  @override
  Future<List<Conversation>> getConversations() async => all;

  @override
  Future<Conversation?> getConversation(String id) async => null;

  @override
  Future<Conversation> openDirect(String contactId) =>
      throw UnimplementedError();

  @override
  Future<Conversation> createGroup(String name, List<String> memberIds) async {
    createdName = name;
    createdMembers = memberIds;
    return Conversation(
      id: 'g',
      kind: ConversationKind.group,
      title: name,
      memberIds: <String>['me', ...memberIds],
      updatedAt: now,
    );
  }

  @override
  Future<Conversation> update(
    String id, {
    bool? pinned,
    bool? muted,
    bool? archived,
    bool? markedUnread,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> leaveGroup(String id) async {}

  @override
  Stream<String> watchChanges() => const Stream<String>.empty();
}

void main() {
  group('GetConversations', () {
    test('puts pinned first, then newest activity first', () {
      final ConversationInbox inbox = GetConversations.sort(<Conversation>[
        conv('old', minutesAgo: 500),
        conv('new', minutesAgo: 5),
        conv('pinned-old', minutesAgo: 9000, pinned: true),
        conv('pinned-new', minutesAgo: 60, pinned: true),
        conv('mid', minutesAgo: 90),
      ]);
      expect(inbox.active.map((Conversation c) => c.id), <String>[
        'pinned-new',
        'pinned-old',
        'new',
        'mid',
        'old',
      ]);
      expect(inbox.pinned.map((Conversation c) => c.id), <String>[
        'pinned-new',
        'pinned-old',
      ]);
      expect(inbox.others.length, 3);
    });

    test('keeps archived conversations apart, in order', () {
      final ConversationInbox inbox = GetConversations.sort(<Conversation>[
        conv('a', minutesAgo: 30, archived: true),
        conv('b', minutesAgo: 10),
        conv('c', minutesAgo: 5, archived: true),
      ]);
      expect(inbox.active.map((Conversation c) => c.id), <String>['b']);
      expect(inbox.archived.map((Conversation c) => c.id), <String>['c', 'a']);
    });

    test('loads through the repository', () async {
      final ConversationInbox inbox = await GetConversations(
        _ConversationsOf(<Conversation>[conv('a'), conv('b', pinned: true)]),
      )();
      expect(inbox.active.first.id, 'b');
    });

    test('counts unread messages that deserve attention', () {
      final ConversationInbox inbox = GetConversations.sort(<Conversation>[
        conv('a', unread: 3),
        conv('b', unread: 4, muted: true),
        conv('c', markedUnread: true),
        conv('d', unread: 2, archived: true),
        conv('e'),
      ]);
      // 3 from a, 1 for the flagged c; muted and archived stay quiet.
      expect(inbox.unreadTotal, 4);
    });
  });

  group('SearchConversations', () {
    final List<Conversation> all = <Conversation>[
      conv('1', title: 'Mina Park', last: 'See you at the lake'),
      conv('2', title: 'Omar Haddad', last: 'Spoiler: I kept the blue'),
      conv('3', title: 'Weekend hike', last: 'Who has the route notes?'),
    ];

    test('matches the name, ignoring case', () {
      expect(
        const SearchConversations()(all, 'mINA').map((Conversation c) => c.id),
        <String>['1'],
      );
    });

    test('matches the last message', () {
      expect(
        const SearchConversations()(all, 'route').map((Conversation c) => c.id),
        <String>['3'],
      );
    });

    test('a blank query matches everything and keeps the order', () {
      expect(const SearchConversations()(all, '  '), all);
    });

    test('no match gives an empty list', () {
      expect(const SearchConversations()(all, 'zzz'), isEmpty);
    });
  });

  group('GetMessages', () {
    final List<Message> history = <Message>[
      for (int i = 0; i < 70; i++)
        msg('m$i', 'x', now.subtract(Duration(minutes: 70 - i))),
    ];

    test('returns the newest page oldest first, without duplicates', () async {
      final MessagePage page = await GetMessages(_ListMessages(history))('c');
      expect(page.messages.length, 30);
      expect(page.messages.first.id, 'm40');
      expect(page.messages.last.id, 'm69');
      expect(page.hasMore, isTrue);
    });

    test('pages backwards from a message until the start', () async {
      final GetMessages get = GetMessages(_ListMessages(history));
      final MessagePage second = await get('c', beforeId: 'm40');
      expect(second.messages.first.id, 'm10');
      expect(second.messages.last.id, 'm39');
      expect(second.hasMore, isTrue);
      final MessagePage third = await get('c', beforeId: 'm10');
      expect(third.messages.length, 10);
      expect(third.messages.first.id, 'm0');
      expect(third.hasMore, isFalse);
    });
  });

  group('SendMessage', () {
    test('trims the text and returns the stored message', () async {
      final _ListMessages repo = _ListMessages(<Message>[]);
      final Message sent = await SendMessage(repo)('c', text: '  hello  ');
      expect(repo.sent.single.text, 'hello');
      expect(sent.id, 'srv-1');
    });

    test('refuses an empty message', () async {
      final SendMessage send = SendMessage(_ListMessages(<Message>[]));
      expect(() => send('c', text: '   '), throwsArgumentError);
    });

    test('allows an attachment without text', () async {
      final _ListMessages repo = _ListMessages(<Message>[]);
      await SendMessage(repo)(
        'c',
        attachment: const Attachment(kind: AttachmentKind.location),
      );
      expect(repo.sent.single.attachment?.kind, AttachmentKind.location);
    });

    test('canSend follows the draft', () {
      expect(SendMessage.canSend(''), isFalse);
      expect(SendMessage.canSend('  \n '), isFalse);
      expect(SendMessage.canSend('x'), isTrue);
      expect(
        SendMessage.canSend(
          '',
          attachment: const Attachment(kind: AttachmentKind.file),
        ),
        isTrue,
      );
    });

    test('carries a reply and tells the host', () async {
      final _ListMessages repo = _ListMessages(<Message>[]);
      final List<Message> told = <Message>[];
      await SendMessage(repo, onSent: told.add)(
        'c',
        text: 'yes',
        replyTo: const ReplyPreview(
          messageId: 'm1',
          senderId: 'x',
          text: 'Dinner?',
        ),
      );
      expect(repo.sent.single.replyTo?.messageId, 'm1');
      expect(told.single.text, 'yes');
    });
  });

  test('MarkRead and DeleteMessage go to the repository', () async {
    final _ListMessages repo = _ListMessages(<Message>[]);
    await MarkRead(repo)('c');
    await DeleteMessage(repo)('c', 'm1');
    expect(repo.read, <String>['c']);
    expect(repo.deleted, <String>['m1']);
  });

  group('GroupMessages', () {
    final DateTime t = DateTime(2026, 10, 9, 9);

    test('puts messages from one sender within five minutes in one run', () {
      final List<ThreadItem> items = const GroupMessages()(<Message>[
        msg('1', 'a', t),
        msg('2', 'a', t.add(const Duration(minutes: 2))),
        msg('3', 'a', t.add(const Duration(minutes: 4))),
      ]);
      final List<ThreadMessage> rows = items
          .whereType<ThreadMessage>()
          .toList();
      expect(rows.map((ThreadMessage r) => r.startsRun), <bool>[
        true,
        false,
        false,
      ]);
      expect(rows.map((ThreadMessage r) => r.endsRun), <bool>[
        false,
        false,
        true,
      ]);
    });

    test(
      'exactly five minutes continues the run, one second more breaks it',
      () {
        final List<ThreadMessage> rows = const GroupMessages()(<Message>[
          msg('1', 'a', t),
          msg('2', 'a', t.add(const Duration(minutes: 5))),
          msg('3', 'a', t.add(const Duration(minutes: 10, seconds: 1))),
        ]).whereType<ThreadMessage>().toList();
        expect(rows[1].startsRun, isFalse);
        expect(rows[2].startsRun, isTrue);
      },
    );

    test('a different sender starts a new run', () {
      final List<ThreadMessage> rows = const GroupMessages()(<Message>[
        msg('1', 'a', t),
        msg('2', 'b', t.add(const Duration(seconds: 30))),
        msg('3', 'a', t.add(const Duration(minutes: 1))),
      ]).whereType<ThreadMessage>().toList();
      expect(rows.every((ThreadMessage r) => r.startsRun && r.endsRun), isTrue);
    });

    test('adds a date separator at the start and whenever the day changes', () {
      final List<ThreadItem> items = const GroupMessages()(<Message>[
        msg('1', 'a', DateTime(2026, 10, 8, 23, 58)),
        msg('2', 'a', DateTime(2026, 10, 9, 0, 1)),
        msg('3', 'a', DateTime(2026, 10, 9, 0, 2)),
      ]);
      expect(items.map((ThreadItem i) => i.runtimeType), <Type>[
        DateSeparator,
        ThreadMessage,
        DateSeparator,
        ThreadMessage,
        ThreadMessage,
      ]);
      // Two minutes apart, but across midnight: not one run.
      final List<ThreadMessage> rows = items
          .whereType<ThreadMessage>()
          .toList();
      expect(rows[0].endsRun, isTrue);
      expect(rows[1].startsRun, isTrue);
      expect(rows[2].startsRun, isFalse);
    });

    test('an empty list gives no rows', () {
      expect(const GroupMessages()(<Message>[]), isEmpty);
    });

    test('keys are stable', () {
      final List<ThreadItem> items = const GroupMessages()(<Message>[
        msg('1', 'a', t),
      ]);
      expect(items.map((ThreadItem i) => i.key), <String>[
        'day-${DateTime(2026, 10, 9).toIso8601String()}',
        'msg-1',
      ]);
    });
  });

  group('FormatRelativeTime', () {
    const FormatRelativeTime format = FormatRelativeTime();

    test('minutes, hours and now', () {
      expect(format(now.subtract(const Duration(seconds: 20)), now), 'now');
      expect(format(now.subtract(const Duration(minutes: 12)), now), '12m');
      expect(format(now.subtract(const Duration(hours: 3)), now), '3h');
    });

    test('yesterday, weekday and date', () {
      expect(format(DateTime(2026, 10, 8, 20), now), 'Yesterday');
      // Wednesday 7 October: within a week, shown by weekday.
      expect(format(DateTime(2026, 10, 7, 9), now), 'Wed');
      expect(format(DateTime(2026, 9, 30, 9), now), '30 Sep');
      expect(format(DateTime(2025, 12, 24, 9), now), '24 Dec 2025');
    });

    test('a message from late yesterday is Yesterday, not 13h', () {
      expect(format(DateTime(2026, 10, 8, 23), now), 'Yesterday');
    });

    test('the future reads as now', () {
      expect(format(now.add(const Duration(minutes: 3)), now), 'now');
    });

    test('last seen', () {
      expect(format.lastSeen(now, now), 'last seen just now');
      expect(
        format.lastSeen(now.subtract(const Duration(minutes: 40)), now),
        'last seen 40m ago',
      );
      expect(
        format.lastSeen(DateTime(2026, 10, 9, 7, 5), now),
        'last seen today at 07:05',
      );
      expect(
        format.lastSeen(DateTime(2026, 10, 8, 18, 30), now),
        'last seen yesterday at 18:30',
      );
      expect(format.lastSeen(DateTime(2026, 10, 5, 9), now), 'last seen Mon');
    });
  });

  group('date labels', () {
    test('Today, Yesterday and weekday with date', () {
      expect(formatDayLabel(DateTime(2026, 10, 9), now), 'Today');
      expect(formatDayLabel(DateTime(2026, 10, 8), now), 'Yesterday');
      expect(formatDayLabel(DateTime(2026, 10, 7), now), 'Wed 7 Oct');
      expect(formatDayLabel(DateTime(2025, 10, 7), now), 'Tue 7 Oct 2025');
    });

    test('calendar days ignore the time of day', () {
      expect(
        calendarDaysBetween(
          DateTime(2026, 10, 8, 23, 59),
          DateTime(2026, 10, 9, 0, 1),
        ),
        1,
      );
      expect(formatClock(DateTime(2026, 1, 1, 7, 5)), '07:05');
    });
  });

  group('CreateGroup', () {
    test('validates the name and the members', () {
      expect(
        CreateGroup.validate('', <String>['a', 'b']),
        GroupProblem.nameRequired,
      );
      expect(
        CreateGroup.validate('   ', <String>['a', 'b']),
        GroupProblem.nameRequired,
      );
      expect(
        CreateGroup.validate('x' * 41, <String>['a', 'b']),
        GroupProblem.nameTooLong,
      );
      expect(
        CreateGroup.validate('Team', <String>['a']),
        GroupProblem.tooFewMembers,
      );
      expect(
        CreateGroup.validate('Team', <String>['a', 'a']),
        GroupProblem.tooFewMembers,
      );
      expect(CreateGroup.validate('Team', <String>['a', 'b']), isNull);
    });

    test('creates the group with a trimmed name and unique members', () async {
      final _ConversationsOf repo = _ConversationsOf(<Conversation>[]);
      final Conversation c = await CreateGroup(repo)('  Team  ', <String>[
        'a',
        'b',
        'a',
      ]);
      expect(c.isGroup, isTrue);
      expect(repo.createdName, 'Team');
      expect(repo.createdMembers, <String>['a', 'b']);
    });

    test('throws for an invalid group', () {
      expect(
        () => CreateGroup(_ConversationsOf(<Conversation>[]))('', <String>[
          'a',
          'b',
        ]),
        throwsA(isA<InvalidGroupException>()),
      );
    });
  });

  group('ReactToMessage', () {
    final Message base = msg('1', 'x', now);

    test('adds your emoji', () {
      final Message m = ReactToMessage.apply(base, '\u{1F44D}', 'me');
      expect(m.reactions.single.emoji, '\u{1F44D}');
      expect(m.reactions.single.userIds, <String>['me']);
    });

    test('a second tap removes it, and an unused emoji disappears', () {
      final Message once = ReactToMessage.apply(base, '\u{1F44D}', 'me');
      final Message twice = ReactToMessage.apply(once, '\u{1F44D}', 'me');
      expect(twice.reactions, isEmpty);
    });

    test('joins other people on the same emoji', () {
      final Message theirs = base.copyWith(
        reactions: const <Reaction>[
          Reaction('\u{2764}\u{FE0F}', <String>['x']),
        ],
      );
      final Message both = ReactToMessage.apply(
        theirs,
        '\u{2764}\u{FE0F}',
        'me',
      );
      expect(both.reactions.single.count, 2);
      expect(both.reactions.single.includes('me'), isTrue);
      final Message back = ReactToMessage.apply(both, '\u{2764}\u{FE0F}', 'me');
      expect(back.reactions.single.userIds, <String>['x']);
    });

    test('different emoji sit side by side', () {
      Message m = ReactToMessage.apply(base, '\u{1F44D}', 'me');
      m = ReactToMessage.apply(m, '\u{1F602}', 'me');
      expect(m.reactions.map((Reaction r) => r.emoji), <String>[
        '\u{1F44D}',
        '\u{1F602}',
      ]);
    });
  });

  group('contacts', () {
    final List<Contact> people = <Contact>[
      const Contact(id: '1', name: 'Zed Zulu', about: 'Chess'),
      const Contact(id: '2', name: 'amy Adams', about: 'Piano'),
      const Contact(id: '3', name: 'Adam Ant'),
      const Contact(id: '4', name: '1st Place'),
      const Contact(id: 'me', name: 'Me'),
      const Contact(id: '5', name: 'Blocked B', blocked: true),
    ];

    test('GroupContacts: alphabetical sections with # last', () {
      final List<ContactSection> sections = const GroupContacts()(
        people.where((Contact c) => c.id != 'me' && !c.blocked).toList(),
      );
      expect(sections.map((ContactSection s) => s.letter), <String>[
        'A',
        'Z',
        '#',
      ]);
      expect(sections.first.contacts.map((Contact c) => c.name), <String>[
        'Adam Ant',
        'amy Adams',
      ]);
    });

    test('SearchContacts: name or status line', () {
      expect(
        const SearchContacts()(people, 'piano').map((Contact c) => c.id),
        <String>['2'],
      );
      expect(
        const SearchContacts()(people, 'ZED').map((Contact c) => c.id),
        <String>['1'],
      );
      expect(const SearchContacts()(people, ''), people);
    });

    test('initials', () {
      expect(const Contact(id: 'a', name: 'Mina Park').initials, 'MP');
      expect(const Contact(id: 'a', name: 'hana').initials, 'H');
      expect(const Contact(id: 'a', name: 'Jean Luc Picard').initials, 'JP');
      expect(const Contact(id: 'a', name: '  ').initials, '?');
    });

    test('presence reads from JSON, unknown means offline', () {
      expect(Presence.fromWire('dnd'), Presence.doNotDisturb);
      expect(Presence.fromWire('mystery'), Presence.offline);
      expect(Presence.fromWire(null), Presence.offline);
    });
  });

  group('text helpers', () {
    test('emoji-only messages', () {
      expect(isEmojiOnly('\u{1F602}'), isTrue);
      expect(isEmojiOnly('\u{1F64C}\u{1F64C} '), isTrue);
      expect(isEmojiOnly('\u{2764}\u{FE0F}'), isTrue);
      // A family: several code points joined, one emoji.
      expect(
        isEmojiOnly('\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}'),
        isTrue,
      );
      // A flag is two regional indicators, one emoji.
      expect(isEmojiOnly('\u{1F1EB}\u{1F1F7}'), isTrue);
      expect(isEmojiOnly('hi \u{1F602}'), isFalse);
      expect(isEmojiOnly('\u{1F602}\u{1F602}\u{1F602}\u{1F602}'), isFalse);
      expect(isEmojiOnly(''), isFalse);
      expect(isEmojiOnly('ok'), isFalse);
    });

    test('links are split out and trailing punctuation stays outside', () {
      final List<TextPart> parts = splitLinks(
        'Menu: https://example.com/menu. See www.example.org, ok?',
      );
      expect(
        parts.where((TextPart p) => p.isLink).map((TextPart p) => p.text),
        <String>['https://example.com/menu', 'www.example.org'],
      );
      expect(parts.map((TextPart p) => p.text).join(), contains('menu. See'));
      expect(splitLinks('no links here').single.isLink, isFalse);
      expect(splitLinks(''), isEmpty);
    });
  });

  group('mappers', () {
    test('a message survives a round trip through JSON', () {
      final Message m = Message(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'u1',
        sentAt: DateTime(2026, 10, 9, 8, 30),
        text: 'Look',
        status: MessageStatus.read,
        replyTo: const ReplyPreview(
          messageId: 'm0',
          senderId: 'me',
          text: 'Photo?',
        ),
        attachment: const Attachment(
          kind: AttachmentKind.image,
          asset: 'assets/images/photo-lake.jpg',
          aspectRatio: 1.5,
        ),
        reactions: const <Reaction>[
          Reaction('\u{1F44D}', <String>['me', 'u2']),
        ],
      );
      expect(MessageMapper.fromJson(MessageMapper.toJson(m)), m);
    });

    test('a message with only the required fields reads with defaults', () {
      final Message m = MessageMapper.fromJson(<String, Object?>{
        'id': 'm',
        'conversationId': 'c',
        'senderId': 'u',
        'sentAt': '2026-10-09T08:30:00.000',
      });
      expect(m.text, '');
      expect(m.status, MessageStatus.sent);
      expect(m.reactions, isEmpty);
      expect(m.attachment, isNull);
    });

    test('previews summarise attachments', () {
      Message carrying(Attachment a, [String text = '']) => Message(
        id: 'm',
        conversationId: 'c',
        senderId: 'u',
        sentAt: now,
        text: text,
        attachment: a,
      );
      expect(
        carrying(const Attachment(kind: AttachmentKind.image)).preview,
        'Photo',
      );
      expect(
        carrying(
          const Attachment(kind: AttachmentKind.file, name: 'a.pdf'),
        ).preview,
        'a.pdf',
      );
      expect(
        carrying(const Attachment(kind: AttachmentKind.location)).preview,
        'Location',
      );
      expect(
        carrying(
          const Attachment(kind: AttachmentKind.image),
          'Caption',
        ).preview,
        'Caption',
      );
      expect(msg('1', 'u', now, text: 'a\n\n b').preview, 'a b');
    });

    test('a page of history reads with its cursor flag', () {
      final MessagePage page = MessageMapper.pageFromJson(<String, Object?>{
        'messages': <Object?>[
          <String, Object?>{
            'id': 'm',
            'conversationId': 'c',
            'senderId': 'u',
            'sentAt': '2026-10-09T08:30:00.000',
          },
        ],
        'hasMore': true,
      });
      expect(page.messages.single.id, 'm');
      expect(page.hasMore, isTrue);
    });

    test('a contact survives a round trip', () {
      final Contact c = Contact(
        id: 'u',
        name: 'Mina Park',
        about: 'Hiking',
        avatar: 'assets/images/avatar-mina.jpg',
        presence: Presence.away,
        lastSeen: DateTime(2026, 10, 9, 8),
      );
      expect(ContactMapper.fromJson(ContactMapper.toJson(c)), c);
    });

    test('a conversation reads its last message', () {
      final Conversation c = ConversationMapper.fromJson(<String, Object?>{
        'id': 'c',
        'type': 'group',
        'title': 'Hike',
        'memberIds': <Object?>['me', 'a'],
        'updatedAt': '2026-10-09T08:30:00.000',
        'unread': 2,
        'pinned': true,
        'lastMessage': <String, Object?>{
          'id': 'm',
          'conversationId': 'c',
          'senderId': 'a',
          'sentAt': '2026-10-09T08:30:00.000',
          'text': 'Hi',
        },
      });
      expect(c.isGroup, isTrue);
      expect(c.unread, 2);
      expect(c.pinned, isTrue);
      expect(c.lastMessage?.text, 'Hi');
    });

    test('events decode by type and unknown types are ignored', () {
      expect(
        ChatEventMapper.fromJson(<String, Object?>{
          'type': 'typing',
          'conversationId': 'c',
          'userId': 'u',
          'typing': true,
        }),
        const TypingChanged('c', 'u', typing: true),
      );
      expect(
        ChatEventMapper.fromJson(<String, Object?>{
          'type': 'conversation',
          'conversationId': 'c',
        }),
        const ConversationChanged('c'),
      );
      expect(
        ChatEventMapper.fromJson(<String, Object?>{
          'type': 'message.removed',
          'conversationId': 'c',
          'messageId': 'm',
        }),
        const MessageRemoved('c', 'm'),
      );
      expect(
        ChatEventMapper.fromJson(<String, Object?>{'type': 'from-the-future'}),
        isNull,
      );
    });
  });

  group('contact use cases', () {
    test('GetContacts leaves out you and blocked people, sorted', () async {
      final _Contacts repo = _Contacts(<Contact>[
        const Contact(id: 'b', name: 'bea'),
        const Contact(id: 'me', name: 'Me'),
        const Contact(id: 'a', name: 'Al'),
        const Contact(id: 'x', name: 'Xena', blocked: true),
      ]);
      final List<Contact> shown = await GetContacts(repo, 'me')();
      expect(shown.map((Contact c) => c.name), <String>['Al', 'bea']);
    });

    test('UpdateProfile trims, and ignores a blank name', () async {
      final _Contacts repo = _Contacts(<Contact>[]);
      await UpdateProfile(repo)(name: '  New Name ', about: ' hi ');
      expect(repo.lastName, 'New Name');
      expect(repo.lastAbout, 'hi');
      await UpdateProfile(repo)(name: '   ', presence: Presence.away);
      expect(repo.lastName, isNull);
      expect(repo.lastPresence, Presence.away);
    });
  });

  group('demo data and bot', () {
    final ChatSeed seed = ChatSeed.build(now: now, currentUserId: 'me');

    test('has people, groups and more than a hundred messages', () {
      expect(seed.contacts.length, greaterThanOrEqualTo(10));
      expect(
        seed.conversations
            .where((Map<String, Object?> c) => c['type'] == 'group')
            .length,
        2,
      );
      final int total = seed.messages.values.fold<int>(
        0,
        (int sum, List<Map<String, Object?>> l) => sum + l.length,
      );
      expect(total, greaterThan(100));
    });

    test('every conversation member and sender is a known contact', () {
      final Set<String> ids = seed.contacts
          .map((Map<String, Object?> c) => c['id']! as String)
          .toSet();
      for (final Map<String, Object?> c in seed.conversations) {
        for (final Object? id in c['memberIds']! as List<Object?>) {
          expect(ids, contains(id));
        }
      }
      for (final List<Map<String, Object?>> list in seed.messages.values) {
        for (final Map<String, Object?> m in list) {
          expect(ids, contains(m['senderId']));
        }
      }
    });

    test('history is oldest first and ids are unique', () {
      for (final List<Map<String, Object?>> list in seed.messages.values) {
        final List<String> times = list
            .map((Map<String, Object?> m) => m['sentAt']! as String)
            .toList();
        expect(times, orderedEquals(<String>[...times]..sort()));
      }
      final List<String> ids = <String>[
        for (final List<Map<String, Object?>> l in seed.messages.values)
          for (final Map<String, Object?> m in l) m['id']! as String,
      ];
      expect(ids.toSet().length, ids.length);
    });

    test('the demo bot is deterministic and varied', () {
      expect(DemoBot.replyTo('thanks a lot', turn: 0).text, 'Anytime!');
      expect(DemoBot.replyTo('send a photo please', turn: 1).photo, isNotNull);
      expect(DemoBot.replyTo('Hello there', turn: 0).text, contains('Hey'));
      expect(
        DemoBot.replyTo('what time?', turn: 0).text,
        DemoBot.replyTo('what time?', turn: 0).text,
      );
      final Set<String> generic = <String>{
        for (int i = 0; i < 4; i++) DemoBot.replyTo('ok', turn: i).text,
      };
      expect(generic.length, 4);
    });
  });
}
