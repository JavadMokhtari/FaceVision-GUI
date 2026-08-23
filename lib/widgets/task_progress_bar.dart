import 'package:flutter/material.dart';

import '../models/run_controller.dart';
import '../theme/app_theme.dart';

/// Live progress bar for the currently running task, driven by
/// `RunController.progress*` fields (see PROGRESS_REPORTING.md). Shows
/// nothing when no structured progress is active — the plain start/stop
/// text log still works fine without it.
class TaskProgressBar extends StatelessWidget {
  const TaskProgressBar({super.key, required this.controller});

  final RunController controller;

  String _eta() {
    final done = controller.progressDone;
    final total = controller.progressTotal;
    final elapsed = controller.progressElapsedSecs;
    if (done == 0 || total == 0) return '';
    final rate = done / elapsed;
    if (rate <= 0) return '';
    final remaining = (total - done) / rate;
    if (remaining < 1) return '<1s left';
    if (remaining < 60) return '${remaining.round()}s left';
    return '${(remaining / 60).round()}m left';
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.progressActive;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !active
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.progressLabel ?? 'Processing…',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: context.cTextPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${controller.progressDone}/${controller.progressTotal}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.cTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Container(height: 8, color: context.cBorder),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: controller.progressPercent / 100,
                          ),
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          builder: (context, t, _) {
                            return FractionallySizedBox(
                              widthFactor: t.clamp(0, 1),
                              child: Container(
                                height: 8,
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.progressPercent}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentB,
                        ),
                      ),
                      Text(
                        _eta(),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: context.cTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
