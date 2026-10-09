import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../../core/presentation/onboarding_text.dart';
import '../../../core/presentation/widgets/touch_target.dart';
import '../../../domain/permissions/models/permission_kind.dart';
import '../../../domain/permissions/models/permission_request.dart';
import '../../../domain/permissions/models/permission_status.dart';

/// One permission: what it is for, a button to allow it, and what happened.
///
/// The three outcomes are shown differently:
///
/// * not asked: an "Allow" button;
/// * allowed: a quiet confirmation;
/// * declined: an explanation of how to enable it later, with "Try again" while
///   the system will still ask and "Open settings" once it will not.
class PermissionCard extends StatelessWidget {
  /// Creates a card.
  const PermissionCard({
    super.key,
    required this.request,
    required this.status,
    required this.busy,
    required this.onAllow,
    required this.onOpenSettings,
  });

  /// The copy.
  final PermissionRequest request;

  /// Where the permission stands.
  final PermissionStatus status;

  /// Whether the system prompt is open.
  final bool busy;

  /// Asks for the permission.
  final VoidCallback onAllow;

  /// Opens the system settings.
  final VoidCallback onOpenSettings;

  static IconData _icon(PermissionKind kind) => switch (kind) {
    PermissionKind.notifications => Icons.notifications_none,
    PermissionKind.location => Icons.place_outlined,
    PermissionKind.camera => Icons.photo_camera_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String name = request.title.toLowerCase();
    return CairnCard(
      gap: 12,
      children: <Widget>[
        CairnCardContent(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.muted,
                  borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                ),
                child: ExcludeSemantics(
                  child: Icon(
                    _icon(request.kind),
                    size: 20,
                    color: theme.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    request.title,
                    style: onboardingText(
                      theme,
                      theme.textStyle(CairnTypography.base),
                      weight: CairnTypography.semibold,
                    ),
                  ),
                ),
              ),
              if (status.isGranted)
                const CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  leading: CairnIcon(CairnIconData.check),
                  label: Text('Allowed'),
                ),
            ],
          ),
        ),
        CairnCardContent(
          child: Text(
            request.benefit,
            style: onboardingText(
              theme,
              theme.textStyle(CairnTypography.sm),
              color: theme.mutedForeground,
              height: 1.45,
            ),
          ),
        ),
        CairnCardContent(
          child: Semantics(liveRegion: true, child: _action(context, name)),
        ),
      ],
    );
  }

  Widget _action(BuildContext context, String name) {
    if (status.isGranted) {
      return Text(
        'You can change this any time in settings.',
        style: onboardingText(
          CairnTheme.of(context),
          CairnTheme.of(context).textStyle(CairnTypography.xs),
          color: CairnTheme.of(context).mutedForeground,
        ),
      );
    }
    final bool declined = status.isDenied;
    final bool again = status == PermissionStatus.denied;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (declined) ...<Widget>[
          CairnAlert(
            icon: const CairnIcon(CairnIconData.info),
            title: const Text('Not allowed'),
            description: Text(request.deniedHelp),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: <Widget>[
            if (!declined || again)
              Flexible(
                child: TouchTarget(
                  onTap: busy ? null : onAllow,
                  child: CairnButton(
                    variant: declined
                        ? CairnButtonVariant.outline
                        : CairnButtonVariant.primary,
                    onPressed: busy ? null : onAllow,
                    semanticLabel: declined
                        ? 'Try allowing $name again'
                        : 'Allow $name',
                    child: Text(
                      busy
                          ? 'Asking...'
                          : declined
                          ? 'Try again'
                          : 'Allow $name',
                    ),
                  ),
                ),
              ),
            if (declined) ...<Widget>[
              if (again) const SizedBox(width: 8),
              Flexible(
                child: TouchTarget(
                  onTap: onOpenSettings,
                  child: CairnButton(
                    variant: CairnButtonVariant.ghost,
                    onPressed: onOpenSettings,
                    semanticLabel: 'Open settings to allow $name',
                    child: const Text('Open settings'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
