import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/bloc/active_training_bloc.dart';

import '../../../../app_colors.dart';
import '../../../../core/widgets/dash_border_painter_widget.dart';
import '../../../training_management/domain/entities/training.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('home_page_selected_trainings'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                GestureDetector(
                  onTap: () {
                    GoRouter.of(context).push('/trainings');
                  },
                  child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tr('home_page_see_all'),
                            style: const TextStyle(color: AppColors.lightBlack),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.lightBlack,
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildSelectedWidgets(),
        ],
      ),
    );
  }
}

Widget _buildSelectedWidgets() {
  return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
    builder: (context, state) {
      if ((state is TrainingManagementInitial)) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(15)),
        );
      }

      if ((state is TrainingManagementLoaded)) {
        final filteredTrainings = state.trainings.where((training) {
          return training.isSelected;
        }).toList();

        if (filteredTrainings.isEmpty) {
          return Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).push('/trainings');
              },
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: AppColors.lightBlack,
                  strokeWidth: 1.0,
                  dashLength: 5.0,
                  gapLength: 5.0,
                ),
                child: SizedBox(
                  height: 180,
                  width: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        tr('home_page_select_training'),
                        style: const TextStyle(color: AppColors.lightBlack),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.add, color: AppColors.lightBlack),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.only(left: 20),
            height: 180,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final training = state.trainings
                      .where((training) => training.isSelected)
                      .toList()[index];

                  Color color = AppColors.white;
                  IconData icon = Icons.self_improvement;
                  if (training.type == TrainingType.yoga) {
                    color = AppColors.purple;
                    icon = Icons.self_improvement;
                  } else if (training.type == TrainingType.run) {
                    color = AppColors.blue;
                    icon = Symbols.sprint;
                  } else if (training.type == TrainingType.workout) {
                    color = AppColors.orange;
                    icon = Icons.fitness_center;
                  }
                  return Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(right: 10),
                    width: 180,
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(15)),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(icon),
                                const SizedBox(width: 10),
                                Text(training.type.name[0].toUpperCase() +
                                    training.type.name.substring(1)),
                              ],
                            ),
                            Text(training.name),
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<ActiveTrainingBloc>()
                                    .add(LoadDefaultActiveTraining());
                                context
                                    .read<TrainingManagementBloc>()
                                    .add(StartTrainingEvent(training.id!));

                                GoRouter.of(context).push('/active_training');
                              },
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(tr('global_start')),
                                      const Icon(Icons.chevron_right)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: -10,
                          right: -12,
                          child: PopupMenuButton(
                            onSelected: (value) {
                              final bloc =
                                  BlocProvider.of<TrainingManagementBloc>(
                                      context);
                              if (value == 'unselect') {
                                bloc.add(UnselectTrainingEvent(training.id!));
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'unselect',
                                child: Row(
                                  children: [Text(tr('home_page_unselect'))],
                                ),
                              ),
                            ],
                            icon: const Icon(
                              Icons.more_horiz,
                              color: AppColors.lightBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: state.trainings
                    .where((training) => training.isSelected)
                    .length),
          );
        }
      }
      return Center(child: Text(context.tr('error_state')));
    },
  );
}
