import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/widgets/active_multiset_widget.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/widgets/active_run_widget.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/widgets/timer_widget.dart';

import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';

import '../../../training_management/domain/entities/multiset.dart';
import '../widgets/active_exercise_widget.dart';

class ActiveTrainingPage extends StatefulWidget {
  const ActiveTrainingPage({super.key});

  @override
  State<ActiveTrainingPage> createState() => _ActiveTrainingPageState();
}

class _ActiveTrainingPageState extends State<ActiveTrainingPage> {
  final GlobalKey<TimerWidgetState> timerWidgetKey =
      GlobalKey<TimerWidgetState>();

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
                      _buildTrainingItemList(sortedItems),
                      const SizedBox(height: 90),
                    ],
                  ),
                );
              }
              return Center(child: Text(context.tr('error_state')));
            })
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: TimerWidget(
          key: timerWidgetKey,
        ),
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

  Widget _buildTrainingItemList(List<Map<String, dynamic>> items) {
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
                  timerWidgetKey: timerWidgetKey,
                )
              : ActiveExerciseWidget(
                  tExercise: exercise,
                  timerWidgetKey: timerWidgetKey,
                  isLast: isLast);
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          final isLast = index == items.length - 1;
          return ActiveMultisetWidget(
              isLast: isLast,
              multiset: multiset,
              timerWidgetKey: timerWidgetKey);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
