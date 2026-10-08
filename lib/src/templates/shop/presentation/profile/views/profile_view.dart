import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../domain/profile/models/account.dart';
import '../../saved/bloc/saved_cubit.dart';
import '../bloc/profile_cubit.dart';

/// Account summary and notification settings.
class ProfileView extends StatelessWidget {
  /// Creates the view.
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final ProfileState profile = context.watch<ProfileCubit>().state;
    final int savedCount = context.select((SavedCubit c) => c.state.ids.length);
    final Account? account = profile.account;
    if (account == null) return const Center(child: CairnSpinner());

    Widget chevron() =>
        Icon(Icons.chevron_right, size: 18, color: theme.mutedForeground);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: <Widget>[
        const ScreenTitle('Profile'),
        const SizedBox(height: 16),
        Row(
          spacing: 12,
          children: <Widget>[
            CairnAvatar(
              size: CairnAvatarSize.lg,
              fallback: Text(account.initials),
            ),
            Column(
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
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        CairnStats(
          children: <Widget>[
            CairnStat(
              title: const Text('Orders'),
              value: Text('${account.orderCount}'),
            ),
            CairnStat(title: const Text('Saved'), value: Text('$savedCount')),
            CairnStat(
              title: const Text('Reviews'),
              value: Text('${account.reviewCount}'),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            CairnListItem(
              title: const Text('Addresses'),
              trailing: chevron(),
              onTap: () {},
            ),
            CairnListItem(
              title: const Text('Payment methods'),
              trailing: chevron(),
              onTap: () {},
            ),
            CairnListItem(
              title: const Text('Help and support'),
              trailing: chevron(),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
