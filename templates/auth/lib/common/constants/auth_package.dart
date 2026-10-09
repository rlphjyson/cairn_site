/// The package that would bundle the template's images.
///
/// The template is typographic and ships no images, so nothing reads this
/// today. It exists so that, if you add a hero or a brand image under
/// `assets/images/`, you resolve it with `package: AuthPackage.name` and it
/// keeps working both as a package and as copied source. If you copy `lib/`
/// and `assets/` straight into your own app, set [name] to `null` and declare
/// the assets in your own `pubspec.yaml`.
abstract final class AuthPackage {
  /// The asset package. When the assets belong to the host app instead, change
  /// the value to `null`.
  // ignore: unnecessary_nullable_for_final_variable_declarations
  static const String? name = 'cairn_template_auth';
}
