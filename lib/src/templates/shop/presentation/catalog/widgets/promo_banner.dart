import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// The storefront's seasonal banner.
class PromoBanner extends StatelessWidget {
  /// Creates a banner.
  const PromoBanner({super.key, required this.onShop});

  /// Called when "Shop now" is pressed.
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radiusScale.xl),
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              'assets/images/sneaker-red.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  ColoredBox(color: theme.muted),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xCC000000), Color(0x00000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const CairnBadge(
                    variant: CairnBadgeVariant.secondary,
                    label: Text('New season'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Up to 30% off\nsneakers',
                    style: theme
                        .textStyle(CairnTypography.lg)
                        .copyWith(
                          color: const Color(0xFFFFFFFF),
                          fontWeight: CairnTypography.semibold,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 10),
                  CairnButton(
                    size: CairnButtonSize.sm,
                    variant: CairnButtonVariant.secondary,
                    onPressed: onShop,
                    child: const Text('Shop now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
