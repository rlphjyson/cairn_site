/// A page outside the app that a setting can open.
///
/// The template never opens a URL itself. It tells the host, which knows how
/// (a browser, an in-app web view, a router).
enum SettingsLink {
  /// The terms of service.
  terms,

  /// The privacy policy.
  privacy,
}
