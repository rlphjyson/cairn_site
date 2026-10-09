import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/settings_layout.dart';
import '../../core/presentation/navigation/settings_navigation_cubit.dart';
import '../../core/presentation/navigation/settings_navigator.dart';
import '../../core/presentation/navigation/settings_page.dart';
import '../../core/presentation/widgets/control_scale.dart';
import '../../domain/settings/registry/settings_registry.dart';
import '../about/views/about_view.dart';
import '../appearance/views/appearance_view.dart';
import '../danger/views/danger_view.dart';
import '../help/views/help_view.dart';
import '../home/views/home_view.dart';
import '../language/views/language_view.dart';
import '../notifications/views/notifications_view.dart';
import '../privacy/views/blocked_users_view.dart';
import '../privacy/views/change_password_view.dart';
import '../privacy/views/privacy_view.dart';
import '../privacy/views/sessions_view.dart';
import '../profile/views/profile_edit_view.dart';
import '../storage/views/storage_view.dart';

/// Composes the screens: on a phone the home list or one page at a time, from
/// [SettingsLayout.wideBreakpoint] up a list on the left and the selected
/// category on the right.
class SettingsShell extends StatelessWidget {
  /// Creates the shell.
  const SettingsShell({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsNavigationState nav = context
        .watch<SettingsNavigationCubit>()
        .state;
    final SettingsNavigator navigator = context.read<SettingsNavigator>();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        // At large text sizes the list pane would swallow the page beside it, so
        // a tablet falls back to one page at a time.
        final bool wide =
            box.maxWidth >= SettingsLayout.wideBreakpoint &&
            !isLargeText(context);
        // On a tablet the list is always visible, so the system back only has
        // something to do when a sub-page is open on top of a category.
        final bool canPop = wide ? nav.stack.length <= 1 : nav.stack.isEmpty;
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) unawaited(navigator.back(context));
          },
          child: wide ? _TwoPane(nav: nav) : _OnePane(nav: nav),
        );
      },
    );
  }
}

/// Builds the screen for [page]. [wide] hides the back control on a category's
/// own page, because the list is beside it.
Widget _pageFor(BuildContext context, SettingsPage page, {required bool wide}) {
  final SettingsNavigator navigator = context.read<SettingsNavigator>();
  final VoidCallback? back = wide && page.isRoot
      ? null
      : () => unawaited(navigator.back(context));
  return switch (page) {
    SettingsPage.profile => ProfileEditView(onBack: back),
    SettingsPage.appearance => AppearanceView(onBack: back),
    SettingsPage.notifications => NotificationsView(onBack: back),
    SettingsPage.privacy => PrivacyView(onBack: back),
    SettingsPage.changePassword => ChangePasswordView(onBack: back),
    SettingsPage.sessions => SessionsView(onBack: back),
    SettingsPage.blockedUsers => BlockedUsersView(onBack: back),
    SettingsPage.language => LanguageView(onBack: back),
    SettingsPage.storage => StorageView(onBack: back),
    SettingsPage.help => HelpView(onBack: back),
    SettingsPage.about => AboutView(onBack: back),
    SettingsPage.danger => DangerView(onBack: back),
  };
}

/// A phone: the home list, or the top page over it.
class _OnePane extends StatelessWidget {
  const _OnePane({required this.nav});

  final SettingsNavigationState nav;

  @override
  Widget build(BuildContext context) {
    final SettingsPage? top = nav.top;
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : CairnMotion.d200,
      switchInCurve: CairnMotion.easeOut,
      switchOutCurve: CairnMotion.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(nav.forward ? 0.05 : -0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
      child: KeyedSubtree(
        key: ValueKey<Object>(top ?? 'home'),
        child: top == null
            ? const HomeView(wide: false)
            : _pageFor(context, top, wide: false),
      ),
    );
  }
}

/// A tablet: the list beside the open category.
class _TwoPane extends StatelessWidget {
  const _TwoPane({required this.nav});

  final SettingsNavigationState nav;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final SettingsPage first = registry.sections.isEmpty
        ? SettingsPage.profile
        : SettingsPage.of(registry.sections.first);
    final SettingsPage page = nav.top ?? first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: SettingsLayout.listPaneWidth,
          child: ColoredBox(
            color: theme.muted.withValues(alpha: 0.35),
            child: const HomeView(wide: true),
          ),
        ),
        ColoredBox(color: theme.border, child: const SizedBox(width: 1)),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey<Object>(page),
            child: _pageFor(context, page, wide: true),
          ),
        ),
      ],
    );
  }
}
