// lib/Data/chart_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatelessWidget {
  final Map<DateTime, int> completedPerDay;

  const ChartPage({super.key, required this.completedPerDay});

  @override
  Widget build(BuildContext context) {
    final sortedDates = completedPerDay.keys.toList()..sort();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (completedPerDay.values.isEmpty
                ? 1
                : completedPerDay.values.reduce((a, b) => a > b ? a : b) + 1)
            .toDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, _) {
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
        ),
        barGroups: List.generate(sortedDates.length, (index) {
          final date = sortedDates[index];
          final count = completedPerDay[date] ?? 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: count.toDouble(), color: Colors.deepPurple),
            ],
          );
        }),
      ),
    );
  }
}
