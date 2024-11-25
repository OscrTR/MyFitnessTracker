import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/big_text_field_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/more_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/multiset_exercise_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/multiset_run_exercise_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/small_text_field_widget.dart';
import 'package:uuid/uuid.dart';

import '../../../../assets/app_colors.dart';

class MultisetWidget extends StatefulWidget {
  final String multisetKey;
  const MultisetWidget({super.key, required this.multisetKey});

  @override
  State<MultisetWidget> createState() => _MultisetWidgetState();
}

class _MultisetWidgetState extends State<MultisetWidget> {
  Timer? _debounceTimer;
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    _initializeControllers();
    _attachListeners();
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    _controllers = {
      'sets': TextEditingController(),
      'specialInstructions': TextEditingController(),
      'objectives': TextEditingController(),
      'setRestMinutes': TextEditingController(),
      'setRestSeconds': TextEditingController(),
      'multisetRestMinutes': TextEditingController(),
      'multisetRestSeconds': TextEditingController(),
    };
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final multisets = currentState.selectedTraining?.multisets ?? [];
      final multiset = multisets
          .firstWhere((multiset) => multiset.key == widget.multisetKey);

      _controllers['sets']?.text = multiset.sets?.toString() ?? '';
      _controllers['setRestMinutes']?.text = (multiset.setRest != null
          ? (multiset.setRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['setRestSeconds']?.text =
          (multiset.setRest != null ? (multiset.setRest! % 60).toString() : '');
      _controllers['multisetRestMinutes']?.text = (multiset.multisetRest != null
          ? (multiset.multisetRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['multisetRestSeconds']?.text = (multiset.multisetRest != null
          ? (multiset.multisetRest! % 60).toString()
          : '');
      _controllers['specialInstructions']?.text =
          multiset.specialInstructions?.toString() ?? '';
      _controllers['objectives']?.text = multiset.objectives?.toString() ?? '';
    }
  }

  void _attachListeners() {
    _controllers.forEach((key, controller) {
      controller.addListener(() => _onControllerChanged(key));
    });
  }

  void _onControllerChanged(String key) {
    _debounce(() => _updateInBloc(key));
  }

  void _debounce(Function() action,
      [Duration delay = const Duration(milliseconds: 500)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  void _updateInBloc(String key) {
    final bloc = context.read<TrainingManagementBloc>();

    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      final updatedMultisetsList = List<Multiset>.from(
        currentState.selectedTraining!.multisets,
      );

      final index = updatedMultisetsList.indexWhere(
        (multiset) => multiset.key == widget.multisetKey,
      );

      if (index != -1) {
        final updatedMultiset = updatedMultisetsList[index].copyWith(
          sets: key == 'sets'
              ? int.tryParse(_controllers['sets']?.text ?? '')
              : null,
          setRest: key == 'setRestMinutes' || key == 'setRestSeconds'
              ? ((int.tryParse(_controllers['setRestMinutes']?.text ?? '') ??
                          0) *
                      60) +
                  ((int.tryParse(_controllers['setRestSeconds']?.text ?? '') ??
                      0))
              : null,
          multisetRest: key == 'multisetRestMinutes' ||
                  key == 'multisetRestSeconds'
              ? ((int.tryParse(_controllers['multisetRestMinutes']?.text ??
                              '') ??
                          0) *
                      60) +
                  ((int.tryParse(
                          _controllers['multisetRestSeconds']?.text ?? '') ??
                      0))
              : null,
          specialInstructions: key == 'specialInstructions'
              ? _controllers['specialInstructions']?.text ?? ''
              : null,
          objectives: key == 'objectives'
              ? _controllers['objectives']?.text ?? ''
              : null,
        );

        // Replace the old exercise with the updated one in the list
        updatedMultisetsList[index] = updatedMultiset;
      } else {
        // Handle the case where the key is not found (optional)
        print('Multiset with key ${widget.multisetKey} not found.');
      }

      bloc.add(UpdateSelectedTrainingProperty(multisets: updatedMultisetsList));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.lightBlack),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSetsRow(),
            _buildSetRestRow(),
            _buildMultisetRestRow(),
            const SizedBox(height: 10),
            BigTextFieldWidget(
                controller: _controllers['specialInstructions']!,
                hintText: 'Special instructions'),
            const SizedBox(height: 10),
            BigTextFieldWidget(
                controller: _controllers['objectives']!,
                hintText: 'Objectives'),
            const SizedBox(height: 10),
            _buildExercisesList(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ));
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Multiset', style: TextStyle(color: AppColors.lightBlack)),
        MoreWidget(multisetKey: widget.multisetKey),
      ],
    );
  }

