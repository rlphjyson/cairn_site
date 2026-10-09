import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/navigation/onboarding_navigation_cubit.dart';
import '../flow/bloc/onboarding_cubit.dart';

/// Exposes the session-scoped cubits to every screen.
///
/// These are lazy singletons owned by the container, so they are provided with
/// `BlocProvider.value` (which never closes them). Views read them with
/// `context.read` and never touch the container.
class OnboardingProviders extends StatelessWidget {
  /// Creates the providers.
  const OnboardingProviders({
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
      BlocProvider<OnboardingNavigationCubit>.value(
        value: locator<OnboardingNavigationCubit>(),
      ),
      BlocProvider<OnboardingCubit>.value(value: locator<OnboardingCubit>()),
    ],
    child: child,
  );
}
