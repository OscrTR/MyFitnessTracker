import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_colors.dart';
import '../../domain/entities/multiset.dart';
import '../../domain/entities/training_exercise.dart';
import 'package:uuid/uuid.dart';
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
                            trainingExerciseType: TrainingExerciseType.workout,
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
                            autoStart: null,
                            position: nextPosition,
                            key: uuid.v4(),
                            runExerciseTarget: RunExerciseTarget.distance,
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
                    child: AutoSizeText(
                      context.tr('training_detail_page_add_exercise'),
                      maxLines: 1,
                    ),
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
                            autoStart: null,
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
                    child: AutoSizeText(
                      context.tr('training_detail_page_add_run'),
                      maxLines: 1,
                    ),
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
