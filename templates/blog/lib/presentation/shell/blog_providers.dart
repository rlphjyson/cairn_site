import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../feed/bloc/posts_feed_cubit.dart';

/// Exposes the session-scoped cubits to every page.
///
/// Lazy singletons owned by the container, so they are provided with
/// `BlocProvider.value`, which never closes them.
class BlogProviders extends StatelessWidget {
  /// Creates the providers.
  const BlogProviders({super.key, required this.locator, required this.child});

  /// The container that owns the cubits.
  final GetIt locator;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<BlogNavigationCubit>.value(
        value: locator<BlogNavigationCubit>(),
      ),
      BlocProvider<PostsFeedCubit>.value(value: locator<PostsFeedCubit>()),
    ],
    child: child,
  );
}
