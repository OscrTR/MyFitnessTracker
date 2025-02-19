import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../training_management/bloc/training_management_bloc.dart';
import '../../../core/database/object_box.dart';
import '../../../injection_container.dart';
import '../../training_history/models/history_entry.dart';
import '../../training_history/bloc/training_history_bloc.dart';
import '../../../helper_functions.dart';
import '../bloc/active_training_bloc.dart';
import '../../../app_colors.dart';
import '../../exercise_management/models/exercise.dart';
import '../../exercise_management/bloc/exercise_management_bloc.dart';
import '../../training_management/models/training_exercise.dart';
import '../../../core/widgets/small_text_field_widget.dart';

class ActiveExerciseWidget extends StatefulWidget {
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final bool isLast;
  const ActiveExerciseWidget(
      {super.key,
      required this.tExercise,
      required this.isLast,
      required this.exerciseIndex});

  @override
  State<ActiveExerciseWidget> createState() => _ActiveExerciseWidgetState();
}

class _ActiveExerciseWidgetState extends State<ActiveExerciseWidget> {
  late final Map<String, TextEditingController>? _controllers;
  late final Map<String, int?> _setHistoryIds;

  final training =
      (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
          .activeTraining!;
  late final int lastTrainingVersionId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    lastTrainingVersionId = sl<ObjectBox>()
        .getMostRecentTrainingVersionForTrainingId(training.id)!
        .id;
  }

  void _initializeControllers() {
    final sets = widget.tExercise.sets;
    final historyBlocState = sl<TrainingHistoryBloc>().state;

    if (historyBlocState is TrainingHistoryLoaded) {
      final entries = historyBlocState.historyTrainings
          .where((trainingHistory) =>
              trainingHistory.linkedTrainingVersionId ==
              widget.tExercise.linkedTrainingId)
          .toList()
          .sortedBy((entry) => entry.date)
          .lastOrNull
          ?.historyEntries;

      _setHistoryIds = {
        for (int i = 1; i <= sets; i++) ...{
          'idSet$i': entries
              ?.where((entry) =>
                  entry.linkedTrainingExerciseId == widget.tExercise.id &&
                  entry.setNumber == i - 1)
              .toList()
              .sortedBy((entry) => entry.date)
              .lastOrNull
              ?.id,
        }
      };

      _controllers = {
        for (int i = 1; i <= sets; i++) ...{
          'weightSet$i': TextEditingController(
            text: entries != null
                ? entries
                        .where((entry) =>
                            entry.linkedTrainingExerciseId ==
                                widget.tExercise.id &&
                            entry.setNumber == i - 1 &&
                            entry.weight != null)
                        .toList()
                        .sortedBy((entry) => entry.date)
                        .lastOrNull
                        ?.weight
                        ?.toString() ??
                    ''
                : '',
          ),
          'repsSet$i': TextEditingController(
            text: entries != null
                ? entries
                        .where((entry) =>
                            entry.linkedTrainingExerciseId ==
                                widget.tExercise.id &&
                            entry.setNumber == i - 1 &&
                            entry.reps != null)
                        .toList()
                        .sortedBy((entry) => entry.date)
                        .lastOrNull
                        ?.reps
                        ?.toString() ??
                    ''
                : '',
          ),
        },
      };
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers!.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
      builder: (context, exerciseBlocState) {
        final matchingExercise = exerciseBlocState is ExerciseManagementLoaded
            ? exerciseBlocState.exercises.firstWhereOrNull(
                (e) => e.id == widget.tExercise.exercise.targetId)
            : null;

        return Column(
          children: [
            _buildExercise(matchingExercise, widget.tExercise, context,
                lastTrainingVersionId),
            _buildExerciseRest(),
          ],
        );
      },
    );
  }

