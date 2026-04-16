import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../models/daily_record.dart';
import '../providers/diet_provider.dart';
import '../widgets/food_entry_tile.dart';
import '../widgets/keyboard_dismissible.dart';
import '../widgets/summary_card.dart';

class DayDetailScreen extends StatelessWidget {
  final DailyRecord record;

  const DayDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(record.dateKey);
    final formattedDate = DateFormat.yMMMEd('ja').format(date);
    final dateKey = record.dateKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEntrySheet(context, dateKey),
        tooltip: AppStrings.addFood,
        child: const Icon(Icons.add),
      ),
      body: KeyboardDismissible(
        child: Consumer<DietProvider>(
        builder: (context, provider, _) {
          // 最新データを provider から取得（追加後に即時反映）
          final liveRecord = provider.getRecordForDate(dateKey) ?? record;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  SummaryCard(
                    totalCalories: liveRecord.totalCalories,
                    totalProtein: liveRecord.totalProtein,
                    entryCount: liveRecord.entryCount,
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: liveRecord.entryCount,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return FoodEntryTile(
                            entry: liveRecord.entries[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  void _openAddEntrySheet(BuildContext context, String dateKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddEntryBottomSheet(dateKey: dateKey),
    );
  }
}

// ─── 食事追加ボトムシート ───────────────────────────────────────────

class _AddEntryBottomSheet extends StatefulWidget {
  final String dateKey;

  const _AddEntryBottomSheet({required this.dateKey});

  @override
  State<_AddEntryBottomSheet> createState() => _AddEntryBottomSheetState();
}

class _AddEntryBottomSheetState extends State<_AddEntryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.addFood,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.foodName,
                prefixIcon: Icon(Icons.restaurant),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
              autofocus: true,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? AppStrings.required : null,
            ),
            const SizedBox(height: 8),
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 0) return AppStrings.invalidNumber;
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
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 0) return AppStrings.invalidNumber;
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: const Text(AppStrings.addButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DietProvider>();
    await provider.addEntryForDate(
      dateKey: widget.dateKey,
      name: _nameController.text.trim(),
      calories: double.parse(_caloriesController.text.trim()),
      protein: double.parse(_proteinController.text.trim()),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }
}
