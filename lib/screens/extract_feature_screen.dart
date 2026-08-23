import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../src/rust/api/ops.dart' as bridge;
import '../models/log_entry.dart';
import '../models/run_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/folder_field.dart';
import '../widgets/run_button.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';
import '../widgets/shard_field.dart';
import '../widgets/toggle_row.dart';

const _modelOptions = ['Facenet128', 'Facenet512', 'SFace'];

class ExtractFeatureScreen extends StatefulWidget {
  const ExtractFeatureScreen({super.key});

  @override
  State<ExtractFeatureScreen> createState() => _ExtractFeatureScreenState();
}

class _ExtractFeatureScreenState extends State<ExtractFeatureScreen> {
  final _srcDir = TextEditingController();
  final _dstDir = TextEditingController();
  String _modelName = _modelOptions.first.toLowerCase();
  bool _recursive = true;
  bool _quantized = true;
  bool _verbose = true;
  (BigInt, BigInt)? _shard;

  @override
  void dispose() {
    _srcDir.dispose();
    _dstDir.dispose();
    super.dispose();
  }

  Future<void> _run(RunController run) async {
    if (_srcDir.text.isEmpty || _dstDir.text.isEmpty) {
      run.log('Please choose both a source and destination folder.',
          level: LogLevel.warning);
      return;
    }
    run.log(
      'Params → model=$_modelName, recursive=$_recursive, quantized=$_quantized'
      '${_shard != null ? ', shard=${_shard!.$1}/${_shard!.$2}' : ''}',
    );
    await run.run('Extraction', () async {
      await bridge.extractFeature(
        srcDir: _srcDir.text,
        dstDir: _dstDir.text,
        modelName: _modelName,
        recursive: _recursive,
        quantized: _quantized,
        shard: _shard,
        verbose: _verbose,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunController>();

    return ScreenScaffold(
      title: 'Feature Extraction',
      subtitle: 'Compute face embeddings for a dataset',
      icon: Icons.blur_on_rounded,
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
          title: 'MODEL',
          icon: Icons.model_training_rounded,
          children: [
            Text('Model name',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.cTextPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in _modelOptions)
                  _ModelChip(
                    label: m,
                    selected: m.toLowerCase() == _modelName,
                    onTap: () => setState(() => _modelName = m.toLowerCase()),
                  ),
              ],
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
              label: 'Quantized',
              subtitle: 'Store embeddings as quantized bytes',
              value: _quantized,
              onChanged: (v) => setState(() => _quantized = v),
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
          label: 'Run Extraction',
          loading: run.isRunning,
          onPressed: () => _run(run),
        ),
      ],
    );
  }
}

class _ModelChip extends StatelessWidget {
  const _ModelChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.accentGradient : null,
          color: selected ? null : context.cSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.transparent : context.cBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : context.cTextSecondary,
          ),
        ),
      ),
    );
  }
}
