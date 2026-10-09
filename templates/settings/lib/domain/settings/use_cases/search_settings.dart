import 'package:equatable/equatable.dart';

import '../models/setting_definition.dart';
import '../models/settings_section.dart';
import '../registry/settings_registry.dart';

/// The settings in one section that matched a search.
class SettingsSearchGroup extends Equatable {
  /// Creates a group.
  const SettingsSearchGroup(this.section, this.hits);

  /// The section the hits belong to.
  final SettingsSection section;

  /// The matching settings, best first.
  final List<SettingDefinition> hits;

  @override
  List<Object?> get props => <Object?>[section, hits];
}

/// Searches the registry by keyword.
///
/// The query is split on spaces and every word must match something: the
/// title (best), a keyword, the description or the section's name. Matching is
/// case-insensitive and by substring. Results are grouped by section, in the
/// order sections are declared, with the best match first inside each group.
class SearchSettings {
  /// Creates the use case.
  const SearchSettings(this._registry);

  final SettingsRegistry _registry;

  /// The groups that match [query]. An empty or blank query matches nothing.
  List<SettingsSearchGroup> call(String query) {
    final List<String> words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const <SettingsSearchGroup>[];

    final Map<SettingsSection, List<({SettingDefinition d, int score, int at})>>
    found =
        <SettingsSection, List<({SettingDefinition d, int score, int at})>>{};
    for (int i = 0; i < _registry.definitions.length; i++) {
      final SettingDefinition d = _registry.definitions[i];
      final int score = _score(d, words);
      if (score > 0) {
        (found[d.section] ??= <({SettingDefinition d, int score, int at})>[])
            .add((d: d, score: score, at: i));
      }
    }

    return <SettingsSearchGroup>[
      for (final SettingsSection s in SettingsSection.values)
        if (found[s] != null)
          SettingsSearchGroup(
            s,
            (found[s]!..sort((a, b) {
                  final int byScore = b.score.compareTo(a.score);
                  return byScore != 0 ? byScore : a.at.compareTo(b.at);
                }))
                .map((({SettingDefinition d, int score, int at}) e) => e.d)
                .toList(),
          ),
    ];
  }

  /// The total score, or 0 when any word matches nothing.
  int _score(SettingDefinition d, List<String> words) {
    final String title = d.title.toLowerCase();
    final String description = (d.description ?? '').toLowerCase();
    final String section = d.section.title.toLowerCase();
    int total = 0;
    for (final String w in words) {
      int best = 0;
      if (title.startsWith(w) || title.contains(' $w')) {
        best = 4;
      } else if (title.contains(w)) {
        best = 3;
      } else if (d.keywords.any((String k) => k.toLowerCase().contains(w))) {
        best = 2;
      } else if (description.contains(w) || section.contains(w)) {
        best = 1;
      }
      if (best == 0) return 0;
      total += best;
    }
    return total;
  }
}
