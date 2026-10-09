import '../../../common/utils/json.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/faq_content.dart';

/// Maps the FAQ JSON.
FaqContent mapFaq(JsonMap json) => FaqContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  items: <FaqItem>[
    for (final JsonMap e in json.objects('items'))
      FaqItem(
        id: e.string('id'),
        question: e.string('question'),
        answer: e.string('answer'),
      ),
  ],
  contactText: json.string('contactText'),
  contact: mapLink(json.object('contact')),
);