  Widget _buildExercise(
    Exercise? exercise,
    TrainingExercise tExercise,
    BuildContext context,
    int lastTrainingVersionId,
  ) {
    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        final isSetsInReps = widget.tExercise.isSetsInReps;
        bool isActiveExercise = false;
        final lastStartedTimerId = state.lastStartedTimerId;
        final exerciseIndex = widget.exerciseIndex;
        if (lastStartedTimerId != null &&
            lastStartedTimerId
                .startsWith('${exerciseIndex < 10 ? 0 : ''}$exerciseIndex')) {
          isActiveExercise = true;
        }

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(
                  color: isActiveExercise
                      ? AppColors.parchment
                      : AppColors.timberwolf),
              borderRadius: BorderRadius.circular(10),
              color:
                  isActiveExercise ? AppColors.floralWhite : AppColors.white),
          child: Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpandablePanel(
                  header:
                      _buildExpandableHeader(exercise, context, isSetsInReps),
                  collapsed: const SizedBox(),
                  expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exercise != null &&
                          exercise.description != null &&
                          exercise.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('exercise_detail_page_description'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              exercise.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: AppColors.frenchGray),
                            ),
                          ],
                        ),
                      if (tExercise.objectives != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('global_objectives'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${tExercise.objectives}'),
                          ],
                        ),
                    ],
                  ),
                  theme: const ExpandableThemeData(
                    hasIcon: false,
                    tapHeaderToExpand: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                color: AppColors.timberwolf,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sets',
                      style: TextStyle(color: AppColors.taupeGray)),
                  Row(
                    children: [
                      SizedBox(
                          width: 50,
                          child: Center(
                            child: Text(isSetsInReps ? 'Kg' : '',
                                style: const TextStyle(
                                    color: AppColors.taupeGray)),
                          )),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 50,
                          child: Center(
                              child: Text(isSetsInReps ? 'Reps' : '',
                                  style: const TextStyle(
                                      color: AppColors.taupeGray)))),
                      const SizedBox(width: 46)
                    ],
                  )
                ],
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.tExercise.sets,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${index + 1}',
                              style:
                                  const TextStyle(color: AppColors.taupeGray)),
                          isSetsInReps
                              ? ActiveExerciseRow(
                                  historyEntryId:
                                      _setHistoryIds['idSet${index + 1}'],
                                  weightController:
                                      _controllers!['weightSet${index + 1}']!,
                                  repsController:
                                      _controllers['repsSet${index + 1}']!,
                                  tExercise: widget.tExercise,
                                  isLastSet: widget.tExercise.sets == index + 1,
                                  exerciseIndex: widget.exerciseIndex,
                                  setIndex: index,
                                  exerciseGlobalKey: widget.key! as GlobalKey,
                                  lastTrainingVersionId: lastTrainingVersionId,
                                )
                              : ActiveExerciseDurationRow(
                                  tExercise: widget.tExercise,
                                  isLastSet: widget.tExercise.sets == index + 1,
                                  exerciseIndex: widget.exerciseIndex,
                                  setIndex: index,
                                  exerciseGlobalKey: widget.key! as GlobalKey,
                                  lastTrainingVersionId: lastTrainingVersionId,
                                )
                        ],
                      ),
                    );
                  })
            ],
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget _buildExpandableHeader(
      Exercise? exercise, BuildContext context, bool isSetsInReps) {
    return Builder(builder: (context) {
      final controller = ExpandableController.of(context);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise != null &&
              exercise.imagePath != null &&
              exercise.imagePath!.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  width: 130,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(exercise.imagePath!),
                      width: MediaQuery.of(context).size.width - 40,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          if (exercise != null &&
              exercise.imagePath != null &&
              exercise.imagePath!.isNotEmpty)
            const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise != null
                            ? exercise.name
                            : tr('global_exercise_unknown'),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      controller?.expanded == true
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
                if (isSetsInReps)
                  Text(
                      '${widget.tExercise.minReps ?? 0}-${widget.tExercise.maxReps ?? 0} reps')
                else
                  Text(
                      '${widget.tExercise.duration} ${tr('active_training_seconds')}'),
                Text(
                  '${widget.tExercise.setRest != null ? formatDurationToMinutesSeconds(widget.tExercise.setRest) : '0:00'} ${tr('active_training_rest')}',
                ),
                if (widget.tExercise.specialInstructions != null)
                  Text('${widget.tExercise.specialInstructions}'),
              ],
            ),
          )
        ],
      );
    });
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
                  ? formatDurationToMinutesSeconds(
                      widget.tExercise.exerciseRest)
                  : '0:00',
            ),
        ],
      ),
    );
  }
}

class ActiveExerciseRow extends StatefulWidget {
  final int? historyEntryId;
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final int setIndex;
  final bool isLastSet;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const ActiveExerciseRow({
    super.key,
    required this.historyEntryId,
    required this.weightController,
    required this.repsController,
    required this.tExercise,
    required this.isLastSet,
    required this.exerciseIndex,
    required this.setIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
  });

  @override
  State<ActiveExerciseRow> createState() => _ActiveExerciseRowState();
}

