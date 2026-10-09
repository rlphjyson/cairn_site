import '../../../common/utils/json.dart';
import '../../shared/mappers/app_screen_mapper.dart';
import '../models/features_content.dart';

/// Maps the features JSON.
FeaturesContent mapFeatures(JsonMap json) => FeaturesContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  items: <Feature>[
    for (final JsonMap e in json.objects('items'))
      Feature(
        id: e.string('id'),
        tabLabel: e.string('tabLabel'),
        icon: e.string('icon'),
        title: e.string('title'),
        body: e.string('body'),
        bullets: e.strings('bullets'),
        screen: mapScreen(e.object('screen')),
      ),
  ],
);
