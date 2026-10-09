import 'package:equatable/equatable.dart';

import '../../shared/models/link.dart';

/// Everything in the hero.
class HeroContent extends Equatable {
  /// Creates the hero content.
  const HeroContent({
    required this.announcement,
    required this.headline,
    required this.subcopy,
    required this.primaryCta,
    required this.secondaryCta,
    required this.proof,
    required this.visual,
  });

  /// The pill above the headline.
  final Link announcement;

  /// The headline.
  final String headline;

  /// The copy under the headline.
  final String subcopy;

  /// The main call to action.
  final Link primaryCta;

  /// The quieter call to action.
  final Link secondaryCta;

  /// The social-proof line.
  final SocialProof proof;

  /// The product shown in the browser mockup.
  final ProductVisual visual;

  @override
  List<Object?> get props => <Object?>[
    announcement,
    headline,
    subcopy,
    primaryCta,
    secondaryCta,
    proof,
    visual,
  ];
}

/// Avatars, a rating and a sentence.
class SocialProof extends Equatable {
  /// Creates the social proof.
  const SocialProof({
    required this.text,
    required this.rating,
    required this.ratingLabel,
    required this.avatars,
  });

  /// The sentence, such as "Loved by 12,000 teams".
  final String text;

  /// The average rating out of five.
  final double rating;

  /// The accessible description of [rating].
  final String ratingLabel;

  /// Image assets for the avatar stack.
  final List<String> avatars;

  @override
  List<Object?> get props => <Object?>[text, rating, ratingLabel, avatars];
}

/// The mini dashboard drawn inside the browser mockup.
class ProductVisual extends Equatable {
  /// Creates the visual.
  const ProductVisual({
    required this.url,
    required this.project,
    required this.status,
    required this.sidebar,
    required this.metrics,
    required this.chartTitle,
    required this.barLabels,
    required this.bars,
    required this.tasksTitle,
    required this.tasks,
    required this.team,
  });

  /// The address shown in the browser bar.
  final String url;

  /// The project title at the top of the dashboard.
  final String project;

  /// The badge next to the title.
  final String status;

  /// The sidebar entries.
  final List<SidebarEntry> sidebar;

  /// The headline numbers.
  final List<VisualMetric> metrics;

  /// The chart title.
  final String chartTitle;

  /// One label per bar.
  final List<String> barLabels;

  /// One value per bar, from 0 to 1.
  final List<double> bars;

  /// The task list title.
  final String tasksTitle;

  /// The tasks.
  final List<VisualTask> tasks;

  /// Avatar assets for the project team.
  final List<String> team;

  @override
  List<Object?> get props => <Object?>[
    url,
    project,
    status,
    sidebar,
    metrics,
    chartTitle,
    barLabels,
    bars,
    tasksTitle,
    tasks,
    team,
  ];
}

/// One sidebar row in the mockup.
class SidebarEntry extends Equatable {
  /// Creates an entry.
  const SidebarEntry({
    required this.icon,
    required this.label,
    required this.active,
  });

  /// The icon name.
  final String icon;

  /// The label.
  final String label;

  /// Whether this is the current page.
  final bool active;

  @override
  List<Object?> get props => <Object?>[icon, label, active];
}

/// One number in the mockup.
class VisualMetric extends Equatable {
  /// Creates a metric.
  const VisualMetric({
    required this.label,
    required this.value,
    required this.delta,
  });

  /// What is measured.
  final String label;

  /// The value.
  final String value;

  /// The change, such as `+12%`.
  final String delta;

  @override
  List<Object?> get props => <Object?>[label, value, delta];
}

/// One task row in the mockup.
class VisualTask extends Equatable {
  /// Creates a task.
  const VisualTask({
    required this.title,
    required this.owner,
    required this.status,
    required this.progress,
  });

  /// The task name.
  final String title;

  /// The avatar asset of the person it is assigned to.
  final String owner;

  /// The status badge text.
  final String status;

  /// Completion from 0 to 1.
  final double progress;

  @override
  List<Object?> get props => <Object?>[title, owner, status, progress];
}
