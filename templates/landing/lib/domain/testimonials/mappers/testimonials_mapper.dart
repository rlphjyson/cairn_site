import '../../../common/utils/json.dart';
import '../models/testimonials_content.dart';

/// Maps the testimonials JSON.
TestimonialsContent mapTestimonials(JsonMap json) => TestimonialsContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  items: <Testimonial>[
    for (final JsonMap e in json.objects('items'))
      Testimonial(
        quote: e.string('quote'),
        name: e.string('name'),
        role: e.string('role'),
        company: e.string('company'),
        avatar: e.string('avatar'),
        rating: e.number('rating').clamp(0.0, 5.0),
      ),
  ],
);
