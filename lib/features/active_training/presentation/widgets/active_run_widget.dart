import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/active_training_bloc.dart';
import 'distance_widget.dart';
import 'duration_timer_widget.dart';
import 'pace_widget.dart';
import 'timer_widget.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
import 'package:uuid/uuid.dart';

import '../../../../app_colors.dart';

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
  final bool isLast;
  const ActiveRunWidget(
      {super.key,
      required this.tExercise,
      required this.timerWidgetKey,
      required this.isLast});

  @override
  State<ActiveRunWidget> createState() => _ActiveRunWidgetState();
}

class _ActiveRunWidgetState extends State<ActiveRunWidget> {
  final timerId = uuid.v4();
  bool isClicked = false;
  @override
  Widget build(BuildContext context) {
    final hasSpecialInstructions =
        widget.tExercise.specialInstructions != null &&
            widget.tExercise.specialInstructions!.isNotEmpty;
    final hasObjectives = widget.tExercise.objectives != null &&
        widget.tExercise.objectives!.isNotEmpty;

    if (widget.tExercise.runExerciseTarget == RunExerciseTarget.distance ||
        widget.tExercise.runExerciseTarget == RunExerciseTarget.duration) {
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
                      activeRunId: timerId,
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
                    DistanceWidget(activeRunId: timerId)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pace (min/km)',
                      style: TextStyle(color: AppColors.lightBlack),
                    ),
                    PaceWidget(activeRunId: timerId),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    if (!isClicked) {
                      isClicked = true;
                      setState(() {});

                      final bloc = context.read<ActiveTrainingBloc>();

                      final runCompleter = Completer<String>();
                      bloc.add(ResetSecondaryTimer());
                      bloc.add(StartTimer(
                        timerId: 'secondaryTimer',
                        activeRunTimer: timerId,
                        duration: widget.tExercise.duration ?? 0,
                        isRunTimer: true,
                        distance: widget.tExercise.runExerciseTarget ==
                                RunExerciseTarget.distance
                            ? widget.tExercise.targetDistance ?? 0
                            : 0,
                        completer: runCompleter,
                        pace: widget.tExercise.isTargetRythmSelected != null &&
                                widget.tExercise.isTargetRythmSelected!
                            ? widget.tExercise.targetRythm ?? 0
                            : 0,
                      ));
                      await runCompleter.future;
                      bloc.add(ResetSecondaryTimer());
                      final restCompleter = Completer<String>();
                      bloc.add(StartTimer(
                        timerId: 'secondaryTimer',
                        duration: widget.isLast
                            ? 0
                            : widget.tExercise.exerciseRest ?? 0,
                        isCountDown: true,
                        activeRunTimer: 'secondaryTimer',
                        completer: restCompleter,
                      ));
                      await restCompleter.future;
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
                            color: isClicked
                                ? AppColors.lightGrey
                                : AppColors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          isClicked ? 'Started' : tr('global_start'),
                          style: TextStyle(
                              color: isClicked
                                  ? AppColors.lightBlack
                                  : AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          _buildExerciseRest(),
        ],
      );
    } else if (widget.tExercise.intervals != null) {
      return _buildIntervals(widget.tExercise.intervals!);
    } else {
      return const SizedBox();
    }
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
    final List<String> intervalIds = [];
    for (var i = 0; i < widget.tExercise.intervals!; i++) {
      intervalIds.add(uuid.v4());
    }
    return Column(
      children: [
        IntervalWidget2(
          tExercise: widget.tExercise,
          intervalIds: intervalIds,
        ),
        Row(
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
        ),
      ],
    );
  }
}

class IntervalWidget2 extends StatefulWidget {
  const IntervalWidget2({
    super.key,
    required this.tExercise,
    required this.intervalIds,
  });

  final TrainingExercise tExercise;
  final List<String> intervalIds;

  @override
  State<IntervalWidget2> createState() => _IntervalWidgetState2();
}

class _IntervalWidgetState2 extends State<IntervalWidget2> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
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
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.lightBlack),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 10),
          if (tExercise.isIntervalInDistance == true)
            Text(
                'Running interval $targetDistance$targetPace x${tExercise.intervals}'),
          if (tExercise.isIntervalInDistance == false)
            Text(
                'Running interval $targetDuration$targetPace x${tExercise.intervals}'),
          const SizedBox(height: 10),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tExercise.intervals,
              itemBuilder: (context, index) {
                final bool isLastInterval = index + 1 == tExercise.intervals;
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
                            activeRunId: widget.intervalIds[index]),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Distance (km)',
                          style: TextStyle(color: AppColors.lightBlack),
                        ),
                        DistanceWidget(activeRunId: widget.intervalIds[index])
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pace (min/km)',
                          style: TextStyle(color: AppColors.lightBlack),
                        ),
                        PaceWidget(activeRunId: widget.intervalIds[index])
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
                  ],
                );
              }),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final bloc = context.read<ActiveTrainingBloc>();
              if (!isClicked) {
                isClicked = true;
                setState(() {});

                for (var i = 0; i < widget.intervalIds.length; i++) {
                  // Start interval timer
                  final intervalCompleter = Completer<String>();
                  bloc.add(ResetSecondaryTimer());
                  bloc.add(StartTimer(
                    timerId: 'secondaryTimer',
                    activeRunTimer: widget.intervalIds[i],
                    duration: tExercise.intervalDuration ?? 0,
                    completer: intervalCompleter,
                    isRunTimer: true,
                    distance: widget.tExercise.isIntervalInDistance!
                        ? widget.tExercise.intervalDistance ?? 0
                        : 0,
                    pace: widget.tExercise.isTargetRythmSelected != null &&
                            widget.tExercise.isTargetRythmSelected!
                        ? widget.tExercise.targetRythm ?? 0
                        : 0,
                  ));
                  await intervalCompleter.future;
                  // After interval completion, start rest timer
                  bloc.add(ResetSecondaryTimer());
                  final restCompleter = Completer<String>();
                  final isLastInterval = i + 1 == widget.intervalIds.length;
                  bloc.add(StartTimer(
                    timerId: 'secondaryTimer',
                    duration: isLastInterval
                        ? tExercise.exerciseRest ?? 0
                        : tExercise.intervalRest ?? 0,
                    isCountDown: true,
                    activeRunTimer: 'secondaryTimer',
                    completer: restCompleter,
                  ));
                  await restCompleter.future;
                }
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
          const SizedBox(height: 10),
        ]));
  }
}
