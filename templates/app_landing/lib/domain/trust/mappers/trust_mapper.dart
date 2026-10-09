import '../../../common/utils/json.dart';
import '../models/trust_content.dart';

/// Maps the trust strip JSON.
TrustContent mapTrust(JsonMap json) => TrustContent(
  heading: json.string('heading'),
  press: <PressMention>[
    for (final JsonMap e in json.objects('press'))
      PressMention(
        name: e.string('name'),
        style: _style(e.string('style')),
        quote: e.string('quote'),
      ),
  ],
  awards: <Award>[
    for (final JsonMap e in json.objects('awards'))
      Award(
        title: e.string('title'),
        issuer: e.string('issuer'),
        icon: e.string('icon'),
      ),
  ],
);

WordmarkStyle _style(String name) {
  for (final WordmarkStyle s in WordmarkStyle.values) {
    if (s.name == name) return s;
  }
  throw FormatException('Unknown wordmark style "$name"');
}
