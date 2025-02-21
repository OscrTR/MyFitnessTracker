import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../helper_functions.dart';
import '../../../injection_container.dart';
import '../../training_history/models/history_entry.dart';
import '../../training_history/bloc/training_history_bloc.dart';
import '../../training_management/bloc/training_management_bloc.dart';
import '../bloc/active_training_bloc.dart';
import '../../training_management/models/multiset.dart';

import '../../../app_colors.dart';
import '../../base_exercise_management/models/base_exercise.dart';
import '../../base_exercise_management/bloc/base_exercise_management_bloc.dart';
import '../../training_management/models/exercise.dart';
import '../../../core/widgets/small_text_field_widget.dart';

class ActiveMultisetExerciseWidget extends StatefulWidget {
  final Multiset multiset;
  final Exercise exercise;
  final int multisetIndex;
  final int multisetExerciseIndex;
  final bool isLast;
  final int lastTrainingVersionId;
  const ActiveMultisetExerciseWidget({
    super.key,
    required this.multiset,
    required this.exercise,
    required this.isLast,
    required this.multisetIndex,
    required this.multisetExerciseIndex,
    required this.lastTrainingVersionId,
  });

  @override
  State<ActiveMultisetExerciseWidget> createState() =>
      _ActiveMultisetExerciseWidgetState();
}

class _ActiveMultisetExerciseWidgetState
    extends State<ActiveMultisetExerciseWidget> {
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, int?> _setHistoryIds;

  final training =
      (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
          .activeTraining!;

  @override
  void initState() {
    super.initState();

    _initializeControllers();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    final sets = widget.multiset.sets;
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
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        bool isActiveExercise = false;
        final lastStartedTimerId = state.lastStartedTimerId;

        if (lastStartedTimerId != null) {
          final isStartTimerSameBeginning = lastStartedTimerId.startsWith(
              '${widget.multisetIndex < 10 ? 0 : ''}${widget.multisetIndex}');
          final isStartTimerSameEnding = (lastStartedTimerId.endsWith(
                  '${widget.multisetExerciseIndex < 10 ? 0 : ''}${widget.multisetExerciseIndex}') ||
              lastStartedTimerId.endsWith(
                  '${widget.multisetExerciseIndex < 10 ? 0 : ''}${widget.multisetExerciseIndex}-rest'));
          if (isStartTimerSameBeginning && isStartTimerSameEnding) {
            isActiveExercise = true;
          }
        }

        final isSetsInReps = widget.exercise.isSetsInReps;

        return Column(
          children: [
            Container(
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
              child: BlocBuilder<BaseExerciseManagementBloc,
                      BaseExerciseManagementState>(
                  builder: (context, exerciseBlocState) {
                final matchingExercise =
                    exerciseBlocState is BaseExerciseManagementLoaded
                        ? exerciseBlocState.baseExercises.firstWhereOrNull(
                            (e) => e.id == widget.exercise.baseExerciseId)
                        : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ExpandablePanel(
                      header: _buildExpandableHeader(
                          matchingExercise, context, isSetsInReps),
                      collapsed: const SizedBox(),
                      expanded: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (matchingExercise != null &&
                              matchingExercise.description.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('exercise_detail_page_description'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  matchingExercise.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: AppColors.frenchGray),
                                ),
                              ],
                            ),
                          if (widget.exercise.objectives.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('global_objectives'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(widget.exercise.objectives),
                              ],
                            ),
                        ],
                      ),
                      theme: const ExpandableThemeData(
                        hasIcon: false,
                        tapHeaderToExpand: true,
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
                    _buildSets(),
                  ],
                );
              }),
            ),
            if (!widget.isLast && widget.exercise.exerciseRest != 0)
              _buildExerciseRest(),
          ],
        );
      }
      return const SizedBox();
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
                        baseExercise?.name ?? tr('global_exercise_unknown'),
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
                      '${widget.exercise.minReps}-${widget.exercise.maxReps} ${tr('active_training_reps')}')
                else
                  Text(
                      '${widget.exercise.duration} ${tr('active_training_seconds')}'),
                Text(
                  '${widget.exercise.setRest != 0 ? formatDurationToMinutesSeconds(widget.exercise.setRest) : '0:00'} ${tr('active_training_rest')}',
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

  ListView _buildSets() {
    final isSetsInReps = widget.exercise.isSetsInReps;

    final List<Exercise> multisetExercises =
        (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
            .activeTraining!
            .exercises
            .where((e) => e.multisetId == widget.multiset.id)
            .toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.multiset.sets,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${index + 1}',
                style: const TextStyle(color: AppColors.taupeGray),
              ),
              isSetsInReps
                  ? ActiveExerciseRow(
                      historyEntryId: _setHistoryIds['idSet${index + 1}'],
                      weightController: _controllers['weightSet${index + 1}']!,
                      repsController: _controllers['repsSet${index + 1}']!,
                      multiset: widget.multiset,
                      exercise: widget.exercise,
                      isLastSet: widget.multiset.sets == index + 1,
                      isLastMultisetExercise: multisetExercises.length ==
                          widget.exercise.position! + 1,
                      multisetIndex: widget.multisetIndex,
                      multisetExerciseIndex: widget.multisetExerciseIndex,
                      setIndex: index,
                      exerciseGlobalKey: widget.key! as GlobalKey,
                      lastTrainingVersionId: widget.lastTrainingVersionId,
                    )
                  : ActiveExerciseDurationRow(
                      exercise: widget.exercise,
                      multiset: widget.multiset,
                      isLastSet: widget.multiset.sets == index + 1,
                      isLastMultisetExercise: multisetExercises.length ==
                          widget.exercise.position! + 1,
                      multisetIndex: widget.multisetIndex,
                      multisetExerciseIndex: widget.multisetExerciseIndex,
                      setIndex: index,
                      exerciseGlobalKey: widget.key! as GlobalKey,
                      lastTrainingVersionId: widget.lastTrainingVersionId,
                    )
            ],
          ),
        );
      },
    );
  }
}

