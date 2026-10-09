import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/formatters/card_formatters.dart';
import '../../../core/presentation/widgets/labeled_field.dart';
import '../../../domain/checkout/models/payment_details.dart';
import '../../../domain/checkout/use_cases/validate_payment_details.dart';
import '../bloc/checkout_cubit.dart';

/// Step two: card details, clearly marked as a demo.
class PaymentStep extends StatefulWidget {
  /// Creates the step.
  const PaymentStep({super.key});

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  late final PaymentDetails _initial = context
      .read<CheckoutCubit>()
      .state
      .payment;
  late final TextEditingController _holder = TextEditingController(
    text: _initial.cardHolder,
  );
  late final TextEditingController _number = TextEditingController(
    text: _initial.cardNumber,
  );
  late final TextEditingController _expiry = TextEditingController(
    text: _initial.expiry,
  );
  late final TextEditingController _cvc = TextEditingController(
    text: _initial.cvc,
  );

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _holder,
      _number,
      _expiry,
      _cvc,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed() => context.read<CheckoutCubit>().updatePayment(
    PaymentDetails(
      cardHolder: _holder.text,
      cardNumber: _number.text,
      expiry: _expiry.text,
      cvc: _cvc.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Map<PaymentField, String> e = context
        .watch<CheckoutCubit>()
        .state
        .paymentErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: <Widget>[
        const CairnAlert(
          icon: Icon(Icons.info_outline),
          title: Text('This is a demo checkout'),
          description: Text(
            'Card details stay on this device and no payment is taken. Try '
            '4242 4242 4242 4242 with any future expiry and any 3 digit code.',
          ),
        ),
        LabeledField(
          label: 'Name on card',
          controller: _holder,
          error: e[PaymentField.cardHolder],
          keyboardType: TextInputType.name,
          onChanged: (_) => _changed(),
        ),
        LabeledField(
          label: 'Card number',
          controller: _number,
          error: e[PaymentField.cardNumber],
          placeholder: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          inputFormatters: const <TextInputFormatter>[CardNumberFormatter()],
          onChanged: (_) => _changed(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            Expanded(
              child: LabeledField(
                label: 'Expiry',
                controller: _expiry,
                error: e[PaymentField.expiry],
                placeholder: 'MM/YY',
                keyboardType: TextInputType.number,
                inputFormatters: const <TextInputFormatter>[ExpiryFormatter()],
                onChanged: (_) => _changed(),
              ),
            ),
            Expanded(
              child: LabeledField(
                label: 'CVC',
                controller: _cvc,
                error: e[PaymentField.cvc],
                placeholder: '123',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 4,
                obscureText: true,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => _changed(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