class _ActiveExerciseRowState extends State<ActiveExerciseRow> {
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final restTimerId =
        '${widget.exerciseIndex < 10 ? 0 : ''}${widget.exerciseIndex}-${widget.setIndex < 10 ? 0 : ''}${widget.setIndex}-rest';
    context.read<ActiveTrainingBloc>().add(CreateTimer(
            timerState: TimerState(
          timerId: restTimerId,
          isActive: false,
          isStarted: false,
          isRunTimer: false,
          timerValue: 0,
          countDownValue: widget.isLastSet
              ? widget.tExercise.exerciseRest ?? 0
              : widget.tExercise.setRest ?? 0,
          isCountDown: true,
          isAutostart: false,
          exerciseGlobalKey: widget.exerciseGlobalKey,
          trainingId: widget.tExercise.linkedTrainingId!,
          tExerciseId: widget.tExercise.id,
          setNumber: widget.setIndex,
          trainingVersionId: widget.lastTrainingVersionId,
          intervalNumber: null,
        )));

    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        bool isStarted = false;
        final currentIsStarted = state.timersStateList
            .firstWhereOrNull((el) => el.timerId == restTimerId)
            ?.isStarted;
        if (currentIsStarted != null && currentIsStarted) {
          isStarted = true;
        }

        return Row(
          children: [
            SmallTextFieldWidget(
              controller: widget.weightController,
              backgroungColor: isStarted ? AppColors.platinum : AppColors.white,
            ),
            const SizedBox(width: 10),
            SmallTextFieldWidget(
              controller: widget.repsController,
              backgroungColor: isStarted ? AppColors.platinum : AppColors.white,
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                int cals = 0;

                if (widget.tExercise.isSetsInReps) {
                  cals = getCalories(
                      intensity: widget.tExercise.intensity,
                      reps: int.tryParse(widget.repsController.text));
                } else {
                  cals = getCalories(
                      intensity: widget.tExercise.intensity,
                      duration: widget.tExercise.duration);
                }

                context.read<TrainingHistoryBloc>().add(
                      CreateOrUpdateHistoryEntry(
                        historyEntry: HistoryEntry(
                          id: widget.historyEntryId ?? 0,
                          linkedTrainingId: widget.tExercise.linkedTrainingId!,
                          linkedTrainingExerciseId: widget.tExercise.id,
                          setNumber: widget.setIndex,
                          date: DateTime.now(),
                          reps: int.tryParse(widget.repsController.text),
                          weight: int.tryParse(widget.weightController.text),
                          calories: cals,
                          linkedTrainingVersionId: widget.lastTrainingVersionId,
                          intervalNumber: null,
                        ),
                      ),
                    );
                context
                    .read<ActiveTrainingBloc>()
                    .add(StartTimer(timerId: restTimerId));
                FocusScope.of(context).unfocus();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isStarted ? AppColors.platinum : AppColors.licorice),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 20,
                    color: isStarted ? AppColors.frenchGray : AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    });
  }
}

class ActiveExerciseDurationRow extends StatelessWidget {
  final TrainingExercise tExercise;
  final bool isLastSet;
  final int exerciseIndex;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const ActiveExerciseDurationRow({
    super.key,
    required this.tExercise,
    required this.isLastSet,
    required this.exerciseIndex,
    required this.setIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
  });

  @override
  Widget build(BuildContext context) {
    final timerId =
        '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-${setIndex < 10 ? 0 : ''}$setIndex';
    final restTimerId =
        '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-${setIndex < 10 ? 0 : ''}$setIndex-rest';
    context.read<ActiveTrainingBloc>().add(CreateTimer(
            timerState: TimerState(
          timerId: timerId,
          isActive: false,
          isStarted: false,
          isCountDown: true,
          isRunTimer: false,
          countDownValue: tExercise.duration ?? 0,
          timerValue: 0,
          isAutostart: tExercise.isAutoStart,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: tExercise.linkedTrainingId!,
          tExerciseId: tExercise.id,
          setNumber: setIndex,
          trainingVersionId: lastTrainingVersionId,
          intervalNumber: null,
        )));

    context.read<ActiveTrainingBloc>().add(CreateTimer(
            timerState: TimerState(
          timerId: restTimerId,
          isActive: false,
          isStarted: false,
          isRunTimer: false,
          timerValue: 0,
          countDownValue:
              isLastSet ? tExercise.exerciseRest ?? 0 : tExercise.setRest ?? 0,
          isCountDown: true,
          isAutostart: true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: tExercise.linkedTrainingId!,
          tExerciseId: tExercise.id,
          setNumber: setIndex,
          trainingVersionId: lastTrainingVersionId,
          intervalNumber: null,
        )));

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

        return GestureDetector(
          onTap: () async {
            context
                .read<ActiveTrainingBloc>()
                .add(StartTimer(timerId: timerId));
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: isStarted ? AppColors.platinum : AppColors.licorice,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Text(
              isStarted
                  ? '${tr('global_done')} ${formatDurationToMinutesSeconds(tExercise.duration ?? 0)}'
                  : '${tr('global_start')} ${formatDurationToMinutesSeconds(tExercise.duration ?? 0)}',
              style: TextStyle(
                  color: isStarted ? AppColors.frenchGray : AppColors.white),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
