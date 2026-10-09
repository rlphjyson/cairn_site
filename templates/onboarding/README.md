# Onboarding template

A mobile onboarding flow built only from [`cairn_ui`](https://pub.dev/packages/cairn_ui):
a splash screen, swipeable value pages, permission cards, a short
personalisation, an account choice and a calm summary. It is resumable (progress
is saved after every change), injectable (content, storage and permissions are
all arguments) and finishes by handing a typed result to your app. Clean
architecture with the layers at the top level and features inside each layer,
`flutter_bloc` for state and `get_it` for dependency injection.

Full documentation, with install steps, a `shared_preferences` "show once" gate,
real permissions with `permission_handler`, remote-config content, analytics,
auth hand-off and `go_router` integration, is in [`doc/index.html`](doc/index.html).
It is one self-contained file: open it in a browser, offline.

Photographs are from [Pexels](https://www.pexels.com), used under the Pexels
licence; see [`NOTICE.md`](NOTICE.md).

## Features

- **Splash**: the brand mark fades in once (finite, no loops), holds a moment
  and moves on as soon as the content has loaded. A retry is offered if loading
  fails.
- **Value pages**: four swipeable pages (large photograph, title, body), a dot
  indicator, Skip, Next / Get started, and back by swipe, by the back control or
  by the system back gesture.
- **Permissions**: notifications and location (camera is supported by adding a
  card to the content), each a card with benefit copy and an Allow button that
  calls an injectable `PermissionService`. The result is shown on the card; a
  refusal explains how to enable it later and offers Try again or Open settings.
  Continuing without allowing is always possible.
- **Personalise**: interests (selectable chips, at least three), one goal and a
  reminder time (a select), one part per screen with a `CairnSteps` indicator.
  It cannot be skipped, and the flow will not move past it until the answers are
  valid.
- **Account**: Create account, I already have an account, Continue as guest.
  The template builds no sign-in forms; the choice is handed to your app.
- **Done**: a summary of what was chosen and a Start button that calls
  `onCompleted(OnboardingResult)`. A demo-only "Replay from the start" resets
  everything.
- **Resumable**: re-opening continues on the same step, page and part, with the
  same answers. A saved state that no longer fits the content (a page or step
  was removed) is repaired, never trusted.
- **Responsive and accessible**: lays out from 320 px up; from 600 px wide the
  content stays a centred 440 px column. Light and dark. Every control has an
  accessible name; Cairn controls are wrapped to a 44 px touch target (the
  reminder select is Cairn's own 36 px); errors and permission results are live
  regions; headings are announced as headers; images carry descriptions. With
  reduced motion (`MediaQuery.disableAnimations`) every transition is instant.
  Large text scales without overflow: content scrolls and the primary action
  stays pinned.

## Layout

```
onboarding/
├── lib/
│   ├── cairn_template_onboarding.dart   # the barrel: exports OnboardingApp and the host types
│   ├── onboarding_app.dart              # entry widget (OnboardingApp)
│   ├── core/
│   │   ├── infrastructure/
│   │   │   ├── di/                      # get_it container: onboarding_injection.dart
│   │   │   └── onboarding_hooks.dart    # the host's callbacks, shared with the cubits
│   │   └── presentation/
│   │       ├── navigation/              # in-template navigation cubit
│   │       ├── widgets/                 # step layout, footer button, touch target, brand mark
│   │       ├── motion.dart              # reduced-motion aware durations
│   │       └── view_model.dart          # ViewModel, ViewModelBuilder, OnboardingScope
│   ├── common/
│   │   ├── constants/                   # brand, layout, personalise parts, account
│   │   │                                # benefits, OnboardingPackage
│   │   └── utils/                       # list formatting
│   ├── data/<feature>/
│   │   ├── remote/                      # flow content source, demo permission service
│   │   ├── local/                       # the progress store (in-memory here)
│   │   └── repositories/                # implement the domain interfaces
│   ├── domain/<feature>/
│   │   ├── models/                      # plain business objects
│   │   ├── mappers/                     # decoded JSON <-> models
│   │   ├── repositories/                # interfaces the domain depends on
│   │   └── use_cases/                   # one job each
│   └── presentation/
│       ├── <feature>/
│       │   ├── bloc/                    # cubits and their states
│       │   ├── view_models/             # screen-scoped owners of cubits
│       │   ├── views/                   # screens
│       │   └── widgets/                 # feature-specific UI
│       └── shell/                       # providers, the progress bar, step transitions
├── assets/images/                       # the four value-page photographs (Pexels)
├── doc/index.html                       # documentation and tutorial
├── test/                                # unit, session and widget tests
└── NOTICE.md                            # image credits
```

Features: `flow`, `permissions`, `personalise` and `progress` in `domain/` and
`data/`; `splash`, `welcome`, `permissions`, `personalise`, `account`, `done`,
`flow` and `shell` in `presentation/`.

| Feature | Domain use cases |
| --- | --- |
| flow | `GetOnboardingFlow`, `GetNextStep`, `GetPreviousStep`, `CanAdvance` |
| permissions | `RequestPermission`, `OpenPermissionSettings` |
| personalise | `ValidateInterests` |
| progress | `ResumeProgress`, `SaveProgress`, `CompleteOnboarding`, `ResetProgress` |

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart and `common`. A feature's use
   case may depend on another feature's domain model or use case (`CanAdvance`
   uses `ValidateInterests`; `CompleteOnboarding` uses `CanAdvance`), never on
   its data layer.
2. **Data sources return decoded JSON** (`Map<String, Object?>`), exactly as a
   REST client or a remote-config SDK would. Mappers in
   `domain/<feature>/mappers/` turn it into models, and are the only place that
   knows the wire format.
3. **Views never touch the container.** A screen that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>`; session cubits are read with
   `context.read`.
4. **Two kinds of cubit.**
   - *Session cubits* (navigation, the onboarding flow) are lazy singletons,
     provided once by `OnboardingProviders` with `BlocProvider.value`. Nothing
     closes them but the container. The flow cubit owns the content and the
     progress, saves it, and is the only thing that tells the navigation cubit
     which step to show.
   - *Screen cubits* (the personalise draft) are created by a view model, which
     closes them in `dispose`.
5. **Features do not import each other's views.** Anything shared lives in
   `core/presentation/widgets/` (the step layout, the footer button, the brand
   mark). `presentation/shell/` composes the steps.
6. **Static data in `common/constants`**, never inline in a view. Content that
   is meant to change without a release lives in the flow JSON instead.
7. **No code generation.** Registrations are written out in
   `core/infrastructure/di/onboarding_injection.dart`.
8. **Only Cairn.** Widgets come from `cairn_ui` (plus Material `Icon`s for
   glyphs Cairn lacks) and colours from `CairnTheme`.
9. **Storage and the platform are injected.** The template never calls
   `shared_preferences` or a permissions plugin; it asks `ProgressStore` and
   `PermissionService`, which you implement.

## Where to change things

| To change | Edit |
| --- | --- |
| Pages, headings, permission cards, interests, goals, reminder options, which steps appear | `lib/data/flow/remote/flow_remote_data_source.dart` (or write a real data source) |
| The photographs | `assets/images/` and the `image` keys in the same file |
| Brand name, tagline, sample notification | `lib/common/constants/onboarding_brand.dart` |
| The mark on the splash screen | `lib/core/presentation/widgets/brand_mark.dart` |
| Reasons to create an account | `lib/common/constants/account_benefits.dart` |
| Headings of the three personalise parts | `lib/common/constants/personalise_sections.dart` |
| Minimum interests, default reminder | the `personalise` object in the flow JSON |
| Where progress is saved | `OnboardingApp(progressStore: ...)` |
| How permissions are asked for | `OnboardingApp(permissionService: ...)` |
| What happens at the end | `OnboardingApp(onCompleted: ...)` |

## Mount it

```dart
import 'package:cairn_template_onboarding/cairn_template_onboarding.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: Scaffold(
      body: SafeArea(
        child: OnboardingApp(
          onCompleted: (OnboardingResult result) {
            // Save the choices, then route by result.accountChoice.
          },
        ),
      ),
    ),
  ),
);
```

`OnboardingApp` takes whatever size it is given (320 by 640 and up). Inside a
`CairnMockupPhone` it fills the phone; on a tablet or desktop it stays a centred
column 440 px wide. It does not use your router; see "Navigation".

### Arguments

| Argument | Meaning |
| --- | --- |
| `onCompleted(OnboardingResult)` | The user pressed Start. Carries interests, goal, reminder, permission answers and the account choice. |
| `onSkipped(OnboardingStepKind)` | The user skipped a step that allows it. Informational: the flow moves on by itself. |
| `onStepChanged(OnboardingStepKind)` | A step was shown. For analytics. |
| `flowDataSource` | Where the content comes from. Default: `InMemoryFlowRemoteDataSource`. |
| `progressStore` | Where progress is kept. Default: `InMemoryProgressStore` (forgets on exit). |
| `permissionService` | How permissions are requested. Default: `DemoPermissionService` (grants everything, no prompt). |
| `startAtStep` | Open on this step and skip the splash. |
| `showReplay` | Offer "Replay from the start" on the last step. For demos. |

## Use it in your app

As a package, from a path or git dependency:

```yaml
dependencies:
  cairn_template_onboarding:
    path: ../cairn_template_onboarding
