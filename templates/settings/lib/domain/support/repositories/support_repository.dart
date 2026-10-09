import '../../shared/models/action_result.dart';
import '../models/support_request.dart';

/// How the app reaches its support team.
abstract interface class SupportRepository {
  /// Sends [request]. The result's message is the ticket reference.
  Future<ActionResult> submit(SupportRequest request);
}
