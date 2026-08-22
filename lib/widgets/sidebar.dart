// import 'package:flutter/material.dart';

// import '../theme/app_theme.dart';

// class SidebarItem {
//   const SidebarItem({required this.icon, required this.label});
//   final IconData icon;
//   final String label;
// }

// class Sidebar extends StatelessWidget {
//   const Sidebar({
//     super.key,
//     required this.items,
//     required this.selectedIndex,
//     required this.onSelect,
//   });

//   final List<SidebarItem> items;
//   final int selectedIndex;
//   final ValueChanged<int> onSelect;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 232,
//       decoration: const BoxDecoration(
//         color: AppTheme.surface,
//         border: Border(right: BorderSide(color: AppTheme.border)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: 26),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 22),
//             child: Row(
//               children: [
//                 Container(
//                   width: 34,
//                   height: 34,
//                   decoration: const BoxDecoration(
//                     gradient: AppTheme.accentGradient,
//                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                   ),
//                   child: const Icon(Icons.face_retouching_natural,
//                       size: 19, color: Colors.white),
//                 ),
//                 const SizedBox(width: 10),
//                 const Expanded(
//                   child: Text(
//                     'FaceVision',
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Padding(
//             padding: EdgeInsets.only(left: 22),
//             child: Text('Dataset Studio',
//                 style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
//           ),
//           const SizedBox(height: 28),
//           for (var i = 0; i < items.length; i++)
//             _SidebarButton(
//               item: items[i],
//               selected: i == selectedIndex,
//               onTap: () => onSelect(i),
//             ),
//           const Spacer(),
//           Padding(
//             padding: const EdgeInsets.all(18),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppTheme.surfaceElevated,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppTheme.border),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.bolt_rounded, size: 16, color: AppTheme.accentB),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Powered by ONNX Runtime',
//                       style: TextStyle(
//                           fontSize: 11.5, color: AppTheme.textSecondary),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SidebarButton extends StatefulWidget {
//   const _SidebarButton({
//     required this.item,
//     required this.selected,
//     required this.onTap,
//   });

//   final SidebarItem item;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   State<_SidebarButton> createState() => _SidebarButtonState();
// }

// class _SidebarButtonState extends State<_SidebarButton> {
//   bool _hover = false;

//   @override
//   Widget build(BuildContext context) {
//     final selected = widget.selected;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
//       child: MouseRegion(
//         onEnter: (_) => setState(() => _hover = true),
//         onExit: (_) => setState(() => _hover = false),
//         child: GestureDetector(
//           onTap: widget.onTap,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 220),
//             curve: Curves.easeOutCubic,
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(11),
//               gradient: selected ? AppTheme.accentGradient : null,
//               color: selected
//                   ? null
//                   : _hover
//                       ? AppTheme.surfaceElevated
//                       : Colors.transparent,
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   widget.item.icon,
//                   size: 18,
//                   color: selected ? Colors.white : AppTheme.textSecondary,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   widget.item.label,
//                   style: TextStyle(
//                     fontSize: 13.5,
//                     fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
//                     color: selected ? Colors.white : AppTheme.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
