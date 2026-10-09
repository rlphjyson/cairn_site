import 'package:equatable/equatable.dart';

/// One page of the welcome carousel.
class ValuePage extends Equatable {
  /// Creates a page.
  const ValuePage({
    required this.id,
    required this.title,
    required this.body,
    required this.asset,
    required this.imageLabel,
  });

  /// Stable identifier.
  final String id;

  /// The headline.
  final String title;

  /// The supporting text.
  final String body;

  /// The bundled image, such as `assets/images/welcome-morning.jpg`.
  final String asset;

  /// What the photograph shows, read by screen readers.
  final String imageLabel;

  @override
  List<Object?> get props => <Object?>[id, title, body, asset, imageLabel];
}
