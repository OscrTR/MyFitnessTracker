import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_colors.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/entities/training_exercise.dart';
import '../bloc/training_management_bloc.dart';
import 'big_text_field_widget.dart';
import 'more_widget.dart';
import 'small_text_field_widget.dart';

import '../../domain/entities/multiset.dart';

class MultisetRunExerciseWidget extends StatefulWidget {
  final String multisetKey;
  final String exerciseKey;
  const MultisetRunExerciseWidget(
      {super.key, required this.multisetKey, required this.exerciseKey});

  @override
  State<MultisetRunExerciseWidget> createState() =>
      _MultisetRunExerciseWidgetState();
}

class _MultisetRunExerciseWidgetState extends State<MultisetRunExerciseWidget> {
  Timer? _debounceTimer;

  final Map<String, TextEditingController> _controllers = {
    'specialInstructions': TextEditingController(),
    'objectives': TextEditingController(),
    'distance': TextEditingController(),
    'durationHours': TextEditingController(),
    'durationMinutes': TextEditingController(),
    'durationSeconds': TextEditingController(),
    'intervals': TextEditingController(),
    'paceMinutes': TextEditingController(),
    'paceSeconds': TextEditingController(),
    'intervalDistance': TextEditingController(),
    'intervalMinutes': TextEditingController(),
    'intervalSeconds': TextEditingController(),
    'intervalRestMinutes': TextEditingController(),
    'intervalRestSeconds': TextEditingController(),
    'exerciseRestMinutes': TextEditingController(),
    'exerciseRestSeconds': TextEditingController(),
  };

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
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final trainingExercises = currentState.selectedTraining?.multisets
              .firstWhere((multiset) => multiset.key == widget.multisetKey)
              .trainingExercises ??
          [];
      final exercise = trainingExercises
          .firstWhere((exercise) => exercise.key == widget.exerciseKey);

