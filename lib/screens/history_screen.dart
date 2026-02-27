import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/app_strings.dart';
import '../models/daily_record.dart';
import '../providers/diet_provider.dart';
import '../widgets/daily_record_tile.dart';
import 'day_detail_screen.dart';

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

    if (record == null) {
      return Center(
        child: Text(
          AppStrings.noRecordForDay,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      children: [
        DailyRecordTile(
          record: record,
          onTap: () => _openDayDetail(context, record),
        ),
      ],
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
