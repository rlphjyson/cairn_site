import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/shipping_policy.dart';
import '../../../common/utils/dates.dart';
import '../../../common/utils/money.dart';
import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/empty_state.dart';
import '../../../core/presentation/widgets/price_text.dart';
import '../../../core/presentation/widgets/product_photo.dart';
import '../../../core/presentation/widgets/quantity_stepper.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/models/review.dart';
import '../../../domain/catalog/models/variant_group.dart';
import '../../cart/bloc/cart_cubit.dart';
import '../../saved/widgets/save_button.dart';
import '../bloc/product_detail_cubit.dart';
import '../view_models/product_detail_view_model.dart';
import '../widgets/product_badges.dart';
import '../widgets/product_row.dart';

/// A product page: hero photo, price, rating, stock, variants, quantity,
/// details, reviews, suggestions and a sticky buy bar.
class ProductDetailView extends StatelessWidget {
  /// Creates the view.
  const ProductDetailView({super.key, required this.productId});

  /// Which product to show.
  final String productId;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductDetailViewModel>(
      onCreate: (BuildContext context, ProductDetailViewModel vm) =>
          vm.cubit.load(productId),
      builder: (BuildContext context, ProductDetailViewModel vm) =>
          BlocBuilder<ProductDetailCubit, ProductDetailState>(
            bloc: vm.cubit,
            builder: (BuildContext context, ProductDetailState state) {
              if (!state.loaded) {
                return const Center(child: CairnSpinner());
              }
              final Product? product = state.product;
              if (product == null) {
                return EmptyState(
                  icon: Icons.search_off,
                  title: 'We could not find that product',
                  body: 'It may have been removed.',
                  action: 'Back to the shop',
                  onAction: context.read<ShopNavigationCubit>().back,
                );
              }
              return _Content(product: product, state: state, cubit: vm.cubit);
            },
          ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({
    required this.product,
    required this.state,
    required this.cubit,
  });

  final Product product;
  final ProductDetailState state;
  final ProductDetailCubit cubit;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  Set<String> _open = const <String>{'details'};

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Product product = widget.product;
    final ProductDetailState state = widget.state;
    const EdgeInsets side = EdgeInsets.symmetric(horizontal: 16);

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              _Hero(product: product),
              const SizedBox(height: 16),
              Padding(
                padding: side,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            product.category,
                            style: shopText(
                              theme,
                              theme.textStyle(CairnTypography.sm),
                              color: theme.mutedForeground,
                            ),
                          ),
                        ),
                        _StockBadge(product: product),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      header: true,
                      child: Text(
                        product.name,
                        style: shopText(
                          theme,
                          theme.textStyle(CairnTypography.xl2),
                          weight: CairnTypography.semibold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      spacing: 8,
                      children: <Widget>[
                        PriceText(
                          price: product.price,
                          compareAt: product.compareAtPrice,
                          style: CairnTypography.xl,
                          compareStyle: CairnTypography.sm,
                        ),
                        if (product.isOnSale)
                          CairnBadge(
                            variant: CairnBadgeVariant.destructive,
                            label: Text('-${product.discountPercent}%'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RatingSummary(product: product),
                    const SizedBox(height: 14),
                    Text(
                      product.description,
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.sm),
                        color: theme.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                    for (final VariantGroup group
                        in product.variantGroups) ...<Widget>[
                      const SizedBox(height: 18),
                      _VariantPicker(
                        group: group,
                        selected:
                            state.selection[group.label] ?? group.values.first,
                        onSelected: (String v) =>
                            widget.cubit.selectVariant(group.label, v),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Quantity',
                            style: shopText(
                              theme,
                              theme.textStyle(CairnTypography.sm),
                              weight: CairnTypography.medium,
                            ),
                          ),
                        ),
                        QuantityStepper(
                          value: state.quantity,
                          max: state.maxQuantity < 1 ? 1 : state.maxQuantity,
                          subject: product.name,
                          onChanged: widget.cubit.setQuantity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CairnAccordion(
                      multiple: true,
                      expanded: _open,
                      onChanged: (Set<String> next) =>
                          setState(() => _open = next),
                      items: <CairnAccordionItem>[
                        CairnAccordionItem(
                          value: 'details',
                          title: const Text('Details'),
                          content: _Bullets(product.details),
                        ),
                        const CairnAccordionItem(
                          value: 'shipping',
                          title: Text('Shipping & returns'),
                          content: _ShippingInfo(),
                        ),
                        CairnAccordionItem(
                          value: 'reviews',
                          title: Text('Reviews (${product.reviews.length})'),
                          content: _Reviews(product: product),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (state.related.isNotEmpty) ...<Widget>[
                const SizedBox(height: 24),
                const Padding(
                  padding: side,
                  child: SectionHeader('You may also like'),
                ),
                const SizedBox(height: 12),
                ProductRow(products: state.related, tileWidth: 140),
              ],
            ],
          ),
        ),
        _BuyBar(product: product, state: state),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.2,
          child: ProductPhoto(product.imageAsset, radius: 0),
        ),
        Positioned(
          top: 8,
          left: 12,
          child: CairnButton.icon(
            variant: CairnButtonVariant.secondary,
            icon: const CairnIcon(CairnIconData.chevronLeft),
            semanticLabel: 'Back',
            onPressed: () => context.read<ShopNavigationCubit>().back(),
          ),
        ),
        Positioned(
          top: 8,
          right: 12,
          child: SaveButton(
            productId: product.id,
            size: CairnButtonSize.iconMd,
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: IgnorePointer(child: ProductBadges(product)),
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return const CairnBadge(
        variant: CairnBadgeVariant.destructive,
        label: Text('Sold out'),
      );
    }
    if (product.isLowStock) {
      return CairnBadge(
        variant: CairnBadgeVariant.destructive,
        label: Text('Only ${product.stock} left'),
      );
    }
    return const CairnBadge(
      variant: CairnBadgeVariant.outline,
      label: Text('In stock'),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      spacing: 8,
      children: <Widget>[
        CairnRating(
          value: product.rating,
          size: 14,
          allowHalf: true,
          semanticLabel: 'Rated ${product.rating.toStringAsFixed(1)} out of 5',
        ),
        Flexible(
          child: Text(
            '${product.rating.toStringAsFixed(1)} · '
            '${product.ratingCount} ratings',
            style: shopText(
              theme,
              theme.textStyle(CairnTypography.xs),
              color: theme.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({
    required this.group,
    required this.selected,
    required this.onSelected,
  });

  final VariantGroup group;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: group.label,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  weight: CairnTypography.medium,
                ),
              ),
              TextSpan(
                text: '  $selected',
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  color: theme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: CairnToggleGroup<String>(
            type: CairnToggleGroupType.single,
            variant: CairnToggleVariant.outline,
            size: CairnToggleSize.md,
            semanticLabel: group.label,
            values: <String>{selected},
            onChanged: (Set<String> v) {
              if (v.isNotEmpty) onSelected(v.first);
            },
            items: <CairnToggleGroupItem<String>>[
              for (final String v in group.values)
                CairnToggleGroupItem<String>(
                  value: v,
                  semanticLabel: '${group.label} $v',
                  child: Text(v),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    if (items.isEmpty) {
      return Text(
        'No further details.',
        style: shopText(
          theme,
          theme.textStyle(CairnTypography.sm),
          color: theme.mutedForeground,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: <Widget>[
        for (final String item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 10),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.mutedForeground,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: shopText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    color: theme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ShippingInfo extends StatelessWidget {
  const _ShippingInfo();

  @override
  Widget build(BuildContext context) => _Bullets(<String>[
    'Free standard delivery over '
        '${formatMoney(ShippingPolicy.freeShippingThreshold)}, otherwise '
        '${formatMoney(ShippingPolicy.flatRate)}. '
        'About ${ShippingPolicy.standardDays} business days.',
    'Express delivery is ${formatMoney(ShippingPolicy.expressRate)}, about '
        '${ShippingPolicy.expressDays} business days.',
    'Return unworn items within ${ShippingPolicy.returnWindowDays} days for a '
        'full refund.',
  ]);
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    if (product.reviews.isEmpty) {
      return Text(
        'No written reviews yet.',
        style: shopText(
          theme,
          theme.textStyle(CairnTypography.sm),
          color: theme.mutedForeground,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        for (final Review r in product.reviews)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                spacing: 10,
                children: <Widget>[
                  CairnAvatar(
                    size: CairnAvatarSize.sm,
                    fallback: Text(r.initials),
                    semanticLabel: r.author,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          r.author,
                          style: shopText(
                            theme,
                            theme.textStyle(CairnTypography.sm),
                            weight: CairnTypography.medium,
                          ),
                        ),
                        Row(
                          spacing: 8,
                          children: <Widget>[
                            CairnRating(
                              value: r.rating,
                              size: 12,
                              semanticLabel: '${r.rating.round()} out of 5',
                            ),
                            Flexible(
                              child: Text(
                                formatDate(r.date),
                                style: shopText(
                                  theme,
                                  theme.textStyle(CairnTypography.xs),
                                  color: theme.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                r.text,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  color: theme.mutedForeground,
                  height: 1.45,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.product, required this.state});

  final Product product;
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String lineKey = CartLine.lineKey(product.id, state.variant);
    final int inCart = context.select(
      (CartCubit c) => c.state.quantityOfLine(lineKey),
    );
    final int max = state.maxQuantity;
    final bool atMax = product.inStock && inCart >= max;
    final bool canAdd = product.inStock && !atMax;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (inCart > 0) ...<Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: CairnToneColors.resolve(
                      theme,
                      CairnTone.success,
                    ).fill,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$inCart in your cart',
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.xs),
                        color: theme.mutedForeground,
                      ),
                    ),
                  ),
                  CairnButton(
                    size: CairnButtonSize.xs,
                    variant: CairnButtonVariant.link,
                    onPressed: () => context
                        .read<ShopNavigationCubit>()
                        .selectTab(ShopTab.cart),
                    child: const Text('View cart'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              spacing: 16,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.xs),
                        color: theme.mutedForeground,
                      ),
                    ),
                    Text(
                      formatMoney(product.price * state.quantity),
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.lg),
                        weight: CairnTypography.semibold,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: CairnButton(
                    expand: true,
                    onPressed: canAdd
                        ? () => context.read<CartCubit>().add(
                            product.id,
                            variant: state.variant,
                            quantity: state.quantity > max - inCart
                                ? max - inCart
                                : state.quantity,
                          )
                        : null,
                    leading: const Icon(Icons.add_shopping_cart, size: 16),
                    child: Text(
                      !product.inStock
                          ? 'Sold out'
                          : atMax
                          ? 'Maximum in cart'
                          : 'Add to cart',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
