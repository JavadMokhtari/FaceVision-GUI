import 'package:flutter/foundation.dart';

import 'log_entry.dart';

/// Drives task execution and owns the log feed shown in [LogConsole].
///
/// The generated Rust bridge functions in the file you pasted (detectFace,
/// extractFeature, matchFeature, crossMatchFeature) return a bare
/// `Future<void>` with no progress/stream callback, so this controller can
/// only report start / success / failure plus elapsed time — it can't show
/// per-file progress. If you later expose a streaming API from Rust (e.g.
/// a `Stream<String>` of log lines via flutter_rust_bridge), pipe it into
/// [log] from inside the `task` closure passed to [run] and you'll get
/// live per-item logging for free.
class RunController extends ChangeNotifier {
  final List<LogEntry> _logs = [];
  bool _isRunning = false;
  String? _currentTask;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  bool get isRunning => _isRunning;
  String? get currentTask => _currentTask;

  void log(String message, {LogLevel level = LogLevel.info}) {
    _logs.add(LogEntry(message, level: level));
    notifyListeners();
  }

  /// For raw lines coming off a Rust log stream (see RUST_LOGGING.md).
  /// Recognizes an optional `[WARN]` / `[ERROR]` / `[OK]` prefix and maps
  /// it to a level; everything else logs as plain info.
  void logFromStream(String rawLine) {
    final line = rawLine.trim();
    if (line.startsWith('[ERROR]')) {
      log(line.substring(7).trim(), level: LogLevel.error);
    } else if (line.startsWith('[WARN]')) {
      log(line.substring(6).trim(), level: LogLevel.warning);
    } else if (line.startsWith('[OK]')) {
      log(line.substring(4).trim(), level: LogLevel.success);
    } else {
      log(line);
    }
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  Future<void> run(String taskName, Future<void> Function() task) async {
    if (_isRunning) {
      log('Another task ("$_currentTask") is still running — please wait.',
          level: LogLevel.warning);
      return;
    }
    _isRunning = true;
    _currentTask = taskName;
    notifyListeners();

    log('Starting "$taskName" ...');
    final sw = Stopwatch()..start();
    try {
      await task();
      sw.stop();
      log(
        '"$taskName" completed in ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s',
        level: LogLevel.success,
      );
    } catch (e) {
      sw.stop();
      log('"$taskName" failed: $e', level: LogLevel.error);
      rethrow;
    } finally {
      _isRunning = false;
      _currentTask = null;
      notifyListeners();
    }
  }
}
