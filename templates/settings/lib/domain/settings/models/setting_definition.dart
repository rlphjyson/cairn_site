import 'package:equatable/equatable.dart';

import 'settings_link.dart';
import 'settings_section.dart';

/// What a setting is, which decides how it is stored and drawn.
enum SettingKind {
  /// On or off. Stored as a `bool`.
  toggle,

  /// One of several options. Stored as the option's `String` value.
  choice,

  /// One of a few steps on a scale. Stored as the step's `int` index.
  slider,

  /// Something that happens when tapped (open a screen, clear a cache). Has no
  /// stored value.
  action,

  /// Opens something outside the app. Has no stored value.
  link,
}

/// How a [ChoiceSetting] is drawn.
enum ChoiceStyle {
  /// A select that opens a menu. Best for long lists.
  select,

  /// A radio group. Best for a handful of mutually exclusive options.
  radio,
}

/// One option of a [ChoiceSetting].
class ChoiceOption extends Equatable {
  /// Creates an option.
  const ChoiceOption(this.value, this.label, [this.description]);

  /// What is stored.
  final String value;

  /// What the person reads.
  final String label;

  /// An optional second line.
  final String? description;

  @override
  List<Object?> get props => <Object?>[value, label, description];
}

/// A setting, described as data.
///
/// The registry holds these, and both the search and the screens read them:
/// the home screen searches their titles and keywords, and each category screen
/// draws its own definitions. Adding a setting is adding a definition.
sealed class SettingDefinition extends Equatable {
  /// Creates a definition.
  const SettingDefinition({
    required this.id,
    required this.section,
    required this.title,
    this.description,
    this.keywords = const <String>[],
    this.group,
  });

  /// A unique, stable id such as `notifications.messages`. It is also the key
  /// the value is persisted under.
  final String id;

  /// The category it belongs to.
  final SettingsSection section;

  /// The label.
  final String title;

  /// One line that explains it.
  final String? description;

  /// Extra words the search matches, such as synonyms.
  final List<String> keywords;

  /// A heading that groups consecutive settings inside a category.
  final String? group;

  /// What kind of setting this is.
  SettingKind get kind;

  /// The value a fresh install starts with, or `null` for an action or link.
  Object? get defaultValue;

  /// Whether [value] is a valid stored value for this setting.
  bool accepts(Object? value);

  /// Everything the subclasses share, for [Equatable].
  List<Object?> get baseProps => <Object?>[
    id,
    section,
    title,
    description,
    keywords,
    group,
  ];
}

/// An on/off setting.
final class ToggleSetting extends SettingDefinition {
  /// Creates a toggle.
  const ToggleSetting({
    required super.id,
    required super.section,
    required super.title,
    super.description,
    super.keywords,
    super.group,
    this.initial = false,
  });

  /// The value a fresh install starts with.
  final bool initial;

  @override
  SettingKind get kind => SettingKind.toggle;

  @override
  Object? get defaultValue => initial;

  @override
  bool accepts(Object? value) => value is bool;

  @override
  List<Object?> get props => <Object?>[...baseProps, initial];
}

/// A setting with a fixed set of options.
final class ChoiceSetting extends SettingDefinition {
  /// Creates a choice.
  const ChoiceSetting({
    required super.id,
    required super.section,
    required super.title,
    required this.options,
    required this.initial,
    super.description,
    super.keywords,
    super.group,
    this.style = ChoiceStyle.select,
  });

  /// The options, in the order they are shown.
  final List<ChoiceOption> options;

  /// The value of the option a fresh install starts with.
  final String initial;

  /// How the choice is drawn.
  final ChoiceStyle style;

  @override
  SettingKind get kind => SettingKind.choice;

  @override
  Object? get defaultValue => initial;

  @override
  bool accepts(Object? value) =>
      value is String && options.any((ChoiceOption o) => o.value == value);

  /// The label of the option whose value is [value], or [value] itself.
  String labelOf(String value) {
    for (final ChoiceOption o in options) {
      if (o.value == value) return o.label;
    }
    return value;
  }

  @override
  List<Object?> get props => <Object?>[...baseProps, options, initial, style];
}

/// A setting on a short scale of whole steps.
final class SliderSetting extends SettingDefinition {
  /// Creates a slider. [labels] names every step, so it has `max - min + 1`
  /// entries.
  const SliderSetting({
    required super.id,
    required super.section,
    required super.title,
    required this.labels,
    required this.initial,
    super.description,
    super.keywords,
    super.group,
  });

  /// The name of each step, from the lowest.
  final List<String> labels;

  /// The step a fresh install starts on.
  final int initial;

  /// The lowest step.
  int get min => 0;

  /// The highest step.
  int get max => labels.length - 1;

  @override
  SettingKind get kind => SettingKind.slider;

  @override
  Object? get defaultValue => initial;

  @override
  bool accepts(Object? value) => value is int && value >= min && value <= max;

  @override
  List<Object?> get props => <Object?>[...baseProps, labels, initial];
}

/// A row that does something when tapped.
final class ActionSetting extends SettingDefinition {
  /// Creates an action.
  const ActionSetting({
    required super.id,
    required super.section,
    required super.title,
    super.description,
    super.keywords,
    super.group,
    this.destructive = false,
  });

  /// Whether the action is drawn as dangerous.
  final bool destructive;

  @override
  SettingKind get kind => SettingKind.action;

  @override
  Object? get defaultValue => null;

  @override
  bool accepts(Object? value) => false;

  @override
  List<Object?> get props => <Object?>[...baseProps, destructive];
}

/// A row that opens something outside the app.
final class LinkSetting extends SettingDefinition {
  /// Creates a link.
  const LinkSetting({
    required super.id,
    required super.section,
    required super.title,
    required this.link,
    super.description,
    super.keywords,
    super.group,
  });

  /// Which link the host is asked to open.
  final SettingsLink link;

  @override
  SettingKind get kind => SettingKind.link;

  @override
  Object? get defaultValue => null;

  @override
  bool accepts(Object? value) => false;

  @override
  List<Object?> get props => <Object?>[...baseProps, link];
}
