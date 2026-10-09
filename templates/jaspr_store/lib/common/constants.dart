/// Cross-cutting constants. Nothing brand-specific lives here; see
/// `core/config/brand.dart` for that.
library;

const int kProductsPerPage = 8;
const int kMaxLineQuantity = 10;
const int kMaxCartLines = 30;
const int kRelatedProductCount = 4;

/// Query parameters that never change page content. They are stripped from
/// canonical URLs and from internal redirects.
const Set<String> kTrackingParams = {
  'gclid',
  'fbclid',
  'msclkid',
  'dclid',
  'yclid',
  'mc_cid',
  'mc_eid',
  'ref',
  'ref_src',
  'igshid',
  'srsltid',
  'theme',
};

bool isTrackingParam(String name) => name.startsWith('utm_') || kTrackingParams.contains(name);
