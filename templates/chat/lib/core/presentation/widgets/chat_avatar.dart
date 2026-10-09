import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/initials.dart';
import '../../../domain/contacts/models/presence.dart';
import '../chat_images.dart';
import 'presence_dot.dart';

/// A person's or group's avatar: their photo, or their initials, or a group
/// glyph, with an optional presence dot on the corner.
class ChatAvatar extends StatelessWidget {
  /// Creates an avatar for [name].
  const ChatAvatar({
    super.key,
    required this.name,
    this.avatar,
    this.size = CairnAvatarSize.lg,
    this.presence,
    this.group = false,
  });

  /// The person's or group's name: used for the initials and as the accessible
  /// name.
  final String name;

  /// An asset path or URL; `null` shows the initials.
  final String? avatar;

  /// 24, 32 or 40 logical pixels.
  final CairnAvatarSize size;

  /// Shows a dot for [Presence.online], [Presence.away] and
  /// [Presence.doNotDisturb]; nothing for offline or `null`.
  final Presence? presence;

  /// Shows a group glyph instead of initials when there is no photo.
  final bool group;

  @override
  Widget build(BuildContext context) {
    final Widget face = CairnAvatar(
      image: avatar == null ? null : chatImage(avatar!),
      fallback: group
          ? const Icon(Icons.group_outlined, size: 18)
          : Text(initialsOf(name)),
      size: size,
      semanticLabel: name,
    );
    final Presence? p = presence;
    if (p == null || p == Presence.offline) return face;
    return CairnIndicator(
      placement: CairnIndicatorPlacement.bottomEnd,
      offset: size == CairnAvatarSize.sm
          ? const Offset(-1, -1)
          : const Offset(-3, -3),
      indicator: PresenceDot(p, size: size == CairnAvatarSize.sm ? 8 : 10),
      child: face,
    );
  }
}
