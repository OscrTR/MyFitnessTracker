import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../models/history_run_location.dart';

class PaceChart extends StatelessWidget {
  final List<RunLocation> locations;

  const PaceChart({super.key, required this.locations});

  String _formatDate(int date) {
    final formattedDate = DateTime.fromMillisecondsSinceEpoch(date);
    return '${formattedDate.hour}:${formattedDate.minute.toString().padLeft(2, '0')}:${formattedDate.second.toString().padLeft(2, '0')}';
  }

  List<FlSpot> _applyMovingAverage(List<FlSpot> spots, {int windowSize = 5}) {
    if (spots.isEmpty) return [];
    final List<FlSpot> smoothed = [];

    for (int i = 0; i < spots.length; i++) {
      // Déterminer le début et la fin de la fenêtre
      final int start = (i - (windowSize ~/ 2)).clamp(0, spots.length - 1);
      final int end = (i + (windowSize ~/ 2)).clamp(0, spots.length - 1);

      double sumY = 0;
      int count = 0;
      for (int j = start; j <= end; j++) {
        sumY += spots[j].y;
        count++;
      }
      // Conserver l'abscisse d'origine, et calculer la moyenne des ordonnées
      smoothed.add(FlSpot(spots[i].x, sumY / count));
    }

    return smoothed;
  }

  @override
  Widget build(BuildContext context) {
    const double minSpeed = 0.5;
    const double maxSpeed = 10.0;

    // Filtrer les valeurs aberrantes de vitesse
    final filteredLocations = locations
        .where((loc) => loc.speed >= minSpeed && loc.speed <= maxSpeed)
        .toList();

    // Créer les spots bruts à partir des locations filtrées
    final List<FlSpot> rawSpots = filteredLocations.map((loc) {
      // Calcul du pace en minutes par km (en supposant une vitesse en m/s)
      final double pace = loc.speed > 0 ? 1000 / loc.speed / 60 : 0;
      return FlSpot(loc.date.toDouble(), pace);
    }).toList();

    // Appliquer le lissage via une moyenne mobile
    final List<FlSpot> smoothedSpots =
        _applyMovingAverage(rawSpots, windowSize: 5);

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
              spots: smoothedSpots,
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
                  final location = filteredLocations[index];
                  final date = _formatDate(location.date);
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
