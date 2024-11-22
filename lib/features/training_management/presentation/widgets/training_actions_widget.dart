import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:uuid/uuid.dart';
import '../../../../assets/app_colors.dart';
import '../bloc/training_management_bloc.dart';

class TrainingActionsWidget extends StatelessWidget {
  const TrainingActionsWidget({super.key});
  final uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final currentExercises = (context
                              .read<TrainingManagementBloc>()
                              .state as TrainingManagementLoaded)
                          .selectedTraining
                          ?.trainingExercises ??
                      [];
                  final currentMultisets = (context
                              .read<TrainingManagementBloc>()
                              .state as TrainingManagementLoaded)
                          .selectedTraining
                          ?.multisets ??
                      [];
                  final nextPosition =
                      currentExercises.length + currentMultisets.length;

                  context.read<TrainingManagementBloc>().add(
                        AddExerciseToSelectedTrainingEvent(
                          TrainingExercise(
                            id: null,
                            trainingId: null,
                            multisetId: null,
                            exerciseId: null,
                            trainingExerciseType: null,
                            specialInstructions: null,
                            objectives: null,
                            targetDistance: null,
                            targetDuration: null,
                            targetRythm: null,
                            intervals: null,
                            intervalDistance: null,
                            intervalDuration: null,
                            intervalRest: null,
                            sets: null,
                            isSetsInReps: null,
                            minReps: null,
                            maxReps: null,
                            actualReps: null,
                            duration: null,
                            setRest: null,
                            exerciseRest: null,
                            manualStart: null,
                            position: nextPosition,
                            key: uuid.v4(),
                          ),
                        ),
                      );
                },
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightBlack),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child:
                        Text(context.tr('training_detail_page_add_exercise')),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final currentExercises = (context
                              .read<TrainingManagementBloc>()
                              .state as TrainingManagementLoaded)
                          .selectedTraining
                          ?.trainingExercises ??
                      [];
                  final currentMultisets = (context
                              .read<TrainingManagementBloc>()
                              .state as TrainingManagementLoaded)
                          .selectedTraining
                          ?.multisets ??
                      [];
                  final nextPosition =
                      currentExercises.length + currentMultisets.length;
                  context.read<TrainingManagementBloc>().add(
                        AddExerciseToSelectedTrainingEvent(
                          TrainingExercise(
                            id: null,
                            trainingId: null,
                            multisetId: null,
                            exerciseId: null,
                            trainingExerciseType: TrainingExerciseType.run,
                            specialInstructions: null,
                            objectives: null,
                            runExerciseTarget: RunExerciseTarget.distance,
                            targetDistance: null,
                            targetDuration: null,
                            isTargetRythmSelected: false,
                            targetRythm: null,
                            intervals: null,
                            isIntervalInDistance: true,
                            intervalDistance: null,
                            intervalDuration: null,
                            intervalRest: null,
                            sets: null,
                            isSetsInReps: null,
                            minReps: null,
                            maxReps: null,
                            actualReps: null,
                            duration: null,
                            setRest: null,
                            exerciseRest: null,
                            manualStart: null,
                            position: nextPosition,
                            key: uuid.v4(),
                          ),
                        ),
                      );
                },
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightBlack),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(context.tr('training_detail_page_add_run')),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            final currentExercises = (context
                        .read<TrainingManagementBloc>()
                        .state as TrainingManagementLoaded)
                    .selectedTraining
                    ?.trainingExercises ??
                [];
            final currentMultisets = (context
                        .read<TrainingManagementBloc>()
                        .state as TrainingManagementLoaded)
                    .selectedTraining
                    ?.multisets ??
                [];
            final nextPosition =
                currentExercises.length + currentMultisets.length;

            context
                .read<TrainingManagementBloc>()
                .add(AddMultisetToSelectedTrainingEvent(
                  Multiset(
                    trainingId: null,
                    trainingExercises: const [],
                    sets: null,
                    setRest: null,
                    multisetRest: null,
                    specialInstructions: null,
                    objectives: null,
                    position: nextPosition,
                    key: uuid.v4(),
                  ),
                ));
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightBlack),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(context.tr('training_detail_page_add_multiset')),
            ),
          ),
        )
      ],
    );
  }
}
