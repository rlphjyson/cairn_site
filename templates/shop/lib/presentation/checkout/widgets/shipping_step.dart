import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/shipping_policy.dart';
import '../../../common/utils/money.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/labeled_field.dart';
import '../../../domain/cart/models/delivery_method.dart';
import '../../../domain/checkout/use_cases/validate_shipping_details.dart';
import '../../../domain/orders/models/shipping_details.dart';
import '../bloc/checkout_cubit.dart';

/// Step one: who and where to, and how fast.
class ShippingStep extends StatefulWidget {
  /// Creates the step.
  const ShippingStep({super.key});

  @override
  State<ShippingStep> createState() => _ShippingStepState();
}

class _ShippingStepState extends State<ShippingStep> {
  late final ShippingDetails _initial = context
      .read<CheckoutCubit>()
      .state
      .shipping;
  late final TextEditingController _name = TextEditingController(
    text: _initial.fullName,
  );
  late final TextEditingController _email = TextEditingController(
    text: _initial.email,
  );
  late final TextEditingController _phone = TextEditingController(
    text: _initial.phone,
  );
  late final TextEditingController _address = TextEditingController(
    text: _initial.address,
  );
  late final TextEditingController _city = TextEditingController(
    text: _initial.city,
  );
  late final TextEditingController _postal = TextEditingController(
    text: _initial.postalCode,
  );

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _name,
      _email,
      _phone,
      _address,
      _city,
      _postal,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed() => context.read<CheckoutCubit>().updateShipping(
    ShippingDetails(
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      address: _address.text,
      city: _city.text,
      postalCode: _postal.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CheckoutState state = context.watch<CheckoutCubit>().state;
    final Map<ShippingField, String> e = state.shippingErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: <Widget>[
        LabeledField(
          label: 'Full name',
          controller: _name,
          error: e[ShippingField.fullName],
          keyboardType: TextInputType.name,
          onChanged: (_) => _changed(),
        ),
        LabeledField(
          label: 'Email',
          controller: _email,
          error: e[ShippingField.email],
          keyboardType: TextInputType.emailAddress,
          placeholder: 'you@example.com',
          onChanged: (_) => _changed(),
        ),
        LabeledField(
          label: 'Phone',
          controller: _phone,
          error: e[ShippingField.phone],
          keyboardType: TextInputType.phone,
          onChanged: (_) => _changed(),
        ),
        LabeledField(
          label: 'Address',
          controller: _address,
          error: e[ShippingField.address],
          keyboardType: TextInputType.streetAddress,
          onChanged: (_) => _changed(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            Expanded(
              child: LabeledField(
                label: 'City',
                controller: _city,
                error: e[ShippingField.city],
                onChanged: (_) => _changed(),
              ),
            ),
            Expanded(
              child: LabeledField(
                label: 'Postal code',
                controller: _postal,
                error: e[ShippingField.postalCode],
                textInputAction: TextInputAction.done,
                onChanged: (_) => _changed(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Delivery',
          style: shopText(
            theme,
            theme.textStyle(CairnTypography.sm),
            weight: CairnTypography.medium,
          ),
        ),
        // The radio's label is laid out without a width limit, so give it one
        // (the row less the 16px radio and its 8px gap) and let it wrap.
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) =>
              CairnRadioGroup<DeliveryMethod>(
                value: state.delivery,
                semanticLabel: 'Delivery method',
                spacing: 12,
                onChanged: context.read<CheckoutCubit>().setDelivery,
                children: <Widget>[
                  CairnRadioItem<DeliveryMethod>(
                    value: DeliveryMethod.standard,
                    semanticLabel: 'Standard delivery',
                    label: _DeliveryLabel(
                      width: box.maxWidth - 24,
                      title: 'Standard',
                      detail:
                          'About ${ShippingPolicy.standardDays} business '
                          'days. Free over '
                          '${formatMoney(ShippingPolicy.freeShippingThreshold)}'
                          ', otherwise ${formatMoney(ShippingPolicy.flatRate)}.',
                    ),
                  ),
                  CairnRadioItem<DeliveryMethod>(
                    value: DeliveryMethod.express,
                    semanticLabel: 'Express delivery',
                    label: _DeliveryLabel(
                      width: box.maxWidth - 24,
                      title:
                          'Express · ${formatMoney(ShippingPolicy.expressRate)}',
                      detail:
                          'About ${ShippingPolicy.expressDays} business days.',
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }
}

class _DeliveryLabel extends StatelessWidget {
  const _DeliveryLabel({
    required this.width,
    required this.title,
    required this.detail,
  });

  final double width;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: shopText(
              theme,
              theme.textStyle(CairnTypography.sm),
              weight: CairnTypography.medium,
            ),
          ),
          Text(
            detail,
            style: shopText(
              theme,
              theme.textStyle(CairnTypography.xs),
              color: theme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
