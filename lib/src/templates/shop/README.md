# E-commerce template

A sample mobile storefront built only from `cairn_ui`. Clean architecture with
the layers at the top level and features inside each layer, `flutter_bloc` for
state and `get_it` for dependency injection. It is one folder: copy it into a
Flutter app that depends on `cairn_ui`, `flutter_bloc`, `get_it` and
`equatable`, add the images under `assets/images/`, and mount `ShopApp`.

Photographs are from [Pexels](https://www.pexels.com), used under the Pexels
licence.

## Layout

```
shop/
├── shop_app.dart               # entry point (the template's main.dart)
├── core/
│   ├── infrastructure/
│   │   └── di/                 # get_it container
│   └── presentation/
│       ├── navigation/         # in-phone navigation cubit
│       ├── widgets/            # shared widgets
│       └── view_model.dart     # ViewModel, ViewModelBuilder, ShopScope
├── common/
│   ├── constants/              # categories, shipping policy
│   └── utils/                  # money formatting
├── data/
│   └── <feature>/
│       ├── remote/             # data sources (in-memory stand-ins here)
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
    │   ├── views/              # screens
    │   └── widgets/            # feature-specific UI
    └── shell/                  # providers, dock, tab composition
```

Features: `catalog`, `saved`, `cart`, `checkout`, `profile`.

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart (and `common`). A feature's
   use case may depend on another feature's domain interface (`cart` uses
   `ProductRepository`), never on its data layer.
2. **Views never touch the container.** A screen that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>`; session cubits are read with
   `context.read`.
3. **Two kinds of cubit.**
   - *Session cubits* (navigation, saved, cart, checkout, profile) are lazy
     singletons, provided once by `ShopProviders` with `BlocProvider.value`.
     Nothing closes them but the container.
   - *Screen cubits* (catalogue, product page) are created by a view model,
     which closes them in `dispose`.
4. **Features do not import each other's presentation**, with two deliberate
   exceptions: the catalogue's tile uses the saved feature's `SaveButton`, and
   the saved view reuses the catalogue's `ProductGrid`. Anything that composes
   two features (the cart tab, which shows either the cart or the order
   confirmation) lives in `presentation/shell/`.
5. **Static data in `common/constants`**, never inline in a view.
6. **No code generation.** Registrations are written out in
   `core/infrastructure/di/shop_injection.dart`.

## Swapping the data

Each remote data source is behind an interface and returns plain decoded JSON.
To use a real backend, write a data source that calls it and register it in
`shop_injection.dart` in place of the `InMemory` one; extend the mapper if the
shape differs. Nothing else changes.

## Navigation

The phone uses its own `ShopNavigationCubit`, not the host app's router, so the
template runs inside any app. In a real project, replace that cubit with
`go_router` or `Navigator` and keep the views.

## Screenshots

The images on the site's Templates page come from
`CAPTURE_SCREENSHOTS=1 flutter test test/capture_template_screenshots_test.dart`.
