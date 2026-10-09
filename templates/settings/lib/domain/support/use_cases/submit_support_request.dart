import '../../../common/constants/support_subjects.dart';
import '../../../common/utils/settings_failure.dart';
import '../models/support_request.dart';
import '../repositories/support_repository.dart';

/// Validates a support request and sends it.
class SubmitSupportRequest {
  /// Creates the use case.
  const SubmitSupportRequest(this._repository);

  final SupportRepository _repository;

  /// Checks [request]. Pure.
  SupportValidation validate(SupportRequest request) {
    final String message = request.message.trim();
    return SupportValidation(
      subjectError: SupportSubjects.isValid(request.subject)
          ? null
          : 'Choose a subject.',
      messageError: message.length < SupportRequest.minMessage
          ? 'Tell us a little more (at least ${SupportRequest.minMessage} characters).'
          : message.length > SupportRequest.maxMessage
          ? 'Keep it under ${SupportRequest.maxMessage} characters.'
          : null,
    );
  }

  /// Sends [request] and returns the ticket reference, if the server gave one.
  /// Throws a [SettingsFailure] when it is invalid or cannot be sent.
  Future<String?> call(SupportRequest request) async {
    if (!validate(request).isValid) {
      throw const SettingsFailure('Fix the highlighted fields and try again.');
    }
    final result = await _repository.submit(
      SupportRequest(subject: request.subject, message: request.message.trim()),
    );
    if (!result.ok) {
      throw SettingsFailure(result.message ?? 'Could not send your message.');
    }
    return result.message;
  }
}
