import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../models/daily_record.dart';
import '../providers/diet_provider.dart';
import '../widgets/daily_record_tile.dart';
import 'day_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        final dates = provider.allDates;

        if (dates.isEmpty) {
          return const Center(
            child: Text(
              AppStrings.noRecords,
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
      },
    );
  }

  void _openDayDetail(BuildContext context, DailyRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayDetailScreen(record: record),
      ),
    );
  }
}
