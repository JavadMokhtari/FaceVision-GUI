import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'models/log_poller.dart';
import 'models/run_controller.dart';
import 'models/theme_controller.dart';
import 'src/rust/frb_generated.dart';
import 'theme/app_theme.dart';

// Everything Rust-facing in this project (detectFace, extractFeature,
// matchFeature, crossMatchFeature, drainLogLines, requestCancel, ...)
// lives in one generated file:
// import 'src/rust/api/ops.dart' as bridge;
// `LogPoller` already imports it directly — see models/log_poller.dart.

// The StreamSink-based options below (ProgressEvent / createLogStream /
// createProgressStream) are the "fancy" route from RUST_LOGGING.md /
// PROGRESS_REPORTING.md, only relevant if you moved off LogPoller's
// simple polling approach (SIMPLE_LOG_CAPTURE.md) for push-based updates.
// import 'models/progress_event.dart'; // fromBridge(...) mapping — see that file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();

  final runController = RunController();

  // Polls `bridge.drainLogLines()` (Vec<String>, no custom bridge type)
  // on a timer, but ONLY while a task is running — see
  // models/log_poller.dart and SIMPLE_LOG_CAPTURE.md. Idle time costs
  // nothing.
  LogPoller(runController).attach();

  // Once you've added `create_log_stream` on the Rust side (see
  // RUST_LOGGING.md), you could use this push-based alternative instead
  // of LogPoller:
  // bridge.createLogStream().listen(runController.logFromStream);

  // Once you've added `create_progress_stream` (see
  // PROGRESS_REPORTING.md) and the `fromBridge` mapping described in
  // `models/progress_event.dart`, uncomment this for a live progress bar
  // driven by structured events instead of parsed text:
  // bridge.createProgressStream()
  //     .listen((e) => runController.applyProgressEvent(fromBridge(e)));

  runApp(FaceVisionApp(runController: runController));
}

class FaceVisionApp extends StatelessWidget {
  const FaceVisionApp({super.key, required this.runController});

  final RunController runController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: runController),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'FaceVision Dataset Studio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.mode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
