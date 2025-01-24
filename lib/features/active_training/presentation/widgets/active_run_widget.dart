import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
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
    final hasSpecialInstructions =
        widget.tExercise.specialInstructions != null &&
            widget.tExercise.specialInstructions!.isNotEmpty;
    final hasObjectives = widget.tExercise.objectives != null &&
        widget.tExercise.objectives!.isNotEmpty;

    return Column(
      children: [
        BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
            builder: (context, state) {
          if (state is ActiveTrainingLoaded) {
            Color exerciseActiveColor = AppColors.whiteSmoke;
            bool isActiveExercise = false;
            final lastStartedTimerId = state.lastStartedTimerId;
            final exerciseIndex = widget.exerciseIndex;
            if (lastStartedTimerId != null &&
                lastStartedTimerId.startsWith(
                    '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex')) {
              isActiveExercise = true;
            }
            return Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActiveExercise ? exerciseActiveColor : AppColors.white,
                border: Border.all(color: AppColors.lightBlack),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  widget.tExercise.runExerciseTarget ==
                          RunExerciseTarget.intervals
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
                      exerciseGlobalKey: widget.key! as GlobalKey,
                    ),
                  if (widget.tExercise.runExerciseTarget ==
                      RunExerciseTarget.intervals)
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
                ? formatDurationToHoursMinutesSeconds(
                    widget.tExercise.exerciseRest!)
                : '0:00',
          ),
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
    final targetDistance =
        tExercise.intervalDistance != null && tExercise.intervalDistance! > 0
            ? '${(tExercise.intervalDistance! / 1000).toStringAsFixed(1)}km'
            : '';
    final targetDuration = tExercise.intervalDuration != null
        ? formatDurationToHoursMinutesSeconds(tExercise.intervalDuration!)
        : '';
    final targetPace = tExercise.isTargetPaceSelected == true
        ? ' at ${formatPace(tExercise.targetPace ?? 0)}'
        : '';
    final intervals = tExercise.intervals ?? 1;

    if (tExercise.isIntervalInDistance == true) {
      return Text('Running interval $targetDistance$targetPace x$intervals');
    } else if (tExercise.isIntervalInDistance == false) {
      return Text('Running interval $targetDuration$targetPace x$intervals');
    } else {
      return const Text('Running');
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
            targetDistance:
                tExercise.runExerciseTarget == RunExerciseTarget.distance
                    ? tExercise.targetDistance ?? 0
                    : 0,
            targetDuration:
                tExercise.runExerciseTarget == RunExerciseTarget.duration
                    ? tExercise.targetDuration ?? 0
                    : 0,
            targetPace: tExercise.isTargetPaceSelected != null &&
                    tExercise.isTargetPaceSelected!
                ? tExercise.targetPace ?? 0
                : 0,
            isAutostart: tExercise.autoStart ?? false,
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: tExercise.trainingId,
            tExerciseId: tExercise.id,
            setNumber: null,
            multisetSetNumber: null,
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
            trainingId: null,
            tExerciseId: null,
            setNumber: null,
            multisetSetNumber: null,
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
                        color: isStarted
                            ? AppColors.lightGrey
                            : AppColors.licorice,
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
    final intervals = tExercise.intervals ?? 1;

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 160,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: isStarted
                            ? AppColors.lightGrey
                            : AppColors.licorice,
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
          targetDistance: tExercise.isIntervalInDistance!
              ? tExercise.intervalDistance ?? 0
              : 0,
          targetDuration: tExercise.isIntervalInDistance!
              ? 0
              : tExercise.intervalDuration ?? 0,
          targetPace: tExercise.isTargetPaceSelected != null &&
                  tExercise.isTargetPaceSelected!
              ? tExercise.targetPace ?? 0
              : 0,
          isAutostart: intervalIndex == 0 ? tExercise.autoStart ?? false : true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: tExercise.trainingId,
          tExerciseId: tExercise.id,
          setNumber: intervalIndex,
          multisetSetNumber: null,
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
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: null,
          tExerciseId: null,
          setNumber: null,
          multisetSetNumber: null,
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
                      ? formatDurationToHoursMinutesSeconds(
                          tExercise.intervalRest!)
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
