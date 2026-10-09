import 'dart:async';

import 'package:cairn_template_chat/cairn_template_chat.dart';
import 'package:cairn_template_chat/core/presentation/navigation/chat_navigation_cubit.dart';
import 'package:cairn_template_chat/core/presentation/widgets/icon_action.dart';
import 'package:cairn_template_chat/core/presentation/widgets/search_field.dart';
import 'package:cairn_template_chat/domain/conversations/models/conversation.dart';
import 'package:cairn_template_chat/domain/messages/models/thread_item.dart';
import 'package:cairn_template_chat/presentation/conversations/bloc/conversations_cubit.dart';
import 'package:cairn_template_chat/presentation/conversations/widgets/conversation_skeleton.dart';
import 'package:cairn_template_chat/presentation/conversations/widgets/conversation_tile.dart';
import 'package:cairn_template_chat/presentation/info/views/info_view.dart';
import 'package:cairn_template_chat/presentation/new_chat/views/new_chat_view.dart';
import 'package:cairn_template_chat/presentation/profile/bloc/profile_cubit.dart';
import 'package:cairn_template_chat/presentation/thread/bloc/thread_cubit.dart';
import 'package:cairn_template_chat/presentation/thread/views/thread_view.dart';
import 'package:cairn_template_chat/presentation/thread/widgets/message_composer.dart';
import 'package:cairn_template_chat/presentation/thread/widgets/scroll_to_latest_button.dart';
import 'package:cairn_template_chat/presentation/thread/widgets/typing_indicator.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/chat_harness.dart';
import 'support/fake_sources.dart';

const String thumbsUp = '\u{1F44D}';

Finder tile(String name) => find.widgetWithText(ConversationTile, name);

/// Text inside the open thread (the list shows previews of the same words).
Finder inThread(String text) =>
    find.descendant(of: find.byType(ThreadView), matching: find.text(text));

Finder composerField() => find.descendant(
  of: find.byType(MessageComposer),
  matching: find.byType(EditableText),
);

ThreadCubit threadCubit(WidgetTester tester) =>
    tester.element(find.byType(MessageComposer)).read<ThreadCubit>();

Finder moreFor(String name) =>
    find.descendant(of: tile(name), matching: find.byIcon(Icons.more_vert));

Future<void> openChat(WidgetTester tester, String name) async {
  await tester.tap(tile(name));
  await pumpFrames(tester, 8);
}

Future<void> sendText(
  WidgetTester tester,
  String text, {
  int frames = 8,
}) async {
  await tester.enterText(composerField(), text);
  await pumpFrames(tester, 2);
  await tester.tap(
    find.descendant(
      of: find.byType(MessageComposer),
      matching: find.byIcon(Icons.send),
    ),
  );
  await pumpFrames(tester, frames);
}

Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back).first);
  await pumpFrames(tester, 8);
}

Future<void> longPressMessage(WidgetTester tester, String text) async {
  await tester.longPress(inThread(text));
  await pumpFrames(tester, 6);
}

ConversationsCubit conversations(WidgetTester tester) =>
    read<ConversationsCubit>(tester);

