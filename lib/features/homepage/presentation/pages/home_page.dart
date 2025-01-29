import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import '../../../../app_colors.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildTrainingsList(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

Widget _buildTrainingsList(BuildContext context) {
  String getDayText(WeekDay day) {
    final now = DateTime.now();
    final currentDay =
        WeekDay.values[now.weekday - 1]; // -1 car DateTime.weekday commence à 1

    if (day == currentDay) {
      return context.locale.languageCode == 'fr' ? 'Aujourd\'hui' : 'Today';
    }
    return day.translate(context.locale.languageCode);
  }

  WeekDay getNextTrainingDay(Training training) {
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;

    final sortedDays = List<WeekDay>.from(training.trainingDays!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // On cherche d'abord si le jour actuel est un jour d'entraînement
    if (sortedDays.any((day) => day.index == currentDayIndex)) {
      return sortedDays.firstWhere((day) => day.index == currentDayIndex);
    }

    // Sinon, on cherche le prochain jour d'entraînement
    return sortedDays.firstWhere(
      (day) => day.index > currentDayIndex,
      orElse: () => sortedDays
          .first, // Premier jour de la semaine suivante si aucun jour trouvé
    );
  }

  return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
    if (state is TrainingManagementLoaded) {
      final plannedTrainings = state.trainings
          .where((t) => t.trainingDays?.isNotEmpty ?? false)
          .toList()
        ..sort((a, b) {
          final now = DateTime.now();
          final currentDayIndex = now.weekday - 1;

          int getNextDayIndex(Training t) {
            final days = t.trainingDays!
              ..sort((x, y) => x.index.compareTo(y.index));
            final todayIndex =
                days.indexWhere((d) => d.index == currentDayIndex);
            if (todayIndex != -1) return currentDayIndex;
            final nextDay = days.firstWhere((d) => d.index > currentDayIndex,
                orElse: () => days.first);
            return nextDay.index;
          }

          final nextA = getNextDayIndex(a);
          final nextB = getNextDayIndex(b);

          int daysUntil(int nextDay) => nextDay < currentDayIndex
              ? (7 - currentDayIndex) + nextDay
              : nextDay - currentDayIndex;

          return daysUntil(nextA).compareTo(daysUntil(nextB));
        });

      if (plannedTrainings.isEmpty) {
        return Container(
          margin: const EdgeInsets.only(left: 20),
          width: MediaQuery.of(context).size.width - 40,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.floralWhite,
              border: Border.all(color: AppColors.parchment),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('home_page_first_training_title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 3),
              Text(
                tr('home_page_first_training_description'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.taupeGray),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => GoRouter.of(context).push('/training_detail'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                          color: AppColors.folly,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            tr('global_start'),
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.licorice,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(tr('home_page_planned_today')),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      } else {
        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plannedTrainings.length,
            itemBuilder: (context, index) {
              final training = plannedTrainings.toList()[index];
              final nextDay = getNextTrainingDay(training);

              return Container(
                margin: EdgeInsets.only(
                    left: 20,
                    right: index + 1 == plannedTrainings.length ? 20 : 0),
                width: MediaQuery.of(context).size.width * 0.75,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.floralWhite,
                    border: Border.all(color: AppColors.parchment),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      training.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      training.type.translate(context.locale.languageCode),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: AppColors.taupeGray),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context
                                .read<TrainingManagementBloc>()
                                .add(StartTrainingEvent(training.id!));
                            GoRouter.of(context).push('/active_training');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 7),
                            decoration: BoxDecoration(
                                color: AppColors.folly,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  tr('global_start'),
                                  style:
                                      const TextStyle(color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 7),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.licorice,
                                size: 18,
                              ),
                              const SizedBox(width: 7),
                              Text(getDayText(nextDay)),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      }
    }
    return const SizedBox();
  });
}
