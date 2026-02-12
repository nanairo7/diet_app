import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

class SummaryCard extends StatelessWidget {
  final double totalCalories;
  final double totalProtein;
  final int entryCount;

  const SummaryCard({
    super.key,
    required this.totalCalories,
    required this.totalProtein,
    required this.entryCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    iconColor: Colors.orange,
                    label: AppStrings.totalCalories,
                    value: '${totalCalories.toStringAsFixed(0)} ${AppStrings.kcalUnit}',
                    valueStyle: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
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
                    value: '${totalProtein.toStringAsFixed(1)} ${AppStrings.gramUnit}',
                    valueStyle: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
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