```

Or copy it: put `lib/` (minus the barrel if you like) and `assets/` into your own
app, declare the assets in your `pubspec.yaml`, add `cairn_ui`, `equatable`,
`flutter_bloc` and `get_it`, and change
`OnboardingPackage.name = null` in
`lib/common/constants/onboarding_package.dart` so images resolve from your app
instead of the package.

## Navigation

The flow uses its own `OnboardingNavigationCubit`, not your app's router, so it
runs unchanged inside any app. To use `go_router` or `Navigator`, replace that
cubit and keep the views; `doc/index.html` shows how.

## Accounts

The account step records a choice and moves on. It builds no sign-in forms.
When the user presses Start, `OnboardingResult.accountChoice` says whether to
open sign-up, sign-in or go straight in as a guest. See the authentication
template for the forms, and `doc/index.html` for the hand-off.

## Tests

```
flutter pub get
dart format .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

- `test/domain_test.dart`: the content mapper (including steps that are left out
  or repeated), progress mapping and repair, the step rules, interest
  validation, the use cases and the demo permission service.
- `test/session_test.dart`: the cubits wired through the real container, with no
  widgets: loading, every step, skipping, the progress rules, resuming from a
  second container on the same store, `startAtStep` and restart.
- `test/widget_test.dart`: the whole journey mounted at 320, 360 and 700 px, in
  light and dark (skip, next through the pages, permission allow and deny,
  interest validation, goal, finish, resume after a simulated restart), the
  reduced-motion path and large text. Cairn has repeating animations, so tests
  pump in small steps and never call `pumpAndSettle`.

`test/flutter_test_config.dart` loads Geist from the Cairn site checkout when it
can find it, so text has real metrics; without it the tests still run, in
Flutter's wider placeholder font.
