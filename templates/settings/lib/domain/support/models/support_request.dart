import 'package:equatable/equatable.dart';

/// A message to the support team.
class SupportRequest extends Equatable {
  /// Creates a request.
  const SupportRequest({required this.subject, required this.message});

  /// One of the `SupportSubjects` ids.
  final String subject;

  /// What the person wrote.
  final String message;

  /// The shortest message accepted.
  static const int minMessage = 10;

  /// The longest message accepted.
  static const int maxMessage = 1000;

  @override
  List<Object?> get props => <Object?>[subject, message];
}

/// What is wrong with a support request, per field.
class SupportValidation extends Equatable {
  /// Creates a result.
  const SupportValidation({this.subjectError, this.messageError});

  /// The problem with the subject, if any.
  final String? subjectError;

  /// The problem with the message, if any.
  final String? messageError;

  /// Whether the request can be sent.
  bool get isValid => subjectError == null && messageError == null;

  @override
  List<Object?> get props => <Object?>[subjectError, messageError];
}
