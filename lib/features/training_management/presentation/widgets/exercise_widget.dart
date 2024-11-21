import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/models/exercise_model.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/big_text_field_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/more_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/small_text_field_widget.dart';
import 'package:searchfield/searchfield.dart';

class ExerciseWidget extends StatefulWidget {
  final int widgetId;

  const ExerciseWidget({super.key, required this.widgetId});

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  Timer? _debounceTimer;

  Exercise selectedExercise = const Exercise(name: '');
  TrainingExercise trainingExercise = const TrainingExercise();
  late bool isSetsInReps;
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    _initializeControllers();
    _attachListeners();
    super.initState();
  }

  void _initializeControllers() {
    _controllers = {
      'exercise': TextEditingController(),
      'sets': TextEditingController(),
      'durationMinutes': TextEditingController(),
      'durationSeconds': TextEditingController(),
      'minReps': TextEditingController(),
      'maxReps': TextEditingController(),
      'setRestMinutes': TextEditingController(),
      'setRestSeconds': TextEditingController(),
      'exerciseRestMinutes': TextEditingController(),
      'exerciseRestSeconds': TextEditingController(),
      'specialInstructions': TextEditingController(),
      'objectives': TextEditingController(),
    };
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final exercise =
          currentState.selectedTraining?.trainingExercises[widget.widgetId];

      isSetsInReps = exercise?.isSetsInReps ?? true;

      _controllers['sets']?.text = exercise?.sets?.toString() ?? '';
      _controllers['durationMinutes']?.text = (exercise?.duration != null
          ? (exercise!.duration! % 3600 ~/ 60).toString()
          : '');
      _controllers['durationSeconds']?.text = (exercise?.duration != null
          ? (exercise!.duration! % 60).toString()
          : '');
      _controllers['minReps']?.text = exercise?.minReps?.toString() ?? '';
      _controllers['maxReps']?.text = exercise?.maxReps?.toString() ?? '';
      _controllers['setRestMinutes']?.text = (exercise?.setRest != null
          ? (exercise!.setRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['setRestSeconds']?.text = (exercise?.setRest != null
          ? (exercise!.setRest! % 60).toString()
          : '');
      _controllers['exerciseRestMinutes']?.text =
          (exercise?.exerciseRest != null
              ? (exercise!.exerciseRest! % 3600 ~/ 60).toString()
              : '');
      _controllers['exerciseRestSeconds']?.text =
          (exercise?.exerciseRest != null
              ? (exercise!.exerciseRest! % 60).toString()
              : '');
      _controllers['specialInstructions']?.text =
          exercise?.specialInstructions?.toString() ?? '';
      _controllers['objectives']?.text = exercise?.objectives?.toString() ?? '';
    }
  }

  void _attachListeners() {
    _controllers.forEach((key, controller) {
      controller.addListener(() => _onControllerChanged(key));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged(String key) {
    _debounce(() => _updateInBloc(key));
  }

  void _updateInBloc(String key) {
    final bloc = context.read<TrainingManagementBloc>();

    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      final updatedTrainingExercisesList = List<TrainingExercise>.from(
        currentState.selectedTraining!.trainingExercises,
      );

      final updatedExercise =
          updatedTrainingExercisesList[widget.widgetId].copyWith(
        sets: key == 'sets'
            ? int.tryParse(_controllers['sets']?.text ?? '')
            : null,
        minReps: key == 'minReps'
            ? int.tryParse(_controllers['minReps']?.text ?? '')
            : null,
        maxReps: key == 'maxReps'
            ? int.tryParse(_controllers['maxReps']?.text ?? '')
            : null,
        duration: key == 'durationMinutes' || key == 'durationSeconds'
            ? ((int.tryParse(_controllers['durationMinutes']?.text ?? '') ??
                        0) *
                    60) +
                ((int.tryParse(_controllers['durationSeconds']?.text ?? '') ??
                    0))
            : null,
        setRest: key == 'setRestMinutes' || key == 'setRestSeconds'
            ? ((int.tryParse(_controllers['setRestMinutes']?.text ?? '') ?? 0) *
                    60) +
                ((int.tryParse(_controllers['setRestSeconds']?.text ?? '') ??
                    0))
            : null,
        exerciseRest: key == 'exerciseRestMinutes' ||
                key == 'exerciseRestSeconds'
            ? ((int.tryParse(_controllers['exerciseRestMinutes']?.text ?? '') ??
                        0) *
                    60) +
                ((int.tryParse(
                        _controllers['exerciseRestSeconds']?.text ?? '') ??
                    0))
            : null,
        specialInstructions: key == 'specialInstructions'
            ? _controllers['specialInstructions']?.text ?? ''
            : null,
        objectives:
            key == 'objectives' ? _controllers['objectives']?.text ?? '' : null,

        // Add more fields if necessary
      );

      updatedTrainingExercisesList[widget.widgetId] = updatedExercise;

      bloc.add(UpdateSelectedTrainingProperty(
          trainingExercises: updatedTrainingExercisesList));
    }
  }

  void _debounce(Function() action,
      [Duration delay = const Duration(milliseconds: 500)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
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
          _buildExerciseSearch(),
          const SizedBox(height: 10),
          _buildExerciseDetails(),
          const SizedBox(height: 10),
          const Divider(
            color: AppColors.lightBlack,
          ),
          const SizedBox(height: 10),
          _buildSetsRow(),
          _buildSetsChoiceOptions(),
          _buildSetRestRow(),
          _buildExerciseRestRow(),
          const SizedBox(height: 10),
          BigTextFieldWidget(
              controller: _controllers['specialInstructions']!,
              hintText: 'Special instructions'),
          const SizedBox(height: 10),
          BigTextFieldWidget(
              controller: _controllers['objectives']!, hintText: 'Objectives')
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Exercise', style: TextStyle(color: AppColors.lightBlack)),
        MoreWidget(trainingExercisePosition: widget.widgetId),
      ],
    );
  }

  Widget _buildExerciseSearch() {
    void updateExerciseIdInBloc(int? id) {
      final bloc = context.read<TrainingManagementBloc>();
      final currentState = bloc.state as TrainingManagementLoaded;

      final updatedTrainingExercisesList = List<TrainingExercise>.from(
        currentState.selectedTraining!.trainingExercises,
      );

      final updatedExercise = id != null
          ? updatedTrainingExercisesList[widget.widgetId].copyWith(
              exerciseId: id,
            )
          : updatedTrainingExercisesList[widget.widgetId]
              .copyWithExerciseIdNull();

      updatedTrainingExercisesList[widget.widgetId] = updatedExercise;

      bloc.add(UpdateSelectedTrainingProperty(
          trainingExercises: updatedTrainingExercisesList));
      if (id != null) {
        FocusScope.of(context).unfocus();
      }
    }

    void navigateToCreateExercise() {
      GoRouter.of(context).push('/exercise_detail', extra: 'training_detail');
    }

    String initialExerciseName = '';

    final exercisesList = (context.read<ExerciseManagementBloc>().state
            as ExerciseManagementLoaded)
        .exercises
        .where((element) =>
            element.id ==
            (context.read<TrainingManagementBloc>().state
                    as TrainingManagementLoaded)
                .selectedTraining!
                .trainingExercises[widget.widgetId]
                .exerciseId)
        .toList();

    if (exercisesList.isNotEmpty) {
      initialExerciseName = exercisesList[0].name;
    }

    final initialItem = initialExerciseName != ''
        ? SearchFieldListItem(initialExerciseName)
        : null;

    return SearchField(
      controller: _controllers['exercise'],
      onSuggestionTap: (query) {
        if (query.searchKey == 'Create New Exercise') {
          _controllers['exercise']!.clear();
          FocusScope.of(context).unfocus();
          navigateToCreateExercise();
          return;
        }

        List<Exercise> filteredExercises = (context
                .read<ExerciseManagementBloc>()
                .state as ExerciseManagementLoaded)
            .exercises
            .where((element) =>
                element.name.toLowerCase() == query.searchKey.toLowerCase())
            .toList();
        if (filteredExercises.isNotEmpty) {
          updateExerciseIdInBloc(filteredExercises[0].id!);
        }
      },
      onSearchTextChanged: (query) {
        List<Exercise> filteredExercises = (context
                .read<ExerciseManagementBloc>()
                .state as ExerciseManagementLoaded)
            .exercises
            .where(
                (element) => element.name.toLowerCase() == query.toLowerCase())
            .toList();

        if (filteredExercises.isNotEmpty) {
          updateExerciseIdInBloc(filteredExercises[0].id!);
        } else {
          updateExerciseIdInBloc(null);
        }

        final filter = (context.read<ExerciseManagementBloc>().state
                as ExerciseManagementLoaded)
            .exercises
            .where((element) =>
                element.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Add "Create New Exercise" option if no exact matches are found
        final suggestions =
            filter.map((e) => SearchFieldListItem(e.name)).toList();

        suggestions.add(SearchFieldListItem(
          'Create New Exercise',
          child: const Row(
            children: [
              Icon(Icons.add, color: AppColors.black),
              SizedBox(width: 8),
              Text('Create New Exercise'),
            ],
          ),
        ));

        return suggestions;
      },
      initialValue: initialItem,
      maxSuggestionsInViewPort: 5,
      hint: 'Search an exercise',
      suggestions: (context.read<ExerciseManagementBloc>().state
              as ExerciseManagementLoaded)
          .exercises
          .map((e) => SearchFieldListItem(e.name))
          .toList()
        ..add(SearchFieldListItem(
          'Create New Exercise',
          child: const Row(
            children: [
              Icon(Icons.add, color: AppColors.black),
              SizedBox(width: 8),
              Text('Create New Exercise'),
            ],
          ),
        )),
    );
  }

  Widget _buildExerciseDetails() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final exerciseId = state
              .selectedTraining?.trainingExercises[widget.widgetId].exerciseId;

          const ExerciseModel noExercise = ExerciseModel(name: 'no exercise');

          if (exerciseId != null) {
            final Exercise exercise = (context
                    .read<ExerciseManagementBloc>()
                    .state as ExerciseManagementLoaded)
                .exercises
                .firstWhere(
                  (el) => el.id == exerciseId,
                  orElse: () => noExercise,
                );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseImage(exercise.imagePath),
                SizedBox(height: exercise.description != null ? 10 : 0),
                exercise.description != null
                    ? Text(
                        exercise.description ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: AppColors.lightBlack),
                      )
                    : const SizedBox(),
              ],
            );
          }
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildExerciseImage(String? imagePath) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightBlack, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: imagePath != null && imagePath.isNotEmpty
            ? Image.file(File(imagePath),
                width: MediaQuery.of(context).size.width - 40,
                fit: BoxFit.cover)
            : const SizedBox(),
      ),
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

  Widget _buildSetsChoiceOptions() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final isSetsInReps = state.selectedTraining!
                  .trainingExercises[widget.widgetId].isSetsInReps ??
              true;

          return Column(
            children: [
              _buildSetsChoiceOption(
                'Reps',
                true,
                isSetsInReps,
                true,
                _controllers['minReps'],
                _controllers['maxReps'],
              ),
              _buildSetsChoiceOption(
                'Duration',
                false,
                isSetsInReps,
                false,
                _controllers['durationMinutes'],
                _controllers['durationSeconds'],
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSetsChoiceOption(
    String choice,
    bool choiceValue,
    bool currentSelection,
    bool isReps, [
    TextEditingController? controller1,
    TextEditingController? controller2,
  ]) {
    return GestureDetector(
      onTap: () => _updateBloc(choiceValue),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Radio<bool>(
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
                    if (controller2 != null && isReps)
                      Text(' - ',
                          style: TextStyle(
                            fontSize: 20,
                            color: currentSelection == choiceValue
                                ? AppColors.black
                                : AppColors.lightBlack,
                          )),
                    if (controller2 != null && !isReps)
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateBloc(bool choiceValue) {
    final bloc = context.read<TrainingManagementBloc>();

    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      final updatedTrainingExercisesList = List<TrainingExercise>.from(
          currentState.selectedTraining!.trainingExercises);

      final updatedExercise = updatedTrainingExercisesList[widget.widgetId]
          .copyWith(isSetsInReps: choiceValue);

      updatedTrainingExercisesList[widget.widgetId] = updatedExercise;

      bloc.add(UpdateSelectedTrainingProperty(
          trainingExercises: updatedTrainingExercisesList));
    }
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

  Widget _buildExerciseRestRow() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Exercise rest',
              style: TextStyle(color: AppColors.lightBlack)),
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
}
