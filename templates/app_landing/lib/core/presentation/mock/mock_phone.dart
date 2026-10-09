import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/shared/models/app_screen.dart';
import 'app_screen_view.dart';

/// A [CairnMockupPhone] showing a live mock app screen.
///
/// The screen is laid out once at [AppScreenView.designSize] and scaled to the
/// phone, so it looks the same at any [width] and can never overflow. It is
/// decorative: it takes no pointer or keyboard input, and screen readers get
/// the screen's description instead of its widgets.
class MockPhone extends StatelessWidget {
  /// Creates a phone showing [screen].
  const MockPhone({super.key, required this.screen, this.width = 220});

  /// What the phone shows.
  final AppScreen screen;

  /// The device width; the height follows the phone's aspect ratio.
  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    image: true,
    label: screen.description,
    child: ExcludeSemantics(
      child: ExcludeFocus(
        child: IgnorePointer(
          child: CairnMockupPhone(
            width: width,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox.fromSize(
                size: AppScreenView.designSize,
                child: AppScreenView(screen: screen),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
