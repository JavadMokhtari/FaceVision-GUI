enum LogLevel { info, success, warning, error }

class LogEntry {
  LogEntry(this.message, {this.level = LogLevel.info}) : time = DateTime.now();

  final DateTime time;
  final String message;
  final LogLevel level;

  String get timeLabel {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
