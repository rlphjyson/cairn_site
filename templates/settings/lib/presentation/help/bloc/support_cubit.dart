import 'package:equatable/equatable.dart';

import '../../../common/utils/settings_failure.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/support/models/support_request.dart';
import '../../../domain/support/use_cases/submit_support_request.dart';

/// The contact support form.
class SupportState extends Equatable {
  /// Creates a state.
  const SupportState({
    this.validation = const SupportValidation(),
    this.sending = false,
    this.sentCount = 0,
    this.notice,
  });

  /// Errors to show. Empty until the form is submitted.
  final SupportValidation validation;

  /// Whether the message is being sent.
  final bool sending;

  /// How many messages have been sent, so the form can clear itself.
  final int sentCount;

  /// A message to show as a toast.
  final Notice? notice;

  @override
  List<Object?> get props => <Object?>[validation, sending, sentCount, notice];
}

/// The contact support form. Screen-scoped.
class SupportCubit extends SafeCubit<SupportState> {
  /// Creates the cubit.
  SupportCubit(this._submit) : super(const SupportState());

  final SubmitSupportRequest _submit;

  /// Validates and sends. Returns whether the message was sent.
  Future<bool> send({required String subject, required String message}) async {
    if (state.sending) return false;
    final SupportRequest request = SupportRequest(
      subject: subject,
      message: message,
    );
    final SupportValidation validation = _submit.validate(request);
    if (!validation.isValid) {
      emit(SupportState(validation: validation, sentCount: state.sentCount));
      return false;
    }
    emit(SupportState(sending: true, sentCount: state.sentCount));
    try {
      final String? reference = await _submit(request);
      emit(
        SupportState(
          sentCount: state.sentCount + 1,
          notice: Notice(
            'Message sent',
            description: reference == null
                ? 'We will reply by email.'
                : 'Reference $reference. We will reply by email.',
          ),
        ),
      );
      return true;
    } on SettingsFailure catch (e) {
      emit(
        SupportState(
          sentCount: state.sentCount,
          notice: Notice(e.message, isError: true),
        ),
      );
    } on Object {
      emit(
        SupportState(
          sentCount: state.sentCount,
          notice: Notice('Could not send your message', isError: true),
        ),
      );
    }
    return false;
  }
}
