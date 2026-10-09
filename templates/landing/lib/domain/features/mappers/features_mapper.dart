import '../../../common/utils/json.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/features_content.dart';

/// Maps the features JSON.
FeaturesContent mapFeatures(JsonMap json) => FeaturesContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  items: <FeatureItem>[
    for (final JsonMap e in json.objects('items'))
      FeatureItem(
        icon: e.string('icon'),
        title: e.string('title'),
        description: e.string('description'),
        tag: e.maybeString('tag'),
      ),
  ],
  spotlights: <Spotlight>[
    for (final JsonMap e in json.objects('spotlights'))
      Spotlight(
        eyebrow: e.string('eyebrow'),
        title: e.string('title'),
        description: e.string('description'),
        bullets: e.strings('bullets'),
        image: e.string('image'),
        imageAlt: e.string('imageAlt'),
        cta: e['cta'] == null ? null : mapLink(e.object('cta')),
      ),
  ],
);
