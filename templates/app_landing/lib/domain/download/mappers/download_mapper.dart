import '../../../common/utils/json.dart';
import '../models/download_content.dart';

/// Maps the get-the-app JSON.
DownloadContent mapDownload(JsonMap json) => DownloadContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  formTitle: json.string('formTitle'),
  placeholder: json.string('placeholder'),
  buttonLabel: json.string('buttonLabel'),
  privacyNote: json.string('privacyNote'),
  successTitle: json.string('successTitle'),
  successMessage: json.string('successMessage'),
  storesHeading: json.string('storesHeading'),
  qr: _qr(json.object('qr')),
);

QrCardContent _qr(JsonMap j) => QrCardContent(
  title: j.string('title'),
  caption: j.string('caption'),
  badge: j.string('badge'),
  demoNote: j.string('demoNote'),
  payload: j.string('payload'),
);
