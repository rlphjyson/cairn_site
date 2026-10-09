# App landing page template

A one-page landing site for a mobile app, built only from
[`cairn_ui`](https://pub.dev/packages/cairn_ui). A hero with two live phone
mockups and store buttons, a tabbed feature showcase, a screenshots carousel,
reviews with a rating breakdown, pricing, an FAQ and a get-the-app section with
a send-me-the-link form and a QR card. Clean architecture with the layers at the
top level and features inside each layer, `flutter_bloc` for state and `get_it`
for dependency injection.

The app it sells is made up: **Ember**, a friendly habit coach. Its name,
tagline, store links, every word of copy, the numbers, the reviews and even the
screens drawn inside the phones live in one JSON document, so re-pointing the
page at your own app is a content edit.

Full documentation, with install steps, the JSON reference, SMS and email
examples, smart app banners, attribution links and SEO notes, is in
[`doc/index.html`](doc/index.html). It is one self-contained file: open it in a
browser, offline.

Photographs are from [Pexels](https://www.pexels.com), used under the Pexels
licence; see [`NOTICE.md`](NOTICE.md).

## Sections

One scroll, one sticky navbar. Its links smooth-scroll to the sections, the one
in view is highlighted, and below 1000 px the links move into a menu sheet.

| Id | Section | Feature folder | Cairn components |
| --- | --- | --- | --- |
| `hero` | Headline, App Store and Google Play buttons, rating line, two overlapping phones | `hero` | `CairnMockupPhone`, `CairnButton`, `CairnBadge`, `CairnRating`, `CairnAvatarGroup` |
| `trust` | Press wordmarks (text, no real logos) and award badges | `trust` | `CairnBadge`-style cards |
| `features` | Four tabs, each switching the phone screen beside the copy | `features` | `CairnTabs`, `CairnMockupPhone` |
| `how-it-works` | Three numbered steps | `how_it_works` | `CairnCard` |
| `gallery` | Five phone frames in a carousel with captions | `gallery` | `CairnCarousel` |
| `stats` | A photo and four figures | `stats` | `CairnStats`, `CairnStat` |
| `reviews` | Rating summary with a bar per star count and review cards, "Write a review" toast | `reviews` | `CairnCard`, `CairnRating`, `CairnProgress`, `CairnAvatar`, `CairnToast` |
| `pricing` | Free and Premium, monthly/yearly switch | `pricing` | `CairnCard`, `CairnSwitch`, `CairnBadge` |
| `faq` | Six questions | `faq` | `CairnAccordion` |
| `download` | Send-me-the-link form, QR card, store buttons | `download` | `CairnInput`, `CairnButton`, `CairnSpinner`, `CairnToast` |
| `footer` | Link columns, social icons, legal links | `footer` | `CairnLink`, `CairnSeparator` |

The phone screens (today, progress, calendar, settings, goals) are drawn live
from `CairnDock`, `CairnRadialProgress`, `CairnProgress`, `CairnSwitch`,
`CairnAvatar`, `CairnBadge` and `CairnButton`. They are not screenshots, and
they take no pointer or keyboard input; screen readers get a one-sentence
description of each instead of the widgets.

## Mounting it

```dart
import 'package:cairn_template_app_landing/cairn_template_app_landing.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: Scaffold(
      body: AppLandingApp(
        onStoreTap: (StoreKind store, String href) => debugPrint('$store $href'),
        onCtaTap: (String href) => debugPrint('open $href'),
      ),
    ),
  ),
);
```

`AppLandingApp` fills the space it is given, adapts to that width (not the
screen's), creates its own container and disposes it. Every parameter is
optional:

| Parameter | What it does |
| --- | --- |
| `contentDataSource` | Where the copy comes from (`AppContentDataSource`); defaults to the in-memory demo |
| `linkService` | Sends the download link by SMS or email (`DownloadLinkService`); defaults to a stand-in |
| `onStoreTap` | Called with the `StoreKind` and the listing URL when a store button is pressed |
| `onCtaTap` | Called with the `href` of every other link that is not a `#` anchor |
| `initialSection` | Scroll to a section id shortly after the first build, for deep links |
| `onSectionChanged` | Told when the section at the top of the viewport changes |
| `overrides` | Swap any other registration in the container before the page builds |

As a package it needs `cairn_ui`, `equatable`, `flutter_bloc` and `get_it`. To
copy it into an app instead, copy `lib/` and `assets/images/`, declare the
assets in your pubspec and set `AppLandingPackage.name` to `null` in
`lib/common/constants/app_landing_package.dart`.

## Layout

```
app_landing/
├── lib/
│   ├── cairn_template_app_landing.dart  # barrel: AppLandingApp and the interfaces
│   ├── app_landing_app.dart             # entry widget (the template's main.dart)
│   ├── core/
│   │   ├── infrastructure/
│   │   │   └── di/                      # get_it container
│   │   └── presentation/
│   │       ├── navigation/              # scroll navigation cubit
│   │       ├── mock/                    # live phone screens (MockPhone, AppScreenView)
│   │       ├── widgets/                 # SectionFrame, SectionHeader, grids, Reveal, store buttons
│   │       ├── content_cubit.dart       # one cubit + view model for content sections
│   │       ├── layout.dart              # breakpoints, AppLandingViewport
│   │       └── view_model.dart          # ViewModel, ViewModelBuilder, AppLandingScope
│   ├── common/
│   │   ├── constants/                   # section ids, content keys, asset package
│   │   └── utils/                       # JSON reader, price, count and date formatting
│   ├── data/
│   │   ├── content/remote/              # AppContentDataSource + the demo JSON
│   │   ├── download/remote/             # DownloadLinkService + in-memory stand-in
│   │   └── <feature>/repositories/      # implement the domain interfaces
│   ├── domain/
│   │   └── <feature>/
│   │       ├── models/                  # plain business objects
│   │       ├── mappers/                 # JSON -> models
│   │       ├── repositories/            # interfaces the domain depends on
│   │       └── use_cases/               # one job each
│   └── presentation/
│       ├── <feature>/
│       │   ├── bloc/                    # cubits and their states
│       │   ├── view_models/             # screen-scoped owners of cubits
│       │   ├── views/                   # sections
│       │   └── widgets/                 # feature-specific UI
│       └── shell/                       # providers, navbar, scroll frame, page order
├── assets/images/                       # Pexels photographs
├── doc/index.html                       # the tutorial
└── test/                                # domain, session and widget tests
```

Features: `site`, `hero`, `trust`, `features`, `how_it_works`, `gallery`,
`stats`, `reviews`, `pricing`, `faq`, `download`, `footer`.

Use cases: `GetSiteInfo`, `GetHero`, `GetTrust`, `GetFeatures`, `GetHowItWorks`,
`GetGallery`, `GetStats`, `GetReviews` (newest first, with `RatingDistribution`
deriving the total, average and bar shares), `GetPricing`, `CalculatePrice`
(monthly and yearly discount), `GetFaq`, `GetDownload`, `ValidateContact` (an
email or a phone number), `SendDownloadLink`, `BuildQrPattern` and `GetFooter`.

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart (and `common`).
2. **Views never touch the container.** A section that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>` (content sections go through
   `ContentView<T>`, which wraps it); session cubits are read with
   `context.read`.
3. **Two kinds of cubit.**
   - *Session cubits* (navigation, the site info shared by the navbar, hero,
     download section and footer) are lazy singletons, provided once by
     `AppLandingProviders` with `BlocProvider.value`. Nothing closes them but
     the container.
   - *Screen cubits* (every section, the feature tabs, the gallery, the pricing
     toggle, the send-link form) are created by a view model, which closes them
     in `dispose`.
4. **Content-only sections share one generic cubit.** `ContentCubit<T>` loads a
   use case's result; sections with behaviour (`features`, `gallery`,
   `pricing`, `download`) have their own cubits.
5. **Features do not import each other's presentation.** Shared pieces (the
   phone screens, the store buttons) live in `core/presentation`.
6. **No code generation.** Registrations are written out in
   `core/infrastructure/di/app_landing_injection.dart`.
7. **Only Cairn components and tokens.** No hard-coded colours, except the
   gradient and caption over a photograph.

## Changing the content

Every section's copy is a JSON-shaped map in
`lib/data/content/remote/app_content_json.dart`, served through
`AppContentDataSource` and turned into models by the mappers in
`lib/domain/<feature>/mappers/`. A missing or mistyped key throws a
`FormatException` that names it.

| To change | Edit |
| --- | --- |
| App name, tagline, navbar links, the navbar button, **store labels and URLs** | the `_site` map in `app_content_json.dart` |
| Headline, subcopy, badge, rating line, the two hero screens | `_hero` |
| Press mentions and awards | `_trust` |
| Feature tabs, their copy and their phone screens | `_features` |
| The three steps | `_howItWorks` |
| Screenshot captions and screens | `_gallery` |
| Numbers and the photo beside them | `_stats` |
| Rating counts (total, average and bars are derived) and reviews | `_reviews` |
| Plans, prices, yearly discount, buttons | `_pricing` |
| Questions and answers | `_faq` |
| Form copy and the QR card | `_download` |
| Footer columns, social icons, legal links | `_footer` |
| The mock phone screens | `_todayScreen`, `_progressScreen`, `_calendarScreen`, `_settingsScreen`, `_goalsScreen` |
| Section order | `presentation/shell/app_landing_page.dart` and `common/constants/section_ids.dart` |
| Icon names usable in content | `core/presentation/app_landing_icons.dart` |

## Swapping the data

`AppContentDataSource.fetchSection(String section)` returns plain decoded JSON
for one of the `ContentSections` keys. To use a CMS or your own API, implement
it and pass it in; nothing else changes:

```dart
AppLandingApp(contentDataSource: MyCmsContent(), linkService: MyLinks());
```

`DownloadLinkService.send(Contact)` is the one method to implement for the
send-me-the-link form (SMS or email). It throws a `DownloadLinkException` with a
message for the visitor when the message cannot be sent.

## The demo QR

The QR card draws a deterministic QR-looking pattern (`BuildQrPattern`,
painted by `QrPainter`) and labels itself as a demo. **It does not scan.**
Replace it with a real code before launch; the docs show how.

## Navigation

The page uses its own `AppLandingNavigationCubit` and scroll controller rather
than the host app's router, so it runs inside any app. The cubit holds intent
(`goTo`, `activate`); `AppLandingShell` performs the scroll and reports the
active section back. In an app with `go_router`, see the docs.

## Tests

```
flutter test
```

Domain tests (pricing, rating maths, contact validation, the send use case, the
QR pattern, mappers), session tests that run the cubits through the real
container, and widget tests that mount `AppLandingApp` at 390, 768 and 1280 px,
in light and dark, and drive navigation, the feature tabs, the carousel, the
pricing toggle, the FAQ, the send-me-the-link form (invalid, valid, refused),
the phone menu, the host callbacks and reduced motion. `test/flutter_test_config.dart`
loads the Geist font from the repository's `fonts/` folder when it is
reachable, so text metrics match a device; outside the repo it falls back to
Flutter's test font, which is wider and can overflow the narrow layouts. Outside
the repo, point the path in `test/flutter_test_config.dart` at your own copy of
the Geist files.
