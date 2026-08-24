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

class ExtractFeatureScreen extends StatefulWidget {
  const ExtractFeatureScreen({super.key});

  @override
  State<ExtractFeatureScreen> createState() => _ExtractFeatureScreenState();
}

class _ExtractFeatureScreenState extends State<ExtractFeatureScreen> {
  final _srcDir = TextEditingController();
  final _dstDir = TextEditingController();
  int _embeddingLen = 128;
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
      'Params → embeddingLen=$_embeddingLen, recursive=$_recursive, quantized=$_quantized'
      '${_shard != null ? ', shard=${_shard!.$1}/${_shard!.$2}' : ''}',
    );
    await run.run('Extraction', () async {
      await bridge.extractFeature(
        srcDir: _srcDir.text,
        dstDir: _dstDir.text,
        embeddingLen: _embeddingLen,
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
          title: 'OPTIONS',
          icon: Icons.settings_suggest_rounded,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Embedding Length',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: context.cTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dimension of the face embedding vector',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.cTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 170,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: context.cSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.cBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _embeddingLen,
                      isExpanded: true,
                      dropdownColor: context.cSurface,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.cTextPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 128,
                          child: Center(
                            child: Text('128  ( Compact )'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 512,
                          child: Center(
                            child: Text('512  ( More Accurate )'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _embeddingLen = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
        Align(
          alignment: Alignment.centerRight,
          child: RunButton(
            label: 'Run Extraction',
            loading: run.isRunning,
            onPressed: () => _run(run),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
