import '../../../common/utils/json.dart';

/// Reads the pricing section as decoded JSON.
abstract interface class PricingRemoteDataSource {
  /// The pricing section.
  Future<JsonMap> fetchPricing();
}

/// The demo plans.
///
/// `monthlyPrice` is per unit per month when billed monthly. A plan without
/// one shows `priceLabel` instead ("Custom"). A price of `0` shows "Free".
/// `yearlyDiscountPercent` is taken off every paid plan when billed yearly.
class InMemoryPricingRemoteDataSource implements PricingRemoteDataSource {
  /// Creates the data source.
  const InMemoryPricingRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'eyebrow': 'Pricing',
    'title': 'Simple pricing that scales with your team',
    'subtitle':
        'Start free, upgrade when you are ready. Every paid plan includes a '
        '14-day trial, with no card required.',
    'currency': r'$',
    'yearlyDiscountPercent': 20,
    'monthlyLabel': 'Monthly',
    'yearlyLabel': 'Yearly',
    'plans': <Object?>[
      <String, Object?>{
        'id': 'starter',
        'name': 'Starter',
        'description': 'For individuals and small projects getting started.',
        'monthlyPrice': 0,
        'unit': 'forever',
        'cta': <String, Object?>{
          'label': 'Start for free',
          'href': '#waitlist',
        },
        'featuresHeading': 'Includes',
        'features': <Object?>[
          'Up to 3 projects',
          'Unlimited tasks',
          'Basic reporting',
          'Community support',
        ],
      },
      <String, Object?>{
        'id': 'team',
        'name': 'Team',
        'description': 'For growing teams that plan together every week.',
        'monthlyPrice': 12,
        'unit': 'per seat / month',
        'highlighted': true,
        'badge': 'Most popular',
        'cta': <String, Object?>{
          'label': 'Start free trial',
          'href': '#waitlist',
        },
        'featuresHeading': 'Everything in Starter, plus',
        'features': <Object?>[
          'Unlimited projects',
          'Roadmaps and dependencies',
          'Automations',
          'Workload view',
          'Priority email support',
        ],
      },
      <String, Object?>{
        'id': 'scale',
        'name': 'Scale',
        'description': 'For organisations that need control and insight.',
        'monthlyPrice': 29,
        'unit': 'per seat / month',
        'cta': <String, Object?>{
          'label': 'Start free trial',
          'href': '#waitlist',
        },
        'featuresHeading': 'Everything in Team, plus',
        'features': <Object?>[
          'Portfolio reporting',
          'Single sign-on and audit logs',
          'Granular permissions',
          'Dedicated success manager',
        ],
      },
    ],
    'compareNote':
        'Need custom security reviews or an annual contract? Talk to our team.',
    'compare': <String, Object?>{
      'label': 'Contact sales',
      'href': 'mailto:sales@kestrel.example',
    },
  };

  @override
  Future<JsonMap> fetchPricing() async => _json;
}
