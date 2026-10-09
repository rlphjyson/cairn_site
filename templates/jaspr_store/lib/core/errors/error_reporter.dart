/// Error reporting seam. Swap [ConsoleErrorReporter] for Sentry/GlitchTip by
/// implementing [ErrorReporter] and changing one line in `di/service_locator.dart`.
library;

abstract interface class ErrorReporter {
  void report(Object error, StackTrace? stack, {String? context});
}

class ConsoleErrorReporter implements ErrorReporter {
  const ConsoleErrorReporter();
  @override
  void report(Object error, StackTrace? stack, {String? context}) {
    // ignore: avoid_print
    print('[error]${context == null ? '' : ' ($context)'} $error${stack == null ? '' : '\n$stack'}');
  }
}

class RecordingErrorReporter implements ErrorReporter {
  final List<Object> errors = [];
  @override
  void report(Object error, StackTrace? stack, {String? context}) => errors.add(error);
}
