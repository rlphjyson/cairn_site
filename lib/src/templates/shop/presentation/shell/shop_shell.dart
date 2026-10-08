import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../cart/bloc/cart_cubit.dart';
import '../catalog/views/product_detail_view.dart';
import '../catalog/views/storefront_view.dart';
import '../profile/views/profile_view.dart';
import '../saved/views/saved_view.dart';
import 'cart_tab.dart';

/// The phone screen: the current view above a bottom dock.
class ShopShell extends StatelessWidget {
  /// Creates the shell.
  const ShopShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Clears the phone's notch.
        const SizedBox(height: 22),
        Expanded(
          child: BlocBuilder<ShopNavigationCubit, ShopNavigationState>(
            builder: (BuildContext context, ShopNavigationState nav) {
              final String? productId = nav.productId;
              return AnimatedSwitcher(
                duration: CairnMotion.d150,
                child: KeyedSubtree(
                  key: ValueKey<Object>(productId ?? nav.tab),
                  child: productId != null
                      ? ProductDetailView(productId: productId)
                      : switch (nav.tab) {
                          ShopTab.shop => const StorefrontView(),
                          ShopTab.saved => const SavedView(),
                          ShopTab.cart => const CartTab(),
                          ShopTab.profile => const ProfileView(),
                        },
                ),
              );
            },
          ),
        ),
        const _ShopDock(),
      ],
    );
  }
}

class _ShopDock extends StatelessWidget {
  const _ShopDock();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopNavigationCubit, ShopNavigationState>(
      builder: (BuildContext context, ShopNavigationState nav) => CairnDock(
        index: nav.tab.index,
        onChanged: (int i) =>
            context.read<ShopNavigationCubit>().selectTab(ShopTab.values[i]),
        items: <CairnDockItem>[
          const CairnDockItem(
            icon: Icon(Icons.storefront_outlined, size: 20),
            label: 'Shop',
          ),
          const CairnDockItem(
            icon: Icon(Icons.favorite_border, size: 20),
            label: 'Saved',
          ),
          CairnDockItem(
            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
            label: 'Cart',
            badge: context.select((CartCubit c) => c.state.isEmpty)
                ? null
                : const CairnStatus(tone: CairnTone.destructive),
          ),
          const CairnDockItem(
            icon: Icon(Icons.person_outline, size: 20),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
