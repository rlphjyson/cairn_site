/// Everything the template asks its backend for, as decoded JSON.
///
/// This is the one integration point of the data layer. Every method returns
/// what a REST client would hand you after `jsonDecode`, and the mappers in
/// `domain/<feature>/mappers/` turn it into models. To use a real backend,
/// implement this interface (or extend `InMemorySettingsDataSource` and
/// override only the calls you replace) and pass it to
/// `SettingsApp(settingsDataSource: ...)`.
///
/// Writes answer with the envelope `{ "ok": true }` or
/// `{ "ok": false, "error": "A sentence for the person." }`.
abstract interface class SettingsDataSource {
  /// `{ "schema": 1, "values": { "<setting id>": <value> } }`. May be empty.
  Future<Map<String, Object?>> loadSettings();

  /// Persists the same shape `loadSettings` returns.
  Future<void> saveSettings(Map<String, Object?> json);

  /// `{ "name", "version", "build", "licences": [{ "name", "licence",
  /// "summary" }] }`.
  Future<Map<String, Object?>> loadAppInfo();

  /// `{ "name", "username", "email", "bio", "avatar" }`.
  Future<Map<String, Object?>> loadProfile();

  /// Saves a profile in the shape `loadProfile` returns and answers with what
  /// was stored.
  Future<Map<String, Object?>> saveProfile(Map<String, Object?> json);

  /// `{ "available": true }`.
  Future<Map<String, Object?>> checkUsername(String username);

  /// `{ "sessions": [{ "id", "device", "location", "lastActive", "current" }] }`.
  Future<Map<String, Object?>> loadSessions();

  /// Signs one device out. Answers with the write envelope.
  Future<Map<String, Object?>> revokeSession(String sessionId);

  /// Signs every other device out. Answers with the write envelope.
  Future<Map<String, Object?>> revokeOtherSessions();

  /// Changes the password. Answers with the write envelope.
  Future<Map<String, Object?>> changePassword({
    required String current,
    required String next,
  });

  /// `{ "secret": "JBSWY3DPEHPK3PXP" }`.
  Future<Map<String, Object?>> beginTwoFactor();

  /// Confirms two-factor setup. Answers with the write envelope.
  Future<Map<String, Object?>> verifyTwoFactor(String code);

  /// Turns two-factor off. Answers with the write envelope.
  Future<Map<String, Object?>> disableTwoFactor();

  /// `{ "id": "exp_1", "requestedAt": "2026-10-09T08:30:00Z" }`.
  Future<Map<String, Object?>> requestExport();

  /// `{ "blocked": [{ "id", "name", "username" }] }`.
  Future<Map<String, Object?>> loadBlockedUsers();

  /// Unblocks someone. Answers with the write envelope.
  Future<Map<String, Object?>> unblockUser(String userId);

  /// Hides the account. Answers with the write envelope.
  Future<Map<String, Object?>> deactivateAccount();

  /// Deletes the account for good. Answers with the write envelope.
  Future<Map<String, Object?>> deleteAccount();

  /// `{ "capacity": 5368709120, "categories": [{ "id", "label", "bytes" }] }`.
  Future<Map<String, Object?>> loadStorage();

  /// `{ "ok": true, "reclaimed": 92274688 }`.
  Future<Map<String, Object?>> clearCache();

  /// Sends a support message `{ "subject", "message" }`. Answers with the write
  /// envelope; `message` is the ticket reference.
  Future<Map<String, Object?>> submitSupportRequest(Map<String, Object?> json);
}
