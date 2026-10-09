import '../../../common/utils/json.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/hero_content.dart';

/// Maps the hero JSON.
HeroContent mapHero(JsonMap json) => HeroContent(
  announcement: mapLink(json.object('announcement')),
  headline: json.string('headline'),
  subcopy: json.string('subcopy'),
  primaryCta: mapLink(json.object('primaryCta')),
  secondaryCta: mapLink(json.object('secondaryCta')),
  proof: _proof(json.object('proof')),
  visual: _visual(json.object('visual')),
);

SocialProof _proof(JsonMap j) => SocialProof(
  text: j.string('text'),
  rating: j.number('rating'),
  ratingLabel: j.string('ratingLabel'),
  avatars: j.strings('avatars'),
);

ProductVisual _visual(JsonMap j) => ProductVisual(
  url: j.string('url'),
  project: j.string('project'),
  status: j.string('status'),
  sidebar: <SidebarEntry>[
    for (final JsonMap e in j.objects('sidebar'))
      SidebarEntry(
        icon: e.string('icon'),
        label: e.string('label'),
        active: e.flag('active'),
      ),
  ],
  metrics: <VisualMetric>[
    for (final JsonMap e in j.objects('metrics'))
      VisualMetric(
        label: e.string('label'),
        value: e.string('value'),
        delta: e.string('delta'),
      ),
  ],
  chartTitle: j.string('chartTitle'),
  barLabels: j.strings('barLabels'),
  bars: <double>[
    for (final Object? v in j['bars']! as List<Object?>)
      (v! as num).toDouble().clamp(0.0, 1.0),
  ],
  tasksTitle: j.string('tasksTitle'),
  tasks: <VisualTask>[
    for (final JsonMap e in j.objects('tasks'))
      VisualTask(
        title: e.string('title'),
        owner: e.string('owner'),
        status: e.string('status'),
        progress: e.number('progress').clamp(0.0, 1.0),
      ),
  ],
  team: j.strings('team'),
);
