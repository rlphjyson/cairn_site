import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/cart/models/delivery_method.dart';
import '../../../domain/checkout/models/payment_details.dart';
import '../../../domain/checkout/use_cases/place_order.dart';
import '../../../domain/checkout/use_cases/validate_payment_details.dart';
import '../../../domain/checkout/use_cases/validate_shipping_details.dart';
import '../../../domain/orders/models/order.dart';
import '../../../domain/orders/models/shipping_details.dart';

/// Where checkout is up to.
enum CheckoutStatus {
  /// Not checking out; the cart shows.
  idle,

  /// Filling in the steps.
  editing,

  /// Placing the order.
  placing,

  /// The order went through; see [CheckoutState.order].
  placed,
}

/// The steps before an order is placed, in order. The confirmation is not a
/// step: it is [CheckoutStatus.placed].
enum CheckoutStep {
  /// Address and delivery method.
  shipping('Shipping'),

  /// Card details.
  payment('Payment'),

  /// A last look.
  review('Review');

  const CheckoutStep(this.label);

  /// The label on the progress bar.
  final String label;
}

/// The checkout state: step, form values and any errors.
class CheckoutState extends Equatable {
  /// Creates a state.
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.step = CheckoutStep.shipping,
    this.shipping = const ShippingDetails(),
    this.delivery = DeliveryMethod.standard,
    this.payment = const PaymentDetails(),
    this.shippingErrors = const <ShippingField, String>{},
    this.paymentErrors = const <PaymentField, String>{},
    this.shippingAttempted = false,
    this.paymentAttempted = false,
    this.order,
    this.failure,
  });

  /// Progress.
  final CheckoutStatus status;

  /// The current step while [status] is [CheckoutStatus.editing].
  final CheckoutStep step;

  /// The shipping form.
  final ShippingDetails shipping;

  /// The delivery method.
  final DeliveryMethod delivery;

  /// The payment form.
  final PaymentDetails payment;

  /// Shipping errors, shown once the shopper has tried to continue.
  final Map<ShippingField, String> shippingErrors;

  /// Payment errors, shown once the shopper has tried to continue.
  final Map<PaymentField, String> paymentErrors;

  /// Whether Continue has been pressed on the shipping step.
  final bool shippingAttempted;

  /// Whether Continue has been pressed on the payment step.
  final bool paymentAttempted;

  /// The placed order, once [status] is [CheckoutStatus.placed].
  final Order? order;

  /// A message when placing the order failed.
  final String? failure;

  /// Whether the shopper is in the middle of checking out.
  bool get isActive =>
      status == CheckoutStatus.editing || status == CheckoutStatus.placing;

  /// A copy with the given fields replaced. Pass `clearFailure` to drop the
  /// failure message.
  CheckoutState copyWith({
    CheckoutStatus? status,
    CheckoutStep? step,
    ShippingDetails? shipping,
    DeliveryMethod? delivery,
    PaymentDetails? payment,
    Map<ShippingField, String>? shippingErrors,
    Map<PaymentField, String>? paymentErrors,
    bool? shippingAttempted,
    bool? paymentAttempted,
    Order? order,
    String? failure,
    bool clearFailure = false,
  }) => CheckoutState(
    status: status ?? this.status,
    step: step ?? this.step,
    shipping: shipping ?? this.shipping,
    delivery: delivery ?? this.delivery,
    payment: payment ?? this.payment,
    shippingErrors: shippingErrors ?? this.shippingErrors,
    paymentErrors: paymentErrors ?? this.paymentErrors,
    shippingAttempted: shippingAttempted ?? this.shippingAttempted,
    paymentAttempted: paymentAttempted ?? this.paymentAttempted,
    order: order ?? this.order,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    step,
    shipping,
    delivery,
    payment,
    shippingErrors,
    paymentErrors,
    shippingAttempted,
    paymentAttempted,
    order,
    failure,
  ];
}

/// Session-scoped checkout: the current step and everything typed so far.
///
/// A lazy singleton, so going back to the cart and returning keeps the form.
class CheckoutCubit extends Cubit<CheckoutState> {
  /// Creates the cubit.
  CheckoutCubit(this._placeOrder, this._validateShipping, this._validatePayment)
    : super(const CheckoutState());

