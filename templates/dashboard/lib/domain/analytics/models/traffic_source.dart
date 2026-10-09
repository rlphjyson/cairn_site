import 'package:equatable/equatable.dart';

/// Where visitors came from, as a share of all sessions.
class TrafficSource extends Equatable {
  /// Creates a source.
  const TrafficSource({required this.label, required this.share});

  /// The channel.
  final String label;

  /// Percent of sessions.
  final double share;

  @override
  List<Object?> get props => <Object?>[label, share];
}
