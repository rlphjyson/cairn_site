import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/help_topics.dart';
import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/empty_state.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/orders/models/shipping_details.dart';
import '../../../domain/profile/models/account.dart';
import '../../catalog/widgets/suggested_products.dart';
import '../../orders/bloc/orders_cubit.dart';
import '../../orders/widgets/order_history_list.dart';
import '../../saved/bloc/saved_cubit.dart';
import '../bloc/profile_cubit.dart';

/// Account summary, order history, addresses, notifications and help.
class ProfileView extends StatefulWidget {
  /// Creates the view.
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Set<String> _help = const <String>{};

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final ProfileState profile = context.watch<ProfileCubit>().state;
    final OrdersState orders = context.watch<OrdersCubit>().state;
    final int savedCount = context.select((SavedCubit c) => c.state.ids.length);
    final Account? account = profile.account;

    if (!profile.loaded) return const Center(child: CairnSpinner());
    if (account == null) {
      return EmptyState(
        icon: Icons.person_outline,
        title: 'You are signed out',
        body: 'Sign in to see your orders, saved addresses and settings.',
        action: 'Sign in',
        onAction: context.read<ProfileCubit>().signIn,
        below: const SuggestedProducts(title: 'While you are here'),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        const ScreenTitle('Profile'),
        const SizedBox(height: 16),
        Row(
          spacing: 12,
          children: <Widget>[
            CairnAvatar(
              size: CairnAvatarSize.lg,
              fallback: Text(account.initials),
              semanticLabel: account.name,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    account.name,
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.base),
                      weight: CairnTypography.semibold,
                    ),
                  ),
                  Text(
                    account.email,
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.xs),
                      color: theme.mutedForeground,
                    ),
                  ),
                  Text(
                    'Member since ${account.memberSince}',
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.xs),
                      color: theme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CairnStats(
          children: <Widget>[
            CairnStat(
              title: const Text('Orders'),
              value: Text('${orders.orders.length}'),
            ),
            CairnStat(title: const Text('Saved'), value: Text('$savedCount')),
            CairnStat(
              title: const Text('Reviews'),
              value: Text('${account.reviewCount}'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionHeader(
          'Order history',
          trailing: orders.orders.isEmpty
              ? null
              : CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text('${orders.orders.length}'),
                ),
        ),
        const SizedBox(height: 12),
        if (orders.orders.isEmpty)
          _Quiet(
            message: 'No orders yet. Your first one will show up here.',
            action: 'Start shopping',
            onAction: () =>
                context.read<ShopNavigationCubit>().selectTab(ShopTab.shop),
          )
        else
          OrderHistoryList(
            orders: orders.orders,
            onOpen: context.read<ShopNavigationCubit>().openOrder,
          ),
        const SizedBox(height: 24),
        const SectionHeader('Saved addresses'),
        const SizedBox(height: 12),
        if (orders.addresses.isEmpty)
          const _Quiet(
            message: 'Addresses you ship to are saved here after checkout.',
          )
        else
          CairnList(
            bordered: true,
            children: <Widget>[
              for (final ShippingDetails a in orders.addresses)
                CairnListItem(
                  leading: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: theme.mutedForeground,
                  ),
                  title: Text(a.address),
                  subtitle: Text('${a.fullName} · ${a.city} ${a.postalCode}'),
                ),
            ],
          ),
        const SizedBox(height: 24),
        const SectionHeader('Notifications'),
        const SizedBox(height: 12),
        CairnList(
          bordered: true,
          children: <Widget>[
            CairnListItem(
              title: const Text('Order updates'),
              subtitle: const Text('Shipping and delivery alerts'),
              trailing: CairnSwitch(
                value: profile.preferences.orderUpdates,
                onChanged: context.read<ProfileCubit>().setOrderUpdates,
                semanticLabel: 'Order updates',
              ),
            ),
            CairnListItem(
              title: const Text('Offers'),
              subtitle: const Text('Sales and new arrivals'),
              trailing: CairnSwitch(
                value: profile.preferences.offers,
                onChanged: context.read<ProfileCubit>().setOffers,
                semanticLabel: 'Offers',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader('Help'),
        const SizedBox(height: 4),
        CairnAccordion(
          expanded: _help,
          onChanged: (Set<String> next) => setState(() => _help = next),
          items: <CairnAccordionItem>[
            for (final HelpTopic t in HelpTopics.values)
              CairnAccordionItem(
                value: t.id,
                title: Text(t.question),
                content: Text(
                  t.answer,
                  style: shopText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    color: theme.mutedForeground,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        CairnButton(
          expand: true,
          variant: CairnButtonVariant.outline,
          onPressed: context.read<ProfileCubit>().signOut,
          leading: const Icon(Icons.logout, size: 16),
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet({required this.message, this.action, this.onAction});

  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: <Widget>[
            Text(
              message,
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.sm),
                color: theme.mutedForeground,
              ),
            ),
            if (action != null)
              CairnButton(
                size: CairnButtonSize.sm,
                variant: CairnButtonVariant.outline,
                onPressed: onAction,
                child: Text(action!),
              ),
          ],
        ),
      ),
    );
  }
}
