import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_colors.dart';
import '../../domain/entities/training_exercise.dart';
import '../bloc/training_management_bloc.dart';
import 'big_text_field_widget.dart';
import 'more_widget.dart';
import 'small_text_field_widget.dart';

import '../../../../core/messages/bloc/message_bloc.dart';

class RunExerciseWidget extends StatefulWidget {
  final String exerciseKey;
  const RunExerciseWidget({super.key, required this.exerciseKey});

  @override
  State<RunExerciseWidget> createState() => _RunExerciseWidgetState();
}

class _RunExerciseWidgetState extends State<RunExerciseWidget> {
  Timer? _debounceTimer;

  final Map<String, TextEditingController> _controllers = {
    'specialInstructions': TextEditingController(),
    'objectives': TextEditingController(),
    'distance': TextEditingController(),
    'durationHours': TextEditingController(),
    'durationMinutes': TextEditingController(),
    'durationSeconds': TextEditingController(),
    'intervals': TextEditingController(),
    'rythmMinutes': TextEditingController(),
    'rythmSeconds': TextEditingController(),
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
      final trainingExercises =
          currentState.selectedTraining?.trainingExercises ?? [];
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
      _controllers['rythmMinutes']?.text = (exercise.targetRythm != null
          ? (exercise.targetRythm! % 3600 ~/ 60).toString()
          : '');
      _controllers['rythmSeconds']?.text = (exercise.targetRythm != null
          ? (exercise.targetRythm! % 60).toString()
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
        currentState.selectedTraining!.trainingExercises,
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
          targetRythm: key == 'rythmMinutes' || key == 'rythmSeconds'
              ? ((int.tryParse(_controllers['rythmMinutes']?.text ?? '') ?? 0) *
                      60) +
                  ((int.tryParse(_controllers['rythmSeconds']?.text ?? '') ??
                      0))
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

      bloc.add(UpdateSelectedTrainingProperty(
          trainingExercises: updatedTrainingExercisesList));
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
          _buildTargetRythm(),
          _buildSetRestRow(),
          _buildExerciseRestRow(),
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
        MoreWidget(exerciseKey: widget.exerciseKey),
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

  Widget _buildSetRestRow() {
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

  Widget _buildTargetChoiceOptions() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final runExerciseTarget = state.selectedTraining!.trainingExercises
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
          currentState.selectedTraining!.trainingExercises);
      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      final updatedExercise = updatedTrainingExercisesList
          .firstWhere((exercise) => exercise.key == widget.exerciseKey)
          .copyWith(runExerciseTarget: choiceValue);

      updatedTrainingExercisesList[index] = updatedExercise;

      bloc.add(UpdateSelectedTrainingProperty(
          trainingExercises: updatedTrainingExercisesList));
    }
  }

  Widget _buildIntervalsChoiceOptions() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final isIntervalInDistance = state.selectedTraining!.trainingExercises
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
            .trainingExercises
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

  void _updateBlocIntervals(bool choiceValue) {
    final bloc = context.read<TrainingManagementBloc>();

    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      final updatedTrainingExercisesList = List<TrainingExercise>.from(
          currentState.selectedTraining!.trainingExercises);
      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      final updatedExercise = updatedTrainingExercisesList
          .firstWhere((exercise) => exercise.key == widget.exerciseKey)
          .copyWith(isIntervalInDistance: choiceValue);

      updatedTrainingExercisesList[index] = updatedExercise;

      bloc.add(UpdateSelectedTrainingProperty(
          trainingExercises: updatedTrainingExercisesList));
    }
  }

  Widget _buildTargetRythm() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
        builder: (context, state) {
      if (state is TrainingManagementLoaded) {
        final isTargetRythmSelected = state.selectedTraining!.trainingExercises
                .firstWhere((exercise) => exercise.key == widget.exerciseKey)
                .isTargetRythmSelected ??
            false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 20,
              child: Theme(
                data: Theme.of(context).copyWith(
                  checkboxTheme: CheckboxThemeData(
                    side: WidgetStateBorderSide.resolveWith(
                      (states) {
                        return const BorderSide(
                            color: AppColors.lightBlack, width: 2);
                      },
                    ),
                    fillColor: WidgetStateProperty.resolveWith(
                      (states) {
                        return AppColors.white;
                      },
                    ),
                  ),
                ),
                child: Checkbox(
                    checkColor: AppColors.black,
                    value: isTargetRythmSelected,
                    onChanged: (value) {
                      final bloc = context.read<TrainingManagementBloc>();

                      if (bloc.state is TrainingManagementLoaded) {
                        final currentState =
                            bloc.state as TrainingManagementLoaded;
                        final updatedTrainingExercisesList =
                            List<TrainingExercise>.from(currentState
                                .selectedTraining!.trainingExercises);

                        final index = updatedTrainingExercisesList.indexWhere(
                          (exercise) => exercise.key == widget.exerciseKey,
                        );

                        final updatedExercise = updatedTrainingExercisesList
                            .firstWhere((exercise) =>
                                exercise.key == widget.exerciseKey)
                            .copyWith(isTargetRythmSelected: value);

                        updatedTrainingExercisesList[index] = updatedExercise;

                        bloc.add(UpdateSelectedTrainingProperty(
                            trainingExercises: updatedTrainingExercisesList));
                      }
                    }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('exercise_rythm'),
                      style: const TextStyle(color: AppColors.lightBlack)),
                  Row(
                    children: [
                      SmallTextFieldWidget(
                        controller: _controllers['rythmMinutes']!,
                        textColor: isTargetRythmSelected
                            ? AppColors.black
                            : AppColors.lightBlack,
                      ),
                      Text(' : ',
                          style: TextStyle(
                            fontSize: 20,
                            color: isTargetRythmSelected
                                ? AppColors.black
                                : AppColors.lightBlack,
                          )),
                      SmallTextFieldWidget(
                        controller: _controllers['rythmSeconds']!,
                        textColor: isTargetRythmSelected
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
