import 'package:cairn_template_settings/common/constants/confirmation_phrases.dart';
import 'package:cairn_template_settings/common/constants/text_size_steps.dart';
import 'package:cairn_template_settings/common/utils/byte_format.dart';
import 'package:cairn_template_settings/common/utils/format_preview.dart';
import 'package:cairn_template_settings/common/utils/relative_time.dart';
import 'package:cairn_template_settings/common/utils/settings_failure.dart';
import 'package:cairn_template_settings/data/profile/repositories/profile_repository_impl.dart';
import 'package:cairn_template_settings/data/security/repositories/security_repository_impl.dart';
import 'package:cairn_template_settings/data/settings/remote/in_memory_settings_data_source.dart';
import 'package:cairn_template_settings/data/settings/repositories/settings_repository_impl.dart';
import 'package:cairn_template_settings/data/storage/repositories/storage_repository_impl.dart';
import 'package:cairn_template_settings/data/support/repositories/support_repository_impl.dart';
import 'package:cairn_template_settings/domain/profile/mappers/profile_mapper.dart';
import 'package:cairn_template_settings/domain/profile/models/profile.dart';
import 'package:cairn_template_settings/domain/profile/models/profile_validation.dart';
import 'package:cairn_template_settings/domain/profile/use_cases/check_username.dart';
import 'package:cairn_template_settings/domain/profile/use_cases/save_profile.dart';
import 'package:cairn_template_settings/domain/profile/use_cases/validate_profile.dart';
import 'package:cairn_template_settings/domain/security/mappers/security_mapper.dart';
import 'package:cairn_template_settings/domain/security/models/device_session.dart';
import 'package:cairn_template_settings/domain/security/models/password_strength.dart';
import 'package:cairn_template_settings/domain/security/models/password_validation.dart';
import 'package:cairn_template_settings/domain/security/use_cases/blocked_users.dart';
import 'package:cairn_template_settings/domain/security/use_cases/change_password.dart';
import 'package:cairn_template_settings/domain/security/use_cases/delete_account.dart';
import 'package:cairn_template_settings/domain/security/use_cases/export_data.dart';
import 'package:cairn_template_settings/domain/security/use_cases/get_sessions.dart';
import 'package:cairn_template_settings/domain/security/use_cases/revoke_session.dart';
import 'package:cairn_template_settings/domain/security/use_cases/two_factor_use_cases.dart';
import 'package:cairn_template_settings/domain/settings/mappers/settings_mapper.dart';
import 'package:cairn_template_settings/domain/settings/models/setting_definition.dart';
import 'package:cairn_template_settings/domain/settings/models/settings_section.dart';
import 'package:cairn_template_settings/domain/settings/models/settings_snapshot.dart';
import 'package:cairn_template_settings/domain/settings/registry/default_settings_registry.dart';
import 'package:cairn_template_settings/domain/settings/registry/home_groups.dart';
import 'package:cairn_template_settings/domain/settings/registry/settings_registry.dart';
import 'package:cairn_template_settings/domain/settings/use_cases/search_settings.dart';
import 'package:cairn_template_settings/domain/settings/use_cases/update_setting.dart';
import 'package:cairn_template_settings/domain/storage/mappers/storage_mapper.dart';
import 'package:cairn_template_settings/domain/storage/models/storage_usage.dart';
import 'package:cairn_template_settings/domain/storage/use_cases/storage_use_cases.dart';
import 'package:cairn_template_settings/domain/support/models/support_request.dart';
import 'package:cairn_template_settings/domain/support/use_cases/submit_support_request.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pure logic and the data layer, with no widgets: the registry, the search, the
/// mappers, every use case and the in-memory data source.
void main() {
  final DateTime now = DateTime.utc(2026, 10, 9, 12);
  late InMemorySettingsDataSource source;

  setUp(() {
    source = InMemorySettingsDataSource(latency: Duration.zero, now: () => now);
  });

  group('registry', () {
    test('every id is unique and every default is valid', () {
      final List<String> ids = defaultSettingsRegistry.definitions
          .map((SettingDefinition d) => d.id)
          .toList();
      expect(ids.toSet().length, ids.length);
      for (final SettingDefinition d in defaultSettingsRegistry.definitions) {
        switch (d) {
          case ChoiceSetting():
            expect(d.accepts(d.initial), isTrue, reason: d.id);
            expect(d.options, isNotEmpty);
          case SliderSetting():
            expect(d.accepts(d.initial), isTrue, reason: d.id);
          case ToggleSetting():
            expect(d.accepts(d.initial), isTrue, reason: d.id);
          case ActionSetting() || LinkSetting():
            expect(d.defaultValue, isNull);
        }
      }
    });

    test('duplicate ids are rejected', () {
      expect(
        () => SettingsRegistry(const <SettingDefinition>[
          ToggleSetting(id: 'a', section: SettingsSection.about, title: 'A'),
          ToggleSetting(id: 'a', section: SettingsSection.about, title: 'B'),
        ]),
        throwsArgumentError,
      );
    });

    test('lookups, sections and defaults', () {
      final SettingsRegistry r = defaultSettingsRegistry;
      expect(r.contains(SettingIds.themeMode), isTrue);
      expect(r.contains('nope'), isFalse);
      expect(r.maybe<ChoiceSetting>(SettingIds.themeMode), isNotNull);
      expect(r.maybe<ToggleSetting>(SettingIds.themeMode), isNull);
      expect(r.sections, SettingsSection.values);
      expect(
        r.inSection(SettingsSection.danger).map((SettingDefinition d) => d.id),
        <String>[
          SettingIds.signOut,
          SettingIds.deactivate,
          SettingIds.deleteAccount,
        ],
      );
      expect(r.defaults[SettingIds.themeMode], 'system');
      expect(r.defaults[SettingIds.textSize], TextSizeSteps.defaultStep);
      expect(r.defaults.containsKey(SettingIds.signOut), isFalse);
    });

    test('the home groups cover every section exactly once', () {
      final List<SettingsSection> grouped = <SettingsSection>[
        for (final ({String title, List<SettingsSection> sections}) g
            in HomeGroups.all)
          ...g.sections,
      ];
      expect(grouped.toSet(), SettingsSection.values.toSet());
      expect(grouped.length, SettingsSection.values.length);
    });

    test('a section is found by id', () {
      expect(SettingsSection.fromId('privacy'), SettingsSection.privacy);
      expect(SettingsSection.fromId('nope'), isNull);
    });

    test('value validation per kind', () {
      final SettingsRegistry r = defaultSettingsRegistry;
      expect(r.byId(SettingIds.reduceMotion)!.accepts(true), isTrue);
      expect(r.byId(SettingIds.reduceMotion)!.accepts('yes'), isFalse);
      expect(r.byId(SettingIds.themeMode)!.accepts('dark'), isTrue);
      expect(r.byId(SettingIds.themeMode)!.accepts('pink'), isFalse);
      expect(r.byId(SettingIds.textSize)!.accepts(3), isTrue);
      expect(r.byId(SettingIds.textSize)!.accepts(4), isFalse);
      expect(r.byId(SettingIds.textSize)!.accepts(1.5), isFalse);
      expect(r.byId(SettingIds.signOut)!.accepts(true), isFalse);
      expect(
        r.maybe<ChoiceSetting>(SettingIds.region)!.labelOf('GB'),
        'United Kingdom',
      );
    });
  });

  group('search', () {
    final SearchSettings s = SearchSettings(defaultSettingsRegistry);

    List<String> ids(String q) => <String>[
      for (final SettingsSearchGroup g in s(q))
        for (final SettingDefinition d in g.hits) d.id,
    ];

    test('blank queries match nothing', () {
      expect(s(''), isEmpty);
      expect(s('   '), isEmpty);
    });

    test('matches titles, keywords and descriptions, ignoring case', () {
      expect(ids('password'), contains(SettingIds.changePassword));
      expect(ids('PASSWORD'), contains(SettingIds.changePassword));
      expect(ids('dark'), contains(SettingIds.themeMode));
      expect(ids('2fa'), contains(SettingIds.twoFactor));
      expect(ids('master switch'), contains(SettingIds.notificationsMaster));
    });

    test('every word must match', () {
      expect(ids('dark zebra'), isEmpty);
      expect(ids('quiet hours'), contains(SettingIds.quietHours));
    });

    test('results are grouped by section in order, best match first', () {
      final List<SettingsSection> sections = s(
        'notif',
      ).map((SettingsSearchGroup g) => g.section).toList();
      final List<SettingsSection> sorted = <SettingsSection>[...sections]
        ..sort((SettingsSection a, SettingsSection b) => a.index - b.index);
      expect(sections, sorted);
      expect(s('mess').first.hits.first.id, 'notifications.messages');
    });

    test('a title match outranks a keyword match', () {
      final SettingsSearchGroup danger = s('sign').firstWhere(
        (SettingsSearchGroup g) => g.section == SettingsSection.danger,
      );
      expect(danger.hits.first.id, SettingIds.signOut);
    });

    test('nonsense finds nothing', () {
      expect(s('qqqqzzzz'), isEmpty);
    });

    test('a registry without a setting does not find it', () {
      final SettingsRegistry smaller = SettingsRegistry(
        defaultSettingsRegistry.definitions.where(
          (SettingDefinition d) => d.id != SettingIds.reduceMotion,
        ),
      );
      expect(
        SearchSettings(smaller)(
          'reduce',
        ).expand((SettingsSearchGroup g) => g.hits),
        isEmpty,
      );
    });
  });

  group('settings mapper', () {
    final SettingsMapper mapper = SettingsMapper(defaultSettingsRegistry);

    test('an empty or malformed blob gives the defaults', () {
      expect(
        mapper.snapshotFromJson(null).values,
        defaultSettingsRegistry.defaults,
      );
      expect(
        mapper.snapshotFromJson(<String, Object?>{'values': 5}).values,
        defaultSettingsRegistry.defaults,
      );
    });

    test('valid values are kept, invalid ones repaired, unknown dropped', () {
      final SettingsSnapshot s = mapper.snapshotFromJson(<String, Object?>{
        'schema': 1,
        'values': <String, Object?>{
          SettingIds.themeMode: 'dark',
          SettingIds.textSize: 9,
          SettingIds.reduceMotion: 'yes',
          'removed.setting': true,
        },
      });
      expect(s.choice(SettingIds.themeMode), 'dark');
      expect(s.step(SettingIds.textSize), TextSizeSteps.defaultStep);
      expect(s.flag(SettingIds.reduceMotion), isFalse);
      expect(s.values.containsKey('removed.setting'), isFalse);
    });

    test('toJson round-trips', () {
      final SettingsSnapshot s = mapper
          .snapshotFromJson(null)
          .set(SettingIds.accent, 'forest');
      final Map<String, Object?> json = mapper.snapshotToJson(s);
      expect(json['schema'], SettingsMapper.schema);
      expect(mapper.snapshotFromJson(json), s);
    });

    test('app info is read with blanks for what is missing', () {
      final info = mapper.appInfoFromJson(<String, Object?>{
        'name': 'X',
        'version': '1.2.3',
        'build': 45,
        'licences': <Object?>[
          <String, Object?>{'name': 'a', 'licence': 'MIT'},
          'junk',
        ],
      });
      expect(info.versionLabel, '1.2.3 (45)');
      expect(info.licences.single.name, 'a');
      expect(mapper.appInfoFromJson(<String, Object?>{}).name, 'App');
    });
  });

  group('UpdateSetting', () {
    late UpdateSetting update;
    late SettingsRepositoryImpl repo;
    late SettingsSnapshot start;

    setUp(() {
      final SettingsMapper mapper = SettingsMapper(defaultSettingsRegistry);
      repo = SettingsRepositoryImpl(source, mapper);
      update = UpdateSetting(defaultSettingsRegistry, repo);
      start = mapper.snapshotFromJson(null);
    });

    test('changes and persists a valid value', () async {
      final SettingsSnapshot next = await update(
        start,
        SettingIds.themeMode,
        'dark',
      );
      expect(next.choice(SettingIds.themeMode), 'dark');
      expect((await repo.load()).choice(SettingIds.themeMode), 'dark');
    });

    test('rejects unknown ids and invalid values, saving nothing', () async {
      await expectLater(
        update(start, 'nope', true),
        throwsA(isA<SettingsFailure>()),
      );
      await expectLater(
        update(start, SettingIds.themeMode, 'pink'),
        throwsA(isA<SettingsFailure>()),
      );
      await expectLater(
        update(start, SettingIds.signOut, true),
        throwsA(isA<SettingsFailure>()),
      );
      expect((await repo.load()).values, start.values);
    });
  });

  group('profile', () {
    const ValidateProfile validate = ValidateProfile();
    const Profile good = Profile(
      name: 'Ada Lovelace',
      username: 'ada_l',
      email: 'ada@example.com',
    );

    test('a good profile is valid', () {
      expect(validate(good).isValid, isTrue);
    });

    test('each field reports its own problem', () {
      final ProfileValidation v = validate(
        const Profile(name: ' ', username: 'A!', email: 'nope', bio: ''),
      );
      expect(v[ProfileField.name], isNotNull);
      expect(v[ProfileField.username], isNotNull);
      expect(v[ProfileField.email], isNotNull);
      expect(v[ProfileField.bio], isNull);
      expect(
        validate(good.copyWith(bio: 'x' * 161))[ProfileField.bio],
        isNotNull,
      );
    });

    test('username rules', () {
      expect(ValidateProfile.usernameProblem(''), isNotNull);
      expect(ValidateProfile.usernameProblem('ab'), contains('at least'));
      expect(ValidateProfile.usernameProblem('a' * 21), contains('or fewer'));
      expect(ValidateProfile.usernameProblem('Ada'), isNotNull);
      expect(ValidateProfile.usernameProblem('a b c'), isNotNull);
      expect(ValidateProfile.usernameProblem('ada.l_9'), isNull);
    });

    test('initials come from the first two words', () {
      expect(good.initials, 'AL');
      expect(good.copyWith(name: 'madonna').initials, 'M');
      expect(good.copyWith(name: '  ').initials, '?');
    });

    test('the mapper repairs an unknown avatar and round-trips', () {
      final Profile p = ProfileMapper.fromJson(<String, Object?>{
        'name': 'A',
        'avatar': 'lava',
      });
      expect(p.avatarId, 'initials');
      expect(ProfileMapper.fromJson(ProfileMapper.toJson(good)), good);
    });

    test('CheckUsername: format first, then availability', () async {
      final CheckUsername check = CheckUsername(ProfileRepositoryImpl(source));
      expect((await check('')).status, UsernameStatus.unknown);
      expect((await check('A!')).status, UsernameStatus.invalid);
      expect((await check('admin')).status, UsernameStatus.taken);
      expect((await check('fresh_name')).status, UsernameStatus.available);
      // The person's own username is always theirs.
      expect(
        (await check('admin', current: 'admin')).status,
        UsernameStatus.available,
      );
    });

    test('SaveProfile validates, checks the name and trims', () async {
      final SaveProfile save = SaveProfile(
        validate,
        ProfileRepositoryImpl(source),
      );
      await expectLater(
        save(good.copyWith(name: ''), savedUsername: 'ada'),
        throwsA(isA<SettingsFailure>()),
      );
      await expectLater(
        save(good.copyWith(username: 'admin'), savedUsername: 'ada'),
        throwsA(
          isA<SettingsFailure>().having(
            (SettingsFailure f) => f.message,
            'message',
            contains('taken'),
          ),
        ),
      );
      final Profile stored = await save(
        good.copyWith(name: '  Ada L  '),
        savedUsername: 'ada_l',
      );
      expect(stored.name, 'Ada L');
      expect((await ProfileRepositoryImpl(source).load()).name, 'Ada L');
    });
  });

  group('password', () {
    final ChangePassword change = ChangePassword(
      SecurityRepositoryImpl(
        InMemorySettingsDataSource(latency: Duration.zero),
      ),
    );

    test('strength levels', () {
      expect(PasswordStrength.of(''), PasswordStrengthLevel.empty);
      expect(PasswordStrength.of('abc'), PasswordStrengthLevel.weak);
      expect(PasswordStrength.of('abcdefgh'), PasswordStrengthLevel.weak);
      expect(PasswordStrength.of('abcdefgh1'), PasswordStrengthLevel.weak);
      expect(PasswordStrength.of('Abcdefg1'), PasswordStrengthLevel.fair);
      expect(PasswordStrength.of('Abcdefg1!'), PasswordStrengthLevel.good);
      expect(PasswordStrength.of('Abcdefghij1!'), PasswordStrengthLevel.strong);
      expect(PasswordStrengthLevel.strong.score, 4);
    });

    test('validate reports each field', () {
      final PasswordValidation v = change.validate(
        current: '',
        next: 'short',
        confirm: 'other',
      );
      expect(v[PasswordField.current], isNotNull);
      expect(v[PasswordField.next], contains('at least 8'));
      expect(v[PasswordField.confirm], isNotNull);
      expect(
        change
            .validate(current: 'x', next: 'password', confirm: 'password')
            .errors[PasswordField.next],
        contains('Too easy'),
      );
      expect(
        change
            .validate(
              current: 'Abcdefg1!',
              next: 'Abcdefg1!',
              confirm: 'Abcdefg1!',
            )
            .errors[PasswordField.next],
        contains('not using'),
      );
      expect(
        change
            .validate(current: 'x', next: 'Abcdefg1!', confirm: 'Abcdefg1!')
            .isValid,
        isTrue,
      );
    });

    test('call changes the password, or explains why not', () async {
      await change(current: 'old', next: 'Abcdefg1!', confirm: 'Abcdefg1!');
      await expectLater(
        change(
          current: demoWrongPassword,
          next: 'Abcdefg1!',
          confirm: 'Abcdefg1!',
        ),
        throwsA(
          isA<SettingsFailure>().having(
            (SettingsFailure f) => f.message,
            'message',
            contains('not right'),
          ),
        ),
      );
      await expectLater(
        change(current: 'old', next: 'a', confirm: 'b'),
        throwsA(isA<SettingsFailure>()),
      );
    });
  });

  group('sessions and 2FA', () {
    late SecurityRepositoryImpl repo;
    setUp(() => repo = SecurityRepositoryImpl(source));

    test('sessions are mapped, current device first', () async {
      final List<DeviceSession> sessions = await GetSessions(repo)();
      expect(sessions.first.isCurrent, isTrue);
      expect(sessions.length, 3);
      expect(sessions.skip(1).map((DeviceSession s) => s.device), <String>[
        'MacBook Pro',
        'iPad Air',
      ]);
    });

    test('RevokeSession signs another device out, never this one', () async {
      final RevokeSession revoke = RevokeSession(repo);
      final List<DeviceSession> before = await GetSessions(repo)();
      await expectLater(revoke(before.first), throwsA(isA<SettingsFailure>()));
      await revoke(before[1]);
      expect(await GetSessions(repo)(), hasLength(2));
      await revoke.others();
      expect(await GetSessions(repo)(), hasLength(1));
    });

    test('revoking a session that is gone fails politely', () async {
      await expectLater(
        RevokeSession(repo)(
          DeviceSession(
            id: 'ghost',
            device: 'x',
            location: 'y',
            lastActive: now,
          ),
        ),
        throwsA(isA<SettingsFailure>()),
      );
    });

    test('two-factor: key, code format, code check, disable', () async {
      final TwoFactorSetup setup = await BeginTwoFactor(repo)();
      expect(setup.secret, 'JBSW Y3DP EHPK 3PXP');
      final VerifyTwoFactor verify = VerifyTwoFactor(repo);
      expect(VerifyTwoFactor.isWellFormed('123456'), isTrue);
      expect(VerifyTwoFactor.isWellFormed('12345'), isFalse);
      expect(VerifyTwoFactor.isWellFormed('12345a'), isFalse);
      await expectLater(verify('12'), throwsA(isA<SettingsFailure>()));
      await expectLater(verify('000000'), throwsA(isA<SettingsFailure>()));
      await verify(demoTwoFactorCode);
      await DisableTwoFactor(repo)();
    });

    test('export and blocked users', () async {
      final request = await ExportData(repo)();
      expect(request.id, 'exp_1');
      expect(request.requestedAt, now);
      final List<BlockedUser> blocked = await GetBlockedUsers(repo)();
      expect(blocked, hasLength(2));
      await UnblockUser(repo)(blocked.first.id);
      expect(await GetBlockedUsers(repo)(), hasLength(1));
    });

    test('the mapper copes with junk', () {
      expect(
        SecurityMapper.sessionsFromJson(<String, Object?>{
          'sessions': <Object?>[
            5,
            <String, Object?>{'id': 'a'},
          ],
        }).single.device,
        'Unknown device',
      );
      expect(SecurityMapper.blockedFromJson(<String, Object?>{}), isEmpty);
    });
  });

  group('DeleteAccount', () {
    test('the confirmation is exact', () {
      expect(DeleteAccount.isConfirmed('DELETE'), isTrue);
      expect(DeleteAccount.isConfirmed(' DELETE '), isTrue);
      expect(DeleteAccount.isConfirmed('delete'), isFalse);
      expect(DeleteAccount.isConfirmed('DELET'), isFalse);
      expect(DeleteAccount.isConfirmed(''), isFalse);
    });

    test('nothing is deleted without it', () async {
      final DeleteAccount delete = DeleteAccount(
        SecurityRepositoryImpl(source),
      );
      await expectLater(delete('nope'), throwsA(isA<SettingsFailure>()));
      await delete('DELETE');
      await DeactivateAccount(SecurityRepositoryImpl(source))();
    });
  });

  group('storage', () {
    test('usage adds up and the cache clears', () async {
      final StorageRepositoryImpl repo = StorageRepositoryImpl(source);
      final StorageUsage usage = await GetStorageUsage(repo)();
      expect(usage.categories.length, 4);
      expect(usage.usedBytes + usage.freeBytes, usage.capacityBytes);
      expect(usage.cacheBytes, 92274688);
      final int reclaimed = await ClearCache(repo)();
      expect(reclaimed, 92274688);
      expect((await GetStorageUsage(repo)()).cacheBytes, 0);
      expect(usage.withoutCache().cacheBytes, 0);
      expect(usage.withoutCache().usedBytes, usage.usedBytes - reclaimed);
    });

    test('the mapper copes with junk', () {
      expect(
        StorageMapper.usageFromJson(<String, Object?>{}).categories,
        isEmpty,
      );
      expect(StorageMapper.reclaimedFromJson(<String, Object?>{}), 0);
    });

    test('bytes read well', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(1023), '1023 B');
      expect(formatBytes(1024), '1 KB');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(92274688), '88 MB');
      expect(formatBytes(1288490189), '1.2 GB');
      expect(formatBytes(5368709120), '5 GB');
    });
  });

  group('support', () {
    test('validation and sending', () async {
      final SubmitSupportRequest submit = SubmitSupportRequest(
        SupportRepositoryImpl(source),
      );
      expect(
        submit
            .validate(const SupportRequest(subject: '', message: 'hi'))
            .isValid,
        isFalse,
      );
      final SupportValidation v = submit.validate(
        const SupportRequest(subject: 'bug', message: 'short'),
      );
      expect(v.subjectError, isNull);
      expect(v.messageError, isNotNull);
      expect(
        submit
            .validate(SupportRequest(subject: 'bug', message: 'x' * 1001))
            .messageError,
        isNotNull,
      );
      await expectLater(
        submit(const SupportRequest(subject: 'bug', message: 'x')),
        throwsA(isA<SettingsFailure>()),
      );
      expect(
        await submit(
          const SupportRequest(subject: 'bug', message: 'It does not work'),
        ),
        'SUP-4821',
      );
    });
  });

  group('formatting helpers', () {
    test('relative time', () {
      expect(describeActivity(now, now), 'Active now');
      expect(
        describeActivity(now.subtract(const Duration(minutes: 1)), now),
        'Active 1 minute ago',
      );
      expect(
        describeActivity(now.subtract(const Duration(minutes: 30)), now),
        'Active 30 minutes ago',
      );
      expect(
        describeActivity(now.subtract(const Duration(hours: 3)), now),
        'Active 3 hours ago',
      );
      expect(
        describeActivity(now.subtract(const Duration(days: 5)), now),
        'Active 5 days ago',
      );
      expect(
        describeActivity(now.subtract(const Duration(days: 30)), now),
        'Active 4 weeks ago',
      );
    });

    test('format preview', () {
      expect(FormatPreview.date('dmy'), '31/12/2026');
      expect(FormatPreview.date('mdy'), '12/31/2026');
      expect(FormatPreview.date('ymd'), '2026-12-31');
      expect(FormatPreview.time('24h'), '14:30');
      expect(FormatPreview.time('12h'), '2:30 PM');
      expect(FormatPreview.distance('imperial'), '3.1 mi');
      expect(FormatPreview.temperature('metric'), '21 C');
    });

    test('text size steps', () {
      expect(TextSizeSteps.factorOf(0), lessThan(1));
      expect(TextSizeSteps.factorOf(1), 1);
      expect(TextSizeSteps.factorOf(3), greaterThan(1.2));
      expect(TextSizeSteps.factorOf(99), TextSizeSteps.factors.last);
      expect(TextSizeSteps.labels.length, TextSizeSteps.factors.length);
    });
  });
}
