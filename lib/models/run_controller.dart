import 'package:flutter/foundation.dart';

import 'log_entry.dart';

/// Matches `print_bar`'s exact format: \r|####++----| 42% - 84/200 (3.51s)
/// Group 1: percent, group 2: done, group 3: total, group 4: elapsed secs.
/// The `[#+\-]+` bar characters themselves are discarded — we render a
/// real gradient bar from the numbers instead.
final RegExp _progressBarLine = RegExp(
  r'^\|[#+\-]+\|\s*(\d+)%\s*-\s*(\d+)\/(\d+)\s*\(([\d.]+)s\)$',
);

/// Drives task execution and owns both the text log feed and the live
/// progress bar shown in [LogConsole].
class RunController extends ChangeNotifier {
  final List<LogEntry> _logs = [];
  bool _isRunning = false;
  String? _currentTask;

  /// Index of the most recent unparsed `\r`-prefixed text line, for the
  /// plain-text redraw fallback (see [_upsertRedrawLine]). Reset
  /// whenever a normal line breaks the "slot", same rule a terminal follows.
  int? _redrawLineIndex;

  // ---- Structured progress state (from either source above) -----------
  String? _progressLabel;
  int _progressDone = 0;
  int _progressTotal = 0;
  int _progressPercent = 0;
  double _progressElapsedSecs = 0;
  bool _progressActive = false;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  bool get isRunning => _isRunning;
  String? get currentTask => _currentTask;

  String? get progressLabel => _progressLabel;
  int get progressDone => _progressDone;
  int get progressTotal => _progressTotal;
  int get progressPercent => _progressPercent;
  double get progressElapsedSecs => _progressElapsedSecs;
  bool get progressActive => _progressActive;

  void log(String message, {LogLevel level = LogLevel.info}) {
    _logs.add(LogEntry(message, level: level));
    _redrawLineIndex = null; // a normal line breaks any redraw "slot"
    notifyListeners();
  }

  /// For raw lines coming off a plain Rust log stream (see
  /// RUST_LOGGING.md / SIMPLE_LOG_CAPTURE.md). Recognizes:
  ///  - a leading `\r` matching `print_bar`'s exact format — parsed into
  ///    [progressPercent] / [progressDone] / [progressTotal] /
  ///    [progressElapsedSecs] and rendered as a real gradient bar
  ///    ([TaskProgressBar]) instead of a text line at all.
  ///  - any other leading `\r` — falls back to overwriting the previous
  ///    redraw line as plain text (terminal-style), in case the format
  ///    ever changes and the regex above stops matching.
  ///  - an optional `[WARN]` / `[ERROR]` / `[OK]` prefix, mapped to a
  ///    log level.
  /// Everything else logs as a plain new info line.
  void logFromStream(String rawLine) {
    if (rawLine.startsWith('\r')) {
      final body = rawLine.substring(1).trim();
      final match = _progressBarLine.firstMatch(body);
      if (match != null) {
        _applyParsedProgressLine(match);
      } else {
        _upsertRedrawLine(body);
      }
      return;
    }
    final line = rawLine.trim();
    if (line.isEmpty) return;
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

  void _applyParsedProgressLine(RegExpMatch match) {
    _progressActive = true;
    _progressLabel = _currentTask;
    _progressPercent = int.parse(match.group(1)!);
    _progressDone = int.parse(match.group(2)!);
    _progressTotal = int.parse(match.group(3)!);
    _progressElapsedSecs = double.parse(match.group(4)!);
    notifyListeners();
  }

  /// Overwrites the current redraw line in place if it's still the most
  /// recent entry, or starts a new one otherwise (e.g. right after a
  /// normal log line interrupted it).
  void _upsertRedrawLine(String message) {
    if (message.isEmpty) return;
    final entry = LogEntry(message, level: LogLevel.info);
    if (_redrawLineIndex != null && _redrawLineIndex == _logs.length - 1) {
      _logs[_redrawLineIndex!] = entry;
    } else {
      _logs.add(entry);
      _redrawLineIndex = _logs.length - 1;
    }
    notifyListeners();
  }

  void clear() {
    _logs.clear();
    _redrawLineIndex = null;
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
    _redrawLineIndex = null;
    notifyListeners();

    log('Starting "$taskName" ...');
    try {
      await task();
      log(
        '"$taskName" completed!',
        level: LogLevel.success,
      );
    } catch (e) {
      log('"$taskName" failed: $e', level: LogLevel.error);
      rethrow;
    } finally {
      _isRunning = false;
      _currentTask = null;
      _progressActive = false;
      notifyListeners();
    }
  }
}
