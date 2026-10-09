import 'package:flutter/widgets.dart';

import '../../common/constants/chat_package.dart';

/// The image for an avatar or attachment reference: an `http(s)` URL loads from
/// the network, anything else is an asset path of this template (or of the host
/// app, see [ChatPackage]).
ImageProvider<Object> chatImage(String reference) {
  if (reference.startsWith('http://') || reference.startsWith('https://')) {
    return NetworkImage(reference);
  }
  return AssetImage(reference, package: ChatPackage.name);
}
