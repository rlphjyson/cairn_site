import '../models/send_outcome.dart';
import '../repositories/download_repository.dart';
import 'validate_contact.dart';

/// Validates an email or phone number and, if it passes, sends the download
/// link there.
class SendDownloadLink {
  /// Creates the use case.
  const SendDownloadLink(this._validate, this._repository);

  final ValidateContact _validate;
  final DownloadRepository _repository;

  /// Runs the use case. Never throws.
  Future<SendOutcome> call(String entry) async {
    final ContactCheck check = _validate(entry);
    final Contact? contact = check.contact;
    if (contact == null) return SendOutcome.invalid(check.message!);
    try {
      await _repository.sendLink(contact);
      return SendOutcome.sent(contact);
    } on DownloadLinkException catch (e) {
      return SendOutcome.failed(e.message);
    } on Object {
      return const SendOutcome.failed(
        'Something went wrong. Please try again in a moment.',
      );
    }
  }
}
