import 'package:equatable/equatable.dart';

import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/security/models/device_session.dart';
import '../../../domain/security/use_cases/export_data.dart';
import '../../../domain/security/use_cases/two_factor_use_cases.dart';

/// Where the data export request is.
enum ExportStatus {
  /// Not requested.
  idle,

  /// Sending the request.
  requesting,

  /// Requested; the data arrives by email.
  requested,
}

/// The Privacy and security screen's own state.
class PrivacyState extends Equatable {
  /// Creates a state.
  const PrivacyState({
    this.exportStatus = ExportStatus.idle,
    this.request,
    this.notice,
  });

  /// Where the export is.
  final ExportStatus exportStatus;

  /// The request, once made.
  final DataExportRequest? request;

  /// A message to show as a toast.
  final Notice? notice;

  @override
  List<Object?> get props => <Object?>[exportStatus, request, notice];
}

/// The data export request and turning two-factor off. Screen-scoped.
class PrivacyCubit extends SafeCubit<PrivacyState> {
  /// Creates the cubit.
  PrivacyCubit(this._export, this._disableTwoFactor)
    : super(const PrivacyState());

  final ExportData _export;
  final DisableTwoFactor _disableTwoFactor;

  /// Files a data export request.
  Future<void> requestExport() async {
    if (state.exportStatus != ExportStatus.idle) return;
    emit(const PrivacyState(exportStatus: ExportStatus.requesting));
    try {
      final DataExportRequest request = await _export();
      emit(
        PrivacyState(
          exportStatus: ExportStatus.requested,
          request: request,
          notice: Notice(
            'Export requested',
            description: 'We will email you a download link.',
          ),
        ),
      );
    } on Object {
      emit(
        PrivacyState(
          notice: Notice('Could not request the export', isError: true),
        ),
      );
    }
  }

  /// Turns two-factor off. Returns whether it worked.
  Future<bool> disableTwoFactor() async {
    try {
      await _disableTwoFactor();
      emit(
        PrivacyState(
          exportStatus: state.exportStatus,
          request: state.request,
          notice: Notice('Two-factor authentication is off'),
        ),
      );
      return true;
    } on Object {
      emit(
        PrivacyState(
          exportStatus: state.exportStatus,
          request: state.request,
          notice: Notice('Could not turn it off', isError: true),
        ),
      );
      return false;
    }
  }
}
