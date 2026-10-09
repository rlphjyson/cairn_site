import 'package:flutter/material.dart' show ThemeMode;

import '../../../common/utils/settings_failure.dart';
import '../../../core/infrastructure/settings_hooks.dart';
import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/settings/models/notification_permission.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/use_cases/get_app_info.dart';
import '../../../domain/settings/use_cases/load_settings.dart';
import '../../../domain/settings/use_cases/update_setting.dart';
import 'settings_state.dart';

/// Every stored setting, for the whole session.
///
/// A session cubit: provided once by `SettingsProviders`, read by the theme
/// wrapper (so a change applies live), the home screen (for row values) and each
/// category screen.
class SettingsCubit extends SafeCubit<SettingsState> {
  /// Creates the cubit.
  SettingsCubit({
    required this._loadSettings,
    required this._getAppInfo,
    required this._updateSetting,
    required this._hooks,
    NotificationPermission permission = NotificationPermission.granted,
  }) : super(SettingsState(notificationPermission: permission));

  final LoadSettings _loadSettings;
  final GetAppInfo _getAppInfo;
  final UpdateSetting _updateSetting;
  final SettingsHooks _hooks;

  /// Loads the values and the app info.
  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      final SettingsSnapshot snapshot = await _loadSettings();
      emit(state.copyWith(status: LoadStatus.ready, snapshot: snapshot));
      emit(state.copyWith(appInfo: await _getAppInfo()));
    } on Object {
      emit(state.copyWith(status: LoadStatus.failure));
    }
  }

  /// The stored value of [id]'s theme mode.
  ThemeMode get themeMode =>
      switch (state.snapshot?.choice(SettingIds.themeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  /// Sets [id] to [value]: the screen updates at once, then the value is saved.
  /// If saving fails the previous value comes back and a notice is raised.
  Future<void> set(String id, Object? value) async {
    final SettingsSnapshot? before = state.snapshot;
    if (before == null) return;
    final SettingsSnapshot next;
    try {
      next = _updateSetting.apply(before, id, value);
    } on SettingsFailure catch (e) {
      emit(state.copyWith(notice: Notice(e.message, isError: true)));
      return;
    }
    if (next == before) return;
    emit(state.copyWith(snapshot: next));
    _hooks.onSettingChanged?.call(id, value);
    if (id == SettingIds.themeMode) {
      _hooks.onThemeModeChanged?.call(themeMode);
    }
    try {
      await _updateSetting.persist(next);
    } on Object {
      emit(
        state.copyWith(
          snapshot: before,
          notice: Notice('Could not save that change', isError: true),
        ),
      );
    }
  }

  /// Turns notifications on or off. Turning them on asks the platform first
  /// when permission has not been decided; a refusal leaves them off.
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled &&
        state.notificationPermission == NotificationPermission.notDetermined) {
      final Future<NotificationPermission> Function()? ask =
          _hooks.onRequestNotificationPermission;
      if (ask != null) {
        final NotificationPermission answer = await ask();
        emit(state.copyWith(notificationPermission: answer));
        if (answer != NotificationPermission.granted) return;
      }
    }
    if (enabled &&
        state.notificationPermission == NotificationPermission.denied) {
      return;
    }
    await set(SettingIds.notificationsMaster, enabled);
  }

  /// Records what the operating system now allows.
  void setNotificationPermission(NotificationPermission permission) {
    if (permission == state.notificationPermission) return;
    emit(state.copyWith(notificationPermission: permission));
  }

  /// Asks the host to open the app's page in the system settings.
  void openSystemSettings() => _hooks.onOpenSystemSettings?.call();
}
