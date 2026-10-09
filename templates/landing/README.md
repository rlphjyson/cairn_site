# SaaS landing page template

A one-page SaaS landing site built only from `cairn_ui`, modelled on daisyUI's
SaaS landing page template. Clean architecture with the layers at the top level
and features inside each layer, `flutter_bloc` for state and `get_it` for
dependency injection. The product is a made-up project planner called
**Kestrel**; every word, number, link and image reference lives in JSON-shaped
data, so rebranding is a content edit.

Open `doc/index.html` in a browser for the full documentation and tutorial
(works offline, light and dark).

Photographs are from [Pexels](https://www.pexels.com), used under the Pexels
licence; see `NOTICE.md`.

## Sections

One scroll, one sticky navbar. Its links smooth-scroll to the sections, the one
in view is highlighted, and below 1000 px the links move into a menu sheet.

| Id | Section | Feature folder |
| --- | --- | --- |
| `hero` | Headline, calls to action, avatar stack and rating, product mockup | `hero` |
| `logos` | Trusted-by wordmarks (text, no real logos) | `logos` |
| `features` | Bento grid of six cards and three image spotlights | `features` |
| `how-it-works` | Numbered steps | `how_it_works` |
| `stats` | Four numbers in a `CairnStats` band | `stats` |
| `testimonials` | Six quotes with portraits and ratings | `testimonials` |
| `pricing` | Monthly/yearly switch, three plans | `pricing` |
| `faq` | `CairnAccordion` | `faq` |
| `waitlist` | Email form with validation, states and a toast | `waitlist` |
| `footer` | Link columns, social icons, legal links | `footer` |

The navbar and the footer share the brand through the `site` feature.

## Mounting it

```dart
import 'package:cairn_template_landing/cairn_template_landing.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: Scaffold(
      body: LandingApp(onLink: (String href) => debugPrint('open $href')),
    ),
  ),
);
```

`LandingApp` fills the space it is given, adapts to that width (not the
screen's), creates its own container and disposes it. Links in the content that
start with `#` scroll to a section; every other link goes to `onLink`.

Other parameters: `initialSection` (scroll to a section id shortly after the
first build, for deep links), `onSectionChanged` (told when the visible section
changes) and `overrides` (swap any registration, such as a data source, before
the page builds):

```dart
LandingApp(
  overrides: (GetIt locator) => locator
    ..unregister<WaitlistRemoteDataSource>()
    ..registerLazySingleton<WaitlistRemoteDataSource>(MyWaitlist.new),
)
```

As a package it needs `cairn_ui`, `equatable`, `flutter_bloc` and `get_it`. To
copy it into an app instead, copy `lib/` and `assets/images/`, declare the
assets in your pubspec and set `LandingPackage.name` to `null` in
`lib/common/constants/landing_package.dart`.

## Layout

```
landing/
├── landing_app.dart            # entry point (the template's main.dart)
├── core/
│   ├── infrastructure/
│   │   └── di/                 # get_it container
│   └── presentation/
│       ├── navigation/         # scroll navigation cubit
│       ├── widgets/            # SectionFrame, SectionHeader, grids, Reveal
│       ├── content_cubit.dart  # one cubit + view model for content sections
│       ├── layout.dart         # breakpoints, LandingViewport
│       └── view_model.dart     # ViewModel, ViewModelBuilder, LandingScope
├── common/
│   ├── constants/              # section ids, asset package
│   └── utils/                  # JSON reader, price formatting
├── data/
│   └── <feature>/
│       ├── remote/             # data sources (in-memory content lives here)
│       └── repositories/       # implement the domain interfaces
├── domain/
│   └── <feature>/
│       ├── models/             # plain business objects
│       ├── mappers/            # remote JSON -> models
│       ├── repositories/       # interfaces the domain depends on
│       └── use_cases/          # one job each
└── presentation/
    ├── <feature>/
    │   ├── bloc/               # cubits and their states
    │   ├── view_models/        # screen-scoped owners of cubits
    │   ├── views/              # sections
    │   └── widgets/            # feature-specific UI
    └── shell/                  # providers, navbar, scroll frame, page order
```

Features: `site`, `hero`, `logos`, `features`, `how_it_works`, `stats`,
`testimonials`, `pricing`, `faq`, `waitlist`, `footer`.

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart (and `common`).
2. **Views never touch the container.** A section that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>` (content sections go through
   `ContentView<T>`, which wraps it); session cubits are read with
   `context.read`.
3. **Two kinds of cubit.**
   - *Session cubits* (navigation, site info) are lazy singletons, provided
     once by `LandingProviders` with `BlocProvider.value`. Nothing closes them
     but the container.
   - *Screen cubits* (every section, the pricing toggle, the waitlist form)
     are created by a view model, which closes them in `dispose`.
4. **Content-only sections share one generic cubit.** `ContentCubit<T>` loads a
   use case's result; sections with behaviour (`pricing`, `waitlist`) have
   their own cubits.
5. **Features do not import each other's presentation.** The navbar and footer
   read the brand from the session `ContentCubit<SiteInfo>`.
6. **No code generation.** Registrations are written out in
   `core/infrastructure/di/landing_injection.dart`.

## Changing the content

Each section's copy is a JSON-shaped map in
`lib/data/<feature>/remote/<feature>_remote_data_source.dart`, read by an
`InMemory...` data source and turned into models by the mappers in
`lib/domain/<feature>/mappers/`. A missing or mistyped key throws a
`FormatException` that names it.

| To change | Edit |
| --- | --- |
| Brand name, tagline, navbar links, sign-in and main button | `data/site/remote/site_remote_data_source.dart` |
| Headline, buttons, social proof, the dashboard in the mockup | `data/hero/remote/hero_remote_data_source.dart` |
| Company wordmarks | `data/logos/remote/logos_remote_data_source.dart` |
| Feature cards and spotlights (copy and images) | `data/features/remote/features_remote_data_source.dart` |
| Steps | `data/how_it_works/remote/how_it_works_remote_data_source.dart` |
| Numbers | `data/stats/remote/stats_remote_data_source.dart` |
| Testimonials and portraits | `data/testimonials/remote/testimonials_remote_data_source.dart` |
| Plans, prices, yearly discount, buttons | `data/pricing/remote/pricing_remote_data_source.dart` |
| Questions and answers | `data/faq/remote/faq_remote_data_source.dart` |
| Waitlist copy (and the stand-in signup service) | `data/waitlist/remote/waitlist_remote_data_source.dart` |
| Footer columns, social icons, legal links | `data/footer/remote/footer_remote_data_source.dart` |
| Section order | `presentation/shell/landing_page.dart` and `common/constants/section_ids.dart` |
| Icon names usable in content | `core/presentation/landing_icons.dart` |

## Swapping the data

Each remote data source is behind an interface and returns plain decoded JSON.
To use a real backend or CMS, write a data source that calls it and register it
in `landing_injection.dart` in place of the `InMemory` one; extend the mapper
if the shape differs. Nothing else changes. The waitlist is the main example:
`WaitlistRemoteDataSource.submit` is the one method to implement.

## Navigation

The page uses its own `LandingNavigationCubit` and scroll controller rather
than the host app's router, so it runs inside any app. The cubit holds intent
(`goTo`, `activate`); `LandingShell` performs the scroll and reports the active
section back. In an app with `go_router`, keep the sections and drive them from
the route (see the docs).

## Tests

```
flutter test
```

Domain tests (pricing, email validation, mappers, the signup use case), session
tests that run the cubits through the real container, and widget tests that
mount `LandingApp` at 390, 768 and 1280 px and drive navigation, the pricing
toggle, the FAQ, the waitlist and the phone menu. The widget tests load the
Geist font from the repository's `fonts/` folder when it is reachable, so text
metrics match a device; outside the repo they fall back to Flutter's test font,
which is wider and can overflow the narrow layouts; copy the fonts to `test/fonts/` to avoid that.
