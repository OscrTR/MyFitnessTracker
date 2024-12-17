import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/active_training_bloc.dart';
import 'distance_widget.dart';
import 'duration_timer_widget.dart';
import 'pace_widget.dart';
import '../../../training_management/domain/entities/training_exercise.dart';

import '../../../../app_colors.dart';

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
  final int exerciseIndex;
  final bool isLast;

  const ActiveRunWidget({
    super.key,
    required this.tExercise,
    required this.isLast,
    required this.exerciseIndex,
  });

  @override
  State<ActiveRunWidget> createState() => _ActiveRunWidgetState();
}

class _ActiveRunWidgetState extends State<ActiveRunWidget> {
  @override
  Widget build(BuildContext context) {
    final hasSpecialInstructions =
        widget.tExercise.specialInstructions != null &&
            widget.tExercise.specialInstructions!.isNotEmpty;
    final hasObjectives = widget.tExercise.objectives != null &&
        widget.tExercise.objectives!.isNotEmpty;

    return Column(
      children: [
        Container(
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
              widget.tExercise.runExerciseTarget == RunExerciseTarget.intervals
                  ? buildIntervalText()
                  : buildRunExerciseText(),
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
              if (widget.tExercise.runExerciseTarget ==
                      RunExerciseTarget.distance ||
                  widget.tExercise.runExerciseTarget ==
                      RunExerciseTarget.duration)
                DistanceOrDurationRun(
                  tExercise: widget.tExercise,
                  isLast: widget.isLast,
                  exerciseIndex: widget.exerciseIndex,
                ),
              if (widget.tExercise.runExerciseTarget ==
                      RunExerciseTarget.intervals &&
                  widget.tExercise.intervals != null &&
                  widget.tExercise.intervals! > 0)
                IntervalWidget(
                  tExercise: widget.tExercise,
                  isLast: widget.isLast,
                  exerciseIndex: widget.exerciseIndex,
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        _buildExerciseRest(),
      ],
    );
  }

  Row _buildExerciseRest() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.isLast)
          const Icon(
            Icons.snooze,
            size: 20,
          ),
        if (!widget.isLast) const SizedBox(width: 5),
        if (!widget.isLast)
          Text(
            widget.tExercise.exerciseRest != null
                ? formatDuration(widget.tExercise.exerciseRest!)
                : '0:00',
          ),
        if (widget.isLast) Text(tr('active_training_end')),
      ],
    );
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
    final targetDistance = widget.tExercise.targetDistance != null
        ? '${(widget.tExercise.targetDistance! / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = widget.tExercise.targetDuration != null
        ? formatDuration(widget.tExercise.targetDuration!)
        : '';
    final targetPace = widget.tExercise.isTargetRythmSelected == true
        ? ' at ${formatPace(widget.tExercise.targetRythm!)}'
        : '';

    if (widget.tExercise.runExerciseTarget == RunExerciseTarget.distance) {
      return Text('Running $targetDistance$targetPace');
    } else if (widget.tExercise.runExerciseTarget ==
        RunExerciseTarget.duration) {
      return Text('Running $targetDuration$targetPace');
    } else {
      return const Text('Running');
    }
  }

  Text buildIntervalText() {
    final tExercise = widget.tExercise;
    final targetDistance = tExercise.intervalDistance != null
        ? '${(tExercise.intervalDistance! / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = tExercise.intervalDuration != null
        ? formatDuration(tExercise.intervalDuration!)
        : '';
    final targetPace = tExercise.isTargetRythmSelected == true
        ? ' at ${formatPace(tExercise.targetRythm!)}'
        : '';

    if (tExercise.isIntervalInDistance == true) {
      return Text(
          'Running interval $targetDistance$targetPace x${tExercise.intervals}');
    } else if (tExercise.isIntervalInDistance == false) {
      return Text(
          'Running interval $targetDuration$targetPace x${tExercise.intervals}');
    } else {
      return const Text('Running');
    }
  }
}

