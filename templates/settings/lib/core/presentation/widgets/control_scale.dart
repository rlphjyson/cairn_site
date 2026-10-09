import 'package:flutter/widgets.dart';

/// Limits how far text inside a fixed-height Cairn control scales.
///
/// Cairn's input and select are 36 px tall, so at the largest text sizes their
/// text would be cut off. Inside this wrapper the text still grows (up to
/// [maxScale] times), which is as much as the control can hold. Everything
/// around it, labels, hints and errors, keeps the full scale.
class ControlScale extends StatelessWidget {
  /// Creates the wrapper.
  const ControlScale({super.key, required this.child, this.maxScale = 1.5});

  /// The control.
  final Widget child;

  /// The largest scale factor the control's own text may use.
  final double maxScale;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: MediaQuery.textScalerOf(
        context,
      ).clamp(maxScaleFactor: maxScale),
    ),
    child: child,
  );
}

/// Whether text is scaled enough that a row should stack its action under its
/// text instead of beside it.
bool isLargeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(10) > 13.5;
