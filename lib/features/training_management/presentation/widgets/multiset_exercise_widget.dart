import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app_colors.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../../exercise_management/data/models/exercise_model.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../../domain/entities/multiset.dart';
import '../../domain/entities/training_exercise.dart';
import '../bloc/training_management_bloc.dart';
import 'big_text_field_widget.dart';
import 'more_widget.dart';
import 'small_text_field_widget.dart';
import 'package:searchfield/searchfield.dart';

class MultisetExerciseWidget extends StatefulWidget {
  final String multisetKey;
  final String exerciseKey;

  const MultisetExerciseWidget(
      {super.key, required this.multisetKey, required this.exerciseKey});

  @override
  State<MultisetExerciseWidget> createState() => _MultisetExerciseWidgetState();
}

class _MultisetExerciseWidgetState extends State<MultisetExerciseWidget> {
  Timer? _debounceTimer;

  Exercise selectedExercise =
      const Exercise(name: '', exerciseType: ExerciseType.workout);
  TrainingExercise trainingExercise = const TrainingExercise();
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
      'durationMinutes': TextEditingController(),
      'durationSeconds': TextEditingController(),
      'minReps': TextEditingController(),
      'maxReps': TextEditingController(),
      'exerciseRestMinutes': TextEditingController(),
      'exerciseRestSeconds': TextEditingController(),
      'specialInstructions': TextEditingController(),
      'objectives': TextEditingController(),
    };
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final trainingExercises = currentState.selectedTraining?.multisets
              .firstWhere((multiset) => multiset.key == widget.multisetKey)
              .trainingExercises ??
          [];
      final exercise = trainingExercises
          .firstWhere((exercise) => exercise.key == widget.exerciseKey);

      _controllers['durationMinutes']?.text = (exercise.duration != null
          ? (exercise.duration! % 3600 ~/ 60).toString()
          : '');
      _controllers['durationSeconds']?.text = (exercise.duration != null
          ? (exercise.duration! % 60).toString()
          : '');
      _controllers['minReps']?.text = exercise.minReps?.toString() ?? '';
      _controllers['maxReps']?.text = exercise.maxReps?.toString() ?? '';
      _controllers['exerciseRestMinutes']?.text = (exercise.exerciseRest != null
          ? (exercise.exerciseRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['exerciseRestSeconds']?.text = (exercise.exerciseRest != null
          ? (exercise.exerciseRest! % 60).toString()
          : '');
      _controllers['specialInstructions']?.text =
          exercise.specialInstructions?.toString() ?? '';
      _controllers['objectives']?.text = exercise.objectives?.toString() ?? '';
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
        currentState.selectedTraining!.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises!,
      );

      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      if (index != -1) {
        final updatedExercise = updatedTrainingExercisesList[index].copyWith(
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
          specialInstructions: key == 'specialInstructions'
              ? _controllers['specialInstructions']?.text ?? ''
              : null,
          objectives: key == 'objectives'
              ? _controllers['objectives']?.text ?? ''
              : null,
        );

        // Replace the old exercise with the updated one in the list
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
          _buildSetsChoiceOptions(),
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

  TrainingExerciseType handleExerciseType(ExerciseType exerciseType) {
    return TrainingExerciseType.values
        .firstWhere((el) => el.name == exerciseType.name);
  }

  Widget _buildExerciseSearch() {
    void updateExerciseIdInBloc(Exercise? exercise) {
      final bloc = context.read<TrainingManagementBloc>();
      final currentState = bloc.state as TrainingManagementLoaded;

      final updatedTrainingExercisesList = List<TrainingExercise>.from(
        currentState.selectedTraining!.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises!,
      );

      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      final updatedExercise = exercise?.id != null
          ? updatedTrainingExercisesList
              .firstWhere((exercise) => exercise.key == widget.exerciseKey)
              .copyWith(
                  exerciseId: exercise!.id,
                  trainingExerciseType:
                      handleExerciseType(exercise.exerciseType))
          : updatedTrainingExercisesList
              .firstWhere((exercise) => exercise.key == widget.exerciseKey)
              .copyWithExerciseIdNull();

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
      if (exercise?.id != null) {
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
                .multisets
                .firstWhere((multiset) => multiset.key == widget.multisetKey)
                .trainingExercises!
                .firstWhere((exercise) => exercise.key == widget.exerciseKey)
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
          _controllers['exercise']?.clear();
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
          updateExerciseIdInBloc(filteredExercises[0]);
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
          updateExerciseIdInBloc(filteredExercises[0]);
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
          child: Row(
            children: [
              const Icon(Icons.add, color: AppColors.black),
              const SizedBox(width: 8),
              Text(tr('exercise_create_new')),
            ],
          ),
        ));

        return suggestions;
      },
      initialValue: initialItem,
      maxSuggestionsInViewPort: 5,
      hint: tr('exercise_search'),
      suggestions: (context.read<ExerciseManagementBloc>().state
              as ExerciseManagementLoaded)
          .exercises
          .map((e) => SearchFieldListItem(e.name))
          .toList()
        ..add(SearchFieldListItem(
          'Create New Exercise',
          child: Row(
            children: [
              const Icon(Icons.add, color: AppColors.black),
              const SizedBox(width: 8),
              Text(tr('exercise_create_new')),
            ],
          ),
        )),
    );
  }

  Widget _buildExerciseDetails() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final exerciseId = state.selectedTraining?.multisets
              .firstWhere((multiset) => multiset.key == widget.multisetKey)
              .trainingExercises!
              .firstWhere((exercise) => exercise.key == widget.exerciseKey)
              .exerciseId;

          const ExerciseModel noExercise = ExerciseModel(
              name: 'no exercise', exerciseType: ExerciseType.workout);

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

  Widget _buildSetsChoiceOptions() {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final isSetsInReps = state.selectedTraining!.multisets
                  .firstWhere((multiset) => multiset.key == widget.multisetKey)
                  .trainingExercises!
                  .firstWhere((exercise) => exercise.key == widget.exerciseKey)
                  .isSetsInReps ??
              true;

          return Column(
            children: [
              _buildSetsChoiceOption(
                tr('exercise_reps'),
                true,
                isSetsInReps,
                true,
                _controllers['minReps'],
                _controllers['maxReps'],
              ),
              _buildSetsChoiceOption(
                tr('exercise_duration'),
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
        currentState.selectedTraining!.multisets
            .firstWhere((multiset) => multiset.key == widget.multisetKey)
            .trainingExercises!,
      );

      final index = updatedTrainingExercisesList.indexWhere(
        (exercise) => exercise.key == widget.exerciseKey,
      );

      final updatedExercise = updatedTrainingExercisesList
          .firstWhere((exercise) => exercise.key == widget.exerciseKey)
          .copyWith(isSetsInReps: choiceValue);

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
}
