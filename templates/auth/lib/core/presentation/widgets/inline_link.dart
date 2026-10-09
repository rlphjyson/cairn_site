import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A link that sits inside a sentence.
///
/// Inline links cannot be 44 px tall without breaking the line spacing, so they
/// get a few pixels of tappable padding above and below instead. Stand-alone
/// links use `AuthLink`, which is 44 px.
class InlineLink extends StatelessWidget {
  /// Creates a link.
  const InlineLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.small = false,
    this.padding = 6,
  });

  /// Whether to use the 12 px caption size instead of 14 px.
  final bool small;

  /// Tappable padding above and below the text.
  final double padding;

  /// The link text.
  final String label;

  /// Called when tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    excludeFromSemantics: true,
    onTap: onPressed,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: CairnLink(
        onPressed: onPressed,
        child: Text(
          label,
          style: small ? const TextStyle(fontSize: 12, height: 16 / 12) : null,
        ),
      ),
    ),
  );
}
