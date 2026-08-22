import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../src/rust/api/run_dataset.dart' as bridge;
import '../models/log_entry.dart';
import '../models/run_controller.dart';
import '../widgets/folder_field.dart';
import '../widgets/run_button.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';
import '../widgets/tag_input.dart';
import '../widgets/toggle_row.dart';

class MatchFeatureScreen extends StatefulWidget {
  const MatchFeatureScreen({super.key});

  @override
  State<MatchFeatureScreen> createState() => _CrossMatchScreenState();
}

class _CrossMatchScreenState extends State<MatchFeatureScreen> {
  final _refDir = TextEditingController();
  final _probeDir = TextEditingController();
  final _outputDir = TextEditingController();
  bool _recursive = true;
  bool _isQuantized = true;
  bool _verbose = true;
  List<String> _featureExts = ['.bin'];

  @override
  void dispose() {
    _refDir.dispose();
    _probeDir.dispose();
    _outputDir.dispose();
    super.dispose();
  }

  Future<void> _run(RunController run) async {
    if (_refDir.text.isEmpty ||
        _probeDir.text.isEmpty ||
        _outputDir.text.isEmpty) {
      run.log('Please choose reference, probe, and output folders.',
          level: LogLevel.warning);
      return;
    }
    if (_featureExts.isEmpty) {
      run.log('Add at least one feature file extension.',
          level: LogLevel.warning);
      return;
    }
    run.log(
      'Params → recursive=$_recursive, quantized=$_isQuantized, '
      'exts=${_featureExts.join(", ")}',
    );
    await run.run('Cross Match Feature', () async {
      await bridge.matchFeature(
        refDir: _refDir.text,
        probeDir: _probeDir.text,
        outputDir: _outputDir.text,
        recursive: _recursive,
        isQuantized: _isQuantized,
        featureExts: _featureExts,
        verbose: _verbose,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunController>();

    return ScreenScaffold(
      title: 'Feature Matching',
      subtitle: 'Compare a probe set against a reference set',
      icon: Icons.swap_horiz_rounded,
      children: [
        SectionCard(
          title: 'FOLDERS',
          icon: Icons.folder_open_rounded,
          children: [
            FolderField(label: 'Reference folder', controller: _refDir),
            FolderField(label: 'Probe folder', controller: _probeDir),
            FolderField(label: 'Output folder', controller: _outputDir),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'FEATURE FILES',
          icon: Icons.data_object_rounded,
          children: [
            TagInput(
              label: 'Feature file extensions',
              initialTags: _featureExts,
              onChanged: (tags) => _featureExts = tags,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'OPTIONS',
          icon: Icons.settings_suggest_rounded,
          children: [
            ToggleRow(
              label: 'Recursive',
              subtitle: 'Include subfolders',
              value: _recursive,
              onChanged: (v) => setState(() => _recursive = v),
            ),
            ToggleRow(
              label: 'Quantized features',
              value: _isQuantized,
              onChanged: (v) => setState(() => _isQuantized = v),
            ),
            ToggleRow(
              label: 'Verbose logging',
              value: _verbose,
              onChanged: (v) => setState(() => _verbose = v),
            ),
          ],
        ),
        const SizedBox(height: 24),
        RunButton(
          label: 'Run Matcher',
          loading: run.isRunning,
          onPressed: () => _run(run),
        ),
      ],
    );
  }
}
