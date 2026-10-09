import 'package:equatable/equatable.dart';

/// Sessions on one kind of device.
class DeviceUsage extends Equatable {
  /// Creates a usage figure.
  const DeviceUsage({required this.label, required this.sessions});

  /// Desktop, mobile or tablet.
  final String label;

  /// Session count.
  final int sessions;

  @override
  List<Object?> get props => <Object?>[label, sessions];
}
