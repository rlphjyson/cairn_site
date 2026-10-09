import '../../../common/utils/json.dart';
import '../models/logo_cloud.dart';

/// Maps the logo cloud JSON. An unknown `style` falls back to bold.
LogoCloud mapLogoCloud(JsonMap json) => LogoCloud(
  heading: json.string('heading'),
  logos: <CompanyLogo>[
    for (final JsonMap e in json.objects('logos'))
      CompanyLogo(
        name: e.string('name'),
        icon: e.string('icon'),
        style: WordmarkStyle.values.firstWhere(
          (WordmarkStyle s) => s.name == e.maybeString('style'),
          orElse: () => WordmarkStyle.bold,
        ),
      ),
  ],
);
