import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

class SummaryCard extends StatelessWidget {
  final double totalCalories;
  final double totalProtein;
  final int entryCount;
  final double? calorieGoal;

  const SummaryCard({
    super.key,
    required this.totalCalories,
    required this.totalProtein,
    required this.entryCount,
    this.calorieGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGoal = calorieGoal != null && calorieGoal! > 0;
    final isOver = hasGoal && totalCalories > calorieGoal!;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricColumn(
                    icon: Icons.local_fire_department,
                    iconColor: isOver ? Colors.red : Colors.orange,
                    label: AppStrings.totalCalories,
                    value:
                        '${totalCalories.toStringAsFixed(0)} ${AppStrings.kcalUnit}',
                    valueStyle: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOver ? Colors.red.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _MetricColumn(
                    icon: Icons.fitness_center,
                    iconColor: Colors.blue,
                    label: AppStrings.totalProtein,
                    value:
                        '${totalProtein.toStringAsFixed(1)} ${AppStrings.gramUnit}',
                    valueStyle: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (hasGoal) ...[
              const SizedBox(height: 16),
              _CalorieGoalBar(
                totalCalories: totalCalories,
                calorieGoal: calorieGoal!,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '${AppStrings.entryCount}: $entryCount ${AppStrings.entryUnit}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieGoalBar extends StatelessWidget {
  final double totalCalories;
  final double calorieGoal;

  const _CalorieGoalBar({
    required this.totalCalories,
    required this.calorieGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (totalCalories / calorieGoal).clamp(0.0, 1.5);
    final isOver = totalCalories > calorieGoal;
    final diff = (totalCalories - calorieGoal).abs();
    final barColor = isOver ? Colors.red : Colors.green;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppStrings.calorieGoal}: ${calorieGoal.toStringAsFixed(0)} ${AppStrings.kcalUnit}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              isOver
                  ? '${AppStrings.overCalorie}: +${diff.toStringAsFixed(0)} ${AppStrings.kcalUnit}'
                  : '${AppStrings.remainingCalorie}: ${diff.toStringAsFixed(0)} ${AppStrings.kcalUnit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOver ? Colors.red.shade700 : Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio > 1.0 ? 1.0 : ratio,
            minHeight: 10,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _MetricColumn({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
      ],
    );
  }
}
