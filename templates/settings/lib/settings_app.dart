import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/settings_injection.dart';
import 'core/infrastructure/settings_hooks.dart';
import 'core/presentation/navigation/settings_page.dart';
import 'core/presentation/view_model.dart';
import 'data/settings/remote/settings_data_source.dart';
import 'domain/profile/models/profile.dart';
import 'domain/settings/models/notification_permission.dart';
import 'domain/settings/models/settings_link.dart';
import 'domain/settings/registry/settings_registry.dart';
import 'presentation/profile/bloc/profile_cubit.dart';
import 'presentation/settings/bloc/settings_cubit.dart';
import 'presentation/shell/settings_providers.dart';
import 'presentation/shell/settings_shell.dart';
import 'presentation/shell/settings_theme_scope.dart';

/// Mobile settings screens, built only from `cairn_ui` and Cairn tokens.
///
/// A searchable home with a profile card and grouped categories, and a screen
/// for each: Edit profile, Appearance, Notifications, Privacy and security,
/// Language and region, Storage and data, Help, About and the Danger zone. From
/// 600 px wide it becomes a two-pane master/detail layout.
///
/// Everything a host needs to change is injected, so the template never has to
/// be forked:
///
/// * [settingsDataSource] supplies and stores everything (settings, profile,
///   sessions, storage...). The default keeps it in memory;
/// * [registry] lists the settings, so a host can add, remove or reorder them;
/// * [profile] is the signed-in person, when the host already has it;
/// * [onThemeModeChanged], [onSettingChanged], [onSignOut],
///   [onDeactivateAccount], [onDeleteAccount], [onLinkTap], [onRateApp],
///   [onOpenSystemSettings] and [onRequestNotificationPermission] tell the host
///   what the person did.
///
/// The template applies the person's appearance choices to itself (theme mode,
/// text size, accent and reduce motion) by wrapping its content in its own
/// `Theme` and `MediaQuery`, so the Appearance screen is a live preview without
/// any wiring. A host that wants the rest of its app to follow listens to
/// [onThemeModeChanged] and [onSettingChanged]; see `doc/index.html`.
class SettingsApp extends StatefulWidget {
  /// Creates the app.
  const SettingsApp({
    super.key,
    this.settingsDataSource,
    this.registry,
    this.profile,
    this.onThemeModeChanged,
    this.onSettingChanged,
    this.onSignOut,
    this.onDeactivateAccount,
    this.onDeleteAccount,
    this.onLinkTap,
    this.onRateApp,
    this.onOpenSystemSettings,
    this.onRequestNotificationPermission,
    this.notificationPermission = NotificationPermission.granted,
    this.initialLocation,
  });

  /// Where everything is read from and written to. Defaults to an in-memory
  /// `InMemorySettingsDataSource`, which forgets everything when the app closes;
  /// pass your own to persist and sync.
  final SettingsDataSource? settingsDataSource;

  /// The settings the app has. Defaults to `defaultSettingsRegistry`.
  final SettingsRegistry? registry;

  /// The signed-in person. When given it is shown at once and the data source
  /// is not asked for it; saving still goes through the data source. When
  /// omitted it is loaded from the data source.
  final Profile? profile;

  /// Called when the person picks Light, Dark or System.
  final void Function(ThemeMode mode)? onThemeModeChanged;

  /// Called after any stored setting changes, with its id and new value.
  final void Function(String id, Object? value)? onSettingChanged;

  /// Called when the person signs out of this device.
  final VoidCallback? onSignOut;

  /// Called after the account has been deactivated.
  final VoidCallback? onDeactivateAccount;

  /// Called after the account has been deleted.
  final VoidCallback? onDeleteAccount;

  /// Called when the Terms of service or Privacy policy row is tapped. The
  /// template never opens URLs itself.
  final void Function(SettingsLink link)? onLinkTap;

  /// Called with the stars (1 to 5) when the person rates the app.
  final void Function(int stars)? onRateApp;

  /// Called when the person asks to open this app's page in the system
  /// settings, from the "Notifications are blocked" alert.
  final VoidCallback? onOpenSystemSettings;

  /// Asks the platform for notification permission, when the person turns
  /// notifications on while it has not been decided. Returns the answer.
  final Future<NotificationPermission> Function()?
  onRequestNotificationPermission;

  /// What the operating system allows. Read again whenever it changes.
  final NotificationPermission notificationPermission;

  /// Opens the settings on a page: a category name such as `appearance`, or a
  /// path such as `privacy/sessions`. See `SettingsPage`. It is read once, when
  /// the app is first built.
  final String? initialLocation;

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  late final SettingsHooks _hooks = SettingsHooks();

  late final GetIt _locator = createSettingsLocator(
    settingsDataSource: widget.settingsDataSource,
    registry: widget.registry,
    profile: widget.profile,
    notificationPermission: widget.notificationPermission,
    initialPages: SettingsPage.parse(widget.initialLocation),
    hooks: _hooks,
  );

  void _syncHooks() {
    // The callbacks may change between builds without restarting the app.
    _hooks
      ..onThemeModeChanged = widget.onThemeModeChanged
      ..onSettingChanged = widget.onSettingChanged
      ..onSignOut = widget.onSignOut
      ..onDeactivateAccount = widget.onDeactivateAccount
      ..onDeleteAccount = widget.onDeleteAccount
      ..onLinkTap = widget.onLinkTap
      ..onRateApp = widget.onRateApp
      ..onOpenSystemSettings = widget.onOpenSystemSettings
      ..onRequestNotificationPermission =
          widget.onRequestNotificationPermission;
  }

  @override
  void initState() {
    super.initState();
    _syncHooks();
    unawaited(_locator<SettingsCubit>().load());
    unawaited(_locator<ProfileCubit>().load());
  }

  @override
  void didUpdateWidget(SettingsApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncHooks();
    if (oldWidget.notificationPermission != widget.notificationPermission) {
      _locator<SettingsCubit>().setNotificationPermission(
        widget.notificationPermission,
      );
    }
  }

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsScope(
    locator: _locator,
    child: SettingsProviders(
      locator: _locator,
      child: SettingsThemeScope(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) => CairnToaster(
            alignment: Alignment.topCenter,
            width: (box.maxWidth - 32).clamp(200.0, 356.0),
            child: const SettingsShell(),
          ),
        ),
      ),
    ),
  );
}
