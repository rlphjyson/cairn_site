import '../../../common/constants/content_sections.dart';
import '../../../common/utils/json.dart';
import 'app_content_json.dart';

/// Reads the page's content, one section at a time, as decoded JSON.
///
/// This is the single seam between the page and its copy. The in-memory
/// implementation below serves the demo content from `app_content_json.dart`;
/// to use a CMS or your own backend, implement this interface, return the same
/// shapes for the same [ContentSections] keys, and pass it to
/// `AppLandingApp(contentDataSource: ...)`.
abstract interface class AppContentDataSource {
  /// The JSON for [section], one of the [ContentSections] keys.
  Future<JsonMap> fetchSection(String section);
}

/// The demo content: an invented habit coach called Ember.
class InMemoryAppContentDataSource implements AppContentDataSource {
  /// Creates the data source.
  const InMemoryAppContentDataSource();

  @override
  Future<JsonMap> fetchSection(String section) async {
    final JsonMap? json = appContentJson[section];
    if (json == null) {
      throw ArgumentError.value(section, 'section', 'No content for section');
    }
    return json;
  }
}
