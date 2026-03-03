import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/app_strings.dart';
import '../models/daily_record.dart';
import '../providers/diet_provider.dart';
import '../widgets/daily_record_tile.dart';
import '../widgets/food_entry_tile.dart';
import '../widgets/summary_card.dart';
import 'day_detail_screen.dart';

// ─── 食事追加ボトムシート ───────────────────────────────────────────

class _AddEntrySheet extends StatefulWidget {
  final String dateKey;

  const _AddEntrySheet({required this.dateKey});

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
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
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text(AppStrings.addButton),
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
    final savedToFavorites = _addToFavorites;
    final provider = context.read<DietProvider>();

    await provider.addEntryForDate(
      dateKey: widget.dateKey,
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
    Navigator.pop(context);
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  /// dateKey ("YYYY-MM-DD") を持つ日付セットを返す
  Set<DateTime> _buildRecordedDays(List<String> allDates) {
    return allDates.map((key) => DateTime.parse(key)).toSet();
  }

  /// 指定日に記録があるか判定する
  bool _hasRecord(Set<DateTime> recordedDays, DateTime day) {
    return recordedDays.any((d) => isSameDay(d, day));
  }

  String _toDateKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _openDayDetail(BuildContext context, DailyRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DayDetailScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        final recordedDays = _buildRecordedDays(provider.allDates);
        final theme = Theme.of(context);

        return Column(
          children: [
            _buildCalendar(theme, recordedDays),
            const Divider(height: 1),
            Expanded(
              child: _buildDayContent(context, provider, recordedDays),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar(ThemeData theme, Set<DateTime> recordedDays) {
    return TableCalendar(
      // 表示範囲: 5年前〜今日まで
      firstDay: DateTime(DateTime.now().year - 5, 1, 1),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      locale: 'ja_JP',

      // 表示形式（月・2週間・週の切り替えを有効化）
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: AppStrings.calendarView,
      },
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },

      // 月またぎナビゲーション
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },

      // 選択日
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,

      // 記録がある日にマーカーを表示するためにeventLoaderを使用
      eventLoader: (day) =>
          _hasRecord(recordedDays, day) ? [true] : [],

      // ヘッダースタイル（年月を中央表示）
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMMM(locale).format(date),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Theme.of(context).colorScheme.primary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),

      // カレンダースタイル
      calendarStyle: CalendarStyle(
        // 選択日
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        // 今日
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
        // 記録ありマーカー（緑の点）
        markerDecoration: BoxDecoration(
          color: Colors.green.shade600,
          shape: BoxShape.circle,
        ),
        markerSize: 6,
        markersMaxCount: 1,
        markerMargin: const EdgeInsets.only(top: 2),
        // 当月以外の日を薄く表示
        outsideDaysVisible: true,
        outsideTextStyle: TextStyle(color: theme.colorScheme.outline),
      ),
    );
  }

  Widget _buildDayContent(
    BuildContext context,
    DietProvider provider,
    Set<DateTime> recordedDays,
  ) {
    // 日付未選択時: 全記録のリスト表示
    if (_selectedDay == null) {
      return _buildAllRecordsList(context, provider);
    }

    // 選択日に記録があれば詳細、なければ「記録なし」メッセージ
    final dateKey = _toDateKey(_selectedDay!);
    final record = provider.getRecordForDate(dateKey);

    return Column(
      children: [
        Expanded(
          child: (record == null || record.entries.isEmpty)
              ? Center(
                  child: Text(
                    AppStrings.noRecordForDay,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: record.entries.length + 1,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SummaryCard(
                        totalCalories: record.totalCalories,
                        totalProtein: record.totalProtein,
                        entryCount: record.entryCount,
                      );
                    }
                    return FoodEntryTile(
                      entry: record.entries[index - 1],
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _openAddEntrySheet(context, dateKey),
              child: const Text(AppStrings.addFood),
            ),
          ),
        ),
      ],
    );
  }

  void _openAddEntrySheet(BuildContext context, String dateKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddEntrySheet(dateKey: dateKey),
    );
  }

  Widget _buildAllRecordsList(BuildContext context, DietProvider provider) {
    final dates = provider.allDates;

    if (dates.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noRecords,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: dates.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final dateKey = dates[index];
        final record = provider.getRecordForDate(dateKey);
        if (record == null) return const SizedBox.shrink();

        return DailyRecordTile(
          record: record,
          onTap: () => _openDayDetail(context, record),
        );
      },
    );
  }
}
