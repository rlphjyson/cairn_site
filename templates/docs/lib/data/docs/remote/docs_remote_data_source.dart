import 'content/docs_manifest.dart';
import 'content/v1_pages.dart';
import 'content/v2_guides_pages.dart';
import 'content/v2_reference_pages.dart';
import 'content/v2_start_pages.dart';

/// Where the raw documentation comes from.
///
/// It returns plain decoded JSON (maps and lists), exactly what
/// `jsonDecode(response.body)` would give, so the domain's `DocsMapper` is the
/// same whether the content ships in the app, comes from a CMS, or is converted
/// from Markdown files. Replace [InMemoryDocsRemoteDataSource] to change where
/// content is loaded from; nothing else changes.
abstract interface class DocsRemoteDataSource {
  /// The version list: `{"versions": [...]}`.
  Future<Map<String, dynamic>> fetchManifest();

  /// One version's content: `{"sidebar": [...], "pages": [...]}`.
  Future<Map<String, dynamic>> fetchSite(String versionId);
}

/// The content that ships with the template, as Dart literals.
///
/// **This is the place to start editing.** The sidebar trees live in
/// `content/docs_manifest.dart`; each page is a map under `content/`. Delete
/// the Acme SDK pages and write your own, or swap this class out entirely.
class InMemoryDocsRemoteDataSource implements DocsRemoteDataSource {
  /// Creates the data source. [latency] simulates a network round trip.
  const InMemoryDocsRemoteDataSource({
    this.latency = const Duration(milliseconds: 120),
  });

  /// How long each call takes.
  final Duration latency;

  @override
  Future<Map<String, dynamic>> fetchManifest() async {
    await Future<void>.delayed(latency);
    return docsManifest;
  }

  @override
  Future<Map<String, dynamic>> fetchSite(String versionId) async {
    await Future<void>.delayed(latency);
    return switch (versionId) {
      'v2.0' => <String, dynamic>{
        'sidebar': v2Sidebar,
        'pages': <Map<String, dynamic>>[
          ...v2StartPages,
          ...v2GuidesPages,
          ...v2ReferencePages,
        ],
      },
      'v1.x' => <String, dynamic>{'sidebar': v1Sidebar, 'pages': v1Pages},
      _ => throw ArgumentError.value(versionId, 'versionId', 'Unknown version'),
    };
  }
}
