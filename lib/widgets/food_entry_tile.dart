import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/food_entry.dart';

class FoodEntryTile extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback? onDelete;

  const FoodEntryTile({
    super.key,
    required this.entry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.restaurant),
      ),
      title: Text(entry.name),
      subtitle: Text(
        '${entry.calories.toStringAsFixed(0)} ${AppStrings.kcalUnit} / '
        '${entry.protein.toStringAsFixed(1)} ${AppStrings.gramUnit}',
      ),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            )
          : null,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
