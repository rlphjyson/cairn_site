import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/navigation/dashboard_navigation_cubit.dart';
import '../../domain/filters/models/period.dart';
import '../filters/bloc/period_cubit.dart';

/// Exposes the session-scoped cubits to every page.
///
/// Lazy singletons owned by the container, so they are provided with
/// `BlocProvider.value`, which never closes them.
class DashboardProviders extends StatelessWidget {
  /// Creates the providers.
  const DashboardProviders({
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
      BlocProvider<DashboardNavigationCubit>.value(
        value: locator<DashboardNavigationCubit>(),
      ),
      BlocProvider<PeriodCubit>.value(value: locator<PeriodCubit>()),
    ],
    child: child,
  );
}

/// The periods offered in the picker.
const List<Period> periodOptions = Period.values;
