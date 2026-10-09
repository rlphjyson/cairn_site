import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Asks for confirmation before something that cannot be undone. Resolves to
/// `true` when the person confirms and `false` when they cancel.
///
/// The dialog cannot be dismissed by tapping outside, so the answer is always a
/// deliberate one.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final bool? confirmed = await showCairnAlertDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => CairnAlertDialog(
      title: Text(title),
      description: Text(description),
      actions: <Widget>[
        CairnButton(
          variant: CairnButtonVariant.outline,
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        CairnButton(
          variant: CairnButtonVariant.destructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