class ActiveExerciseRow extends StatefulWidget {
  final int? historyEntryId;
  final Multiset multiset;
  final Exercise exercise;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final int multisetIndex;
  final int multisetExerciseIndex;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const ActiveExerciseRow({
    super.key,
    required this.historyEntryId,
    required this.multiset,
    required this.exercise,
    required this.weightController,
    required this.repsController,
    required this.isLastSet,
    required this.isLastMultisetExercise,
    required this.multisetIndex,
    required this.multisetExerciseIndex,
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
        '${widget.multisetIndex < 10 ? 0 : ''}${widget.multisetIndex}-${widget.setIndex < 10 ? 0 : ''}${widget.setIndex}-${widget.multisetExerciseIndex < 10 ? 0 : ''}${widget.multisetExerciseIndex}-rest';

    context.read<ActiveTrainingBloc>().add(
          CreateTimer(
            timerState: TimerState(
              timerId: restTimerId,
              isActive: false,
              isStarted: false,
              isRunTimer: false,
              timerValue: 0,
              countDownValue: widget.isLastMultisetExercise
                  ? widget.isLastSet
                      ? widget.multiset.multisetRest
                      : widget.multiset.setRest
                  : widget.exercise.exerciseRest,
              isCountDown: true,
              isAutostart: false,
              exerciseGlobalKey: widget.exerciseGlobalKey,
              trainingId: widget.exercise.trainingId!,
              exerciseId: widget.exercise.id!,
              setNumber: widget.setIndex,
              trainingVersionId: widget.lastTrainingVersionId,
              intervalNumber: null,
            ),
          ),
        );

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
                          id: widget.historyEntryId ?? 0,
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
  final Multiset multiset;
  final Exercise exercise;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final int multisetIndex;
  final int multisetExerciseIndex;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;
  final int lastTrainingVersionId;

  const ActiveExerciseDurationRow({
    super.key,
    required this.multiset,
    required this.exercise,
    required this.isLastSet,
    required this.isLastMultisetExercise,
    required this.multisetIndex,
    required this.multisetExerciseIndex,
    required this.setIndex,
    required this.exerciseGlobalKey,
    required this.lastTrainingVersionId,
  });

  @override
  Widget build(BuildContext context) {
    final timerId =
        '${multisetIndex < 10 ? 0 : ''}$multisetIndex-${setIndex < 10 ? 0 : ''}$setIndex-${multisetExerciseIndex < 10 ? 0 : ''}$multisetExerciseIndex';
    final restTimerId =
        '${multisetIndex < 10 ? 0 : ''}$multisetIndex-${setIndex < 10 ? 0 : ''}$setIndex-${multisetExerciseIndex < 10 ? 0 : ''}$multisetExerciseIndex-rest';

    context.read<ActiveTrainingBloc>().add(CreateTimer(
          timerState: TimerState(
            timerId: timerId,
            isActive: false,
            isStarted: false,
            isRunTimer: false,
            timerValue: 0,
            countDownValue: exercise.duration,
            isCountDown: true,
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

        return GestureDetector(
          onTap: () async {
            context
                .read<ActiveTrainingBloc>()
                .add(StartTimer(timerId: timerId));
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
                color: isStarted ? AppColors.platinum : AppColors.licorice,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Text(
              isStarted
                  ? '${tr('global_done')} ${formatDurationToMinutesSeconds(exercise.duration)}'
                  : '${tr('global_start')} ${formatDurationToHoursMinutesSeconds(exercise.duration)}',
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
