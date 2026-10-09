/// The blog's name, copy and links. Change these to rebrand the template.
abstract final class BlogBrand {
  /// Shown in the navbar, the footer and the About page.
  static const String name = 'Fieldnotes';

  /// A single letter for the logo mark.
  static const String mark = 'F';

  /// The line under the brand in the footer.
  static const String tagline =
      'Notes on design systems, Flutter and the teams that build them.';

  /// The home page's eyebrow above the headline.
  static const String eyebrow = 'The journal';

  /// The home page's headline.
  static const String headline = 'Notes on building interfaces that last';

  /// The home page's lead paragraph.
  static const String lead =
      'Essays from a small product team about design systems, Flutter, '
      'product thinking and how we work together.';

  /// The base used by "Copy link": `<postBaseUrl>/<post id>`.
  static const String postBaseUrl = 'https://example.com/blog';

  /// The footer's copyright line.
  static const String copyright = 'Fieldnotes. Built with Cairn UI.';

  /// The About page's introduction.
  static const String aboutLead =
      'Fieldnotes is where a small product team writes down what it learns '
      'while building and maintaining a design system, a Flutter codebase '
      'and the habits around them.';
}
