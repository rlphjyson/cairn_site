import 'dart:async';

import 'package:cairn_template_chat/cairn_template_chat.dart';
import 'package:cairn_template_chat/core/infrastructure/chat_session.dart';
import 'package:cairn_template_chat/core/infrastructure/di/chat_injection.dart';
import 'package:cairn_template_chat/core/presentation/navigation/chat_navigation_cubit.dart';
import 'package:cairn_template_chat/domain/conversations/models/conversation.dart';
import 'package:cairn_template_chat/domain/conversations/use_cases/create_group.dart';
import 'package:cairn_template_chat/domain/messages/models/outgoing_message.dart';
import 'package:cairn_template_chat/domain/messages/models/thread_item.dart';
import 'package:cairn_template_chat/domain/messages/repositories/message_repository.dart';
import 'package:cairn_template_chat/presentation/contacts/bloc/contacts_cubit.dart';
import 'package:cairn_template_chat/presentation/conversations/bloc/conversations_cubit.dart';
import 'package:cairn_template_chat/presentation/conversations/bloc/conversations_state.dart';
import 'package:cairn_template_chat/presentation/info/bloc/info_cubit.dart';
import 'package:cairn_template_chat/presentation/info/view_models/info_view_model.dart';
import 'package:cairn_template_chat/presentation/new_chat/view_models/new_chat_view_model.dart';
import 'package:cairn_template_chat/presentation/profile/bloc/profile_cubit.dart';
import 'package:cairn_template_chat/presentation/thread/bloc/thread_cubit.dart';
import 'package:cairn_template_chat/presentation/thread/bloc/thread_state.dart';
import 'package:cairn_template_chat/presentation/thread/view_models/thread_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'support/fake_sources.dart';

final DateTime now = DateTime(2026, 10, 9, 12);

/// The template wired through the real container, with no widgets.
class Rig {
  Rig._(this.g, this.source);

  factory Rig({
    Duration latency = Duration.zero,
    InMemoryChatDataSource? inner,
    bool wrap = false,
    void Function(Message message)? onSent,
  }) {
    final InMemoryChatDataSource memory =
        inner ?? demoSource(replyLatency: latency);
    final ChatRemoteDataSource source = wrap ? WrappedSource(memory) : memory;
    final GetIt g = createChatLocator(
      dataSource: source,
      session: ChatSession(userId: 'me', now: () => now),
      ownsDataSource: true,
      onMessageSent: onSent,
    );
    addTearDown(g.reset);
    return Rig._(g, source);
  }

  final GetIt g;
  final ChatRemoteDataSource source;

  WrappedSource get wrapped => source as WrappedSource;

  ConversationsCubit get conversations => g<ConversationsCubit>();
  ContactsCubit get contacts => g<ContactsCubit>();
  ProfileCubit get profile => g<ProfileCubit>();
  ChatNavigationCubit get nav => g<ChatNavigationCubit>();

  /// Opens a thread the way a screen would, and closes it with the test.
  Future<ThreadCubit> thread(String conversationId) async {
    final ThreadViewModel vm = g<ThreadViewModel>();
    addTearDown(vm.dispose);
    await vm.cubit.load(conversationId);
    return vm.cubit;
  }

  Future<void> loadAll() async {
    await conversations.load();
    await contacts.load();
    await profile.load();
  }
}

/// Lets timers and streams run: the bot answers on the next few event-loop
/// turns when its latency is zero.
Future<void> settle() => pumpEventQueue(times: 60);

Conversation conversationOf(Rig rig, String id) =>
    rig.conversations.state.find(id)!;

