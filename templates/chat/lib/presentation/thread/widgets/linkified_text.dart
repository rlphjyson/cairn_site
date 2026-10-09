import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/links.dart';

/// Text in which web addresses are underlined and tappable.
///
/// It inherits the colour and size of the surrounding bubble, so links read
/// correctly on both sent and received messages.
class LinkifiedText extends StatefulWidget {
  /// Creates the text.
  const LinkifiedText(this.text, {super.key, required this.onLink});

  /// The message text.
  final String text;

  /// Called with the address when a link is tapped.
  final ValueChanged<String> onLink;

  @override
  State<LinkifiedText> createState() => _LinkifiedTextState();
}

class _LinkifiedTextState extends State<LinkifiedText> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];
  late List<InlineSpan> _spans = _build();

  List<InlineSpan> _build() {
    for (final TapGestureRecognizer r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    return <InlineSpan>[
      for (final TextPart part in splitLinks(widget.text))
        if (part.isLink)
          TextSpan(
            text: part.text,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: _recognize(part.text),
          )
        else
          TextSpan(text: part.text),
    ];
  }

  TapGestureRecognizer _recognize(String url) {
    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () => widget.onLink(url);
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  void didUpdateWidget(LinkifiedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _spans = _build();
  }

  @override
  void dispose() {
    for (final TapGestureRecognizer r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text.rich(TextSpan(children: _spans));
}
