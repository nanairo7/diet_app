import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../models/daily_record.dart';
import '../providers/diet_provider.dart';

/// 週次・月次の摂取カロリー／タンパク質グラフ画面
class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

// ── 期間モード ──────────────────────────────────────────────────────────
enum _Period { weekly, monthly }

// ── 指標モード ──────────────────────────────────────────────────────────
enum _Metric { calories, protein }

class _GraphScreenState extends State<GraphScreen> {
  _Period _period = _Period.weekly;
  _Metric _metric = _Metric.calories;

  /// 0 = 今週／今月、-1 = 前の週／月、-2 = さらに前…
  int _offset = 0;

  // ── 表示対象の日付リストを返す ────────────────────────────────────────
  List<DateTime> _buildDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_period == _Period.weekly) {
      // offset 0: today-6 〜 today
      // offset -1: today-13 〜 today-7  …
      final end = DateTime(today.year, today.month, today.day + 7 * _offset);
      final start = DateTime(end.year, end.month, end.day - 6);
      return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
    } else {
      // offset 0: 今月1日〜今日
      // offset -1: 先月1日〜先月末日  …
      final base = DateTime(today.year, today.month + _offset, 1);
      final isCurrentMonth = _offset == 0;
      final lastDay = isCurrentMonth
          ? today
          : DateTime(base.year, base.month + 1, 0); // 月末日
      final days = lastDay.day;
      return List.generate(days, (i) => DateTime(base.year, base.month, i + 1));
    }
  }

  // ── 期間ラベル（ナビゲーション行に表示） ─────────────────────────────
  String _periodLabel(List<DateTime> dates) {
    if (_period == _Period.weekly) {
      final s = DateFormat('M/d', 'ja').format(dates.first);
      final e = DateFormat('M/d', 'ja').format(dates.last);
      return '$s 〜 $e';
    } else {
      return DateFormat('yyyy年M月', 'ja').format(dates.first);
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _getValue(DailyRecord? record) {
    if (record == null) return 0;
    return _metric == _Metric.calories
        ? record.totalCalories
        : record.totalProtein;
  }

  Color get _barColor => _metric == _Metric.calories
      ? Colors.orange.shade600
      : Colors.teal.shade400;

  Color get _barColorLight => _metric == _Metric.calories
      ? Colors.orange.shade200
      : Colors.teal.shade100;

  // ── X 軸ラベル ────────────────────────────────────────────────────────
  String _xLabel(DateTime d) {
    if (_period == _Period.weekly) {
      return DateFormat('E', 'ja').format(d); // 月・火・水…
    } else {
      // 月次: 5日刻みで表示（1, 5, 10, 15, 20, 25, 末日）
      if (d.day == 1 ||
          d.day % 5 == 0 ||
          d.day == DateUtils.getDaysInMonth(d.year, d.month)) {
        return '${d.day}';
      }
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        final dates = _buildDateRange();
        final records = dates
            .map((d) => provider.getRecordForDate(_dateKey(d)))
            .toList();
        final values = records.map(_getValue).toList();

        final maxValue =
            values.fold<double>(0, (m, v) => v > m ? v : m);
        final hasData = values.any((v) => v > 0);

        return Column(
          children: [
            _buildControls(context),
            _buildPeriodNav(dates),
            if (hasData) _buildSummaryRow(values),
            Expanded(
              child: hasData
                  ? _buildChart(dates, values, maxValue)
                  : _buildEmpty(),
            ),
          ],
        );
      },
    );
  }

  // ── 期間・指標トグル ──────────────────────────────────────────────────
  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // 期間
          SegmentedButton<_Period>(
            segments: const [
              ButtonSegment(
                value: _Period.weekly,
                label: Text(AppStrings.graphWeekly),
              ),
              ButtonSegment(
                value: _Period.monthly,
                label: Text(AppStrings.graphMonthly),
              ),
            ],
            selected: {_period},
            onSelectionChanged: (s) =>
                setState(() {
                  _period = s.first;
                  _offset = 0; // 期間切り替え時はリセット
                }),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const Spacer(),
          // 指標
          SegmentedButton<_Metric>(
            segments: [
              ButtonSegment(
                value: _Metric.calories,
                icon: Icon(Icons.local_fire_department,
                    color: _metric == _Metric.calories
                        ? theme.colorScheme.onSecondaryContainer
                        : null),
                label: const Text(AppStrings.graphCalories),
              ),
              ButtonSegment(
                value: _Metric.protein,
                icon: Icon(Icons.fitness_center,
                    color: _metric == _Metric.protein
                        ? theme.colorScheme.onSecondaryContainer
                        : null),
                label: const Text(AppStrings.graphProtein),
              ),
            ],
            selected: {_metric},
            onSelectionChanged: (s) =>
                setState(() => _metric = s.first),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ── 期間ナビゲーション行（< ラベル >） ────────────────────────────────
  Widget _buildPeriodNav(List<DateTime> dates) {
    final isLatest = _offset == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _offset--),
            tooltip: AppStrings.graphPrev,
          ),
          SizedBox(
            width: 160,
            child: Text(
              _periodLabel(dates),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isLatest ? Colors.grey.shade300 : null,
            ),
            onPressed: isLatest ? null : () => setState(() => _offset++),
            tooltip: isLatest ? null : AppStrings.graphNext,
          ),
        ],
      ),
    );
  }

  // ── サマリー行（平均・最大・合計） ─────────────────────────────────────
  Widget _buildSummaryRow(List<double> values) {
    final activeDays = values.where((v) => v > 0).length;
    final total = values.fold<double>(0, (s, v) => s + v);
    final avg = activeDays > 0 ? total / activeDays : 0.0;
    final maxV = values.fold<double>(0, (m, v) => v > m ? v : m);
    final unit =
        _metric == _Metric.calories ? AppStrings.kcalUnit : AppStrings.gramUnit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _summaryChip(AppStrings.graphAvg, avg, unit),
          const SizedBox(width: 8),
          _summaryChip(AppStrings.graphMax, maxV, unit),
          const SizedBox(width: 8),
          _summaryChip(AppStrings.graphTotal, total, unit),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, double value, String unit) {
    final isCalories = _metric == _Metric.calories;
    final displayValue = isCalories
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: _barColorLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(
              '$displayValue $unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _barColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── バーチャート ─────────────────────────────────────────────────────
  Widget _buildChart(
      List<DateTime> dates, List<double> values, double maxValue) {
    final isMonthly = _period == _Period.monthly;
    final barWidth = isMonthly ? 8.0 : 20.0;
    final goalY = _metric == _Metric.calories
        ? context.read<DietProvider>().calorieGoal
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: BarChart(
        BarChartData(
          maxY: _calcMaxY(maxValue, goalY),
          extraLinesData: goalY != null
              ? ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: goalY,
                    color: Colors.orange.shade300,
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      labelResolver: (_) =>
                          '目標 ${goalY.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ])
              : null,
          barGroups: List.generate(dates.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: values[i] > 0 ? _barColor : Colors.grey.shade200,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= dates.length) return const SizedBox();
                  final label = _xLabel(dates[i]);
                  if (label.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(label,
                        style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox();
                  return Text(value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.right);
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = dates[groupIndex];
                final dateLabel =
                    DateFormat('M/d', 'ja').format(date);
                final unit = _metric == _Metric.calories
                    ? AppStrings.kcalUnit
                    : AppStrings.gramUnit;
                final value = _metric == _Metric.calories
                    ? rod.toY.toStringAsFixed(0)
                    : rod.toY.toStringAsFixed(1);
                return BarTooltipItem(
                  '$dateLabel\n$value $unit',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _calcMaxY(double dataMax, double? goalY) {
    final candidates = [dataMax, if (goalY != null) goalY];
    final base = candidates.fold<double>(0, (m, v) => v > m ? v : m);
    if (base == 0) return 100;
    // 上に 20% の余白を取り、きりの良い数字に切り上げ
    final padded = base * 1.2;
    final step = _metric == _Metric.calories ? 100.0 : 10.0;
    return (padded / step).ceil() * step;
  }

  // ── データなし表示 ────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            AppStrings.graphNoData,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