  Widget _buildSetsRow() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sets', style: TextStyle(color: AppColors.lightBlack)),
          SmallTextFieldWidget(controller: _controllers['sets']!),
        ],
      ),
    );
  }

  Widget _buildSetRestRow() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Set rest', style: TextStyle(color: AppColors.lightBlack)),
          Row(
            children: [
              SmallTextFieldWidget(controller: _controllers['setRestMinutes']!),
              const Text(' : ', style: TextStyle(fontSize: 20)),
              SmallTextFieldWidget(controller: _controllers['setRestSeconds']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultisetRestRow() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Multiset rest',
              style: TextStyle(color: AppColors.lightBlack)),
          Row(
            children: [
              SmallTextFieldWidget(
                  controller: _controllers['multisetRestMinutes']!),
              const Text(' : ', style: TextStyle(fontSize: 20)),
              SmallTextFieldWidget(
                  controller: _controllers['multisetRestSeconds']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    const uuid = Uuid();
    final multisetExercises = (context.read<TrainingManagementBloc>().state
                as TrainingManagementLoaded)
            .selectedTraining
            ?.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises ??
        [];
    final nextPosition = multisetExercises.length;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<TrainingManagementBloc>().add(
                    AddExerciseToSelectedTrainingMultisetEvent(
                      widget.multisetKey,
                      TrainingExercise(
                        id: null,
                        trainingId: null,
                        multisetId: null,
                        exerciseId: null,
                        trainingExerciseType: TrainingExerciseType.workout,
                        specialInstructions: null,
                        objectives: null,
                        targetDistance: null,
                        targetDuration: null,
                        targetRythm: null,
                        intervals: null,
                        intervalDistance: null,
                        intervalDuration: null,
                        intervalRest: null,
                        sets: null,
                        isSetsInReps: null,
                        minReps: null,
                        maxReps: null,
                        actualReps: null,
                        duration: null,
                        setRest: null,
                        exerciseRest: null,
                        manualStart: null,
                        position: nextPosition,
                        key: uuid.v4(),
                        runExerciseTarget: RunExerciseTarget.distance,
                      ),
                    ),
                  );
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightBlack),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(context.tr('training_detail_page_add_exercise')),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<TrainingManagementBloc>().add(
                    AddExerciseToSelectedTrainingMultisetEvent(
                      widget.multisetKey,
                      TrainingExercise(
                        id: null,
                        trainingId: null,
                        multisetId: null,
                        exerciseId: null,
                        trainingExerciseType: TrainingExerciseType.run,
                        specialInstructions: null,
                        objectives: null,
                        runExerciseTarget: RunExerciseTarget.distance,
                        targetDistance: null,
                        targetDuration: null,
                        isTargetRythmSelected: false,
                        targetRythm: null,
                        intervals: null,
                        isIntervalInDistance: true,
                        intervalDistance: null,
                        intervalDuration: null,
                        intervalRest: null,
                        sets: null,
                        isSetsInReps: null,
                        minReps: null,
                        maxReps: null,
                        actualReps: null,
                        duration: null,
                        setRest: null,
                        exerciseRest: null,
                        manualStart: null,
                        position: nextPosition,
                        key: uuid.v4(),
                      ),
                    ),
                  );
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightBlack),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(context.tr('training_detail_page_add_run')),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildExercisesList() {
    final multisetExercises = (context.read<TrainingManagementBloc>().state
                as TrainingManagementLoaded)
            .selectedTraining
            ?.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises ??
        [];
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final exercise = multisetExercises[index];
          if (exercise.trainingExerciseType != TrainingExerciseType.run) {
            return MultisetExerciseWidget(
                multisetKey: widget.multisetKey, exerciseKey: exercise.key!);
          }
          return MultisetRunExerciseWidget(
              multisetKey: widget.multisetKey, exerciseKey: exercise.key!);
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 10);
        },
        itemCount: multisetExercises.length);
  }
}
