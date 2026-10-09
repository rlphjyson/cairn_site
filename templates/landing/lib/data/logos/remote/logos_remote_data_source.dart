import '../../../common/utils/json.dart';

/// Reads the trusted-by strip as decoded JSON.
abstract interface class LogosRemoteDataSource {
  /// The strip.
  Future<JsonMap> fetchLogoCloud();
}

/// Six invented companies, each drawn as an icon and a wordmark in text. No
/// real brand logos are used. `style` is one of `bold`, `light`, `italic`,
/// `spaced`.
class InMemoryLogosRemoteDataSource implements LogosRemoteDataSource {
  /// Creates the data source.
  const InMemoryLogosRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'heading': 'Trusted by product teams at fast-moving companies',
    'logos': <Object?>[
      <String, Object?>{'name': 'Lumen', 'icon': 'wb_sunny', 'style': 'bold'},
      <String, Object?>{
        'name': 'Pinecrest',
        'icon': 'forest',
        'style': 'italic',
      },
      <String, Object?>{'name': 'Halcyon', 'icon': 'waves', 'style': 'light'},
      <String, Object?>{'name': 'Meridian', 'icon': 'public', 'style': 'bold'},
      <String, Object?>{
        'name': 'tidewater',
        'icon': 'anchor',
        'style': 'spaced',
      },
      <String, Object?>{
        'name': 'Overland',
        'icon': 'layers',
        'style': 'italic',
      },
    ],
  };

  @override
  Future<JsonMap> fetchLogoCloud() async => _json;
}
