import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'models/log_poller.dart';
import 'models/run_controller.dart';
import 'models/theme_controller.dart';
import 'src/rust/frb_generated.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  final runController = RunController();
  LogPoller(runController).start();
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
