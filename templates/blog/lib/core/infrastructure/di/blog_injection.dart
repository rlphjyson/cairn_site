import 'package:get_it/get_it.dart';

import '../../../data/authors/remote/authors_remote_data_source.dart';
import '../../../data/authors/repositories/author_repository_impl.dart';
import '../../../data/newsletter/remote/newsletter_remote_data_source.dart';
import '../../../data/newsletter/repositories/newsletter_repository_impl.dart';
import '../../../data/posts/remote/posts_remote_data_source.dart';
import '../../../data/posts/repositories/post_repository_impl.dart';
import '../../../domain/authors/repositories/author_repository.dart';
import '../../../domain/authors/use_cases/get_author_profiles.dart';
import '../../../domain/newsletter/repositories/newsletter_repository.dart';
import '../../../domain/newsletter/use_cases/subscribe_to_newsletter.dart';
import '../../../domain/newsletter/use_cases/validate_email.dart';
import '../../../domain/posts/repositories/post_repository.dart';
import '../../../domain/posts/use_cases/get_categories.dart';
import '../../../domain/posts/use_cases/get_featured_post.dart';
import '../../../domain/posts/use_cases/get_post.dart';
import '../../../domain/posts/use_cases/get_posts.dart';
import '../../../domain/posts/use_cases/get_related_posts.dart';
import '../../../domain/posts/use_cases/query_posts.dart';
import '../../../presentation/authors/bloc/authors_cubit.dart';
import '../../../presentation/authors/view_models/authors_view_model.dart';
import '../../../presentation/feed/bloc/posts_feed_cubit.dart';
import '../../../presentation/newsletter/bloc/newsletter_cubit.dart';
import '../../../presentation/newsletter/view_models/newsletter_view_model.dart';
import '../../../presentation/post/bloc/post_detail_cubit.dart';
import '../../../presentation/post/view_models/post_detail_view_model.dart';
import '../../presentation/navigation/blog_navigation_cubit.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit, so there is no `build_runner` step. Scopes:
///
/// * data sources and repositories: lazy singletons;
/// * use cases: factories (stateless and free to build);
/// * **session cubits** (navigation, the posts feed): lazy singletons,
///   provided once and never closed by a view model;
/// * **screen cubits** (article, authors, each sign-up form): created and
///   closed by their view model.
///
/// To use a real backend, pass your own data sources, or edit the three
/// `InMemory...` registrations below.
GetIt createBlogLocator({
  PostsRemoteDataSource? postsDataSource,
  AuthorsRemoteDataSource? authorsDataSource,
  NewsletterRemoteDataSource? newsletterDataSource,
}) {
  final GetIt g = GetIt.asNewInstance();

  // The one place to swap in a CMS, REST API or Firebase.
  g
    ..registerLazySingleton<PostsRemoteDataSource>(
      () => postsDataSource ?? const InMemoryPostsRemoteDataSource(),
    )
    ..registerLazySingleton<AuthorsRemoteDataSource>(
      () => authorsDataSource ?? const InMemoryAuthorsRemoteDataSource(),
    )
    ..registerLazySingleton<NewsletterRemoteDataSource>(
      () => newsletterDataSource ?? InMemoryNewsletterRemoteDataSource(),
    );

  g
    ..registerLazySingleton<AuthorRepository>(() => AuthorRepositoryImpl(g()))
    ..registerLazySingleton<PostRepository>(() => PostRepositoryImpl(g(), g()))
    ..registerLazySingleton<NewsletterRepository>(
      () => NewsletterRepositoryImpl(g()),
    );

  g
    ..registerFactory<GetPosts>(() => GetPosts(g()))
    ..registerFactory<GetPost>(() => GetPost(g()))
    ..registerFactory<GetRelatedPosts>(() => GetRelatedPosts(g()))
    ..registerFactory<GetCategories>(GetCategories.new)
    ..registerFactory<GetFeaturedPost>(GetFeaturedPost.new)
    ..registerFactory<QueryPosts>(QueryPosts.new)
    ..registerFactory<GetAuthorProfiles>(() => GetAuthorProfiles(g(), g()))
    ..registerFactory<ValidateEmail>(ValidateEmail.new)
    ..registerFactory<SubscribeToNewsletter>(
      () => SubscribeToNewsletter(g(), g()),
    );

  g
    ..registerLazySingleton<BlogNavigationCubit>(
      BlogNavigationCubit.new,
      dispose: (BlogNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<PostsFeedCubit>(
      () => PostsFeedCubit(g(), g(), g(), g()),
      dispose: (PostsFeedCubit c) => c.close(),
    );

  g
    ..registerFactory<PostDetailViewModel>(
      () => PostDetailViewModel(PostDetailCubit(g(), g())),
    )
    ..registerFactory<AuthorsViewModel>(
      () => AuthorsViewModel(AuthorsCubit(g())),
    )
    ..registerFactory<NewsletterViewModel>(
      () => NewsletterViewModel(NewsletterCubit(g(), g())),
    );

  return g;
}
