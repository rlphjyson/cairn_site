import 'package:equatable/equatable.dart';

/// A label and where it goes.
///
/// [href] is either a section anchor (`#pricing`) or anything else the host
/// understands (a URL, a route); see `AppLandingApp.onCtaTap`.
class Link extends Equatable {
  /// Creates a link.
  const Link({required this.label, required this.href});

  /// The visible text.
  final String label;

  /// The destination.
  final String href;

  @override
  List<Object?> get props => <Object?>[label, href];
}
