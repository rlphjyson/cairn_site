import 'package:equatable/equatable.dart';

/// An open-source package the app ships with, for the licences list.
class LicenceEntry extends Equatable {
  /// Creates an entry.
  const LicenceEntry({
    required this.name,
    required this.licence,
    this.summary = '',
  });

  /// The package name.
  final String name;

  /// The licence name, such as `MIT`.
  final String licence;

  /// A line about what it is for.
  final String summary;

  @override
  List<Object?> get props => <Object?>[name, licence, summary];
}

/// What the About and Help screens show about the app itself.
class AppInfo extends Equatable {
  /// Creates app info.
  const AppInfo({
    required this.name,
    required this.version,
    required this.build,
    this.licences = const <LicenceEntry>[],
  });

  /// The app's name.
  final String name;

  /// The marketing version, such as `2.4.1`.
  final String version;

  /// The build number, such as `240`.
  final String build;

  /// Third-party licences.
  final List<LicenceEntry> licences;

  /// `2.4.1 (240)`: what a support agent asks for.
  String get versionLabel => '$version ($build)';

  @override
  List<Object?> get props => <Object?>[name, version, build, licences];
}
