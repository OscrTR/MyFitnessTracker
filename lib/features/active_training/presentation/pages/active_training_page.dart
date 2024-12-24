import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/app_colors.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/widgets/error_state_widget.dart';
import 'package:uuid/uuid.dart';
import '../widgets/active_multiset_widget.dart';
import '../widgets/active_run_widget.dart';
import '../widgets/timer_widget.dart';

import '../../../training_management/domain/entities/training_exercise.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';

import '../../../training_management/domain/entities/multiset.dart';
import '../widgets/active_exercise_widget.dart';

const uuid = Uuid();

class ActiveTrainingPage extends StatelessWidget {
  const ActiveTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                builder: (context, state) {
              if (state is TrainingManagementLoaded &&
                  state.activeTraining != null) {
                final sortedItems = _getSortedTrainingItems(state);

                final exercisesAndMultisetsList = [
                  ...state.activeTraining!.trainingExercises
                      .map((e) => {'type': 'exercise', 'data': e}),
                  ...state.activeTraining!.multisets
                      .map((m) => {'type': 'multiset', 'data': m}),
                ];
                exercisesAndMultisetsList.sort((a, b) {
                  final aPosition = (a['data'] as dynamic).position ?? 0;
                  final bPosition = (b['data'] as dynamic).position ?? 0;
                  return aPosition.compareTo(bPosition);
                });
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildHeader(state, context),
                      const SizedBox(height: 30),
                      _buildTrainingItemList(
                          sortedItems, context, exercisesAndMultisetsList),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: (){
                          GoRouter.of(context).go('/home');
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              context.tr('active_training_end'),
                              style: const TextStyle(color: AppColors.white),
                            )),
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                );
              }
              return const ErrorStateWidget();
            })
          ],
        ),
      ),
      const Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: TimerWidget(),
      )
    ]);
  }

  Widget _buildHeader(TrainingManagementLoaded state, BuildContext context) {
    return Text(
      state.activeTraining!.name,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  List<Map<String, dynamic>> _getSortedTrainingItems(
      TrainingManagementLoaded state) {
    final items = [
      ...state.activeTraining!.trainingExercises
          .map((e) => {'type': 'exercise', 'data': e}),
      ...state.activeTraining!.multisets
          .map((m) => {'type': 'multiset', 'data': m}),
    ];
    items.sort((a, b) {
      final aPos = (a['data'] as dynamic).position ?? 0;
      final bPos = (b['data'] as dynamic).position ?? 0;
      return aPos.compareTo(bPos);
    });
    return items;
  }

  Widget _buildTrainingItemList(
      List<Map<String, dynamic>> items,
      BuildContext context,
      List<Map<String, Object>> exercisesAndMultisetsList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'exercise') {
          final exercise = item['data'] as TrainingExercise;
          final isLast = index == items.length - 1;

          return exercise.trainingExerciseType == TrainingExerciseType.run
              ? ActiveRunWidget(
                  tExercise: exercise,
                  isLast: isLast,
                  exerciseIndex: index,
                )
              : ActiveExerciseWidget(
                  tExercise: exercise,
                  isLast: isLast,
                  exerciseIndex: index,
                );
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          final isLast = index == items.length - 1;
          return ActiveMultisetWidget(
            isLast: isLast,
            multiset: multiset,
            multisetIndex: index,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
