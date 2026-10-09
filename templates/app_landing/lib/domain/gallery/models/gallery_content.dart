import 'package:equatable/equatable.dart';

import '../../shared/models/app_screen.dart';

/// The screenshots gallery.
class GalleryContent extends Equatable {
  /// Creates the content.
  const GalleryContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.slides,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The phone frames, left to right.
  final List<GallerySlide> slides;

  @override
  List<Object?> get props => <Object?>[eyebrow, title, subtitle, slides];
}

/// One phone frame with its caption.
class GallerySlide extends Equatable {
  /// Creates a slide.
  const GallerySlide({
    required this.title,
    required this.caption,
    required this.screen,
  });

  /// The short heading.
  final String title;

  /// The caption under the phone.
  final String caption;

  /// The live phone screen.
  final AppScreen screen;

  @override
  List<Object?> get props => <Object?>[title, caption, screen];
}
