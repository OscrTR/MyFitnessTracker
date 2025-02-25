import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../helper_functions.dart';
import '../../training_management/models/multiset.dart';
import '../../training_management/models/exercise.dart';
import '../bloc/active_training_bloc.dart';
import 'distance_widget.dart';
import 'duration_timer_widget.dart';
import 'pace_widget.dart';

class ActiveMultisetRunWidget extends StatefulWidget {
  final Multiset multiset;
  final Exercise exercise;
  final bool isLast;
  final int lastTrainingVersionId;

  const ActiveMultisetRunWidget({
    super.key,
    required this.multiset,
    required this.exercise,
    required this.isLast,
    required this.lastTrainingVersionId,
  });

  @override
  State<ActiveMultisetRunWidget> createState() =>
      _ActiveMultisetRunWidgetState();
}

class _ActiveMultisetRunWidgetState extends State<ActiveMultisetRunWidget> {
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

            if (lastStartedTimerId != null) {
              final possibleTimerIds = [];
              for (var i = 0; i < widget.multiset.sets; i++) {
                possibleTimerIds.add(
                    '${widget.multiset.position! < 10 ? 0 : ''}${widget.multiset.position!}-${i < 10 ? 0 : ''}$i-${widget.exercise.position! < 10 ? 0 : ''}${widget.exercise.position!}');
              }

              if (possibleTimerIds
                  .any((el) => lastStartedTimerId.startsWith(el))) {
                isActiveExercise = true;
              }
            }

            final List<Exercise> multisetExercises = state
                .activeTraining!.exercises
                .where((e) => e.multisetId == widget.multiset.id)
                .toList();

