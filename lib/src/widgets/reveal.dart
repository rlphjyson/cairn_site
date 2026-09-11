import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Fades and lifts its child into place once, on mount.
///
/// Used to stagger the hero. The duration and curve are Cairn's own
/// [CairnMotion] values rather than invented ones, and the whole effect is
/// skipped when the platform asks for reduced motion — an entrance animation is
/// exactly the kind of thing that makes a vestibular disorder worse.
class Reveal extends StatefulWidget {
  /// Wraps [child].
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 16.0,
    this.duration = const Duration(milliseconds: 520),
  });

  /// The content.
  final Widget child;

  /// How long to wait before starting.
  final Duration delay;

  /// How far below its final position the child starts.
  final double offset;

  /// How long the reveal takes.
  final Duration duration;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: CairnMotion.easeOut,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _curve,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
