import 'package:flutter/material.dart';

/// Resolves the icon names used in the content JSON to glyphs.
///
/// Content never holds `IconData`; it holds a short name such as `bolt`. Add a
/// name here to make it available to every section. Unknown names fall back to
/// a dot, so a typo is visible but never crashes.
abstract final class AppLandingIcons {
  static const Map<String, IconData> _byName = <String, IconData>{
    'apple': Icons.phone_iphone,
    'arrow_forward': Icons.arrow_forward,
    'award': Icons.workspace_premium_outlined,
    'bar_chart': Icons.bar_chart_rounded,
    'bell': Icons.notifications_none,
    'calendar': Icons.calendar_month_outlined,
    'check': Icons.check,
    'download': Icons.download_rounded,
    'edit': Icons.edit_outlined,
    'fire': Icons.local_fire_department_outlined,
    'flag': Icons.flag_outlined,
    'heart': Icons.favorite_border,
    'home': Icons.home_outlined,
    'insights': Icons.insights,
    'lock': Icons.lock_outline,
    'mail': Icons.mail_outline,
    'menu': Icons.menu,
    'moon': Icons.dark_mode_outlined,
    'phone': Icons.smartphone,
    'play': Icons.play_arrow_rounded,
    'public': Icons.public,
    'rss': Icons.rss_feed,
    'settings': Icons.settings_outlined,
    'shield': Icons.verified_user_outlined,
    'star': Icons.star_outline_rounded,
    'sun': Icons.wb_sunny_outlined,
    'support': Icons.support_agent,
    'tune': Icons.tune,
    'user': Icons.person_outline,
    'water': Icons.water_drop_outlined,
    'book': Icons.menu_book_outlined,
    'run': Icons.directions_run,
    'sleep': Icons.bedtime_outlined,
    'task': Icons.task_alt,
  };

  /// The glyph for [name], or a dot when the name is unknown.
  static IconData byName(String name) => _byName[name] ?? Icons.circle;
}
