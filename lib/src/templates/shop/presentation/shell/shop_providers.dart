import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../cart/bloc/cart_cubit.dart';
import '../checkout/bloc/checkout_cubit.dart';
import '../profile/bloc/profile_cubit.dart';
import '../saved/bloc/saved_cubit.dart';

/// Exposes the session-scoped cubits to every screen.
///
/// These are lazy singletons owned by the container, so they are provided with
/// `BlocProvider.value` (which never closes them). Views read them with
/// `context.read` and never touch the container.
class ShopProviders extends StatelessWidget {
  /// Creates the providers.
  const ShopProviders({super.key, required this.locator, required this.child});

  /// The container that owns the cubits.
  final GetIt locator;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ShopNavigationCubit>.value(
        value: locator<ShopNavigationCubit>(),
      ),
      BlocProvider<SavedCubit>.value(value: locator<SavedCubit>()),
      BlocProvider<CartCubit>.value(value: locator<CartCubit>()),
      BlocProvider<CheckoutCubit>.value(value: locator<CheckoutCubit>()),
      BlocProvider<ProfileCubit>.value(value: locator<ProfileCubit>()),
    ],
    // A placed order empties the cart in the repository; this keeps the cart
    // cubit's state in step without the two features knowing about each other.
    child: BlocListener<CheckoutCubit, CheckoutState>(
      listenWhen: (CheckoutState previous, CheckoutState current) =>
          previous.status != current.status &&
          current.status == CheckoutStatus.placed,
      listener: (BuildContext context, CheckoutState state) =>
          context.read<CartCubit>().load(),
      child: child,
    ),
  );
}
