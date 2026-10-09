/// Lets a screen with unsaved edits stop the user leaving it by accident.
///
/// A screen sets [isDirty] while it is open and clears it when it goes. The
/// shell asks before it pops the screen or switches to another category, and
/// shows a confirm dialog when [isDirty] says there is something to lose.
class UnsavedChangesGuard {
  /// Whether there are unsaved changes right now. `null` when no screen
  /// registered one.
  bool Function()? isDirty;

  /// Whether leaving would lose work.
  bool get hasUnsavedChanges => isDirty?.call() ?? false;
}
