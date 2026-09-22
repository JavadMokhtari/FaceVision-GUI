import 'dart:async';

import 'run_controller.dart';
import '../src/rust/api/logging.dart' as bridge;

/// Polls `bridge.drainLogLines()` on a timer and feeds every line into
/// [RunController.logFromStream]. No stream subscription lifecycle to
/// manage, no custom bridge type — just `Vec<String>` in, one call at a
/// time.
///
/// The timer only runs while [RunController.isRunning] is true — call
/// [attach] once in `main()` and forget about it; it starts and stops
/// itself. Polling continuously for the app's entire lifetime (including
/// while idle, which is most of the time) was unnecessary background CPU
/// work and FFI traffic for no benefit, so this only pays that cost while
/// a task is actually in flight.
class LogPoller {
  LogPoller(this._runController);

  final RunController _runController;
  Timer? _timer;

  /// [interval] of ~200-300ms feels close to live without hammering the
  /// bridge. Bump it up if you only care about start/finish lines rather
  /// than fine-grained progress text.
  void attach({Duration interval = const Duration(milliseconds: 250)}) {
    _runController.addListener(() => _syncWithRunState(interval));
    _syncWithRunState(interval); // in case a task is already running
  }

  void _syncWithRunState(Duration interval) {
    final running = _runController.isRunning;
    if (running && _timer == null) {
      _timer = Timer.periodic(interval, (_) => _poll());
    } else if (!running && _timer != null) {
      _timer!.cancel();
      _timer = null;
      // One last drain to pick up any trailing lines Rust wrote right
      // before the run finished, between the last tick and now.
      unawaited(_poll());
    }
  }

  Future<void> _poll() async {
    final lines = await bridge.drainLogLines();
    for (final line in lines) {
      _runController.logFromStream(line);
    }
  }

  void dispose() => _timer?.cancel();
}
