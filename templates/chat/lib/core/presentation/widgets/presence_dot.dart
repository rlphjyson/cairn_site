import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/contacts/models/presence.dart';

/// The tone a presence is drawn in: green, amber, red or grey.
CairnTone presenceTone(Presence presence) => switch (presence) {
  Presence.online => CairnTone.success,
  Presence.away => CairnTone.warning,
  Presence.doNotDisturb => CairnTone.destructive,
  Presence.offline => CairnTone.neutral,
};

/// A small coloured dot for a person's availability, ringed in the page colour
/// so it reads on top of an avatar.
class PresenceDot extends StatelessWidget {
  /// Creates a dot.
  const PresenceDot(this.presence, {super.key, this.size = 10});

  /// Whose availability.
  final Presence presence;

  /// The dot's diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.background, width: 2),
      ),
      child: CairnStatus(
        tone: presenceTone(presence),
        size: size,
        semanticLabel: presence.label,
      ),
    );
  }
}
