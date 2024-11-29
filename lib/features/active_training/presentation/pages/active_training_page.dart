import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/small_text_field_widget.dart';

import '../../../../assets/app_colors.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../training_management/domain/entities/multiset.dart';

class ActiveTrainingPage extends StatelessWidget {
  const ActiveTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          OutlinedButton(
              onPressed: () {
                final bloc = context.read<TrainingManagementBloc>();
                final currentState = bloc.state as TrainingManagementLoaded;
                print(currentState);
              },
              child: const Text('clic')),
          BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
              builder: (context, state) {
            if (state is TrainingManagementLoaded &&
                state.activeTraining != null) {
              final sortedItems = _getSortedTrainingItems(state);

              final exercisesAndMultisetsList = [
                ...state.activeTraining!.trainingExercises
                    .map((e) => {'type': 'exercise', 'data': e}),
                ...state.activeTraining!.multisets
                    .map((m) => {'type': 'multiset', 'data': m}),
              ];
              exercisesAndMultisetsList.sort((a, b) {
                final aPosition = (a['data'] as dynamic).position ?? 0;
                final bPosition = (b['data'] as dynamic).position ?? 0;
                return aPosition.compareTo(bPosition);
              });
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(state, context),
                    const SizedBox(height: 30),
                    _buildTrainingItemList(sortedItems),
                  ],
                ),
              );
            }
            return Center(child: Text(context.tr('error_state')));
          })
        ],
      ),
    );
  }

  Widget _buildHeader(TrainingManagementLoaded state, BuildContext context) {
    return Text(
      state.activeTraining!.name,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  List<Map<String, dynamic>> _getSortedTrainingItems(
      TrainingManagementLoaded state) {
    final items = [
      ...state.activeTraining!.trainingExercises
          .map((e) => {'type': 'exercise', 'data': e}),
      ...state.activeTraining!.multisets
          .map((m) => {'type': 'multiset', 'data': m}),
    ];
    items.sort((a, b) {
      final aPos = (a['data'] as dynamic).position ?? 0;
      final bPos = (b['data'] as dynamic).position ?? 0;
      return aPos.compareTo(bPos);
    });
    return items;
  }

  Widget _buildTrainingItemList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'exercise') {
          final exercise = item['data'] as TrainingExercise;
          return exercise.trainingExerciseType == TrainingExerciseType.run
              ? Text(exercise.id!.toString())
              : ActiveExerciseWidget(tExercise: exercise);
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          return Text(multiset.id!.toString());
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ActiveExerciseWidget extends StatefulWidget {
  final TrainingExercise tExercise;
  const ActiveExerciseWidget({super.key, required this.tExercise});

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
    final exerciseBlocState = context.read<ExerciseManagementBloc>().state;
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
  }

  Row _buildExerciseRest() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.snooze,
          size: 20,
        ),
        const SizedBox(width: 5),
        Text(
          widget.tExercise.exerciseRest != null
              ? _formatDuration(widget.tExercise.exerciseRest)
              : '0:00',
        ),
      ],
    );
  }

  Container _buildExerciseDetails(
      Exercise? matchingExercise, BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              ActiveExerciseRow(
                controller: _controllers!['set${index + 1}']!,
              ),
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
    return Builder(
      builder: (context) {
        final controller = ExpandableController.of(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  matchingExercise != null
                      ? matchingExercise.name
                      : tr('exercise_unknown'),
                ),
              ],
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
                      ? _formatDuration(widget.tExercise.exerciseRest)
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

  String _formatDuration(int? seconds) {
    final minutes = (seconds ?? 0) ~/ 60;
    final remainingSeconds = (seconds ?? 0) % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class ActiveExerciseRow extends StatefulWidget {
  final TextEditingController controller;
  const ActiveExerciseRow({super.key, required this.controller});

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
