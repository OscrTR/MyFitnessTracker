import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../../../helper_functions.dart';
import '../models/history_run_location.dart';

class PaceChart extends StatelessWidget {
  final List<RunLocation> locations;

  const PaceChart({super.key, required this.locations});

  String _formatDate(int date) {
    final formattedDate = DateTime.fromMillisecondsSinceEpoch(date);
    return '${formattedDate.hour}:${formattedDate.minute.toString().padLeft(2, '0')}:${formattedDate.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.floralWhite,
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 14, left: 0, right: 20),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.platinum,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 8),
                      Center(
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  );
                },
              ),
            ),
          ),
          borderData: _buildBorderData(),
          lineBarsData: [
            LineChartBarData(
              spots: locations.map((loc) {
                final double pace = loc.speed > 0 ? 1000 / loc.speed / 60 : 0;
                return FlSpot(loc.date.toDouble(), pace);
              }).toList(),
              isCurved: true,
              color: AppColors.folly,
              dotData: const FlDotData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            getTouchLineStart: (barData, spotIndex) => 0,
            getTouchLineEnd: (barData, spotIndex) => 0,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) {
                return AppColors.licorice;
              },
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final index = touchedSpot.spotIndex;
                  final location = locations[index];
                  final date = _formatDate(location.date);
                  final pace = formatPace(touchedSpot.y.toInt());

                  return LineTooltipItem(
                    'Pace: $pace\nTime: $date',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: const Border(
        top: BorderSide.none,
        bottom: BorderSide(color: AppColors.timberwolf, width: 1),
        left: BorderSide(color: AppColors.timberwolf, width: 1),
        right: BorderSide.none,
      ),
    );
  }
}
