import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../core/presentation/widgets/empty_state.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../catalog/widgets/product_grid.dart';
import '../../catalog/widgets/suggested_products.dart';
import '../bloc/saved_cubit.dart';

/// Everything the shopper has hearted.
class SavedView extends StatelessWidget {
  /// Creates the view.
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedCubit, SavedState>(
      builder: (BuildContext context, SavedState state) {
        if (state.products.isEmpty) {
          return EmptyState(
            icon: Icons.favorite_border,
            title: 'Nothing saved yet',
            body: 'Tap the heart on anything you like and it will wait here.',
            action: 'Browse the shop',
            onAction: () =>
                context.read<ShopNavigationCubit>().selectTab(ShopTab.shop),
            below: const SuggestedProducts(title: 'Start with these'),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            ScreenTitle(
              'Saved',
              trailing: CairnBadge(
                variant: CairnBadgeVariant.secondary,
                label: Text('${state.products.length}'),
              ),
            ),
            const SizedBox(height: 16),
            ProductGrid(products: state.products),
            const SizedBox(height: 28),
            SuggestedProducts(title: 'You might also like', exclude: state.ids),
          ],
        );
      },
    );
  }
}
