import '../../../common/utils/json.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/site_info.dart';

/// Maps the site JSON.
SiteInfo mapSiteInfo(JsonMap json) => SiteInfo(
  brandName: json.string('brandName'),
  brandIcon: json.string('brandIcon'),
  tagline: json.string('tagline'),
  navLinks: mapLinks(json.objects('navLinks')),
  cta: mapLink(json.object('cta')),
  appStore: _store(json.object('appStore')),
  googlePlay: _store(json.object('googlePlay')),
);

StoreLink _store(JsonMap j) => StoreLink(
  caption: j.string('caption'),
  label: j.string('label'),
  icon: j.string('icon'),
  href: j.string('href'),
);