  final PlaceOrder _placeOrder;
  final ValidateShippingDetails _validateShipping;
  final ValidatePaymentDetails _validatePayment;

  /// Starts (or resumes) checkout at the shipping step. [prefill] fills an
  /// empty shipping form, e.g. from the signed-in account.
  void begin({ShippingDetails? prefill}) {
    final ShippingDetails shipping = state.shipping.isBlank && prefill != null
        ? prefill
        : state.shipping;
    emit(
      state.copyWith(
        status: CheckoutStatus.editing,
        step: CheckoutStep.shipping,
        shipping: shipping,
        clearFailure: true,
      ),
    );
  }

  /// Replaces the shipping form's values.
  void updateShipping(ShippingDetails shipping) => emit(
    state.copyWith(
      shipping: shipping,
      shippingErrors: state.shippingAttempted
          ? _validateShipping(shipping)
          : null,
    ),
  );

  /// Chooses the delivery method.
  void setDelivery(DeliveryMethod delivery) =>
      emit(state.copyWith(delivery: delivery));

  /// Replaces the payment form's values.
  void updatePayment(PaymentDetails payment) => emit(
    state.copyWith(
      payment: payment,
      paymentErrors: state.paymentAttempted ? _validatePayment(payment) : null,
    ),
  );

  /// Moves to the next step, or shows the errors that stop it.
  void next() {
    switch (state.step) {
      case CheckoutStep.shipping:
        final Map<ShippingField, String> errors = _validateShipping(
          state.shipping,
        );
        emit(
          errors.isEmpty
              ? state.copyWith(
                  step: CheckoutStep.payment,
                  shippingErrors: errors,
                  shippingAttempted: true,
                )
              : state.copyWith(shippingErrors: errors, shippingAttempted: true),
        );
      case CheckoutStep.payment:
        final Map<PaymentField, String> errors = _validatePayment(
          state.payment,
        );
        emit(
          errors.isEmpty
              ? state.copyWith(
                  step: CheckoutStep.review,
                  paymentErrors: errors,
                  paymentAttempted: true,
                )
              : state.copyWith(paymentErrors: errors, paymentAttempted: true),
        );
      case CheckoutStep.review:
        break;
    }
  }

  /// Goes back a step, or out to the cart from the first step. Nothing typed
  /// is lost.
  void back() {
    switch (state.step) {
      case CheckoutStep.shipping:
        exit();
      case CheckoutStep.payment:
        emit(state.copyWith(step: CheckoutStep.shipping));
      case CheckoutStep.review:
        emit(state.copyWith(step: CheckoutStep.payment));
    }
  }

  /// Jumps back to an earlier [step], from the review's edit links.
  void goTo(CheckoutStep step) => emit(state.copyWith(step: step));

  /// Leaves checkout for the cart, keeping the form.
  void exit() => emit(state.copyWith(status: CheckoutStatus.idle));

  /// Places the order for the current cart.
  Future<void> placeOrder() async {
    if (state.status == CheckoutStatus.placing) return;
    emit(state.copyWith(status: CheckoutStatus.placing, clearFailure: true));
    Order? order;
    try {
      order = await _placeOrder(
        shipping: state.shipping,
        delivery: state.delivery,
        payment: state.payment,
      );
    } on Object {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CheckoutStatus.editing,
          failure: 'We could not place your order. Please try again.',
        ),
      );
      return;
    }
    if (isClosed) return;
    if (order == null) {
      emit(
        state.copyWith(
          status: CheckoutStatus.editing,
          failure: 'Your cart is empty, so there is nothing to order.',
        ),
      );
      return;
    }
    // The card details are not kept once the order is placed.
    emit(
      CheckoutState(
        status: CheckoutStatus.placed,
        shipping: state.shipping,
        delivery: state.delivery,
        order: order,
      ),
    );
  }

  /// Clears the confirmation so the next order starts clean.
  void reset() => emit(CheckoutState(shipping: state.shipping));
}
