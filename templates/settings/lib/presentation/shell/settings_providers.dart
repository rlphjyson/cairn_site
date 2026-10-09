import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/infrastructure/settings_hooks.dart';
import '../../core/infrastructure/unsaved_changes_guard.dart';
import '../../core/presentation/navigation/settings_navigation_cubit.dart';
import '../../core/presentation/navigation/settings_navigator.dart';
import '../../domain/settings/registry/settings_registry.dart';
import '../profile/bloc/profile_cubit.dart';
import '../settings/bloc/settings_cubit.dart';

/// Exposes the session-scoped cubits and the few shared helpers to every
/// screen.
///
/// The cubits are lazy singletons owned by the container, so they are provided
/// with `BlocProvider.value` (which never closes them). Views read them with
/// `context.read` and never touch the container.
class SettingsProviders extends StatelessWidget {
  /// Creates the providers.
  const SettingsProviders({
    super.key,
    required this.locator,
    required this.child,
  });

  /// The container that owns the cubits.
  final GetIt locator;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: <RepositoryProvider<dynamic>>[
      RepositoryProvider<SettingsHooks>.value(value: locator<SettingsHooks>()),
      RepositoryProvider<SettingsRegistry>.value(
        value: locator<SettingsRegistry>(),
      ),
      RepositoryProvider<UnsavedChangesGuard>.value(
        value: locator<UnsavedChangesGuard>(),
      ),
      RepositoryProvider<SettingsNavigator>.value(
        value: locator<SettingsNavigator>(),
      ),
    ],
    child: MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SettingsNavigationCubit>.value(
          value: locator<SettingsNavigationCubit>(),
        ),
        BlocProvider<SettingsCubit>.value(value: locator<SettingsCubit>()),
        BlocProvider<ProfileCubit>.value(value: locator<ProfileCubit>()),
      ],
      child: child,
    ),
  );
}
