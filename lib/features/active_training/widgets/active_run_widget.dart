import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../helper_functions.dart';
import '../../training_management/models/exercise.dart';
import '../bloc/active_training_bloc.dart';
import 'distance_widget.dart';
import 'duration_timer_widget.dart';
import 'pace_widget.dart';

class ActiveRunWidget extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final bool isLast;
  final int lastTrainingVersionId;

  const ActiveRunWidget({
    super.key,
    required this.exercise,
    required this.isLast,
    required this.exerciseIndex,
    required this.lastTrainingVersionId,
  });

  @override
  State<ActiveRunWidget> createState() => _ActiveRunWidgetState();
}

class _ActiveRunWidgetState extends State<ActiveRunWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
            builder: (context, state) {
          if (state is ActiveTrainingLoaded) {
            bool isActiveExercise = false;
            final lastStartedTimerId = state.lastStartedTimerId;
            final exerciseIndex = widget.exerciseIndex;
            if (lastStartedTimerId != null &&
                lastStartedTimerId.startsWith(
                    '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex')) {
              isActiveExercise = true;
            }

            final bool isInterval = widget.exercise.sets > 1;

            return Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isActiveExercise ? AppColors.floralWhite : AppColors.white,
                border: Border.all(
                    color: isActiveExercise
                        ? AppColors.licorice
                        : AppColors.timberwolf),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  isInterval ? buildIntervalText() : buildRunExerciseText(),
                  const SizedBox(height: 10),
                  if (widget.exercise.specialInstructions.isNotEmpty)
                    Text(widget.exercise.specialInstructions),
                  if (widget.exercise.objectives.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tr('global_objectives')}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(widget.exercise.objectives),
                      ],
                    ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.timberwolf),
                  if (!isInterval)
                    DistanceOrDurationRun(
                      exercise: widget.exercise,
                      isLast: widget.isLast,
                      exerciseIndex: widget.exerciseIndex,
                      exerciseGlobalKey: widget.key! as GlobalKey,
                      lastTrainingVersionId: widget.lastTrainingVersionId,
                    ),
                  if (isInterval)
                    IntervalWidget(
                      exercise: widget.exercise,
                      isLast: widget.isLast,
                      exerciseIndex: widget.exerciseIndex,
                      exerciseGlobalKey: widget.key! as GlobalKey,
                      lastTrainingVersionId: widget.lastTrainingVersionId,
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }
          return const SizedBox();
        }),
        _buildExerciseRest(),
      ],
    );
  }

  Widget _buildExerciseRest() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
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
              widget.exercise.exerciseRest != 0
                  ? formatDurationToHoursMinutesSeconds(
                      widget.exercise.exerciseRest)
                  : '0:00',
            ),
        ],
      ),
    );
  }

  Text buildRunExerciseText() {
    final targetDistance = widget.exercise.targetDistance != 0 &&
            widget.exercise.targetDistance > 0
        ? '${(widget.exercise.targetDistance / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = widget.exercise.targetDuration != 0
        ? formatDurationToHoursMinutesSeconds(widget.exercise.targetDuration)
        : '';
    final targetSpeed = widget.exercise.isTargetPaceSelected == true
        ? ' at ${formatPace(widget.exercise.targetSpeed)}'
        : '';

    if (widget.exercise.runType == RunType.distance) {
      return Text(
        '${tr('active_training_running')} $targetDistance$targetSpeed',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (widget.exercise.runType == RunType.duration) {
      return Text(
        '${tr('active_training_running')} $targetDuration$targetSpeed',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        tr('active_training_running'),
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Text buildIntervalText() {
    final exercise = widget.exercise;
    final targetDistance = exercise.targetDistance > 0
        ? '${(exercise.targetDistance / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = exercise.targetDuration != 0
        ? formatDurationToHoursMinutesSeconds(exercise.targetDuration)
        : '';
    final targetSpeed = exercise.isTargetPaceSelected == true
        ? ' at ${formatPace(exercise.targetSpeed)}'
        : '';
    final intervals = exercise.sets;

    if (exercise.runType == RunType.distance) {
      return Text(
        '${tr('active_training_running_interval')} ${'$intervals'}x$targetDistance$targetSpeed',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        '${tr('active_training_running_interval')} ${'$intervals'}x$targetDuration$targetSpeed',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

class DistanceOrDurationRun extends StatelessWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final bool isLast;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const DistanceOrDurationRun(
      {super.key,
      required this.exercise,
      required this.isLast,
      required this.exerciseIndex,
      required this.exerciseGlobalKey,
      required this.lastTrainingVersionId});

  @override
  Widget build(BuildContext context) {
    final timerId = '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex';
    final restTimerId = '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-rest';
    // Create exercise timer
    context.read<ActiveTrainingBloc>().add(CreateTimer(
          timerState: TimerState(
            timerId: timerId,
            isActive: false,
            isStarted: false,
            isRunTimer: true,
            isCountDown: false,
            timerValue: 0,
            targetDistance: exercise.runType == RunType.distance
                ? exercise.targetDistance
                : 0,
            targetDuration: exercise.runType == RunType.duration
                ? exercise.targetDuration
                : 0,
            targetSpeed:
                exercise.isTargetPaceSelected ? exercise.targetSpeed : 0.0,
            isAutostart: exercise.isAutoStart,
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: exercise.trainingId!,
            exerciseId: exercise.id!,
            setNumber: 0,
            trainingVersionId: lastTrainingVersionId,
            intervalNumber: null,
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
            countDownValue: exercise.exerciseRest,
            isCountDown: true,
            isAutostart: true,
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: exercise.trainingId!,
            exerciseId: exercise.id!,
            setNumber: 0,
            trainingVersionId: lastTrainingVersionId,
            intervalNumber: null,
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
        return Container(
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('active_training_duration')),
                  DurationTimerWidget(
                    timerId: timerId,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('active_training_distance')),
                  DistanceWidget(timerId: timerId)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('active_training_pace_short')),
                  PaceWidget(timerId: timerId),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  context
                      .read<ActiveTrainingBloc>()
                      .add(StartTimer(timerId: timerId));
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color:
                          isStarted ? AppColors.platinum : AppColors.licorice,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    isStarted
                        ? tr('active_training_started')
                        : tr('global_start'),
                    style: TextStyle(
                        color:
                            isStarted ? AppColors.frenchGray : AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox();
    });
  }
}

class IntervalWidget extends StatelessWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final bool isLast;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const IntervalWidget({
    super.key,
    required this.exercise,
    required this.isLast,
    required this.exerciseIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
  });

  @override
  Widget build(BuildContext context) {
    final intervals = exercise.sets;

    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: intervals,
            itemBuilder: (context, index) {
              final bool isLastInterval = index + 1 == intervals;

              return IntervalRun(
                exercise: exercise,
                isLastInterval: isLastInterval,
                exerciseIndex: exerciseIndex,
                intervalIndex: index,
                exerciseGlobalKey: exerciseGlobalKey,
                lastTrainingVersionId: lastTrainingVersionId,
              );
            }),
        BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
            builder: (context, state) {
          if (state is ActiveTrainingLoaded) {
            bool isStarted = false;
            final currentIsStarted = state.timersStateList
                .firstWhereOrNull((el) =>
                    el.timerId ==
                    '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-00')
                ?.isStarted;
            if (currentIsStarted != null && currentIsStarted) {
              isStarted = true;
            }
            return GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                context.read<ActiveTrainingBloc>().add(StartTimer(
                    timerId:
                        '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-00'));
              },
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                width: double.infinity,
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: isStarted ? AppColors.platinum : AppColors.licorice,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  isStarted
                      ? tr('active_training_started')
                      : tr('global_start'),
                  style: TextStyle(
                      color:
                          isStarted ? AppColors.frenchGray : AppColors.white),
                ),
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }
}

class IntervalRun extends StatelessWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final int intervalIndex;
  final bool isLastInterval;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const IntervalRun({
    super.key,
    required this.exercise,
    required this.isLastInterval,
    required this.exerciseIndex,
    required this.intervalIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
  });

  @override
  Widget build(BuildContext context) {
    final timerId =
        '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-${intervalIndex < 10 ? 0 : ''}$intervalIndex';
    final restTimerId =
        '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-${intervalIndex < 10 ? 0 : ''}$intervalIndex-rest';
    // Create exercise timer
    context.read<ActiveTrainingBloc>().add(CreateTimer(
            timerState: TimerState(
          timerId: timerId,
          isActive: false,
          isStarted: false,
          isRunTimer: true,
          timerValue: 0,
          isCountDown: false,
          targetDistance: exercise.runType == RunType.distance
              ? exercise.targetDistance
              : 0,
          targetDuration: exercise.runType == RunType.duration
              ? 0
              : exercise.targetDuration,
          targetSpeed: exercise.isTargetPaceSelected ? exercise.targetSpeed : 0,
          isAutostart: intervalIndex == 0 ? exercise.isAutoStart : true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: exercise.trainingId!,
          exerciseId: exercise.id!,
          setNumber: intervalIndex,
          trainingVersionId: lastTrainingVersionId,
          intervalNumber: intervalIndex,
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
          countDownValue:
              isLastInterval ? exercise.exerciseRest : exercise.setRest,
          isAutostart: true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: exercise.trainingId!,
          exerciseId: exercise.id!,
          setNumber: intervalIndex,
          trainingVersionId: lastTrainingVersionId,
          intervalNumber: intervalIndex,
        )));

    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        return Container(
          margin: const EdgeInsets.only(top: 10),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('active_training_duration')),
                DurationTimerWidget(
                  timerId: timerId,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('active_training_distance')),
                DistanceWidget(timerId: timerId)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('active_training_pace_short')),
                PaceWidget(timerId: timerId),
              ],
            ),
            if (!isLastInterval)
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.timberwolf),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.snooze,
                      size: 20,
                      color: AppColors.frenchGray,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      exercise.setRest != 0
                          ? formatDurationToHoursMinutesSeconds(
                              exercise.setRest)
                          : '0:00',
                      style: const TextStyle(color: AppColors.frenchGray),
                    ),
                    const SizedBox(width: 5),
                    const Expanded(
                      child: Divider(color: AppColors.timberwolf),
                    ),
                  ],
                ),
              ),
            if (isLastInterval) const SizedBox(height: 10)
          ]),
        );
      }
      return const SizedBox();
    });
  }
}
