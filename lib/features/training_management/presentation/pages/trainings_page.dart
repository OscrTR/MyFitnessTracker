import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/training_exercise.dart';
import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../bloc/training_management_bloc.dart';
import '../../domain/entities/training.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  Map<TrainingType, bool> _selectedTrainingTypes = {};
  bool _isExercisesSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedTrainingTypes = {};
    _selectedTrainingTypes = Map.fromEntries(
        TrainingType.values.map((type) => MapEntry(type, false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPageHeader(context),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildFilters(context),
                    _buildFilteredItems(),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BlocBuilder<TrainingManagementBloc, TrainingManagementState>
      _buildFilteredItems() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
        builder: (context, state) {
      if (state is TrainingManagementLoaded) {
        final hasSelectedTypes =
            _selectedTrainingTypes.values.any((isSelected) => isSelected);
        final displayedTrainings = hasSelectedTypes
            ? state.trainings.where(
                (training) => _selectedTrainingTypes[training.type] ?? false)
            : state.trainings;

        if (displayedTrainings.isEmpty && !_isExercisesSelected) {
          return SizedBox(
            height: MediaQuery.of(context).size.height - 250,
            child: Center(
              child: Text(tr('training_page_no_training')),
            ),
          );
        }

        if (!_isExercisesSelected) {
          return _buildTrainingsList(displayedTrainings);
        } else {
          return _buildExercisesList();
        }
      }
      return const SizedBox();
    });
  }

  BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>
      _buildExercisesList() {
    return BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
        builder: (context, state) {
      if (state is ExerciseManagementLoaded) {
        final displayedExercises = state.exercises;

        if (displayedExercises.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height - 250,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(tr('training_page_no_exercise')),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedExercises.length,
          itemBuilder: (context, index) {
            final exercise = displayedExercises.elementAt(index);
            return Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.timberwolf),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exercise.imagePath != null &&
                      exercise.imagePath!.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(
                          width: 130,
                          height: 110,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              File(exercise.imagePath!),
                              width: MediaQuery.of(context).size.width - 40,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<ExerciseManagementBloc>()
                              .add(GetExerciseEvent(exercise.id!));
                          GoRouter.of(context).push('/exercise_detail');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.timberwolf),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                              child: Text(
                            tr('training_page_see_details'),
                            style: const TextStyle(color: AppColors.taupeGray),
                          )),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      }
      return const SizedBox();
    });
  }

  ListView _buildTrainingsList(Iterable<Training> displayedTrainings) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedTrainings.length,
      itemBuilder: (context, index) {
        final training = displayedTrainings.elementAt(index);
        final exercisesAndMultisetsList = [
          ...training.trainingExercises
              .map((e) => {'type': 'exercise', 'data': e}),
          ...training.multisets.map((m) => {'type': 'multiset', 'data': m}),
        ];
        exercisesAndMultisetsList.sort((a, b) {
          final aPosition = (a['data'] as dynamic).position ?? 0;
          final bPosition = (b['data'] as dynamic).position ?? 0;
          return aPosition.compareTo(bPosition);
        });

        final daysSinceTraining =
            (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
                .daysSinceLastTraining[training.id];

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.timberwolf),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrainingItemHeader(training, context),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(
                  LucideIcons.timer,
                  color: AppColors.licorice,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(formatDurationToHoursMinutesSeconds(
                    calculateTrainingDuration(training)))
              ]),
              Row(children: [
                const Icon(
                  LucideIcons.target,
                  color: AppColors.licorice,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(tr('training_page_exercises_count',
                    args: ['${exercisesAndMultisetsList.length}']))
              ]),
              Row(children: [
                const Icon(
                  LucideIcons.calendar,
                  color: AppColors.licorice,
                  size: 16,
                ),
                const SizedBox(width: 5),
                if (daysSinceTraining != null)
                  Text(tr('training_page_days_since_training',
                      args: ['$daysSinceTraining']))
                else
                  Text(tr('global_never'))
              ]),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  context
                      .read<TrainingManagementBloc>()
                      .add(GetTrainingEvent(id: training.id!));
                  GoRouter.of(context).push('/training_detail');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.timberwolf),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                      child: Text(
                    tr('training_page_see_details'),
                    style: const TextStyle(color: AppColors.taupeGray),
                  )),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  context
                      .read<TrainingManagementBloc>()
                      .add(StartTrainingEvent(training.id!));
                  GoRouter.of(context).push('/active_training');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: AppColors.licorice,
                  ),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tr('global_start'),
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Wrap _buildFilters(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        ..._selectedTrainingTypes.keys.map(
          (e) => FilterChip(
            side: BorderSide(
                color: _selectedTrainingTypes[e]!
                    ? AppColors.white
                    : AppColors.timberwolf),
            label: Text(
              e.translate(context.locale.languageCode),
            ),
            labelStyle: TextStyle(
              color: _selectedTrainingTypes[e]!
                  ? AppColors.white
                  : AppColors.licorice,
            ),
            showCheckmark: true,
            selectedColor: AppColors.licorice,
            checkmarkColor: AppColors.white,
            backgroundColor: AppColors.white,
            selected: _selectedTrainingTypes[e]!,
            onSelected: (bool value) {
              setState(() {
                _selectedTrainingTypes[e] = value;
                _isExercisesSelected = false;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 40,
            width: 1,
            color: AppColors.licorice,
          ),
        ),
        FilterChip(
          side: BorderSide(
              color: _isExercisesSelected
                  ? AppColors.white
                  : AppColors.timberwolf),
          label: Text(
            tr('exercise_page_exercises'),
          ),
          labelStyle: TextStyle(
            color: _isExercisesSelected ? AppColors.white : AppColors.licorice,
          ),
          showCheckmark: true,
          selectedColor: AppColors.licorice,
          checkmarkColor: AppColors.white,
          backgroundColor: AppColors.white,
          selected: _isExercisesSelected,
          onSelected: (bool value) {
            setState(() {
              _isExercisesSelected = value;
              _selectedTrainingTypes = Map.fromEntries(
                  TrainingType.values.map((type) => MapEntry(type, false)));
            });
          },
        )
      ],
    );
  }

  Row _buildPageHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('trainings_page_title'),
          style: Theme.of(context).textTheme.displayLarge,
        ),
        GestureDetector(
          onTap: () {
            _showNewDialog(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
                color: AppColors.folly, borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                Text(
                  tr('trainings_page_new'),
                  style: const TextStyle(color: AppColors.white),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.add,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Wrap _buildTrainingItemHeader(Training training, BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        Text(
          training.name,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
              color: AppColors.parchment,
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            training.type.translate(context.locale.languageCode),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (training.trainingDays != null)
          if (training.trainingDays!.length == 7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.platinum,
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                tr('global_everyday'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ...training.trainingDays!.map((day) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.platinum,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    day.translate(context.locale.languageCode),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )),
      ],
    );
  }
}

void _showNewDialog(BuildContext context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('global_create')),
          GestureDetector(
            onTap: () => Navigator.pop(context, 'Close'),
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.centerRight,
              child: const ClipRect(
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 0.85,
                  child: Icon(
                    Icons.close,
                    color: AppColors.licorice,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              GoRouter.of(context).push(
                '/training_detail',
              );
              Navigator.pop(context, 'New training');
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.taupeGray),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                tr('training_page_create_training'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              GoRouter.of(context).push('/exercise_detail');
              Navigator.pop(context, 'New exercise');
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.taupeGray),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                tr('training_page_create_exercise'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

int calculateTrainingDuration(Training training) {
  int totalSeconds = 0;

  // Fonction utilitaire pour convertir les répétitions en secondes
  int repsToSeconds(int reps) {
    const secondsPerRep = 3; // Estimation moyenne de 3 secondes par répétition
    return reps * secondsPerRep;
  }

  // Traitement des exercices individuels
  for (TrainingExercise exercise in training.trainingExercises) {
    if (exercise.duration != null) {
      // Si l'exercice a une durée explicite
      totalSeconds += exercise.duration!;
    } else if (exercise.isSetsInReps!) {
      // Calcul basé sur les répétitions
      int avgReps = ((exercise.minReps ?? 0) + (exercise.maxReps ?? 0)) ~/ 2;
      totalSeconds += repsToSeconds(avgReps) * (exercise.sets ?? 1);
    }

    // Ajout des temps de repos
    totalSeconds += (exercise.setRest ?? 0) * (exercise.sets ?? 1);
    totalSeconds += (exercise.exerciseRest ?? 0);

    // Gestion des intervalles
    if (exercise.intervals != null) {
      totalSeconds += (exercise.intervalRest ?? 0) * (exercise.intervals! - 1);
      if (exercise.intervalDuration != null) {
        totalSeconds += exercise.intervalDuration! * exercise.intervals!;
      }
    }
  }

  // Traitement des multisets
  for (var multiset in training.multisets) {
    int multisetTotalSeconds = 0;

    for (TrainingExercise exercise in multiset.trainingExercises!) {
      if (exercise.duration != null) {
        multisetTotalSeconds += exercise.duration!;
      } else if (exercise.isSetsInReps!) {
        int avgReps = ((exercise.minReps ?? 0) + (exercise.maxReps ?? 0)) ~/ 2;
        multisetTotalSeconds += repsToSeconds(avgReps) * (exercise.sets ?? 1);
      }
      multisetTotalSeconds += (exercise.setRest ?? 0) * (exercise.sets ?? 1);
    }

    // Multiplie par le nombre de sets du multiset
    totalSeconds += multisetTotalSeconds * (multiset.sets ?? 1);
    // Ajoute le repos entre les sets du multiset
    totalSeconds += (multiset.setRest ?? 0) * ((multiset.sets ?? 1) - 1);
    // Ajoute le repos final du multiset
    totalSeconds += (multiset.multisetRest ?? 0);
  }

  return totalSeconds;
}
