import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/load_status.dart';
import '../../../domain/profile/models/profile.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../profile/widgets/profile_avatar.dart';

/// The signed-in person at the top of the home screen: avatar, name, email and a
/// chevron that opens Edit profile.
class ProfileCard extends StatelessWidget {
  /// Creates the card.
  const ProfileCard({super.key, required this.onTap, this.selected = false});

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Whether Edit profile is the open page (the tablet list).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final ProfileState state = context.watch<ProfileCubit>().state;
    final Profile? profile = state.profile;
    if (profile == null) {
      return state.status == LoadStatus.failure
          ? const SizedBox.shrink()
          : const CairnSkeleton(height: 72);
    }
    return Semantics(
      button: true,
      selected: selected,
      label: 'Edit profile. ${profile.name}, ${profile.email}',
      onTap: onTap,
      excludeSemantics: true,
      child: CairnList(
        bordered: true,
        children: <Widget>[
          CairnListItem(
            selected: selected,
            onTap: onTap,
            leading: ProfileAvatar(
              initials: profile.initials,
              presetId: profile.avatarId,
              size: 48,
            ),
            title: Text(
              profile.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              profile.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: CairnIcon(
              CairnIconData.chevronRight,
              color: theme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
