import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The tabs in the bottom dock, in order.
enum ShopTab {
  /// The storefront.
  shop,

  /// Saved products.
  saved,

  /// The cart and checkout.
  cart,

  /// Account and settings.
  profile,
}

/// Where the user is: a tab, and optionally a product page or an order page on
/// top of it.
class ShopNavigationState extends Equatable {
  /// Creates a state.
  const ShopNavigationState({
    this.tab = ShopTab.shop,
    this.productId,
    this.orderId,
  });

  /// The selected tab.
  final ShopTab tab;

  /// The open product, or `null` when none.
  final String? productId;

  /// The open order, or `null` when none.
  final String? orderId;

  @override
  List<Object?> get props => <Object?>[tab, productId, orderId];
}

/// Navigation inside the phone.
///
/// The template deliberately does not use the host app's router: it has to run
/// unchanged inside any Flutter app, whatever that app uses for routing. In a
/// real project, swap this cubit for `go_router` or `Navigator` and keep every
/// view as it is (see `doc/index.html`).
class ShopNavigationCubit extends Cubit<ShopNavigationState> {
  /// Creates the cubit.
  ShopNavigationCubit() : super(const ShopNavigationState());

  /// Switches tab and closes any open product or order.
  void selectTab(ShopTab tab) => emit(ShopNavigationState(tab: tab));

  /// Opens a product page over the current tab.
  void openProduct(String id) =>
      emit(ShopNavigationState(tab: state.tab, productId: id));

  /// Opens an order's page over the profile tab.
  void openOrder(String id) =>
      emit(ShopNavigationState(tab: ShopTab.profile, orderId: id));

  /// Closes the product or order page.
  void back() => emit(ShopNavigationState(tab: state.tab));
}
