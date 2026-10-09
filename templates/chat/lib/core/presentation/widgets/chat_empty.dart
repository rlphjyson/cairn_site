import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// An icon, a message and optional actions for a screen with nothing to show.
///
/// Centred, and scrollable so it still works on a short screen.
class ChatEmpty extends StatelessWidget {
  /// Creates an empty state.
  const ChatEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actions = const <Widget>[],
  });

  /// The glyph.
  final IconData icon;

  /// The headline.
  final String title;

  /// The explanation.
  final String description;

  /// Buttons under the text.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints box) =>
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: box.maxHeight.isFinite ? box.maxHeight : 0,
            ),
            child: Center(
              child: Semantics(
                liveRegion: true,
                child: CairnEmpty(
                  bordered: false,
                  media: Icon(icon),
                  title: title,
                  description: description,
                  actions: actions,
                ),
              ),
            ),
          ),
        ),
  );
}
