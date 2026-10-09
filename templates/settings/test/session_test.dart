import 'package:cairn_template_settings/common/constants/confirmation_phrases.dart';
import 'package:cairn_template_settings/core/infrastructure/di/settings_injection.dart';
import 'package:cairn_template_settings/core/infrastructure/settings_hooks.dart';
import 'package:cairn_template_settings/core/infrastructure/unsaved_changes_guard.dart';
import 'package:cairn_template_settings/core/presentation/load_status.dart';
import 'package:cairn_template_settings/core/presentation/navigation/settings_navigation_cubit.dart';
import 'package:cairn_template_settings/core/presentation/navigation/settings_page.dart';
import 'package:cairn_template_settings/data/settings/remote/in_memory_settings_data_source.dart';
import 'package:cairn_template_settings/domain/profile/models/profile.dart';
import 'package:cairn_template_settings/domain/profile/models/profile_validation.dart';
import 'package:cairn_template_settings/domain/security/models/device_session.dart';
import 'package:cairn_template_settings/domain/security/models/password_strength.dart';
import 'package:cairn_template_settings/domain/settings/models/notification_permission.dart';
import 'package:cairn_template_settings/domain/settings/models/settings_section.dart';
import 'package:cairn_template_settings/domain/settings/registry/default_settings_registry.dart';
import 'package:cairn_template_settings/presentation/danger/bloc/account_cubit.dart';
import 'package:cairn_template_settings/presentation/danger/view_models/account_view_model.dart';
import 'package:cairn_template_settings/presentation/help/bloc/support_cubit.dart';
import 'package:cairn_template_settings/presentation/help/view_models/support_view_model.dart';
import 'package:cairn_template_settings/presentation/home/bloc/search_cubit.dart';
import 'package:cairn_template_settings/presentation/home/view_models/search_view_model.dart';
import 'package:cairn_template_settings/presentation/privacy/bloc/blocked_users_cubit.dart';
import 'package:cairn_template_settings/presentation/privacy/bloc/change_password_cubit.dart';
import 'package:cairn_template_settings/presentation/privacy/bloc/privacy_cubit.dart';
import 'package:cairn_template_settings/presentation/privacy/bloc/sessions_cubit.dart';
import 'package:cairn_template_settings/presentation/privacy/bloc/two_factor_cubit.dart';
import 'package:cairn_template_settings/presentation/privacy/view_models/privacy_view_models.dart';
import 'package:cairn_template_settings/presentation/profile/bloc/profile_cubit.dart';
import 'package:cairn_template_settings/presentation/profile/bloc/profile_edit_cubit.dart';
import 'package:cairn_template_settings/presentation/profile/bloc/profile_edit_state.dart';
import 'package:cairn_template_settings/presentation/profile/view_models/profile_edit_view_model.dart';
import 'package:cairn_template_settings/presentation/settings/bloc/settings_cubit.dart';
import 'package:cairn_template_settings/presentation/storage/bloc/storage_cubit.dart';
import 'package:cairn_template_settings/presentation/storage/view_models/storage_view_model.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The cubits wired through the real container, with no widgets: the point of
/// the layering is that the whole app runs without a UI.
void main() {
  late GetIt locator;
  late InMemorySettingsDataSource source;
  late SettingsHooks hooks;
  late List<ThemeMode> modes;
  late List<(String, Object?)> changes;
  late int signedOut;
  late int deleted;
  late int deactivated;

  GetIt build({
    InMemorySettingsDataSource? data,
    Profile? profile,
    NotificationPermission permission = NotificationPermission.granted,
  }) => createSettingsLocator(
    settingsDataSource: data ?? source,
    profile: profile,
    notificationPermission: permission,
    hooks: hooks,
  );

  setUp(() {
    source = InMemorySettingsDataSource(latency: Duration.zero);
    modes = <ThemeMode>[];
    changes = <(String, Object?)>[];
    signedOut = deleted = deactivated = 0;
    hooks = SettingsHooks(
      onThemeModeChanged: modes.add,
      onSettingChanged: (String id, Object? v) => changes.add((id, v)),
      onSignOut: () => signedOut++,
      onDeleteAccount: () => deleted++,
      onDeactivateAccount: () => deactivated++,
    );
    locator = build();
  });
  tearDown(() => locator.reset());

  SettingsCubit settings() => locator<SettingsCubit>();

  group('container', () {
    test('each container is independent', () {
      final GetIt other = createSettingsLocator();
      expect(
        identical(locator<SettingsCubit>(), other<SettingsCubit>()),
        isFalse,
      );
      expect(
        identical(
          locator<SettingsNavigationCubit>(),
          other<SettingsNavigationCubit>(),
        ),
        isFalse,
      );
      expect(
        identical(locator<UnsavedChangesGuard>(), other<UnsavedChangesGuard>()),
        isFalse,
      );
    });

    test('session cubits are singletons, screen view models are not', () {
      expect(identical(settings(), locator<SettingsCubit>()), isTrue);
      expect(
        identical(
          locator<SearchViewModel>().cubit,
          locator<SearchViewModel>().cubit,
        ),
        isFalse,
      );
    });

    test('resetting closes the session cubits', () async {
      final SettingsCubit c = settings();
      await locator.reset();
      expect(c.isClosed, isTrue);
    });

    test('a view model closes its cubit when disposed', () {
      final SearchViewModel vm = locator<SearchViewModel>();
      vm.dispose();
      expect(vm.cubit.isClosed, isTrue);
    });
  });

  group('navigation', () {
    test('open, select, back and home', () {
      final SettingsNavigationCubit nav = locator<SettingsNavigationCubit>();
      expect(nav.state.stack, isEmpty);
      nav.open(SettingsPage.privacy);
      nav.open(SettingsPage.sessions);
      expect(nav.state.stack, <SettingsPage>[
        SettingsPage.privacy,
        SettingsPage.sessions,
      ]);
      expect(nav.state.section, SettingsSection.privacy);
      expect(nav.back(), isTrue);
      expect(nav.state.top, SettingsPage.privacy);
      expect(nav.state.forward, isFalse);
      nav.select(SettingsPage.about);
      expect(nav.state.stack, <SettingsPage>[SettingsPage.about]);
      nav.home();
      expect(nav.state.stack, isEmpty);
      expect(nav.back(), isFalse);
    });

    test('opening the page that is already open does nothing', () {
      final SettingsNavigationCubit nav = locator<SettingsNavigationCubit>();
      nav.open(SettingsPage.help);
      nav.open(SettingsPage.help);
      expect(nav.state.stack, hasLength(1));
    });

    test('locations are parsed', () {
      expect(SettingsPage.parse(null), isEmpty);
      expect(SettingsPage.parse(''), isEmpty);
      expect(SettingsPage.parse('appearance'), <SettingsPage>[
        SettingsPage.appearance,
      ]);
      expect(SettingsPage.parse('privacy/sessions'), <SettingsPage>[
        SettingsPage.privacy,
        SettingsPage.sessions,
      ]);
      expect(SettingsPage.parse('nonsense'), isEmpty);
    });

    test('search results open the right page', () {
      expect(
        SettingsPage.forSetting(SettingIds.sessions, SettingsSection.privacy),
        SettingsPage.sessions,
      );
      expect(
        SettingsPage.forSetting(SettingIds.biometric, SettingsSection.privacy),
        SettingsPage.privacy,
      );
      expect(SettingsPage.of(SettingsSection.danger), SettingsPage.danger);
      expect(SettingsPage.privacy.isRoot, isTrue);
      expect(SettingsPage.sessions.isRoot, isFalse);
    });

    test('the container opens on the given pages', () {
      final GetIt g = createSettingsLocator(
        initialPages: SettingsPage.parse('privacy/sessions'),
      );
      expect(g<SettingsNavigationCubit>().state.top, SettingsPage.sessions);
    });
  });

  group('SettingsCubit', () {
    test('loads defaults and app info', () async {
      expect(settings().state.status, LoadStatus.loading);
      await settings().load();
      expect(settings().state.status, LoadStatus.ready);
      expect(settings().state.snapshot!.choice(SettingIds.themeMode), 'system');
      expect(settings().state.appInfo!.versionLabel, '2.4.1 (241)');
      expect(settings().themeMode, ThemeMode.system);
    });

    test('a change is applied, saved and reported to the host', () async {
      await settings().load();
      await settings().set(SettingIds.themeMode, 'dark');
      expect(settings().themeMode, ThemeMode.dark);
      expect(modes, <ThemeMode>[ThemeMode.dark]);
      expect(changes.single, (SettingIds.themeMode, 'dark'));
      // Persisted: a second app on the same data source sees it.
      final GetIt again = build();
      await again<SettingsCubit>().load();
      expect(
        again<SettingsCubit>().state.snapshot!.choice(SettingIds.themeMode),
        'dark',
      );
      await again.reset();
    });

    test('other settings do not call onThemeModeChanged', () async {
      await settings().load();
      await settings().set(SettingIds.reduceMotion, true);
      await settings().set(SettingIds.textSize, 3);
      expect(modes, isEmpty);
      expect(changes, hasLength(2));
    });

    test('an unchanged value is not saved or reported', () async {
      await settings().load();
      await settings().set(SettingIds.reduceMotion, false);
      expect(changes, isEmpty);
    });

    test('an invalid value raises a notice and changes nothing', () async {
      await settings().load();
      await settings().set(SettingIds.themeMode, 'pink');
      expect(settings().state.notice!.isError, isTrue);
      expect(settings().state.snapshot!.choice(SettingIds.themeMode), 'system');
      expect(changes, isEmpty);
    });

    test('a failed save puts the old value back', () async {
      final GetIt g = build(data: _FailingSave());
      await g<SettingsCubit>().load();
      await g<SettingsCubit>().set(SettingIds.reduceMotion, true);
      expect(
        g<SettingsCubit>().state.snapshot!.flag(SettingIds.reduceMotion),
        isFalse,
      );
      expect(
        g<SettingsCubit>().state.notice!.title,
        contains('Could not save'),
      );
      await g.reset();
    });

    test('a failed load can be retried', () async {
      final _FlakyLoad flaky = _FlakyLoad();
      final GetIt g = build(data: flaky);
      await g<SettingsCubit>().load();
      expect(g<SettingsCubit>().state.status, LoadStatus.failure);
      flaky.fail = false;
      await g<SettingsCubit>().load();
      expect(g<SettingsCubit>().state.status, LoadStatus.ready);
      await g.reset();
    });

    test('notifications: granted turns the master switch on and off', () async {
      await settings().load();
      await settings().setNotificationsEnabled(false);
      expect(
        settings().state.snapshot!.flag(SettingIds.notificationsMaster),
        isFalse,
      );
      await settings().setNotificationsEnabled(true);
      expect(
        settings().state.snapshot!.flag(SettingIds.notificationsMaster),
        isTrue,
      );
    });

    test('notifications: denied cannot be turned on', () async {
      final GetIt g = build(permission: NotificationPermission.denied);
      await g<SettingsCubit>().load();
      await g<SettingsCubit>().setNotificationsEnabled(false);
      await g<SettingsCubit>().setNotificationsEnabled(true);
      expect(
        g<SettingsCubit>().state.snapshot!.flag(SettingIds.notificationsMaster),
        isFalse,
      );
      await g.reset();
    });

    test('notifications: undecided asks the platform first', () async {
      hooks.onRequestNotificationPermission = () async =>
          NotificationPermission.denied;
      final GetIt g = build(permission: NotificationPermission.notDetermined);
      await g<SettingsCubit>().load();
      await g<SettingsCubit>().setNotificationsEnabled(false);
      await g<SettingsCubit>().setNotificationsEnabled(true);
      expect(
        g<SettingsCubit>().state.notificationPermission,
        NotificationPermission.denied,
      );
      expect(
        g<SettingsCubit>().state.snapshot!.flag(SettingIds.notificationsMaster),
        isFalse,
      );
      hooks.onRequestNotificationPermission = () async =>
          NotificationPermission.granted;
      g<SettingsCubit>().setNotificationPermission(
        NotificationPermission.notDetermined,
      );
      await g<SettingsCubit>().setNotificationsEnabled(true);
      expect(
        g<SettingsCubit>().state.snapshot!.flag(SettingIds.notificationsMaster),
        isTrue,
      );
      await g.reset();
    });
  });

  group('ProfileCubit and ProfileEditCubit', () {
    ProfileEditCubit edit() => locator<ProfileEditViewModel>().cubit;

    Future<void> ready() async {
      await locator<ProfileCubit>().load();
    }

    test('loads the profile from the data source', () async {
      await ready();
      expect(locator<ProfileCubit>().state.profile!.name, 'Ada Lovelace');
    });

    test('a profile given by the host is used as it is', () async {
      final GetIt g = build(
        profile: const Profile(
          name: 'Grace Hopper',
          username: 'grace',
          email: 'grace@example.com',
        ),
      );
      expect(g<ProfileCubit>().state.profile!.name, 'Grace Hopper');
      await g<ProfileCubit>().load();
      expect(g<ProfileCubit>().state.profile!.name, 'Grace Hopper');
      await g.reset();
    });

    test('editing makes it dirty, discarding clears it', () async {
      await ready();
      final ProfileEditCubit c = edit();
      expect(c.state.isDirty, isFalse);
      c.setName('Ada L');
      expect(c.state.isDirty, isTrue);
      c.discard();
      expect(c.state.isDirty, isFalse);
      expect(c.state.draft.name, 'Ada Lovelace');
      await c.close();
    });

    test(
      'errors show only for fields that were touched, then for all',
      () async {
        await ready();
        final ProfileEditCubit c = edit();
        c.setName('');
        expect(c.visibleErrors[ProfileField.name], isNotNull);
        expect(c.visibleErrors[ProfileField.email], isNull);
        c.setEmail('');
        expect(await c.save(), isFalse);
        expect(c.state.submitted, isTrue);
        expect(c.visibleErrors[ProfileField.email], isNotNull);
        await c.close();
      },
    );

    test('the username is checked as it is typed', () async {
      await ready();
      final ProfileEditCubit c = edit();
      await c.setUsername('admin');
      expect(c.state.usernameCheck.status, UsernameStatus.taken);
      expect(await c.save(), isFalse);
      await c.setUsername('A!');
      expect(c.state.usernameCheck.status, UsernameStatus.invalid);
      await c.setUsername('ada_2');
      expect(c.state.usernameCheck.status, UsernameStatus.available);
      await c.setUsername('ada');
      expect(c.state.usernameCheck.message, 'This is you.');
      await c.close();
    });

    test('only the latest username answer is kept', () async {
      await ready();
      final ProfileEditCubit c = edit();
      final Future<void> slow = c.setUsername('admin');
      await c.setUsername('free_name');
      await slow;
      expect(c.state.usernameCheck.status, UsernameStatus.available);
      await c.close();
    });

    test(
      'saving stores it, updates the session profile and raises a notice',
      () async {
        await ready();
        final ProfileEditCubit c = edit();
        c.setName('Ada King');
        c.setAvatar('dusk');
        expect(await c.save(), isTrue);
        expect(c.state.saveStatus, ProfileSaveStatus.saved);
        expect(c.state.isDirty, isFalse);
        expect(c.state.notice!.title, 'Profile saved');
        expect(locator<ProfileCubit>().state.profile!.name, 'Ada King');
        expect(locator<ProfileCubit>().state.profile!.avatarId, 'dusk');
        await c.close();
      },
    );

    test('the guard follows the draft', () async {
      await ready();
      final ProfileEditCubit c = edit();
      final UnsavedChangesGuard guard = locator<UnsavedChangesGuard>();
      expect(guard.hasUnsavedChanges, isFalse);
      guard.isDirty = () => c.state.isDirty;
      c.setBio('hello');
      expect(guard.hasUnsavedChanges, isTrue);
      await c.save();
      expect(guard.hasUnsavedChanges, isFalse);
      await c.close();
    });
  });

  group('search', () {
    test('finds, groups and clears', () {
      final SearchCubit c = locator<SearchViewModel>().cubit;
      expect(c.state.isSearching, isFalse);
      c.setQuery('password');
      expect(c.state.count, greaterThan(0));
      expect(c.state.isEmpty, isFalse);
      c.setQuery('zzzzqqqq');
      expect(c.state.isEmpty, isTrue);
      c.clear();
      expect(c.state.isSearching, isFalse);
      expect(c.state.groups, isEmpty);
    });
  });

  group('privacy', () {
    test(
      'change password: strength follows typing, errors show on submit',
      () async {
        final ChangePasswordCubit c = locator<ChangePasswordViewModel>().cubit;
        c.newPasswordChanged('Abcdefg1!');
        expect(c.state.strength, PasswordStrengthLevel.good);
        expect(c.state.errors.isValid, isTrue);
        expect(await c.submit(current: '', next: 'x', confirm: 'y'), isFalse);
        expect(c.state.errors.isValid, isFalse);
        expect(
          await c.submit(
            current: demoWrongPassword,
            next: 'Abcdefg1!',
            confirm: 'Abcdefg1!',
          ),
          isFalse,
        );
        expect(c.state.notice!.isError, isTrue);
        expect(c.state.errors.errors, isNotEmpty);
        expect(
          await c.submit(
            current: 'ok',
            next: 'Abcdefg1!',
            confirm: 'Abcdefg1!',
          ),
          isTrue,
        );
        expect(c.state.done, isTrue);
        expect(c.state.notice!.title, 'Password changed');
        await c.close();
      },
    );

    test('sessions: revoke one, then all the others', () async {
      final SessionsCubit c = locator<SessionsViewModel>().cubit;
      await c.load();
      expect(c.state.sessions, hasLength(3));
      final DeviceSession mac = c.state.sessions[1];
      await c.revoke(mac);
      expect(c.state.sessions, hasLength(2));
      expect(c.state.notice!.title, contains('MacBook'));
      await c.revokeOthers();
      expect(c.state.sessions, hasLength(1));
      expect(c.state.others, isEmpty);
      // The current device cannot be signed out from here.
      await c.revoke(c.state.sessions.single);
      expect(c.state.notice!.isError, isTrue);
      expect(c.state.sessions, hasLength(1));
      await c.close();
    });

    test('two-factor: key, code step, wrong then right code', () async {
      final TwoFactorCubit c = locator<TwoFactorViewModel>().cubit;
      expect(c.state.loading, isTrue);
      await c.begin();
      expect(c.state.setup!.secret, 'JBSW Y3DP EHPK 3PXP');
      c.next();
      expect(c.state.step, TwoFactorStep.code);
      expect(await c.verify('000000'), isFalse);
      expect(c.state.error, isNotNull);
      expect(c.state.step, TwoFactorStep.code);
      c.back();
      expect(c.state.step, TwoFactorStep.key);
      c.next();
      expect(await c.verify(demoTwoFactorCode), isTrue);
      expect(c.state.step, TwoFactorStep.done);
      await c.close();
    });

    test('export is requested once', () async {
      final PrivacyCubit c = locator<PrivacyViewModel>().cubit;
      await c.requestExport();
      expect(c.state.exportStatus, ExportStatus.requested);
      expect(c.state.request!.id, 'exp_1');
      await c.requestExport();
      expect(c.state.request!.id, 'exp_1');
      expect(await c.disableTwoFactor(), isTrue);
      expect(c.state.exportStatus, ExportStatus.requested);
      await c.close();
    });

    test('blocked users can be unblocked down to an empty list', () async {
      final BlockedUsersCubit c = locator<BlockedUsersViewModel>().cubit;
      await c.load();
      expect(c.state.users, hasLength(2));
      for (final BlockedUser u in <BlockedUser>[...c.state.users]) {
        await c.unblock(u);
      }
      expect(c.state.users, isEmpty);
      expect(c.state.status, LoadStatus.ready);
      await c.close();
    });
  });

  group('storage', () {
    test('clearing the cache frees it and says how much', () async {
      final StorageCubit c = locator<StorageViewModel>().cubit;
      await c.load();
      expect(c.state.usage!.cacheBytes, 92274688);
      await c.clearCache();
      expect(c.state.usage!.cacheBytes, 0);
      expect(c.state.notice!.description, '88 MB reclaimed.');
      expect(c.state.clearing, isFalse);
      await c.close();
    });
  });

  group('support', () {
    test('validation errors, then a sent message clears the form', () async {
      final SupportCubit c = locator<SupportViewModel>().cubit;
      expect(await c.send(subject: '', message: 'x'), isFalse);
      expect(c.state.validation.isValid, isFalse);
      expect(
        await c.send(subject: 'bug', message: 'Something broke on sign in'),
        isTrue,
      );
      expect(c.state.sentCount, 1);
      expect(c.state.notice!.description, contains('SUP-4821'));
      await c.close();
    });
  });

  group('account', () {
    AccountCubit account() => locator<AccountViewModel>().cubit;

    test('sign out calls the host', () {
      final AccountCubit c = account();
      c.signOut();
      expect(signedOut, 1);
      expect(c.state.notice!.title, 'Signed out');
    });

    test('deactivating calls the host', () async {
      final AccountCubit c = account();
      expect(await c.deactivate(), isTrue);
      expect(deactivated, 1);
      expect(deleted, 0);
      await c.close();
    });

    test('deleting needs the exact word and then calls the host', () async {
      final AccountCubit c = account();
      expect(await c.delete('delete'), isFalse);
      expect(deleted, 0);
      expect(c.state.notice!.isError, isTrue);
      expect(await c.delete(deleteConfirmationPhrase), isTrue);
      expect(deleted, 1);
      await c.close();
    });

    test('sign out without a host callback still explains itself', () {
      final GetIt g = createSettingsLocator();
      final AccountCubit c = g<AccountViewModel>().cubit;
      c.signOut();
      expect(c.state.notice!.description, contains('onSignOut'));
    });
  });
}

class _FailingSave extends InMemorySettingsDataSource {
  _FailingSave() : super(latency: Duration.zero);

  @override
  Future<void> saveSettings(Map<String, Object?> json) =>
      Future<void>.error(StateError('offline'));
}

class _FlakyLoad extends InMemorySettingsDataSource {
  _FlakyLoad() : super(latency: Duration.zero);

  bool fail = true;

  @override
  Future<Map<String, Object?>> loadSettings() => fail
      ? Future<Map<String, Object?>>.error(StateError('offline'))
      : super.loadSettings();
}
