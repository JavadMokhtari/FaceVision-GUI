import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'models/run_controller.dart';
import 'models/theme_controller.dart';
import 'src/rust/frb_generated.dart';
import 'theme/app_theme.dart';

// import 'src/rust/api/run_dataset.dart' as bridge; // for createLogStream()

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();

  final runController = RunController();

  // Once you've added `create_log_stream` on the Rust side (see
  // RUST_LOGGING.md), uncomment this to pipe every eprintln!-replacement
  // line straight into the log console:
  // bridge.createLogStream().listen(runController.logFromStream);

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
