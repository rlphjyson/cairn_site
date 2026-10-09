import 'package:get_it/get_it.dart';

import '../../../data/chat/remote/chat_remote_data_source.dart';
import '../../../data/contacts/repositories/contact_repository_impl.dart';
import '../../../data/conversations/repositories/conversation_repository_impl.dart';
import '../../../data/messages/repositories/message_repository_impl.dart';
import '../../../domain/contacts/repositories/contact_repository.dart';
import '../../../domain/contacts/use_cases/block_contact.dart';
import '../../../domain/contacts/use_cases/get_contacts.dart';
import '../../../domain/contacts/use_cases/get_current_user.dart';
import '../../../domain/contacts/use_cases/group_contacts.dart';
import '../../../domain/contacts/use_cases/search_contacts.dart';
import '../../../domain/contacts/use_cases/update_profile.dart';
import '../../../domain/contacts/use_cases/watch_presence.dart';
import '../../../domain/conversations/repositories/conversation_repository.dart';
import '../../../domain/conversations/use_cases/create_group.dart';
import '../../../domain/conversations/use_cases/delete_conversation.dart';
import '../../../domain/conversations/use_cases/format_relative_time.dart';
import '../../../domain/conversations/use_cases/get_conversation.dart';
import '../../../domain/conversations/use_cases/get_conversations.dart';
import '../../../domain/conversations/use_cases/leave_group.dart';
import '../../../domain/conversations/use_cases/open_direct_conversation.dart';
import '../../../domain/conversations/use_cases/search_conversations.dart';
import '../../../domain/conversations/use_cases/update_conversation.dart';
import '../../../domain/conversations/use_cases/watch_conversation_changes.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/repositories/message_repository.dart';
import '../../../domain/messages/use_cases/delete_message.dart';
import '../../../domain/messages/use_cases/get_messages.dart';
import '../../../domain/messages/use_cases/get_shared_media.dart';
import '../../../domain/messages/use_cases/group_messages.dart';
import '../../../domain/messages/use_cases/mark_read.dart';
import '../../../domain/messages/use_cases/react_to_message.dart';
import '../../../domain/messages/use_cases/send_message.dart';
import '../../../domain/messages/use_cases/watch_conversation.dart';
import '../../../presentation/contacts/bloc/contacts_cubit.dart';
import '../../../presentation/conversations/bloc/conversations_cubit.dart';
import '../../../presentation/info/bloc/info_cubit.dart';
import '../../../presentation/info/view_models/info_view_model.dart';
import '../../../presentation/new_chat/bloc/new_chat_cubit.dart';
import '../../../presentation/new_chat/view_models/new_chat_view_model.dart';
import '../../../presentation/profile/bloc/profile_cubit.dart';
import '../../../presentation/thread/bloc/thread_cubit.dart';
import '../../../presentation/thread/view_models/thread_view_model.dart';
import '../../presentation/navigation/chat_navigation_cubit.dart';
import '../chat_session.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit rather than generated, so the template needs no
/// `build_runner` step. The scopes follow one rule:
///
/// * the data source, repositories: lazy singletons, one per session;
/// * use cases: factories (they are stateless and free to build);
/// * **session cubits** (navigation, conversations, contacts, profile): lazy
///   singletons, provided to the tree once and never closed by a view model;
/// * **screen cubits** (thread, new chat, info): created and closed by their
///   view model, which is a factory.
///
/// [dataSource] is the backend. When [ownsDataSource] is true (the demo's
/// in-memory one) the container disposes it with the app; a data source the
/// host passes in stays the host's to dispose. [onMessageSent] is called for
/// every message the backend accepted.
GetIt createChatLocator({
  required ChatRemoteDataSource dataSource,
  required ChatSession session,
  bool ownsDataSource = false,
  void Function(Message message)? onMessageSent,
}) {
  final GetIt g = GetIt.asNewInstance();

  g.registerSingleton<ChatSession>(session);

  // The backend. Replace it with one that calls your service.
  g.registerSingleton<ChatRemoteDataSource>(
    dataSource,
    dispose: ownsDataSource ? (ChatRemoteDataSource d) => d.dispose() : null,
  );

  // Repositories.
  g
    ..registerLazySingleton<ContactRepository>(() => ContactRepositoryImpl(g()))
    ..registerLazySingleton<ConversationRepository>(
      () => ConversationRepositoryImpl(g()),
    )
    ..registerLazySingleton<MessageRepository>(
      () => MessageRepositoryImpl(g()),
    );

  // Use cases.
  g
    ..registerFactory<GetContacts>(() => GetContacts(g(), session.userId))
    ..registerFactory<GroupContacts>(GroupContacts.new)
    ..registerFactory<SearchContacts>(SearchContacts.new)
    ..registerFactory<GetCurrentUser>(() => GetCurrentUser(g()))
    ..registerFactory<UpdateProfile>(() => UpdateProfile(g()))
    ..registerFactory<BlockContact>(() => BlockContact(g()))
    ..registerFactory<WatchPresence>(() => WatchPresence(g()))
    ..registerFactory<GetConversations>(() => GetConversations(g()))
    ..registerFactory<GetConversation>(() => GetConversation(g()))
    ..registerFactory<SearchConversations>(SearchConversations.new)
    ..registerFactory<UpdateConversation>(() => UpdateConversation(g()))
    ..registerFactory<DeleteConversation>(() => DeleteConversation(g()))
    ..registerFactory<OpenDirectConversation>(() => OpenDirectConversation(g()))
    ..registerFactory<CreateGroup>(() => CreateGroup(g()))
    ..registerFactory<LeaveGroup>(() => LeaveGroup(g()))
    ..registerFactory<WatchConversationChanges>(
      () => WatchConversationChanges(g()),
    )
    ..registerFactory<FormatRelativeTime>(FormatRelativeTime.new)
    ..registerFactory<GetMessages>(() => GetMessages(g()))
    ..registerFactory<SendMessage>(
      () => SendMessage(g(), onSent: onMessageSent),
    )
    ..registerFactory<MarkRead>(() => MarkRead(g()))
    ..registerFactory<GroupMessages>(GroupMessages.new)
    ..registerFactory<ReactToMessage>(() => ReactToMessage(g()))
    ..registerFactory<DeleteMessage>(() => DeleteMessage(g()))
    ..registerFactory<WatchConversation>(() => WatchConversation(g()))
    ..registerFactory<GetSharedMedia>(() => GetSharedMedia(g()));

  // Session cubits.
  g
    ..registerLazySingleton<ChatNavigationCubit>(
      ChatNavigationCubit.new,
      dispose: (ChatNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<ConversationsCubit>(
      () => ConversationsCubit(g(), g(), g(), g(), g()),
      dispose: (ConversationsCubit c) => c.close(),
    )
    ..registerLazySingleton<ContactsCubit>(
      () => ContactsCubit(g(), g(), g(), g(), g(), g(), session.userId),
      dispose: (ContactsCubit c) => c.close(),
    )
    ..registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(g(), g(), g()),
      dispose: (ProfileCubit c) => c.close(),
    );

  // Screen view models; each creates and owns its own cubit.
  g
    ..registerFactory<ThreadViewModel>(
      () => ThreadViewModel(
        ThreadCubit(session, g(), g(), g(), g(), g(), g(), g(), g()),
      ),
    )
    ..registerFactory<NewChatViewModel>(
      () => NewChatViewModel(NewChatCubit(g(), g(), g(), g(), g())),
    )
    ..registerFactory<InfoViewModel>(
      () => InfoViewModel(InfoCubit(g(), g(), g(), g(), g(), g(), g(), g())),
    );

  return g;
}
