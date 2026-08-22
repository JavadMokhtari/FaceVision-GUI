import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'toggle_row.dart';

/// UI for the optional `(BigInt, BigInt)? shard` parameter — a
/// (shardIndex, shardCount) pair used to split a dataset across workers.
class ShardField extends StatefulWidget {
  const ShardField({super.key, required this.onChanged});

  /// Called with null when sharding is disabled, or (index, count).
  final ValueChanged<(BigInt, BigInt)?> onChanged;

  @override
  State<ShardField> createState() => _ShardFieldState();
}

class _ShardFieldState extends State<ShardField> {
  bool _enabled = false;
  final _indexCtrl = TextEditingController(text: '0');
  final _countCtrl = TextEditingController(text: '4');

  void _emit() {
    if (!_enabled) {
      widget.onChanged(null);
      return;
    }
    final i = BigInt.tryParse(_indexCtrl.text) ?? BigInt.zero;
    final c = BigInt.tryParse(_countCtrl.text) ?? BigInt.one;
    widget.onChanged((i, c));
  }

  @override
  void dispose() {
    _indexCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToggleRow(
          label: 'Shard dataset',
          subtitle: 'Split work across parallel workers',
          value: _enabled,
          onChanged: (v) {
            setState(() => _enabled = v);
            _emit();
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState:
              _enabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: _MiniIntField(
                    label: 'Shard index',
                    controller: _indexCtrl,
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniIntField(
                    label: 'Shard count',
                    controller: _countCtrl,
                    onChanged: (_) => _emit(),
                  ),
                ),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _MiniIntField extends StatelessWidget {
  const _MiniIntField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: context.cTextSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }
}
