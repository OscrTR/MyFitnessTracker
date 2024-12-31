import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../bloc/active_training_bloc.dart';
import '../../../../app_colors.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
import '../../../training_management/presentation/widgets/small_text_field_widget.dart';

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
  Timer? _debounceTimer;
  late final Map<String, TextEditingController>? _controllers;

  @override
  void initState() {
    _initializeControllers();
    _attachListeners();
    super.initState();
  }

  void _initializeControllers() {
    final sets = widget.tExercise.sets ?? 0;
    _controllers = {
      for (int i = 1; i <= sets; i++) 'set$i': TextEditingController(),
    };
  }

  void _attachListeners() {
    _controllers?.forEach((key, controller) {
      controller.addListener(() => _debounce(() => _updateBloc(key)));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _controllers!.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateBloc(String key) {}

  void _debounce(Function() action,
      [Duration delay = const Duration(milliseconds: 500)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
      builder: (context, exerciseBlocState) {
        final matchingExercise = exerciseBlocState is ExerciseManagementLoaded
            ? exerciseBlocState.exercises
                .firstWhereOrNull((e) => e.id == widget.tExercise.exerciseId)
            : null;

        return Column(
          children: [
            _buildExerciseDetails(matchingExercise, context),
            _buildExerciseRest(),
          ],
        );
      },
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
                ? formatDurationToMinutesSeconds(widget.tExercise.exerciseRest)
                : '0:00',
          ),
      ],
    );
  }

  Widget _buildExerciseDetails(
      Exercise? matchingExercise, BuildContext context) {
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
        final exerciseIndex = widget.exerciseIndex;
        if (lastStartedTimerId != null &&
            lastStartedTimerId
                .startsWith('${exerciseIndex < 10 ? 0 : ''}$exerciseIndex')) {
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
          ),
        );
      }
      return const SizedBox();
    });
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

  ListView _buildSets() {
    final isSetsInReps = widget.tExercise.isSetsInReps ?? true;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.tExercise.sets ?? 0,
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
                      tExercise: widget.tExercise,
                      isLastSet: widget.tExercise.sets == index + 1,
                      exerciseIndex: widget.exerciseIndex,
                      setIndex: index,
                    )
                  : ActiveExerciseDurationRow(
                      tExercise: widget.tExercise,
                      isLastSet: widget.tExercise.sets == index + 1,
                      exerciseIndex: widget.exerciseIndex,
                      setIndex: index,
                    )
            ],
          ),
        );
      },
    );
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
            Row(
              children: [
                const Icon(
                  Icons.snooze,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.tExercise.setRest != null
                      ? formatDurationToMinutesSeconds(widget.tExercise.setRest)
                      : '0:00',
                ),
                const SizedBox(width: 10),
                Icon(
                  controller?.expanded == true
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ActiveExerciseRow extends StatelessWidget {
  final TrainingExercise tExercise;
  final int exerciseIndex;
  final int setIndex;
  final bool isLastSet;
  final TextEditingController controller;

  const ActiveExerciseRow({
    super.key,
    required this.controller,
    required this.tExercise,
    required this.isLastSet,
    required this.exerciseIndex,
    required this.setIndex,
  });

  @override
  Widget build(BuildContext context) {
    final restTimerId =
        '${exerciseIndex < 10 ? 0 : ''}$exerciseIndex-${setIndex < 10 ? 0 : ''}$setIndex';
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
          isAutostart: false,
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
              controller: controller,
              backgroungColor:
                  isStarted ? AppColors.lightGrey : AppColors.white,
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                sl<ActiveTrainingBloc>().add(StartTimer(timerId: restTimerId));
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
  final TrainingExercise tExercise;
  final bool isLastSet;
  final int exerciseIndex;
  final int setIndex;

  const ActiveExerciseDurationRow({
    super.key,
    required this.tExercise,
    required this.isLastSet,
    required this.exerciseIndex,
    required this.setIndex,
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
          isAutostart: tExercise.autoStart ?? false,
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
            sl<ActiveTrainingBloc>().add(StartTimer(timerId: timerId));
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
                  : '${tr('global_start')} ${formatDurationToMinutesSeconds(tExercise.duration ?? 0)}',
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
