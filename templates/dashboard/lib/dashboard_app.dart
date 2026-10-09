import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/dashboard_injection.dart';
import 'core/presentation/view_model.dart';
import 'presentation/shell/dashboard_providers.dart';
import 'presentation/shell/dashboard_shell.dart';

/// An analytics dashboard, built only from `cairn_ui`, Cairn tokens and
/// fl_chart restyled through Cairn's chart theme.
///
/// A sidebar, a top bar with a period picker, KPI cards, revenue and traffic
/// charts and a sortable, searchable orders table, modelled on daisyUI's
/// dashboard templates. It fills whatever space its parent gives it and
/// collapses its sidebar below 760 logical pixels.
///
/// Organised as clean architecture, by layer and then by feature; see the
/// README next to this file.
class DashboardApp extends StatefulWidget {
  /// Creates the app.
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  late final GetIt _locator = createDashboardLocator();

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DashboardScope(
    locator: _locator,
    child: DashboardProviders(locator: _locator, child: const DashboardShell()),
  );
}