/// The whole conversation of a chat user with the template: search, open a
/// thread, send, get the bot's answer, react, reply, copy, delete, mute,
/// archive and restore, create a group, and page in older history.
Future<void> journey(
  WidgetTester tester,
  double width, {
  CairnTheme theme = CairnTheme.light,
}) async {
  final bool twoPane = width >= 700;
  await mountChat(
    tester,
    width: width,
    height: twoPane ? 900 : (width < 340 ? 640 : 780),
    theme: theme,
  );

  // The list: pinned first, then the rest.
  expect(find.text('Pinned'), findsOneWidget);
  expect(find.text('All chats'), findsOneWidget);
  expect(tile('Mina Park'), findsOneWidget);
  expect(
    twoPane ? find.text('Select a conversation') : find.text('Chats'),
    findsWidgets,
  );

  // Search by name, then by message, then nothing, then clear.
  final Finder search = find.descendant(
    of: find.byType(SearchField),
    matching: find.byType(EditableText),
  );
  await tester.enterText(search, 'hike');
  await pumpFrames(tester, 2);
  expect(tile('Weekend hike'), findsOneWidget);
  expect(tile('Mina Park'), findsNothing);
  await tester.enterText(search, 'zzzz');
  await pumpFrames(tester, 2);
  expect(find.text('No chats found'), findsOneWidget);
  await tapText(tester, 'Clear search');
  expect(tile('Mina Park'), findsOneWidget);
  expect(tester.widget<EditableText>(search).controller.text, isEmpty);

  // Open a thread.
  await openChat(tester, 'Mina Park');
  expect(find.byType(ThreadView), findsOneWidget);
  expect(inThread('Sounds good, see you there!'), findsOneWidget);
  expect(inThread('Online'), findsOneWidget);
  expect(
    threadCubit(tester).state.items.whereType<DateSeparator>().last.day,
    DateTime(2026, 10, 9),
  );
  expect(
    find.descendant(
      of: find.byType(ThreadView),
      matching: find.byIcon(Icons.arrow_back),
    ),
    twoPane ? findsNothing : findsOneWidget,
  );

  // Send, and the demo bot answers.
  await sendText(tester, 'Hello from the test');
  expect(inThread('Hello from the test'), findsOneWidget);
  expect(inThread('Hey! How is your day going?'), findsOneWidget);
  expect(tester.widget<EditableText>(composerField()).controller.text, isEmpty);
  expect(threadCubit(tester).state.typingUserIds, isEmpty);

  // React with an emoji.
  await longPressMessage(tester, 'Hello from the test');
  expect(find.text('Reply'), findsOneWidget);
  await tester.tap(find.text(thumbsUp));
  await pumpFrames(tester, 6);
  expect(inThread(thumbsUp), findsOneWidget);
  expect(
    threadCubit(tester).state.messages
        .firstWhere((Message m) => m.text == 'Hello from the test')
        .reactions
        .single
        .includes('me'),
    isTrue,
  );

  // Reply.
  await longPressMessage(tester, 'Hey! How is your day going?');
  await tester.tap(find.text('Reply'));
  await pumpFrames(tester, 6);
  expect(find.text('Replying to Mina Park'), findsOneWidget);
  await sendText(tester, 'Replying to you');
  expect(find.text('Replying to Mina Park'), findsNothing);
  // The original and the quote of it.
  expect(inThread('Hey! How is your day going?'), findsNWidgets(2));
  expect(
    threadCubit(tester).state.messages
        .firstWhere((Message m) => m.text == 'Replying to you')
        .replyTo
        ?.text,
    'Hey! How is your day going?',
  );

  // Copy, then delete for me.
  await longPressMessage(tester, 'Replying to you');
  await tester.tap(find.text('Copy text'));
  await pumpFrames(tester, 6);
  expect(find.text('Copied'), findsOneWidget);
  await longPressMessage(tester, 'Replying to you');
  await tester.tap(find.text('Delete for me'));
  await pumpFrames(tester, 6);
  expect(inThread('Replying to you'), findsNothing);
  expect(find.text('Message deleted'), findsOneWidget);

  // Mute from the information screen.
  await tester.tap(find.byIcon(Icons.info_outline));
  await pumpFrames(tester, 8);
  expect(find.byType(InfoView), findsOneWidget);
  expect(find.text('Contact info'), findsOneWidget);
  expect(find.text('Block Mina'), findsOneWidget);
  await tester.tap(find.text('Mute notifications'));
  await pumpFrames(tester, 6);
  expect(conversations(tester).state.find('c_mina')!.muted, isTrue);
  await goBack(tester);
  expect(find.byType(ThreadView), findsOneWidget);
  if (!twoPane) await goBack(tester);
  expect(
    find.descendant(
      of: tile('Mina Park'),
      matching: find.byIcon(Icons.notifications_off_outlined),
    ),
    findsOneWidget,
  );

  // Archive from the overflow menu, find it in the archive, restore it.
  await tester.tap(moreFor('Tasha Brown'));
  await pumpFrames(tester, 6);
  expect(find.text('Mark as read'), findsOneWidget);
  await tester.tap(find.text('Archive'));
  await pumpFrames(tester, 6);
  expect(tile('Tasha Brown'), findsNothing);
  await tapText(tester, 'Archived');
  expect(find.text('Archived'), findsWidgets);
  expect(tile('Tasha Brown'), findsOneWidget);
  expect(tile('Amara Okafor'), findsOneWidget);
  await tester.tap(moreFor('Tasha Brown'));
  await pumpFrames(tester, 6);
  await tester.tap(find.text('Unarchive'));
  await pumpFrames(tester, 6);
  expect(tile('Tasha Brown'), findsNothing);
  await tester.tap(find.byIcon(Icons.arrow_back).first);
  await pumpFrames(tester, 6);
  expect(tile('Tasha Brown'), findsOneWidget);

  // New group: an invalid attempt, then a valid one.
  await tester.tap(find.byIcon(Icons.edit_outlined));
  await pumpFrames(tester, 8);
  expect(find.byType(NewChatView), findsOneWidget);
  await tapText(tester, 'New group');
  final Finder newChatFields = find.descendant(
    of: find.byType(NewChatView),
    matching: find.byType(EditableText),
  );
  for (final String name in <String>['Amara', 'Diego']) {
    await tester.enterText(newChatFields.last, name);
    await pumpFrames(tester, 2);
    await tester.tap(
      find.descendant(
        of: find.byType(NewChatView),
        matching: find.textContaining('$name '),
      ),
    );
    await pumpFrames(tester, 2);
  }
  await tester.enterText(newChatFields.last, '');
  await pumpFrames(tester, 2);
  expect(find.text('Create group (2)'), findsOneWidget);
  await tapText(tester, 'Create group (2)');
  expect(find.text('Give the group a name.'), findsOneWidget);
  await tester.enterText(newChatFields.first, 'Lunch crew');
  await pumpFrames(tester, 2);
  await tapText(tester, 'Create group (2)');
  await pumpFrames(tester, 8);
  expect(find.byType(ThreadView), findsOneWidget);
  expect(find.text('Lunch crew'), findsWidgets);
  expect(inThread('3 members'), findsOneWidget);
  expect(inThread('Say hello'), findsOneWidget);
  expect(find.text('Group created'), findsOneWidget);

  // Back to the list, open the long chat and page in older history.
  if (!twoPane) await goBack(tester);
  expect(tile('Lunch crew'), findsOneWidget);
  await openChat(tester, 'Mina Park');
  final ThreadCubit thread = threadCubit(tester);
  expect(thread.state.messages.length, lessThanOrEqualTo(30));
  final Finder messages = find.descendant(
    of: find.byType(ThreadView),
    matching: find.byType(ListView),
  );
  for (int i = 0; i < 12 && thread.state.messages.length <= 30; i++) {
    await tester.drag(messages, const Offset(0, 700));
    await pumpFrames(tester, 3);
  }
  expect(thread.state.messages.length, greaterThan(30));
}

