import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatelessWidget {
  final Map<DateTime, int> completedPerDay;

  const ChartPage({super.key, required this.completedPerDay});

  @override
  Widget build(BuildContext context) {
    // 날짜 오름차순 정렬
    final sortedDates = completedPerDay.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (completedPerDay.values.isEmpty
                  ? 1
                  : completedPerDay.values.reduce((a, b) => a > b ? a : b) + 1)
              .toDouble(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = sortedDates[group.x.toInt()];
                return BarTooltipItem(
                  '${DateFormat('MM/dd').format(date)}\n완료: ${rod.toY.toInt()}개',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          gridData: FlGridData(show: false), // 점선 제거
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < sortedDates.length) {
                    final date = sortedDates[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          barGroups: List.generate(sortedDates.length, (index) {
            final date = sortedDates[index];
            final count = completedPerDay[date] ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(4),
                  width: 16,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
