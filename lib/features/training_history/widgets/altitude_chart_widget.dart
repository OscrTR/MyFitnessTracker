import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../models/history_run_location.dart';

class AltitudeChart extends StatelessWidget {
  final List<RunLocation> locations;

  const AltitudeChart({super.key, required this.locations});

  String _formatDate(int date) {
    final formattedDate = DateTime.fromMillisecondsSinceEpoch(date);
    return '${formattedDate.hour}:${formattedDate.minute.toString().padLeft(2, '0')}:${formattedDate.second.toString().padLeft(2, '0')}';
  }

  double _calculateInterval(double min, double max) {
    final double range = max - min;
    final double rawInterval = range / 5;

    final double magnitude =
        math.pow(10, (math.log(rawInterval) / math.ln10).floor()).toDouble();
    final intervals = [1, 2, 5, 10];

    return intervals
        .map((i) => i * magnitude)
        .firstWhere((i) => i >= rawInterval);
  }

  Map<DateTime, double> aggregateAltitudesByMinute(
      List<RunLocation> locations) {
    if (locations.isEmpty) return {};

    final Map<DateTime, List<double>> groupedAltitudes = {};

    for (final loc in locations) {
      // Convertir le timestamp en DateTime
      final timestamp = DateTime.fromMillisecondsSinceEpoch(loc.date);
      // Conserver uniquement l'année, le mois, le jour, l'heure et la minute
      final key = DateTime(timestamp.year, timestamp.month, timestamp.day,
          timestamp.hour, timestamp.minute);

      groupedAltitudes.putIfAbsent(key, () => []).add(loc.altitude);
    }

    // Calculer la moyenne pour chaque minute et retourner la map
    final Map<DateTime, double> aggregated = {};
    groupedAltitudes.forEach((minute, altitudes) {
      final double avgAltitude =
          altitudes.reduce((a, b) => a + b) / altitudes.length;
      aggregated[minute] = avgAltitude;
    });

    return aggregated;
  }

  @override
  Widget build(BuildContext context) {
    if (locations.length < 2) return const SizedBox();

    final altitudeMap = aggregateAltitudesByMinute(locations);

    // Trier les clés de la map par date croissante
    final sortedKeys = altitudeMap.keys.toList()..sort();

    // Extraire les altitudes et définir l'axe x avec l'index (ou avec le nombre de minutes écoulées)
    final List<double> altitudes = [];
    final List<FlSpot> spots = [];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final altitude = altitudeMap[key]!;
      altitudes.add(altitude);
      spots.add(FlSpot(i.toDouble(), altitude));
    }

    // Calcul des limites min et max pour l'axe Y
    final minAltitude = altitudes.reduce(math.min);
    final maxAltitude = altitudes.reduce(math.max);
    double minY = minAltitude.floorToDouble();
    double maxY = (maxAltitude + 1).floorToDouble();
    if (minY == maxY) {
      minY -= 10;
      maxY += 10;
    }
    final interval = _calculateInterval(minY, maxY);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.floralWhite,
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 14, left: 0, right: 20),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
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
                  final formattedValue = '${value.toInt().toString()}m';
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
              spots: spots,
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

                  return LineTooltipItem(
                    'Altitude: ${touchedSpot.y.toInt()}m\nTime: $date',
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