void main() {
  group('the whole journey, light', () {
    for (final double width in testWidths) {
      testWidgets('at $width px', (WidgetTester tester) async {
        await journey(tester, width);
      });
    }
  });

  group('the whole journey, dark', () {
    for (final double width in <double>[320, 700]) {
      testWidgets('at $width px', (WidgetTester tester) async {
        await journey(tester, width, theme: CairnTheme.dark);
      });
    }
  });

  group('every screen in light and dark', () {
    for (final double width in testWidths) {
      for (final bool dark in <bool>[false, true]) {
        testWidgets('${dark ? 'dark' : 'light'} at $width px', (
          WidgetTester tester,
        ) async {
          await mountChat(
            tester,
            width: width,
            height: width < 340 ? 640 : 780,
            theme: dark ? CairnTheme.dark : CairnTheme.light,
          );
          final ChatNavigationCubit nav = read<ChatNavigationCubit>(tester);
          for (final ChatTab tab in ChatTab.values) {
            nav.selectTab(tab);
            await pumpFrames(tester);
          }
          nav.selectTab(ChatTab.chats);
          for (final String id in <String>['c_mina', 'c_hike', 'c_omar']) {
            nav.openThread(id);
            await pumpFrames(tester, 8);
            nav.openInfo(id);
            await pumpFrames(tester, 8);
          }
          nav.openNewChat();
          await pumpFrames(tester, 8);
          nav.openNewChat(group: true);
          await pumpFrames(tester, 8);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('the list', () {
    testWidgets('shows skeletons while loading, then the chats', (
      WidgetTester tester,
    ) async {
      final Completer<void> gate = Completer<void>();
      final WrappedSource source = WrappedSource(demoSource())
        ..conversationsGate = gate;
      addTearDown(source.dispose);
      await mountChat(tester, dataSource: source);
      expect(find.byType(ConversationSkeleton), findsOneWidget);
      expect(find.byType(ConversationTile), findsNothing);
      gate.complete();
      await pumpFrames(tester);
      expect(find.byType(ConversationSkeleton), findsNothing);
      expect(tile('Mina Park'), findsOneWidget);
    });

    testWidgets('an empty inbox invites you to start a chat', (
      WidgetTester tester,
    ) async {
      final InMemoryChatDataSource source = InMemoryChatDataSource(
        replyLatency: Duration.zero,
        now: fixedNow,
        seed: ChatSeed(
          contacts: <Map<String, Object?>>[
            <String, Object?>{'id': 'me', 'name': 'Me', 'presence': 'online'},
          ],
        ),
      );
      addTearDown(source.dispose);
      await mountChat(tester, dataSource: source);
      expect(find.text('No conversations yet'), findsOneWidget);
      await tapText(tester, 'New chat');
      expect(find.byType(NewChatView), findsOneWidget);
      expect(find.text('No contacts found'), findsOneWidget);
    });

    testWidgets('long-press opens the menu; pin moves a chat up', (
      WidgetTester tester,
    ) async {
      await mountChat(tester);
      await tester.longPress(tile('Tasha Brown'));
      await pumpFrames(tester, 6);
      for (final String label in <String>[
        'Pin',
        'Mute',
        'Mark as read',
        'Archive',
        'Delete',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      await tester.tap(find.text('Pin'));
      await pumpFrames(tester, 6);
      expect(
        conversations(tester).state.visiblePinned.map((Conversation c) => c.id),
        contains('c_tasha'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('delete asks first; cancel keeps the chat', (
      WidgetTester tester,
    ) async {
      await mountChat(tester);
      await tester.tap(moreFor('Diego Alvarez'));
      await pumpFrames(tester, 6);
      await tester.tap(find.text('Delete'));
      await pumpFrames(tester, 8);
      expect(find.text('Delete this chat?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await pumpFrames(tester, 8);
      expect(tile('Diego Alvarez'), findsOneWidget);

      await tester.tap(moreFor('Diego Alvarez'));
      await pumpFrames(tester, 6);
      await tester.tap(find.text('Delete'));
      await pumpFrames(tester, 8);
      await tester.tap(
        find.descendant(
          of: find.byType(CairnAlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await pumpFrames(tester, 8);
      expect(tile('Diego Alvarez'), findsNothing);
      expect(find.text('Chat deleted'), findsOneWidget);
    });

    testWidgets('the dock badge counts unread, quiet chats excluded', (
      WidgetTester tester,
    ) async {
      await mountChat(tester);
      expect(
        find.descendant(of: find.byType(CairnDock), matching: find.text('6')),
        findsOneWidget,
      );
      await openChat(tester, 'Omar Haddad');
      await goBack(tester);
      expect(
        find.descendant(of: find.byType(CairnDock), matching: find.text('4')),
        findsOneWidget,
      );
    });

    testWidgets('unread rows show a badge and a muted one is quiet', (
      WidgetTester tester,
    ) async {
      await mountChat(tester);
      expect(
        find.descendant(of: tile('Weekend hike'), matching: find.text('3')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: tile('Diego Alvarez'),
          matching: find.byIcon(Icons.notifications_off_outlined),
        ),
        findsOneWidget,
      );
    });
  });

  group('a thread', () {
    testWidgets('shows typing while the bot writes, then its reply', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, replyLatency: const Duration(milliseconds: 600));
      await openChat(tester, 'Lena Fischer');
      await sendText(tester, 'Are you around?', frames: 0);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TypingIndicator), findsOneWidget);
      expect(inThread('typing...'), findsOneWidget);
      await pumpFrames(tester, 8);
      expect(find.byType(TypingIndicator), findsNothing);
      expect(inThread('Good question. Let me think about it.'), findsOneWidget);
    });

    testWidgets('groups messages into runs and separates days', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, height: 1400);
      await openChat(tester, 'Mina Park');
      expect(inThread('Today'), findsOneWidget);
      // The two photos' captions are on one run each, with their own time.
      expect(inThread('08:37'), findsOneWidget);
      final ThreadCubit cubit = threadCubit(tester);
      expect(
        cubit.state.items.whereType<DateSeparator>().map(
          (DateSeparator d) => d.day,
        ),
        contains(DateTime(2026, 10, 8)),
      );
      while (cubit.state.hasMore) {
        await cubit.loadOlder();
      }
      expect(
        cubit.state.items.whereType<DateSeparator>().length,
        greaterThan(3),
      );
    });

    testWidgets('renders photos, links, emoji, files and locations', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, height: 1400);
      await openChat(tester, 'Mina Park');
      expect(find.byType(Image), findsWidgets);
      expect(inThread('The lake at the halfway point'), findsWidgets);
      await goBack(tester);
      await openChat(tester, 'Omar Haddad');
      expect(inThread('onboarding-v3.pdf'), findsOneWidget);
      expect(inThread('471 KB'), findsOneWidget);
      expect(inThread('\u{1F602}'), findsOneWidget);
      await goBack(tester);
      await openChat(tester, 'Weekend hike');
      expect(inThread('Trailhead car park'), findsOneWidget);
      expect(inThread('Diego Alvarez'), findsWidgets);
    });

    testWidgets('a tapped link says where it goes', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, height: 1000);
      await openChat(tester, 'Mina Park');
      await tester.tapOnText(
        find.textRange.ofSubstring('https://example.com/menu').last,
      );
      await pumpFrames(tester, 4);
      expect(find.text('Link tapped'), findsOneWidget);
      expect(find.text('https://example.com/menu'), findsOneWidget);
    });

    testWidgets('the send button is disabled until there is text', (
      WidgetTester tester,
    ) async {
      await mountChat(tester);
      await openChat(tester, 'Mina Park');
      CairnButton send() => tester.widget<CairnButton>(
        find.ancestor(
          of: find.byIcon(Icons.send),
          matching: find.byType(CairnButton),
        ),
      );
      expect(send().onPressed, isNull);
      await tester.enterText(composerField(), '   ');
      await pumpFrames(tester, 2);
      expect(send().onPressed, isNull);
      await tester.enterText(composerField(), 'x');
      await pumpFrames(tester, 2);
      expect(send().onPressed, isNotNull);
    });

    testWidgets('the composer grows to five lines and then scrolls', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, height: 900);
      await openChat(tester, 'Mina Park');
      Future<double> heightFor(int lines) async {
        await tester.enterText(
          composerField(),
          List<String>.filled(lines, 'line').join('\n'),
        );
        await pumpFrames(tester, 3);
        return tester.getSize(find.byType(CairnTextarea)).height;
      }

      final double one = await heightFor(1);
      final double three = await heightFor(3);
      final double five = await heightFor(5);
      final double nine = await heightFor(9);
      expect(three, greaterThan(one));
      expect(five, greaterThan(three));
      expect(nine, five);
    });

    testWidgets('attach offers photo, camera, file and location', (
      WidgetTester tester,
    ) async {
      await mountChat(tester);
      await openChat(tester, 'Mina Park');
      await tester.tap(find.byIcon(Icons.add));
      await pumpFrames(tester, 6);
      for (final String label in <String>[
        'Photo library',
        'Camera',
        'File',
        'Location',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      await tester.tap(find.text('Camera'));
      await pumpFrames(tester, 6);
      expect(find.text('Camera is a demo'), findsOneWidget);
    });

    testWidgets('scroll to latest appears when away, counts new messages', (
      WidgetTester tester,
    ) async {
      final WrappedSource source = WrappedSource(demoSource());
      addTearDown(source.dispose);
      await mountChat(tester, dataSource: source);
      await openChat(tester, 'Mina Park');
      expect(find.byType(ScrollToLatestButton), findsNothing);
      await tester.drag(
        find.descendant(
          of: find.byType(ThreadView),
          matching: find.byType(ListView),
        ),
        const Offset(0, 500),
      );
      await pumpFrames(tester, 3);
      expect(find.byType(ScrollToLatestButton), findsOneWidget);

      source.pushIncoming(
        conversationId: 'c_mina',
        senderId: 'u_mina',
        text: 'Brand new message',
      );
      await pumpFrames(tester, 3);
      expect(threadCubit(tester).state.unseen, 1);
      expect(
        find.descendant(
          of: find.byType(ScrollToLatestButton),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(ScrollToLatestButton));
      await pumpFrames(tester, 8);
      expect(find.byType(ScrollToLatestButton), findsNothing);
      expect(inThread('Brand new message'), findsOneWidget);
      expect(threadCubit(tester).state.unseen, 0);
    });

    testWidgets('a message sent from the host callback is reported', (
      WidgetTester tester,
    ) async {
      final List<String> told = <String>[];
      await mountChat(tester, onMessageSent: (Message m) => told.add(m.text));
      await openChat(tester, 'Mina Park');
      await sendText(tester, 'Ping');
      expect(told, <String>['Ping']);
    });

    testWidgets('a failed send shows Not sent', (WidgetTester tester) async {
      final WrappedSource source = WrappedSource(demoSource())
        ..failSending = true;
      addTearDown(source.dispose);
      await mountChat(tester, dataSource: source);
      await openChat(tester, 'Mina Park');
      await sendText(tester, 'Nobody will see this');
      expect(inThread('Not sent'), findsOneWidget);
    });
  });

  group('contacts, profile and information', () {
    testWidgets('a contact opens a new conversation; it joins the list once '
        'something is said', (WidgetTester tester) async {
      await mountChat(tester);
      await tapText(tester, 'Contacts');
      expect(find.text('Search contacts'), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: find.byType(SearchField),
          matching: find.byType(EditableText),
        ),
        'Hana',
      );
      await pumpFrames(tester, 2);
      await tester.tap(find.text('Hana Kimura'));
      await pumpFrames(tester, 8);
      expect(inThread('Say hello'), findsOneWidget);
      await sendText(tester, 'Welcome, Hana');
      await goBack(tester);
      await tapText(tester, 'Chats');
      expect(tile('Hana Kimura'), findsOneWidget);
    });

    testWidgets('the profile edits name and availability', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, height: 900);
      await tapText(tester, 'Profile');
      expect(find.text('Alex Rivera'), findsWidgets);
      await tester.enterText(
        find.byType(EditableText).first,
        'Alex Rivera-Stone',
      );
      await pumpFrames(tester, 2);
      await tester.tap(find.text('Save').first);
      await pumpFrames(tester, 4);
      expect(read<ProfileCubit>(tester).state.me?.name, 'Alex Rivera-Stone');
      expect(find.text('Name saved'), findsOneWidget);
      await tester.tap(find.text('Away'));
      await pumpFrames(tester, 4);
      expect(read<ProfileCubit>(tester).state.me?.presence, Presence.away);
    });

    testWidgets('group information lists members and lets you leave', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, height: 900);
      await openChat(tester, 'Weekend hike');
      await tester.tap(find.byIcon(Icons.info_outline));
      await pumpFrames(tester, 8);
      expect(find.text('Group info'), findsOneWidget);
      expect(find.text('Members (4)'), findsOneWidget);
      expect(find.text('Alex Rivera (You)'), findsOneWidget);
      expect(find.text('Theo Marsh'), findsOneWidget);
      await tester.ensureVisible(find.text('Leave group'));
      await pumpFrames(tester, 2);
      await tester.tap(find.text('Leave group'));
      await pumpFrames(tester, 8);
      expect(find.text('Leave Weekend hike?'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(CairnAlertDialog),
          matching: find.text('Leave group'),
        ),
      );
      await pumpFrames(tester, 8);
      expect(tile('Weekend hike'), findsNothing);
      expect(find.text('You left the group'), findsOneWidget);
    });

    testWidgets('blocking removes the person and the chat', (
      WidgetTester tester,
    ) async {
      await mountChat(tester);
      await openChat(tester, 'Tasha Brown');
      await tester.tap(find.byIcon(Icons.info_outline));
      await pumpFrames(tester, 8);
      await tester.tap(find.text('Block Tasha'));
      await pumpFrames(tester, 8);
      await tester.tap(
        find.descendant(
          of: find.byType(CairnAlertDialog),
          matching: find.text('Block'),
        ),
      );
      await pumpFrames(tester, 8);
      expect(tile('Tasha Brown'), findsNothing);
      await tapText(tester, 'Contacts');
      expect(find.text('Tasha Brown'), findsNothing);
    });
  });

  group('layout and accessibility', () {
    testWidgets('at 700 px the list and the thread sit side by side', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, width: 700, height: 800);
      expect(find.text('Select a conversation'), findsOneWidget);
      expect(find.byType(CairnDock), findsOneWidget);
      await openChat(tester, 'Omar Haddad');
      expect(find.text('Select a conversation'), findsNothing);
      expect(tile('Omar Haddad'), findsOneWidget);
      expect(find.byType(ThreadView), findsOneWidget);
      // Opening another conversation swaps the right pane.
      await openChat(tester, 'Weekend hike');
      expect(find.byType(ThreadView), findsOneWidget);
      expect(inThread('4 members'), findsOneWidget);
    });

    testWidgets('below 700 px there is a dock and no second pane', (
      WidgetTester tester,
    ) async {
      await mountChat(tester, width: 699);
      expect(find.text('Select a conversation'), findsNothing);
      await openChat(tester, 'Mina Park');
      expect(find.byType(CairnDock), findsNothing);
      await goBack(tester);
      expect(find.byType(CairnDock), findsOneWidget);
    });

    testWidgets('icon buttons have 44 px targets and names', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await mountChat(tester, width: 320, height: 640);
      for (final Element e in find.byType(IconAction).evaluate()) {
        final Size size = tester.getSize(find.byWidget(e.widget));
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      }
      expect(find.bySemanticsLabel('New chat'), findsOneWidget);
      expect(
        find.bySemanticsLabel('More actions for Mina Park'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('^Mina Park, pinned, Sounds good')),
        findsOneWidget,
      );
      await openChat(tester, 'Mina Park');
      for (final IconAction a in tester.widgetList<IconAction>(
        find.byType(IconAction),
      )) {
        expect(a.label, isNotEmpty);
      }
      for (final Element e in find.byType(IconAction).evaluate()) {
        final Size size = tester.getSize(find.byWidget(e.widget));
        expect(size.shortestSide, greaterThanOrEqualTo(44));
      }
      expect(find.bySemanticsLabel('Send message'), findsOneWidget);
      expect(find.bySemanticsLabel('Attach'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('new messages and typing are live regions', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await mountChat(tester, replyLatency: const Duration(milliseconds: 500));
      await openChat(tester, 'Mina Park');
      await sendText(tester, 'Hello', frames: 0);
      await tester.pump(const Duration(milliseconds: 300));
      final SemanticsNode typing = tester.getSemantics(
        find.bySemanticsLabel('Mina Park is typing'),
      );
      expect(typing.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
      await pumpFrames(tester, 8);
      final Finder announced = find.bySemanticsLabel(
        RegExp('^New message from Mina Park: '),
      );
      expect(announced, findsOneWidget);
      expect(
        tester
            .getSemantics(announced)
            .getSemanticsData()
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      semantics.dispose();
    });

    testWidgets('deep links open a conversation and report the open one', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      final ValueNotifier<String?> wanted = ValueNotifier<String?>('c_omar');
      addTearDown(wanted.dispose);
      final List<String?> reported = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: CairnTheme.materialTheme(
            CairnTheme.light.copyWith(fontFamily: 'Geist'),
          ),
          home: Scaffold(
            body: ValueListenableBuilder<String?>(
              valueListenable: wanted,
              builder: (BuildContext context, String? id, Widget? child) =>
                  ChatApp(
                    replyLatency: Duration.zero,
                    now: fixedNow,
                    initialConversationId: id,
                    onConversationOpened: reported.add,
                  ),
            ),
          ),
        ),
      );
      await pumpFrames(tester);
      expect(find.byType(ThreadView), findsOneWidget);
      expect(inThread('Omar Haddad'), findsOneWidget);
      expect(reported, isEmpty, reason: 'the initial one is not news');

      await goBack(tester);
      expect(reported, <String?>[null]);

      wanted.value = 'c_mina';
      await pumpFrames(tester, 8);
      expect(inThread('Mina Park'), findsWidgets);
      expect(reported, <String?>[null, 'c_mina']);

      wanted.value = null;
      await pumpFrames(tester, 8);
      expect(find.byType(ThreadView), findsNothing);
    });

    testWidgets('large text does not overflow at 320 px', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: CairnTheme.materialTheme(
            CairnTheme.light.copyWith(fontFamily: 'Geist'),
          ),
          builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const Scaffold(
            body: ChatApp(replyLatency: Duration.zero, now: fixedNow),
          ),
        ),
      );
      await pumpFrames(tester);
      await openChat(tester, 'Weekend hike');
      expect(tester.takeException(), isNull);
    });
  });
}
