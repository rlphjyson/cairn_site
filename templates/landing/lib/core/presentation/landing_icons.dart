import 'package:flutter/material.dart';

/// Resolves the icon names used in the content JSON to glyphs.
///
/// Content never holds `IconData`; it holds a short name such as `bolt`. Add a
/// name here to make it available to every section. Unknown names fall back to
/// a dot, so a typo is visible but never crashes.
abstract final class LandingIcons {
  static const Map<String, IconData> _byName = <String, IconData>{
    'anchor': Icons.anchor,
    'arrow_forward': Icons.arrow_forward,
    'bar_chart': Icons.bar_chart_rounded,
    'bolt': Icons.bolt,
    'check': Icons.check,
    'code': Icons.code,
    'dashboard': Icons.dashboard_outlined,
    'explore': Icons.explore_outlined,
    'extension': Icons.extension_outlined,
    'folder': Icons.folder_outlined,
    'forest': Icons.forest_outlined,
    'groups': Icons.groups_outlined,
    'hub': Icons.hub_outlined,
    'insights': Icons.insights,
    'layers': Icons.layers_outlined,
    'lock': Icons.lock_outline,
    'mail': Icons.mail_outline,
    'menu': Icons.menu,
    'notifications': Icons.notifications_none,
    'public': Icons.public,
    'rocket': Icons.rocket_launch_outlined,
    'roadmap': Icons.map_outlined,
    'rss': Icons.rss_feed,
    'shield': Icons.verified_user_outlined,
    'speed': Icons.speed,
    'support': Icons.support_agent,
    'sync': Icons.sync,
    'timeline': Icons.timeline,
    'tune': Icons.tune,
    'waves': Icons.waves,
    'wb_sunny': Icons.wb_sunny_outlined,
  };

  /// The glyph for [name], or a dot when the name is unknown.
  static IconData byName(String name) => _byName[name] ?? Icons.circle;
}
