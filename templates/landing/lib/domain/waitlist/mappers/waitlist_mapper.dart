import '../../../common/utils/json.dart';
import '../models/join_outcome.dart';
import '../models/waitlist_content.dart';

/// Maps the waitlist copy JSON.
WaitlistContent mapWaitlist(JsonMap json) => WaitlistContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  placeholder: json.string('placeholder'),
  buttonLabel: json.string('buttonLabel'),
  privacyNote: json.string('privacyNote'),
  successTitle: json.string('successTitle'),
  successMessage: json.string('successMessage'),
);

/// Maps the service response, `{"position": 1284}`.
WaitlistReceipt mapReceipt(JsonMap json) =>
    WaitlistReceipt(position: json.number('position').round());
