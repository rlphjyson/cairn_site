import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../docs/bloc/docs_cubit.dart';
import '../search/bloc/search_cubit.dart';
import '../sidebar/bloc/sidebar_cubit.dart';

/// Exposes the session cubits to every screen and wires them together.
///
/// The cubits are lazy singletons owned by the container, so they are provided
/// with `BlocProvider.value` (which never closes them). Three listeners keep
/// them in step without the features knowing about each other:
///
/// * a new version in navigation loads that version's content;
/// * newly loaded content rebuilds the search index;
/// * a change of location is reported to the host (`onLocationChanged`).
class DocsProviders extends StatelessWidget {
  /// Creates the providers.
  const DocsProviders({
    super.key,
    required this.locator,
    required this.child,
    this.onLocationChanged,
  });

  /// The container that owns the cubits.
  final GetIt locator;

  /// Called whenever the version, page or heading changes.
  final ValueChanged<DocsLocation>? onLocationChanged;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<DocsNavigationCubit>.value(
          value: locator<DocsNavigationCubit>(),
        ),
        BlocProvider<DocsCubit>.value(value: locator<DocsCubit>()),
        BlocProvider<SearchCubit>.value(value: locator<SearchCubit>()),
        BlocProvider<SidebarCubit>.value(value: locator<SidebarCubit>()),
      ],
      child: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<DocsNavigationCubit, DocsNavigationState>(
            listenWhen: (DocsNavigationState a, DocsNavigationState b) =>
                a.versionId != b.versionId,
            listener: (BuildContext context, DocsNavigationState nav) =>
                context.read<DocsCubit>().load(nav.versionId),
          ),
          BlocListener<DocsCubit, DocsState>(
            listenWhen: (DocsState a, DocsState b) =>
                b.status == DocsStatus.ready && a.site != b.site,
            listener: (BuildContext context, DocsState docs) =>
                context.read<SearchCubit>().index(docs.site!),
          ),
          BlocListener<DocsNavigationCubit, DocsNavigationState>(
            listenWhen: (DocsNavigationState a, DocsNavigationState b) =>
                a.location != b.location,
            listener: (BuildContext context, DocsNavigationState nav) =>
                onLocationChanged?.call(nav.location),
          ),
        ],
        child: child,
      ),
    );
  }
}
