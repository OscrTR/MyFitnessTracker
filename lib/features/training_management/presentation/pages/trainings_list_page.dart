import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../assets/app_colors.dart';
import '../../../../core/widgets/dash_border_painter_widget.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../../../exercise_management/presentation/widgets/exercise_list_item_widget.dart';
import '../../domain/entities/training.dart';
import '../bloc/training_management_bloc.dart';

class TrainingsListPage extends StatelessWidget {
  const TrainingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            TrainingSection(
              titleKey: 'training_page_yoga',
              icon: Icons.self_improvement,
              color: AppColors.purple,
              trainingType: TrainingType.yoga,
            ),
            SizedBox(height: 40),
            TrainingSection(
              titleKey: 'training_page_run',
              icon: Symbols.sprint,
              color: AppColors.blue,
              trainingType: TrainingType.run,
            ),
            SizedBox(height: 40),
            TrainingSection(
              titleKey: 'training_page_workout',
              icon: Icons.fitness_center,
              color: AppColors.orange,
              trainingType: TrainingType.workout,
            ),
            SizedBox(height: 40),
            ExerciseSection(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class TrainingSection extends StatelessWidget {
  final String titleKey;
  final IconData icon;
  final Color color;
  final TrainingType trainingType;

  const TrainingSection({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.trainingType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderWidget(titleKey: titleKey, icon: icon, color: color),
        const SizedBox(height: 20),
        BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
          builder: (context, state) {
            if (state is TrainingManagementInitial ||
                (state is TrainingManagementLoaded &&
                    state.trainings.isEmpty)) {
              return CreateButton(
                textKey: 'training_page_create_${trainingType.name}',
                onTap: () => GoRouter.of(context).go(
                  '/training_detail',
                  extra: trainingType,
                ),
              );
            }
            if (state is TrainingManagementLoaded) {
              return TrainingList(trainings: state.trainings);
            }
            return Center(child: Text(context.tr('error_state')));
          },
        ),
      ],
    );
  }
}

class ExerciseSection extends StatelessWidget {
  const ExerciseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeaderWidget(
          titleKey: 'exercise_page_exercises',
          icon: Icons.list,
          color: AppColors.lightGrey,
        ),
        const SizedBox(height: 20),
        BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
          builder: (context, state) {
            if (state is ExerciseManagementLoaded) {
              if (state.exercises.isEmpty) {
                return CreateButton(
                  textKey: 'training_page_create_exercise',
                  onTap: () => GoRouter.of(context).go('/exercise_detail'),
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
          },
        ),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String titleKey;
  final IconData icon;
  final Color color;

  const HeaderWidget({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.black, size: 30),
          const SizedBox(width: 10),
          Text(
            context.tr(titleKey),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class CreateButton extends StatelessWidget {
  final String textKey;
  final VoidCallback onTap;

  const CreateButton({super.key, required this.textKey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              Text(
                context.tr(textKey),
                style: const TextStyle(color: AppColors.lightBlack),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.add, color: AppColors.lightBlack),
            ],
          ),
        ),
      ),
    );
  }
}

class TrainingList extends StatelessWidget {
  final List<Training> trainings;

  const TrainingList({super.key, required this.trainings});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 10.0),
      itemCount: trainings.length,
      itemBuilder: (context, index) {
        final training = trainings[index];
        return Text(training.name);
      },
    );
  }
}
