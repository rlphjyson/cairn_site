import '../../../common/utils/json.dart';
import '../models/how_it_works_content.dart';

/// Maps the how-it-works JSON.
HowItWorksContent mapHowItWorks(JsonMap json) => HowItWorksContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  steps: <StepItem>[
    for (final JsonMap e in json.objects('steps'))
      StepItem(
        icon: e.string('icon'),
        title: e.string('title'),
        description: e.string('description'),
      ),
  ],
);
