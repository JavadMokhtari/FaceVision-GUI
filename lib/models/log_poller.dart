import 'dart:async';

import 'run_controller.dart';
import '../src/rust/api/logging.dart' as bridge;

/// Polls `bridge.drainLogLines()` on a timer and feeds every line into
/// [RunController.logFromStream]. No stream subscription lifecycle to
/// manage, no custom bridge type — just `Vec<String>` in, one call at a
/// time. Start once in `main()` and forget about it.
class LogPoller {
  LogPoller(this._runController);

  final RunController _runController;
  Timer? _timer;

  /// [interval] of ~200-300ms feels close to live without hammering the bridge.
  void start({Duration interval = const Duration(milliseconds: 250)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  Future<void> _poll() async {
    final lines = await bridge.drainLogLines();
    for (final line in lines) {
      _runController.logFromStream(line);
    }
  }

  void dispose() => _timer?.cancel();
}
