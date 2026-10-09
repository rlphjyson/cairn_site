import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// A search box with a magnifier and a clear button.
class SearchField extends StatefulWidget {
  /// Creates a search field.
  const SearchField({
    super.key,
    required this.placeholder,
    required this.onChanged,
    this.text = '',
  });

  /// The hint, also the accessible name.
  final String placeholder;

  /// Called on every change.
  final ValueChanged<String> onChanged;

  /// The current search text. The field starts with it (a search that survives
  /// leaving the screen) and follows it when something else changes it, such as
  /// a "Clear search" button.
  final String text;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) => CairnInput(
    controller: _controller,
    placeholder: widget.placeholder,
    semanticLabel: widget.placeholder,
    textInputAction: TextInputAction.search,
    onChanged: widget.onChanged,
    leading: const Icon(Icons.search),
    trailing: _controller.text.isEmpty
        ? null
        : GestureDetector(
            onTap: _clear,
            behavior: HitTestBehavior.opaque,
            child: Semantics(
              button: true,
              label: 'Clear search',
              child: const Icon(Icons.close),
            ),
          ),
  );
}
