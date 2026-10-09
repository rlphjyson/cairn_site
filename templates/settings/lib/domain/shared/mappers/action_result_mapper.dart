import '../models/action_result.dart';

/// Reads the `{ "ok": true }` / `{ "ok": false, "error": "..." }` envelope the
/// data source answers writes with.
abstract final class ActionResultMapper {
  /// The result in [json].
  static ActionResult fromJson(Map<String, Object?> json) {
    if (json['ok'] == true) {
      return ActionResult.success(json['message'] as String?);
    }
    return ActionResult.failure(
      json['error'] as String? ?? 'Something went wrong. Please try again.',
    );
  }
}
