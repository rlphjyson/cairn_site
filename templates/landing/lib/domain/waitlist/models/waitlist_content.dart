import 'package:equatable/equatable.dart';

/// The copy of the waitlist call to action.
class WaitlistContent extends Equatable {
  /// Creates the content.
  const WaitlistContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.placeholder,
    required this.buttonLabel,
    required this.privacyNote,
    required this.successTitle,
    required this.successMessage,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The email field placeholder.
  final String placeholder;

  /// The submit button label.
  final String buttonLabel;

  /// The small print under the form.
  final String privacyNote;

  /// The heading shown once the visitor has joined.
  final String successTitle;

  /// The message shown once the visitor has joined.
  final String successMessage;

  @override
  List<Object?> get props => <Object?>[
    eyebrow,
    title,
    subtitle,
    placeholder,
    buttonLabel,
    privacyNote,
    successTitle,
    successMessage,
  ];
}
