import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helper_functions.dart';
import '../../../training_history/domain/entities/history_entry.dart';
import '../../../training_history/presentation/bloc/training_history_bloc.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';
import '../bloc/active_training_bloc.dart';
import '../../../training_management/domain/entities/multiset.dart';

import '../../../../app_colors.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
import '../../../../core/widgets/small_text_field_widget.dart';

class ActiveMultisetExerciseWidget extends StatefulWidget {
  final Multiset multiset;
  final TrainingExercise tExercise;
  final int multisetIndex;
  final int multisetExerciseIndex;
  final bool isLast;
  const ActiveMultisetExerciseWidget(
      {super.key,
      required this.multiset,
      required this.tExercise,
      required this.isLast,
      required this.multisetIndex,
      required this.multisetExerciseIndex});

  @override
  State<ActiveMultisetExerciseWidget> createState() =>
      _ActiveMultisetExerciseWidgetState();
}

class _ActiveMultisetExerciseWidgetState
    extends State<ActiveMultisetExerciseWidget> {
  Timer? _debounceTimer;
  late final Map<String, TextEditingController>? _controllers;

  @override
  void initState() {
    _initializeControllers();
    _attachListeners();
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _controllers!.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    final sets = widget.multiset.sets ?? 0;
    _controllers = {
      for (int i = 1; i <= sets; i++) ...{
        'weightSet$i': TextEditingController(),
        'repsSet$i': TextEditingController(),
      },
    };
  }

  void _attachListeners() {
    _controllers?.forEach((key, controller) {
      controller.addListener(() => _debounce(() => _updateBloc(key)));
    });
  }

  void _updateBloc(String key) {}

  void _debounce(Function() action,
      [Duration delay = const Duration(milliseconds: 500)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
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

        final isSetsInReps = widget.tExercise.isSetsInReps ?? true;

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
              child:
                  BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
                      builder: (context, exerciseBlocState) {
                final matchingExercise =
                    exerciseBlocState is ExerciseManagementLoaded
                        ? exerciseBlocState.exercises.firstWhereOrNull(
                            (e) => e.id == widget.tExercise.exerciseId)
                        : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ExpandablePanel(
                      header: _buildExpandableHeader(
                          matchingExercise!, context, isSetsInReps),
                      collapsed: const SizedBox(),
                      expanded: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (matchingExercise.description != null &&
                              matchingExercise.description!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('exercise_detail_page_description'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  matchingExercise.description!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: AppColors.frenchGray),
                                ),
                              ],
                            ),
                          if (widget.tExercise.objectives != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('global_objectives'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('${widget.tExercise.objectives}'),
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
            if (!widget.isLast && widget.tExercise.exerciseRest != null)
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
              widget.tExercise.exerciseRest != null
                  ? formatDurationToMinutesSeconds(
                      widget.tExercise.exerciseRest)
                  : '0:00',
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableHeader(
      Exercise exercise, BuildContext context, bool isSetsInReps) {
    return Builder(builder: (context) {
      final controller = ExpandableController.of(context);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise.imagePath != null && exercise.imagePath!.isNotEmpty)
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
          if (exercise.imagePath != null && exercise.imagePath!.isNotEmpty)
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
                        exercise.name,
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
                      '${widget.tExercise.minReps ?? 0}-${widget.tExercise.maxReps ?? 0} ${tr('active_training_reps')}')
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

  ListView _buildSets() {
    final isSetsInReps = widget.tExercise.isSetsInReps ?? true;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.multiset.sets ?? 0,
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
                      weightController: _controllers!['weightSet${index + 1}']!,
                      repsController: _controllers['repsSet${index + 1}']!,
                      multiset: widget.multiset,
                      tExercise: widget.tExercise,
                      isLastSet: widget.multiset.sets == index + 1,
                      isLastMultisetExercise:
                          widget.multiset.trainingExercises!.length ==
                              widget.tExercise.position! + 1,
                      multisetIndex: widget.multisetIndex,
                      multisetExerciseIndex: widget.multisetExerciseIndex,
                      setIndex: index,
                      exerciseGlobalKey: widget.key! as GlobalKey,
                    )
                  : ActiveExerciseDurationRow(
                      tExercise: widget.tExercise,
                      multiset: widget.multiset,
                      isLastSet: widget.multiset.sets == index + 1,
                      isLastMultisetExercise:
                          widget.multiset.trainingExercises!.length ==
                              widget.tExercise.position! + 1,
                      multisetIndex: widget.multisetIndex,
                      multisetExerciseIndex: widget.multisetExerciseIndex,
                      setIndex: index,
                      exerciseGlobalKey: widget.key! as GlobalKey,
                    )
            ],
          ),
        );
      },
    );
  }
}

class ActiveExerciseRow extends StatefulWidget {
  final Multiset multiset;
  final TrainingExercise tExercise;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final int multisetIndex;
  final int multisetExerciseIndex;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;

