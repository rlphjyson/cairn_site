import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/settings/models/settings_section.dart';
import 'settings_page.dart';

/// The pages open on top of the home screen, outermost first.
class SettingsNavigationState extends Equatable {
  /// Creates a state.
  const SettingsNavigationState({
    this.stack = const <SettingsPage>[],
    this.forward = true,
  });

  /// The open pages. Empty means the home screen is showing (on a phone) or
  /// the default category is selected (on a tablet).
  final List<SettingsPage> stack;

  /// Whether the last move went deeper. The transition slides the new screen in
  /// from the matching side.
  final bool forward;

  /// The page on top, or `null` on the home screen.
  SettingsPage? get top => stack.isEmpty ? null : stack.last;

  /// The category that is open, or `null`.
  SettingsSection? get section => stack.isEmpty ? null : stack.first.section;

  @override
  List<Object?> get props => <Object?>[stack, forward];
}

/// Navigation inside the settings.
///
/// The template deliberately does not use the host app's router: it has to run
/// unchanged inside any Flutter app. This cubit holds a small stack of pages;
/// on a phone the top of it fills the screen, on a tablet the first entry is
/// the selected category and the top is shown beside the list. To drive the
/// pages from `go_router` instead, replace this cubit and keep the views (see
/// `doc/index.html`).
class SettingsNavigationCubit extends Cubit<SettingsNavigationState> {
  /// Creates the cubit, optionally opening [initial] pages.
  SettingsNavigationCubit({List<SettingsPage> initial = const <SettingsPage>[]})
    : super(SettingsNavigationState(stack: initial));

  /// Opens [page] on top of the current ones.
  void open(SettingsPage page) {
    if (state.top == page) return;
    emit(SettingsNavigationState(stack: <SettingsPage>[...state.stack, page]));
  }

  /// Makes [page] the only open page. Used by the tablet list, where choosing a
  /// category replaces the one beside it.
  void select(SettingsPage page) {
    if (state.stack.length == 1 && state.top == page) return;
    emit(SettingsNavigationState(stack: <SettingsPage>[page]));
  }

  /// Closes the top page. Returns `false` when nothing was open.
  bool back() {
    if (state.stack.isEmpty) return false;
    emit(
      SettingsNavigationState(
        stack: state.stack.sublist(0, state.stack.length - 1),
        forward: false,
      ),
    );
    return true;
  }

  /// Closes everything and returns to the home screen.
  void home() {
    if (state.stack.isEmpty) return;
    emit(const SettingsNavigationState(forward: false));
  }
}
