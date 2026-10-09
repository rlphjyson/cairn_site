import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../contacts/bloc/contacts_cubit.dart';
import '../conversations/bloc/conversations_cubit.dart';
import '../profile/bloc/profile_cubit.dart';

/// Exposes the session-scoped cubits to every screen.
///
/// These are lazy singletons owned by the container, so they are provided with
/// `BlocProvider.value` (which never closes them). Views read them with
/// `context.read` and never touch the container.
class ChatProviders extends StatelessWidget {
  /// Creates the providers.
  const ChatProviders({super.key, required this.locator, required this.child});

  /// The container that owns the cubits.
  final GetIt locator;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ChatNavigationCubit>.value(
        value: locator<ChatNavigationCubit>(),
      ),
      BlocProvider<ConversationsCubit>.value(
        value: locator<ConversationsCubit>(),
      ),
      BlocProvider<ContactsCubit>.value(value: locator<ContactsCubit>()),
      BlocProvider<ProfileCubit>.value(value: locator<ProfileCubit>()),
    ],
    child: child,
  );
}
