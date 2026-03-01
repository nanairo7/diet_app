import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../providers/diet_provider.dart';
import '../widgets/calorie_arc_gauge.dart';
import '../widgets/food_entry_tile.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? AppStrings.todayCalories : AppStrings.history,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppStrings.settings,
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildTodayView() : const HistoryScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: AppStrings.today,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: AppStrings.history,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final record = provider.todayRecord;

        return Column(
          children: [
            // 円弧ゲージ
            CalorieArcGauge(
              currentCalories: record.totalCalories,
              goalCalories: provider.calorieGoal,
              date: DateTime.now(),
            ),
            // 食事エントリ一覧
            Expanded(
              child: record.entries.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.noEntries,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: record.entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = record.entries[index];
                        return FoodEntryTile(
                          entry: entry,
                          onDelete: () => provider.deleteEntry(entry.id),
                        );
                      },
                    ),
            ),
            // インライン入力フォーム
            _InlineEntryForm(
              onOpenFavorites: () => _openFavorites(context),
            ),
          ],
        );
      },
    );
  }

  void _openFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}

class _InlineEntryForm extends StatefulWidget {
  final VoidCallback onOpenFavorites;

  const _InlineEntryForm({required this.onOpenFavorites});

  @override
  State<_InlineEntryForm> createState() => _InlineEntryFormState();
}

class _InlineEntryFormState extends State<_InlineEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  bool _addToFavorites = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 名前フィールド
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.foodName,
                prefixIcon: Icon(Icons.restaurant),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // カロリー・タンパク質フィールド（横並び）
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.calories,
                      prefixIcon: Icon(Icons.local_fire_department),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      final num = double.tryParse(value.trim());
                      if (num == null || num < 0) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.protein,
                      prefixIcon: Icon(Icons.fitness_center),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      final num = double.tryParse(value.trim());
                      if (num == null || num < 0) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 追加ボタン + お気に入りアイコン
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text(AppStrings.addCalorieButton),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () =>
                      setState(() => _addToFavorites = !_addToFavorites),
                  icon: Icon(
                    _addToFavorites ? Icons.star : Icons.star_outline,
                    color: _addToFavorites ? Colors.amber : null,
                  ),
                  tooltip: AppStrings.addToFavorites,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // お気に入りから追加ボタン
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onOpenFavorites,
                child: const Text(AppStrings.addFromFavoritesButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final calories = double.parse(_caloriesController.text.trim());
    final protein = double.parse(_proteinController.text.trim());
    final provider = context.read<DietProvider>();

    final savedToFavorites = _addToFavorites;

    await provider.addEntry(
      name: name,
      calories: calories,
      protein: protein,
    );

    if (savedToFavorites) {
      await provider.addFavorite(
        name: name,
        calories: calories,
        protein: protein,
      );
    }

    if (!mounted) return;

    _nameController.clear();
    _caloriesController.clear();
    _proteinController.clear();
    setState(() => _addToFavorites = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedToFavorites
              ? '${AppStrings.added}・${AppStrings.favoriteAdded}'
              : AppStrings.added,
        ),
      ),
    );
  }
}