      _controllers['specialInstructions']?.text =
          exercise.specialInstructions?.toString() ?? '';
      _controllers['objectives']?.text = exercise.objectives?.toString() ?? '';
      _controllers['distance']?.text = (exercise.targetDistance != null
          ? (exercise.targetDistance! ~/ 1000).toString()
          : '');
      _controllers['durationHours']?.text = (exercise.targetDuration != null
          ? (exercise.targetDuration! ~/ 3600).toString()
          : '');
      _controllers['durationMinutes']?.text = (exercise.targetDuration != null
          ? (exercise.targetDuration! % 3600 ~/ 60).toString()
          : '');
      _controllers['durationSeconds']?.text = (exercise.targetDuration != null
          ? (exercise.targetDuration! % 60).toString()
          : '');
      _controllers['intervals']?.text = exercise.intervals?.toString() ?? '';
      _controllers['paceMinutes']?.text = (exercise.targetPace != null
          ? (exercise.targetPace! % 3600 ~/ 60).toString()
          : '');
      _controllers['paceSeconds']?.text = (exercise.targetPace != null
          ? (exercise.targetPace! % 60).toString()
          : '');
      _controllers['intervalDistance']?.text =
          (exercise.intervalDistance != null
              ? (exercise.intervalDistance! ~/ 1000).toString()
              : '');
      _controllers['intervalMinutes']?.text = (exercise.intervalDuration != null
          ? (exercise.intervalDuration! % 3600 ~/ 60).toString()
          : '');
      _controllers['intervalSeconds']?.text = (exercise.intervalDuration != null
          ? (exercise.intervalDuration! % 60).toString()
          : '');
      _controllers['intervalRestMinutes']?.text = (exercise.intervalRest != null
          ? (exercise.intervalRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['intervalRestSeconds']?.text = (exercise.intervalRest != null
          ? (exercise.intervalRest! % 60).toString()
          : '');
      _controllers['exerciseRestMinutes']?.text = (exercise.exerciseRest != null
          ? (exercise.exerciseRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['exerciseRestSeconds']?.text = (exercise.exerciseRest != null
          ? (exercise.exerciseRest! % 60).toString()
          : '');
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
      final updatedTrainingExercisesList = List<TrainingExercise>.from(
        currentState.selectedTraining!.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises!,
      );

      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      if (index != -1) {
        final updatedExercise = updatedTrainingExercisesList[index].copyWith(
          targetDistance: key == 'distance'
              ? ((double.tryParse((_controllers['distance']?.text ?? '')
                              .replaceAll(',', '.')) ??
                          0) *
                      1000)
                  .toInt()
              : null,
          targetDuration: key == 'durationHours' ||
                  key == 'durationMinutes' ||
                  key == 'durationSeconds'
              ? ((int.tryParse(_controllers['durationHours']?.text ?? '') ??
                          0) *
                      3600) +
                  ((int.tryParse(_controllers['durationMinutes']?.text ?? '') ??
                          0) *
                      60) +
                  ((int.tryParse(_controllers['durationSeconds']?.text ?? '') ??
                      0))
              : null,
          intervals: key == 'intervals'
              ? int.tryParse(_controllers['intervals']?.text ?? '')
              : null,
          targetPace: key == 'paceMinutes' || key == 'paceSeconds'
              ? ((int.tryParse(_controllers['paceMinutes']?.text ?? '') ?? 0) *
                      60) +
                  ((int.tryParse(_controllers['paceSeconds']?.text ?? '') ?? 0))
              : null,
          intervalDistance: key == 'intervalDistance'
              ? ((double.tryParse((_controllers['intervalDistance']?.text ?? '')
                              .replaceAll(',', '.')) ??
                          0) *
                      1000)
                  .toInt()
              : null,
          intervalDuration: key == 'intervalMinutes' || key == 'intervalSeconds'
              ? ((int.tryParse(_controllers['intervalMinutes']?.text ?? '') ??
                          0) *
                      60) +
                  ((int.tryParse(_controllers['intervalSeconds']?.text ?? '') ??
                      0))
              : null,
          specialInstructions: key == 'specialInstructions'
              ? _controllers['specialInstructions']?.text ?? ''
              : null,
          objectives: key == 'objectives'
              ? _controllers['objectives']?.text ?? ''
              : null,
          intervalRest: key == 'intervalRestMinutes' ||
                  key == 'intervalRestSeconds'
              ? ((int.tryParse(_controllers['intervalRestMinutes']?.text ??
                              '') ??
                          0) *
                      60) +
                  ((int.tryParse(
                          _controllers['intervalRestSeconds']?.text ?? '') ??
                      0))
              : null,
          exerciseRest: key == 'exerciseRestMinutes' ||
                  key == 'exerciseRestSeconds'
              ? ((int.tryParse(_controllers['exerciseRestMinutes']?.text ??
                              '') ??
                          0) *
                      60) +
                  ((int.tryParse(
                          _controllers['exerciseRestSeconds']?.text ?? '') ??
                      0))
              : null,
        );

        updatedTrainingExercisesList[index] = updatedExercise;
      } else {
        context.read<MessageBloc>().add(AddMessageEvent(
            message:
                tr('message_exercise_not_found', args: [widget.exerciseKey]),
            isError: true));
      }

      final updatedMultiset = currentState.selectedTraining!.multisets
          .firstWhere((multiset) => multiset.key == widget.multisetKey)
          .copyWith(trainingExercises: updatedTrainingExercisesList);

      final updatedMultisetsList =
          List<Multiset>.from(currentState.selectedTraining!.multisets);

      final multisetIndex = updatedMultisetsList.indexWhere(
        (multiset) => multiset.key == widget.multisetKey,
      );

      updatedMultisetsList[multisetIndex] = updatedMultiset;

      bloc.add(UpdateSelectedTrainingProperty(multisets: updatedMultisetsList));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.lightBlack),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildTargetChoiceOptions(),
          _buildIntervalsChoiceOptions(),
          _buildTargetPace(),
          _buildIntervalRestRow(),
          _buildExerciseRestRow(),
          _buildAutostart(),
          const SizedBox(height: 10),
          BigTextFieldWidget(
              controller: _controllers['specialInstructions']!,
              hintText: tr('global_special_instructions')),
          const SizedBox(height: 10),
          BigTextFieldWidget(
              controller: _controllers['objectives']!,
              hintText: tr('global_objectives'))
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(tr('global_exercise'),
            style: const TextStyle(color: AppColors.lightBlack)),
        MoreWidget(
            multisetKey: widget.multisetKey, exerciseKey: widget.exerciseKey),
      ],
    );
  }

