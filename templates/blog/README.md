# Blog template

A blog built only from `cairn_ui`, modelled on daisyUI's blog template. A
sticky navbar with live search, a featured post, category chips, a paginated
grid of post cards, an article page rendered from content blocks, an About page
and a newsletter form. Light and dark, one to three columns, keyboard
accessible. Clean architecture by layer and then by feature, `flutter_bloc` for
state and `get_it` for dependency injection.

Full documentation, with a tutorial for changing the content, branding,
connecting a CMS, swapping the navigation for `go_router` and migrating, is in
[`doc/index.html`](doc/index.html) (one self-contained file; open it in a
browser).

## Use it

```yaml
dependencies:
  cairn_template_blog:
    path: ../templates/blog   # or a git dependency
  cairn_ui: ^0.2.0
```

```dart
import 'package:cairn_template_blog/cairn_template_blog.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: const Scaffold(body: BlogApp()),
  ),
);
```

`BlogApp` fills the space its parent gives it and adapts to that width, not the
screen's: one column under 640 logical pixels, two under 1024, then three. It
brings its own toaster, so toasts work in any host app.

### Images and the package name

The bundled photographs resolve as
`packages/cairn_template_blog/assets/images/...`, through
`BlogPackage.name` (`lib/common/constants/blog_package.dart`). If you copy
`lib/` and `assets/` into your own app instead of depending on the package, set
`BlogPackage.name` to `null` and declare `assets/images/` in your own
`pubspec.yaml`. Post covers, avatars and inline images may also be `http(s)`
URLs, which need no asset at all.

## Layout

```
lib/
├── blog_app.dart                 # entry point (the template's main.dart)
├── cairn_template_blog.dart      # barrel
├── core/
│   ├── infrastructure/di/        # get_it container
│   └── presentation/
│       ├── navigation/           # route cubit: home | post(id) | about
│       ├── widgets/              # layout, pressable, image, avatar
│       ├── blog_text.dart        # text-style helper over Cairn tokens
│       └── view_model.dart       # ViewModel, ViewModelBuilder, BlogScope
├── common/
│   ├── constants/                # brand copy, config, package name
│   └── utils/                    # date and text formatting
├── data/<feature>/
│   ├── remote/                   # data sources (in-memory stand-ins here)
│   └── repositories/             # implement the domain interfaces
├── domain/<feature>/
│   ├── models/                   # plain business objects
│   ├── mappers/                  # remote JSON -> models
│   ├── repositories/             # interfaces the domain depends on
│   └── use_cases/                # one job each
└── presentation/
    ├── <feature>/
    │   ├── bloc/                 # cubits and their states
    │   ├── view_models/          # screen-scoped owners of cubits
    │   ├── views/                # screens
    │   └── widgets/              # feature-specific UI
    └── shell/                    # providers, navbar, footer, frame
```

Features: `feed` (home), `post` (article), `authors` (About), `newsletter`.
The domain also has `posts`, `authors` and `newsletter` folders.

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart (and `common`). A feature may
   use another feature's domain interface (`authors` counts posts through
   `PostRepository`, the post repository resolves authors through
   `AuthorRepository`), never its data layer.
2. **Views never touch the container.** A screen that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>`; session cubits are read with
   `context.read`.
3. **Two kinds of cubit.**
   - *Session cubits* (navigation and the posts feed) are lazy singletons,
     provided once by `BlogProviders` with `BlocProvider.value`. Nothing closes
     them but the container. The feed is a session cubit on purpose: opening an
     article and going back returns to the same search, category and page.
   - *Screen cubits* (article, authors, each sign-up form) are created by a view
     model, which closes them in `dispose`.
4. **Features do not import each other's presentation**, with deliberate
   exceptions: the article page reuses the feed's `PostGrid` and `PostMeta`,
   and links such as "More from Marisol" drive the session `PostsFeedCubit`.
   Anything that composes features (navbar, footer, page switching) lives in
   `presentation/shell/`.
5. **Static data in `common/constants`**, never inline in a view.
6. **No code generation.** Registrations are written out in
   `core/infrastructure/di/blog_injection.dart`.

## Where to change things

| To change | Edit |
| --- | --- |
| Posts, authors, categories, tags | `lib/data/posts/remote/blog_seed.dart` (or replace the data source) |
| Brand name, headline, footer copy, link base URL | `lib/common/constants/blog_brand.dart` |
| Page size, article width, related count | `lib/common/constants/blog_config.dart` |
| Images | `assets/images/`, referenced from the seed JSON |
| Colours, radius, font | the `CairnTheme` you pass to `MaterialApp` |
| Where content comes from | `PostsRemoteDataSource`, `AuthorsRemoteDataSource`, `NewsletterRemoteDataSource` |

## Swapping the data

Each remote data source is behind an interface and returns plain decoded JSON.
To use a real backend, write a data source that calls it and pass it to
`BlogApp(postsDataSource: ...)`, or register it in `blog_injection.dart` in
place of the `InMemory` one; extend the mappers if the shape differs. Nothing
else changes. `doc/index.html` has a complete `http` example.

The in-memory newsletter service accepts any valid address, reports a repeat as
"already subscribed", and fails for addresses ending in `@error.test`, so every
state of the form can be tried.

## Navigation

The blog uses its own `BlogNavigationCubit`, not the host app's router, so the
template runs inside any app. In a real project, replace that cubit with
`go_router` or `Navigator` and keep the views; the docs show how.

## Tests

```
flutter test
```

Domain tests (use cases, mappers, validation) and cubit tests run through the
real container with no widgets. Widget tests mount `BlogApp` at 390, 768 and
1280 logical pixels and drive search, category filter, pagination, opening a
post, copying its link, going back and subscribing. If the repository's
`fonts/` folder is two levels up, `test/flutter_test_config.dart` loads Geist so
text has realistic metrics; without it the tests still pass with placeholder
metrics.

## Licence of the photographs

See [`NOTICE.md`](NOTICE.md). The photographs are from Pexels and are sample
content.
