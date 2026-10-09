/// The account and code the in-memory server knows about.
///
/// These exist only so the template can be tried without a backend. They are
/// used by `InMemoryAuthRemoteDataSource` and by the optional on-screen demo
/// hint (`AuthApp.showDemoHint`); delete both when you connect a real server.
abstract final class DemoAccount {
  /// The seeded user's id.
  static const String id = 'user-ada';

  /// The seeded user's display name.
  static const String name = 'Ada Lovelace';

  /// The seeded user's email address.
  static const String email = 'ada@example.com';

  /// The seeded user's password.
  static const String password = 'Cairn-demo-1';

  /// The one verification code the in-memory server accepts.
  static const String code = '123456';
}
