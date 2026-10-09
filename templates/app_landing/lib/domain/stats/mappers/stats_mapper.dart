import '../../../common/utils/json.dart';
import '../models/stats_content.dart';

/// Maps the stats JSON.
StatsContent mapStats(JsonMap json) => StatsContent(
  title: json.string('title'),
  caption: json.string('caption'),
  photo: json.string('photo'),
  photoLabel: json.string('photoLabel'),
  stats: <StatItem>[
    for (final JsonMap e in json.objects('stats'))
      StatItem(
        label: e.string('label'),
        value: e.string('value'),
        description: e.string('description'),
      ),
  ],
);
