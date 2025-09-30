import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartCard extends StatelessWidget {
  final List<double> values; // [95, 75, 80, ...]
  final List<String> months; // ["Ene", "Feb", ...]

  const LineChartCard({
    super.key,
    required this.values,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Año 2025", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.6,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Text(months[index], style: const TextStyle(fontSize: 10));
                          }
                          return const SizedBox.shrink();
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.black,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) {
                          final percent = spot.y.toInt();
                          Color color;
                          if (percent >= 90) {
                            color = Colors.red;
                          } else if (percent >= 80) {
                            color = Colors.pink;
                          } else {
                            color = Colors.yellow[700]!;
                          }

                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: Colors.black,
                          );
                        },
                      ),
                      spots: List.generate(values.length,
                              (index) => FlSpot(index.toDouble(), values[index])),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    getTouchedSpotIndicator: (_, spots) {
                      return spots.map((e) {
                        return TouchedSpotIndicatorData(
                          FlLine(color: Colors.transparent),
                          FlDotData(show: false),
                        );
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final y = spot.y.toInt();
                          final style = TextStyle(
                            color: y >= 90
                                ? Colors.red
                                : y >= 80
                                ? Colors.pink
                                : Colors.yellow[700],
                            fontWeight: FontWeight.bold,
                          );
                          return LineTooltipItem("$y%", style);
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
