import 'package:equatable/equatable.dart';

/// The copy of the get-the-app section.
class DownloadContent extends Equatable {
  /// Creates the content.
  const DownloadContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.formTitle,
    required this.placeholder,
    required this.buttonLabel,
    required this.privacyNote,
    required this.successTitle,
    required this.successMessage,
    required this.storesHeading,
    required this.qr,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The heading above the form.
  final String formTitle;

  /// The field placeholder.
  final String placeholder;

  /// The submit button label.
  final String buttonLabel;

  /// The small print under the form.
  final String privacyNote;

  /// The heading shown once the link has been sent.
  final String successTitle;

  /// The message shown once the link has been sent.
  final String successMessage;

  /// The line above the two store buttons.
  final String storesHeading;

  /// The QR card.
  final QrCardContent qr;

  @override
  List<Object?> get props => <Object?>[
    eyebrow,
    title,
    subtitle,
    formTitle,
    placeholder,
    buttonLabel,
    privacyNote,
    successTitle,
    successMessage,
    storesHeading,
    qr,
  ];
}

/// The QR card.
class QrCardContent extends Equatable {
  /// Creates the card content.
  const QrCardContent({
    required this.title,
    required this.caption,
    required this.badge,
    required this.demoNote,
    required this.payload,
  });

  /// The card title.
  final String title;

  /// The line under the code.
  final String caption;

  /// The short label on the badge, such as `Demo`.
  final String badge;

  /// The note that marks the pattern as a demo.
  final String demoNote;

  /// The text the code stands for, usually the smart link; it seeds the demo
  /// pattern.
  final String payload;

  @override
  List<Object?> get props => <Object?>[
    title,
    caption,
    badge,
    demoNote,
    payload,
  ];
}
