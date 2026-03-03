import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/favorite_entry.dart';

class FavoriteEntryTile extends StatelessWidget {
  final FavoriteEntry entry;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const FavoriteEntryTile({
    super.key,
    required this.entry,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(Icons.star, color: Colors.amber),
      title: Text(entry.name),
      subtitle: Text(
        '${entry.calories.toStringAsFixed(0)} ${AppStrings.kcalUnit}  ·  '
        '${entry.protein.toStringAsFixed(1)} ${AppStrings.gramUnit}',
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: AppStrings.delete,
        onPressed: onDelete,
      ),
      onTap: onAdd,
    );
  }
}
