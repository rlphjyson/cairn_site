import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/content_cubit.dart';
import '../../core/presentation/navigation/app_landing_navigation_cubit.dart';
import '../../domain/site/models/site_info.dart';

/// Exposes the session-scoped cubits to every section.
///
/// Lazy singletons owned by the container, so they are provided with
/// `BlocProvider.value`, which never closes them.
class AppLandingProviders extends StatelessWidget {
  /// Creates the providers.
  const AppLandingProviders({
    super.key,
    required this.locator,
    required this.child,
  });

  /// The container that owns the cubits.
  final GetIt locator;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<AppLandingNavigationCubit>.value(
        value: locator<AppLandingNavigationCubit>(),
      ),
      BlocProvider<ContentCubit<SiteInfo>>.value(
        value: locator<ContentCubit<SiteInfo>>(),
      ),
    ],
    child: child,
  );
}
