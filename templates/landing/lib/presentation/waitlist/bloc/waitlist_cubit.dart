import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/content_cubit.dart';
import '../../../domain/waitlist/models/join_outcome.dart';
import '../../../domain/waitlist/models/waitlist_content.dart';
import '../../../domain/waitlist/use_cases/get_waitlist.dart';
import '../../../domain/waitlist/use_cases/join_waitlist.dart';

/// Where the signup form is.
enum WaitlistStatus {
  /// Waiting for an email.
  idle,

  /// A signup is in flight.
  submitting,

  /// The visitor is on the list.
  success,

  /// The email did not pass validation.
  invalid,

  /// The service failed.
  failure,
}

/// The waitlist section: its copy and the signup form.
class WaitlistState extends Equatable {
  /// Creates a state.
  const WaitlistState({
    this.load = ContentStatus.initial,
    this.content,
    this.status = WaitlistStatus.idle,
    this.message,
    this.receipt,
    this.submissions = 0,
  });

  /// Whether the copy has loaded.
  final ContentStatus load;

  /// The copy, once loaded.
  final WaitlistContent? content;

  /// The state of the form.
  final WaitlistStatus status;

  /// The validation or service message for [WaitlistStatus.invalid] and
  /// [WaitlistStatus.failure].
  final String? message;

  /// The receipt for [WaitlistStatus.success].
  final WaitlistReceipt? receipt;

  /// How many submissions have finished; lets listeners react to a repeat of
  /// the same outcome.
  final int submissions;

  /// A copy with the given fields replaced; [message] and [receipt] are
  /// always replaced, so they clear when omitted.
  WaitlistState copyWith({
    ContentStatus? load,
    WaitlistContent? content,
    WaitlistStatus? status,
    String? message,
    WaitlistReceipt? receipt,
    int? submissions,
  }) => WaitlistState(
    load: load ?? this.load,
    content: content ?? this.content,
    status: status ?? this.status,
    message: message,
    receipt: receipt,
    submissions: submissions ?? this.submissions,
  );

  @override
  List<Object?> get props => <Object?>[
    load,
    content,
    status,
    message,
    receipt,
    submissions,
  ];
}

/// Loads the waitlist copy and runs the signup.
class WaitlistCubit extends Cubit<WaitlistState> {
  /// Creates the cubit.
  WaitlistCubit(this._getWaitlist, this._join) : super(const WaitlistState());

  final GetWaitlist _getWaitlist;
  final JoinWaitlist _join;

  /// Loads the copy; does nothing once loaded.
  Future<void> load() async {
    if (state.load == ContentStatus.loading ||
        state.load == ContentStatus.loaded) {
      return;
    }
    emit(state.copyWith(load: ContentStatus.loading));
    try {
      final WaitlistContent content = await _getWaitlist();
      emit(state.copyWith(load: ContentStatus.loaded, content: content));
    } on Object {
      emit(state.copyWith(load: ContentStatus.failure));
    }
  }

  /// Validates [email] and joins the waitlist.
  Future<void> submit(String email) async {
    if (state.status == WaitlistStatus.submitting) return;
    emit(state.copyWith(status: WaitlistStatus.submitting));
    final JoinOutcome outcome = await _join(email);
    if (isClosed) return;
    emit(
      state.copyWith(
        status: switch (outcome.status) {
          JoinStatus.invalid => WaitlistStatus.invalid,
          JoinStatus.joined => WaitlistStatus.success,
          JoinStatus.failed => WaitlistStatus.failure,
        },
        message: outcome.message,
        receipt: outcome.receipt,
        submissions: state.submissions + 1,
      ),
    );
  }

  /// Clears a validation or service message, for when the visitor edits.
  void clearError() {
    if (state.status == WaitlistStatus.invalid ||
        state.status == WaitlistStatus.failure) {
      emit(state.copyWith(status: WaitlistStatus.idle));
    }
  }

  /// Returns the form to its empty state, for signing up another address.
  void reset() => emit(state.copyWith(status: WaitlistStatus.idle));
}
