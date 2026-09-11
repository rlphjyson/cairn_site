import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../widgets/surfaces.dart';

/// Shown for any unrecognised path.
class NotFoundPage extends StatelessWidget {
  /// Creates the page.
  const NotFoundPage({super.key, required this.location});

  /// The path that did not match a route.
  final String location;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return PageContainer(
      maxWidth: 640,
      padding: const EdgeInsets.symmetric(
        horizontal: CairnSpacing.s5,
        vertical: CairnSpacing.s24,
      ),
      child: CairnEmpty(
        media: Text(
          '404',
          style: theme
              .textStyle(CairnTypography.xl4)
              .copyWith(
                color: theme.mutedForeground,
                fontWeight: CairnTypography.semibold,
              ),
        ),
        title: 'No such page',
        description: '$location does not match any route on this site.',
        actions: <Widget>[
          CairnButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('Go home'),
          ),
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => context.go(Routes.components),
            child: const Text('Browse components'),
          ),
        ],
      ),
    );
  }
}
