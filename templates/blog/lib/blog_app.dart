import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/blog_injection.dart';
import 'core/presentation/view_model.dart';
import 'data/authors/remote/authors_remote_data_source.dart';
import 'data/newsletter/remote/newsletter_remote_data_source.dart';
import 'data/posts/remote/posts_remote_data_source.dart';
import 'presentation/shell/blog_providers.dart';
import 'presentation/shell/blog_shell.dart';

/// A blog built only from `cairn_ui`, Cairn tokens and Material glyphs.
///
/// A sticky navbar with search, a featured post, a filterable and paginated
/// grid of posts, an article page rendered from content blocks, an About page
/// and a newsletter form. It fills
/// whatever space its parent gives it and adapts to that width, not the
/// screen's: one column under 640 logical pixels, two under 1024, then three.
///
/// Organised as clean architecture, by layer and then by feature; see the
/// README next to this file. The content comes from in-memory data sources;
/// pass your own to read from a CMS or API.
class BlogApp extends StatefulWidget {
  /// Creates the app.
  ///
  /// [postsDataSource], [authorsDataSource] and [newsletterDataSource]
  /// replace the in-memory stand-ins.
  const BlogApp({
    super.key,
    this.postsDataSource,
    this.authorsDataSource,
    this.newsletterDataSource,
  });

  /// Where posts come from. Defaults to the bundled seed content.
  final PostsRemoteDataSource? postsDataSource;

  /// Where authors come from. Defaults to the bundled seed content.
  final AuthorsRemoteDataSource? authorsDataSource;

  /// Where sign-ups go. Defaults to a fake service that always succeeds.
  final NewsletterRemoteDataSource? newsletterDataSource;

  @override
  State<BlogApp> createState() => _BlogAppState();
}

class _BlogAppState extends State<BlogApp> {
  late final GetIt _locator = createBlogLocator(
    postsDataSource: widget.postsDataSource,
    authorsDataSource: widget.authorsDataSource,
    newsletterDataSource: widget.newsletterDataSource,
  );

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlogScope(
    locator: _locator,
    child: BlogProviders(
      locator: _locator,
      // The template brings its own toaster, so "Copy link" and the
      // newsletter form can toast in any host app.
      child: const CairnToaster(
        child: Material(type: MaterialType.transparency, child: BlogShell()),
      ),
    ),
  );
}
