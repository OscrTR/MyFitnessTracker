import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../models/history_run_location.dart';

class AltitudeChart extends StatelessWidget {
  final List<RunLocation> locations;

  const AltitudeChart({super.key, required this.locations});

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  double _calculateInterval(double min, double max) {
    if (min == 0 && max == 0) return 1;

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
    // Application du filtre de Kalman
    List<RunLocation> kalmanFilteredData =
        RunLocation.applyKalmanFilter(locations);
    final altitudeMap = aggregateAltitudesByMinute(kalmanFilteredData);

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
    final double maxAltitude =
        altitudes.length > 1 ? altitudes.reduce(math.max) : 0;
    final double minAltitude =
        altitudes.length > 1 ? altitudes.reduce(math.min).floorToDouble() : 0;

    final interval = _calculateInterval(minAltitude, maxAltitude);

    double adjustedMin = (minAltitude / interval).floor() * interval;
    double adjustedMax = (maxAltitude / interval).ceil() * interval;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.floralWhite,
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 14, left: 0, right: 20),
      child: LineChart(
        LineChartData(
          minY: adjustedMin,
          maxY: adjustedMax,
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
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 60,
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
                  final date = _formatDate(altitudeMap.keys.toList()[index]);

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
