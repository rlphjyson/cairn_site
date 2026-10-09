import 'package:equatable/equatable.dart';

import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/notice.dart';
import '../../../domain/settings/models/app_info.dart';
import '../../../domain/settings/models/notification_permission.dart';
import '../../../domain/settings/models/settings_snapshot.dart';

/// The stored settings, the app info and the system's notification permission.
class SettingsState extends Equatable {
  /// Creates a state.
  const SettingsState({
    this.status = LoadStatus.loading,
    this.snapshot,
    this.appInfo,
    this.notificationPermission = NotificationPermission.granted,
    this.notice,
  });

  /// Whether loading finished.
  final LoadStatus status;

  /// Every stored value. `null` until loaded.
  final SettingsSnapshot? snapshot;

  /// The app's version and licences. `null` until loaded.
  final AppInfo? appInfo;

  /// What the operating system allows.
  final NotificationPermission notificationPermission;

  /// A message to show as a toast, such as "Could not save".
  final Notice? notice;

  /// A copy with some fields changed.
  SettingsState copyWith({
    LoadStatus? status,
    SettingsSnapshot? snapshot,
    AppInfo? appInfo,
    NotificationPermission? notificationPermission,
    Notice? notice,
  }) => SettingsState(
    status: status ?? this.status,
    snapshot: snapshot ?? this.snapshot,
    appInfo: appInfo ?? this.appInfo,
    notificationPermission:
        notificationPermission ?? this.notificationPermission,
    notice: notice ?? this.notice,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    snapshot,
    appInfo,
    notificationPermission,
    notice,
  ];
}
