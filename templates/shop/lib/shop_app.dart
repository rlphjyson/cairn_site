import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/shop_injection.dart';
import 'core/presentation/view_model.dart';
import 'core/presentation/widgets/shop_column.dart';
import 'presentation/cart/bloc/cart_cubit.dart';
import 'presentation/catalog/bloc/catalog_cubit.dart';
import 'presentation/orders/bloc/orders_cubit.dart';
import 'presentation/profile/bloc/profile_cubit.dart';
import 'presentation/saved/bloc/saved_cubit.dart';
import 'presentation/shell/shop_providers.dart';
import 'presentation/shell/shop_shell.dart';

/// A sample e-commerce app, built only from `cairn_ui` and Cairn tokens.
///
/// A storefront with sorting and filtering, product pages with variants and
/// reviews, a cart with promo codes, a four-step checkout, order history and a
/// profile, in a phone-shaped column. It fills whatever space it is given up to
/// a phone's width and stays a centred column on anything wider.
///
/// It is organised as clean architecture, by layer and then by feature; see the
/// README next to this file. Photographs are from Pexels, used under the
/// Pexels licence.
class ShopApp extends StatefulWidget {
  /// Creates the app.
  ///
  /// [catalogLatency] simulates the time a real backend takes to return the
  /// catalogue, so the storefront's skeletons show. Pass [Duration.zero] to
  /// load instantly (tests do).
  const ShopApp({
    super.key,
    this.catalogLatency = const Duration(milliseconds: 600),
  });

  /// How long the in-memory catalogue takes to load.
  final Duration catalogLatency;

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late final GetIt _locator = createShopLocator(
    catalogLatency: widget.catalogLatency,
  );

  @override
  void initState() {
    super.initState();
    // Session state is loaded once, up front, so every tab opens populated.
    unawaited(_locator<CatalogCubit>().load());
    unawaited(_locator<SavedCubit>().load());
    unawaited(_locator<CartCubit>().load());
    unawaited(_locator<ProfileCubit>().load());
    unawaited(_locator<OrdersCubit>().load());
  }

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShopScope(
    locator: _locator,
    child: ShopProviders(
      locator: _locator,
      child: const ShopColumn(child: ShopShell()),
    ),
  );
}