  Widget _buildExerciseRestRow() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('exercise_exercise_rest'),
              style: const TextStyle(color: AppColors.lightBlack)),
          Row(
            children: [
              SmallTextFieldWidget(
                  controller: _controllers['exerciseRestMinutes']!),
              const Text(' : ', style: TextStyle(fontSize: 20)),
              SmallTextFieldWidget(
                  controller: _controllers['exerciseRestSeconds']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChoiceOptions() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final runExerciseTarget = state.selectedTraining!.multisets
                  .firstWhere((multiset) => multiset.key == widget.multisetKey)
                  .trainingExercises!
                  .firstWhere((exercise) => exercise.key == widget.exerciseKey)
                  .runExerciseTarget ??
              RunExerciseTarget.distance;

          return Column(
            children: [
              _buildTargetChoiceOption(
                tr('exercise_distance'),
                RunExerciseTarget.distance,
                runExerciseTarget,
                _controllers['distance'],
              ),
              _buildTargetChoiceOption(
                tr('exercise_duration'),
                RunExerciseTarget.duration,
                runExerciseTarget,
                _controllers['durationHours'],
                _controllers['durationMinutes'],
                _controllers['durationSeconds'],
              ),
              _buildTargetChoiceOption(
                tr('exercise_intervals'),
                RunExerciseTarget.intervals,
                runExerciseTarget,
                _controllers['intervals'],
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTargetChoiceOption(
    String choice,
    RunExerciseTarget choiceValue,
    RunExerciseTarget currentSelection, [
    TextEditingController? controller1,
    TextEditingController? controller2,
    TextEditingController? controller3,
  ]) {
    return GestureDetector(
      onTap: () => _updateBloc(choiceValue),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Radio<RunExerciseTarget>(
              value: choiceValue,
              groupValue: currentSelection,
              onChanged: (value) => _updateBloc(value!),
              activeColor: AppColors.black,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                return currentSelection == choiceValue
                    ? AppColors.black
                    : AppColors.lightBlack;
              }),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  choice,
                  style: const TextStyle(color: AppColors.lightBlack),
                ),
                Row(
                  children: [
                    if (controller1 != null)
                      SmallTextFieldWidget(
                        controller: controller1,
                        textColor: currentSelection == choiceValue
                            ? AppColors.black
                            : AppColors.lightBlack,
                      ),
                    if (controller2 != null)
                      Text(' : ',
                          style: TextStyle(
                            fontSize: 20,
                            color: currentSelection == choiceValue
                                ? AppColors.black
                                : AppColors.lightBlack,
                          )),
                    if (controller2 != null)
                      SmallTextFieldWidget(
                        controller: controller2,
                        textColor: currentSelection == choiceValue
                            ? AppColors.black
                            : AppColors.lightBlack,
                      ),
                    if (controller3 != null)
                      Text(' : ',
                          style: TextStyle(
                            fontSize: 20,
                            color: currentSelection == choiceValue
                                ? AppColors.black
                                : AppColors.lightBlack,
                          )),
                    if (controller3 != null)
                      SmallTextFieldWidget(
                        controller: controller3,
                        textColor: currentSelection == choiceValue
                            ? AppColors.black
                            : AppColors.lightBlack,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateBloc(RunExerciseTarget choiceValue) {
    final bloc = context.read<TrainingManagementBloc>();

    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      final updatedTrainingExercisesList = List<TrainingExercise>.from(
        currentState.selectedTraining!.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises!,
      );

      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      final updatedExercise = updatedTrainingExercisesList
          .firstWhere((exercise) => exercise.key == widget.exerciseKey)
          .copyWith(runExerciseTarget: choiceValue);

      updatedTrainingExercisesList[index] = updatedExercise;

      final updatedMultiset = currentState.selectedTraining!.multisets
          .firstWhere((multiset) => multiset.key == widget.multisetKey)
          .copyWith(trainingExercises: updatedTrainingExercisesList);

      final updatedMultisets =
          List<Multiset>.from(currentState.selectedTraining!.multisets);

      updatedMultisets
          .removeWhere((multiset) => multiset.key == widget.multisetKey);
      updatedMultisets.add(updatedMultiset);

      bloc.add(UpdateSelectedTrainingProperty(multisets: updatedMultisets));
    }
  }

  Widget _buildIntervalsChoiceOptions() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final isIntervalInDistance = state.selectedTraining!.multisets
                  .firstWhere((multiset) => multiset.key == widget.multisetKey)
                  .trainingExercises!
                  .firstWhere((exercise) => exercise.key == widget.exerciseKey)
                  .isIntervalInDistance ??
              true;

          return Column(
            children: [
              _buildIntervalsChoiceOption(
                tr('exercise_interval_distance'),
                true,
                isIntervalInDistance,
                _controllers['intervalDistance'],
              ),
              _buildIntervalsChoiceOption(
                tr('exercise_interval_duration'),
                false,
                isIntervalInDistance,
                _controllers['intervalMinutes'],
                _controllers['intervalSeconds'],
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildIntervalsChoiceOption(
    String choice,
    bool choiceValue,
    bool currentSelection, [
    TextEditingController? controller1,
    TextEditingController? controller2,
  ]) {
    final runExerciseTarget = (context.read<TrainingManagementBloc>().state
                as TrainingManagementLoaded)
            .selectedTraining!
            .multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises!
            .firstWhere((exercise) => exercise.key == widget.exerciseKey)
            .runExerciseTarget ??
        RunExerciseTarget.distance;

    return GestureDetector(
      onTap: () => _updateBlocIntervals(choiceValue),
      child: Row(
        children: [
          const SizedBox(width: 30),
          SizedBox(
            width: 20,
            child: Radio<bool>(
              value: choiceValue,
              groupValue: currentSelection,
              onChanged: (value) => _updateBlocIntervals(value!),
              activeColor: AppColors.black,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                return runExerciseTarget == RunExerciseTarget.intervals
                    ? currentSelection == choiceValue
                        ? AppColors.black
                        : AppColors.lightBlack
                    : AppColors.lightBlack;
              }),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  choice,
                  style: const TextStyle(color: AppColors.lightBlack),
                ),
                Row(
                  children: [
                    if (controller1 != null)
                      SmallTextFieldWidget(
                        controller: controller1,
                        textColor:
                            runExerciseTarget == RunExerciseTarget.intervals
                                ? currentSelection == choiceValue
                                    ? AppColors.black
                                    : AppColors.lightBlack
                                : AppColors.lightBlack,
                      ),
                    if (controller2 != null)
                      Text(' : ',
                          style: TextStyle(
                            fontSize: 20,
                            color:
                                runExerciseTarget == RunExerciseTarget.intervals
                                    ? currentSelection == choiceValue
                                        ? AppColors.black
                                        : AppColors.lightBlack
                                    : AppColors.lightBlack,
                          )),
                    if (controller2 != null)
                      SmallTextFieldWidget(
                        controller: controller2,
                        textColor:
                            runExerciseTarget == RunExerciseTarget.intervals
                                ? currentSelection == choiceValue
                                    ? AppColors.black
                                    : AppColors.lightBlack
                                : AppColors.lightBlack,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalRestRow() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('exercise_interval_rest'),
              style: const TextStyle(color: AppColors.lightBlack)),
          Row(
            children: [
              SmallTextFieldWidget(
                  controller: _controllers['intervalRestMinutes']!),
              const Text(' : ', style: TextStyle(fontSize: 20)),
              SmallTextFieldWidget(
                  controller: _controllers['intervalRestSeconds']!),
            ],
          ),
        ],
      ),
    );
  }

  void _updateBlocIntervals(bool choiceValue) {
    final bloc = context.read<TrainingManagementBloc>();

    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      final updatedTrainingExercisesList = List<TrainingExercise>.from(
        currentState.selectedTraining!.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises!,
      );

      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      final updatedExercise = updatedTrainingExercisesList
          .firstWhere((exercise) => exercise.key == widget.exerciseKey)
          .copyWith(isIntervalInDistance: choiceValue);

      updatedTrainingExercisesList[index] = updatedExercise;

      final updatedMultiset = currentState.selectedTraining!.multisets
          .firstWhere((multiset) => multiset.key == widget.multisetKey)
          .copyWith(trainingExercises: updatedTrainingExercisesList);

      final updatedMultisets =
          List<Multiset>.from(currentState.selectedTraining!.multisets);

      updatedMultisets
          .removeWhere((multiset) => multiset.key == widget.multisetKey);
      updatedMultisets.add(updatedMultiset);

      bloc.add(UpdateSelectedTrainingProperty(multisets: updatedMultisets));
    }
  }

  Widget _buildAutostart() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
        builder: (context, state) {
      if (state is TrainingManagementLoaded) {
        final multiset = state.selectedTraining!.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey);
        final isAutostart = multiset.trainingExercises!
                .firstWhere((exercise) => exercise.key == widget.exerciseKey)
                .autoStart ??
            false;

        return Row(
          children: [
            SizedBox(
              width: 20,
              child: Checkbox(
                value: isAutostart,
                onChanged: (bool? value) {
                  final bloc = context.read<TrainingManagementBloc>();
                  final currentState = bloc.state as TrainingManagementLoaded;

                  final updatedTrainingExercisesList =
                      List<TrainingExercise>.from(multiset.trainingExercises!);

                  final index = updatedTrainingExercisesList.indexWhere(
                    (exercise) => exercise.key == widget.exerciseKey,
                  );

                  final updatedExercise = updatedTrainingExercisesList
                      .firstWhere(
                          (exercise) => exercise.key == widget.exerciseKey)
                      .copyWith(autoStart: !isAutostart);

                  updatedTrainingExercisesList[index] = updatedExercise;

                  final updatedMultiset = currentState
                      .selectedTraining!.multisets
                      .firstWhere(
                          (multiset) => multiset.key == widget.multisetKey)
                      .copyWith(
                          trainingExercises: updatedTrainingExercisesList);

                  final updatedMultisets = List<Multiset>.from(
                      currentState.selectedTraining!.multisets);

                  updatedMultisets.removeWhere(
                      (multiset) => multiset.key == widget.multisetKey);
                  updatedMultisets.add(updatedMultiset);

                  bloc.add(UpdateSelectedTrainingProperty(
                      multisets: updatedMultisets));
                },
              ),
            ),
            const SizedBox(width: 10),
            Text(
              tr('training_detail_page_autostart'),
              style: const TextStyle(color: AppColors.lightBlack),
            ),
          ],
        );
      }
      return const SizedBox();
    });
  }

  Widget _buildTargetPace() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
        builder: (context, state) {
      if (state is TrainingManagementLoaded) {
        final isTargetPaceSelected = state.selectedTraining!.multisets
                .firstWhere((multiset) => multiset.key == widget.multisetKey)
                .trainingExercises!
                .firstWhere((exercise) => exercise.key == widget.exerciseKey)
                .isTargetPaceSelected ??
            false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 20,
              child: Checkbox(
                value: isTargetPaceSelected,
                onChanged: (value) {
                  final bloc = context.read<TrainingManagementBloc>();

                  if (bloc.state is TrainingManagementLoaded) {
                    final currentState = bloc.state as TrainingManagementLoaded;
                    final updatedTrainingExercisesList =
                        List<TrainingExercise>.from(
                      currentState.selectedTraining!.multisets
                          .firstWhere(
                              (multiset) => multiset.key == widget.multisetKey)
                          .trainingExercises!,
                    );

                    final index = updatedTrainingExercisesList.indexWhere(
                      (exercise) => exercise.key == widget.exerciseKey,
                    );

                    final updatedExercise = updatedTrainingExercisesList
                        .firstWhere(
                            (exercise) => exercise.key == widget.exerciseKey)
                        .copyWith(isTargetPaceSelected: value);

                    updatedTrainingExercisesList[index] = updatedExercise;

                    final updatedMultiset = currentState
                        .selectedTraining!.multisets
                        .firstWhere(
                            (multiset) => multiset.key == widget.multisetKey)
                        .copyWith(
                            trainingExercises: updatedTrainingExercisesList);

                    final updatedMultisets = List<Multiset>.from(
                        currentState.selectedTraining!.multisets);

                    updatedMultisets.removeWhere(
                        (multiset) => multiset.key == widget.multisetKey);
                    updatedMultisets.add(updatedMultiset);

                    bloc.add(UpdateSelectedTrainingProperty(
                        multisets: updatedMultisets));
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('exercise_pace'),
                      style: const TextStyle(color: AppColors.lightBlack)),
                  Row(
                    children: [
                      SmallTextFieldWidget(
                        controller: _controllers['paceMinutes']!,
                        textColor: isTargetPaceSelected
                            ? AppColors.black
                            : AppColors.lightBlack,
                      ),
                      Text(' : ',
                          style: TextStyle(
                            fontSize: 20,
                            color: isTargetPaceSelected
                                ? AppColors.black
                                : AppColors.lightBlack,
                          )),
                      SmallTextFieldWidget(
                        controller: _controllers['paceSeconds']!,
                        textColor: isTargetPaceSelected
                            ? AppColors.black
                            : AppColors.lightBlack,
                      ),
                    ],
                  ),
                ],
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
