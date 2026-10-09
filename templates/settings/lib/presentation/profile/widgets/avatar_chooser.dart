import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../common/constants/avatar_presets.dart';
import '../../../core/presentation/widgets/focus_tap.dart';
import 'profile_avatar.dart';

/// A row of avatar presets to pick from. There is no camera or gallery: the
/// choices are the initials and a few gradients built from Cairn colours.
class AvatarChooser extends StatelessWidget {
  /// Creates the chooser.
  const AvatarChooser({
    super.key,
    required this.initials,
    required this.selectedId,
    required this.onChanged,
  });

  /// The letters drawn on every option.
  final String initials;

  /// The chosen preset id.
  final String selectedId;

  /// Called with the id of the tapped preset.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      container: true,
      label: 'Avatar',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (final ({String id, String label}) p in AvatarPresets.all)
            FocusTap(
              label: p.label,
              selected: p.id == selectedId,
              onTap: () => onChanged(p.id),
              builder: (BuildContext context, bool focused) => Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: p.id == selectedId || focused
                        ? theme.ring
                        : const Color(0x00000000),
                    width: 2,
                  ),
                  boxShadow: focused ? theme.focusRing : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    ProfileAvatar(initials: initials, presetId: p.id, size: 40),
                    if (p.id == selectedId)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.background),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10,
                            color: theme.primaryForeground,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
