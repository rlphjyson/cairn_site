import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/confirmation_phrases.dart';
import '../../../core/presentation/widgets/labeled_field.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/security/use_cases/delete_account.dart';

/// Step one of deleting an account: explains what will be lost and asks the
/// person to type `DELETE`. Pops with the typed text when Continue is pressed,
/// or `null` when cancelled.
class TypedConfirmDialog extends StatefulWidget {
  /// Creates the dialog.
  const TypedConfirmDialog({super.key});

  @override
  State<TypedConfirmDialog> createState() => _TypedConfirmDialogState();
}

class _TypedConfirmDialogState extends State<TypedConfirmDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _ok = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CairnDialog(
    showCloseButton: false,
    title: const Text('Delete your account?'),
    description: const Text(
      'This permanently removes your profile, settings and data. It cannot '
      'be undone.',
    ),
    actions: <Widget>[
      DialogButton(
        label: 'Cancel',
        variant: CairnButtonVariant.outline,
        onPressed: () => Navigator.of(context).pop(),
      ),
      DialogButton(
        label: 'Continue',
        variant: CairnButtonVariant.destructive,
        onPressed: _ok
            ? () => Navigator.of(context).pop(_controller.text)
            : null,
      ),
    ],
    content: LabeledField(
      label: 'Type $deleteConfirmationPhrase to confirm',
      child: CairnInput(
        controller: _controller,
        autofocus: true,
        semanticLabel: 'Type $deleteConfirmationPhrase to confirm',
        placeholder: deleteConfirmationPhrase,
        textInputAction: TextInputAction.done,
        onChanged: (String v) =>
            setState(() => _ok = DeleteAccount.isConfirmed(v)),
      ),
    ),
  );
}

/// Step two: a last warning. Pops with `true` to go ahead.
class FinalDeleteDialog extends StatelessWidget {
  /// Creates the dialog.
  const FinalDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) => CairnAlertDialog(
    title: const Text('This is the last step'),
    description: const Text(
      'Your account and everything in it will be deleted now. There is no '
      'way back.',
    ),
    actions: <Widget>[
      DialogButton(
        label: 'Keep my account',
        variant: CairnButtonVariant.outline,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      DialogButton(
        label: 'Delete account',
        variant: CairnButtonVariant.destructive,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
}
