import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../base_exercise_management/bloc/base_exercise_management_bloc.dart';
import '../../base_exercise_management/models/base_exercise.dart';
import '../../training_management/bloc/training_management_bloc.dart';
import '../../../injection_container.dart';
import '../../training_history/models/history_entry.dart';
import '../../training_history/bloc/training_history_bloc.dart';
import '../../../helper_functions.dart';
import '../bloc/active_training_bloc.dart';
import '../../../app_colors.dart';
import '../../training_management/models/exercise.dart';
import '../../../core/widgets/small_text_field_widget.dart';

class ActiveExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  final int lastTrainingVersionId;
  final int exerciseIndex;
  final bool isLast;
  const ActiveExerciseWidget({
    super.key,
    required this.exercise,
    required this.isLast,
    required this.exerciseIndex,
    required this.lastTrainingVersionId,
  });

  @override
  State<ActiveExerciseWidget> createState() => _ActiveExerciseWidgetState();
}

class _ActiveExerciseWidgetState extends State<ActiveExerciseWidget> {
  late final Map<String, TextEditingController>? _controllers;
  late final Map<String, int?> _setHistoryIds;

  final training =
      (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
          .activeTraining!;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final sets = widget.exercise.sets;
    final historyBlocState = sl<TrainingHistoryBloc>().state;

    if (historyBlocState is TrainingHistoryLoaded) {
      final entries = historyBlocState.historyTrainings
          .where((trainingHistory) =>
              trainingHistory.training.id == widget.exercise.trainingId)
          .toList()
          .sortedBy((entry) => entry.date)
          .lastOrNull
          ?.historyEntries;

      _setHistoryIds = {
        for (int i = 1; i <= sets; i++) ...{
          'idSet$i': entries
              ?.where((entry) =>
                  entry.exerciseId == widget.exercise.id &&
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
                            entry.exerciseId == widget.exercise.id &&
                            entry.setNumber == i - 1 &&
                            entry.weight != 0)
                        .toList()
                        .sortedBy((entry) => entry.date)
                        .lastOrNull
                        ?.weight
                        .toString() ??
                    ''
                : '',
          ),
          'repsSet$i': TextEditingController(
            text: entries != null
                ? entries
                        .where((entry) =>
                            entry.exerciseId == widget.exercise.id &&
                            entry.setNumber == i - 1 &&
                            entry.reps != 0)
                        .toList()
                        .sortedBy((entry) => entry.date)
                        .lastOrNull
                        ?.reps
                        .toString() ??
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
    return BlocBuilder<BaseExerciseManagementBloc, BaseExerciseManagementState>(
      builder: (context, exerciseBlocState) {
        final matchingExercise = exerciseBlocState
                is BaseExerciseManagementLoaded
            ? exerciseBlocState.baseExercises
                .firstWhereOrNull((e) => e.id == widget.exercise.baseExerciseId)
            : null;

        return Column(
          children: [
            _buildExercise(matchingExercise, widget.exercise, context,
                widget.lastTrainingVersionId),
            _buildExerciseRest(),
          ],
        );
      },
    );
  }

  Widget _buildExercise(
    BaseExercise? baseExercise,
    Exercise exercise,
    BuildContext context,
    int lastTrainingVersionId,
  ) {
    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        final isSetsInReps = widget.exercise.isSetsInReps;
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
                  header: _buildExpandableHeader(
                      baseExercise, context, isSetsInReps),
                  collapsed: const SizedBox(),
                  expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (baseExercise != null &&
                          baseExercise.description.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('exercise_detail_page_description'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              baseExercise.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: AppColors.frenchGray),
                            ),
                          ],
                        ),
                      if (exercise.objectives.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('global_objectives'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(exercise.objectives),
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
                  itemCount: widget.exercise.sets,
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
                                  exercise: widget.exercise,
                                  isLastSet: widget.exercise.sets == index + 1,
                                  exerciseIndex: widget.exerciseIndex,
                                  setIndex: index,
                                  exerciseGlobalKey: widget.key! as GlobalKey,
                                  lastTrainingVersionId: lastTrainingVersionId,
                                )
                              : ActiveExerciseDurationRow(
                                  exercise: widget.exercise,
                                  isLastSet: widget.exercise.sets == index + 1,
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
      BaseExercise? baseExercise, BuildContext context, bool isSetsInReps) {
    return Builder(builder: (context) {
      final controller = ExpandableController.of(context);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (baseExercise != null && baseExercise.imagePath.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  width: 130,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(baseExercise.imagePath),
                      width: MediaQuery.of(context).size.width - 40,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          if (baseExercise != null && baseExercise.imagePath.isNotEmpty)
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
                        baseExercise != null
                            ? baseExercise.name
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
                      '${widget.exercise.minReps}-${widget.exercise.maxReps} reps')
                else
                  Text(
                      '${widget.exercise.duration} ${tr('active_training_seconds')}'),
                Text(
                  '${formatDurationToMinutesSeconds(widget.exercise.setRest)} ${tr('active_training_rest')}',
                ),
                if (widget.exercise.specialInstructions.isNotEmpty)
                  Text(widget.exercise.specialInstructions),
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
              widget.exercise.exerciseRest != 0
                  ? formatDurationToMinutesSeconds(widget.exercise.exerciseRest)
                  : '0:00',
            ),
        ],
      ),
    );
  }
}

class ActiveExerciseRow extends StatefulWidget {
  final int? historyEntryId;
  final Exercise exercise;
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
    required this.exercise,
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
              ? widget.exercise.exerciseRest
              : widget.exercise.setRest,
          isCountDown: true,
          isAutostart: false,
          exerciseGlobalKey: widget.exerciseGlobalKey,
          trainingId: widget.exercise.trainingId!,
          exerciseId: widget.exercise.id!,
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

                if (widget.exercise.isSetsInReps) {
                  cals = getCalories(
                      intensity: widget.exercise.intensity,
                      reps: int.tryParse(widget.repsController.text));
                } else {
                  cals = getCalories(
                      intensity: widget.exercise.intensity,
                      duration: widget.exercise.duration);
                }

                context.read<TrainingHistoryBloc>().add(
                      CreateOrUpdateHistoryEntry(
                        historyEntry: HistoryEntry(
                          id: widget.historyEntryId,
                          trainingId: widget.exercise.trainingId!,
                          exerciseId: widget.exercise.id!,
                          setNumber: widget.setIndex,
                          date: DateTime.now(),
                          reps: int.tryParse(widget.repsController.text) ?? 0,
                          weight:
                              int.tryParse(widget.weightController.text) ?? 0,
                          calories: cals,
                          trainingVersionId: widget.lastTrainingVersionId,
                          intervalNumber: null,
                          duration: 0,
                          distance: 0,
                          pace: 0,
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
  final Exercise exercise;
  final bool isLastSet;
  final int exerciseIndex;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const ActiveExerciseDurationRow({
    super.key,
    required this.exercise,
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
          countDownValue: exercise.duration,
          timerValue: 0,
          isAutostart: exercise.isAutoStart,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: exercise.trainingId!,
          exerciseId: exercise.id!,
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
          countDownValue: isLastSet ? exercise.exerciseRest : exercise.setRest,
          isCountDown: true,
          isAutostart: true,
          exerciseGlobalKey: exerciseGlobalKey,
          trainingId: exercise.trainingId!,
          exerciseId: exercise.id!,
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
                  ? '${tr('global_done')} ${formatDurationToMinutesSeconds(exercise.duration)}'
                  : '${tr('global_start')} ${formatDurationToMinutesSeconds(exercise.duration)}',
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
