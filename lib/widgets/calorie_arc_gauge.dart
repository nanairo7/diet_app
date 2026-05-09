import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_strings.dart';

class CalorieArcGauge extends StatelessWidget {
  final double currentCalories;
  final double? goalCalories;
  final DateTime date;

  const CalorieArcGauge({
    super.key,
    required this.currentCalories,
    required this.date,
    this.goalCalories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGoal = goalCalories != null && goalCalories! > 0;
    final progress =
        hasGoal ? (currentCalories / goalCalories!).clamp(0.0, 1.0) : 0.0;
    final isOver = hasGoal && currentCalories > goalCalories!;
    final progressColor = isOver ? theme.colorScheme.error : Colors.green;

    return Container(
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // 日付
          Text(
            DateFormat('yyyy/MM/dd').format(date),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(200)),
          ),
          const SizedBox(height: 8),
          // 円弧ゲージ
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _ArcPainter(
                progress: progress,
                trackColor:
                    theme.colorScheme.onPrimary.withAlpha(60),
                progressColor: progressColor,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currentCalories.toStringAsFixed(0)}kcal',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasGoal)
                        Text(
                          '/${goalCalories!.toStringAsFixed(0)}kcal',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withAlpha(200),
                          ),
                        ),
                      if (!hasGoal)
                        Text(
                          AppStrings.notSet,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary.withAlpha(180),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    // 丸キャップ（strokeWidth/2）が下にはみ出さないようセンターを上にずらす
    final center = Offset(size.width / 2, size.height - strokeWidth / 2);
    final radius = math.min(size.width / 2, size.height - strokeWidth / 2) - strokeWidth / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 背景弧（180°）
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // 進捗弧
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
