import 'package:get_it/get_it.dart';

import '../../../data/docs/remote/docs_remote_data_source.dart';
import '../../../data/docs/repositories/docs_repository_impl.dart';
import '../../../domain/docs/repositories/docs_repository.dart';
import '../../../domain/docs/use_cases/extract_headings.dart';
import '../../../domain/docs/use_cases/get_docs_site.dart';
import '../../../domain/docs/use_cases/get_page_neighbours.dart';
import '../../../domain/docs/use_cases/get_versions.dart';
import '../../../domain/search/use_cases/search_docs.dart';
import '../../../presentation/docs/bloc/docs_cubit.dart';
import '../../../presentation/docs/bloc/toc_cubit.dart';
import '../../../presentation/docs/view_models/doc_page_view_model.dart';
import '../../../presentation/search/bloc/search_cubit.dart';
import '../../../presentation/sidebar/bloc/sidebar_cubit.dart';
import '../../presentation/navigation/docs_navigation_cubit.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit rather than generated, so the template needs no
/// `build_runner` step. The scopes follow one rule:
///
/// * data sources, repositories: lazy singletons, one per session;
/// * use cases: factories (they are stateless and free to build);
/// * **session cubits** (navigation, docs, search, sidebar): lazy singletons,
///   provided to the tree once and never closed by a view model;
/// * **screen cubits** (the table-of-contents cursor): created and closed by
///   their view model.
///
/// To load content from somewhere else, register your own
/// [DocsRemoteDataSource] with [remote] (or edit the line below).
GetIt createDocsLocator({
  DocsLocation initialLocation = const DocsLocation(),
  DocsRemoteDataSource? remote,
}) {
  final GetIt g = GetIt.asNewInstance();

  // Data source: the one line to change to load content from elsewhere.
  g.registerLazySingleton<DocsRemoteDataSource>(
    () => remote ?? const InMemoryDocsRemoteDataSource(),
  );

  // Repositories.
  g.registerLazySingleton<DocsRepository>(() => DocsRepositoryImpl(g()));

  // Use cases.
  g
    ..registerFactory<GetVersions>(() => GetVersions(g()))
    ..registerFactory<GetDocsSite>(() => GetDocsSite(g()))
    ..registerFactory<ExtractHeadings>(ExtractHeadings.new)
    ..registerFactory<GetPageNeighbours>(GetPageNeighbours.new)
    ..registerFactory<SearchDocs>(SearchDocs.new);

  // Session cubits.
  g
    ..registerLazySingleton<DocsNavigationCubit>(
      () => DocsNavigationCubit(initialLocation),
      dispose: (DocsNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<DocsCubit>(
      () => DocsCubit(g(), g()),
      dispose: (DocsCubit c) => c.close(),
    )
    ..registerLazySingleton<SearchCubit>(
      () => SearchCubit(g()),
      dispose: (SearchCubit c) => c.close(),
    )
    ..registerLazySingleton<SidebarCubit>(
      SidebarCubit.new,
      dispose: (SidebarCubit c) => c.close(),
    );

  // Screen view models; each creates and owns its own cubit.
  g.registerFactory<DocPageViewModel>(
    () => DocPageViewModel(TocCubit(), g(), g()),
  );

  return g;
}
