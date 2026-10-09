import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/newsletter/models/subscribe_result.dart';
import '../../../domain/newsletter/use_cases/subscribe_to_newsletter.dart';
import '../../../domain/newsletter/use_cases/validate_email.dart';

/// Where the sign-up form is.
enum NewsletterStatus {
  /// Waiting for an address.
  idle,

  /// The request is in flight.
  submitting,

  /// The address was accepted.
  success,

  /// The service failed or the address was refused.
  failure,
}

/// What one sign-up form is showing.
class NewsletterState extends Equatable {
  /// Creates a state.
  const NewsletterState({
    this.status = NewsletterStatus.idle,
    this.error,
    this.result,
  });

  /// Where the form is.
  final NewsletterStatus status;

  /// A message for the field or the form; `null` when there is none.
  final String? error;

  /// The outcome once [status] is [NewsletterStatus.success].
  final SubscribeResult? result;

  /// Whether the field should be drawn as invalid.
  bool get hasError => error != null;

  @override
  List<Object?> get props => <Object?>[status, error, result];
}

/// State for one sign-up form. Each form owns one (through its view model),
/// so the home page and the footer do not share a half-typed address.
class NewsletterCubit extends Cubit<NewsletterState> {
  /// Creates the cubit.
  NewsletterCubit(this._validate, this._subscribe)
    : super(const NewsletterState());

  final ValidateEmail _validate;
  final SubscribeToNewsletter _subscribe;

  /// Called as the reader types: clears a stale error.
  void edit() {
    if (state.status == NewsletterStatus.submitting) return;
    if (state.status != NewsletterStatus.idle || state.hasError) {
      emit(const NewsletterState());
    }
  }

  /// Validates and submits [email].
  Future<void> submit(String email) async {
    if (state.status == NewsletterStatus.submitting) return;
    final String? problem = _validate(email);
    if (problem != null) {
      emit(NewsletterState(status: NewsletterStatus.failure, error: problem));
      return;
    }
    emit(const NewsletterState(status: NewsletterStatus.submitting));
    try {
      final SubscribeResult result = await _subscribe(email);
      if (isClosed) return;
      emit(NewsletterState(status: NewsletterStatus.success, result: result));
    } on NewsletterException catch (e) {
      if (isClosed) return;
      emit(NewsletterState(status: NewsletterStatus.failure, error: e.message));
    } on Object {
      if (isClosed) return;
      emit(
        const NewsletterState(
          status: NewsletterStatus.failure,
          error: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  /// Returns to an empty form after a success.
  void reset() => emit(const NewsletterState());
}
