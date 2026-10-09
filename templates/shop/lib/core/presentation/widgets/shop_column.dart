import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// The widest the shop's content gets, however wide the space it is given.
const double shopMaxWidth = 480;

/// Below this width the shop fills the space; from it up the shop stays a
/// centred column of [shopMaxWidth].
const double shopWideBreakpoint = 700;

/// Keeps the shop a phone-shaped column on wide screens.
///
/// In a phone frame (or any narrow space) it does nothing. On a tablet the
/// content stays centred at [shopMaxWidth], with hairlines on either side.
class ShopColumn extends StatelessWidget {
  /// Creates a column.
  const ShopColumn({super.key, required this.child});

  /// The shop.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        if (box.maxWidth < shopWideBreakpoint) return child;
        final CairnTheme theme = CairnTheme.of(context);
        return ColoredBox(
          color: theme.muted.withValues(alpha: 0.4),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.background,
                border: Border.symmetric(
                  vertical: BorderSide(color: theme.border),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: shopMaxWidth),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
