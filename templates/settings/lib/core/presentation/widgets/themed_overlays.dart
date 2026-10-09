import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../notice.dart';
import '../settings_text.dart';
import '../view_model.dart';
import 'touch_target.dart';

/// Wraps [builder]'s result in the theme, text scale and motion setting of
/// [context], so a dialog or sheet looks like the app that opened it.
///
/// Cairn's dialogs and sheets open on the root navigator, above the template's
/// own theme. Without this they would use the host's theme, which differs
/// whenever the person has chosen another mode, accent or text size here.
WidgetBuilder _scoped(
  BuildContext context,
  WidgetBuilder builder, {
  bool dialog = false,
}) {
  // Read everything now: the route may rebuild after [context] is gone.
  final ThemeData theme = Theme.of(context);
  final MediaQueryData mine = MediaQuery.of(context);
  final GetIt locator = SettingsScope.of(context);
  return (BuildContext _) => Theme(
    data: theme,
    child: SettingsScope(
      locator: locator,
      child: Builder(
        builder: (BuildContext inner) => MediaQuery(
          data: MediaQuery.of(inner).copyWith(
            textScaler: mine.textScaler,
            disableAnimations: mine.disableAnimations,
            // Cairn lays a dialog's buttons out in one row from 640 px wide, which
            // cannot hold two labels at large text. Reporting a narrower screen
            // keeps them stacked and full width on every device.
            size: dialog
                ? Size(
                    MediaQuery.sizeOf(inner).width.clamp(0.0, 600.0),
                    MediaQuery.sizeOf(inner).height,
                  )
                : null,
          ),
          child: Builder(
            builder: (BuildContext c) => dialog
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(c).bottom,
                    ),
                    child: builder(c),
                  )
                : builder(c),
          ),
        ),
      ),
    ),
  );
}

/// Opens an alert dialog that is dismissed only by its buttons.
Future<T?> showSettingsAlert<T>(BuildContext context, WidgetBuilder builder) =>
    showCairnAlertDialog<T>(
      context: context,
      builder: _scoped(context, builder, dialog: true),
    );

/// Opens a dialog that can also be dismissed by tapping outside it.
Future<T?> showSettingsDialog<T>(BuildContext context, WidgetBuilder builder) =>
    showCairnDialog<T>(
      context: context,
      builder: _scoped(context, builder, dialog: true),
    );

/// Opens a bottom sheet.
Future<T?> showSettingsSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showCairnDrawer<T>(context: context, builder: _scoped(context, builder));

/// Asks the person to confirm something. Resolves `true` when they do.
///
/// [destructive] makes the confirm button red. Cancel is always offered, and is
/// the safe default.
Future<bool> confirmSettingsAction(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final bool? result = await showSettingsAlert<bool>(
    context,
    (BuildContext context) => CairnAlertDialog(
      title: Text(title),
      description: Text(description),
      actions: <Widget>[
        DialogButton(
          label: cancelLabel,
          variant: CairnButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        DialogButton(
          label: confirmLabel,
          variant: destructive
              ? CairnButtonVariant.destructive
              : CairnButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// A dialog button at least 44 px tall.
class DialogButton extends StatelessWidget {
  /// Creates a button.
  const DialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CairnButtonVariant.primary,
    this.busy = false,
  });

  /// The text.
  final String label;

  /// Called on tap. `null` disables the button.
  final VoidCallback? onPressed;

  /// The look.
  final CairnButtonVariant variant;

  /// Whether to show a spinner before the label.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color spinner = switch (variant) {
      CairnButtonVariant.primary => theme.primaryForeground,
      CairnButtonVariant.destructive => theme.destructiveForeground,
      _ => theme.foreground,
    };
    // In a column it fills the width. A wide dialog lays its buttons out in a
    // row, where the width is unbounded and the button must size to its label.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) => TouchTarget(
        onTap: onPressed,
        child: CairnButton(
          variant: variant,
          size: CairnButtonSize.lg,
          expand: box.hasBoundedWidth,
          onPressed: onPressed,
          leading: busy
              ? CairnSpinner(size: 16, color: spinner, semanticLabel: 'Working')
              : null,
          // The button never wraps its label, so long labels at large text sizes
          // shrink to fit instead of being cut off.
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
        ),
      ),
    );
  }
}

/// Shows [notice] as a toast.
void showSettingsToast(BuildContext context, Notice notice) {
  CairnToast.show(
    context,
    CairnToast(
      title: notice.title,
      description: notice.description,
      variant: notice.isError
          ? CairnToastVariant.error
          : CairnToastVariant.success,
    ),
  );
}

/// Shows a toast whenever the cubit's state carries a new notice.
class NoticeListener<C extends StateStreamable<S>, S> extends StatelessWidget {
  /// Creates a listener. [pick] reads the notice out of a state.
  const NoticeListener({super.key, required this.pick, required this.child});

  /// Reads the notice out of a state.
  final Notice? Function(S state) pick;

  /// The screen.
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocListener<C, S>(
    listenWhen: (S previous, S current) {
      final Notice? next = pick(current);
      return next != null && next != pick(previous);
    },
    listener: (BuildContext context, S state) =>
        showSettingsToast(context, pick(state)!),
    child: child,
  );
}

/// A spinner shown inside a button while it works.
class ButtonSpinner extends StatelessWidget {
  /// Creates a spinner.
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) =>
      const CairnSpinner(size: 16, semanticLabel: 'Working');
}

/// Muted explanatory text under a heading.
class HelpText extends StatelessWidget {
  /// Creates the text.
  const HelpText(this.text, {super.key});

  /// What to say.
  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Text(
      text,
      style: settingsText(
        theme,
        CairnTypography.sm,
        color: theme.mutedForeground,
        height: 1.45,
      ),
    );
  }
}
