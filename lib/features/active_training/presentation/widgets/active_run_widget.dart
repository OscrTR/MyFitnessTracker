import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/bloc/active_training_bloc.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/widgets/duration_timer_widget.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/widgets/timer_widget.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:uuid/uuid.dart';

import '../../../../assets/app_colors.dart';

const uuid = Uuid();

String formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;
  return '${hours > 0 ? '$hours:' : ''}${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String formatPace(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}/km';
}

class ActiveRunWidget extends StatefulWidget {
  final TrainingExercise tExercise;
  final GlobalKey<TimerWidgetState> timerWidgetKey;
  const ActiveRunWidget(
      {super.key, required this.tExercise, required this.timerWidgetKey});

  @override
  State<ActiveRunWidget> createState() => _ActiveRunWidgetState();
}

class _ActiveRunWidgetState extends State<ActiveRunWidget> {
  final timerId = uuid.v4();
  @override
  Widget build(BuildContext context) {
    final hasSpecialInstructions =
        widget.tExercise.specialInstructions != null &&
            widget.tExercise.specialInstructions!.isNotEmpty;
    final hasObjectives = widget.tExercise.objectives != null &&
        widget.tExercise.objectives!.isNotEmpty;

    if (widget.tExercise.runExerciseTarget == RunExerciseTarget.distance ||
        widget.tExercise.runExerciseTarget == RunExerciseTarget.duration) {
      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.lightBlack),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            buildRunExerciseText(),
            const SizedBox(height: 10),
            if (hasSpecialInstructions)
              _buildOptionalInfo(
                title: 'global_special_instructions',
                content: widget.tExercise.specialInstructions,
                context: context,
              ),
            if (hasObjectives)
              _buildOptionalInfo(
                title: 'global_objectives',
                content: widget.tExercise.objectives,
                context: context,
              ),
            if (hasSpecialInstructions || hasObjectives) ...[
              const Divider(),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Duration',
                  style: TextStyle(color: AppColors.lightBlack),
                ),
                DurationTimerWidget(
                  timerId: timerId,
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distance (km)',
                  style: TextStyle(color: AppColors.lightBlack),
                ),
                Text(
                  '0',
                  style: TextStyle(color: AppColors.lightBlack),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rythm (min/km)',
                  style: TextStyle(color: AppColors.lightBlack),
                ),
                Text(
                  '00:00',
                  style: TextStyle(color: AppColors.lightBlack),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                context
                    .read<ActiveTrainingBloc>()
                    .add(StartTimer(timerId: timerId));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 160,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      tr('global_start'),
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    } else if (widget.tExercise.intervals != null) {
      return _buildIntervals(widget.tExercise.intervals!);
    } else {
      return const SizedBox();
    }
  }

  Widget _buildOptionalInfo({
    required String title,
    required String? content,
    required BuildContext context,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(title),
          style: const TextStyle(color: AppColors.lightBlack),
        ),
        Text(
          content,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.lightBlack,
              ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Text buildRunExerciseText() {
    final tExercise = widget.tExercise;
    final targetDistance = tExercise.targetDistance != null
        ? '${(tExercise.targetDistance! / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = tExercise.targetDuration != null
        ? formatDuration(tExercise.targetDuration!)
        : '';
    final targetPace = tExercise.isTargetRythmSelected == true
        ? ' at ${formatPace(tExercise.targetRythm!)}'
        : '';

    if (tExercise.runExerciseTarget == RunExerciseTarget.distance) {
      return Text('Running $targetDistance$targetPace');
    } else if (tExercise.runExerciseTarget == RunExerciseTarget.duration) {
      return Text('Running $targetDuration$targetPace');
    } else {
      return const Text('Running');
    }
  }

  Widget _buildIntervals(int intervals) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: intervals,
        itemBuilder: (context, index) {
          return Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.lightBlack),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text('Run interval $index'),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 160,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              tr('global_start'),
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ]));
        });
  }
}