class DistanceOrDurationRun extends StatelessWidget {
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final bool isLast;
  const DistanceOrDurationRun({
    super.key,
    required this.tExercise,
    required this.isLast,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    final timerId = '$exerciseIndex';
    final restTimerId = '$exerciseIndex-rest';
    // Create exercise timer
    context.read<ActiveTrainingBloc>().add(CreateTimer(
          timerState: TimerState(
            timerId: timerId,
            isActive: false,
            isStarted: false,
            isRunTimer: true,
            isCountDown: false,
            timerValue: 0,
            targetDistance:
                tExercise.runExerciseTarget == RunExerciseTarget.distance
                    ? tExercise.targetDistance ?? 0
                    : 0,
            targetDuration:
                tExercise.runExerciseTarget == RunExerciseTarget.duration
                    ? tExercise.targetDuration ?? 0
                    : 0,
            targetPace: tExercise.isTargetRythmSelected != null &&
                    tExercise.isTargetRythmSelected!
                ? tExercise.targetRythm ?? 0
                : 0,
          ),
        ));

    // Create rest timer
    context.read<ActiveTrainingBloc>().add(CreateTimer(
          timerState: TimerState(
            timerId: restTimerId,
            isActive: false,
            isStarted: false,
            isRunTimer: false,
            timerValue: 0,
            countDownValue: tExercise.exerciseRest ?? 0,
            isCountDown: true,
            isAutostart: true,
          ),
        ));

    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        bool isStarted = false;
        final currentIsStarted = state.timersStateList
            .firstWhereOrNull((el) => el.timerId == timerId)
            ?.isStarted;
        if (currentIsStarted != null && currentIsStarted) {
          isStarted = true;
        }
        return Column(
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Distance (km)',
                  style: TextStyle(color: AppColors.lightBlack),
                ),
                DistanceWidget(timerId: timerId)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pace (min/km)',
                  style: TextStyle(color: AppColors.lightBlack),
                ),
                PaceWidget(timerId: timerId),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final bloc = context.read<ActiveTrainingBloc>();
                final runCompleter = Completer<String>();

                bloc.add(
                  StartTimer(timerId: timerId, completer: runCompleter),
                );
                await runCompleter.future;

                if (!isLast) {
                  bloc.add(StartTimer(timerId: restTimerId));
                }
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
                        color:
                            isStarted ? AppColors.lightGrey : AppColors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      isStarted ? 'Started' : tr('global_start'),
                      style: TextStyle(
                          color: isStarted
                              ? AppColors.lightBlack
                              : AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      return const SizedBox();
    });
  }
}

class IntervalWidget extends StatefulWidget {
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final bool isLast;

  const IntervalWidget(
      {super.key,
      required this.tExercise,
      required this.isLast,
      required this.exerciseIndex});

  @override
  State<IntervalWidget> createState() => _IntervalWidgetState();
}

class _IntervalWidgetState extends State<IntervalWidget> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.tExercise.intervals,
            itemBuilder: (context, index) {
              final bool isLastInterval =
                  index + 1 == widget.tExercise.intervals;

              return IntervalRun(
                tExercise: widget.tExercise,
                isLastInterval: isLastInterval,
                exerciseIndex: widget.exerciseIndex,
                intervalIndex: index,
              );
            }),
        GestureDetector(
          onTap: () async {
            final bloc = context.read<ActiveTrainingBloc>();
            if (!isClicked) {
              isClicked = true;
              setState(() {});

              bloc.add(StartTimer(timerId: '${widget.exerciseIndex}-0'));
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: isClicked ? AppColors.lightGrey : AppColors.black,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  isClicked ? 'Started' : tr('global_start'),
                  style: TextStyle(
                      color:
                          isClicked ? AppColors.lightBlack : AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IntervalRun extends StatelessWidget {
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final int intervalIndex;
  final bool isLastInterval;
  const IntervalRun({
    super.key,
    required this.tExercise,
    required this.isLastInterval,
    required this.exerciseIndex,
    required this.intervalIndex,
  });

  @override
  Widget build(BuildContext context) {
    final timerId = '$exerciseIndex-$intervalIndex';
    final restTimerId = '$exerciseIndex-$intervalIndex-rest';
    // Create exercise timer
    context.read<ActiveTrainingBloc>().add(CreateTimer(
            timerState: TimerState(
          timerId: timerId,
          isActive: false,
          isStarted: false,
          isRunTimer: true,
          timerValue: 0,
          isCountDown: false,
          targetDistance: tExercise.intervalDistance ?? 0,
          targetDuration: tExercise.intervalDuration ?? 0,
          targetPace: tExercise.isTargetRythmSelected != null &&
                  tExercise.isTargetRythmSelected!
              ? tExercise.targetRythm ?? 0
              : 0,
          isAutostart: intervalIndex == 0 ? false : true,
        )));

    // Create rest timer
    context.read<ActiveTrainingBloc>().add(CreateTimer(
            timerState: TimerState(
          timerId: restTimerId,
          isActive: false,
          isStarted: false,
          isRunTimer: false,
          timerValue: 0,
          isCountDown: true,
          countDownValue: isLastInterval
              ? tExercise.exerciseRest ?? 0
              : tExercise.intervalRest ?? 0,
          isAutostart: true,
        )));

    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        return Column(children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Distance (km)',
                style: TextStyle(color: AppColors.lightBlack),
              ),
              DistanceWidget(timerId: timerId)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pace (min/km)',
                style: TextStyle(color: AppColors.lightBlack),
              ),
              PaceWidget(timerId: timerId),
            ],
          ),
          if (!isLastInterval)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(child: Divider()),
                const SizedBox(width: 5),
                const Icon(
                  Icons.snooze,
                  size: 20,
                  color: AppColors.lightBlack,
                ),
                const SizedBox(width: 5),
                Text(
                  tExercise.intervalRest != null
                      ? formatDuration(tExercise.intervalRest!)
                      : '0:00',
                  style: const TextStyle(color: AppColors.lightBlack),
                ),
                const SizedBox(width: 5),
                const Expanded(child: Divider()),
              ],
            ),
          if (isLastInterval) const SizedBox(height: 10)
        ]);
      }
      return const SizedBox();
    });
  }
}
