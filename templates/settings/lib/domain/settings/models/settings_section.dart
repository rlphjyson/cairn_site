/// A category of settings: one screen, one row on the home screen.
enum SettingsSection {
  /// The signed-in person's name, username, email, bio and avatar.
  profile('Edit profile', 'Name, username, email and avatar'),

  /// Theme, text size, accent colour and motion.
  appearance('Appearance', 'Theme, text size and colour'),

  /// What the app may notify about, and when.
  notifications('Notifications', 'Alerts, channels and quiet hours'),

  /// Locks, passwords, sessions and your data.
  privacy('Privacy and security', 'Lock, password, sessions and data'),

  /// Language, region and formats.
  language('Language and region', 'Language, dates, time and units'),

  /// What the app stores on the device.
  storage('Storage and data', 'Usage, cache and downloads'),

  /// Answers and a way to reach support.
  help('Help', 'Questions and contact'),

  /// Version, licences and legal links.
  about('About', 'Version, licences and legal'),

  /// Sign out, deactivate or delete.
  danger('Danger zone', 'Sign out, deactivate or delete');

  const SettingsSection(this.title, this.summary);

  /// The heading of the screen, and the row's title.
  final String title;

  /// One line under the row's title on the home screen.
  final String summary;

  /// The section named [id] (the enum name), or `null`.
  static SettingsSection? fromId(String? id) {
    for (final SettingsSection s in values) {
      if (s.name == id) return s;
    }
    return null;
  }
}
