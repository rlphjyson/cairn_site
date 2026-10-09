import '../../../common/constants/text_size_steps.dart';
import '../../../common/constants/time_options.dart';
import '../models/setting_definition.dart';
import '../models/settings_link.dart';
import '../models/settings_section.dart';
import 'settings_registry.dart';

/// Ids of the settings that screens treat specially. Everything else is drawn
/// from its definition alone.
abstract final class SettingIds {
  /// Theme mode: `light`, `dark` or `system`.
  static const String themeMode = 'appearance.themeMode';

  /// Text size step, 0 to 3.
  static const String textSize = 'appearance.textSize';

  /// Accent preset: `ink`, `ocean` or `forest`.
  static const String accent = 'appearance.accent';

  /// Reduce motion switch.
  static const String reduceMotion = 'appearance.reduceMotion';

  /// The notifications master switch.
  static const String notificationsMaster = 'notifications.master';

  /// Quiet hours switch.
  static const String quietHours = 'notifications.quietHours';

  /// Quiet hours start time.
  static const String quietStart = 'notifications.quietStart';

  /// Quiet hours end time.
  static const String quietEnd = 'notifications.quietEnd';

  /// Biometric lock switch.
  static const String biometric = 'privacy.biometric';

  /// Two-factor authentication.
  static const String twoFactor = 'privacy.twoFactor';

  /// Opens the change password screen.
  static const String changePassword = 'privacy.changePassword';

  /// Opens the active sessions screen.
  static const String sessions = 'privacy.sessions';

  /// Requests a data export.
  static const String exportData = 'privacy.export';

  /// Opens the blocked users screen.
  static const String blockedUsers = 'privacy.blocked';

  /// Language choice.
  static const String language = 'language.language';

  /// Region choice.
  static const String region = 'language.region';

  /// Date format choice.
  static const String dateFormat = 'language.dateFormat';

  /// Time format choice.
  static const String timeFormat = 'language.timeFormat';

  /// Units choice.
  static const String units = 'language.units';

  /// Clear cache action.
  static const String clearCache = 'storage.clearCache';

  /// Wi-Fi only switch.
  static const String wifiOnly = 'storage.wifiOnly';

  /// Auto-delete choice.
  static const String autoDelete = 'storage.autoDelete';

  /// Edit profile (an action that opens the profile screen).
  static const String editProfile = 'profile.edit';

  /// FAQ (an action that opens the Help screen).
  static const String faq = 'help.faq';

  /// Contact support.
  static const String contact = 'help.contact';

  /// App version, tap to copy.
  static const String version = 'help.version';

  /// Third-party licences.
  static const String licences = 'about.licences';

  /// Terms of service link.
  static const String terms = 'about.terms';

  /// Privacy policy link.
  static const String privacyPolicy = 'about.privacy';

  /// Rate the app.
  static const String rate = 'about.rate';

  /// Sign out of this device.
  static const String signOut = 'danger.signOut';

  /// Deactivate the account.
  static const String deactivate = 'danger.deactivate';

  /// Delete the account.
  static const String deleteAccount = 'danger.delete';
}

