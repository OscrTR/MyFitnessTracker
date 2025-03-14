import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../models/history_run_location.dart';

class PaceChart extends StatelessWidget {
  final List<RunLocation> locations;

  const PaceChart({super.key, required this.locations});

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<DateTime, double> aggregatePacesByMinute(List<RunLocation> locations) {
    if (locations.isEmpty) return {};

    final Map<DateTime, List<double>> groupedPaces = {};

    for (final loc in locations) {
      // Convertir le timestamp en DateTime
      final timestamp = DateTime.fromMillisecondsSinceEpoch(loc.date);
      // Conserver uniquement l'année, le mois, le jour, l'heure et la minute
      final key = DateTime(timestamp.year, timestamp.month, timestamp.day,
          timestamp.hour, timestamp.minute);

      groupedPaces.putIfAbsent(key, () => []).add(loc.pace);
    }

    // Calculer la moyenne pour chaque minute et retourner la map
    final Map<DateTime, double> aggregated = {};
    groupedPaces.forEach((minute, paces) {
      final double avgPace = paces.reduce((a, b) => a + b) / paces.length;
      aggregated[minute] = avgPace;
    });

    return aggregated;
  }

  @override
  Widget build(BuildContext context) {
    final filteredData =
        locations.where((e) => e.pace > 0 && e.pace <= 10).toList();

    List<RunLocation> kalmanFilteredData =
        RunLocation.applyKalmanFilter(filteredData);
    final paceMap = aggregatePacesByMinute(kalmanFilteredData);

    final sortedKeys = paceMap.keys.toList()..sort();

    final List<double> paces = [];
    final List<FlSpot> spots = [];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final pace = paceMap[key]!;
      paces.add(pace);
      spots.add(FlSpot(i.toDouble(), pace));
    }

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
              spots: spots.isNotEmpty ? spots : [FlSpot(0, 0)],
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
                  final date = _formatDate(paceMap.keys.toList()[index]);
                  final int minutes = touchedSpot.y.floor();
                  final int seconds = ((touchedSpot.y - minutes) * 60).round();

                  // Formater les secondes pour toujours afficher deux chiffres.
                  final String secondsStr = seconds.toString().padLeft(2, '0');
                  final pace = '$minutes:$secondsStr/km';

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
