import '../../../common/utils/json.dart';
import '../models/link.dart';

/// Maps `{"label": ..., "href": ...}`.
Link mapLink(JsonMap json) =>
    Link(label: json.string('label'), href: json.string('href'));

/// Maps a list of links.
List<Link> mapLinks(List<JsonMap> json) => json.map(mapLink).toList();
