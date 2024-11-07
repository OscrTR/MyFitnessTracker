import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';
import 'package:my_fitness_tracker/core/widgets/dash_border_painter_widget.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/widgets/exercise_list_item_widget.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';

class TrainingsListPage extends StatelessWidget {
  const TrainingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.purple,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.self_improvement,
                    color: AppColors.black,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('training_page_yoga'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Liste
            BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                builder: (context, state) {
              if (state is TrainingManagementLoaded) {
                if (state.trainings.isEmpty) {
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go(
                        '/training_detail',
                        extra: TrainingType.yoga,
                      );
                    },
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: AppColors.lightBlack,
                        strokeWidth: 1.0,
                        dashLength: 5.0,
                        gapLength: 5.0,
                      ),
                      child: SizedBox(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.tr('training_page_create_yoga'),
                                  style: const TextStyle(
                                      color: AppColors.lightBlack),
                                ),
                                const Icon(
                                  Icons.add,
                                  color: AppColors.lightBlack,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10.0),
                  itemCount: state.trainings.length,
                  itemBuilder: (context, index) {
                    final training = state.trainings[index];
                    return Text(training.name);
                  },
                );
              }
              return Center(child: Text(context.tr('error_state')));
            }),
            const SizedBox(height: 40),
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.blue,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Symbols.sprint,
                    color: AppColors.black,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('training_page_run'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Liste
            BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                builder: (context, state) {
              if (state is TrainingManagementLoaded) {
                if (state.trainings.isEmpty) {
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go(
                        '/training_detail',
                        extra: TrainingType.run,
                      );
                    },
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: AppColors.lightBlack,
                        strokeWidth: 1.0,
                        dashLength: 5.0,
                        gapLength: 5.0,
                      ),
                      child: SizedBox(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.tr('training_page_create_run'),
                                  style: const TextStyle(
                                      color: AppColors.lightBlack),
                                ),
                                const Icon(
                                  Icons.add,
                                  color: AppColors.lightBlack,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10.0),
                  itemCount: state.trainings.length,
                  itemBuilder: (context, index) {
                    final training = state.trainings[index];
                    return Text(training.name);
                  },
                );
              }
              return Center(child: Text(context.tr('error_state')));
            }),
            const SizedBox(height: 40),
            // Header
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.orange,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: AppColors.black,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('training_page_workout'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Liste
            BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                builder: (context, state) {
              if (state is TrainingManagementLoaded) {
                if (state.trainings.isEmpty) {
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go(
                        '/training_detail',
                        extra: TrainingType.workout,
                      );
                    },
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: AppColors.lightBlack,
                        strokeWidth: 1.0,
                        dashLength: 5.0,
                        gapLength: 5.0,
                      ),
                      child: SizedBox(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.tr('training_page_create_workout'),
                                  style: const TextStyle(
                                      color: AppColors.lightBlack),
                                ),
                                const Icon(
                                  Icons.add,
                                  color: AppColors.lightBlack,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10.0),
                  itemCount: state.trainings.length,
                  itemBuilder: (context, index) {
                    final training = state.trainings[index];
                    return Text(training.name);
                  },
                );
              }
              return Center(child: Text(context.tr('error_state')));
            }),
            const SizedBox(height: 40),
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.lightGrey,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.list,
                    color: AppColors.black,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('exercise_page_exercises'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
                builder: (context, state) {
              if (state is ExerciseManagementLoaded) {
                if (state.exercises.isEmpty) {
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go('/exercise_detail');
                    },
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: AppColors.lightBlack,
                        strokeWidth: 1.0,
                        dashLength: 5.0,
                        gapLength: 5.0,
                      ),
                      child: SizedBox(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.tr('training_page_create_exercise'),
                                  style: const TextStyle(
                                      color: AppColors.lightBlack),
                                ),
                                const Icon(
                                  Icons.add,
                                  color: AppColors.lightBlack,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10.0),
                  itemCount: state.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = state.exercises[index];
                    return ExerciseListItem(
                      exerciseId: exercise.id!,
                      exerciseName: exercise.name,
                      exerciseImagePath: exercise.imagePath,
                      exerciseDescription: exercise.description,
                    );
                  },
                );
              }
              return Center(child: Text(context.tr('error_state')));
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