            final bool isInterval = widget.exercise.sets > 1;

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
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.multiset.sets,
                      itemBuilder: (context, setIndex) {
                        if (!isInterval) {
                          return DistanceOrDurationRun(
                            multiset: widget.multiset,
                            exercise: widget.exercise,
                            isLastSet: widget.multiset.sets == setIndex + 1,
                            isLastMultisetExercise: multisetExercises.length ==
                                widget.exercise.position! + 1,
                            setIndex: setIndex,
                            exerciseGlobalKey: widget.key! as GlobalKey,
                            lastTrainingVersionId: widget.lastTrainingVersionId,
                          );
                        } else if (isInterval) {
                          return IntervalWidget(
                              exercise: widget.exercise,
                              multiset: widget.multiset,
                              isLastSet: widget.multiset.sets == setIndex + 1,
                              isLastMultisetExercise:
                                  multisetExercises.length ==
                                      widget.exercise.position! + 1,
                              setIndex: setIndex,
                              exerciseGlobalKey: widget.key! as GlobalKey,
                              lastTrainingVersionId:
                                  widget.lastTrainingVersionId,
                              multisetExercises: multisetExercises);
                        }
                        return const SizedBox();
                      }),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }
          return const SizedBox();
        }),
        _buildExerciseRest()
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
                  ? formatDurationToMinutesSeconds(widget.exercise.exerciseRest)
                  : '0:00',
            ),
        ],
      ),
    );
  }

  Text buildRunExerciseText() {
    final targetDistance = widget.exercise.targetDistance != 0
        ? '${(widget.exercise.targetDistance / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = widget.exercise.targetDuration != 0
        ? formatDurationToHoursMinutesSeconds(widget.exercise.targetDuration)
        : '';
    final targetPace = widget.exercise.isTargetPaceSelected == true
        ? ' at ${formatPace(widget.exercise.targetPace)}'
        : '';

    if (widget.exercise.runType == RunType.distance) {
      return Text(
        '${tr('active_training_running')}  $targetDistance$targetPace',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (widget.exercise.runType == RunType.duration) {
      return Text(
        '${tr('active_training_running')}  $targetDuration$targetPace',
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
    final targetDistance = exercise.targetDistance != 0
        ? '${(exercise.targetDistance / 1000).toStringAsFixed(1)}km'
        : '';
    final targetDuration = exercise.targetDuration != 0
        ? formatDurationToHoursMinutesSeconds(exercise.targetDuration)
        : '';
    final targetPace = exercise.isTargetPaceSelected == true
        ? ' at ${formatPace(exercise.targetPace)}'
        : '';
    final intervals = exercise.sets;

    if (exercise.runType == RunType.distance) {
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
  final Multiset multiset;
  final Exercise exercise;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const DistanceOrDurationRun({
    super.key,
    required this.multiset,
    required this.exercise,
    required this.isLastSet,
    required this.isLastMultisetExercise,
    required this.setIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
  });

  @override
  Widget build(BuildContext context) {
    final timerId =
        '${multiset.position! < 10 ? 0 : ''}${multiset.position!}-${setIndex < 10 ? 0 : ''}$setIndex-${exercise.position! < 10 ? 0 : ''}${exercise.position!}';
    final restTimerId =
        '${multiset.position! < 10 ? 0 : ''}${multiset.position!}-${setIndex < 10 ? 0 : ''}$setIndex-${exercise.position! < 10 ? 0 : ''}${exercise.position!}-rest';
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
            targetPace: exercise.isTargetPaceSelected ? exercise.targetPace : 0,
            isAutostart: exercise.isAutoStart,
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: exercise.trainingId!,
            exerciseId: exercise.id!,
            setNumber: setIndex,
            trainingVersionId: lastTrainingVersionId,
            intervalNumber: null,
          ),
        ));

    context.read<ActiveTrainingBloc>().add(CreateTimer(
          timerState: TimerState(
            timerId: restTimerId,
            isActive: false,
            isStarted: false,
            isRunTimer: false,
            timerValue: 0,
            countDownValue: isLastMultisetExercise
                ? isLastSet
                    ? multiset.multisetRest
                    : multiset.setRest
                : exercise.exerciseRest,
            isCountDown: true,
            isAutostart: true,
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: exercise.trainingId!,
            exerciseId: exercise.id!,
            setNumber: setIndex,
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
          margin: const EdgeInsets.only(top: 20),
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
                  context.read<ActiveTrainingBloc>().add(
                        StartTimer(timerId: timerId),
                      );
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color:
                          isStarted ? AppColors.platinum : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
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
  final Multiset multiset;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;
  final List<Exercise> multisetExercises;

  const IntervalWidget({
    super.key,
    required this.exercise,
    required this.multiset,
    required this.isLastSet,
    required this.isLastMultisetExercise,
    required this.setIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
    required this.multisetExercises,
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
            itemBuilder: (context, intervalIndex) {
              final bool isLastInterval = intervalIndex + 1 == intervals;

              return IntervalRun(
                exercise: exercise,
                isLastInterval: isLastInterval,
                intervalIndex: intervalIndex,
                multiset: multiset,
                isLastSet: multiset.sets == setIndex + 1,
                isLastMultisetExercise:
                    multisetExercises.length == exercise.position! + 1,
                setIndex: setIndex,
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
                    '${multiset.position! < 10 ? 0 : ''}${multiset.position!}-${setIndex < 10 ? 0 : ''}$setIndex-${exercise.position! < 10 ? 0 : ''}${exercise.position!}-00')
                ?.isStarted;
            if (currentIsStarted != null && currentIsStarted) {
              isStarted = true;
            }

            return GestureDetector(
              onTap: () async {
                context.read<ActiveTrainingBloc>().add(StartTimer(
                    timerId:
                        '${multiset.position! < 10 ? 0 : ''}${multiset.position!}-${setIndex < 10 ? 0 : ''}$setIndex-${exercise.position! < 10 ? 0 : ''}${exercise.position!}-00'));
              },
              child: Container(
                margin: EdgeInsets.only(top: 20, bottom: isLastSet ? 0 : 20),
                width: double.infinity,
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: isStarted ? AppColors.platinum : AppColors.licorice,
                    borderRadius: BorderRadius.circular(10)),
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
  final bool isLastInterval;
  final Multiset multiset;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final int setIndex;
  final int intervalIndex;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const IntervalRun({
    super.key,
    required this.exercise,
    required this.isLastInterval,
    required this.multiset,
    required this.isLastSet,
    required this.isLastMultisetExercise,
    required this.setIndex,
    required this.intervalIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
  });

  @override
  Widget build(BuildContext context) {
    final timerId =
        '${multiset.position! < 10 ? 0 : ''}${multiset.position!}-${setIndex < 10 ? 0 : ''}$setIndex-${exercise.position! < 10 ? 0 : ''}${exercise.position!}-${intervalIndex < 10 ? 0 : ''}$intervalIndex';
    final restTimerId =
        '${multiset.position! < 10 ? 0 : ''}${multiset.position!}-${setIndex < 10 ? 0 : ''}$setIndex-${exercise.position! < 10 ? 0 : ''}${exercise.position!}-${intervalIndex < 10 ? 0 : ''}$intervalIndex-rest';
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
              ? exercise.targetDuration
              : 0,
          targetPace: exercise.isTargetPaceSelected ? exercise.targetPace : 0,
          isAutostart: intervalIndex == 0 ? exercise.isAutoStart : true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: exercise.trainingId!,
          exerciseId: exercise.id!,
          setNumber: setIndex,
          trainingVersionId: lastTrainingVersionId,
          intervalNumber: intervalIndex,
        )));

    context.read<ActiveTrainingBloc>().add(CreateTimer(
            timerState: TimerState(
          timerId: restTimerId,
          isActive: false,
          isStarted: false,
          isRunTimer: false,
          timerValue: 0,
          isCountDown: true,
          countDownValue: isLastInterval
              ? isLastMultisetExercise
                  ? isLastSet
                      ? multiset.multisetRest
                      : multiset.setRest
                  : exercise.exerciseRest
              : exercise.setRest,
          isAutostart: true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: exercise.trainingId!,
          exerciseId: exercise.id!,
          setNumber: setIndex,
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
                        child: Divider(
                      color: AppColors.timberwolf,
                    )),
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
                        child: Divider(
                      color: AppColors.timberwolf,
                    )),
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
