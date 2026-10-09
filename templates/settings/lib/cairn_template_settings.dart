/// The settings template.
library;

export 'core/presentation/navigation/settings_page.dart' show SettingsPage;
export 'data/settings/remote/in_memory_settings_data_source.dart'
    show InMemorySettingsDataSource;
export 'data/settings/remote/settings_data_source.dart' show SettingsDataSource;
export 'domain/profile/models/profile.dart' show Profile;
export 'domain/settings/models/notification_permission.dart'
    show NotificationPermission;
export 'domain/settings/models/setting_definition.dart'
    show
        ActionSetting,
        ChoiceOption,
        ChoiceSetting,
        ChoiceStyle,
        LinkSetting,
        SettingDefinition,
        SettingKind,
        SliderSetting,
        ToggleSetting;
export 'domain/settings/models/settings_link.dart' show SettingsLink;
export 'domain/settings/models/settings_section.dart' show SettingsSection;
export 'domain/settings/registry/default_settings_registry.dart'
    show SettingIds, defaultSettingsRegistry;
export 'domain/settings/registry/settings_registry.dart' show SettingsRegistry;
export 'settings_app.dart' show SettingsApp;
