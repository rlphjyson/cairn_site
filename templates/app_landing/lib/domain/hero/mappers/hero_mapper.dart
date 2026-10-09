import '../../../common/utils/json.dart';
import '../../shared/mappers/app_screen_mapper.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/hero_content.dart';

/// Maps the hero JSON.
HeroContent mapHero(JsonMap json) => HeroContent(
  badge: json.string('badge'),
  headline: json.string('headline'),
  subcopy: json.string('subcopy'),
  secondaryCta: mapLink(json.object('secondaryCta')),
  rating: json.number('rating'),
  ratingText: json.string('ratingText'),
  ratingLabel: json.string('ratingLabel'),
  avatars: json.strings('avatars'),
  frontScreen: mapScreen(json.object('frontScreen')),
  backScreen: mapScreen(json.object('backScreen')),
);
