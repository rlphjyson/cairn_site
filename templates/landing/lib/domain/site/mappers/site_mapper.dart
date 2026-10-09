import '../../../common/utils/json.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/site_info.dart';

/// Maps the site JSON.
SiteInfo mapSiteInfo(JsonMap json) => SiteInfo(
  brandName: json.string('brandName'),
  brandIcon: json.string('brandIcon'),
  tagline: json.string('tagline'),
  navLinks: mapLinks(json.objects('navLinks')),
  signIn: mapLink(json.object('signIn')),
  cta: mapLink(json.object('cta')),
);
