import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/chat_text.dart';

/// A labelled text field with a Save button that appears when the text differs
/// from the saved value.
class EditableField extends StatefulWidget {
  /// Creates the field.
  const EditableField({
    super.key,
    required this.label,
    required this.value,
    required this.onSave,
    this.maxLength = 60,
  });

  /// The field's label, also its accessible name.
  final String label;

  /// The saved value.
  final String value;

  /// Called with the new text when Save is pressed (or the keyboard submits).
  final Future<void> Function(String text) onSave;

  /// The longest text allowed.
  final int maxLength;

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void didUpdateWidget(EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow changes made elsewhere, unless the person is mid-edit.
    if (oldWidget.value != widget.value &&
        _controller.text == oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  bool get _dirty => _controller.text.trim() != widget.value;

  Future<void> _save() async {
    if (!_dirty || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(_controller.text);
      if (!mounted) return;
      CairnToast.show(
        context,
        CairnToast(
          title: '${widget.label} saved',
          variant: CairnToastVariant.success,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: <Widget>[
        Text(
          widget.label,
          style: chatText(
            theme,
            theme.textStyle(CairnTypography.xs),
            color: theme.mutedForeground,
            weight: CairnTypography.medium,
          ),
        ),
        Row(
          spacing: 8,
          children: <Widget>[
            Expanded(
              child: CairnInput(
                controller: _controller,
                semanticLabel: widget.label,
                maxLength: widget.maxLength,
                onSubmitted: (String _) => _save(),
              ),
            ),
            CairnButton(
              size: CairnButtonSize.md,
              onPressed: _dirty && !_saving ? _save : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
