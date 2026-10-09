import '../../../domain/settings/models/settings_section.dart';

/// A screen inside the settings: a category, or a page opened from one.
enum SettingsPage {
  /// Edit profile.
  profile('Edit profile', SettingsSection.profile),

  /// Appearance.
  appearance('Appearance', SettingsSection.appearance),

  /// Notifications.
  notifications('Notifications', SettingsSection.notifications),

  /// Privacy and security.
  privacy('Privacy and security', SettingsSection.privacy),

  /// Change password, opened from Privacy and security.
  changePassword('Change password', SettingsSection.privacy),

  /// Active sessions, opened from Privacy and security.
  sessions('Active sessions', SettingsSection.privacy),

  /// Blocked users, opened from Privacy and security.
  blockedUsers('Blocked users', SettingsSection.privacy),

  /// Language and region.
  language('Language and region', SettingsSection.language),

  /// Storage and data.
  storage('Storage and data', SettingsSection.storage),

  /// Help.
  help('Help', SettingsSection.help),

  /// About.
  about('About', SettingsSection.about),

  /// Danger zone.
  danger('Danger zone', SettingsSection.danger);

  const SettingsPage(this.title, this.section);

  /// The heading of the page.
  final String title;

  /// The category the page belongs to.
  final SettingsSection section;

  /// Whether this page is a category's own screen, as opposed to a page opened
  /// from one.
  bool get isRoot => name == section.name;

  /// The root page of [section].
  static SettingsPage of(SettingsSection section) => SettingsPage.values
      .firstWhere((SettingsPage p) => p.name == section.name);

  /// The page that shows the setting with [id] in [section]: its own page for
  /// the three that have one, otherwise the section's page.
  static SettingsPage forSetting(String id, SettingsSection section) =>
      switch (id) {
        'privacy.changePassword' => changePassword,
        'privacy.sessions' => sessions,
        'privacy.blocked' => blockedUsers,
        _ => of(section),
      };

  /// Reads a location such as `appearance` or `privacy/sessions` into the pages
  /// to show, outermost first. Unknown names are ignored.
  static List<SettingsPage> parse(String? location) {
    if (location == null || location.trim().isEmpty) return <SettingsPage>[];
    final List<SettingsPage> pages = <SettingsPage>[];
    for (final String part in location.split('/')) {
      for (final SettingsPage p in values) {
        if (p.name == part.trim()) pages.add(p);
      }
    }
    return pages;
  }
}
