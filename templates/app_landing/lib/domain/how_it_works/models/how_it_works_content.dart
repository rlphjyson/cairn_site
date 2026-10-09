import 'package:equatable/equatable.dart';

/// The how-it-works section.
class HowItWorksContent extends Equatable {
  /// Creates the content.
  const HowItWorksContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The steps, in order.
  final List<StepItem> steps;

  @override
  List<Object?> get props => <Object?>[eyebrow, title, subtitle, steps];
}

/// One step.
class StepItem extends Equatable {
  /// Creates a step.
  const StepItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// The icon name.
  final String icon;

  /// The step title.
  final String title;

  /// What happens in this step.
  final String description;

  @override
  List<Object?> get props => <Object?>[icon, title, description];
}
