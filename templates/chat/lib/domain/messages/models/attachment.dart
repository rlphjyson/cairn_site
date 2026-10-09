import 'package:equatable/equatable.dart';

/// What kind of thing is attached.
enum AttachmentKind {
  /// A photo.
  image('image'),

  /// Any file.
  file('file'),

  /// A place on a map.
  location('location');

  const AttachmentKind(this.wire);

  /// The value used in JSON.
  final String wire;

  /// Reads the JSON value, treating anything unknown as [file].
  static AttachmentKind fromWire(Object? value) =>
      AttachmentKind.values.firstWhere(
        (AttachmentKind k) => k.wire == value,
        orElse: () => AttachmentKind.file,
      );
}

/// Something sent with (or instead of) text.
class Attachment extends Equatable {
  /// Creates an attachment.
  const Attachment({
    required this.kind,
    this.asset,
    this.url,
    this.name,
    this.sizeBytes,
    this.aspectRatio = 4 / 3,
  });

  /// Photo, file or location.
  final AttachmentKind kind;

  /// An asset path (`assets/images/...`); used by the demo.
  final String? asset;

  /// An `http(s)` URL; what a real backend returns.
  final String? url;

  /// The file name, or the place name for a location.
  final String? name;

  /// The size of a file, in bytes.
  final int? sizeBytes;

  /// Width divided by height of an image, so the bubble can reserve its space
  /// before the picture loads.
  final double aspectRatio;

  @override
  List<Object?> get props => <Object?>[
    kind,
    asset,
    url,
    name,
    sizeBytes,
    aspectRatio,
  ];
}
