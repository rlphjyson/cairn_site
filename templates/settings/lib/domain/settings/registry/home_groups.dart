import '../models/settings_section.dart';

/// How the home screen groups the categories under headings.
///
/// A section that has no definitions in the registry is skipped, and so is a
/// group left with no sections.
abstract final class HomeGroups {
  /// A heading and the sections under it, in order.
  static const List<({String title, List<SettingsSection> sections})> all =
      <({String title, List<SettingsSection> sections})>[
        (
          title: 'Account',
          sections: <SettingsSection>[
            SettingsSection.profile,
            SettingsSection.privacy,
          ],
        ),
        (
          title: 'Preferences',
          sections: <SettingsSection>[
            SettingsSection.appearance,
            SettingsSection.notifications,
            SettingsSection.language,
          ],
        ),
        (
          title: 'Data and support',
          sections: <SettingsSection>[
            SettingsSection.storage,
            SettingsSection.help,
            SettingsSection.about,
          ],
        ),
        (title: 'Session', sections: <SettingsSection>[SettingsSection.danger]),
      ];
}
