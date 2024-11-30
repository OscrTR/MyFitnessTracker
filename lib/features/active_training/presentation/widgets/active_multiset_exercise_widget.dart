import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/widgets/timer_widget.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';

import '../../../../assets/app_colors.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
import '../../../training_management/presentation/widgets/small_text_field_widget.dart';

String _formatDuration(int? seconds) {
  final minutes = (seconds ?? 0) ~/ 60;
  final remainingSeconds = (seconds ?? 0) % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

class ActiveMultisetExerciseWidget extends StatefulWidget {
  final Multiset multiset;
  final TrainingExercise tExercise;
  final GlobalKey<TimerWidgetState> timerWidgetKey;
  final bool isLast;
  const ActiveMultisetExerciseWidget(
      {super.key,
      required this.multiset,
      required this.tExercise,
      required this.timerWidgetKey,
      required this.isLast});

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
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.lightBlack),
        borderRadius: BorderRadius.circular(15),
      ),
      child: BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
          builder: (context, exerciseBlocState) {
        final matchingExercise = exerciseBlocState is ExerciseManagementLoaded
            ? exerciseBlocState.exercises
                .firstWhereOrNull((e) => e.id == widget.tExercise.exerciseId)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      matchingExercise != null
                          ? matchingExercise.name
                          : tr('exercise_unknown'),
                    ),
                    if (minRep != 0 &&
                        maxRep != 0 &&
                        minRep != maxRep &&
                        matchingExercise != null)
                      Text(
                        ' ($minRep-$maxRep reps)',
                      ),
                    if (minRep != 0 &&
                        maxRep != 0 &&
                        minRep == maxRep &&
                        matchingExercise != null)
                      Text(
                        ' ($minRep reps)',
                      ),
                  ],
                ),
              ],
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
    final setDuration = widget.tExercise.duration ?? 0;

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
                      tExercise: widget.tExercise,
                      multiset: widget.multiset,
                      timerWidgetKey: widget.timerWidgetKey,
                      isLastSet: widget.multiset.sets == index + 1,
                      isLastExercise:
                          widget.multiset.trainingExercises!.length ==
                              widget.tExercise.position! + 1,
                    )
                  : ActiveExerciseDurationRow(
                      controller: _controllers!['set${index + 1}']!,
                      tExercise: widget.tExercise,
                      multiset: widget.multiset,
                      timerWidgetKey: widget.timerWidgetKey,
                      isLastSet: widget.multiset.sets == index + 1,
                      isLastExercise:
                          widget.multiset.trainingExercises!.length ==
                              widget.tExercise.position! + 1,
                      setDuration: _formatDuration(setDuration),
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
  final TrainingExercise tExercise;
  final Multiset multiset;
  final GlobalKey<TimerWidgetState> timerWidgetKey;
  final bool isLastSet;
  final bool isLastExercise;
  final TextEditingController controller;

  const ActiveExerciseRow({
    super.key,
    required this.controller,
    required this.tExercise,
    required this.multiset,
    required this.timerWidgetKey,
    required this.isLastSet,
    required this.isLastExercise,
  });

  @override
  ActiveExerciseRowState createState() => ActiveExerciseRowState();
}

class ActiveExerciseRowState extends State<ActiveExerciseRow> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmallTextFieldWidget(
          controller: widget.controller,
          backgroungColor: isClicked ? AppColors.lightGrey : AppColors.white,
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            if (widget.isLastExercise) {
              widget.timerWidgetKey.currentState?.resetSecondaryTimer();
              widget.isLastSet
                  ? widget.timerWidgetKey.currentState
                      ?.startSecondaryTimer(widget.multiset.multisetRest ?? 0)
                  : widget.timerWidgetKey.currentState
                      ?.startSecondaryTimer(widget.multiset.setRest ?? 0);
            }
            setState(() {
              isClicked = true;
            });
          },
          child: Text(
            isClicked ? 'OK' : tr('global_validate'),
            style: const TextStyle(color: AppColors.lightBlack),
          ),
        ),
      ],
    );
  }
}

class ActiveExerciseDurationRow extends StatefulWidget {
  final TrainingExercise tExercise;
  final Multiset multiset;
  final GlobalKey<TimerWidgetState> timerWidgetKey;
  final bool isLastSet;
  final bool isLastExercise;
  final TextEditingController controller;
  final String setDuration;
  const ActiveExerciseDurationRow({
    super.key,
    required this.controller,
    required this.tExercise,
    required this.multiset,
    required this.timerWidgetKey,
    required this.isLastSet,
    required this.isLastExercise,
    required this.setDuration,
  });

  @override
  State<ActiveExerciseDurationRow> createState() =>
      _ActiveExerciseDurationRowState();
}

class _ActiveExerciseDurationRowState extends State<ActiveExerciseDurationRow> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        void startRestAfterDuration() {
          widget.timerWidgetKey.currentState?.resetSecondaryTimer();
          widget.isLastSet
              ? widget.timerWidgetKey.currentState
                  ?.startSecondaryTimer(widget.multiset.multisetRest ?? 0)
              : widget.timerWidgetKey.currentState
                  ?.startSecondaryTimer(widget.multiset.setRest ?? 0);
        }

        widget.timerWidgetKey.currentState?.resetSecondaryTimer();
        if (widget.isLastExercise) {
          widget.timerWidgetKey.currentState?.startSecondaryTimer(
              widget.tExercise.duration ?? 0,
              onComplete: startRestAfterDuration);
        } else {
          widget.timerWidgetKey.currentState
              ?.startSecondaryTimer(widget.tExercise.duration ?? 0);
        }

        setState(() {
          isClicked = true;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
            color: isClicked ? AppColors.lightGrey : AppColors.black,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Text(
          isClicked ? 'OK' : '${tr('global_start')} ${widget.setDuration}',
          style: TextStyle(
              color: isClicked ? AppColors.lightBlack : AppColors.white),
        ),
      ),
    );
  }
}
