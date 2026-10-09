import '../../../common/utils/json.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/footer_content.dart';

/// Maps the footer JSON.
FooterContent mapFooter(JsonMap json) => FooterContent(
  description: json.string('description'),
  columns: <FooterColumn>[
    for (final JsonMap e in json.objects('columns'))
      FooterColumn(
        title: e.string('title'),
        links: mapLinks(e.objects('links')),
      ),
  ],
  social: <SocialLink>[
    for (final JsonMap e in json.objects('social'))
      SocialLink(
        label: e.string('label'),
        icon: e.string('icon'),
        href: e.string('href'),
      ),
  ],
  copyright: json.string('copyright'),
  legal: mapLinks(json.objects('legal')),
);