/// The built-in settings. Add, remove or reorder entries here, or build your own
/// `SettingsRegistry` and pass it to `SettingsApp(registry: ...)`.
///
/// Rows appear on a category screen in the order they are listed. Consecutive
/// rows with the same `group` share a heading and a card.
final SettingsRegistry
defaultSettingsRegistry = SettingsRegistry(<SettingDefinition>[
  // Profile.
  const ActionSetting(
    id: SettingIds.editProfile,
    section: SettingsSection.profile,
    title: 'Edit profile',
    description: 'Name, username, email, bio and avatar',
    keywords: <String>[
      'name',
      'username',
      'email',
      'bio',
      'avatar',
      'photo',
      'picture',
      'account',
    ],
  ),

  // Appearance.
  const ChoiceSetting(
    id: SettingIds.themeMode,
    section: SettingsSection.appearance,
    title: 'Theme',
    description: 'Light, dark, or follow your device',
    keywords: <String>['dark mode', 'light mode', 'night', 'colour scheme'],
    style: ChoiceStyle.radio,
    initial: 'system',
    options: <ChoiceOption>[
      ChoiceOption('light', 'Light'),
      ChoiceOption('dark', 'Dark'),
      ChoiceOption('system', 'System'),
    ],
  ),
  const SliderSetting(
    id: SettingIds.textSize,
    section: SettingsSection.appearance,
    title: 'Text size',
    description: 'Makes text larger or smaller across the app',
    keywords: <String>[
      'font',
      'bigger',
      'larger',
      'smaller',
      'accessibility',
      'zoom',
    ],
    labels: TextSizeSteps.labels,
    initial: TextSizeSteps.defaultStep,
  ),
  const ChoiceSetting(
    id: SettingIds.accent,
    section: SettingsSection.appearance,
    title: 'Accent colour',
    description: 'Used for buttons, switches and highlights',
    keywords: <String>['color', 'highlight', 'tint', 'brand'],
    initial: 'ink',
    options: <ChoiceOption>[
      ChoiceOption('ink', 'Ink'),
      ChoiceOption('ocean', 'Ocean'),
      ChoiceOption('forest', 'Forest'),
    ],
  ),
  const ToggleSetting(
    id: SettingIds.reduceMotion,
    section: SettingsSection.appearance,
    title: 'Reduce motion',
    description: 'Turns off transitions and animations',
    keywords: <String>['animation', 'accessibility', 'transitions'],
  ),

  // Notifications.
  const ToggleSetting(
    id: SettingIds.notificationsMaster,
    section: SettingsSection.notifications,
    title: 'Allow notifications',
    description: 'The master switch for everything below',
    keywords: <String>['alerts', 'push', 'mute', 'silence', 'off'],
    initial: true,
  ),
  const ToggleSetting(
    id: 'notifications.messages',
    section: SettingsSection.notifications,
    title: 'Messages',
    description: 'Direct messages and replies',
    keywords: <String>['chat', 'dm', 'replies'],
    group: 'What to notify about',
    initial: true,
  ),
  const ToggleSetting(
    id: 'notifications.mentions',
    section: SettingsSection.notifications,
    title: 'Mentions',
    description: 'When someone mentions you',
    keywords: <String>['tag', 'at', 'reply'],
    group: 'What to notify about',
    initial: true,
  ),
  const ToggleSetting(
    id: 'notifications.updates',
    section: SettingsSection.notifications,
    title: 'Product updates',
    description: 'New features and improvements',
    keywords: <String>['news', 'release', 'changelog', 'features'],
    group: 'What to notify about',
    initial: true,
  ),
  const ToggleSetting(
    id: 'notifications.marketing',
    section: SettingsSection.notifications,
    title: 'Offers and tips',
    description: 'Occasional offers and suggestions',
    keywords: <String>['marketing', 'promotions', 'deals', 'newsletter'],
    group: 'What to notify about',
  ),
  const ChoiceSetting(
    id: 'notifications.channel',
    section: SettingsSection.notifications,
    title: 'Deliver by',
    description: 'Where notifications reach you',
    keywords: <String>['push', 'email', 'channel', 'delivery'],
    group: 'How',
    style: ChoiceStyle.radio,
    initial: 'push',
    options: <ChoiceOption>[
      ChoiceOption('push', 'Push'),
      ChoiceOption('email', 'Email'),
      ChoiceOption('both', 'Push and email'),
    ],
  ),
  const ChoiceSetting(
    id: 'notifications.digest',
    section: SettingsSection.notifications,
    title: 'Digest',
    description: 'How often to bundle notifications',
    keywords: <String>['summary', 'frequency', 'daily', 'weekly', 'batch'],
    group: 'How',
    style: ChoiceStyle.radio,
    initial: 'instant',
    options: <ChoiceOption>[
      ChoiceOption('instant', 'As they happen'),
      ChoiceOption('daily', 'Once a day'),
      ChoiceOption('weekly', 'Once a week'),
    ],
  ),
  const ToggleSetting(
    id: SettingIds.quietHours,
    section: SettingsSection.notifications,
    title: 'Quiet hours',
    description: 'Silence notifications on a schedule',
    keywords: <String>['do not disturb', 'dnd', 'sleep', 'night', 'schedule'],
    group: 'Quiet hours',
  ),
  ChoiceSetting(
    id: SettingIds.quietStart,
    section: SettingsSection.notifications,
    title: 'From',
    keywords: const <String>['quiet hours', 'start'],
    group: 'Quiet hours',
    initial: '22:00',
    options: <ChoiceOption>[
      for (final String t in TimeOptions.halfHours) ChoiceOption(t, t),
    ],
  ),
  ChoiceSetting(
    id: SettingIds.quietEnd,
    section: SettingsSection.notifications,
    title: 'Until',
    keywords: const <String>['quiet hours', 'end'],
    group: 'Quiet hours',
    initial: '07:00',
    options: <ChoiceOption>[
      for (final String t in TimeOptions.halfHours) ChoiceOption(t, t),
    ],
  ),

  // Privacy and security.
  const ToggleSetting(
    id: SettingIds.biometric,
    section: SettingsSection.privacy,
    title: 'Biometric lock',
    description: 'Unlock the app with your face or fingerprint',
    keywords: <String>['face id', 'fingerprint', 'touch id', 'lock', 'unlock'],
    group: 'Sign-in',
  ),
  const ToggleSetting(
    id: SettingIds.twoFactor,
    section: SettingsSection.privacy,
    title: 'Two-factor authentication',
    description: 'Ask for a code when you sign in',
    keywords: <String>['2fa', 'otp', 'authenticator', 'code', 'verification'],
    group: 'Sign-in',
  ),
  const ActionSetting(
    id: SettingIds.changePassword,
    section: SettingsSection.privacy,
    title: 'Change password',
    keywords: <String>['credentials', 'reset', 'secure'],
    group: 'Sign-in',
  ),
  const ActionSetting(
    id: SettingIds.sessions,
    section: SettingsSection.privacy,
    title: 'Active sessions',
    description: 'Devices signed in to your account',
    keywords: <String>['devices', 'logout', 'sign out', 'security'],
    group: 'Your data',
  ),
  const ActionSetting(
    id: SettingIds.exportData,
    section: SettingsSection.privacy,
    title: 'Export my data',
    description: 'Get a copy of everything we hold about you',
    keywords: <String>['download', 'gdpr', 'copy', 'archive'],
    group: 'Your data',
  ),
  const ActionSetting(
    id: SettingIds.blockedUsers,
    section: SettingsSection.privacy,
    title: 'Blocked users',
    keywords: <String>['block', 'unblock', 'mute people'],
    group: 'Your data',
  ),

  // Language and region.
  const ChoiceSetting(
    id: SettingIds.language,
    section: SettingsSection.language,
    title: 'Language',
    keywords: <String>['locale', 'translation', 'english', 'español'],
    style: ChoiceStyle.radio,
    initial: 'en',
    options: <ChoiceOption>[
      ChoiceOption('en', 'English'),
      ChoiceOption('es', 'Español'),
      ChoiceOption('fr', 'Français'),
      ChoiceOption('de', 'Deutsch'),
      ChoiceOption('pt', 'Português'),
    ],
  ),
  const ChoiceSetting(
    id: SettingIds.region,
    section: SettingsSection.language,
    title: 'Region',
    description: 'Sets currency and defaults',
    keywords: <String>['country', 'currency', 'location'],
    group: 'Formats',
    initial: 'US',
    options: <ChoiceOption>[
      ChoiceOption('US', 'United States'),
      ChoiceOption('GB', 'United Kingdom'),
      ChoiceOption('CA', 'Canada'),
      ChoiceOption('AU', 'Australia'),
      ChoiceOption('IN', 'India'),
      ChoiceOption('DE', 'Germany'),
      ChoiceOption('FR', 'France'),
      ChoiceOption('ES', 'Spain'),
      ChoiceOption('BR', 'Brazil'),
    ],
  ),
  const ChoiceSetting(
    id: SettingIds.dateFormat,
    section: SettingsSection.language,
    title: 'Date format',
    keywords: <String>['day', 'month', 'year', 'calendar'],
    group: 'Formats',
    initial: 'mdy',
    options: <ChoiceOption>[
      ChoiceOption('mdy', 'MM/DD/YYYY'),
      ChoiceOption('dmy', 'DD/MM/YYYY'),
      ChoiceOption('ymd', 'YYYY-MM-DD'),
    ],
  ),
  const ChoiceSetting(
    id: SettingIds.timeFormat,
    section: SettingsSection.language,
    title: 'Time format',
    keywords: <String>['clock', '24 hour', '12 hour', 'am', 'pm'],
    group: 'Formats',
    initial: '12h',
    options: <ChoiceOption>[
      ChoiceOption('12h', '12-hour'),
      ChoiceOption('24h', '24-hour'),
    ],
  ),
  const ChoiceSetting(
    id: SettingIds.units,
    section: SettingsSection.language,
    title: 'Units',
    keywords: <String>['metric', 'imperial', 'miles', 'kilometres', 'celsius'],
    group: 'Formats',
    initial: 'metric',
    options: <ChoiceOption>[
      ChoiceOption('metric', 'Metric'),
      ChoiceOption('imperial', 'Imperial'),
    ],
  ),

  // Storage and data.
  const ActionSetting(
    id: SettingIds.clearCache,
    section: SettingsSection.storage,
    title: 'Clear cache',
    description: 'Frees space. Nothing you saved is removed.',
    keywords: <String>['free up space', 'temporary', 'delete', 'memory'],
    group: 'Manage',
  ),
  const ToggleSetting(
    id: SettingIds.wifiOnly,
    section: SettingsSection.storage,
    title: 'Download over Wi-Fi only',
    description: 'Avoids using mobile data',
    keywords: <String>['cellular', 'data', 'mobile data', 'network'],
    group: 'Manage',
    initial: true,
  ),
  const ChoiceSetting(
    id: SettingIds.autoDelete,
    section: SettingsSection.storage,
    title: 'Auto-delete downloads',
    description: 'Remove old downloads automatically',
    keywords: <String>['cleanup', 'old', 'expire', 'space'],
    group: 'Manage',
    initial: 'never',
    options: <ChoiceOption>[
      ChoiceOption('never', 'Never'),
      ChoiceOption('30d', 'After 30 days'),
      ChoiceOption('90d', 'After 90 days'),
      ChoiceOption('1y', 'After a year'),
    ],
  ),

  // Help.
  const ActionSetting(
    id: SettingIds.faq,
    section: SettingsSection.help,
    title: 'Frequently asked questions',
    keywords: <String>['faq', 'answers', 'how to', 'guide'],
  ),
  const ActionSetting(
    id: SettingIds.contact,
    section: SettingsSection.help,
    title: 'Contact support',
    description: 'Send us a message',
    keywords: <String>['help', 'email', 'bug', 'report', 'feedback'],
  ),
  const ActionSetting(
    id: SettingIds.version,
    section: SettingsSection.help,
    title: 'App version',
    description: 'Tap to copy for a support request',
    keywords: <String>['build', 'release', 'copy'],
  ),

  // About.
  const ActionSetting(
    id: SettingIds.licences,
    section: SettingsSection.about,
    title: 'Open-source licences',
    keywords: <String>['licenses', 'third party', 'credits', 'packages'],
  ),
  const LinkSetting(
    id: SettingIds.terms,
    section: SettingsSection.about,
    title: 'Terms of service',
    keywords: <String>['legal', 'agreement', 'tos'],
    link: SettingsLink.terms,
  ),
  const LinkSetting(
    id: SettingIds.privacyPolicy,
    section: SettingsSection.about,
    title: 'Privacy policy',
    keywords: <String>['legal', 'data', 'gdpr'],
    link: SettingsLink.privacy,
  ),
  const ActionSetting(
    id: SettingIds.rate,
    section: SettingsSection.about,
    title: 'Rate the app',
    keywords: <String>['review', 'stars', 'store', 'feedback'],
  ),

  // Danger zone.
  const ActionSetting(
    id: SettingIds.signOut,
    section: SettingsSection.danger,
    title: 'Sign out',
    description: 'Sign out of this device only',
    keywords: <String>['log out', 'logout', 'leave'],
  ),
  const ActionSetting(
    id: SettingIds.deactivate,
    section: SettingsSection.danger,
    title: 'Deactivate account',
    description: 'Hide your account. You can come back any time.',
    keywords: <String>['pause', 'disable', 'hide', 'break'],
  ),
  const ActionSetting(
    id: SettingIds.deleteAccount,
    section: SettingsSection.danger,
    title: 'Delete account',
    description: 'Permanently remove your account and data',
    keywords: <String>['remove', 'erase', 'close', 'gdpr', 'forget me'],
    destructive: true,
  ),
]);
