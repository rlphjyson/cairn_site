import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/promo_slides.dart';
import '../../../common/constants/shop_package.dart';
import '../../../core/presentation/widgets/tap_target.dart';

/// The storefront's promotional carousel: a swipeable [PageView] of
/// [PromoSlides.values] with dot indicators.
///
/// Nothing advances on its own: no timers, so it never fights the shopper and
/// tests never wait on it.
class PromoBanner extends StatefulWidget {
  /// Creates a banner.
  const PromoBanner({super.key, required this.onSelect});

  /// Called with the slide whose button was pressed.
  final ValueChanged<PromoSlide> onSelect;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    const List<PromoSlide> slides = PromoSlides.values;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 164,
          child: PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (int i) => setState(() => _page = i),
            itemBuilder: (BuildContext context, int i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Slide(
                slide: slides[i],
                onPressed: () => widget.onSelect(slides[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < slides.length; i++)
              TapTarget(
                semanticLabel: 'Show offer ${i + 1} of ${slides.length}',
                onTap: () => _controller.animateToPage(
                  i,
                  duration: CairnMotion.d150,
                  curve: CairnMotion.standard,
                ),
                child: SizedBox(
                  width: 28,
                  height: 24,
                  child: Center(
                    child: AnimatedContainer(
                      duration: CairnMotion.d150,
                      width: i == _page ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i == _page
                            ? theme.foreground
                            : theme.mutedForeground.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide, required this.onPressed});

  final PromoSlide slide;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radiusScale.xl),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            slide.asset,
            package: ShopPackage.name,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            excludeFromSemantics: true,
            errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                ColoredBox(color: theme.muted),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Color(0xD9000000), Color(0x00000000)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text(slide.tag),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.title,
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
                  onPressed: onPressed,
                  child: Text(slide.action),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
