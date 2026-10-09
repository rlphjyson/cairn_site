import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/promo_codes.dart';
import '../../../core/presentation/shop_text.dart';
import '../bloc/cart_cubit.dart';

/// The cart's promo code box: an input and Apply button, or the applied code
/// with a way to remove it.
class PromoCodeField extends StatefulWidget {
  /// Creates the field.
  const PromoCodeField({super.key});

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final bool ok = await context.read<CartCubit>().applyPromo(
      _controller.text,
    );
    if (ok) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CartState cart = context.watch<CartCubit>().state;
    final cairnSuccess = CairnToneColors.resolve(theme, CairnTone.success).fill;

    if (cart.promo != null) {
      return Row(
        spacing: 8,
        children: <Widget>[
          Icon(Icons.local_offer_outlined, size: 16, color: cairnSuccess),
          Expanded(
            child: Text(
              '${cart.promo!.code} applied: ${cart.promo!.percentOff}% off',
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.sm),
                weight: CairnTypography.medium,
              ),
            ),
          ),
          CairnButton(
            size: CairnButtonSize.sm,
            variant: CairnButtonVariant.ghost,
            semanticLabel: 'Remove promo code',
            onPressed: context.read<CartCubit>().removePromo,
            child: const Text('Remove'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          spacing: 8,
          children: <Widget>[
            Expanded(
              child: CairnInput(
                controller: _controller,
                placeholder: 'Promo code',
                semanticLabel: 'Promo code',
                hasError: cart.promoError != null,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _apply(),
              ),
            ),
            CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: _apply,
              child: const Text('Apply'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Semantics(
          liveRegion: cart.promoError != null,
          child: Text(
            cart.promoError ?? 'Try ${PromoCodes.hint} for 10% off.',
            style: shopText(
              theme,
              theme.textStyle(CairnTypography.xs),
              color: cart.promoError != null
                  ? theme.destructive
                  : theme.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
