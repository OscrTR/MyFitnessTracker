import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../training_history/models/history_training.dart';
import 'dart:math' as math;

import '../../../app_colors.dart';

class TrainingDurationChart extends StatelessWidget {
  final List<HistoryTraining> historyTrainings;
  final DateTime startDate;
  final DateTime endDate;

  const TrainingDurationChart({
    super.key,
    required this.historyTrainings,
    required this.startDate,
    required this.endDate,
  });

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

  /// Vérifie si deux dates représentent le même jour
  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// Retourne une liste de dates (sans heure) entre [start] et [end] inclus
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    final List<DateTime> dates = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    final DateTime last = DateTime(end.year, end.month, end.day);
    while (!current.isAfter(last)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Renvoie une couleur à utiliser pour l'entraînement d'indice [index]
  Color _colorForIndex(int index) {
    const availableColors = [
      AppColors.folly,
      AppColors.licorice,
    ];

    return availableColors[index % availableColors.length];
  }

  /// Convertit la durée (en secondes) en minutes (valeur double)
  double _durationInMinutes(int durationSec) => durationSec / 60.0;

  /// Calcule la valeur maximale de l’axe Y (en minutes) parmi tous les jours
  double _calculateMaxY(Map<DateTime, double> dailyTotals) {
    if (dailyTotals.isEmpty) return 20;
    final maxVal = dailyTotals.values.reduce((a, b) => a > b ? a : b);
    final calculatedMax = (maxVal + 1).floorToDouble();
    return calculatedMax < 20
        ? 20
        : calculatedMax; // Toujours retourner au moins 20
  }

  @override
  Widget build(BuildContext context) {
    // 1. Récupérer la liste de tous les jours dans l'intervalle.
    final allDates = getDatesInRange(startDate, endDate);

    // Définir la largeur des barres en fonction du nombre de dates
    final double rodWidth = allDates.length > 15 ? 8.0 : 20.0;

    // 2. Grouper les entraînements par date (en comparant juste le jour)
    Map<DateTime, List<HistoryTraining>> trainingsByDate = {};
    for (DateTime day in allDates) {
      trainingsByDate[day] =
          historyTrainings.where((ht) => isSameDay(ht.date, day)).toList();
    }

    // 3. Construire les BarChartGroupData pour chaque jour.
    // Simultanément, on calcule la somme totale des durées par jour (en minutes) pour fixer l'échelle Y.
    Map<DateTime, double> dailyTotals = {};
    List<BarChartGroupData> barGroups = [];

    for (int index = 0; index < allDates.length; index++) {
      final day = allDates[index];
      final trainingsOfDay = trainingsByDate[day] ?? [];

      double cumulative = 0.0;
      List<BarChartRodStackItem> stackItems = [];

      // Pour chaque entraînement de cette journée, créer un segment de barre.
      for (int i = 0; i < trainingsOfDay.length; i++) {
        final training = trainingsOfDay[i];
        final double durationMin = _durationInMinutes(training.duration);
        // Ajouter un segment : de cumulative à cumulative + duration
        stackItems.add(BarChartRodStackItem(
            cumulative, cumulative + durationMin, _colorForIndex(i)));
        cumulative += durationMin;
      }

      dailyTotals[day] = cumulative;

      // En cas de journée sans entraînement, cumulative vaut 0.
      // On peut choisir d'afficher une barre très fine (ou rien) pour visualiser le jour.
      final rod = BarChartRodData(
        toY: cumulative,
        color: AppColors.licorice,
        rodStackItems: stackItems,
        width: rodWidth,
        borderRadius: BorderRadius.circular(4),
      );

      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [rod],
        ),
      );
    }

    // Définir l'échelle Y en fonction des durées maximales
    final maxY = _calculateMaxY(dailyTotals);
    final interval = _calculateInterval(0, maxY);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: AppColors.floralWhite,
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 14, left: 0, right: 20),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: barGroups,
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
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
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= allDates.length) {
                    return const SizedBox.shrink();
                  }
                  // Si le nombre de dates est > 15, n'afficher qu'un jour sur deux
                  if (allDates.length > 15 && index % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  final day = allDates[index];
                  final dateStr = '${day.day}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dateStr,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: AppColors.timberwolf, width: 1),
              left: BorderSide(color: AppColors.timberwolf, width: 1),
              top: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (touchedSpot) {
                return AppColors.licorice;
              },
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = allDates[group.x.toInt()];
                final trainingsOfDay = trainingsByDate[day]!;
                // Si pas d'entraînement, afficher simplement le jour
                if (trainingsOfDay.isEmpty) {
                  return BarTooltipItem(
                    'Aucun entraînement\n${day.day}/${day.month}/${day.year}',
                    const TextStyle(color: Colors.white),
                  );
                }
                // Sinon, lister les durées de chaque entraînement
                String tooltip = '';
                double cumulative = 0.0;
                for (int i = 0; i < trainingsOfDay.length; i++) {
                  final training = trainingsOfDay[i];
                  final durationMin = _durationInMinutes(training.duration);
                  tooltip +=
                      'Entraînement ${i + 1}: ${durationMin.toStringAsFixed(1)} min\n';
                  cumulative += durationMin;
                }
                tooltip += 'Total: ${cumulative.toStringAsFixed(1)} min';
                return BarTooltipItem(
                  tooltip,
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
