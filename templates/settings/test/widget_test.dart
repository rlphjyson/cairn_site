import 'package:cairn_template_settings/cairn_template_settings.dart';
import 'package:cairn_template_settings/common/constants/confirmation_phrases.dart';
import 'package:cairn_template_settings/core/presentation/settings_appearance.dart';
import 'package:cairn_template_settings/core/presentation/widgets/setting_rows.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/settings_harness.dart';

/// Every page, mounted in the sizes and themes the template is built for and
/// driven the way a person would. Flutter fails a test on any RenderFlex
/// overflow, so passing at every width and text scale also means no overflow.
void main() {
  const List<String?> allPages = <String?>[
    null,
    'profile',
    'appearance',
    'notifications',
    'privacy',
    'privacy/changePassword',
    'privacy/sessions',
    'privacy/blockedUsers',
    'language',
    'storage',
    'help',
    'about',
    'danger',
  ];

  CairnTheme themeOf(WidgetTester tester) =>
      CairnTheme.of(tester.element(find.byType(CairnList).first));

  Finder radio(String value) => find.byWidgetPredicate(
    (Widget w) => w is CairnRadioItem<String> && w.value == value,
  );

  Finder named(String label) => find.byWidgetPredicate(
    (Widget w) => w is Semantics && w.properties.label == label,
    description: 'semantics "$label"',
  );

  Finder select(String label) => find.byWidgetPredicate(
    (Widget w) => w is CairnSelect<String> && w.semanticLabel == label,
  );

  /// The switch inside the toggle row titled [title].
  CairnSwitch switchIn(WidgetTester tester, String title) => tester.widget(
    find.descendant(
      of: find.byWidgetPredicate(
        (Widget w) => w is ToggleRow && w.title == title,
      ),
      matching: find.byType(CairnSwitch),
    ),
  );

  for (final double width in testWidths) {
    final bool wide = width >= 600;
    final double height = width == 320 ? 640 : (wide ? 1000 : 780);

    for (final bool dark in <bool>[false, true]) {
      final String where = '${width.toInt()}px ${dark ? 'dark' : 'light'}';

      group('every page at $where', () {
        for (final double scale in <double>[1, 1.3, 2]) {
          testWidgets('renders at text scale $scale without overflow', (
            tester,
          ) async {
            for (final String? page in allPages) {
              await mountSettings(
                tester,
                width: width,
                height: height,
                dark: dark,
                textScale: scale,
                initialLocation: page,
              );
              await pumpFrames(tester, 4);
              expect(
                tester.takeException(),
                isNull,
                reason: 'page ${page ?? 'home'}',
              );
              expect(find.byType(SettingsApp), findsOneWidget);
            }
          });
        }

        testWidgets('follows the platform brightness while on System', (
          tester,
        ) async {
          await mountSettings(tester, width: width, height: height, dark: dark);
          expect(
            themeOf(tester).brightness,
            dark ? Brightness.dark : Brightness.light,
          );
        });
      });
    }

    group('flows at ${width.toInt()}px', () {
      testWidgets('the home lists the profile and every group', (tester) async {
        await mountSettings(tester, width: width, height: height);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Ada Lovelace'), findsWidgets);
        expect(find.text('ada@example.com'), findsWidgets);
        for (final String group in <String>[
          'Account',
          'Preferences',
          'Data and support',
        ]) {
          expect(find.text(group), findsOneWidget);
        }
        for (final String title in <String>[
          'Privacy and security',
          'Appearance',
          'Notifications',
          'Language and region',
          'Storage and data',
          'Help',
          'About',
        ]) {
          expect(find.text(title), findsOneWidget, reason: title);
        }
        // Current values show at the end of the row.
        expect(find.text('English'), findsOneWidget);
        expect(find.text('On'), findsOneWidget);
      });

      testWidgets('search filters by keyword, groups and finds nothing', (
        tester,
      ) async {
        await mountSettings(tester, width: width, height: height);
        await typeInto(tester, 'Search settings', 'password');
        expect(find.text('1 result'), findsOneWidget);
        expect(find.text('Privacy and security'), findsOneWidget);
        expect(find.text('Change password'), findsOneWidget);
        expect(find.text('Appearance'), findsNothing);

        await typeInto(tester, 'Search settings', 'dark');
        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);

        await typeInto(tester, 'Search settings', 'zzzzqqq');
        expect(find.text('No results'), findsOneWidget);
        expect(find.textContaining('zzzzqqq'), findsWidgets);

        await tapOn(tester, buttonNamed('Clear search'));
        expect(find.text('No results'), findsNothing);
        expect(find.text('Ada Lovelace'), findsWidgets);
      });

      testWidgets('a search result opens its page', (tester) async {
        await mountSettings(tester, width: width, height: height);
        await typeInto(tester, 'Search settings', 'sessions');
        await tapRow(tester, 'Active sessions');
        expect(find.text('Sign out all other devices'), findsOneWidget);
        expect(find.text('MacBook Pro'), findsOneWidget);
      });

      testWidgets('categories open and go back', (tester) async {
        await mountSettings(tester, width: width, height: height);
        await tapRow(tester, 'Language and region');
        expect(find.text('Preview'), findsOneWidget);
        if (wide) {
          // The list stays beside the page.
          expect(find.text('Search settings'), findsWidgets);
          expect(buttonNamed('Back'), findsNothing);
        } else {
          expect(buttonNamed('Back'), findsOneWidget);
          await tapOn(tester, buttonNamed('Back'));
          expect(find.text('Settings'), findsOneWidget);
          expect(find.text('Preview'), findsNothing);
        }
      });

      testWidgets('the system back goes up one page', (tester) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy/sessions',
        );
        expect(find.text('Sign out all other devices'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await pumpFrames(tester);
        expect(find.text('Sign out all other devices'), findsNothing);
        expect(find.text('Biometric lock'), findsOneWidget);
      });

      testWidgets('edit profile: validation, username check, save, toast', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'profile',
        );
        expect(find.text('27/160'), findsOneWidget);
        // Saving is pointless until something changes.
        expect(
          tester.widget<CairnButton>(button('Save changes')).onPressed,
          isNull,
        );

        await typeInto(tester, 'Name', '');
        expect(find.text('Enter your name.'), findsOneWidget);
        await typeInto(tester, 'Name', 'Ada King');
        expect(find.text('Enter your name.'), findsNothing);

        await typeInto(tester, 'Username', 'admin');
        expect(find.text('@admin is taken.'), findsOneWidget);
        await typeInto(tester, 'Username', 'A!a!');
        expect(find.textContaining('Use lower case'), findsWidgets);
        await typeInto(tester, 'Username', 'ada_king');
        expect(find.text('@ada_king is available.'), findsOneWidget);

        await typeInto(tester, 'Email', 'nope');
        await tapButton(tester, 'Save changes');
        expect(find.text('Enter a valid email address.'), findsOneWidget);
        await typeInto(tester, 'Email', 'ada@example.com');

        await typeInto(tester, 'Bio', 'x' * 200);
        expect(find.text('160/160'), findsOneWidget);
        await typeInto(tester, 'Bio', 'Counting.');
        expect(find.text('9/160'), findsOneWidget);

        await tester.tap(named('Dusk'), warnIfMissed: false);
        await pumpFrames(tester, 2);

        await tapButton(tester, 'Save changes');
        expect(find.text('Profile saved'), findsOneWidget);
        final Map<String, Object?> stored = await h.source.loadProfile();
        expect(stored['name'], 'Ada King');
        expect(stored['username'], 'ada_king');
        expect(stored['bio'], 'Counting.');
        expect(stored['avatar'], 'dusk');
        // The button goes back to disabled: nothing to save.
        expect(
          tester.widget<CairnButton>(button('Save changes')).onPressed,
          isNull,
        );
      });

      testWidgets('edit profile: leaving with changes asks first', (
        tester,
      ) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'profile',
        );
        await typeInto(tester, 'Name', 'Ada L');

        if (wide) {
          await tapRow(tester, 'Appearance');
        } else {
          await tapOn(tester, buttonNamed('Back'));
        }
        expect(find.text('Discard changes?'), findsOneWidget);

        // Keep editing: the form and the text are still there.
        await tapButton(tester, 'Keep editing');
        expect(find.text('Discard changes?'), findsNothing);
        expect(find.text('Edit profile'), findsWidgets);
        expect(find.text('Ada L'), findsOneWidget);

        // The system back asks too.
        if (!wide) {
          await tester.binding.handlePopRoute();
          await pumpFrames(tester);
          expect(find.text('Discard changes?'), findsOneWidget);
          await tapButton(tester, 'Keep editing');
        }

        // Discard: leave, and the next visit starts clean.
        if (wide) {
          await tapRow(tester, 'Appearance');
        } else {
          await tapOn(tester, buttonNamed('Back'));
        }
        await tapButton(tester, 'Discard');
        expect(find.text('Discard changes?'), findsNothing);
        if (wide) {
          expect(find.text('Text size'), findsOneWidget);
        } else {
          expect(find.text('Settings'), findsOneWidget);
        }
        await tapRow(tester, 'Edit profile');
        expect(find.text('Ada Lovelace'), findsWidgets);
      });

      testWidgets('edit profile: leaving without changes does not ask', (
        tester,
      ) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'profile',
        );
        if (wide) {
          await tapRow(tester, 'Appearance');
          expect(find.text('Text size'), findsOneWidget);
        } else {
          await tapOn(tester, buttonNamed('Back'));
          expect(find.text('Settings'), findsOneWidget);
        }
        expect(find.text('Discard changes?'), findsNothing);
      });

      testWidgets('appearance: the theme changes the whole template live', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'appearance',
        );
        expect(themeOf(tester).brightness, Brightness.light);
        final Color lightBackground = themeOf(tester).background;

        await tapOn(tester, radio('dark'));
        expect(themeOf(tester).brightness, Brightness.dark);
        expect(themeOf(tester).background, isNot(lightBackground));
        expect(h.modes, <ThemeMode>[ThemeMode.dark]);

        await tapOn(tester, radio('light'));
        expect(themeOf(tester).brightness, Brightness.light);
        expect(h.modes, <ThemeMode>[ThemeMode.dark, ThemeMode.light]);

        await tapOn(tester, radio('system'));
        expect(h.modes.last, ThemeMode.system);
        expect(h.changes.last, (SettingIds.themeMode, 'system'));
      });

      testWidgets('appearance: text size scales the text, with a sample', (
        tester,
      ) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'appearance',
        );
        double scaleOf() => MediaQuery.textScalerOf(
          tester.element(find.text('Text size').first),
        ).scale(100);
        expect(scaleOf(), closeTo(100, 0.01));
        expect(find.text('Default'), findsOneWidget);

        await tester.drag(find.byType(CairnSlider), const Offset(400, 0));
        await pumpFrames(tester);
        expect(find.text('Extra large'), findsOneWidget);
        expect(scaleOf(), closeTo(130, 0.01));
        expect(
          find.text('The quick brown fox jumps over the lazy dog.'),
          findsOneWidget,
        );

        await tester.drag(find.byType(CairnSlider), const Offset(-400, 0));
        await pumpFrames(tester);
        expect(find.text('Small'), findsOneWidget);
        expect(scaleOf(), closeTo(90, 0.01));
      });

      testWidgets('appearance: the accent and reduce motion apply live', (
        tester,
      ) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'appearance',
        );
        final Color ink = themeOf(tester).primary;
        await tester.tap(named('Ocean'), warnIfMissed: false);
        await pumpFrames(tester);
        expect(
          themeOf(tester).primary,
          SettingsAppearance.accentColor('ocean', Brightness.light),
        );
        expect(themeOf(tester).primary, isNot(ink));
        await tester.tap(named('Ink'), warnIfMissed: false);
        await pumpFrames(tester);
        expect(themeOf(tester).primary, ink);

        expect(
          MediaQuery.disableAnimationsOf(
            tester.element(find.text('Reduce motion')),
          ),
          isFalse,
        );
        await tapRow(tester, 'Reduce motion');
        expect(
          MediaQuery.disableAnimationsOf(
            tester.element(find.text('Reduce motion')),
          ),
          isTrue,
        );
      });

      testWidgets('notifications: the master switch greys out the rest', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'notifications',
        );
        expect(switchIn(tester, 'Messages').onChanged, isNotNull);
        expect(
          tester.widget<CairnSelect<String>>(select('From')).onChanged,
          isNull,
          reason: 'quiet hours is off',
        );

        await tapRow(tester, 'Allow notifications');
        expect(switchIn(tester, 'Allow notifications').value, isFalse);
        expect(switchIn(tester, 'Messages').onChanged, isNull);
        expect(switchIn(tester, 'Quiet hours').onChanged, isNull);
        expect(
          tester
              .widget<CairnRadioGroup<String>>(
                find.byWidgetPredicate(
                  (Widget w) =>
                      w is CairnRadioGroup<String> &&
                      w.semanticLabel == 'Digest',
                ),
              )
              .onChanged,
          isNull,
        );
        // A greyed-out row ignores taps.
        await tapRow(tester, 'Messages');
        expect(h.changes.map(((String, Object?) c) => c.$1), <String>[
          SettingIds.notificationsMaster,
        ]);

        await tapRow(tester, 'Allow notifications');
        expect(switchIn(tester, 'Messages').onChanged, isNotNull);
      });

      testWidgets('notifications: categories, channel, digest', (tester) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'notifications',
        );
        expect(switchIn(tester, 'Offers and tips').value, isFalse);
        await tapRow(tester, 'Offers and tips');
        expect(switchIn(tester, 'Offers and tips').value, isTrue);
        await tapOn(tester, radio('both'));
        await tapOn(tester, radio('weekly'));
        expect(h.changes, <(String, Object?)>[
          ('notifications.marketing', true),
          ('notifications.channel', 'both'),
          ('notifications.digest', 'weekly'),
        ]);
      });

      testWidgets('notifications: quiet hours with start and end times', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'notifications',
        );
        await tapRow(tester, 'Quiet hours');
        expect(
          tester.widget<CairnSelect<String>>(select('From')).onChanged,
          isNotNull,
        );
        expect(
          tester.widget<CairnSelect<String>>(select('Until')).onChanged,
          isNotNull,
        );
        expect(find.text('22:00'), findsOneWidget);
        expect(find.text('07:00'), findsOneWidget);

        await tapOn(tester, select('From'));
        await tapOn(tester, find.text('23:30').last);
        expect(find.text('23:30'), findsOneWidget);
        await tapOn(tester, select('Until'));
        await tapOn(tester, find.text('06:30').last);
        expect(find.text('06:30'), findsOneWidget);
        expect(h.changes.map(((String, Object?) c) => c.$2), <Object?>[
          true,
          '23:30',
          '06:30',
        ]);
      });

      testWidgets('notifications: a refused permission explains itself', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'notifications',
          permission: NotificationPermission.denied,
        );
        expect(find.text('Notifications are blocked'), findsOneWidget);
        expect(switchIn(tester, 'Allow notifications').value, isFalse);
        expect(switchIn(tester, 'Allow notifications').onChanged, isNull);
        expect(switchIn(tester, 'Messages').onChanged, isNull);
        await tapButton(tester, 'Open settings');
        expect(h.systemSettingsOpened, 1);
      });

      testWidgets('privacy: biometric lock is reported to the host', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy',
        );
        await tapRow(tester, 'Biometric lock');
        expect(switchIn(tester, 'Biometric lock').value, isTrue);
        expect(h.changes.single, (SettingIds.biometric, true));
      });

      testWidgets('change password: validation, strength, errors, success', (
        tester,
      ) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy/changePassword',
        );
        await typeInto(tester, 'New password', 'abc');
        expect(find.text('Weak'), findsOneWidget);
        await typeInto(tester, 'New password', 'Abcdefg1!');
        expect(find.text('Good'), findsOneWidget);
        await typeInto(tester, 'New password', 'Abcdefghij1!');
        expect(find.text('Strong'), findsOneWidget);

        // Nothing is said until the form is sent.
        expect(find.text('Enter your current password.'), findsNothing);
        await tapButton(tester, 'Change password');
        expect(find.text('Enter your current password.'), findsOneWidget);
        expect(find.text('The passwords do not match.'), findsOneWidget);

        await typeInto(tester, 'Current password', demoWrongPassword);
        await typeInto(tester, 'Confirm new password', 'Abcdefghij1!');
        await tapButton(tester, 'Change password');
        expect(find.text('Your current password is not right.'), findsWidgets);

        await typeInto(tester, 'Current password', 'my-old-password');
        await tapButton(tester, 'Change password');
        expect(find.text('Password changed'), findsOneWidget);
        // Back on Privacy and security.
        expect(find.text('Biometric lock'), findsOneWidget);
      });

      testWidgets('sessions: sign out one device, then all the others', (
        tester,
      ) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy/sessions',
        );
        expect(find.text('This device'), findsOneWidget);
        expect(buttonNamed('Sign out This phone'), findsNothing);
        expect(find.textContaining('Active 3 hours ago'), findsOneWidget);

        await tapOn(tester, buttonNamed('Sign out MacBook Pro'));
        expect(find.text('Signed out MacBook Pro'), findsOneWidget);
        expect(find.text('MacBook Pro'), findsNothing);
        expect(find.text('iPad Air'), findsOneWidget);

        await tapButton(tester, 'Sign out all other devices');
        expect(find.text('Sign out all other devices?'), findsOneWidget);
        await tapButton(tester, 'Cancel');
        expect(find.text('iPad Air'), findsOneWidget);
        await tapButton(tester, 'Sign out all other devices');
        await tapButton(tester, 'Sign out all');
        expect(find.text('iPad Air'), findsNothing);
        expect(find.text('This phone'), findsOneWidget);
        expect(
          tester
              .widget<CairnButton>(button('Sign out all other devices'))
              .onPressed,
          isNull,
        );
      });

      testWidgets('two-factor: the setup sheet, a wrong and a right code', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy',
        );
        await tapRow(tester, 'Two-factor authentication');
        expect(find.text('Set up two-factor authentication'), findsOneWidget);
        expect(find.text('JBSW Y3DP EHPK 3PXP'), findsOneWidget);
        expect(find.textContaining('Step 1 of 2'), findsOneWidget);

        await tapButton(tester, 'Next');
        expect(find.textContaining('Step 2 of 2'), findsOneWidget);
        await typeInto(tester, '6-digit code', '000000');
        await tapButton(tester, 'Verify');
        expect(find.textContaining('not right'), findsOneWidget);

        await typeInto(tester, '6-digit code', '123456');
        await tapButton(tester, 'Verify');
        expect(find.text('Two-factor authentication is on'), findsOneWidget);
        await tapButton(tester, 'Done');
        expect(find.text('Set up two-factor authentication'), findsNothing);
        expect(switchIn(tester, 'Two-factor authentication').value, isTrue);
        expect(h.changes.single, (SettingIds.twoFactor, true));

        // Turning it off asks first.
        await tapRow(tester, 'Two-factor authentication');
        expect(
          find.text('Turn off two-factor authentication?'),
          findsOneWidget,
        );
        await tapButton(tester, 'Turn off');
        expect(switchIn(tester, 'Two-factor authentication').value, isFalse);
      });

      testWidgets('two-factor: cancelling the sheet changes nothing', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy',
        );
        await tapRow(tester, 'Two-factor authentication');
        await tapButton(tester, 'Cancel');
        expect(find.text('Set up two-factor authentication'), findsNothing);
        expect(switchIn(tester, 'Two-factor authentication').value, isFalse);
        expect(h.changes, isEmpty);
      });

      testWidgets('privacy: a data export is requested once', (tester) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy',
        );
        await tapRow(tester, 'Export my data');
        expect(find.text('Export requested'), findsOneWidget);
        expect(find.textContaining('Requested. We will email'), findsOneWidget);
      });

      testWidgets('blocked users: unblock down to the empty state', (
        tester,
      ) async {
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'privacy/blockedUsers',
        );
        expect(find.text('Charles Babbage'), findsOneWidget);
        await tapOn(tester, buttonNamed('Unblock Charles Babbage'));
        await tapOn(tester, buttonNamed('Unblock Mary Somerville'));
        expect(find.text('No blocked users'), findsOneWidget);
        expect(find.text('Charles Babbage'), findsNothing);
      });

      testWidgets('language: choices apply and the preview follows', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'language',
        );
        expect(find.text('12/31/2026'), findsOneWidget);
        await tapOn(tester, radio('fr'));
        await tapOn(tester, select('Date format'));
        await tapOn(tester, find.text('DD/MM/YYYY').last);
        expect(find.text('31/12/2026'), findsOneWidget);
        await tapOn(tester, select('Time format'));
        await tapOn(tester, find.text('24-hour').last);
        expect(find.text('14:30'), findsOneWidget);
        await tapOn(tester, select('Units'));
        await tapOn(tester, find.text('Imperial').last);
        expect(find.text('3.1 mi'), findsOneWidget);
        await tapOn(tester, select('Region'));
        await tapOn(tester, find.text('United Kingdom').last);
        expect(h.changes.map(((String, Object?) c) => c.$2), <Object?>[
          'fr',
          'dmy',
          '24h',
          'imperial',
          'GB',
        ]);
      });

      testWidgets(
        'storage: the meter, and clearing the cache after a confirm',
        (tester) async {
          await mountSettings(
            tester,
            width: width,
            height: height,
            initialLocation: 'storage',
          );
          expect(find.text('2.3 GB of 5 GB used'), findsOneWidget);
          for (final String label in <String>[
            'Photos and media',
            'Documents',
            'Downloads',
            'Cache',
            'Free',
          ]) {
            expect(find.text(label), findsOneWidget, reason: label);
          }
          expect(find.byType(CairnProgress), findsWidgets);

          await tapRow(tester, 'Clear cache');
          expect(find.text('Clear cache?'), findsOneWidget);
          expect(find.textContaining('frees about 88 MB'), findsOneWidget);
          await tapButton(tester, 'Cancel');
          expect(find.text('Cache cleared'), findsNothing);

          await tapRow(tester, 'Clear cache');
          await tapButton(tester, 'Clear cache');
          expect(find.text('Cache cleared'), findsOneWidget);
          expect(find.text('88 MB reclaimed.'), findsOneWidget);
          expect(find.textContaining('The cache is empty'), findsOneWidget);
          expect(find.text('2.2 GB of 5 GB used'), findsOneWidget);
        },
      );

      testWidgets('storage: Wi-Fi only and auto-delete', (tester) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'storage',
        );
        await tapRow(tester, 'Download over Wi-Fi only');
        await tapOn(tester, select('Auto-delete downloads'));
        await tapOn(tester, find.text('After 30 days').last);
        expect(h.changes, <(String, Object?)>[
          ('storage.wifiOnly', false),
          ('storage.autoDelete', '30d'),
        ]);
      });

      testWidgets('help: FAQ, contact form and copying the version', (
        tester,
      ) async {
        final List<String> copied = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall call) async {
            if (call.method == 'Clipboard.setData') {
              copied.add(
                (call.arguments as Map<Object?, Object?>)['text']! as String,
              );
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'help',
        );
        // FAQ accordion.
        expect(find.textContaining('Sign out, choose'), findsNothing);
        await tapOn(tester, find.text('I forgot my password'));
        expect(find.textContaining('Sign out, choose'), findsOneWidget);

        // Contact form: errors first, then a sent message that clears it.
        await tapButton(tester, 'Send message');
        expect(find.text('Choose a subject.'), findsOneWidget);
        expect(find.textContaining('Tell us a little more'), findsOneWidget);
        await tapOn(tester, select('Subject'));
        await tapOn(tester, find.text('Billing').last);
        await typeInto(tester, 'Message', 'I was charged twice this month.');
        await tapButton(tester, 'Send message');
        expect(find.text('Message sent'), findsOneWidget);
        expect(find.textContaining('SUP-4821'), findsOneWidget);
        expect(find.text('I was charged twice this month.'), findsNothing);

        // Version.
        await tapRow(tester, 'App version');
        expect(copied, <String>['2.4.1 (241)']);
        expect(find.text('Version copied'), findsOneWidget);
      });

      testWidgets('about: version, licences, legal links and rating', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'about',
        );
        expect(find.text('Version 2.4.1 (241)'), findsOneWidget);
        expect(find.text('flutter_bloc'), findsNothing);
        await tapRow(tester, 'Open-source licences');
        expect(find.text('flutter_bloc'), findsOneWidget);
        expect(find.text('BSD-3-Clause'), findsOneWidget);
        await tapRow(tester, 'Open-source licences');
        expect(find.text('flutter_bloc'), findsNothing);

        await tapRow(tester, 'Terms of service');
        await tapRow(tester, 'Privacy policy');
        expect(h.links, <SettingsLink>[
          SettingsLink.terms,
          SettingsLink.privacy,
        ]);

        await tapRow(tester, 'Rate the app');
        expect(find.text('Rate the app'), findsWidgets);
        expect(
          tester.widget<CairnButton>(button('Send')).onPressed,
          isNull,
          reason: 'a rating is needed first',
        );
        await tester.tap(find.byType(CairnRating), warnIfMissed: false);
        await pumpFrames(tester, 2);
        // Tap the fourth star: stars are 36 wide with a 2px gap.
        final Rect box = tester.getRect(find.byType(CairnRating));
        await tester.tapAt(Offset(box.left + 3.5 * 38, box.center.dy));
        await pumpFrames(tester, 2);
        await tapButton(tester, 'Send');
        expect(h.ratings, <int>[4]);
        expect(find.text('Thanks for rating'), findsOneWidget);
      });

      testWidgets('danger: sign out is confirmed, then the host is told', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'danger',
        );
        await tapRow(tester, 'Sign out');
        expect(find.text('Sign out?'), findsOneWidget);
        await tapButton(tester, 'Cancel');
        expect(h.signedOut, 0);
        await tapRow(tester, 'Sign out');
        await tapButton(tester, 'Sign out');
        expect(h.signedOut, 1);
        expect(find.text('Signed out'), findsOneWidget);
      });

      testWidgets('danger: deactivating is confirmed', (tester) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'danger',
        );
        await tapRow(tester, 'Deactivate account');
        await tapButton(tester, 'Deactivate');
        expect(h.deactivated, 1);
        expect(find.text('Account deactivated'), findsOneWidget);
      });

      testWidgets('danger: deleting needs DELETE typed, then a final step', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'danger',
        );
        await tapRow(tester, 'Delete account');
        expect(find.text('Delete your account?'), findsOneWidget);
        expect(
          tester.widget<CairnButton>(button('Continue')).onPressed,
          isNull,
        );
        await typeInto(tester, 'Type DELETE to confirm', 'delete');
        expect(
          tester.widget<CairnButton>(button('Continue')).onPressed,
          isNull,
          reason: 'case matters',
        );
        await typeInto(tester, 'Type DELETE to confirm', 'DELET');
        expect(
          tester.widget<CairnButton>(button('Continue')).onPressed,
          isNull,
        );
        await typeInto(tester, 'Type DELETE to confirm', 'DELETE');
        await tapButton(tester, 'Continue');

        // The final step can still be refused.
        expect(find.text('This is the last step'), findsOneWidget);
        await tapButton(tester, 'Keep my account');
        expect(h.deleted, 0);

        await tapRow(tester, 'Delete account');
        await typeInto(tester, 'Type DELETE to confirm', 'DELETE');
        await tapButton(tester, 'Continue');
        await tapButton(tester, 'Delete account');
        expect(h.deleted, 1);
        expect(find.text('Account deleted'), findsOneWidget);
      });

      testWidgets('danger: cancelling the typed step deletes nothing', (
        tester,
      ) async {
        final Host h = await mountSettings(
          tester,
          width: width,
          height: height,
          initialLocation: 'danger',
        );
        await tapRow(tester, 'Delete account');
        await typeInto(tester, 'Type DELETE to confirm', 'DELETE');
        await tapButton(tester, 'Cancel');
        expect(find.text('This is the last step'), findsNothing);
        expect(h.deleted, 0);
      });

      testWidgets('a failing data source offers a retry', (tester) async {
        final _OfflineOnce offline = _OfflineOnce();
        await mountSettings(
          tester,
          width: width,
          height: height,
          host: Host(source: offline),
          initialLocation: 'appearance',
        );
        expect(find.text('Could not load'), findsOneWidget);
        offline.online = true;
        await tapButton(tester, 'Try again');
        expect(find.text('Could not load'), findsNothing);
        expect(find.text('Text size'), findsOneWidget);
      });

      testWidgets('a registry without a setting hides and unsearches it', (
        tester,
      ) async {
        final SettingsRegistry registry = SettingsRegistry(
          defaultSettingsRegistry.definitions.where(
            (SettingDefinition d) =>
                d.id != SettingIds.reduceMotion &&
                d.section != SettingsSection.about,
          ),
        );
        await mountSettings(
          tester,
          width: width,
          height: height,
          registry: registry,
          initialLocation: 'appearance',
        );
        expect(find.text('Reduce motion'), findsNothing);
        expect(find.text('Text size'), findsOneWidget);
        await mountSettings(
          tester,
          width: width,
          height: height,
          registry: registry,
        );
        expect(find.text('About'), findsNothing);
        await typeInto(tester, 'Search settings', 'reduce motion');
        expect(find.text('No results'), findsOneWidget);
      });
    });
  }

  for (final double width in <double>[320, 700]) {
    for (final (bool dark, double scale) in <(bool, double)>[
      (true, 1.3),
      (false, 2),
      (true, 2),
    ]) {
      final double height = width == 320 ? 640 : 1000;
      group(
        'flows at ${width.toInt()}px ${dark ? 'dark' : 'light'} x$scale',
        () {
          testWidgets('search, then open a result', (tester) async {
            await mountSettings(
              tester,
              width: width,
              height: height,
              dark: dark,
              textScale: scale,
            );
            await typeInto(tester, 'Search settings', 'password');
            expect(find.text('Change password'), findsOneWidget);
            await tapRow(tester, 'Change password');
            expect(find.text('Current password'), findsOneWidget);
          });

          testWidgets('quiet hours and the master switch', (tester) async {
            await mountSettings(
              tester,
              width: width,
              height: height,
              dark: dark,
              textScale: scale,
              initialLocation: 'notifications',
            );
            await tapRow(tester, 'Quiet hours');
            await tapOn(tester, select('From'));
            await tapOn(tester, find.text('23:30').last);
            expect(find.text('23:30'), findsOneWidget);
            await tapRow(tester, 'Allow notifications');
            expect(switchIn(tester, 'Messages').onChanged, isNull);
          });

          testWidgets('clear cache, then delete the account', (tester) async {
            final Host h = await mountSettings(
              tester,
              width: width,
              height: height,
              dark: dark,
              textScale: scale,
              initialLocation: 'storage',
            );
            await tapRow(tester, 'Clear cache');
            expect(find.textContaining('frees about 88 MB'), findsOneWidget);
            await tapButton(tester, 'Clear cache');
            expect(find.text('Cache cleared'), findsOneWidget);

            await mountSettings(
              tester,
              width: width,
              height: height,
              dark: dark,
              textScale: scale,
              host: h,
              initialLocation: 'danger',
            );
            await tapRow(tester, 'Delete account');
            await typeInto(tester, 'Type DELETE to confirm', 'DELETE');
            await tapButton(tester, 'Continue');
            await tapButton(tester, 'Delete account');
            expect(h.deleted, 1);
          });

          testWidgets('profile, guard and sessions', (tester) async {
            final Host h = await mountSettings(
              tester,
              width: width,
              height: height,
              dark: dark,
              textScale: scale,
              initialLocation: 'profile',
            );
            await typeInto(tester, 'Bio', 'Hello there');
            await tester.binding.handlePopRoute();
            await pumpFrames(tester);
            if (width < 600 || scale > 1.3) {
              expect(find.text('Discard changes?'), findsOneWidget);
              await tapButton(tester, 'Discard');
            }
            await mountSettings(
              tester,
              width: width,
              height: height,
              dark: dark,
              textScale: scale,
              host: h,
              initialLocation: 'privacy/sessions',
            );
            await tapOn(tester, buttonNamed('Sign out MacBook Pro'));
            expect(find.text('MacBook Pro'), findsNothing);
          });
        },
      );
    }
  }

  group('accessibility', () {
    testWidgets('rows are named, switches announce their state', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountSettings(tester, initialLocation: 'notifications');
      expect(
        tester.getSemantics(find.byType(ToggleRow).first),
        isSemantics(
          label: 'Allow notifications',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.byWidgetPredicate(
            (Widget w) => w is ToggleRow && w.title == 'Offers and tips',
          ),
        ),
        isSemantics(
          label: 'Offers and tips',
          hasToggledState: true,
          isToggled: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('a disabled switch says it is disabled', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountSettings(tester, initialLocation: 'notifications');
      await tapRow(tester, 'Allow notifications');
      expect(
        tester.getSemantics(
          find.byWidgetPredicate(
            (Widget w) => w is ToggleRow && w.title == 'Messages',
          ),
        ),
        isSemantics(
          label: 'Messages',
          hasToggledState: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('the home has a header, a named search and named rows', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountSettings(tester);
      expect(find.bySemanticsLabel(RegExp('Search settings')), findsWidgets);
      expect(
        find.bySemanticsLabel(RegExp(r'^Edit profile\. Ada Lovelace')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'^Appearance\. Theme, text size')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('radios, the slider and the select are named', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountSettings(tester, initialLocation: 'appearance');
      expect(
        tester.getSemantics(radio('system')),
        isSemantics(
          label: 'System',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      expect(
        tester.getSemantics(find.byType(CairnSlider)),
        isSemantics(label: 'Text size', isSlider: true),
      );
      handle.dispose();
    });

    testWidgets('every row, button and radio is at least 44 px tall', (
      tester,
    ) async {
      for (final String? page in <String?>[
        null,
        'notifications',
        'privacy',
        'privacy/sessions',
        'storage',
        'danger',
        'about',
      ]) {
        await mountSettings(tester, initialLocation: page);
        for (final Finder f in <Finder>[
          find.byType(ToggleRow),
          find.byType(NavRow),
          find.byType(CairnRadioItem<String>),
        ]) {
          for (final Element e in f.evaluate()) {
            expect(
              tester.getSize(find.byWidget(e.widget)).height,
              greaterThanOrEqualTo(44),
              reason: '${e.widget.runtimeType} on ${page ?? 'home'}',
            );
          }
        }
      }
    });

    testWidgets('dialog buttons and the back control have 44 px targets', (
      tester,
    ) async {
      await mountSettings(tester, initialLocation: 'danger');
      await tapRow(tester, 'Sign out');
      for (final String label in <String>['Cancel', 'Sign out']) {
        final Finder target = find.ancestor(
          of: button(label),
          matching: find.byType(GestureDetector),
        );
        expect(
          tester.getSize(target.first).height,
          greaterThanOrEqualTo(44),
          reason: label,
        );
      }
      await tapButton(tester, 'Cancel');
      final Finder back = find.ancestor(
        of: buttonNamed('Back'),
        matching: find.byType(GestureDetector),
      );
      expect(tester.getSize(back.first).height, greaterThanOrEqualTo(44));
    });

    testWidgets('form fields announce their errors as live regions', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountSettings(tester, initialLocation: 'profile');
      await typeInto(tester, 'Name', '');
      expect(
        tester.getSemantics(find.text('Enter your name.')),
        isSemantics(isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('focus moves through the home in reading order', (
      tester,
    ) async {
      await mountSettings(tester);
      final List<double> tops = <double>[];
      for (int i = 0; i < 4; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await pumpFrames(tester, 1);
        final FocusNode? f = FocusManager.instance.primaryFocus;
        expect(f, isNotNull);
        tops.add(f!.rect.top);
      }
      // Search first, then the profile card, then the groups, top to bottom.
      expect(tops, <double>[...tops]..sort());
      expect(tops.toSet().length, 4);
    });
  });

  group('two panes', () {
    testWidgets('a tablet shows the list and the first category', (
      tester,
    ) async {
      await mountSettings(tester, width: 700, height: 1000);
      expect(find.text('Search settings'), findsWidgets);
      // The profile page is the default detail.
      expect(find.text('Username'), findsOneWidget);
      expect(buttonNamed('Back'), findsNothing);
    });

    testWidgets('choosing a category replaces the detail, keeping the list', (
      tester,
    ) async {
      await mountSettings(tester, width: 700, height: 1000);
      await tapRow(tester, 'Notifications');
      expect(find.text('Allow notifications'), findsOneWidget);
      expect(find.text('Username'), findsNothing);
      await tapRow(tester, 'Storage and data');
      expect(find.text('Allow notifications'), findsNothing);
      expect(find.textContaining('of 5 GB used'), findsOneWidget);
      expect(find.text('Ada Lovelace'), findsOneWidget);
    });

    testWidgets('sub-pages open in the detail pane with a back control', (
      tester,
    ) async {
      await mountSettings(tester, width: 700, height: 1000);
      await tapRow(tester, 'Privacy and security');
      await tapRow(tester, 'Active sessions');
      expect(find.text('Sign out all other devices'), findsOneWidget);
      expect(find.text('Search settings'), findsWidgets);
      await tapOn(tester, buttonNamed('Back'));
      expect(find.text('Biometric lock'), findsOneWidget);
    });

    testWidgets('rotating from a phone to a tablet keeps the open page', (
      tester,
    ) async {
      await mountSettings(tester, width: 360, height: 780);
      await tapRow(tester, 'Appearance');
      tester.view.physicalSize = const Size(700, 1000);
      await pumpFrames(tester);
      expect(find.text('Text size'), findsOneWidget);
      expect(find.text('Search settings'), findsWidgets);
      tester.view.physicalSize = const Size(360, 780);
      await pumpFrames(tester);
      expect(find.text('Text size'), findsOneWidget);
      expect(find.text('Search settings'), findsNothing);
    });

    testWidgets('a search result selects its category on a tablet', (
      tester,
    ) async {
      await mountSettings(tester, width: 700, height: 1000);
      await typeInto(tester, 'Search settings', 'biometric');
      await tapRow(tester, 'Biometric lock');
      expect(find.text('Two-factor authentication'), findsOneWidget);
      // The result list is still showing beside it.
      expect(find.text('1 result'), findsOneWidget);
    });
  });

  group('integration', () {
    testWidgets('two apps do not share state', (tester) async {
      await mountSettings(tester, initialLocation: 'appearance');
      await tapOn(tester, radio('dark'));
      expect(themeOf(tester).brightness, Brightness.dark);
      await mountSettings(tester, initialLocation: 'appearance');
      expect(themeOf(tester).brightness, Brightness.light);
    });

    testWidgets('settings are persisted through the data source', (
      tester,
    ) async {
      final Host h = await mountSettings(tester, initialLocation: 'appearance');
      await tapOn(tester, radio('dark'));
      await mountSettings(tester, host: h, initialLocation: 'appearance');
      expect(themeOf(tester).brightness, Brightness.dark);
    });

    testWidgets('a host profile is shown without loading', (tester) async {
      await mountSettings(
        tester,
        profile: const Profile(
          name: 'Grace Hopper',
          username: 'grace',
          email: 'grace@example.com',
        ),
      );
      expect(find.text('Grace Hopper'), findsOneWidget);
      expect(find.text('Ada Lovelace'), findsNothing);
    });

    testWidgets('callbacks can change between builds', (tester) async {
      final List<String> a = <String>[];
      final List<String> b = <String>[];
      Widget app(void Function(String, Object?) onChange) => MaterialApp(
        theme: CairnTheme.materialTheme(CairnTheme.light),
        home: Scaffold(
          body: SettingsApp(
            settingsDataSource: InMemorySettingsDataSource(
              latency: Duration.zero,
            ),
            initialLocation: 'appearance',
            onSettingChanged: onChange,
          ),
        ),
      );
      await tester.pumpWidget(app((String id, Object? v) => a.add(id)));
      await pumpFrames(tester);
      await tester.pumpWidget(app((String id, Object? v) => b.add(id)));
      await pumpFrames(tester);
      await tapRow(tester, 'Reduce motion');
      expect(a, isEmpty);
      expect(b, <String>[SettingIds.reduceMotion]);
    });

    testWidgets('permission changes reach the Notifications screen', (
      tester,
    ) async {
      final InMemorySettingsDataSource source = InMemorySettingsDataSource(
        latency: Duration.zero,
      );
      Widget app(NotificationPermission p) => MaterialApp(
        theme: CairnTheme.materialTheme(CairnTheme.light),
        home: Scaffold(
          body: SettingsApp(
            settingsDataSource: source,
            initialLocation: 'notifications',
            notificationPermission: p,
          ),
        ),
      );
      await tester.pumpWidget(app(NotificationPermission.granted));
      await pumpFrames(tester);
      expect(find.text('Notifications are blocked'), findsNothing);
      await tester.pumpWidget(app(NotificationPermission.denied));
      await pumpFrames(tester);
      expect(find.text('Notifications are blocked'), findsOneWidget);
    });
  });
}

class _OfflineOnce extends InMemorySettingsDataSource {
  _OfflineOnce() : super(latency: Duration.zero);

  bool online = false;

  @override
  Future<Map<String, Object?>> loadSettings() => online
      ? super.loadSettings()
      : Future<Map<String, Object?>>.error(StateError('offline'));
}
