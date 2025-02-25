import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/features/training_history/models/history_training.dart';
import 'package:my_fitness_tracker/features/training_management/models/training.dart';

import '../../../app_colors.dart';
import '../../../helper_functions.dart';

class TrainingDurationChart extends StatelessWidget {
  final List<HistoryTraining> trainings;
  final DateTime startDate;
  final DateTime endDate;

  const TrainingDurationChart({
    super.key,
    required this.trainings,
    required this.startDate,
    required this.endDate,
  });

  String _formatDate(int date) {
    final formattedDate = DateTime.fromMillisecondsSinceEpoch(date);
    return '${formattedDate.hour}:${formattedDate.minute.toString().padLeft(2, '0')}:${formattedDate.second.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<DateTime> generateDaysBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; startDate.add(Duration(days: i)).isBefore(endDate); i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    // Ajouter aussi le dernier jour.
    days.add(endDate);
    return days;
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dailyDates = generateDaysBetween(startDate, endDate);

    // Générer la liste des durées pour chaque jour
    List<int> minutesPerDay = [];
    for (var day in dailyDates) {
      final durationToAdd = trainings
          .where((t) => isSameDay(t.date, day))
          .map((t) => t.duration)
          .fold(0, (sum, duration) => sum + duration);
      minutesPerDay.add(durationToAdd);
    }

    List<BarChartGroupData> barGroups = dailyDates.asMap().entries.map((entry) {
      int index = entry.key; // Index de la date
      DateTime day = entry.value; // Date actuelle
      int minutes = minutesPerDay[index]; // Minutes correspondantes
      return BarChartGroupData(
        x: index, // L'index affecté à chaque barre
        barRods: [
          BarChartRodData(
            toY: minutes.toDouble(), // Valeur sur l'axe Y
            color: Colors.blue,
            width: 15.0,
          ),
        ],
      );
    }).toList();

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.floralWhite,
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 14, left: 0, right: 20),
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.center,
        barGroups: barGroups,
      )),
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
