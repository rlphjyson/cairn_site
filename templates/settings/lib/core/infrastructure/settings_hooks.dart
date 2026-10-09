import 'package:flutter/material.dart' show ThemeMode;

import '../../domain/settings/models/notification_permission.dart';
import '../../domain/settings/models/settings_link.dart';

/// The host's callbacks, shared with the cubits.
///
/// `SettingsApp` owns one and keeps its fields current when the widget is
/// rebuilt with new callbacks, so a host never has to re-create the app to
/// change what happens on sign out.
class SettingsHooks {
  /// Creates hooks.
  SettingsHooks({
    this.onThemeModeChanged,
    this.onSettingChanged,
    this.onSignOut,
    this.onDeactivateAccount,
    this.onDeleteAccount,
    this.onLinkTap,
    this.onRateApp,
    this.onOpenSystemSettings,
    this.onRequestNotificationPermission,
  });

  /// Called when the person picks Light, Dark or System.
  void Function(ThemeMode mode)? onThemeModeChanged;

  /// Called after any stored setting changes, with its id and new value.
  void Function(String id, Object? value)? onSettingChanged;

  /// Called when the person signs out of this device.
  void Function()? onSignOut;

  /// Called after the account has been deactivated.
  void Function()? onDeactivateAccount;

  /// Called after the account has been deleted.
  void Function()? onDeleteAccount;

  /// Called when a legal link is tapped.
  void Function(SettingsLink link)? onLinkTap;

  /// Called with the stars (1 to 5) when the person rates the app.
  void Function(int stars)? onRateApp;

  /// Called when the person asks to open the system settings for this app.
  void Function()? onOpenSystemSettings;

  /// Asks the platform for notification permission and returns the answer.
  Future<NotificationPermission> Function()? onRequestNotificationPermission;
}