void main() {
  group('ConversationsCubit', () {
    test('loads the inbox in display order, with the archive apart', () async {
      final Rig rig = Rig();
      expect(rig.conversations.state.status, ConversationsStatus.loading);
      await rig.conversations.load();
      final ConversationsState s = rig.conversations.state;
      expect(s.status, ConversationsStatus.ready);
      expect(s.visiblePinned.map((Conversation c) => c.id), <String>[
        'c_mina',
        'c_omar',
      ]);
      expect(s.visibleOthers.first.id, 'c_hike');
      expect(s.inbox.archived.map((Conversation c) => c.id), <String>[
        'c_amara',
      ]);
      // Jonas and Hana have never been messaged, so they have no entry yet.
      expect(s.find('c_jonas'), isNull);
      // 2 (Omar) + 3 (hike) + 1 (Tasha); Diego is muted, Amara archived.
      expect(s.inbox.unreadTotal, 6);
    });

    test('the preview is the newest message', () async {
      final Rig rig = Rig();
      await rig.conversations.load();
      expect(
        conversationOf(rig, 'c_mina').lastMessage?.text,
        'Sounds good, see you there!',
      );
    });

    test(
      'search filters by name and message, and reports no results',
      () async {
        final Rig rig = Rig();
        await rig.conversations.load();
        rig.conversations.search('hike');
        expect(
          rig.conversations.state.visibleOthers.map((Conversation c) => c.id),
          <String>['c_hike'],
        );
        expect(rig.conversations.state.visiblePinned, isEmpty);
        rig.conversations.search('invoice');
        expect(rig.conversations.state.visibleOthers.single.id, 'c_tasha');
        rig.conversations.search('zzzz');
        expect(rig.conversations.state.noResults, isTrue);
        rig.conversations.search('');
        expect(rig.conversations.state.noResults, isFalse);
        expect(rig.conversations.state.visiblePinned.length, 2);
      },
    );

    test('pin, mute and mark unread', () async {
      final Rig rig = Rig();
      await rig.conversations.load();
      await rig.conversations.setPinned(
        conversationOf(rig, 'c_tasha'),
        pinned: true,
      );
      expect(
        rig.conversations.state.visiblePinned.map((Conversation c) => c.id),
        contains('c_tasha'),
      );
      await rig.conversations.setPinned(
        conversationOf(rig, 'c_tasha'),
        pinned: false,
      );
      expect(conversationOf(rig, 'c_tasha').pinned, isFalse);

      await rig.conversations.setMuted(
        conversationOf(rig, 'c_lena'),
        muted: true,
      );
      expect(conversationOf(rig, 'c_lena').muted, isTrue);

      await rig.conversations.setMarkedUnread(
        conversationOf(rig, 'c_rafa'),
        unread: true,
      );
      expect(conversationOf(rig, 'c_rafa').hasUnread, isTrue);
      expect(rig.conversations.state.inbox.unreadTotal, 7);
      await rig.conversations.setMarkedUnread(
        conversationOf(rig, 'c_rafa'),
        unread: false,
      );
      expect(conversationOf(rig, 'c_rafa').hasUnread, isFalse);
    });

    test('marking an unread chat as read clears its count', () async {
      final Rig rig = Rig();
      await rig.conversations.load();
      expect(conversationOf(rig, 'c_omar').unread, 2);
      await rig.conversations.setMarkedUnread(
        conversationOf(rig, 'c_omar'),
        unread: false,
      );
      expect(conversationOf(rig, 'c_omar').unread, 0);
    });

    test('archive and unarchive, and the archive view', () async {
      final Rig rig = Rig();
      await rig.conversations.load();
      await rig.conversations.setArchived(
        conversationOf(rig, 'c_rafa'),
        archived: true,
      );
      expect(
        rig.conversations.state.visibleOthers.any(
          (Conversation c) => c.id == 'c_rafa',
        ),
        isFalse,
      );
      expect(rig.conversations.state.inbox.archived.length, 2);

      rig.conversations.showArchive(show: true);
      expect(rig.conversations.state.visiblePinned, isEmpty);
      expect(
        rig.conversations.state.visibleOthers.map((Conversation c) => c.id),
        containsAll(<String>['c_rafa', 'c_amara']),
      );

      await rig.conversations.setArchived(
        conversationOf(rig, 'c_rafa'),
        archived: false,
      );
      await rig.conversations.setArchived(
        conversationOf(rig, 'c_amara'),
        archived: false,
      );
      // The archive is empty, so the view returns to the main list by itself.
      expect(rig.conversations.state.showArchived, isFalse);
      expect(rig.conversations.state.inbox.archived, isEmpty);
      expect(conversationOf(rig, 'c_amara').archived, isFalse);
    });

    test('delete removes the conversation and its history', () async {
      final Rig rig = Rig();
      await rig.conversations.load();
      await rig.conversations.delete(conversationOf(rig, 'c_priya'));
      expect(rig.conversations.state.find('c_priya'), isNull);
      final ThreadCubit thread = await rig.thread('c_priya');
      expect(thread.state.messages, isEmpty);
    });

    test('a failing backend shows as failed, and retry recovers', () async {
      final Rig rig = Rig(wrap: true);
      rig.wrapped.conversationsGate = Completer<void>()
        ..completeError(StateError('offline'));
      await rig.conversations.load();
      expect(rig.conversations.state.status, ConversationsStatus.failed);
      rig.wrapped.conversationsGate = null;
      await rig.conversations.retry();
      expect(rig.conversations.state.status, ConversationsStatus.ready);
    });

    test('a reply moves the chat to the top and updates its preview', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      final ThreadCubit thread = await rig.thread('c_tasha');
      await settle();
      expect(
        conversationOf(rig, 'c_tasha').unread,
        0,
        reason: 'opening reads it',
      );

      await thread.send('Sure, tomorrow works');
      await settle();
      final ConversationsState s = rig.conversations.state;
      expect(s.visibleOthers.first.id, 'c_tasha');
      expect(s.visibleOthers.first.lastMessage?.senderId, 'u_tasha');
      // The bot answered while the thread was open and the thread read it.
      expect(thread.state.messages.last.senderId, 'u_tasha');
    });

    test('a reply to a chat nobody has open raises its unread count', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      await rig.g<MessageRepository>().sendMessage(
        const OutgoingMessage(
          conversationId: 'c_rafa',
          text: 'Are you still coming?',
        ),
      );
      await settle();
      expect(conversationOf(rig, 'c_rafa').unread, 1);
      expect(conversationOf(rig, 'c_rafa').lastMessage?.senderId, 'u_rafa');
      expect(rig.conversations.state.visibleOthers.first.id, 'c_rafa');
    });
  });

  group('ThreadCubit', () {
    test('loads the newest page and reads the conversation', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      final ThreadCubit thread = await rig.thread('c_omar');
      await settle();
      expect(thread.state.status, ThreadStatus.ready);
      expect(thread.state.conversation?.title, 'Omar Haddad');
      expect(thread.state.messages.length, 30);
      expect(thread.state.hasMore, isTrue);
      expect(thread.state.messages.last.text, '\u{1F602}');
      expect(conversationOf(rig, 'c_omar').unread, 0);
      expect(rig.conversations.state.inbox.unreadTotal, 4);
    });

    test(
      'pages in older history until the start, in order, without gaps',
      () async {
        final Rig rig = Rig();
        final ThreadCubit thread = await rig.thread('c_mina');
        const int total = 10 + 72;
        int pages = 1;
        while (thread.state.hasMore) {
          await thread.loadOlder();
          pages++;
          expect(pages, lessThan(10));
        }
        expect(thread.state.messages.length, total);
        final List<DateTime> times = thread.state.messages
            .map((Message m) => m.sentAt)
            .toList();
        expect(times, orderedEquals(<DateTime>[...times]..sort()));
        expect(
          thread.state.messages.map((Message m) => m.id).toSet().length,
          total,
        );
        expect(thread.state.loadingOlder, isFalse);
        // Day separators were added for the older days.
        expect(
          thread.state.items.whereType<DateSeparator>().length,
          greaterThan(5),
        );
      },
    );

    test('loadOlder does nothing while loading or at the start', () async {
      final Rig rig = Rig();
      final ThreadCubit thread = await rig.thread('c_tasha');
      expect(thread.state.hasMore, isFalse);
      await thread.loadOlder();
      expect(thread.state.messages.length, 3);
    });

    test('sending shows a message at once and the bot answers', () async {
      final List<Message> told = <Message>[];
      final Rig rig = Rig(onSent: told.add);
      final ThreadCubit thread = await rig.thread('c_mina');
      final List<ThreadState> seen = <ThreadState>[];
      final StreamSubscription<ThreadState> sub = thread.stream.listen(
        seen.add,
      );
      addTearDown(sub.cancel);

      final int before = thread.state.messages.length;
      final Future<void> sending = thread.send('  Hello there  ');
      // Before the backend has answered, the message is already in the thread.
      expect(thread.state.messages.length, before + 1);
      expect(thread.state.messages.last.status, MessageStatus.sending);
      expect(thread.state.messages.last.text, 'Hello there');
      await sending;
      await settle();

      final List<Message> after = thread.state.messages;
      expect(after.length, before + 2);
      final Message mine = after[after.length - 2];
      expect(mine.senderId, 'me');
      expect(mine.text, 'Hello there');
      expect(mine.id.startsWith('local-'), isFalse);
      expect(mine.status, MessageStatus.read);
      expect(after.last.senderId, 'u_mina');
      expect(after.last.text, contains('Hey'));
      expect(thread.state.typingUserIds, isEmpty);
      expect(thread.state.scrollTick, 1);
      // Typing appeared and went away while the bot "wrote".
      expect(
        seen.any((ThreadState s) => s.typingUserIds.contains('u_mina')),
        isTrue,
      );
      expect(told.single.text, 'Hello there');
    });

    test('an empty draft is not sent', () async {
      final Rig rig = Rig();
      final ThreadCubit thread = await rig.thread('c_mina');
      final int before = thread.state.messages.length;
      await thread.send('   ');
      expect(thread.state.messages.length, before);
    });

    test('a reply quotes the message and clears the reply bar', () async {
      final Rig rig = Rig();
      final ThreadCubit thread = await rig.thread('c_mina');
      final Message target = thread.state.messages.last;
      thread.startReply(target);
      expect(thread.state.replyingTo?.id, target.id);
      await thread.send('Answering that');
      await settle();
      expect(thread.state.replyingTo, isNull);
      final Message sent = thread.state.messages.firstWhere(
        (Message m) => m.text == 'Answering that',
      );
      expect(sent.replyTo?.messageId, target.id);
      expect(sent.replyTo?.text, target.preview);
      thread.startReply(target);
      thread.cancelReply();
      expect(thread.state.replyingTo, isNull);
    });

    test('reactions toggle, persist and show to a fresh thread', () async {
      final Rig rig = Rig();
      final ThreadCubit thread = await rig.thread('c_mina');
      final Message target = thread.state.messages.last;
      await thread.react(target, '\u{1F44D}');
      expect(
        thread.state.messages.last.reactions.single.includes('me'),
        isTrue,
      );

      final ThreadCubit again = await rig.thread('c_mina');
      expect(again.state.messages.last.reactions.single.emoji, '\u{1F44D}');

      await again.react(again.state.messages.last, '\u{1F44D}');
      expect(again.state.messages.last.reactions, isEmpty);
    });

    test('delete for me removes it, now and after reopening', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      final ThreadCubit thread = await rig.thread('c_mina');
      final Message last = thread.state.messages.last;
      thread.startReply(last);
      await thread.deleteForMe(last);
      expect(
        thread.state.messages.any((Message m) => m.id == last.id),
        isFalse,
      );
      expect(thread.state.replyingTo, isNull);
      final ThreadCubit again = await rig.thread('c_mina');
      expect(again.state.messages.any((Message m) => m.id == last.id), isFalse);
      await settle();
      expect(conversationOf(rig, 'c_mina').lastMessage?.id, isNot(last.id));
    });

    test('a failed send is marked, not lost', () async {
      final Rig rig = Rig(wrap: true);
      rig.wrapped.failSending = true;
      final ThreadCubit thread = await rig.thread('c_mina');
      await thread.send('Will not arrive');
      expect(thread.state.messages.last.status, MessageStatus.failed);
      expect(thread.state.messages.last.text, 'Will not arrive');
    });

    test('typing shows while the bot writes, with a real delay', () async {
      final Rig rig = Rig(latency: const Duration(milliseconds: 160));
      final ThreadCubit thread = await rig.thread('c_lena');
      final List<List<String>> typing = <List<String>>[];
      final StreamSubscription<ThreadState> sub = thread.stream.listen(
        (ThreadState s) => typing.add(s.typingUserIds),
      );
      addTearDown(sub.cancel);
      await thread.send('Hi Lena');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(typing.any((List<String> t) => t.contains('u_lena')), isTrue);
      expect(thread.state.typingUserIds, isEmpty);
      expect(thread.state.messages.last.senderId, 'u_lena');
    });

    test(
      'a pushed message while scrolled up is counted, and read at the bottom',
      () async {
        final Rig rig = Rig(wrap: true);
        await rig.loadAll();
        final ThreadCubit thread = await rig.thread('c_mina');
        await settle();
        thread.setAtBottom(value: false);
        rig.wrapped.pushIncoming(
          conversationId: 'c_mina',
          senderId: 'u_mina',
          text: 'Pushed from the server',
        );
        await settle();
        expect(thread.state.unseen, 1);
        expect(thread.state.lastIncoming?.text, 'Pushed from the server');
        expect(thread.state.messages.last.text, 'Pushed from the server');

        thread.setAtBottom(value: true);
        expect(thread.state.unseen, 0);
      },
    );

    test('a pushed message at the bottom is not counted', () async {
      final Rig rig = Rig(wrap: true);
      final ThreadCubit thread = await rig.thread('c_mina');
      rig.wrapped.pushIncoming(
        conversationId: 'c_mina',
        senderId: 'u_mina',
        text: 'Hello',
      );
      await settle();
      expect(thread.state.unseen, 0);
      expect(thread.state.messages.last.text, 'Hello');
      // The same message delivered twice is shown once.
      rig.wrapped.pushIncoming(
        conversationId: 'c_mina',
        senderId: 'u_mina',
        text: 'Hello',
      );
      await settle();
      expect(
        thread.state.messages.where((Message m) => m.text == 'Hello').length,
        1,
      );
    });

    test('events for other conversations are ignored', () async {
      final Rig rig = Rig(wrap: true);
      final ThreadCubit thread = await rig.thread('c_mina');
      final int before = thread.state.messages.length;
      rig.wrapped.pushIncoming(
        conversationId: 'c_omar',
        senderId: 'u_omar',
        text: 'Not for Mina',
      );
      await settle();
      expect(thread.state.messages.length, before);
    });

    test('removals and updates pushed by the server apply', () async {
      final Rig rig = Rig(wrap: true);
      final ThreadCubit thread = await rig.thread('c_mina');
      final Message last = thread.state.messages.last;
      rig.wrapped.push(<String, Object?>{
        'type': 'message.removed',
        'conversationId': 'c_mina',
        'messageId': last.id,
      });
      await settle();
      expect(
        thread.state.messages.any((Message m) => m.id == last.id),
        isFalse,
      );
    });

    test('closing the thread stops listening', () async {
      final Rig rig = Rig(wrap: true);
      final ThreadViewModel vm = rig.g<ThreadViewModel>();
      await vm.cubit.load('c_mina');
      vm.dispose();
      await settle();
      expect(vm.cubit.isClosed, isTrue);
      rig.wrapped.pushIncoming(
        conversationId: 'c_mina',
        senderId: 'u_mina',
        text: 'Late',
      );
      await settle();
    });
  });

  group('NewChatCubit', () {
    test('lists contacts alphabetically and searches', () async {
      final Rig rig = Rig();
      final NewChatViewModel vm = rig.g<NewChatViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load();
      expect(
        vm.cubit.state.sections.map((ContactSection s) => s.letter),
        <String>['A', 'D', 'H', 'J', 'L', 'M', 'O', 'P', 'R', 'T'],
      );
      vm.cubit.search('gym');
      expect(
        vm.cubit.state.sections.single.contacts.single.name,
        'Jonas Weber',
      );
    });

    test('creating a group needs a name and two people', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      final NewChatViewModel vm = rig.g<NewChatViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load(group: true);
      expect(vm.cubit.state.group, isTrue);

      expect(await vm.cubit.createGroup(), isNull);
      expect(vm.cubit.state.problem, GroupProblem.nameRequired);

      vm.cubit.setGroupName('Book club');
      expect(vm.cubit.state.problem, isNull, reason: 'editing clears it');
      expect(await vm.cubit.createGroup(), isNull);
      expect(vm.cubit.state.problem, GroupProblem.tooFewMembers);

      final List<Contact> all = vm.cubit.state.contacts;
      vm.cubit.toggle(all[0]);
      vm.cubit.toggle(all[1]);
      vm.cubit.toggle(all[1]);
      expect(vm.cubit.state.selected.length, 1);
      vm.cubit.toggle(all[2]);
      expect(vm.cubit.state.selectedContacts.length, 2);

      final String? id = await vm.cubit.createGroup();
      expect(id, isNotNull);
      await settle();
      final Conversation group = conversationOf(rig, id!);
      expect(group.title, 'Book club');
      expect(group.isGroup, isTrue);
      expect(group.memberIds, contains('me'));
      expect(group.memberIds.length, 3);
    });

    test('switching mode forgets the selection', () async {
      final Rig rig = Rig();
      final NewChatViewModel vm = rig.g<NewChatViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load();
      vm.cubit.setGroupMode(group: true);
      vm.cubit.toggle(vm.cubit.state.contacts.first);
      vm.cubit.setGroupName('x');
      vm.cubit.setGroupMode(group: false);
      expect(vm.cubit.state.selected, isEmpty);
      expect(vm.cubit.state.groupName, isEmpty);
    });

    test(
      'a new one-to-one chat appears in the list once something is said',
      () async {
        final Rig rig = Rig();
        await rig.loadAll();
        final NewChatViewModel vm = rig.g<NewChatViewModel>();
        addTearDown(vm.dispose);
        await vm.cubit.load();
        final Contact hana = vm.cubit.state.contacts.firstWhere(
          (Contact c) => c.name == 'Hana Kimura',
        );
        final String? id = await vm.cubit.startDirect(hana);
        expect(id, isNotNull);
        await rig.conversations.load();
        expect(rig.conversations.state.find(id!), isNull);

        final ThreadCubit thread = await rig.thread(id);
        expect(thread.state.messages, isEmpty);
        await thread.send('Welcome, Hana');
        await settle();
        expect(conversationOf(rig, id).title, 'Hana Kimura');
        // Opening the same contact again finds the same conversation.
        expect(await vm.cubit.startDirect(hana), id);
      },
    );
  });

  group('InfoCubit', () {
    test('describes a group: members, media and mute', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      final InfoViewModel vm = rig.g<InfoViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load('c_hike');
      final InfoState s = vm.cubit.state;
      expect(s.conversation?.isGroup, isTrue);
      expect(s.me?.name, 'Alex Rivera');
      expect(s.members.map((Contact c) => c.name), <String>[
        'Mina Park',
        'Diego Alvarez',
        'Theo Marsh',
      ]);
      expect(s.media.length, 1);

      await vm.cubit.setMuted(muted: true);
      expect(vm.cubit.state.conversation?.muted, isTrue);
      await settle();
      expect(conversationOf(rig, 'c_hike').muted, isTrue);
    });

    test('describes a person', () async {
      final Rig rig = Rig();
      final InfoViewModel vm = rig.g<InfoViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load('c_mina');
      expect(vm.cubit.state.peer?.name, 'Mina Park');
      expect(vm.cubit.state.members, isEmpty);
      expect(vm.cubit.state.media.length, 1);
    });

    test('leaving a group removes it from the list', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      final InfoViewModel vm = rig.g<InfoViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load('c_crit');
      await vm.cubit.leaveGroup();
      await settle();
      expect(rig.conversations.state.find('c_crit'), isNull);
    });

    test('blocking a person removes them and the conversation', () async {
      final Rig rig = Rig();
      await rig.loadAll();
      expect(rig.contacts.state.byId('u_tasha'), isNotNull);
      final InfoViewModel vm = rig.g<InfoViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load('c_tasha');
      await vm.cubit.blockPeer();
      await rig.contacts.load();
      await settle();
      expect(rig.contacts.state.byId('u_tasha'), isNull);
      expect(rig.conversations.state.find('c_tasha'), isNull);
    });

    test('a missing conversation loads as empty', () async {
      final Rig rig = Rig();
      final InfoViewModel vm = rig.g<InfoViewModel>();
      addTearDown(vm.dispose);
      await vm.cubit.load('nope');
      expect(vm.cubit.state.loaded, isTrue);
      expect(vm.cubit.state.conversation, isNull);
    });
  });

  group('ContactsCubit and ProfileCubit', () {
    test('contacts leave out you, in alphabetical sections', () async {
      final Rig rig = Rig();
      await rig.contacts.load();
      expect(rig.contacts.state.contacts.length, 11);
      expect(rig.contacts.state.byId('me'), isNull);
      rig.contacts.search('books');
      expect(
        rig.contacts.state.sections.single.contacts.single.name,
        'Amara Okafor',
      );
    });

    test(
      'presence follows the backend: replying brings a contact online',
      () async {
        final Rig rig = Rig();
        await rig.loadAll();
        expect(rig.contacts.state.byId('u_tasha')?.presence, Presence.offline);
        final ThreadCubit thread = await rig.thread('c_tasha');
        await thread.send('Hello');
        await settle();
        expect(rig.contacts.state.byId('u_tasha')?.presence, Presence.online);
      },
    );

    test('opening a chat from a contact returns its conversation id', () async {
      final Rig rig = Rig();
      await rig.contacts.load();
      final String? id = await rig.contacts.openChat(
        rig.contacts.state.byId('u_mina')!,
      );
      expect(id, 'c_mina');
    });

    test('the profile edits name, status and availability', () async {
      final Rig rig = Rig();
      await rig.profile.load();
      expect(rig.profile.state.me?.name, 'Alex Rivera');
      await rig.profile.saveName('Alex R.');
      await rig.profile.saveAbout('On the move');
      await rig.profile.setPresence(Presence.doNotDisturb);
      expect(rig.profile.state.me?.name, 'Alex R.');
      expect(rig.profile.state.me?.about, 'On the move');
      expect(rig.profile.state.me?.presence, Presence.doNotDisturb);
      await rig.profile.saveName('   ');
      expect(rig.profile.state.me?.name, 'Alex R.', reason: 'blank is ignored');
    });

    test('settings switches are remembered for the session', () async {
      final Rig rig = Rig();
      rig.profile.setNotifications(value: false);
      rig.profile.setPreviews(value: false);
      rig.profile.setReadReceipts(value: false);
      rig.profile.setEnterToSend(value: true);
      final ProfileState s = rig.profile.state;
      expect(
        <bool>[s.notifications, s.previews, s.readReceipts, s.enterToSend],
        <bool>[false, false, false, true],
      );
    });
  });

  group('ChatNavigationCubit', () {
    test('tabs, threads, info and new chat form a stack', () {
      final ChatNavigationCubit nav = ChatNavigationCubit();
      addTearDown(nav.close);
      expect(nav.state.tab, ChatTab.chats);
      expect(nav.state.top, isNull);

      nav.openThread('a');
      expect(nav.state.top, const ThreadRoute('a'));
      expect(nav.state.openThreadId, 'a');

      nav.openInfo('a');
      expect(nav.state.top, const InfoRoute('a'));
      expect(nav.state.openThreadId, 'a');
      nav.back();
      expect(nav.state.top, const ThreadRoute('a'));
      nav.back();
      expect(nav.state.top, isNull);
      nav.back();
      expect(nav.state.stack, isEmpty);

      nav.openNewChat(group: true);
      expect(nav.state.top, const NewChatRoute(group: true));
      nav.openThread('b');
      expect(nav.state.stack, const <ChatRoute>[ThreadRoute('b')]);

      nav.selectTab(ChatTab.profile);
      expect(nav.state.tab, ChatTab.profile);
      expect(nav.state.top, const ThreadRoute('b'), reason: 'stack survives');
      nav.clear();
      expect(nav.state.stack, isEmpty);
    });

    test('closing a conversation closes its screens only', () {
      final ChatNavigationCubit nav = ChatNavigationCubit();
      addTearDown(nav.close);
      nav.openThread('a');
      nav.openInfo('a');
      nav.closeConversation('b');
      expect(nav.state.stack.length, 2);
      nav.closeConversation('a');
      expect(nav.state.stack, isEmpty);
    });
  });

  group('plugging in a backend', () {
    test('the host sees every accepted message', () async {
      final List<String> texts = <String>[];
      final Rig rig = Rig(onSent: (Message m) => texts.add(m.text));
      final ThreadCubit thread = await rig.thread('c_mina');
      await thread.send('One');
      await thread.send('Two');
      expect(texts, <String>['One', 'Two']);
    });

    test(
      'a data source the host passes in is not disposed by the container',
      () async {
        final WrappedSource source = WrappedSource(demoSource());
        final GetIt g = createChatLocator(
          dataSource: source,
          session: ChatSession(userId: 'me', now: () => now),
        );
        await g.reset();
        // Still alive: the host owns it.
        expect(await source.fetchContacts(), isNotEmpty);
        source.dispose();
      },
    );
  });
}
