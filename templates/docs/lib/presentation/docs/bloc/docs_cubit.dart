import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/docs/models/doc_version.dart';
import '../../../domain/docs/models/docs_site.dart';
import '../../../domain/docs/use_cases/get_docs_site.dart';
import '../../../domain/docs/use_cases/get_versions.dart';

/// Where loading the content set has got to.
enum DocsStatus {
  /// A version is being fetched.
  loading,

  /// [DocsState.site] is the requested version.
  ready,

  /// The fetch or the mapping failed.
  failure,
}

/// The loaded documentation: the version list and one version's content.
class DocsState extends Equatable {
  /// Creates a state.
  const DocsState({
    this.status = DocsStatus.loading,
    this.versions = const <DocVersion>[],
    this.versionId,
    this.site,
    this.error,
  });

  /// Loading, ready or failed.
  final DocsStatus status;

  /// Every published version.
  final List<DocVersion> versions;

  /// The version that was asked for (it may still be loading).
  final String? versionId;

  /// The content of [versionId] once [status] is ready.
  final DocsSite? site;

  /// The reason, when [status] is failure.
  final String? error;

  /// The [DocVersion] for [versionId], or `null` while the list loads.
  DocVersion? get version {
    for (final DocVersion v in versions) {
      if (v.id == versionId) return v;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    versions,
    versionId,
    site,
    error,
  ];
}

/// Session cubit that loads versions and the content of the selected one.
///
/// It does not decide which version is selected: the navigation cubit does, and
/// `DocsProviders` calls [load] when that changes.
class DocsCubit extends Cubit<DocsState> {
  /// Creates the cubit.
  DocsCubit(this._getVersions, this._getSite) : super(const DocsState());

  final GetVersions _getVersions;
  final GetDocsSite _getSite;
  int _request = 0;

  /// Loads [versionId] (and the version list, the first time).
  Future<void> load(String versionId) async {
    final int request = ++_request;
    emit(
      DocsState(
        versions: state.versions,
        versionId: versionId,
        site: state.site?.versionId == versionId ? state.site : null,
        status: state.site?.versionId == versionId
            ? DocsStatus.ready
            : DocsStatus.loading,
      ),
    );
    if (state.status == DocsStatus.ready) return;
    try {
      final List<DocVersion> versions = state.versions.isEmpty
          ? await _getVersions()
          : state.versions;
      final DocsSite site = await _getSite(versionId);
      // A newer request superseded this one while it was in flight.
      if (request != _request || isClosed) return;
      emit(
        DocsState(
          status: DocsStatus.ready,
          versions: versions,
          versionId: versionId,
          site: site,
        ),
      );
    } on Object catch (e) {
      if (request != _request || isClosed) return;
      emit(
        DocsState(
          status: DocsStatus.failure,
          versions: state.versions,
          versionId: versionId,
          error: e.toString(),
        ),
      );
    }
  }
}
