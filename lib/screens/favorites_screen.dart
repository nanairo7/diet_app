import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../providers/diet_provider.dart';
import '../widgets/favorite_entry_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.favorites),
      ),
      body: Consumer<DietProvider>(
        builder: (context, provider, _) {
          final favorites = provider.favorites;
          final record = provider.todayRecord;

          return Column(
            children: [
              _TodayIntakeSummary(
                totalCalories: record.totalCalories,
                totalProtein: record.totalProtein,
                calorieGoal: provider.calorieGoal,
              ),
              const Divider(height: 1),
              Expanded(
                child: favorites.isEmpty
                    ? const Center(child: Text(AppStrings.favoritesEmpty))
                    : ListView.separated(
                        itemCount: favorites.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = favorites[index];
                          return FavoriteEntryTile(
                            entry: entry,
                            onAdd: () async {
                              await provider.addEntry(
                                name: entry.name,
                                calories: entry.calories,
                                protein: entry.protein,
                              );
                            },
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  content: Text(
                                      '「${entry.name}」を${AppStrings.favorites}から削除しますか？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text(AppStrings.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text(AppStrings.delete),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true) return;
                              await provider.removeFavorite(entry.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TodayIntakeSummary extends StatelessWidget {
  final double totalCalories;
  final double totalProtein;
  final double? calorieGoal;

  const _TodayIntakeSummary({
    required this.totalCalories,
    required this.totalProtein,
    this.calorieGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calorieText = calorieGoal != null
        ? '${totalCalories.toStringAsFixed(0)} / ${calorieGoal!.toStringAsFixed(0)} ${AppStrings.kcalUnit}'
        : '${totalCalories.toStringAsFixed(0)} ${AppStrings.kcalUnit}';

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            AppStrings.todayIntake,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.local_fire_department,
              size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            calorieText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.fitness_center,
              size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            '${totalProtein.toStringAsFixed(1)} ${AppStrings.gramUnit}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
