import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/models/training_exercise.dart';
import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../bloc/active_training_bloc.dart';
import 'distance_widget.dart';
import 'duration_timer_widget.dart';
import 'pace_widget.dart';

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

            final bool isInterval = widget.tExercise.sets > 1;

            return Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isActiveExercise ? AppColors.floralWhite : AppColors.white,
                border: Border.all(
                    color: isActiveExercise
                        ? AppColors.parchment
                        : AppColors.timberwolf),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  isInterval ? buildIntervalText() : buildRunExerciseText(),
                  const SizedBox(height: 10),
                  if (widget.tExercise.specialInstructions != null &&
                      widget.tExercise.specialInstructions != '')
                    Text('${widget.tExercise.specialInstructions}'),
                  if (widget.tExercise.objectives != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tr('global_objectives')}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${widget.tExercise.objectives}'),
                      ],
                    ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.timberwolf),
                  if (!isInterval)
                    DistanceOrDurationRun(
                      tExercise: widget.tExercise,
                      isLast: widget.isLast,
                      exerciseIndex: widget.exerciseIndex,
                      exerciseGlobalKey: widget.key! as GlobalKey,
                    ),
                  if (isInterval)
                    IntervalWidget(
                      tExercise: widget.tExercise,
                      isLast: widget.isLast,
                      exerciseIndex: widget.exerciseIndex,
                      exerciseGlobalKey: widget.key! as GlobalKey,
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
              widget.tExercise.exerciseRest != null
                  ? formatDurationToHoursMinutesSeconds(
                      widget.tExercise.exerciseRest!)
                  : '0:00',
            ),
        ],
      ),
    );
  }

  Text buildRunExerciseText() {
    final targetDistance = widget.tExercise.targetDistance != null &&
            widget.tExercise.targetDistance! > 0
        ? '${(widget.tExercise.targetDistance! / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = widget.tExercise.targetDuration != null
        ? formatDurationToHoursMinutesSeconds(widget.tExercise.targetDuration!)
        : '';
    final targetPace = widget.tExercise.isTargetPaceSelected == true
        ? ' at ${formatPace(widget.tExercise.targetPace ?? 0)}'
        : '';

    if (widget.tExercise.runType == RunType.distance) {
      return Text(
        '${tr('active_training_running')} $targetDistance$targetPace',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (widget.tExercise.runType == RunType.duration) {
      return Text(
        '${tr('active_training_running')} $targetDuration$targetPace',
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
    final tExercise = widget.tExercise;
    final targetDistance =
        tExercise.targetDistance != null && tExercise.targetDistance! > 0
            ? '${(tExercise.targetDistance! / 1000).toStringAsFixed(1)}km'
            : '';
    final targetDuration = tExercise.targetDuration != null
        ? formatDurationToHoursMinutesSeconds(tExercise.targetDuration!)
        : '';
    final targetPace = tExercise.isTargetPaceSelected == true
        ? ' at ${formatPace(tExercise.targetPace ?? 0)}'
        : '';
    final intervals = tExercise.sets;

    if (tExercise.runType == RunType.distance) {
      return Text(
        '${tr('active_training_running_interval')} ${'$intervals'}x$targetDistance$targetPace',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        '${tr('active_training_running_interval')} ${'$intervals'}x$targetDuration$targetPace',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

class DistanceOrDurationRun extends StatelessWidget {
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final bool isLast;
  final GlobalKey exerciseGlobalKey;

  const DistanceOrDurationRun({
    super.key,
    required this.tExercise,
    required this.isLast,
    required this.exerciseIndex,
    required this.exerciseGlobalKey,
  });

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
            targetDistance: tExercise.runType == RunType.distance
                ? tExercise.targetDistance ?? 0
                : 0,
            targetDuration: tExercise.runType == RunType.duration
                ? tExercise.targetDuration ?? 0
                : 0,
            targetPace: tExercise.isTargetPaceSelected != null &&
                    tExercise.isTargetPaceSelected!
                ? tExercise.targetPace ?? 0
                : 0,
            isAutostart: tExercise.isAutoStart,
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: tExercise.trainingId!,
            tExerciseId: tExercise.id,
            setNumber: 0,
            multisetSetNumber: null,
            multisetId: null,
            exerciseId: null,
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
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: tExercise.trainingId!,
            tExerciseId: tExercise.id,
            setNumber: 0,
            multisetSetNumber: null,
            multisetId: null,
            exerciseId: null,
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
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final bool isLast;
  final GlobalKey exerciseGlobalKey;

  const IntervalWidget({
    super.key,
    required this.tExercise,
    required this.isLast,
    required this.exerciseIndex,
    required this.exerciseGlobalKey,
  });

  @override
  Widget build(BuildContext context) {
    final intervals = tExercise.sets;

    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: intervals,
            itemBuilder: (context, index) {
              final bool isLastInterval = index + 1 == intervals;

              return IntervalRun(
                tExercise: tExercise,
                isLastInterval: isLastInterval,
                exerciseIndex: exerciseIndex,
                intervalIndex: index,
                exerciseGlobalKey: exerciseGlobalKey,
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
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final int intervalIndex;
  final bool isLastInterval;
  final GlobalKey exerciseGlobalKey;

  const IntervalRun({
    super.key,
    required this.tExercise,
    required this.isLastInterval,
    required this.exerciseIndex,
    required this.intervalIndex,
    required this.exerciseGlobalKey,
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
          targetDistance: tExercise.runType == RunType.distance
              ? tExercise.targetDistance ?? 0
              : 0,
          targetDuration: tExercise.runType == RunType.duration
              ? 0
              : tExercise.targetDuration ?? 0,
          targetPace: tExercise.isTargetPaceSelected != null &&
                  tExercise.isTargetPaceSelected!
              ? tExercise.targetPace ?? 0
              : 0,
          isAutostart: intervalIndex == 0 ? tExercise.isAutoStart : true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: tExercise.trainingId!,
          tExerciseId: tExercise.id,
          setNumber: intervalIndex,
          multisetSetNumber: null,
          multisetId: null,
          exerciseId: null,
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
              : tExercise.setRest ?? 0,
          isAutostart: true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: tExercise.trainingId!,
          tExerciseId: tExercise.id,
          setNumber: intervalIndex,
          multisetSetNumber: null,
          multisetId: null,
          exerciseId: null,
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
                      tExercise.setRest != null
                          ? formatDurationToHoursMinutesSeconds(
                              tExercise.setRest!)
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
