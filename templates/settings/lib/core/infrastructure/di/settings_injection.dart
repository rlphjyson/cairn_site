import 'package:get_it/get_it.dart';

import '../../../data/profile/repositories/profile_repository_impl.dart';
import '../../../data/security/repositories/security_repository_impl.dart';
import '../../../data/settings/remote/in_memory_settings_data_source.dart';
import '../../../data/settings/remote/settings_data_source.dart';
import '../../../data/settings/repositories/settings_repository_impl.dart';
import '../../../data/storage/repositories/storage_repository_impl.dart';
import '../../../data/support/repositories/support_repository_impl.dart';
import '../../../domain/profile/models/profile.dart';
import '../../../domain/profile/repositories/profile_repository.dart';
import '../../../domain/profile/use_cases/check_username.dart';
import '../../../domain/profile/use_cases/get_profile.dart';
import '../../../domain/profile/use_cases/save_profile.dart';
import '../../../domain/profile/use_cases/validate_profile.dart';
import '../../../domain/security/repositories/security_repository.dart';
import '../../../domain/security/use_cases/blocked_users.dart';
import '../../../domain/security/use_cases/change_password.dart';
import '../../../domain/security/use_cases/delete_account.dart';
import '../../../domain/security/use_cases/export_data.dart';
import '../../../domain/security/use_cases/get_sessions.dart';
import '../../../domain/security/use_cases/revoke_session.dart';
import '../../../domain/security/use_cases/two_factor_use_cases.dart';
import '../../../domain/settings/mappers/settings_mapper.dart';
import '../../../domain/settings/models/notification_permission.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../../domain/settings/repositories/settings_repository.dart';
import '../../../domain/settings/use_cases/get_app_info.dart';
import '../../../domain/settings/use_cases/load_settings.dart';
import '../../../domain/settings/use_cases/search_settings.dart';
import '../../../domain/settings/use_cases/update_setting.dart';
import '../../../domain/storage/repositories/storage_repository.dart';
import '../../../domain/storage/use_cases/storage_use_cases.dart';
import '../../../domain/support/repositories/support_repository.dart';
import '../../../domain/support/use_cases/submit_support_request.dart';
import '../../../presentation/danger/bloc/account_cubit.dart';
import '../../../presentation/danger/view_models/account_view_model.dart';
import '../../../presentation/help/bloc/support_cubit.dart';
import '../../../presentation/help/view_models/support_view_model.dart';
import '../../../presentation/home/bloc/search_cubit.dart';
import '../../../presentation/home/view_models/search_view_model.dart';
import '../../../presentation/privacy/bloc/blocked_users_cubit.dart';
import '../../../presentation/privacy/bloc/change_password_cubit.dart';
import '../../../presentation/privacy/bloc/privacy_cubit.dart';
import '../../../presentation/privacy/bloc/sessions_cubit.dart';
import '../../../presentation/privacy/bloc/two_factor_cubit.dart';
import '../../../presentation/privacy/view_models/privacy_view_models.dart';
import '../../../presentation/profile/bloc/profile_cubit.dart';
import '../../../presentation/profile/bloc/profile_edit_cubit.dart';
import '../../../presentation/profile/view_models/profile_edit_view_model.dart';
import '../../../presentation/settings/bloc/settings_cubit.dart';
import '../../../presentation/storage/bloc/storage_cubit.dart';
import '../../../presentation/storage/view_models/storage_view_model.dart';
import '../../presentation/navigation/settings_navigation_cubit.dart';
import '../../presentation/navigation/settings_navigator.dart';
import '../../presentation/navigation/settings_page.dart';
import '../settings_hooks.dart';
import '../unsaved_changes_guard.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit rather than generated, so the template needs no
/// `build_runner` step. The scopes follow one rule:
///
/// * the data source, the registry, hooks and repositories: singletons, one per
///   session;
/// * use cases: factories (they are stateless and free to build);
/// * **session cubits** (navigation, settings, profile): lazy singletons,
///   provided to the tree once and never closed by a view model;
/// * **screen cubits** (search, profile draft, sessions, ...): created and
///   closed by their view model, which is a factory.
///
/// The arguments are the template's integration points; anything left `null`
/// gets the in-memory demo.
GetIt createSettingsLocator({
  SettingsDataSource? settingsDataSource,
  SettingsRegistry? registry,
  Profile? profile,
  NotificationPermission notificationPermission =
      NotificationPermission.granted,
  List<SettingsPage> initialPages = const <SettingsPage>[],
  SettingsHooks? hooks,
}) {
  final GetIt g = GetIt.asNewInstance();

  // Integration points. Replace these with ones that call your backend,
  // storage and the platform.
  g
    ..registerSingleton<SettingsHooks>(hooks ?? SettingsHooks())
    ..registerSingleton<UnsavedChangesGuard>(UnsavedChangesGuard())
    ..registerSingleton<SettingsRegistry>(registry ?? defaultSettingsRegistry)
    ..registerSingleton<SettingsDataSource>(
      settingsDataSource ??
          InMemorySettingsDataSource(
            profile: profile == null
                ? null
                : <String, Object?>{
                    'name': profile.name,
                    'username': profile.username,
                    'email': profile.email,
                    'bio': profile.bio,
                    'avatar': profile.avatarId,
                  },
          ),
    );

  // Mapper and repositories.
  g
    ..registerLazySingleton<SettingsMapper>(() => SettingsMapper(g()))
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(g(), g()),
    )
    ..registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(g()))
    ..registerLazySingleton<SecurityRepository>(
      () => SecurityRepositoryImpl(g()),
    )
    ..registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl(g()))
    ..registerLazySingleton<SupportRepository>(
      () => SupportRepositoryImpl(g()),
    );

  // Use cases.
  g
    ..registerFactory<LoadSettings>(() => LoadSettings(g()))
    ..registerFactory<GetAppInfo>(() => GetAppInfo(g()))
    ..registerFactory<UpdateSetting>(() => UpdateSetting(g(), g()))
    ..registerFactory<SearchSettings>(() => SearchSettings(g()))
    ..registerFactory<GetProfile>(() => GetProfile(g()))
    ..registerFactory<ValidateProfile>(ValidateProfile.new)
    ..registerFactory<CheckUsername>(() => CheckUsername(g()))
    ..registerFactory<SaveProfile>(() => SaveProfile(g(), g()))
    ..registerFactory<ChangePassword>(() => ChangePassword(g()))
    ..registerFactory<GetSessions>(() => GetSessions(g()))
    ..registerFactory<RevokeSession>(() => RevokeSession(g()))
    ..registerFactory<BeginTwoFactor>(() => BeginTwoFactor(g()))
    ..registerFactory<VerifyTwoFactor>(() => VerifyTwoFactor(g()))
    ..registerFactory<DisableTwoFactor>(() => DisableTwoFactor(g()))
    ..registerFactory<ExportData>(() => ExportData(g()))
    ..registerFactory<GetBlockedUsers>(() => GetBlockedUsers(g()))
    ..registerFactory<UnblockUser>(() => UnblockUser(g()))
    ..registerFactory<DeleteAccount>(() => DeleteAccount(g()))
    ..registerFactory<DeactivateAccount>(() => DeactivateAccount(g()))
    ..registerFactory<GetStorageUsage>(() => GetStorageUsage(g()))
    ..registerFactory<ClearCache>(() => ClearCache(g()))
    ..registerFactory<SubmitSupportRequest>(() => SubmitSupportRequest(g()));

  // Session cubits.
  g
    ..registerLazySingleton<SettingsNavigationCubit>(
      () => SettingsNavigationCubit(initial: initialPages),
      dispose: (SettingsNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<SettingsNavigator>(
      () => SettingsNavigator(g(), g()),
    )
    ..registerLazySingleton<SettingsCubit>(
      () => SettingsCubit(
        loadSettings: g(),
        getAppInfo: g(),
        updateSetting: g(),
        hooks: g(),
        permission: notificationPermission,
      ),
      dispose: (SettingsCubit c) => c.close(),
    )
    ..registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(g(), initial: profile),
      dispose: (ProfileCubit c) => c.close(),
    );

  // Screen view models; each creates and owns its own cubit.
  g
    ..registerFactory<SearchViewModel>(() => SearchViewModel(SearchCubit(g())))
    ..registerFactory<ProfileEditViewModel>(
      () => ProfileEditViewModel(
        ProfileEditCubit(
          profile: g(),
          validate: g(),
          checkUsername: g(),
          saveProfile: g(),
        ),
      ),
    )
    ..registerFactory<PrivacyViewModel>(
      () => PrivacyViewModel(PrivacyCubit(g(), g())),
    )
    ..registerFactory<ChangePasswordViewModel>(
      () => ChangePasswordViewModel(ChangePasswordCubit(g())),
    )
    ..registerFactory<SessionsViewModel>(
      () => SessionsViewModel(SessionsCubit(g(), g())),
    )
    ..registerFactory<BlockedUsersViewModel>(
      () => BlockedUsersViewModel(BlockedUsersCubit(g(), g())),
    )
    ..registerFactory<TwoFactorViewModel>(
      () => TwoFactorViewModel(TwoFactorCubit(g(), g())),
    )
    ..registerFactory<StorageViewModel>(
      () => StorageViewModel(StorageCubit(g(), g())),
    )
    ..registerFactory<SupportViewModel>(
      () => SupportViewModel(SupportCubit(g())),
    )
    ..registerFactory<AccountViewModel>(
      () => AccountViewModel(AccountCubit(g(), g(), g())),
    );

  return g;
}
