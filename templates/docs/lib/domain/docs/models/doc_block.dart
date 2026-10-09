import 'package:equatable/equatable.dart';

/// One piece of page content. The renderer switches over this sealed type, so
/// adding a block means adding a subtype here, a case in the mapper and a case
/// in `BlockView`; the compiler flags the ones you forget.
sealed class DocBlock extends Equatable {
  const DocBlock();
}

/// An `h2` or `h3` with an anchor [id].
class HeadingBlock extends DocBlock {
  /// Creates a heading.
  const HeadingBlock({
    required this.level,
    required this.id,
    required this.text,
  });

  /// 2 or 3.
  final int level;

  /// The anchor other pages and the search palette link to.
  final String id;

  /// The visible text.
  final String text;

  @override
  List<Object?> get props => <Object?>[level, id, text];
}

/// A paragraph of inline markup (`**bold**`, `code`, `[text](target)`).
class ParagraphBlock extends DocBlock {
  /// Creates a paragraph.
  const ParagraphBlock(this.text);

  /// The markup.
  final String text;

  @override
  List<Object?> get props => <Object?>[text];
}

/// The languages the highlighter knows.
enum CodeLanguage {
  /// Dart source.
  dart('dart'),

  /// YAML, such as a `pubspec.yaml`.
  yaml('yaml'),

  /// Shell commands.
  bash('bash'),

  /// JSON.
  json('json'),

  /// Unhighlighted text.
  text('text');

  const CodeLanguage(this.label);

  /// The label shown in the block header.
  final String label;

  /// Resolves a JSON `language` value, falling back to [text].
  static CodeLanguage parse(String? value) => switch (value?.toLowerCase()) {
    'dart' => dart,
    'yaml' || 'yml' => yaml,
    'bash' || 'sh' || 'shell' || 'console' => bash,
    'json' => json,
    _ => text,
  };
}

/// A fenced code sample with a copy button.
class CodeBlock extends DocBlock {
  /// Creates a code block.
  const CodeBlock({required this.language, required this.code, this.title});

  /// The grammar to highlight with.
  final CodeLanguage language;

  /// The source. Surrounding blank lines are trimmed when rendered.
  final String code;

  /// A file name shown instead of the language label, such as `pubspec.yaml`.
  final String? title;

  @override
  List<Object?> get props => <Object?>[language, code, title];
}

/// The tone of a [CalloutBlock].
enum CalloutKind {
  /// Neutral background information.
  info('Note'),

  /// A suggestion that saves time.
  tip('Tip'),

  /// Something that can go wrong.
  warning('Warning');

  const CalloutKind(this.defaultTitle);

  /// The title used when the JSON gives none.
  final String defaultTitle;

  /// Resolves a JSON `kind`, falling back to [info].
  static CalloutKind parse(String? value) => switch (value?.toLowerCase()) {
    'tip' => tip,
    'warning' || 'danger' || 'caution' => warning,
    _ => info,
  };
}

/// A highlighted note, tip or warning.
class CalloutBlock extends DocBlock {
  /// Creates a callout.
  const CalloutBlock({required this.kind, required this.text, this.title});

  /// The tone.
  final CalloutKind kind;

  /// The body markup.
  final String text;

  /// Overrides [CalloutKind.defaultTitle].
  final String? title;

  @override
  List<Object?> get props => <Object?>[kind, text, title];
}

/// One tab of a [TabsBlock].
class TabItem extends Equatable {
  /// Creates a tab.
  const TabItem({required this.label, required this.blocks});

  /// The tab label.
  final String label;

  /// What the tab shows.
  final List<DocBlock> blocks;

  @override
  List<Object?> get props => <Object?>[label, blocks];
}

/// Alternative content in tabs: package-manager commands, one tab per OS.
class TabsBlock extends DocBlock {
  /// Creates a tabs block.
  const TabsBlock(this.tabs);

  /// The tabs, in order. The first is selected initially.
  final List<TabItem> tabs;

  @override
  List<Object?> get props => <Object?>[tabs];
}

/// One step of a [StepsBlock].
class StepItem extends Equatable {
  /// Creates a step.
  const StepItem({required this.title, required this.blocks});

  /// The step heading.
  final String title;

  /// The step body.
  final List<DocBlock> blocks;

  @override
  List<Object?> get props => <Object?>[title, blocks];
}

/// A numbered procedure.
class StepsBlock extends DocBlock {
  /// Creates a steps block.
  const StepsBlock(this.steps);

  /// The steps, in order.
  final List<StepItem> steps;

  @override
  List<Object?> get props => <Object?>[steps];
}

/// A table of inline markup cells.
class TableBlock extends DocBlock {
  /// Creates a table.
  const TableBlock({required this.headers, required this.rows});

  /// The column headings.
  final List<String> headers;

  /// The rows; each has one cell per header.
  final List<List<String>> rows;

  @override
  List<Object?> get props => <Object?>[headers, rows];
}

/// A bulleted or numbered list of inline markup items.
class ListBlock extends DocBlock {
  /// Creates a list.
  const ListBlock({required this.items, this.ordered = false});

  /// The items.
  final List<String> items;

  /// Whether the items are numbered.
  final bool ordered;

  @override
  List<Object?> get props => <Object?>[items, ordered];
}
