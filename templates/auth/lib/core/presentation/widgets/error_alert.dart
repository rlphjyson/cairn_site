import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// A destructive Cairn alert for a failed request.
///
/// The alert is a live region, so screen readers announce it when it appears.
class ErrorAlert extends StatelessWidget {
  /// Creates an alert.
  const ErrorAlert({super.key, required this.title, required this.message});

  /// A short heading (one line).
  final String title;

  /// What happened and what to do.
  final String message;

  @override
  Widget build(BuildContext context) => CairnAlert(
    variant: CairnAlertVariant.destructive,
    icon: const Icon(Icons.error_outline),
    title: Text(title),
    description: Text(message),
  );
}

/// A neutral Cairn alert for information.
class InfoAlert extends StatelessWidget {
  /// Creates an alert.
  const InfoAlert({super.key, required this.title, required this.message});

  /// A short heading (one line).
  final String title;

  /// The detail.
  final String message;

  @override
  Widget build(BuildContext context) => CairnAlert(
    icon: const Icon(Icons.info_outline),
    title: Text(title),
    description: Text(message),
  );
}
