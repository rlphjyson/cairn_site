/// Outbound links the template renders.
abstract final class DocsLinks {
  /// The repository the documentation sources live in. A page's "Edit this
  /// page" link is [editBase] followed by the page's source path.
  static const String editBase =
      'https://github.com/acme/acme-sdk/edit/main/docs/';

  /// Builds the "Edit this page" URL for [versionId] and [slug].
  static String editUrl(String versionId, String slug) =>
      '$editBase$versionId/$slug.md';

  /// Where the "Report an issue" footer link points.
  static const String issues = 'https://github.com/acme/acme-sdk/issues';
}
