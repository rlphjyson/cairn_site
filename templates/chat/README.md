# Chat template

A mobile chat app built only from [`cairn_ui`](https://pub.dev/packages/cairn_ui):
a conversation list, threads with grouped bubbles, replies, reactions, photos
and history paging, a new chat and group creator, contact and group information,
and a profile. Clean architecture with the layers at the top level and features
inside each layer, `flutter_bloc` for state and `get_it` for dependency
injection. It runs on an in-memory backend with a scripted demo bot, and plugs
into a real service (REST for history, a WebSocket or SSE channel for live
events) through one interface, without forking.

Full documentation, with install steps, the JSON reference, a REST + WebSocket
backend, a Firebase example, push notifications, uploads and deep links, is in
[`doc/index.html`](doc/index.html). It is one self-contained file: open it in a
browser, offline.

Photographs are from [Pexels](https://www.pexels.com), used under the Pexels
licence; see [`NOTICE.md`](NOTICE.md).

## Features

- **Chats**: avatar with a presence dot (online, away, do not disturb), name,
  the last message ("You: ...", "Mina: ..." in groups), relative time (`now`,
  `12m`, `3h`, `Yesterday`, `Mon`, `7 Oct`), an unread badge, a muted icon, a
  pinned section, and an archive. Search filters by name and message. Long-press
  (or the overflow button, or a screen reader's custom action) opens pin, mute,
  mark read or unread, archive and delete, which asks first. Skeletons while
  loading, a retry if loading fails, empty and no-results states.
- **Thread**: header with avatar, presence or last seen, and "typing..."; bubbles
  grouped by sender within five minutes; date separators (`Today`, `Yesterday`,
  `Mon 7 Oct`); delivery ticks (sending, sent, read, not sent); reply quotes;
  photos with captions; files and locations; links; larger emoji-only messages;
  reactions; an animated typing indicator; a composer that grows to five lines
  with a send button that stays disabled while empty; an attach sheet (photo,
  camera, file, location: toasts in the demo); long-press actions (six
  reactions, reply, copy, delete for me); a scroll-to-latest button with a count
  of unseen messages; older history loads as you scroll up.
- **New chat**: contacts in alphabetical sections with search, start a one-to-one
  chat, or switch to group mode, pick people (chips), name the group and create
  it (validated).
- **Info**: avatar, status, shared photos, a mute switch, group members, leave
  or block (both confirm).
- **Profile**: edit your name and status line, choose Online, Away or Do not
  disturb, and a few settings.
- **Responsive and accessible**: lays out from 320 px up with a bottom dock; from
  700 px wide it is two panes (list left, thread right). Light and dark. Icon
  buttons have 44 px targets and names; rows have summary labels and custom
  actions; typing and new messages are live regions.
- **A demo bot** that reads your message after a configurable latency, starts
  typing, and answers with varied replies (sometimes a photo), so unread counts,
  previews, ordering and presence all move the way a real backend's would.

## Layout

```
chat/
├── lib/
│   ├── cairn_template_chat.dart   # the barrel: exports ChatApp and the public types
│   ├── chat_app.dart              # entry widget (ChatApp)
│   ├── core/
│   │   ├── infrastructure/        # ChatSession; di/chat_injection.dart (get_it)
│   │   └── presentation/
│   │       ├── navigation/        # in-app navigation cubit (tabs + screen stack)
│   │       ├── widgets/           # avatar, header, empty state, search, ...
│   │       └── view_model.dart    # ViewModel, ViewModelBuilder, ChatScope
│   ├── common/
│   │   ├── constants/             # limits, reaction emoji, demo replies, ChatPackage
│   │   └── utils/                 # dates, emoji, links, initials
│   ├── data/
│   │   ├── chat/remote/           # ChatRemoteDataSource, the in-memory backend,
│   │   │                          # the demo bot and the seed data
│   │   └── <feature>/repositories/  # implement the domain interfaces
│   ├── domain/<feature>/
│   │   ├── models/                # plain business objects
│   │   ├── mappers/               # decoded JSON <-> models
│   │   ├── repositories/          # interfaces the domain depends on
│   │   └── use_cases/             # one job each
│   └── presentation/
│       ├── <feature>/
│       │   ├── bloc/              # cubits and their states
│       │   ├── view_models/       # screen-scoped owners of cubits
│       │   ├── views/             # screens
│       │   └── widgets/           # feature-specific UI
│       └── shell/                 # providers, dock, two-pane composition
├── assets/images/                 # avatars and photographs (Pexels)
├── doc/index.html                 # documentation and tutorial
├── test/                          # unit, session and widget tests
└── NOTICE.md                      # image credits
```

Features: `contacts`, `conversations`, `messages` (domain and data);
`conversations`, `thread`, `new_chat`, `info`, `contacts`, `profile` and `shell`
(presentation).

| Feature | Domain use cases |
| --- | --- |
| conversations | `GetConversations`, `SearchConversations`, `UpdateConversation`, `DeleteConversation`, `OpenDirectConversation`, `CreateGroup`, `LeaveGroup`, `FormatRelativeTime`, `WatchConversationChanges`, `GetConversation` |
| messages | `GetMessages`, `SendMessage`, `MarkRead`, `GroupMessages`, `ReactToMessage`, `DeleteMessage`, `WatchConversation`, `GetSharedMedia` |
| contacts | `GetContacts`, `GroupContacts`, `SearchContacts`, `GetCurrentUser`, `UpdateProfile`, `BlockContact`, `WatchPresence` |

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart and `common`.
2. **The data source returns decoded JSON** (`Map<String, Object?>`), exactly as
   a REST client would. Mappers in `domain/<feature>/mappers/` turn it into
   models, and are the only place that knows the wire format.
3. **Views never touch the container.** A screen that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>`; session cubits are read with
   `context.read`.
4. **Two kinds of cubit.**
   - *Session cubits* (navigation, conversations, contacts, profile) are lazy
     singletons, provided once by `ChatProviders` with `BlocProvider.value`.
     Nothing closes them but the container.
   - *Screen cubits* (thread, new chat, info) are created by a view model, which
     closes them in `dispose`.
5. **Features do not import each other's views.** They may read each other's
   session cubits (a thread reads the contacts for names and presence), and one
   widget set is shared on purpose: the thread header uses the conversation
   menu from `presentation/conversations/widgets/`. Anything that composes
   features (the tabs, the dock, the two-pane layout) lives in
   `presentation/shell/`.
6. **Static data in `common/constants`**, never inline in a view.
7. **No code generation.** Registrations are written out in
   `core/infrastructure/di/chat_injection.dart`.
8. **Only Cairn.** Widgets come from `cairn_ui` (plus Material `Icon`s for
   glyphs Cairn lacks) and colours from `CairnTheme`. The only literal colours
   are translucent overlays derived from the bubble's own text colour.
9. **Real time goes through one door.** Everything that happens to the app
   without being asked for (a new message, a read receipt, typing, presence)
   arrives as a frame on `ChatRemoteDataSource.events()`, is decoded by
   `ChatEventMapper`, and reaches the screens through
   `MessageRepository.watchConversation`, `ConversationRepository.watchChanges`
   and `ContactRepository.watchPresence`.

## Where to change things

| To change | Edit |
| --- | --- |
| People, conversations and history of the demo | `lib/data/chat/remote/chat_seed.dart` (or pass your own `ChatSeed` to `InMemoryChatDataSource`) |
| What the demo bot says | `lib/common/constants/demo_replies.dart` and `lib/data/chat/remote/demo_bot.dart` |
| Bot answer time | `ChatApp(replyLatency: ...)` |
| Page size, run window, composer lines, breakpoint | `lib/common/constants/chat_limits.dart` |
| The six reaction emoji | `lib/common/constants/reaction_emoji.dart` |
| Bubble layout, ticks, reaction chips | `lib/presentation/thread/widgets/message_bubble.dart` and `message_content.dart` |
| Date and time wording | `lib/common/utils/dates.dart` and `lib/domain/conversations/use_cases/format_relative_time.dart` |
| What attach does | `_attach` in `lib/presentation/thread/views/thread_view.dart` |
| The backend | implement `ChatRemoteDataSource` and pass it as `ChatApp(chatDataSource: ...)` |

## Mount it

```dart
import 'package:cairn_template_chat/cairn_template_chat.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: const Scaffold(body: SafeArea(child: ChatApp())),
  ),
);
```

`ChatApp` takes whatever size it is given (320 by 640 and up). Below 700 px it
is a phone with a dock; at 700 px and wider it splits into two panes. Inside a
`CairnMockupPhone` it fills the phone.

```dart
ChatApp(
  chatDataSource: MyChatDataSource(),       // your backend; defaults to the demo
  currentUserId: 'u_42',                    // decides sent (right) vs received (left)
  onMessageSent: (Message m) => track(m),   // after the backend accepted it
  replyLatency: Duration.zero,              // demo bot only
  initialConversationId: 'c_mina',          // deep link
  onConversationOpened: (String? id) {},    // keep your router in step
)
```

Cairn leaves `fontFamily` unset in its tokens, so give your theme one:
`CairnTheme.light.copyWith(fontFamily: 'Inter')`.

## Use it in your app

As a package, from a path or git dependency:

```yaml
dependencies:
  cairn_template_chat:
    path: ../cairn_template_chat
```

Or copy it: put `lib/` (minus the barrel if you like) and `assets/` into your own
app, declare the assets in your `pubspec.yaml`, add `cairn_ui`, `equatable`,
`flutter_bloc` and `get_it`, and change `ChatPackage.name = null` in
`lib/common/constants/chat_package.dart` so images resolve from your app instead
of the package.

## Navigation

The chat uses its own `ChatNavigationCubit` (tabs, plus a stack of thread, info
and new chat screens), not your app's router, so it runs unchanged inside any
app. For deep links use `initialConversationId` and `onConversationOpened`;
`doc/index.html` shows the `go_router` wiring and how to replace the cubit
outright.

## Limitations

- Attach, camera, file and location are demo no-ops (a toast). The template
  shows where to plug a picker and an upload in; it does not ship one.
- Links are drawn and tappable but only report the address (a toast).
- The settings switches on the Profile tab are kept in memory only.
- The layout is not mirrored for right-to-left languages, and all text is
  English literals (see "Localisation" in the docs).
- The composer is Cairn's textarea, whose minimum height is 64 px, so an empty
  composer is two lines tall.
- Reaction chips are about 30 px tall; the long-press sheet offers the same
  reactions at 44 px.

## Tests

```
flutter pub get
dart format .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

- `test/domain_test.dart` (55): ordering, search, paging, sending, grouping and
  date separators, relative time, group validation, reactions, mappers, the seed
  data and the bot.
- `test/session_test.dart` (43): the cubits wired through the real container with
  no widgets, against the in-memory backend and a wrapped one that pushes events
  by hand.
- `test/widget_test.dart` (40): the whole journey (search, open, send, bot reply,
  react, reply, copy, delete, mute, archive and restore, new group, older
  history) at 320, 360, 390 and 700 px in light and 320 and 700 px in dark, every
  screen in light and dark at every width, plus focused tests for skeletons,
  empty states, menus, typing, the composer, attach, scroll-to-latest, deep
  links, semantics and large text. Cairn has repeating animations, so tests pump
  in small steps and never call `pumpAndSettle`.

`test/flutter_test_config.dart` loads Geist from the Cairn site checkout when it
is there, and the harness gives the test theme `fontFamily: 'Geist'`, so text is
laid out with real metrics and an overflow in a test is an overflow on a device.
