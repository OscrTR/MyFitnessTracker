import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/widgets/exercise_detail_custom_text_field_widget.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';

class TrainingDetailsPage extends StatefulWidget {
  final TrainingType trainingType;

  const TrainingDetailsPage({super.key, required this.trainingType});

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  late TrainingType selectedTrainingType;

  @override
  void initState() {
    super.initState();
    selectedTrainingType = widget.trainingType;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
            builder: (context, state) {
          if (state is TrainingManagementLoaded) {
            final training = state.selectedTraining;

            if (training != null) {
              return const Text('training found');
            }

            return Column(children: [
              _pageTitle(context, training),
              const SizedBox(height: 30),
              _trainingTypeSelection(context),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightBlack),
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                            child: Text(context
                                .tr('training_detail_page_add_exercise'))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightBlack),
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                            child: Text(
                                context.tr('training_detail_page_add_run'))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightBlack),
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                      child: Text(
                          context.tr('training_detail_page_add_multiset'))),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: training == null
                        ? AppColors.lightGrey
                        : AppColors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr(
                            training == null ? 'global_create' : 'global_save'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: training == null
                                    ? AppColors.lightBlack
                                    : AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ]);
          }
          return Center(child: Text(context.tr('error_state')));
        }),
      ),
    );
  }

  SizedBox _pageTitle(BuildContext context, Training? training) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).go('/trainings');
                BlocProvider.of<TrainingManagementBloc>(context)
                    .add(const ClearSelectedTrainingEvent());
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.black,
              ),
            ),
          ),
          Center(
            child: Text(
              context.tr(training == null
                  ? 'training_detail_page_title_create'
                  : 'training_detail_page_title_edit'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Container _trainingTypeSelection(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightBlack),
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('training_detail_page_training_type'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.lightBlack),
            ),
            GestureDetector(
              onTapDown: (details) async {
                final selected = await showMenu<TrainingType>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  ),
                  items: [
                    PopupMenuItem(
                      value: TrainingType.workout,
                      child: Text(context.tr('global_workout')),
                    ),
                    PopupMenuItem(
                      value: TrainingType.yoga,
                      child: Text(context.tr('global_yoga')),
                    ),
                    PopupMenuItem(
                      value: TrainingType.run,
                      child: Text(context.tr('global_run')),
                    ),
                  ],
                );

                // Update the selected training type if an option is selected
                if (selected != null) {
                  setState(() {
                    selectedTrainingType = selected;
                  });
                }
              },
              child: Row(
                children: [
                  Text(
                    selectedTrainingType == TrainingType.workout
                        ? context.tr('global_workout')
                        : selectedTrainingType == TrainingType.yoga
                            ? context.tr('global_yoga')
                            : selectedTrainingType == TrainingType.run
                                ? context.tr('global_run')
                                : context.tr('global_unknown'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.lightBlack,
                    size: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
