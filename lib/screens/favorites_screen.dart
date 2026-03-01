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

          if (favorites.isEmpty) {
            return const Center(
              child: Text(AppStrings.favoritesEmpty),
            );
          }

          return ListView.separated(
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
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${entry.name} ${AppStrings.added}')),
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
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(AppStrings.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(AppStrings.delete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  await provider.removeFavorite(entry.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.favoriteDeleted)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
