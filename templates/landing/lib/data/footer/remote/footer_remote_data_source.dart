import '../../../common/utils/json.dart';

/// Reads the footer as decoded JSON.
abstract interface class FooterRemoteDataSource {
  /// The footer.
  Future<JsonMap> fetchFooter();
}

/// The demo footer: link columns, social icons and legal links.
///
/// Social `icon` names come from `LandingIcons`; Material has no brand glyphs,
/// so the demo uses generic ones. Swap in your own icons if you need them.
class InMemoryFooterRemoteDataSource implements FooterRemoteDataSource {
  /// Creates the data source.
  const InMemoryFooterRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'description':
        'Kestrel is the calm way to plan, track and ship work with your '
        'whole team.',
    'columns': <Object?>[
      <String, Object?>{
        'title': 'Product',
        'links': <Object?>[
          <String, Object?>{'label': 'Features', 'href': '#features'},
          <String, Object?>{'label': 'Pricing', 'href': '#pricing'},
          <String, Object?>{'label': 'Customers', 'href': '#testimonials'},
          <String, Object?>{'label': 'Changelog', 'href': '/changelog'},
        ],
      },
      <String, Object?>{
        'title': 'Company',
        'links': <Object?>[
          <String, Object?>{'label': 'About', 'href': '/about'},
          <String, Object?>{'label': 'Careers', 'href': '/careers'},
          <String, Object?>{'label': 'Blog', 'href': '/blog'},
          <String, Object?>{
            'label': 'Contact',
            'href': 'mailto:hello@kestrel.example',
          },
        ],
      },
      <String, Object?>{
        'title': 'Resources',
        'links': <Object?>[
          <String, Object?>{'label': 'Help centre', 'href': '/help'},
          <String, Object?>{'label': 'Guides', 'href': '/guides'},
          <String, Object?>{'label': 'API', 'href': '/api'},
          <String, Object?>{'label': 'Status', 'href': '/status'},
        ],
      },
    ],
    'social': <Object?>[
      <String, Object?>{
        'label': 'Kestrel on the web',
        'icon': 'public',
        'href': 'https://kestrel.example',
      },
      <String, Object?>{
        'label': 'Kestrel on GitHub',
        'icon': 'code',
        'href': 'https://github.com/kestrel-example',
      },
      <String, Object?>{
        'label': 'Kestrel blog feed',
        'icon': 'rss',
        'href': '/blog/feed.xml',
      },
      <String, Object?>{
        'label': 'Email Kestrel',
        'icon': 'mail',
        'href': 'mailto:hello@kestrel.example',
      },
    ],
    'copyright': '© 2026 Kestrel Labs, Inc. All rights reserved.',
    'legal': <Object?>[
      <String, Object?>{'label': 'Privacy', 'href': '/privacy'},
      <String, Object?>{'label': 'Terms', 'href': '/terms'},
    ],
  };

  @override
  Future<JsonMap> fetchFooter() async => _json;
}
