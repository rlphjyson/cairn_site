# Settings template

Mobile settings screens built only from [`cairn_ui`](https://pub.dev/packages/cairn_ui):
a searchable home with a profile card, Edit profile, Appearance, Notifications,
Privacy and security (two-factor, sessions, blocked users, change password),
Language and region, Storage and data, Help, About and a Danger zone. From 600 px
wide it becomes a two-pane master/detail layout. It is injectable (the backend,
the list of settings and every host callback are arguments), applies the
person's appearance choices to itself and tells your app what changed. Clean
architecture with the layers at the top level and features inside each layer,
`flutter_bloc` for state and `get_it` for dependency injection.

Full documentation, with install steps, a persisted `SettingsDataSource`, a REST
example, registry recipes, theme wiring, account hooks, notification permission,
`go_router` integration and a production checklist, is in
[`doc/index.html`](doc/index.html). It is one self-contained file: open it in a
browser, offline.

The template is typographic: it ships no images, so there is nothing to credit.

## Features

- **Home**: a title, a search field (matches titles, keywords, descriptions and
  section names, grouped under their section, best match first), a profile card
  and the categories in four groups: Account, Preferences, Data and support,
  Session. Rows show a current value where one fits (theme, On/Off, language).
- **Edit profile**: name, username (checked for availability as you type),
  email, bio (160 characters) and an avatar preset. Inline validation, a saving
  state, and a "Discard changes?" dialog if you leave with unsaved edits.
- **Appearance**: Light, Dark or System; text size (four steps, with a live
  sample); accent colour (Ink, Ocean, Forest); Reduce motion. Every change
  applies to the whole template at once and is reported to your app.
- **Notifications**: a master switch, what to notify about, delivery channel,
  digest and quiet hours with start and end times. When the operating system has
  refused permission an alert explains it and offers Open settings.
- **Privacy and security**: biometric lock, two-factor authentication (a setup
  sheet with the secret key and a six-digit code check), change password (strength
  meter, per-field errors), active sessions (sign one device or all the others
  out), export my data and blocked users (unblock down to an empty state).
- **Language and region**: language, region, date format, time format and units,
  with a preview that follows the choices.
- **Storage and data**: a usage meter by category, clear cache (confirmation
  says how much it frees), download over Wi-Fi only and auto-delete.
- **Help**: FAQ accordion, a contact support form (subject, message, validation,
  ticket reference) and the app version, tap to copy.
- **About**: version and build, open-source licences, Terms and Privacy policy
  links (handed to your app) and a star rating dialog.
- **Danger zone**: Sign out (confirmed), Deactivate account (confirmed) and
  Delete account (type `DELETE`, then a final confirmation). Each calls your app.
- **Two panes from 600 px**: categories on the left (288 px), the selected
  category on the right (content up to 560 px). At large text sizes a tablet
  falls back to one page at a time so the list never swallows the page.
- **Responsive and accessible**: works from 320 px wide, light and dark. Every
  control has an accessible name; Cairn controls are wrapped to a 44 px touch
  target (the select and input are Cairn's own 36 px, with text scaling capped
  at 1.5 inside them); switches announce their state; errors and notices are live
  regions; headings are announced as headers. With reduced motion
  (`MediaQuery.disableAnimations`, or the Reduce motion setting) every
  transition is instant. Text size multiplies the system text scale.

## Layout

```
settings/
├── lib/
│   ├── cairn_template_settings.dart     # the barrel: exports SettingsApp and the host types
│   ├── settings_app.dart                # entry widget (SettingsApp)
│   ├── core/
│   │   ├── infrastructure/
│   │   │   ├── di/                      # get_it container: settings_injection.dart
│   │   │   ├── settings_hooks.dart      # the host's callbacks, shared with the cubits
│   │   │   └── unsaved_changes_guard.dart
│   │   └── presentation/
│   │       ├── navigation/              # in-template navigation cubit, navigator, pages
│   │       ├── widgets/                 # page frame, rows, touch target, load gate, overlays
│   │       ├── settings_appearance.dart # stored choices -> CairnTheme
│   │       └── view_model.dart          # ViewModel, ViewModelBuilder, SettingsScope
│   ├── common/
│   │   ├── constants/                   # layout, text sizes, FAQ, support subjects, avatars,
│   │   │                                # time options, confirmation phrases
│   │   └── utils/                       # byte format, relative time, preview, SettingsFailure
│   ├── data/<feature>/
│   │   ├── remote/                      # SettingsDataSource and the in-memory demo
│   │   └── repositories/                # implement the domain interfaces
│   ├── domain/<feature>/
│   │   ├── models/                      # plain business objects (settings: definitions too)
│   │   ├── mappers/                     # decoded JSON <-> models
│   │   ├── registry/                    # settings: the registry, defaults, home groups
│   │   ├── repositories/                # interfaces the domain depends on
│   │   └── use_cases/                   # one job each
│   └── presentation/
│       ├── <feature>/
│       │   ├── bloc/                    # cubits and their states
│       │   ├── view_models/             # screen-scoped owners of cubits
│       │   ├── views/                   # screens
│       │   └── widgets/                 # feature-specific UI
│       └── shell/                       # providers, theme scope, one/two-pane shell
├── doc/index.html                       # documentation and tutorial
└── test/                                # domain, session and widget tests, plus support/
```

Features: `profile`, `security`, `settings`, `shared`, `storage` and `support` in
`domain/` (`shared` holds only the write envelope); `profile`, `security`,
`settings`, `storage` and `support` in `data/`; `about`, `appearance`, `danger`,
`help`, `home`, `language`, `notifications`, `privacy`, `profile`, `settings`,
`storage` and `shell` in `presentation/`.

| Feature | Domain use cases |
| --- | --- |
| settings | `LoadSettings`, `UpdateSetting`, `SearchSettings`, `GetAppInfo` |
| profile | `GetProfile`, `ValidateProfile`, `CheckUsername`, `SaveProfile` |
| security | `ChangePassword`, `GetSessions`, `RevokeSession`, `BeginTwoFactor`, `VerifyTwoFactor`, `DisableTwoFactor`, `ExportData`, `GetBlockedUsers`, `UnblockUser`, `DeactivateAccount`, `DeleteAccount` |
| storage | `GetStorageUsage`, `ClearCache` |
| support | `SubmitSupportRequest` |

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart and `common`.
2. **Data sources return decoded JSON** (`Map<String, Object?>`), exactly as a
   REST client would. Mappers in `domain/<feature>/mappers/` turn it into models
   and are the only place that knows the wire format. Writes answer with
   `{ "ok": true }` or `{ "ok": false, "error": "..." }`.
3. **The registry is the single source of truth for settings.** The search, each
   category screen, the mapper that repairs stored values and `UpdateSetting` all
   read `SettingsRegistry`. Add, remove or reorder a definition and all four
   follow.
4. **Views never touch the container.** A screen that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>`; session cubits are read with `context.read`.
5. **Two kinds of cubit.**
   - *Session cubits* (`SettingsNavigationCubit`, `SettingsCubit`, `ProfileCubit`)
     are lazy singletons, provided once by `SettingsProviders` with
     `BlocProvider.value`. Nothing closes them but the container.
   - *Screen cubits* (search, profile draft, sessions, two-factor, storage,
     support, account...) are created by a view model, which closes them in
     `dispose`.
6. **Features do not import each other's views.** Anything shared lives in
   `core/presentation/widgets/`. `presentation/shell/` composes the screens.
7. **Static data in `common/constants`**, never inline in a view.
8. **No code generation.** Registrations are written out in
   `core/infrastructure/di/settings_injection.dart`.
9. **Only Cairn.** Widgets come from `cairn_ui` (plus Material `Icon`s for
   glyphs Cairn lacks) and colours from `CairnTheme`.
10. **The backend and the platform are injected.** The template never calls
    `shared_preferences`, an HTTP client, `local_auth` or a permissions plugin;
    it asks `SettingsDataSource` and your callbacks.

## Where to change things

| To change | Edit |
| --- | --- |
| Where settings, profile, sessions, storage and support are stored | `SettingsApp(settingsDataSource: ...)` |
| Which settings exist, their order, groups, defaults and options | `SettingsApp(registry: ...)`, or `lib/domain/settings/registry/default_settings_registry.dart` |
| How the home groups the categories | `lib/domain/settings/registry/home_groups.dart` |
| Titles and one-line summaries of the categories | `lib/domain/settings/models/settings_section.dart` |
| FAQ questions and answers | `lib/common/constants/faq_items.dart` |
| Contact form subjects | `lib/common/constants/support_subjects.dart` |
| Text size labels and factors | `lib/common/constants/text_size_steps.dart` |
| Avatar presets | `lib/common/constants/avatar_presets.dart` (looks: `presentation/profile/widgets/profile_avatar.dart`) |
| The word to type before deleting | `lib/common/constants/confirmation_phrases.dart` |
| Accent colours | `lib/core/presentation/settings_appearance.dart` (and the `appearance.accent` options) |
| Breakpoint, pane and content widths | `lib/common/constants/settings_layout.dart` |
| Sign out, deactivate, delete | `SettingsApp(onSignOut: ..., onDeactivateAccount: ..., onDeleteAccount: ...)` |
| Opening Terms and Privacy | `SettingsApp(onLinkTap: ...)` |
| Notification permission | `SettingsApp(notificationPermission: ..., onRequestNotificationPermission: ..., onOpenSystemSettings: ...)` |

## Mount it

```dart
import 'package:cairn_template_settings/cairn_template_settings.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: Scaffold(
      body: SafeArea(
        child: SettingsApp(
          onThemeModeChanged: (ThemeMode mode) {
            // Rebuild your MaterialApp with themeMode: mode.
          },
          onSignOut: () {
            // Clear your session and go to sign in.
          },
        ),
      ),
    ),
  ),
);
```

`SettingsApp` takes whatever size it is given (320 by 640 and up). Inside a
`CairnMockupPhone` it fills the phone; from 600 px wide it becomes two panes. It
does not use your router; see "Navigation".

### Arguments

| Argument | Meaning |
| --- | --- |
| `settingsDataSource` | Where everything is read and written. Default: `InMemorySettingsDataSource` (realistic seed data, forgets on exit). |
| `registry` | The settings the app has. Default: `defaultSettingsRegistry`. |
| `profile` | The signed-in person, when your app already has it. Shown at once; saving still goes through the data source. |
| `onThemeModeChanged(ThemeMode)` | The person picked Light, Dark or System. |
| `onSettingChanged(String id, Object? value)` | Any stored setting changed. |
| `onSignOut` | The person confirmed Sign out. |
| `onDeactivateAccount` | The account was deactivated (after the data source said yes). |
| `onDeleteAccount` | The account was deleted (after the data source said yes). |
| `onLinkTap(SettingsLink)` | Terms of service or Privacy policy was tapped. The template never opens URLs. |
| `onRateApp(int stars)` | The person sent a rating, 1 to 5. |
| `onOpenSystemSettings` | The person tapped Open settings on the "Notifications are blocked" alert. |
| `onRequestNotificationPermission` | Asks the platform for permission when notifications are turned on while it is undecided. Returns the answer. |
| `notificationPermission` | What the operating system allows: `granted` (default), `denied` or `notDetermined`. Read again whenever it changes. |
| `initialLocation` | Open on a page: a category (`appearance`) or a path (`privacy/sessions`). Read once. |

The callbacks may change between builds (a `setState` in the parent is fine); the
app is not restarted. `settingsDataSource`, `registry`, `profile` and
`initialLocation` are read once, when the widget is first built.

## Use it in your app

As a package, from a path or git dependency:

```yaml
dependencies:
  cairn_template_settings:
    path: ../cairn_template_settings
