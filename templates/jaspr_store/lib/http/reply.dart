/// What a controller decides; `app.dart` turns it into a shelf `Response`.
library;

import 'package:jaspr/jaspr.dart';
import 'package:shelf/shelf.dart';

import '../core/seo/seo_data.dart';

/// HTTP caching class of a response.
enum CachePolicy {
  /// Identical for every visitor: shared caches may keep it briefly.
  catalogue,

  /// Personal or transactional: never stored anywhere.
  noStore,
}

sealed class Reply {
  const Reply({this.cookies = const []});

  /// Raw `Set-Cookie` header values.
  final List<String> cookies;
}

/// A server-rendered HTML page.
class PageReply extends Reply {
  const PageReply({
    required this.body,
    required this.seo,
    this.status = 200,
    this.cache = CachePolicy.catalogue,
    super.cookies,
  });

  final Component body;
  final SeoData seo;
  final int status;
  final CachePolicy cache;
}

class RedirectReply extends Reply {
  const RedirectReply(this.location, {this.status = 303, super.cookies});

  final String location;

  /// 301 for permanent canonical moves, 303 after a POST.
  final int status;
}

/// A non-HTML response (JSON, XML, plain text) built by the controller.
class RawReply extends Reply {
  const RawReply(this.response, {super.cookies});
  final Response response;
}

/// Ask `app.dart` for the real 404 page (status 404, `noindex`).
class NotFoundReply extends Reply {
  const NotFoundReply({super.cookies});
}
