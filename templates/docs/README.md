# Documentation template

A documentation site built only from `cairn_ui`: a top bar with a version
selector and a command-palette search, a collapsible sidebar that becomes a
drawer on narrow screens, an article view that renders typed content blocks,
an "On this page" rail that follows the scroll, and previous / next links. The
sample content documents a fictional "Acme SDK". Clean architecture with the
layers at the top level and features inside each layer, `flutter_bloc` for
state and `get_it` for dependency injection.

It is one package. Use it as a path or git dependency, or copy `lib/` into a
Flutter app that depends on `cairn_ui`, `flutter_bloc`, `get_it` and
`equatable`, and mount `DocsApp`. The full tutorial (install, mount, change the
content, load Markdown or a CMS, theming, `go_router` deep links, deployment) is
in [`doc/index.html`](doc/index.html): a single offline page, open it in a
browser.

## Mounting it

```dart
import 'package:cairn_template_docs/cairn_template_docs.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: const Scaffold(body: DocsApp()),
  ),
);
```

`DocsApp` fills the space its parent gives it, takes every colour from the
ambient `CairnTheme`, and brings its own toaster, so copy-to-clipboard toasts
work in any host. Optional parameters: `initialLocation` and
`onLocationChanged` (drive the URL from your router), `onOpenExternal` (open
links with `url_launcher`; the default copies the URL), and `remote` (your own
content source).

## Layout

```
docs/
├── lib/
│   ├── docs_app.dart               # entry point: DocsApp
│   ├── cairn_template_docs.dart    # barrel
│   ├── core/
│   │   ├── infrastructure/
│   │   │   └── di/                 # get_it container (explicit registration)
│   │   └── presentation/
│   │       ├── navigation/         # DocsNavigationCubit: version, page, heading
│   │       ├── widgets/            # brand mark, pressable surface
│   │       ├── docs_host.dart      # external-link handler from the host
│   │       └── view_model.dart     # ViewModel, ViewModelBuilder, DocsScope
│   ├── common/
│   │   ├── constants/              # brand, links, layout breakpoints
│   │   └── utils/                  # inline markup parser, slugify, dates
│   ├── data/
│   │   └── docs/
│   │       ├── remote/             # data source interface + in-memory content
│   │       │   └── content/        # THE CONTENT: sidebar trees and pages
│   │       └── repositories/       # implements the domain interface
│   ├── domain/
│   │   ├── docs/
│   │   │   ├── models/             # DocPage, DocBlock (sealed), DocsSite ...
│   │   │   ├── mappers/            # JSON -> models
│   │   │   ├── repositories/       # interface
│   │   │   └── use_cases/          # load, extract headings, neighbours
│   │   └── search/
│   │       ├── models/             # SearchHit
│   │       └── use_cases/          # SearchDocs
│   └── presentation/
│       ├── docs/                   # bloc, view_models, views, widgets
│       ├── search/                 # SearchCubit, command palette
│       ├── sidebar/                # SidebarCubit, page tree
│       └── shell/                  # providers, top bar, responsive frame
└── test/                           # domain, session cubits, widget tests
```

Features: `docs` (content, pages, headings, neighbours), `search`, `sidebar`.

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart (and `common`). The search
   feature's use case depends on the docs feature's models, never on its data.
2. **Views never touch the container.** A screen that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>`; session cubits are read with
   `context.read`.
3. **Two kinds of cubit.**
   - *Session cubits* (navigation, docs, search, sidebar) are lazy singletons,
     provided once by `DocsProviders` with `BlocProvider.value`. Nothing closes
     them but the container.
   - *Screen cubits* (the table-of-contents cursor) are created by a view
     model, which closes them in `dispose`.
4. **Overlays are outside the providers.** The command palette and the drawer
   are routes on the root navigator, so the widgets that open them read the
   cubits first and hand them in again.
5. **Static data in `common/constants`**, never inline in a view. The sample
   content is the exception that proves the rule: it lives in
   `data/docs/remote/content/`, because it is meant to be replaced.
6. **No code generation.** Registrations are written out in
   `core/infrastructure/di/docs_injection.dart`.

## Changing the content

Content is JSON-shaped Dart maps in `lib/data/docs/remote/content/`: a sidebar
tree per version in `docs_manifest.dart`, and pages in the `v2_*` and `v1_*`
files. A page is `{slug, title, description, updated, blocks}`, and a block is
one of `heading`, `paragraph`, `code`, `callout`, `tabs`, `steps`, `table` or
`list`. The mapper in `domain/docs/mappers/docs_mapper.dart` is the only place
that knows the format, and it fails with a message naming the page and block
when something is wrong. To load content from Markdown files or a CMS, write a
`DocsRemoteDataSource` that returns the same JSON and register it (see the
guide). Nothing else changes.

## Navigation

The template uses its own `DocsNavigationCubit`, not the host's router, so it
runs inside any app. To mirror it into the URL, pass `initialLocation` and
`onLocationChanged`; the guide shows the `go_router` version with deep links.

## Tests

```
flutter pub get
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

The widget tests mount `DocsApp` at 390, 768 and 1280 logical pixels in light
and dark. They pump in small steps and never call `pumpAndSettle`, because
Cairn has components that animate forever. If the Geist faces are found at
`../../fonts` they are loaded so layout uses real metrics; otherwise the tests
still pass with the default test font.
