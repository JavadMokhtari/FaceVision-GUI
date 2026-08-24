import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small chip-entry field for things like feature file extensions
/// (".bin", ".feat", …). Produces a `List<String>` — see the note in
/// `screens/match_feature_screen.dart` about bridging that to the
/// generated `List<Str>` parameter type.
class TagInput extends StatefulWidget {
  const TagInput({
    super.key,
    this.label,
    required this.initialTags,
    required this.onChanged,
    this.hint = 'Type an extension and press Enter',
  });

  /// Optional label shown above the field. When null (or empty), no
  /// label is rendered and no extra vertical space is reserved for
  /// it, so the field itself doesn't shift down.
  final String? label;
  final List<String> initialTags;
  final String hint;
  final ValueChanged<List<String>> onChanged;

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  late final List<String> _tags = List.of(widget.initialTags);
  final _ctrl = TextEditingController();

  void _add(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    setState(() {
      if (!_tags.contains(v)) _tags.add(v);
      _ctrl.clear();
    });
    widget.onChanged(_tags);
  }

  void _remove(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged(_tags);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasLabel = widget.label != null && widget.label!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLabel) ...[
            Text(widget.label!,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.cTextPrimary)),
            const SizedBox(height: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cBorder),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final tag in _tags)
                  _Chip(label: tag, onRemove: () => _remove(tag)),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: _add,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: _tags.isEmpty ? widget.hint : 'Add another…',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 180),
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
