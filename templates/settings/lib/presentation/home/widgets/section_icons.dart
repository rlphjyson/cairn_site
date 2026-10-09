import 'package:flutter/material.dart' show IconData, Icons;

import '../../../domain/settings/models/settings_section.dart';

/// The glyph beside each section on the home screen.
IconData sectionIcon(SettingsSection section) => switch (section) {
  SettingsSection.profile => Icons.person_outline,
  SettingsSection.appearance => Icons.palette_outlined,
  SettingsSection.notifications => Icons.notifications_none,
  SettingsSection.privacy => Icons.lock_outline,
  SettingsSection.language => Icons.language,
  SettingsSection.storage => Icons.sd_storage_outlined,
  SettingsSection.help => Icons.help_outline,
  SettingsSection.about => Icons.info_outline,
  SettingsSection.danger => Icons.warning_amber_outlined,
};
