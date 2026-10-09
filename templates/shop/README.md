# Shop template

A mobile e-commerce app built only from [`cairn_ui`](https://pub.dev/packages/cairn_ui):
a storefront, product pages, a cart, a four-step checkout, order history and a
profile. Clean architecture with the layers at the top level and features inside
each layer, `flutter_bloc` for state and `get_it` for dependency injection.

Full documentation, with install steps, the JSON reference, a REST backend
example and a payment guide, is in [`doc/index.html`](doc/index.html). It is one
self-contained file: open it in a browser, offline.

Photographs are from [Pexels](https://www.pexels.com), used under the Pexels
licence; see [`NOTICE.md`](NOTICE.md).

## Features

- **Storefront**: greeting, cart button with a count badge, search, a swipeable
  promo carousel (three slides, no timers), category chips, a sort control
  (Popular, Price low to high, Price high to low, Top rated), a Featured row,
  New arrivals and the full grid. Skeletons while the catalogue loads and a retry
  if it fails. Filters survive opening a product.
- **Products**: Sale and New badges, struck-through original prices, ratings
  with counts, stock warnings ("Only 3 left"), several variant groups (size,
  colour...), a quantity stepper, accordion sections (Details, Shipping &
  returns, Reviews with avatars and ratings) and a "You may also like" row.
- **Cart**: lines remember their variant (the same product in two variants is
  two lines), quantity steppers, a promo code field (`CAIRN10` is 10% off),
  free-shipping progress, an order summary and suggestions when empty.
- **Checkout** (`CairnSteps`): Shipping (validated inline, Standard or Express
  delivery), Payment (card holder, number grouped in fours with a Luhn check,
  expiry `MM/YY`, CVC; clearly a demo that never leaves the device), Review (with
  edit links) and Confirmation (order number, estimated delivery, a timeline,
  Track order and Continue shopping). Going back keeps what was typed.
- **Orders and profile**: placed orders are kept (in memory) and shown with
  status badges; tapping one opens its page. The profile has an avatar header,
  stats, order history, saved addresses (taken from past orders), notification
  switches, help topics and sign out (with a "Sign in" empty state).
- **Saved**: a grid with suggestions, and a helpful empty state.
- **Responsive and accessible**: lays out from 320 px up. From 700 px wide the
  content stays a centred 480 px column. Light and dark. Icon buttons have
  semantic labels; errors are live regions.

## Layout

```
shop/
├── lib/
│   ├── cairn_template_shop.dart   # the barrel: exports ShopApp
│   ├── shop_app.dart              # entry widget (ShopApp)
│   ├── core/
│   │   ├── infrastructure/di/     # get_it container: shop_injection.dart
│   │   └── presentation/
│   │       ├── navigation/        # in-phone navigation cubit
│   │       ├── formatters/        # card number and expiry input formatters
│   │       ├── widgets/           # shared widgets (empty state, totals, ...)
│   │       └── view_model.dart    # ViewModel, ViewModelBuilder, ShopScope
│   ├── common/
│   │   ├── constants/             # categories, shipping policy, promo codes and
│   │   │                          # slides, help topics, ShopPackage
│   │   └── utils/                 # money, dates, Luhn
│   ├── data/<feature>/
│   │   ├── remote/                # data sources (in-memory stand-ins here)
│   │   └── repositories/          # implement the domain interfaces
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
│       └── shell/                 # providers, dock, tab composition
├── assets/images/                 # product photographs (Pexels)
├── doc/index.html                 # documentation and tutorial
├── test/                          # unit, session and widget tests
└── NOTICE.md                      # image credits
```

Features: `catalog`, `saved`, `cart`, `checkout`, `orders`, `profile`.

| Feature | Domain use cases |
| --- | --- |
| catalog | `GetProducts`, `GetProductById`, `FilterProducts`, `SortProducts`, `RecommendProducts` |
| saved | `GetSavedIds`, `ToggleSaved`, `GetSavedProducts` |
| cart | `GetCart`, `AddToCart`, `SetCartQuantity`, `ApplyPromoCode`, `RemovePromoCode`, `CalculateCartTotals` |
| checkout | `ValidateShippingDetails`, `ValidatePaymentDetails`, `PlaceOrder` |
| orders | `GetOrders`, `GetSavedAddresses` |
| profile | `GetAccount`, `SignIn`, `SignOut`, `GetPreferences`, `SavePreferences` |

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart and `common`. A feature's use
   case may depend on another feature's domain interface (`cart` uses
   `ProductRepository`; `PlaceOrder` uses `CartRepository` and
   `OrderRepository`), never on its data layer.
2. **Data sources return decoded JSON** (`Map<String, Object?>`), exactly as a
   REST client would. Mappers in `domain/<feature>/mappers/` turn it into models,
   and are the only place that knows the wire format.
3. **Views never touch the container.** A screen that needs a screen-scoped
   cubit uses `ViewModelBuilder<T>`; session cubits are read with
   `context.read`.
4. **Two kinds of cubit.**
   - *Session cubits* (navigation, catalogue, saved, cart, checkout, orders,
     profile) are lazy singletons, provided once by `ShopProviders` with
     `BlocProvider.value`. Nothing closes them but the container. The catalogue
     is one so the shopper's filters survive opening a product.
   - *Screen cubits* (product page, suggestions) are created by a view model,
     which closes them in `dispose`.
5. **Features do not import each other's views.** They may read each other's
   session cubits (the storefront reads the cart count, the profile reads the
   orders), and two widgets are shared on purpose: the catalogue tile uses the
   saved feature's `SaveButton`, and the saved view reuses the catalogue's
   `ProductGrid` and `SuggestedProducts`. Anything that composes two features
   (the cart tab, which shows the cart, the checkout or the confirmation) lives
   in `presentation/shell/`.
6. **Static data in `common/constants`**, never inline in a view.
7. **No code generation.** Registrations are written out in
   `core/infrastructure/di/shop_injection.dart`.
8. **Only Cairn.** Widgets come from `cairn_ui` (plus Material `Icon`s for
   glyphs Cairn lacks) and colours from `CairnTheme`.

## Where to change things

| To change | Edit |
| --- | --- |
| Products, prices, variants, reviews, stock | `lib/data/catalog/remote/product_remote_data_source.dart` (or write a real data source) |
| Categories | `lib/common/constants/product_categories.dart` |
| Promo carousel slides | `lib/common/constants/promo_slides.dart` |
| Promo codes | `lib/common/constants/promo_codes.dart` |
| Shipping rates, threshold, delivery days | `lib/common/constants/shipping_policy.dart` |
| Help topics | `lib/common/constants/help_topics.dart` |
| Demo orders and account | `lib/data/orders/remote/` and `lib/data/profile/remote/` |
| Catalogue loading delay | `ShopApp(catalogLatency: ...)` |

Each remote data source is behind an interface. To use a real backend, write a
data source that calls it and register it in `shop_injection.dart` in place of
the `InMemory` one; extend the mapper if the shape differs. Nothing else changes.
`doc/index.html` has a complete REST example.

## Mount it

```dart
import 'package:cairn_template_shop/cairn_template_shop.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: const Scaffold(body: SafeArea(child: ShopApp())),
  ),
);
```

`ShopApp` takes whatever size it is given (320 by 640 and up). Inside a
`CairnMockupPhone` it fills the phone; on a tablet or desktop it stays a centred
column 480 px wide. It does not use your router; see "Navigation".

## Use it in your app

As a package, from a path or git dependency:

```yaml
dependencies:
  cairn_template_shop:
    path: ../cairn_template_shop
```

Or copy it: put `lib/` (minus the barrel if you like) and `assets/` into your own
app, declare the assets in your `pubspec.yaml`, add `cairn_ui`, `equatable`,
`flutter_bloc` and `get_it`, and change
`ShopPackage.name = null` in `lib/common/constants/shop_package.dart` so images
resolve from your app instead of the package.

## Navigation

The shop uses its own `ShopNavigationCubit` (tabs, plus an optional product or
order page on top), not your app's router, so it runs unchanged inside any app.
To use `go_router` or `Navigator`, replace that cubit and keep the views;
`doc/index.html` shows how.

## Payments

The payment step is a demo. It validates the form, keeps only the last four
digits and never contacts a payment provider. To take real payments, replace
the step as described in `doc/index.html`; never send card numbers to your own
server.

## Tests

```
flutter pub get
dart format .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

- `test/domain_test.dart`: totals, promo codes, shipping thresholds, sorting,
  filtering, recommendations, mappers, validators (including Luhn) and the seed
  data.
- `test/session_test.dart`: the session cubits wired through the real
  container, with no widgets.
- `test/widget_test.dart`: the whole purchase journey and the screens at 320,
  360 and 700 px wide. Cairn has repeating animations, so tests pump in small
  steps and never call `pumpAndSettle`.

Flutter's test font draws every glyph as a full em square, much wider than
Geist, so `test/support/shop_harness.dart` scales text by 0.6 to keep line
lengths realistic.
