# Auth template

Authentication screens for a mobile app, built only from
[`cairn_ui`](https://pub.dev/packages/cairn_ui): welcome, sign in, sign up,
forgot password, verify code, reset password and a signed-in placeholder. Clean
architecture with the layers at the top level and features inside each layer,
`flutter_bloc` for state and `get_it` for dependency injection.

Full documentation, with install steps, the backend contract, REST and Firebase
Auth examples, social sign-in, secure session storage, deep links and a
`go_router` recipe, is in [`doc/index.html`](doc/index.html). It is one
self-contained file: open it in a browser, offline.

The template is typographic: it ships no images, so there is nothing to credit.

## Features

- **Welcome**: the brand mark and tagline, `Continue with Google` and
  `Continue with Apple` buttons (generic glyphs, not logos; you add the
  providers' official buttons when you wire their SDKs), `Sign in with email`,
  `Create an account` and the Terms and Privacy Policy links.
- **Sign in**: email and password with a show/hide toggle, `Remember me`, a
  forgot-password link, inline validation, a loading state, an alert for wrong
  credentials, and a rate limit: after five wrong attempts the button reads
  `Try again in 29s` and counts down as plain text (finite, no looping
  animation).
- **Sign up**: name, email, a password with a strength meter
  (`CairnProgress` plus Too short, Weak, Fair or Strong) and a rules checklist
  that updates as you type, a confirmation, the terms checkbox, inline
  validation and an "already registered" error on the email field.
- **Forgot password**: email, then "Check your inbox". The answer is the same
  whether or not an account exists, so the screen cannot be used to find out who
  has one.
- **Verify code**: a six-digit `CairnInputOtp` that submits itself on the sixth
  digit, a Paste button, a wrong-code message with the attempts left, a limit of
  five wrong codes, and a resend link behind a 30 second countdown.
- **Reset password**: a new password with the same meter and checklist, a
  confirmation and a success state that returns to sign in with the email
  prefilled.
- **Signed in**: the person's avatar initials and name, a note explaining the
  `onAuthenticated` hook, and sign out.
- **Navigation**: its own back stack (a cubit driving a nested `Navigator`),
  slide-and-fade transitions built from `CairnMotion` tokens, the system back
  gesture, and forms that keep what you typed when you go back. With the
  platform's reduce-motion setting on, screens swap with no animation.
- **Responsive and accessible**: works from 320 px wide; from 700 px the content
  stays a centred 440 px column. Light and dark. Fields, buttons and stand-alone
  links have 44 px tap areas, icon buttons have labels, an error is part of its
  field's spoken name and is announced when it appears, and nothing overflows
  with large system text or the keyboard open.

## Layout

```
auth/
├── lib/
│   ├── cairn_template_auth.dart   # the barrel: exports AuthApp and its types
│   ├── auth_app.dart              # entry widget (AuthApp)
│   ├── core/
│   │   ├── infrastructure/di/     # get_it container: auth_injection.dart
│   │   └── presentation/
│   │       ├── navigation/        # the back stack (AuthNavigationCubit)
│   │       ├── widgets/           # fields, buttons, strength meter, scaffold...
│   │       ├── auth_copy.dart     # every word the screens show
│   │       ├── auth_scope.dart    # AuthScope, AuthConfig
│   │       └── view_model.dart    # ViewModel, ViewModelBuilder
│   ├── common/
│   │   ├── constants/             # policy numbers, demo account, AuthPackage
│   │   └── utils/                 # clock, ticker, attempt limiter
│   ├── data/auth/
│   │   ├── remote/                # AuthRemoteDataSource + the in-memory server
│   │   └── repositories/          # AuthRepositoryImpl
│   ├── domain/<feature>/
│   │   ├── models/                # plain business objects
│   │   ├── mappers/               # decoded JSON <-> models, error envelope
│   │   ├── repositories/          # AuthRepository
│   │   └── use_cases/             # one job each
│   └── presentation/
│       ├── <feature>/
│       │   ├── bloc/              # cubits and their states
│       │   ├── view_models/       # screen-scoped owners of cubits
│       │   ├── views/             # screens
│       │   └── widgets/           # feature-specific UI
│       └── shell/                 # providers, navigator host, transitions
├── doc/index.html                 # documentation and tutorial
└── test/                          # unit, session and widget tests
```

Domain features: `auth` and `validation`. Presentation features: `welcome`,
`sign_in`, `sign_up`, `recovery` (forgot password, verify code, reset password)
and `session`.

| Feature | Domain use cases |
| --- | --- |
| validation | `ValidateEmail`, `ValidateName`, `ValidatePassword`, `PasswordStrength`, `ValidateCode` |
| auth | `SignIn`, `SignUp`, `SignInWithProvider`, `RequestPasswordReset`, `VerifyCode`, `ResetPassword`, `SignOut` |

## Rules

1. **Dependencies point inwards.** Presentation depends on domain; data depends
   on domain; domain depends on nothing but Dart and `common`. A use case may
   depend on another feature's domain classes (`SignUp` uses the validators),
   never on the data layer.
2. **Data sources return decoded JSON** (`Map<String, Object?>`), exactly as a
   REST client would. `AuthMapper` in `domain/auth/mappers/` turns it into models
   and is the only place that knows the wire format, including the error
   envelope.
3. **Views never touch the container.** A screen that needs its cubit uses
   `ViewModelBuilder<T>`; session cubits are read with `context.read`.
4. **Two kinds of cubit.**
   - *Session cubits* (navigation, session) are lazy singletons, provided once
     by `AuthProviders` with `BlocProvider.value`. Nothing closes them but the
     container.
   - *Screen cubits* (welcome, sign in, sign up, forgot password, verify code,
     reset password) are created by a view model, which closes them in
     `dispose`. Each screen's view model is a factory that receives the
     screen's `AuthDestination`.
5. **Screens do not import each other's views.** They talk through the session
   cubits: a screen that succeeds calls `SessionCubit.start`, and
   `AuthProviders` is the one place that reacts to the session (it moves the
   navigation and calls the host's callbacks).
6. **Static data in `common/constants` and `auth_copy.dart`**, never inline in
   a view.
7. **No code generation.** Registrations are written out in
   `core/infrastructure/di/auth_injection.dart`.
8. **Only Cairn.** Widgets come from `cairn_ui` (plus Material `Icon`s for
   glyphs Cairn lacks) and colours from `CairnTheme`.
9. **No secrets in state.** A password lives in a text controller and is passed
   to a cubit method; it is never a field of a state, so it cannot be printed
   or logged by an equatable state. Tokens are left out of `Session`'s
   equality and `toString`.
10. **Time is injected.** Cubits that count down take a `TickerFactory`, the
    in-memory server takes a `Clock`, so tests never wait.

## Where to change things

| To change | Edit |
| --- | --- |
| The backend (the one place to connect a server) | write an `AuthRemoteDataSource` and pass it as `AuthApp(authDataSource: ...)` |
| Words, tone, translations | `lib/core/presentation/auth_copy.dart` |
| Brand name and tagline | `AuthCopy.brandName` and `AuthCopy.tagline` |
| The logo | `lib/core/presentation/widgets/brand_mark.dart` |
| Password length, lockout, cooldowns, code length and lifetime | `lib/common/constants/auth_policy.dart` |
| Which password rules are required | `PasswordRule` in `lib/domain/validation/models/password_assessment.dart` |
| How strength is scored | `lib/domain/validation/use_cases/password_strength.dart` |
| Email format | `lib/domain/validation/use_cases/validate_email.dart` |
| Demo user and code | `lib/common/constants/demo_account.dart` |
| Social buttons | `AuthApp(socialProviders: ..., onSocialSignIn: ...)` |
| What happens after sign-in | `AuthApp(onAuthenticated: ...)` |

## Mount it

```dart
import 'package:cairn_template_auth/cairn_template_auth.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    theme: CairnTheme.materialTheme(CairnTheme.light),
    darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
    home: Scaffold(
      body: AuthApp(
        onAuthenticated: (Session session) => debugPrint('Hello ${session.account.name}'),
        onSignedOut: () => debugPrint('Signed out'),
        showDemoHint: true, // prints the demo account on screen; remove in a real app
      ),
    ),
  ),
);
```

`AuthApp` takes whatever size it is given (320 by 640 and up). Inside a
`CairnMockupPhone` it fills the phone; on a tablet or desktop the content stays
a centred column 440 px wide. It uses your `CairnTheme`, light and dark. Try the
seeded account `ada@example.com` with `Cairn-demo-1`; the verification code is
`123456`.

Constructor:

```dart
AuthApp({
  void Function(Session session)? onAuthenticated,
  VoidCallback? onSignedOut,
  AuthRemoteDataSource? authDataSource,        // the backend; in memory by default
  AuthScreen startOn = AuthScreen.welcome,     // welcome, signIn, signUp or forgotPassword
  SocialIdTokenProvider? onSocialSignIn,       // run google_sign_in / sign_in_with_apple
  List<SocialProvider> socialProviders = const [google, apple],
  void Function(AuthLegalLink link)? onLegalLink,
  bool showDemoHint = false,
})
```

## Use it in your app

As a package, from a path or git dependency:

```yaml
dependencies:
  cairn_template_auth:
    path: ../cairn_template_auth
```

Or copy it: put `lib/` into your own app, add `cairn_ui`, `equatable`,
`flutter_bloc` and `get_it`, and rewrite the `package:cairn_template_auth/...`
imports. The template has no assets, so `AuthPackage.name` only matters if you
add images.

## Navigation

The template uses its own `AuthNavigationCubit` (a back stack of destinations)
inside a nested `Navigator`, not your app's router, so it runs unchanged inside
any app. Use `onAuthenticated` and `onSignedOut` to drive your own router, or
replace the cubit with `go_router` calls and keep the views;
`doc/index.html` shows how.

## Sessions and security

The template keeps the session in memory only. To stay signed in across
launches, store the refresh token in secure storage (Keychain, Keystore) from
`onAuthenticated` and restore it before mounting `AuthApp`; the docs have the
code. The in-memory server stores passwords in plain text because it is a
throwaway map: a real backend stores a salted hash from Argon2id, scrypt or
bcrypt and enforces its own rate limits, which the client-side cooldowns only
mirror.

## Tests

```
flutter pub get
dart format .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

- `test/domain_test.dart`: validators, strength, the attempt limiter, models,
  the mapper, every use case against a fake repository (including the lockout
  and the code limits) and the in-memory server through the real repository.
- `test/session_test.dart`: the cubits wired through the real container, with a
  fake clock and a fake ticker, and no widgets.
- `test/auth_app_test.dart`: the whole journey (sign in wrong then right, sign
  out, forgot password, verify wrong then right, reset, sign in with the new
  password, sign up, sign out) at 320, 360 and 700 px, in light and dark, plus
  focused tests for each screen, navigation, layout and accessibility. Cairn has
  repeating animations, so tests pump in small steps and never call
  `pumpAndSettle`.

`test/flutter_test_config.dart` loads Geist from `../../fonts` when it can be
found, so text is measured with the real face; without it Flutter's test font
draws every glyph as a wide box.
