import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Fades and lifts its child into place the first time it scrolls into view.
///
/// One short, finite animation using Cairn's own [CairnMotion] values, so tests
/// can pump through it. Skipped entirely when the platform asks for reduced
/// motion, and when there is no scrollable above it.
class Reveal extends StatefulWidget {
  /// Wraps [child].
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 20.0,
  });

  /// The content.
  final Widget child;

  /// How long to wait after becoming visible.
  final Duration delay;

  /// How far below its final position the child starts.
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  // The delay is folded into one controller run, as the leading part of an
  // [Interval], so no timer is ever scheduled and tests can pump through it.
  late final Duration _total = widget.delay + CairnMotion.d500;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.delay.inMilliseconds / _total.inMilliseconds,
      1,
      curve: CairnMotion.easeOut,
    ),
  );
  ScrollPosition? _position;
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollPosition? next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_check);
      _position = next?..addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    if (_shown || !mounted) return;
    final RenderObject? self = context.findRenderObject();
    final RenderObject? scroller = Scrollable.maybeOf(
      context,
    )?.context.findRenderObject();
    if (self is! RenderBox || !self.attached) return;
    if (scroller is! RenderBox) {
      _show();
      return;
    }
    final double top = self.localToGlobal(Offset.zero, ancestor: scroller).dy;
    if (top < scroller.size.height * 0.94) _show();
  }

  void _show() {
    _shown = true;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }
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
