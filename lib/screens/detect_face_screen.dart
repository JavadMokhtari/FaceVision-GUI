import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../src/rust/api/run_dataset.dart' as bridge;
import '../models/log_entry.dart';
import '../models/run_controller.dart';
import '../widgets/folder_field.dart';
import '../widgets/labeled_slider.dart';
import '../widgets/run_button.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';
import '../widgets/shard_field.dart';
import '../widgets/toggle_row.dart';

class DetectFaceScreen extends StatefulWidget {
  const DetectFaceScreen({super.key});

  @override
  State<DetectFaceScreen> createState() => _DetectFaceScreenState();
}

class _DetectFaceScreenState extends State<DetectFaceScreen> {
  final _srcDir = TextEditingController();
  final _dstDir = TextEditingController();
  final _imgSize = TextEditingController(text: '640');

  double _confidence = 0.5;
  double _iou = 0.45;
  bool _recursive = true;
  bool _saveFaces = true;
  bool _verbose = true;
  (BigInt, BigInt)? _shard;

  @override
  void dispose() {
    _srcDir.dispose();
    _dstDir.dispose();
    _imgSize.dispose();
    super.dispose();
  }

  Future<void> _run(RunController run) async {
    if (_srcDir.text.isEmpty || _dstDir.text.isEmpty) {
      run.log('Please choose both a source and destination folder.',
          level: LogLevel.warning);
      return;
    }
    run.log(
      'Params → size=${_imgSize.text}, conf=${_confidence.toStringAsFixed(2)}, '
      'iou=${_iou.toStringAsFixed(2)}, recursive=$_recursive, saveFaces=$_saveFaces'
      '${_shard != null ? ', shard=${_shard!.$1}/${_shard!.$2}' : ''}',
    );
    await run.run('Detect Face', () async {
      await bridge.detectFace(
        srcDir: _srcDir.text,
        dstDir: _dstDir.text,
        imgSize: int.parse(_imgSize.text),
        confidence: _confidence,
        iou: _iou,
        recursive: _recursive,
        shard: _shard,
        saveFaces: _saveFaces,
        verbose: _verbose,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunController>();

    return ScreenScaffold(
      title: 'Face Detection',
      subtitle: 'Run face detection over an image dataset',
      icon: Icons.center_focus_strong_rounded,
      children: [
        SectionCard(
          title: 'FOLDERS',
          icon: Icons.folder_open_rounded,
          children: [
            FolderField(label: 'Source folder', controller: _srcDir),
            FolderField(label: 'Destination folder', controller: _dstDir),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'DETECTION PARAMETERS',
          icon: Icons.tune_rounded,
          children: [
            TextField(
              controller: _imgSize,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Image size (px)'),
            ),
            const SizedBox(height: 16),
            LabeledSlider(
              label: 'Confidence threshold',
              value: _confidence,
              min: 0,
              max: 1,
              onChanged: (v) => setState(() => _confidence = v),
            ),
            LabeledSlider(
              label: 'IoU threshold',
              value: _iou,
              min: 0,
              max: 1,
              onChanged: (v) => setState(() => _iou = v),
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
              label: 'Save cropped faces',
              subtitle: 'Write detected face crops to disk',
              value: _saveFaces,
              onChanged: (v) => setState(() => _saveFaces = v),
            ),
            ToggleRow(
              label: 'Verbose logging',
              value: _verbose,
              onChanged: (v) => setState(() => _verbose = v),
            ),
            const SizedBox(height: 4),
            ShardField(onChanged: (s) => _shard = s),
          ],
        ),
        const SizedBox(height: 24),
        RunButton(
          label: 'Run Detection',
          loading: run.isRunning,
          onPressed: () => _run(run),
        ),
      ],
    );
  }
}
