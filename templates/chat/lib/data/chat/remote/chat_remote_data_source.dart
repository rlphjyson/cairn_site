/// The template's only door to a backend.
///
/// Every method answers with decoded JSON (`Map<String, Object?>`), exactly as a
/// REST client would after `jsonDecode`. The mappers in `domain/*/mappers/` are
/// the only code that knows the wire format, so replacing this interface's
/// implementation is all it takes to connect a real service. The in-memory
/// implementation, [InMemoryChatDataSource], is what the demo runs on.
///
/// `jsonDecode` returns `Map<String, dynamic>`; convert with
/// `Map<String, Object?>.from(...)` (or `cast`) before returning it.
///
/// JSON shapes are documented on `ContactMapper`, `ConversationMapper` and
/// `MessageMapper`, and in `doc/index.html`.
abstract interface class ChatRemoteDataSource {
  // Profile and contacts ----------------------------------------------------

  /// `GET /me`: the signed-in user as a contact.
  Future<Map<String, Object?>> fetchCurrentUser();

  /// `GET /contacts`.
  Future<List<Map<String, Object?>>> fetchContacts();

  /// `PATCH /me` with any of `name`, `about`, `presence`; returns the profile.
  Future<Map<String, Object?>> patchProfile(Map<String, Object?> changes);

  /// `POST /contacts/{id}/block`.
  Future<void> blockContact(String contactId);

  // Conversations -----------------------------------------------------------

  /// `GET /conversations`: each entry carries its `lastMessage`, `unread`
  /// count and `updatedAt`.
  Future<List<Map<String, Object?>>> fetchConversations();

  /// `GET /conversations/{id}`; `null` when it does not exist.
  Future<Map<String, Object?>?> fetchConversation(String id);

  /// `POST /conversations` with `{ "type": "direct", "peerId": ... }`; returns
  /// the existing conversation when there is one.
  Future<Map<String, Object?>> openDirectConversation(String contactId);

  /// `POST /conversations` with `{ "type": "group", "title": ...,
  /// "memberIds": [...] }`.
  Future<Map<String, Object?>> createGroupConversation({
    required String name,
    required List<String> memberIds,
  });

  /// `PATCH /conversations/{id}` with any of `pinned`, `muted`, `archived`,
  /// `markedUnread`.
  Future<Map<String, Object?>> patchConversation(
    String id,
    Map<String, Object?> changes,
  );

  /// `DELETE /conversations/{id}`.
  Future<void> deleteConversation(String id);

  /// `POST /conversations/{id}/leave`.
  Future<void> leaveConversation(String id);

  // Messages ----------------------------------------------------------------

  /// `GET /conversations/{id}/messages?before={beforeId}&limit={limit}`:
  /// `{ "messages": [...oldest first...], "hasMore": bool }`.
  Future<Map<String, Object?>> fetchMessages(
    String conversationId, {
    String? beforeId,
    required int limit,
  });

  /// `POST /conversations/{id}/messages` with `conversationId`, `text`,
  /// `replyTo` and `attachment`; returns the stored message.
  Future<Map<String, Object?>> postMessage(Map<String, Object?> body);

  /// `POST /conversations/{id}/read`.
  Future<void> postRead(String conversationId);

  /// `PUT /messages/{id}/reactions/{emoji}`, toggling; returns the message.
  Future<Map<String, Object?>> postReaction(
    String conversationId,
    String messageId,
    String emoji,
  );

  /// `DELETE /messages/{id}` for you only.
  Future<void> deleteMessage(String conversationId, String messageId);

  /// `GET /conversations/{id}/media`.
  Future<List<Map<String, Object?>>> fetchMedia(String conversationId);

  // Real time ---------------------------------------------------------------

  /// Frames pushed by the server (WebSocket or server-sent events), decoded to
  /// JSON. Must be a broadcast stream. See `ChatEventMapper` for the frame
  /// types.
  Stream<Map<String, Object?>> events();

  /// Releases sockets and timers. Called when the template is unmounted, but
  /// only for a data source the template created itself.
  void dispose();
}
