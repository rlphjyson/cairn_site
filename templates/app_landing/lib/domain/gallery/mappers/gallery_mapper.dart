import '../../../common/utils/json.dart';
import '../../shared/mappers/app_screen_mapper.dart';
import '../models/gallery_content.dart';

/// Maps the gallery JSON.
GalleryContent mapGallery(JsonMap json) => GalleryContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  slides: <GallerySlide>[
    for (final JsonMap e in json.objects('slides'))
      GallerySlide(
        title: e.string('title'),
        caption: e.string('caption'),
        screen: mapScreen(e.object('screen')),
      ),
  ],
);
