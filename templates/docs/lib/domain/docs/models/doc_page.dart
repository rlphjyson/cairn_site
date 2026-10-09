import 'package:equatable/equatable.dart';

import 'doc_block.dart';

/// One documentation page.
class DocPage extends Equatable {
  /// Creates a page.
  const DocPage({
    required this.slug,
    required this.title,
    required this.description,
    required this.updated,
    required this.blocks,
  });

  /// The unique, URL-safe id within a version.
  final String slug;

  /// The page title.
  final String title;

  /// A one-line summary shown under the title and used by search.
  final String description;

  /// When the page last changed.
  final DateTime updated;

  /// The content, top to bottom.
  final List<DocBlock> blocks;

  @override
  List<Object?> get props => <Object?>[
    slug,
    title,
    description,
    updated,
    blocks,
  ];
}
