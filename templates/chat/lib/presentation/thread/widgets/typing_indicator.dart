import 'dart:math' as math;

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Three dots that rise and fall in turn: "someone is typing".
///
/// The animation controller is owned by this widget and disposed with it, and
/// the loop stops by itself when the widget leaves the tree (a typing
/// indicator only exists while someone is typing).
class TypingDots extends StatefulWidget {
  /// Creates the dots, drawn in [color].
  const TypingDots({super.key, required this.color});

  /// The dots' colour.
  final Color color;

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 28,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < 3; i++)
              Transform.translate(
                offset: Offset(
                  0,
                  -3 *
                      math.max(
                        0,
                        math.sin((_controller.value * 2 - i * 0.3) * math.pi),
                      ),
                ),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// The row at the bottom of a thread while someone is typing: a received bubble
/// with the dots, announced to screen readers as a live region.
class TypingIndicator extends StatelessWidget {
  /// Creates the indicator for [name].
  const TypingIndicator({super.key, required this.name, this.avatar});

  /// Who is typing.
  final String name;

  /// Their avatar, shown beside the bubble in groups.
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        liveRegion: true,
        label: '$name is typing',
        child: CairnChatBubble(
          avatar: avatar,
          child: TypingDots(color: theme.mutedForeground),
        ),
      ),
    );
  }
}
