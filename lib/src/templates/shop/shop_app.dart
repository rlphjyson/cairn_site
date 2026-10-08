import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/shop_injection.dart';
import 'core/presentation/view_model.dart';
import 'presentation/cart/bloc/cart_cubit.dart';
import 'presentation/profile/bloc/profile_cubit.dart';
import 'presentation/saved/bloc/saved_cubit.dart';
import 'presentation/shell/shop_providers.dart';
import 'presentation/shell/shop_shell.dart';

/// A sample e-commerce app, built only from `cairn_ui` and Cairn tokens.
///
/// The flow follows daisyUI's Online Store template (storefront, product page,
/// cart, checkout) reshaped for a phone: a bottom dock instead of a top navbar
/// and a stepped checkout instead of a separate page.
///
/// It is organised as clean architecture, by layer and then by feature; see the README next
/// to this file. Photographs are from Pexels, used under the Pexels licence.
class ShopApp extends StatefulWidget {
  /// Creates the app.
  const ShopApp({super.key});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late final GetIt _locator = createShopLocator();

  @override
  void initState() {
    super.initState();
    // Session state is loaded once, up front, so every tab opens populated.
    unawaited(_locator<SavedCubit>().load());
    unawaited(_locator<CartCubit>().load());
    unawaited(_locator<ProfileCubit>().load());
  }

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShopScope(
    locator: _locator,
    child: ShopProviders(locator: _locator, child: const ShopShell()),
  );
}
