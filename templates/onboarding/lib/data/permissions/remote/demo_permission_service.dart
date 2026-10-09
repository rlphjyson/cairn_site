import '../../../domain/permissions/models/permission_kind.dart';
import '../../../domain/permissions/models/permission_status.dart';
import '../../../domain/permissions/repositories/permission_service.dart';

/// A [PermissionService] that answers without a system prompt, for demos and
/// tests. It grants everything unless told otherwise.
///
/// ```dart
/// // The user will "decline" location and permanently decline the camera.
/// DemoPermissionService(
///   answers: {
///     PermissionKind.location: PermissionStatus.denied,
///     PermissionKind.camera: PermissionStatus.permanentlyDenied,
///   },
/// )
/// ```
class DemoPermissionService implements PermissionService {
  /// Creates the service. [answers] overrides what [request] returns for a
  /// kind; the rest are granted. [latency] simulates the system dialog.
  DemoPermissionService({
    Map<PermissionKind, PermissionStatus> answers =
        const <PermissionKind, PermissionStatus>{},
    this.latency = Duration.zero,
  }) : _answers = Map<PermissionKind, PermissionStatus>.of(answers);

  final Map<PermissionKind, PermissionStatus> _answers;

  /// How long [request] takes to answer.
  final Duration latency;

  final Map<PermissionKind, PermissionStatus> _current =
      <PermissionKind, PermissionStatus>{};

  /// How many times [openSettings] was called.
  int settingsOpened = 0;

  @override
  Future<PermissionStatus> status(PermissionKind kind) async =>
      _current[kind] ?? PermissionStatus.notDetermined;

  @override
  Future<PermissionStatus> request(PermissionKind kind) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return _current[kind] = _answers[kind] ?? PermissionStatus.granted;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}