```

Or copy it: put `lib/` (minus the barrel if you like) into your own app, add
`cairn_ui`, `equatable`, `flutter_bloc` and `get_it` to your `pubspec.yaml`, and
rewrite the `package:cairn_template_settings/...` imports to your package name.
There are no assets to declare.

## Navigation

The settings use their own `SettingsNavigationCubit`, not your app's router, so
they run unchanged inside any app. On a phone the top page fills the screen; on a
tablet the first page is the selected category and the top page is shown beside
the list. To use `go_router` or `Navigator`, mount `SettingsApp` as one route and
pass `initialLocation`, or replace that cubit and keep the views; `doc/index.html`
shows how.

## Account hooks

Sign out only calls `onSignOut`: your app ends the session. Deactivate and
delete call the data source first and the hook only when it answers `ok`. The
template never signs anyone out, hides or deletes anything by itself.

## Tests

```
flutter pub get
dart format .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

- `test/domain_test.dart`: the registry (unique ids, valid defaults, lookups,
  sections, home groups), the search, the settings mapper and its repair of bad
  values, `UpdateSetting`, profile validation and username rules, the password
  rules and strength, sessions and two-factor, delete confirmation, storage, the
  support form and the formatting helpers.
- `test/session_test.dart`: the cubits wired through the real container, with no
  widgets: independent containers, navigation and location parsing, settings
  loading, saving and rollback, notification permission, profile editing and its
  unsaved-changes guard, privacy, storage, support and the account hooks.
- `test/widget_test.dart`: every page mounted at 320, 360 and 700 px, in light and
  dark and at text scales 1, 1.3 and 2 (Flutter fails a test on any overflow),
  then the flows: search, profile, appearance applying live, notifications,
  password, sessions, two-factor, language, storage, help, about, the danger zone,
  a failing data source with a retry, a registry with settings removed and the
  accessibility labels. Cairn has repeating animations, so tests pump in small
  steps and never call `pumpAndSettle`.
- `test/support/settings_harness.dart`: `Host` (records every callback),
  `mountSettings`, `pumpFrames` and finders such as `tapRow`, `tapButton` and
  `typeInto`. Copy it into your own tests.

`test/flutter_test_config.dart` loads Geist from the Cairn site checkout when it
can find it, so text has real metrics; without it the tests still run, in
Flutter's wider placeholder font.
