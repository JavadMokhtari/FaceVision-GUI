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
import '../widgets/tag_input.dart';
import '../widgets/toggle_row.dart';

class MatchFeatureScreen extends StatefulWidget {
  const MatchFeatureScreen({super.key});

  @override
  State<MatchFeatureScreen> createState() => _MatchFeatureScreenState();
}

class _MatchFeatureScreenState extends State<MatchFeatureScreen> {
  final _refDir = TextEditingController();
  final _probeDir = TextEditingController();
  final _outputDir = TextEditingController();
  bool _recursive = true;
  bool _isQuantized = true;
  bool _verbose = true;
  List<String> _featureExts = ['bin'];

  // Breakpoint below which the "Feature File Extensions" row collapses
  // into a column instead of squeezing the TagInput horizontally.
  static const double _narrowBreakpoint = 380;

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
    await run.run('Matching', () async {
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

  Widget _buildExtensionsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feature File Extensions',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: context.cTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Match features with different formats',
          style: TextStyle(
            fontSize: 11.5,
            color: context.cTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExtensionsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < _narrowBreakpoint;

        final tagInput = TagInput(
          initialTags: _featureExts,
          onChanged: (tags) => setState(() => _featureExts = tags),
        );

        if (isNarrow) {
          // Stack vertically on small widths so the tag input gets
          // full room instead of being squeezed against the label.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExtensionsHeader(),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: tagInput),
            ],
          );
        }

        // Wide layout: label on the left, tag input on the right.
        // Top-aligned rather than centered, so the label stays pinned
        // to the top of the row instead of drifting toward the middle
        // as the tag input grows taller (chips wrapping to more lines).
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildExtensionsHeader()),
            const SizedBox(width: 12),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topRight,
                child: tagInput,
              ),
            ),
          ],
        );
      },
    );
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
            const SizedBox(height: 12),
            FolderField(label: 'Probe folder', controller: _probeDir),
            const SizedBox(height: 12),
            FolderField(label: 'Output folder', controller: _outputDir),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'OPTIONS',
          icon: Icons.settings_suggest_rounded,
          children: [
            _buildExtensionsRow(),
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
        Align(
          alignment: Alignment.centerRight,
          child: RunButton(
            label: 'Run Matcher',
            loading: run.isRunning,
            onPressed: () => _run(run),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
