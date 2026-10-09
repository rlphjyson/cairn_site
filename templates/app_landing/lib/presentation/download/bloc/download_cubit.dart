import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/content_cubit.dart';
import '../../../domain/download/models/download_content.dart';
import '../../../domain/download/models/qr_pattern.dart';
import '../../../domain/download/models/send_outcome.dart';
import '../../../domain/download/use_cases/build_qr_pattern.dart';
import '../../../domain/download/use_cases/get_download.dart';
import '../../../domain/download/use_cases/send_download_link.dart';

/// Where the send-me-the-link form is.
enum DownloadStatus {
  /// Waiting for an email or a phone number.
  idle,

  /// A send is in flight.
  sending,

  /// The link was sent.
  sent,

  /// What was typed did not pass validation.
  invalid,

  /// The service failed.
  failure,
}

/// The get-the-app section: its copy, the demo QR pattern and the form.
class DownloadState extends Equatable {
  /// Creates a state.
  const DownloadState({
    this.load = ContentStatus.initial,
    this.content,
    this.qr,
    this.status = DownloadStatus.idle,
    this.message,
    this.contact,
    this.attempts = 0,
  });

  /// Whether the copy has loaded.
  final ContentStatus load;

  /// The copy, once loaded.
  final DownloadContent? content;

  /// The demo QR pattern, once the copy has loaded.
  final QrPattern? qr;

  /// The state of the form.
  final DownloadStatus status;

  /// The validation or service message for [DownloadStatus.invalid] and
  /// [DownloadStatus.failure].
  final String? message;

  /// Where the link went, for [DownloadStatus.sent].
  final Contact? contact;

  /// How many sends have finished; lets listeners react to a repeat of the
  /// same outcome.
  final int attempts;

  /// A copy with the given fields replaced; [message] and [contact] are always
  /// replaced, so they clear when omitted.
  DownloadState copyWith({
    ContentStatus? load,
    DownloadContent? content,
    QrPattern? qr,
    DownloadStatus? status,
    String? message,
    Contact? contact,
    int? attempts,
  }) => DownloadState(
    load: load ?? this.load,
    content: content ?? this.content,
    qr: qr ?? this.qr,
    status: status ?? this.status,
    message: message,
    contact: contact,
    attempts: attempts ?? this.attempts,
  );

  @override
  List<Object?> get props => <Object?>[
    load,
    content,
    qr,
    status,
    message,
    contact,
    attempts,
  ];
}

/// Loads the copy, builds the demo QR pattern and runs the send-link form.
class DownloadCubit extends Cubit<DownloadState> {
  /// Creates the cubit.
  DownloadCubit(this._getDownload, this._send, this._buildQr)
    : super(const DownloadState());

  final GetDownload _getDownload;
  final SendDownloadLink _send;
  final BuildQrPattern _buildQr;

  /// Loads the copy; does nothing once loaded.
  Future<void> load() async {
    if (state.load == ContentStatus.loading ||
        state.load == ContentStatus.loaded) {
      return;
    }
    emit(state.copyWith(load: ContentStatus.loading));
    try {
      final DownloadContent content = await _getDownload();
      emit(
        state.copyWith(
          load: ContentStatus.loaded,
          content: content,
          qr: _buildQr(content.qr.payload),
        ),
      );
    } on Object {
      emit(state.copyWith(load: ContentStatus.failure));
    }
  }

  /// Validates [entry] and sends the download link to it.
  Future<void> submit(String entry) async {
    if (state.status == DownloadStatus.sending) return;
    emit(state.copyWith(status: DownloadStatus.sending));
    final SendOutcome outcome = await _send(entry);
    if (isClosed) return;
    emit(
      state.copyWith(
        status: switch (outcome.status) {
          SendStatus.invalid => DownloadStatus.invalid,
          SendStatus.sent => DownloadStatus.sent,
          SendStatus.failed => DownloadStatus.failure,
        },
        message: outcome.message,
        contact: outcome.contact,
        attempts: state.attempts + 1,
      ),
    );
  }

  /// Clears a validation or service message, for when the visitor edits.
  void clearError() {
    if (state.status == DownloadStatus.invalid ||
        state.status == DownloadStatus.failure) {
      emit(state.copyWith(status: DownloadStatus.idle));
    }
  }

  /// Returns the form to its empty state, to send to another address.
  void reset() => emit(state.copyWith(status: DownloadStatus.idle));
}
