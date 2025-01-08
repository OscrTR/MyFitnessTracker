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
import '../bloc/active_training_bloc.dart';
import '../../../training_management/domain/entities/multiset.dart';

import '../../../../app_colors.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
import '../../../training_management/presentation/widgets/small_text_field_widget.dart';

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
      for (int i = 1; i <= sets; i++) 'set$i': TextEditingController(),
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
    final hasSpecialInstructions =
        widget.tExercise.specialInstructions != null &&
            widget.tExercise.specialInstructions!.isNotEmpty;
    final hasObjectives = widget.tExercise.objectives != null &&
        widget.tExercise.objectives!.isNotEmpty;
    return BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
        builder: (context, state) {
      if (state is ActiveTrainingLoaded) {
        Color exerciseActiveColor =
            widget.tExercise.trainingExerciseType == TrainingExerciseType.yoga
                ? AppColors.purple
                : widget.tExercise.trainingExerciseType ==
                        TrainingExerciseType.workout
                    ? AppColors.orange
                    : AppColors.blue;
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

        return Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActiveExercise ? exerciseActiveColor : AppColors.white,
            border: Border.all(color: AppColors.lightBlack),
            borderRadius: BorderRadius.circular(15),
          ),
          child: BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
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
                  header: _buildExpandableHeader(matchingExercise),
                  collapsed: const SizedBox(),
                  expanded: _buildExpandedContent(matchingExercise, context),
                  theme: const ExpandableThemeData(
                    hasIcon: false,
                    tapHeaderToExpand: true,
                  ),
                ),
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
                const SizedBox(height: 10),
                _buildSets(),
              ],
            );
          }),
        );
      }
      return const SizedBox();
    });
  }

  Container _buildExpandedContent(
      Exercise? matchingExercise, BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightBlack, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: matchingExercise != null &&
                      matchingExercise.imagePath != null &&
                      matchingExercise.imagePath!.isNotEmpty
                  ? Image.file(File(matchingExercise.imagePath!),
                      width: MediaQuery.of(context).size.width - 40,
                      fit: BoxFit.cover)
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 20),
          if (matchingExercise != null &&
              matchingExercise.description != null &&
              matchingExercise.description!.isNotEmpty)
            Text(
              matchingExercise.description!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.lightBlack),
            ),
          if (matchingExercise != null &&
              matchingExercise.description != null &&
              matchingExercise.description!.isNotEmpty)
            const SizedBox(height: 10),
        ],
      ),
    );
  }

  Builder _buildExpandableHeader(Exercise? matchingExercise) {
    final minRep = widget.tExercise.minReps ?? 0;
    final maxRep = widget.tExercise.maxReps ?? 0;

    return Builder(
      builder: (context) {
        final controller = ExpandableController.of(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 250,
              child: Text(
                '${matchingExercise != null ? matchingExercise.name : tr('exercise_unknown')}${minRep != 0 && maxRep != 0 && matchingExercise != null ? (minRep != maxRep ? ' ($minRep-$maxRep reps)' : ' ($minRep reps)') : ''}',
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            Icon(
              controller?.expanded == true
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          ],
        );
      },
    );
  }

  ListView _buildSets() {
    final isSetsInReps = widget.tExercise.isSetsInReps ?? true;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.multiset.sets ?? 0,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set ${index + 1}',
                style: const TextStyle(color: AppColors.lightBlack),
              ),
              isSetsInReps
                  ? ActiveExerciseRow(
                      controller: _controllers!['set${index + 1}']!,
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

class ActiveExerciseRow extends StatefulWidget {
  final Multiset multiset;
  final TrainingExercise tExercise;
  final bool isLastSet;
  final bool isLastMultisetExercise;
  final TextEditingController controller;
  final int multisetIndex;
  final int multisetExerciseIndex;
  final int setIndex;
  final GlobalKey exerciseGlobalKey;

  const ActiveExerciseRow({
    super.key,
    required this.multiset,
    required this.tExercise,
    required this.controller,
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
          if (registeredId != null && widget.controller.text == '') {
            widget.controller.text = latestEntry?.reps.toString() ?? '';
            isInitialized = true;
          }
        }

        return Row(
          children: [
            SmallTextFieldWidget(
              controller: widget.controller,
              backgroungColor:
                  isStarted ? AppColors.lightGrey : AppColors.white,
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                context.read<TrainingHistoryBloc>().add(
                    CreateOrUpdateHistoryEntry(
                        historyEntry: HistoryEntry(
                            id: registeredId,
                            trainingId: widget.tExercise.trainingId,
                            trainingExerciseId: widget.tExercise.id,
                            setNumber: widget.setIndex,
                            date: DateTime.now(),
                            reps: int.tryParse(widget.controller.text))));
                context
                    .read<ActiveTrainingBloc>()
                    .add(StartTimer(timerId: restTimerId));
                FocusScope.of(context).unfocus();
              },
              child: Text(
                isStarted ? 'OK' : tr('global_validate'),
                style: const TextStyle(color: AppColors.lightBlack),
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
                color: isStarted ? AppColors.lightGrey : AppColors.black,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Text(
              isStarted
                  ? 'OK'
                  : '${tr('global_start')} ${formatDurationToHoursMinutesSeconds(tExercise.duration ?? 0)}',
              style: TextStyle(
                  color: isStarted ? AppColors.lightBlack : AppColors.white),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
