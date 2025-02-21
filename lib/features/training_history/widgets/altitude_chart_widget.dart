import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../models/history_run_location.dart';

class AltitudeChart extends StatelessWidget {
  final List<RunLocation> locations;

  const AltitudeChart({super.key, required this.locations});

  String _formatAltitude(double altitude) {
    return '${altitude.toStringAsFixed(1)}m';
  }

  String _formatDate(int date) {
    final formattedDate = DateTime.fromMillisecondsSinceEpoch(date);
    return '${formattedDate.hour}:${formattedDate.minute.toString().padLeft(2, '0')}:${formattedDate.second.toString().padLeft(2, '0')}';
  }

  double _calculateInterval(double min, double max) {
    final double range = max - min;
    final double rawInterval = range / 10; // Pour avoir max 11 valeurs

    // Arrondir à un nombre plus lisible
    final double magnitude =
        math.pow(10, (math.log(rawInterval) / math.ln10).floor()).toDouble();
    final intervals = [1, 2, 5, 10];

    return intervals
        .map((i) => i * magnitude)
        .firstWhere((i) => i >= rawInterval);
  }

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) return const SizedBox();

    final startAltitude = locations.first.altitude;
    final altitudeChanges =
        locations.map((loc) => loc.altitude - startAltitude).toList();
    final minAltitude = altitudeChanges.reduce((min, e) => e < min ? e : min);
    final maxAltitude = altitudeChanges.reduce((max, e) => e > max ? e : max);

    final interval = _calculateInterval(minAltitude != 0 ? minAltitude : -10,
        maxAltitude != 0 ? maxAltitude : 10);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.floralWhite,
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 14, left: 0, right: 20),
      child: LineChart(
        LineChartData(
          minY: minAltitude != 0 ? minAltitude : -10,
          maxY: maxAltitude != 0 ? maxAltitude : 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: interval,
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
                interval: interval,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  final formattedValue = value >= 0
                      ? '+${value.toInt()}'
                      : value.toInt().toString();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 8),
                      Center(
                        child: Text(
                          formattedValue,
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
              spots: locations.asMap().entries.map((entry) {
                return FlSpot(
                    entry.key.toDouble(), entry.value.altitude - startAltitude);
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
                  final difference = touchedSpot.y;
                  final formattedDifference = difference >= 0
                      ? '+${_formatAltitude(difference)}'
                      : _formatAltitude(difference);

                  final index = touchedSpot.spotIndex;
                  final location = locations[index];
                  final date = _formatDate(location.date);

                  return LineTooltipItem(
                    'Pace: $formattedDifference\nTime: $date',
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
