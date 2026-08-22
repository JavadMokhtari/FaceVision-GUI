import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FolderField extends StatelessWidget {
  const FolderField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'Select a folder…',
  });

  final String label;
  final TextEditingController controller;
  final String hint;

  Future<void> _pick() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) controller.text = path;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.cTextPrimary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: hint,
                    prefixIcon: const Icon(Icons.folder_outlined, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _BrowseButton(onTap: _pick),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrowseButton extends StatefulWidget {
  const _BrowseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BrowseButton> createState() => _BrowseButtonState();
}

class _BrowseButtonState extends State<_BrowseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _hover ? context.cSurfaceElevated : context.cSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cBorder),
          ),
          child: const Center(
            child: Text('Browse',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
