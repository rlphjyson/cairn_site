import 'package:flutter/widgets.dart';

import '../../infrastructure/unsaved_changes_guard.dart';
import '../widgets/themed_overlays.dart';
import 'settings_navigation_cubit.dart';
import 'settings_page.dart';

/// Moves between pages, asking first when that would lose unsaved edits.
///
/// Views call this instead of the navigation cubit, so the "Discard changes?"
/// dialog appears wherever the person leaves an edited form: the back control,
/// the system back gesture, the tablet's category list or a search result.
class SettingsNavigator {
  /// Creates the navigator.
  const SettingsNavigator(this.cubit, this.guard);

  /// The page stack.
  final SettingsNavigationCubit cubit;

  /// Tells whether the open page has unsaved edits.
  final UnsavedChangesGuard guard;

  /// Opens [page] on top of the current ones.
  void open(SettingsPage page) => cubit.open(page);

  /// Makes [page] the only open page, after confirming if edits would be lost.
  Future<void> select(BuildContext context, SettingsPage page) async {
    if (cubit.state.stack.length == 1 && cubit.state.top == page) return;
    if (!await confirmLeave(context)) return;
    cubit.select(page);
  }

  /// Closes the top page, after confirming if edits would be lost.
  Future<void> back(BuildContext context) async {
    if (cubit.state.stack.isEmpty) return;
    if (!await confirmLeave(context)) return;
    cubit.back();
  }

  /// Returns to the home screen, after confirming if edits would be lost.
  Future<void> home(BuildContext context) async {
    if (!await confirmLeave(context)) return;
    cubit.home();
  }

  /// Whether leaving is fine: nothing is unsaved, or the person agreed to
  /// discard it.
  Future<bool> confirmLeave(BuildContext context) async {
    if (!guard.hasUnsavedChanges) return true;
    final bool discard = await confirmSettingsAction(
      context,
      title: 'Discard changes?',
      description: 'You have unsaved changes. If you leave now they are lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      destructive: true,
    );
    if (discard) guard.isDirty = null;
    return discard;
  }
}
