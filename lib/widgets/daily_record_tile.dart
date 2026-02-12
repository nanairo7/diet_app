import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_strings.dart';
import '../models/daily_record.dart';

class DailyRecordTile extends StatelessWidget {
  final DailyRecord record;
  final VoidCallback onTap;

  const DailyRecordTile({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(record.dateKey);
    final formattedDate = DateFormat.yMMMEd('ja').format(date);

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          '${date.day}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(formattedDate),
      subtitle: Text(
        '${record.totalCalories.toStringAsFixed(0)} ${AppStrings.kcalUnit} / '
        '${record.totalProtein.toStringAsFixed(1)} ${AppStrings.gramUnit}'
        ' (${record.entryCount}${AppStrings.entryUnit})',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
