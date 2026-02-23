import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/daily_record.dart';
import '../widgets/food_entry_tile.dart';
import '../widgets/summary_card.dart';

class DayDetailScreen extends StatelessWidget {
  final DailyRecord record;

  const DayDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(record.dateKey);
    final formattedDate = DateFormat.yMMMEd('ja').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SummaryCard(
                totalCalories: record.totalCalories,
                totalProtein: record.totalProtein,
                entryCount: record.entryCount,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: record.entryCount,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return FoodEntryTile(entry: record.entries[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
