import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeeklyChart extends StatelessWidget {
  static const List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
  final List<int> totalTodos;
  final List<int> completedTodos;

  const WeeklyChart({
    super.key,
    required this.totalTodos,
    required this.completedTodos,
  });

  bool isAllZero(List<int> list) => list.every((e) => e == 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (totalTodos.isEmpty || isAllZero(totalTodos))
              ? Column(
                children: [
                  Lottie.asset('assets/lottie/empty.json'),
                  Center(child: Text('어! 주간 할일 목록이 텅~')),
                ],
              )
              : Expanded(
                child: Stack(
                  children: [
                    BarChart(
                      BarChartData(
                        maxY:
                            [
                              ...totalTodos,
                              ...completedTodos,
                            ].reduce((a, b) => a > b ? a : b).toDouble() +
                            5,
                        barGroups: List.generate(7, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: totalTodos[i].toDouble(),
                                color: const Color.fromARGB(255, 201, 225, 152),
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              BarChartRodData(
                                toY: completedTodos[i].toDouble(),
                                color: Colors.blue,
                                width: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int idx = value.toInt();
                                if (idx < 0 || idx > 6) return Container();
                                return Text(weekDays[idx]);
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                    // 오른쪽 위에 범례
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          _LegendDot(color: Color.fromARGB(255, 201, 225, 152)),
                          const SizedBox(width: 4),
                          const Text('전체'),
                          const SizedBox(width: 12),
                          _LegendDot(color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text('완료'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// 범례용 작은 원 위젯
class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
