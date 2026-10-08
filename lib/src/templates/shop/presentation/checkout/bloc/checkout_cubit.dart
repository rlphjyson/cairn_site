import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/checkout/models/order.dart';
import '../../../domain/checkout/use_cases/place_order.dart';

/// Where checkout is up to.
enum CheckoutStatus {
  /// Nothing placed.
  idle,

  /// Placing an order.
  placing,

  /// The last order succeeded; see [CheckoutState.order].
  placed,
}

/// The checkout state.
class CheckoutState extends Equatable {
  /// Creates a state.
  const CheckoutState({this.status = CheckoutStatus.idle, this.order});

  /// Progress.
  final CheckoutStatus status;

  /// The placed order, once [status] is [CheckoutStatus.placed].
  final Order? order;

  @override
  List<Object?> get props => <Object?>[status, order];
}

/// Session-scoped checkout state. A lazy singleton.
class CheckoutCubit extends Cubit<CheckoutState> {
  /// Creates the cubit.
  CheckoutCubit(this._placeOrder) : super(const CheckoutState());

  final PlaceOrder _placeOrder;

  /// Places an order for the current cart.
  Future<void> placeOrder() async {
    if (state.status == CheckoutStatus.placing) return;
    emit(const CheckoutState(status: CheckoutStatus.placing));
    final Order? order = await _placeOrder();
    if (isClosed) return;
    emit(
      order == null
          ? const CheckoutState()
          : CheckoutState(status: CheckoutStatus.placed, order: order),
    );
  }

  /// Clears the confirmation so the next order starts clean.
  void reset() => emit(const CheckoutState());
}