  const ActiveExerciseRow({
    super.key,
    required this.multiset,
    required this.tExercise,
    required this.weightController,
    required this.repsController,
    required this.isLastSet,
    required this.isLastMultisetExercise,
    required this.multisetIndex,
    required this.multisetExerciseIndex,
    required this.setIndex,
    required this.exerciseGlobalKey,
  });

  @override
  State<ActiveExerciseRow> createState() => _ActiveExerciseRowState();
}

class _ActiveExerciseRowState extends State<ActiveExerciseRow> {
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final restTimerId =
        '${widget.multisetIndex < 10 ? 0 : ''}${widget.multisetIndex}-${widget.setIndex < 10 ? 0 : ''}${widget.setIndex}-${widget.multisetExerciseIndex < 10 ? 0 : ''}${widget.multisetExerciseIndex}';

    context.read<ActiveTrainingBloc>().add(CreateTimer(
        timerState: TimerState(
            timerId: restTimerId,
            isActive: false,
            isStarted: false,
            isRunTimer: false,
            timerValue: 0,
            countDownValue: widget.isLastMultisetExercise
                ? widget.isLastSet
                    ? widget.multiset.multisetRest ?? 0
                    : widget.multiset.setRest ?? 0
                : widget.tExercise.exerciseRest ?? 0,
            isCountDown: true,
            isAutostart: false,
            exerciseGlobalKey: widget.exerciseGlobalKey,
            trainingId: null,
            tExerciseId: null,
            setNumber: null,
            multisetSetNumber: null)));

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

        int? registeredId;

        if (!isInitialized) {
          final entries = (context.read<TrainingHistoryBloc>().state
                  as TrainingHistoryLoaded)
              .historyEntries;
          final List<HistoryEntry> matchingEntries = List.from(entries.where(
              (el) =>
                  el.trainingExerciseId == widget.tExercise.id &&
                  el.setNumber == widget.setIndex &&
                  el.trainingId == widget.tExercise.trainingId));

          final latestEntry = matchingEntries.isNotEmpty
              ? matchingEntries.reduce((HistoryEntry a, HistoryEntry b) =>
                  a.date.isAfter(b.date) ? a : b)
              : null;

          registeredId = latestEntry?.id;
          if (registeredId != null &&
              widget.weightController.text == '' &&
              widget.repsController.text == '') {
            widget.weightController.text =
                latestEntry?.weight?.toString() ?? '';
            widget.repsController.text = latestEntry?.reps?.toString() ?? '';
            isInitialized = true;
          }
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

                if (widget.tExercise.isSetsInReps!) {
                  cals = getCalories(
                      intensity: widget.tExercise.intensity!,
                      reps: int.tryParse(widget.repsController.text));
                } else {
                  cals = getCalories(
                      intensity: widget.tExercise.intensity!,
                      duration: widget.tExercise.duration);
                }

                final training = (context.read<TrainingManagementBloc>().state
                        as TrainingManagementLoaded)
                    .activeTraining!;

                context.read<TrainingHistoryBloc>().add(
                      CreateOrUpdateHistoryEntry(
                        historyEntry: HistoryEntry(
                          id: registeredId,
                          trainingId: widget.tExercise.trainingId!,
                          trainingExerciseId: widget.tExercise.id!,
                          setNumber: widget.setIndex,
                          date: DateTime.now(),
                          reps: int.tryParse(widget.repsController.text),
                          weight: int.tryParse(widget.weightController.text),
                          calories: cals,
                          trainingExerciseType:
                              widget.tExercise.trainingExerciseType!,
                          trainingType: training.type,
                          trainingNameAtTime: training.name,
                          exerciseNameAtTime:
                              findExerciseName(widget.tExercise),
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
  final TrainingExercise tExercise;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final int multisetIndex;
  final int multisetExerciseIndex;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;

  const ActiveExerciseDurationRow({
    super.key,
    required this.multiset,
    required this.tExercise,
    required this.isLastSet,
    required this.isLastMultisetExercise,
    required this.multisetIndex,
    required this.multisetExerciseIndex,
    required this.setIndex,
    required this.exerciseGlobalKey,
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
            countDownValue: tExercise.duration ?? 0,
            isCountDown: true,
            isAutostart: tExercise.autoStart ?? false,
            exerciseGlobalKey: exerciseGlobalKey,
            trainingId: tExercise.trainingId,
            tExerciseId: tExercise.id,
            setNumber: null,
            multisetSetNumber: setIndex,
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
                    ? multiset.multisetRest ?? 0
                    : multiset.setRest ?? 0
                : tExercise.exerciseRest ?? 0,
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
                  ? '${tr('global_done')} ${formatDurationToMinutesSeconds(tExercise.duration ?? 0)}'
                  : '${tr('global_start')} ${formatDurationToHoursMinutesSeconds(tExercise.duration ?? 0)}',
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
