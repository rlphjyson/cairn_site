import 'dart:math' as math;

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/mock/mock_phone.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../domain/shared/models/app_screen.dart';

/// Two overlapping phones, slightly rotated, showing live app screens.
///
/// The back phone leans left and sits lower, the front phone leans right. Each
/// eases in once (a fade and a short rise, skipped when the platform asks for
/// reduced motion); nothing loops.
class HeroPhones extends StatelessWidget {
  /// Creates the pair.
  const HeroPhones({super.key, required this.front, required this.back});

  /// The screen on the phone in front.
  final AppScreen front;

  /// The screen on the phone behind.
  final AppScreen back;

  static const double _aspect = 19.5 / 9;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth;
        // The pair is about 1.5 phone widths wide.
        final double frontWidth = math.min(
          available < 460 ? 200.0 : 250.0,
          (available - 32) / 1.702,
        );
        final double backWidth = frontWidth * 0.9;
        final double stackWidth = frontWidth + backWidth * 0.78;
        final double frontHeight = frontWidth * _aspect;
        final double backHeight = backWidth * _aspect;
        final double stackHeight = math.max(frontHeight + 16, backHeight + 56);

        Widget shadowed(Widget phone) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: CairnShadows.xl,
          ),
          child: phone,
        );

        return Center(
          child: SizedBox(
            width: stackWidth + 32,
            height: stackHeight + 16,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                // A soft disc behind the pair.
                Positioned.fill(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.muted.withValues(alpha: 0.7),
                      ),
                      child: SizedBox.square(dimension: stackWidth * 1.05),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 8,
                  child: Reveal(
                    offset: 36,
                    child: Transform.rotate(
                      angle: -0.07,
                      child: shadowed(
                        MockPhone(screen: back, width: backWidth),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 0,
                  child: Reveal(
                    delay: const Duration(milliseconds: 140),
                    offset: 36,
                    child: Transform.rotate(
                      angle: 0.05,
                      child: shadowed(
                        MockPhone(screen: front, width: frontWidth),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
