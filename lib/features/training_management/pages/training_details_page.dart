import 'dart:async';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/enums/enums.dart';
import '../../base_exercise_management/bloc/base_exercise_management_bloc.dart';

import '../../../app_colors.dart';
import '../../../helper_functions.dart';
import '../../../injection_container.dart';
import '../../../core/widgets/custom_text_field_widget.dart';
import '../../base_exercise_management/models/base_exercise.dart';
import '../models/multiset.dart';
import '../models/exercise.dart';
import '../bloc/training_management_bloc.dart';
import '../widgets/big_text_field_widget.dart';
import '../../../core/widgets/small_text_field_widget.dart';

class TrainingDetailsPage extends StatefulWidget {
  const TrainingDetailsPage({super.key});

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  late final Map<String, TextEditingController> _controllers;
  bool _isDataInitialized = false;

  Exercise _exerciseToCreateOrEdit = Exercise(
    sets: 1,
    isSetsInReps: true,
    exerciseType: ExerciseType.workout,
    isAutoStart: false,
    runType: RunType.distance,
    isTargetPaceSelected: false,
    intensity: 2,
    specialInstructions: '',
    objectives: '',
    targetDistance: 0,
    targetDuration: 0,
    targetSpeed: 0,
    minReps: 0,
    maxReps: 0,
    duration: 0,
    setRest: 0,
    exerciseRest: 0,
  );

  Multiset _multisetToCreateOrEdit = Multiset(
    sets: 1,
    setRest: 0,
    multisetRest: 0,
    specialInstructions: '',
    objectives: '',
    position: null,
  );

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _attachListeners();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeTrainingGeneralInfo() {
    final training =
        (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
            .selectedTraining;

    _controllers['trainingName']!.text = training.name;
    _controllers['trainingObjectives']!.text = training.objectives;
  }

  void initializeExerciseControllers(String? key) {
    final Exercise exercise;

    if (key != null) {
      final bloc = context.read<TrainingManagementBloc>();
      final currentState = bloc.state;

      if (currentState is! TrainingManagementLoaded) return;
      final exercises = currentState.selectedTraining.exercises;
      exercise = exercises.firstWhere((e) => e.widgetKey == key);
    } else {
      exercise = _exerciseToCreateOrEdit;
    }

    // Update `_exerciseToCreateOrEdit` with the selected `exercise`
    _updateExerciseToCreateOrEdit(exercise);

    // Populate the `_controllers` with values from `exercise`
    _populateControllers(exercise);
  }

  void _updateExerciseToCreateOrEdit(Exercise exercise) {
    _exerciseToCreateOrEdit = _exerciseToCreateOrEdit.copyWith(
      id: exercise.id,
      trainingId: exercise.trainingId,
      multisetId: exercise.multisetId,
      baseExerciseId: exercise.baseExerciseId,
      exerciseType: exercise.exerciseType,
      runType: exercise.runType,
      specialInstructions: exercise.specialInstructions,
      objectives: exercise.objectives,
      targetDistance: exercise.targetDistance,
      targetDuration: exercise.targetDuration,
      isTargetPaceSelected: exercise.isTargetPaceSelected,
      targetSpeed: exercise.targetSpeed,
      isAutoStart: exercise.isAutoStart,
      isSetsInReps: exercise.isSetsInReps,
      sets: exercise.sets,
      duration: exercise.duration,
      minReps: exercise.minReps,
      maxReps: exercise.maxReps,
      setRest: exercise.setRest,
      exerciseRest: exercise.exerciseRest,
      position: exercise.position,
      intensity: exercise.intensity,
      widgetKey: exercise.widgetKey,
      multisetKey: exercise.multisetKey,
    );
  }

  void _populateControllers(Exercise exercise) {
    _controllers['sets']?.text = exercise.sets.toString();
    _controllers['durationMinutes']?.text = _formatMinutes(exercise.duration);
    _controllers['durationSeconds']?.text = _formatSeconds(exercise.duration);
    _controllers['minReps']?.text = exercise.minReps.toString();
    _controllers['maxReps']?.text = exercise.maxReps.toString();
    _controllers['setRestMinutes']?.text = _formatMinutes(exercise.setRest);
    _controllers['setRestSeconds']?.text = _formatSeconds(exercise.setRest);
    _controllers['specialInstructions']?.text = exercise.specialInstructions;
    _controllers['objectives']?.text = exercise.objectives;
    _controllers['distance']?.text = exercise.targetDistance != 0
        ? (exercise.targetDistance / 1000).toString()
        : '0';
    _controllers['targetDurationHours']?.text =
        _formatHours(exercise.targetDuration);
    _controllers['targetDurationMinutes']?.text =
        _formatMinutes(exercise.targetDuration);
    _controllers['targetDurationSeconds']?.text =
        _formatSeconds(exercise.targetDuration);
    _controllers['paceMinutes']?.text = _formatMinutes(exercise.targetSpeed);
    _controllers['paceSeconds']?.text = _formatSeconds(exercise.targetSpeed);
    _controllers['exerciseRestMinutes']?.text =
        _formatMinutes(exercise.exerciseRest);
    _controllers['exerciseRestSeconds']?.text =
        _formatSeconds(exercise.exerciseRest);
  }

  String _formatMinutes(num value) {
    return value != 0 ? (value % 3600 ~/ 60).toString() : '0';
  }

  String _formatSeconds(num value) {
    return value != 0 ? (value % 60).toString() : '0';
  }

  String _formatHours(int value) {
    return value != 0 ? (value ~/ 3600).toString() : '0';
  }

  void initializeMultisetControllers(String? key) {
    final Multiset multiset;

    if (key != null) {
      final bloc = context.read<TrainingManagementBloc>();
      final currentState = bloc.state;

      if (currentState is! TrainingManagementLoaded) return;
      final List<Multiset> multisets = currentState.selectedTraining.multisets;
      multiset = multisets.firstWhere((multiset) => multiset.widgetKey == key);
    } else {
      multiset = _multisetToCreateOrEdit;
    }

    // Update `_multisetToCreateOrEdit` with the selected `multiset`
    _updateMultisetToCreateOrEdit(multiset);

    // Populate the `_controllers` with values from `multiset`
    _populateMultisetControllers(multiset);
  }

  void _populateMultisetControllers(Multiset multiset) {
    _controllers['multisetSets']?.text = multiset.sets.toString();
    _controllers['multisetSetRestMinutes']?.text =
        _formatMinutes(multiset.setRest);
    _controllers['multisetSetRestSeconds']?.text =
        _formatSeconds(multiset.setRest);
    _controllers['multisetRestMinutes']?.text =
        _formatMinutes(multiset.multisetRest);
    _controllers['multisetRestSeconds']?.text =
        _formatSeconds(multiset.multisetRest);
    _controllers['multisetInstructions']?.text = multiset.specialInstructions;
    _controllers['multisetObjectives']?.text = multiset.objectives;
  }

  void _updateMultisetToCreateOrEdit(Multiset multiset) {
    _multisetToCreateOrEdit = _multisetToCreateOrEdit.copyWith(
      id: multiset.id,
      trainingId: multiset.trainingId,
      sets: multiset.sets,
      setRest: multiset.setRest,
      multisetRest: multiset.multisetRest,
      specialInstructions: multiset.specialInstructions,
      objectives: multiset.objectives,
      position: multiset.position,
      widgetKey: multiset.widgetKey,
    );
  }

  void _initializeControllers() {
    _controllers = {
      'multisetSets': TextEditingController(),
      'multisetSetRestMinutes': TextEditingController(),
      'multisetSetRestSeconds': TextEditingController(),
      'multisetRestMinutes': TextEditingController(),
      'multisetRestSeconds': TextEditingController(),
      'multisetInstructions': TextEditingController(),
      'multisetObjectives': TextEditingController(),
      'trainingName': TextEditingController(),
      'trainingObjectives': TextEditingController(),
      'exercise': TextEditingController(),
      'sets': TextEditingController(),
      'distance': TextEditingController(),
      'targetDurationHours': TextEditingController(),
      'targetDurationMinutes': TextEditingController(),
      'targetDurationSeconds': TextEditingController(),
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
      'paceMinutes': TextEditingController(),
      'paceSeconds': TextEditingController(),
    };
  }

  void _attachListeners() {
    _controllers.forEach((key, controller) {
      controller.addListener(() => _onControllerChanged(key));
    });
  }

  void _onControllerChanged(String key) {
    _updateData(key);
  }

  void _updateData(String key) {
    if (!mounted) return;

    if (key == 'trainingName' || key == 'trainingObjectives') {
      final training = (context.read<TrainingManagementBloc>().state
              as TrainingManagementLoaded)
          .selectedTraining;

      final trainingToCreateOrEdit = training.copyWith(
          name: _controllers['trainingName']!.text.trim(),
          objectives: _controllers['trainingObjectives']!.text.trim());

      sl<TrainingManagementBloc>()
          .add(CreateOrUpdateSelectedTrainingEvent(trainingToCreateOrEdit));
    } else if (key.contains('multiset')) {
      final currentValues = {
        'sets': _multisetToCreateOrEdit.sets,
        'setRest': _multisetToCreateOrEdit.setRest,
        'multisetRest': _multisetToCreateOrEdit.multisetRest,
        'specialInstructions': _multisetToCreateOrEdit.specialInstructions,
        'objectives': _multisetToCreateOrEdit.objectives,
      };

      _multisetToCreateOrEdit = _multisetToCreateOrEdit.copyWith(
        sets: key == 'multisetSets'
            ? int.tryParse(_controllers['multisetSets']?.text ?? '1') ?? 1
            : currentValues['sets'] as int? ?? 1,
        setRest: key == 'multisetSetRestMinutes' ||
                key == 'multisetSetRestSeconds'
            ? ((int.tryParse(_controllers['multisetSetRestMinutes']?.text ??
                            '0') ??
                        0) *
                    60) +
                (int.tryParse(
                        _controllers['multisetSetRestSeconds']?.text ?? '0') ??
                    0)
            : currentValues['setRest'] as int? ?? 0,
        multisetRest: key == 'multisetRestMinutes' ||
                key == 'multisetRestSeconds'
            ? ((int.tryParse(
                            _controllers['multisetRestMinutes']?.text ?? '0') ??
                        0) *
                    60) +
                (int.tryParse(
                        _controllers['multisetRestSeconds']?.text ?? '0') ??
                    0)
            : currentValues['multisetRest'] as int? ?? 0,
        specialInstructions: key == 'multisetInstructions'
            ? _controllers['multisetInstructions']?.text ?? ''
            : currentValues['specialInstructions'] as String?,
        objectives: key == 'multisetObjectives'
            ? _controllers['multisetObjectives']?.text ?? ''
            : currentValues['objectives'] as String?,
      );
    } else {
      // Pour exercise, on garde les valeurs existantes sauf pour le champ modifié
      final currentValues = {
        'sets': _exerciseToCreateOrEdit.sets,
        'minReps': _exerciseToCreateOrEdit.minReps,
        'maxReps': _exerciseToCreateOrEdit.maxReps,
        'duration': _exerciseToCreateOrEdit.duration,
        'setRest': _exerciseToCreateOrEdit.setRest,
        'exerciseRest': _exerciseToCreateOrEdit.exerciseRest,
        'specialInstructions': _exerciseToCreateOrEdit.specialInstructions,
        'objectives': _exerciseToCreateOrEdit.objectives,
        'distance': _exerciseToCreateOrEdit.targetDistance,
        'targetDuration': _exerciseToCreateOrEdit.targetDuration,
        'targetSpeed': _exerciseToCreateOrEdit.targetSpeed,
      };

      _exerciseToCreateOrEdit = _exerciseToCreateOrEdit.copyWith(
        sets: key == 'sets'
            ? int.tryParse(_controllers['sets']?.text ?? '1') ?? 1
            : currentValues['sets'] as int?,
        minReps: key == 'minReps'
            ? int.tryParse(_controllers['minReps']?.text ?? '')
            : currentValues['minReps'] as int?,
        maxReps: key == 'maxReps'
            ? int.tryParse(_controllers['maxReps']?.text ?? '')
            : currentValues['maxReps'] as int?,
        duration: key == 'durationMinutes' || key == 'durationSeconds'
            ? ((int.tryParse(_controllers['durationMinutes']?.text ?? '0') ??
                        0) *
                    60) +
                (int.tryParse(_controllers['durationSeconds']?.text ?? '0') ??
                    0)
            : currentValues['duration'] as int?,
        setRest: key == 'setRestMinutes' || key == 'setRestSeconds'
            ? ((int.tryParse(_controllers['setRestMinutes']?.text ?? '0') ??
                        0) *
                    60) +
                (int.tryParse(_controllers['setRestSeconds']?.text ?? '0') ?? 0)
            : currentValues['setRest'] as int?,
        exerciseRest: key == 'exerciseRestMinutes' ||
                key == 'exerciseRestSeconds'
            ? ((int.tryParse(
                            _controllers['exerciseRestMinutes']?.text ?? '0') ??
                        0) *
                    60) +
                (int.tryParse(
                        _controllers['exerciseRestSeconds']?.text ?? '0') ??
                    0)
            : currentValues['exerciseRest'] as int?,
        specialInstructions: key == 'specialInstructions'
            ? _controllers['specialInstructions']?.text ?? ''
            : currentValues['specialInstructions'] as String?,
        objectives: key == 'objectives'
            ? _controllers['objectives']?.text ?? ''
            : currentValues['objectives'] as String?,
        targetDistance: key == 'distance'
            ? ((double.tryParse((_controllers['distance']?.text ?? '')
                            .replaceAll(',', '.')) ??
                        0) *
                    1000)
                .toInt()
            : currentValues['distance'] as int?,
        targetDuration: key == 'targetDurationHours' ||
                key == 'targetDurationMinutes' ||
                key == 'targetDurationSeconds'
            ? ((int.tryParse(_controllers['targetDurationHours']?.text ?? '') ??
                        0) *
                    3600) +
                ((int.tryParse(_controllers['targetDurationMinutes']?.text ??
                            '') ??
                        0) *
                    60) +
                (int.tryParse(
                        _controllers['targetDurationSeconds']?.text ?? '') ??
                    0)
            : currentValues['targetDuration'] as int?,
        targetSpeed: key == 'paceMinutes' || key == 'paceSeconds'
            ? ((double.tryParse(_controllers['paceMinutes']?.text ?? '') ?? 0) *
                    60) +
                (double.tryParse(_controllers['paceSeconds']?.text ?? '') ?? 0)
            : currentValues['targetSpeed'] as double?,
      );
    }
  }

  List<TrainingDay> _sortTrainingDays(List<TrainingDay> trainingDays) {
    return trainingDays..sort((a, b) => a.index.compareTo(b.index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
          builder: (context, state) {
            if (state is TrainingManagementLoaded) {
              List<Map<String, Object>> exercisesAndMultisetsList = [];

              if (!_isDataInitialized &&
                  state.selectedTraining !=
                      TrainingManagementLoaded.emptyTraining) {
                _initializeTrainingGeneralInfo();
                _isDataInitialized = true;
              }
              exercisesAndMultisetsList = [
                ...state.selectedTraining.exercises
                    .where((e) => e.multisetKey == null)
                    .map((e) => {'type': 'exercise', 'data': e}),
                ...state.selectedTraining.multisets
                    .map((m) => {'type': 'multiset', 'data': m}),
              ];
              exercisesAndMultisetsList.sort((a, b) {
                final aPosition = (a['data'] as dynamic).position ?? 0;
                final bPosition = (b['data'] as dynamic).position ?? 0;
                return aPosition.compareTo(bPosition);
              });

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildHeader(context, state),
                          const SizedBox(height: 30),
                          _buildTrainingGeneralInfo(context),
                          _buildReorderableListview(
                              exercisesAndMultisetsList, context, state),
                          const SizedBox(height: 20),
                          _buildAddButtons(context),
                          const SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),
                  _buildCreateButton(context, state),
                ],
              );
            }
            return Center(child: Text(context.tr('error_state')));
          },
        ),
      ),
    );
  }

  Positioned _buildCreateButton(
      BuildContext context, TrainingManagementLoaded state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.floralWhite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 70,
        child: GestureDetector(
          onTap: () {
            final training = (context.read<TrainingManagementBloc>().state
                    as TrainingManagementLoaded)
                .selectedTraining;
            final bloc = context.read<TrainingManagementBloc>();
            bloc.add(CreateOrUpdateTrainingEvent(training));
            GoRouter.of(context).push('/trainings');
          },
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.folly, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                state.selectedTraining.id == null
                    ? tr('global_create')
                    : tr('global_save'),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ReorderableListView _buildReorderableListview(
      List<Map<String, Object>> exercisesAndMultisetsList,
      BuildContext context,
      TrainingManagementLoaded state) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {
        if (exercisesAndMultisetsList.length <= 1) {
          return;
        }
        if (newIndex > oldIndex) {
          newIndex--;
        }

        final combinedList =
            List<Map<String, dynamic>>.from(exercisesAndMultisetsList);

        // Remove and reinsert the item
        final movedItem = combinedList.removeAt(oldIndex);
        combinedList.insert(newIndex, movedItem);

        // Update positions for exercises
        final updatedExercises = combinedList
            .where((item) => item['type'] == 'exercise')
            .map((item) {
          final exercise = item['data'] as Exercise;
          final newPosition = combinedList.indexOf(item);
          return exercise.copyWith(position: newPosition);
        }).toList();

        final updatedMultisets = combinedList
            .where((item) => item['type'] == 'multiset')
            .map((item) {
          final multiset = item['data'] as Multiset;
          final newPosition = combinedList.indexOf(item);
          return multiset.copyWith(position: newPosition);
        }).toList();

        updatedExercises.addAll(state.selectedTraining.exercises
            .where((e) => e.multisetKey != null));

        // Dispatch the updated training exercises to the bloc
        context.read<TrainingManagementBloc>().add(
              UpdateSelectedTrainingProperty(
                  exercises: updatedExercises, multisets: updatedMultisets),
            );
      },
      children: exercisesAndMultisetsList.asMap().entries.map((entry) {
        var item = entry.value;

        if (item['type'] == 'exercise') {
          var exercise = item['data'] as Exercise;
          if (exercise.exerciseType == ExerciseType.running) {
            if (exercisesAndMultisetsList.length <= 1) {
              return GestureDetector(
                key: ValueKey(exercise.widgetKey),
                onLongPress: () {},
                child: _buildRunExerciseItem(exercise, context, null),
              );
            } else {
              return _buildRunExerciseItem(exercise, context, null);
            }
          }

          final BaseExercise? baseExercise = (context
                  .read<BaseExerciseManagementBloc>()
                  .state as BaseExerciseManagementLoaded)
              .baseExercises
              .firstWhereOrNull((b) => b.id == exercise.baseExerciseId);

          if (exercisesAndMultisetsList.length <= 1) {
            return GestureDetector(
              key: ValueKey(exercise.widgetKey),
              onLongPress: () {},
              child: _buildExerciseItem(exercise, baseExercise, context, null),
            );
          } else {
            return _buildExerciseItem(exercise, baseExercise, context, null);
          }
        } else if (item['type'] == 'multiset') {
          var tMultiset = item['data'] as Multiset;

          if (exercisesAndMultisetsList.length <= 1) {
            return GestureDetector(
              key: ValueKey(tMultiset.widgetKey),
              onLongPress: () {},
              child: _buildMultisetItem(context, tMultiset),
            );
          } else {
            return _buildMultisetItem(context, tMultiset);
          }
        }
        return const SizedBox.shrink(); // Fallback for unknown types
      }).toList(),
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        elevation: 0,
        child: child,
      ),
    );
  }

  Container _buildExerciseItem(Exercise exercise, BaseExercise? baseExercise,
      BuildContext context, Multiset? multiset) {
    return Container(
      key: ValueKey(exercise.widgetKey),
      margin: EdgeInsets.only(top: multiset == null ? 20 : 10),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.timberwolf),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (baseExercise?.imagePath != null &&
              baseExercise!.imagePath.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  width: 130,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(baseExercise.imagePath),
                      width: MediaQuery.of(context).size.width - 40,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          if (baseExercise?.imagePath != null &&
              baseExercise!.imagePath.isNotEmpty)
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
                        baseExercise?.name ?? tr('exercise_unknown'),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 30,
                      alignment: Alignment.topCenter,
                      child: ClipRect(
                        child: PopupMenuButton(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors.timberwolf)),
                          color: AppColors.white,
                          onSelected: (value) {
                            if (value == 'edit') {
                              initializeExerciseControllers(
                                  exercise.widgetKey!);
                              _buildExerciseDialog(context, multiset: multiset);
                            } else if (value == 'delete') {
                              final bloc =
                                  BlocProvider.of<TrainingManagementBloc>(
                                      context);
                              if (multiset != null) {
                                bloc.add(RemoveMultisetExerciseEvent(
                                    exercise: exercise));
                              } else {
                                bloc.add(RemoveExerciseEvent(exercise));
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                tr('global_edit'),
                                style:
                                    const TextStyle(color: AppColors.taupeGray),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                tr('global_delete'),
                                style:
                                    const TextStyle(color: AppColors.taupeGray),
                              ),
                            ),
                          ],
                          icon: const Icon(
                            Icons.more_horiz,
                            color: AppColors.frenchGray,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${multiset == null ? '${exercise.sets}x' : ''}${exercise.isSetsInReps ? '${exercise.minReps}-${exercise.maxReps} reps' : '${exercise.duration} seconds'}',
                  style: const TextStyle(color: AppColors.taupeGray),
                ),
                Text(
                  '${multiset == null ? (exercise.setRest) : exercise.exerciseRest} seconds rest',
                  style: const TextStyle(color: AppColors.taupeGray),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _buildRunExerciseItem(
      Exercise exercise, BuildContext context, Multiset? multiset) {
    return Container(
      key: ValueKey(exercise.widgetKey),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.timberwolf),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  tr('global_run'),
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 30,
                alignment: Alignment.topCenter,
                child: ClipRect(
                  child: PopupMenuButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.timberwolf)),
                    color: AppColors.white,
                    onSelected: (value) {
                      if (value == 'edit') {
                        initializeExerciseControllers(exercise.widgetKey!);
                        _buildExerciseDialog(context, multiset: multiset);
                      } else if (value == 'delete') {
                        final bloc =
                            BlocProvider.of<TrainingManagementBloc>(context);
                        bloc.add(RemoveExerciseEvent(exercise));
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          tr('global_edit'),
                          style: const TextStyle(color: AppColors.taupeGray),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          tr('global_delete'),
                          style: const TextStyle(color: AppColors.taupeGray),
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.frenchGray,
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildRunText(exercise),
        ],
      ),
    );
  }

  Container _buildMultisetItem(BuildContext context, Multiset multiset) {
    return Container(
      key: ValueKey(multiset.widgetKey),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.timberwolf),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  tr('global_multiset'),
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 30,
                alignment: Alignment.topCenter,
                child: ClipRect(
                  child: PopupMenuButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.timberwolf)),
                    color: AppColors.white,
                    onSelected: (value) {
                      if (value == 'edit') {
                        initializeMultisetControllers(multiset.widgetKey!);
                        _buildMultisetDialog(context);
                      } else if (value == 'delete') {
                        final bloc =
                            BlocProvider.of<TrainingManagementBloc>(context);
                        bloc.add(RemoveMultisetEvent(multiset: multiset));
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          tr('global_edit'),
                          style: const TextStyle(color: AppColors.taupeGray),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          tr('global_delete'),
                          style: const TextStyle(color: AppColors.taupeGray),
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.frenchGray,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${multiset.sets} set(s)',
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          Text(
            '${multiset.setRest} seconds rest',
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          _buildExercisesList(multiset),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              initializeExerciseControllers(null);
              _buildExerciseDialog(context, multiset: multiset);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.licorice),
              child: Center(
                child: Text(
                  tr('training_detail_page_add_exercise'),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(Multiset multiset) {
    final List<Exercise> multisetExercises =
        (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
            .selectedTraining
            .exercises
            .where((e) => e.multisetKey == multiset.widgetKey)
            .toList();

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final Exercise exercise = multisetExercises[index];
          if (exercise.exerciseType == ExerciseType.running) {
            return _buildRunExerciseItem(exercise, context, multiset);
          }

          final BaseExercise? baseExercise = (context
                  .read<BaseExerciseManagementBloc>()
                  .state as BaseExerciseManagementLoaded)
              .baseExercises
              .firstWhereOrNull(
                (b) => b.id == exercise.baseExerciseId,
              );
          return _buildExerciseItem(exercise, baseExercise, context, multiset);
        },
        itemCount: multisetExercises.length);
  }

  Column _buildRunText(Exercise exercise) {
    if (exercise.sets > 1) {
      final targetDistance =
          exercise.targetDistance != 0 && exercise.targetDistance > 0
              ? '${(exercise.targetDistance / 1000).toStringAsFixed(1)}km'
              : '';
      final targetDuration = exercise.targetDuration != 0
          ? formatDurationToHoursMinutesSeconds(exercise.targetDuration)
          : '';
      final targetSpeed = exercise.isTargetPaceSelected == true
          ? ' at ${formatPace(exercise.targetSpeed)}'
          : '';
      final intervals = exercise.sets;
      if (exercise.runType == RunType.distance) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${intervals}x$targetDistance$targetSpeed',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
            Text(
              '${exercise.setRest} seconds rest',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${intervals}x$targetDuration$targetSpeed',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
            Text(
              '${exercise.setRest} seconds rest',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
          ],
        );
      }
    } else {
      final targetDistance =
          exercise.targetDistance != 0 && exercise.targetDistance > 0
              ? '${(exercise.targetDistance / 1000).toStringAsFixed(1)}km'
              : '';
      final targetDuration = exercise.targetDuration != 0
          ? formatDurationToHoursMinutesSeconds(exercise.targetDuration)
          : '';
      final targetSpeed = exercise.isTargetPaceSelected == true
          ? ' at ${formatPace(exercise.targetSpeed)}'
          : '';
      if (exercise.runType == RunType.distance) {
        return Column(
          children: [
            Text(
              '$targetDistance$targetSpeed',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Text(
              '$targetDuration$targetSpeed',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
          ],
        );
      }
    }
  }

  Row _buildAddButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              initializeExerciseControllers(null);
              _buildExerciseDialog(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.licorice),
              child: Center(
                child: Text(
                  tr('training_detail_page_add_exercise'),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _buildMultisetDialog(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.licorice),
              child: Center(
                child: Text(
                  tr('training_detail_page_add_multiset'),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _buildMultisetDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Builder(
          builder: (context) {
            final bool isEdit = _multisetToCreateOrEdit.id != null;
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppColors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEdit
                      ? tr('training_detail_page_edit_multiset')
                      : tr('training_detail_page_add_multiset')),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, 'Close'),
                    child: Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.centerRight,
                      child: const ClipRect(
                        child: Align(
                          alignment: Alignment.centerRight,
                          widthFactor: 0.85,
                          child: Icon(
                            Icons.close,
                            color: AppColors.licorice,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr('exercise_sets'),
                              style:
                                  const TextStyle(color: AppColors.frenchGray)),
                          SmallTextFieldWidget(
                              controller: _controllers['multisetSets']!),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr('exercise_set_rest'),
                              style:
                                  const TextStyle(color: AppColors.frenchGray)),
                          Row(
                            children: [
                              SmallTextFieldWidget(
                                  controller:
                                      _controllers['multisetSetRestMinutes']!),
                              const SizedBox(
                                width: 20,
                                child: Center(
                                  child:
                                      Text(':', style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              SmallTextFieldWidget(
                                  controller:
                                      _controllers['multisetSetRestSeconds']!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr('exercise_multiset_rest'),
                              style:
                                  const TextStyle(color: AppColors.frenchGray)),
                          Row(
                            children: [
                              SmallTextFieldWidget(
                                  controller:
                                      _controllers['multisetRestMinutes']!),
                              const SizedBox(
                                width: 20,
                                child: Center(
                                  child:
                                      Text(':', style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              SmallTextFieldWidget(
                                  controller:
                                      _controllers['multisetRestSeconds']!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    BigTextFieldWidget(
                        controller: _controllers['multisetInstructions']!,
                        hintText: tr('global_special_instructions')),
                    const SizedBox(height: 10),
                    BigTextFieldWidget(
                        controller: _controllers['multisetObjectives']!,
                        hintText: tr('global_objectives')),
                  ],
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    final training = (context
                            .read<TrainingManagementBloc>()
                            .state as TrainingManagementLoaded)
                        .selectedTraining;

                    sl<TrainingManagementBloc>().add(
                        CreateOrUpdateMultisetEvent(
                            multiset: _multisetToCreateOrEdit,
                            training: training));

                    Navigator.pop(context, 'Save');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.licorice),
                    child: Center(
                      child: Text(
                        tr('global_save'),
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _buildExerciseDialog(BuildContext context,
      {Multiset? multiset}) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Builder(builder: (context) {
          final bool isEdit = _exerciseToCreateOrEdit.id != null;
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEdit
                    ? tr('exercise_detail_page_title_edit')
                    : tr('training_detail_page_add_exercise')),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'Close'),
                  child: Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.centerRight,
                    child: const ClipRect(
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor: 0.85,
                        child: Icon(
                          Icons.close,
                          color: AppColors.licorice,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr('exercise_detail_page_type'),
                    style: const TextStyle(color: AppColors.taupeGray),
                  ),
                  const SizedBox(height: 10),
                  CustomDropdown<ExerciseType>(
                    items: ExerciseType.values
                        .sublist(0, ExerciseType.values.length - 1),
                    initialItem: _exerciseToCreateOrEdit.exerciseType,
                    decoration: CustomDropdownDecoration(
                      listItemStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.timberwolf),
                      headerStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.licorice),
                      closedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.timberwolf,
                      ),
                      expandedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 20,
                        color: AppColors.timberwolf,
                      ),
                      closedBorder: Border.all(color: AppColors.timberwolf),
                      expandedBorder: Border.all(color: AppColors.timberwolf),
                    ),
                    headerBuilder: (context, selectedItem, enabled) {
                      return Text(
                          selectedItem.translate(context.locale.languageCode));
                    },
                    listItemBuilder: (context, item, isSelected, onItemSelect) {
                      return Text(item.translate(context.locale.languageCode));
                    },
                    onChanged: (value) {
                      setDialogState(
                        () {
                          _exerciseToCreateOrEdit = _exerciseToCreateOrEdit
                              .copyWith(exerciseType: value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomDropdown<ExerciseDifficulty>(
                    items: ExerciseDifficulty.values,
                    initialItem:
                        difficultyMap[_exerciseToCreateOrEdit.intensity] ??
                            ExerciseDifficulty.moderate,
                    decoration: CustomDropdownDecoration(
                      listItemStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.timberwolf),
                      headerStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.licorice),
                      closedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.timberwolf,
                      ),
                      expandedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 20,
                        color: AppColors.timberwolf,
                      ),
                      closedBorder: Border.all(color: AppColors.timberwolf),
                      expandedBorder: Border.all(color: AppColors.timberwolf),
                    ),
                    headerBuilder: (context, selectedItem, enabled) {
                      return Text(
                          selectedItem.translate(context.locale.languageCode));
                    },
                    listItemBuilder: (context, item, isSelected, onItemSelect) {
                      return Text(item.translate(context.locale.languageCode));
                    },
                    onChanged: (value) {
                      _exerciseToCreateOrEdit = _exerciseToCreateOrEdit
                          .copyWith(intensity: difficultyLevelMap[value!]);
                    },
                  ),
                  const SizedBox(height: 20),
                  _exerciseToCreateOrEdit.exerciseType != ExerciseType.running
                      ? _buildYogaOrWorkoutFields(context, setDialogState,
                          multiset, _exerciseToCreateOrEdit.baseExerciseId)
                      : _buildRunFields(setDialogState),
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('exercise_exercise_rest'),
                            style:
                                const TextStyle(color: AppColors.frenchGray)),
                        Row(
                          children: [
                            SmallTextFieldWidget(
                                controller:
                                    _controllers['exerciseRestMinutes']!),
                            const SizedBox(
                              width: 20,
                              child: Center(
                                child:
                                    Text(':', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            SmallTextFieldWidget(
                                controller:
                                    _controllers['exerciseRestSeconds']!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Checkbox(
                          value: _exerciseToCreateOrEdit.isAutoStart,
                          onChanged: (bool? value) {
                            setDialogState(
                              () {
                                _exerciseToCreateOrEdit =
                                    _exerciseToCreateOrEdit.copyWith(
                                        isAutoStart: value);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tr('training_detail_page_autostart'),
                        style: const TextStyle(color: AppColors.frenchGray),
                      ),
                    ],
                  ),
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
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  final baseExercise = (context
                          .read<BaseExerciseManagementBloc>()
                          .state as BaseExerciseManagementLoaded)
                      .baseExercises
                      .firstWhereOrNull((b) =>
                          b.id == _exerciseToCreateOrEdit.baseExerciseId);

                  if (multiset != null) {
                    sl<TrainingManagementBloc>().add(
                        CreateOrUpdateMultisetExerciseEvent(
                            exercise: _exerciseToCreateOrEdit,
                            multisetKey: multiset.widgetKey!,
                            baseExercise: baseExercise));
                  } else {
                    sl<TrainingManagementBloc>()
                        .add(CreateOrUpdateExerciseEvent(
                      exercise: _exerciseToCreateOrEdit,
                      baseExercise: baseExercise,
                    ));
                  }

                  Navigator.pop(context, 'Save');
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.licorice),
                  child: Center(
                    child: Text(
                      tr('global_save'),
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Column _buildRunFields(StateSetter setDialogState) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('exercise_sets'),
                  style: const TextStyle(color: AppColors.frenchGray)),
              SmallTextFieldWidget(controller: _controllers['sets']!),
            ],
          ),
        ),
        _buildTargetChoiceOption(
          choice: tr('exercise_distance'),
          choiceValue: RunType.distance,
          currentSelection: _exerciseToCreateOrEdit.runType,
          onSelectionChanged: (RunType value) {
            setDialogState(() {
              _exerciseToCreateOrEdit =
                  _exerciseToCreateOrEdit.copyWith(runType: value);
            });
          },
          controller1: _controllers['distance'],
        ),
        _buildTargetChoiceOption(
          choice: tr('exercise_duration'),
          choiceValue: RunType.duration,
          currentSelection: _exerciseToCreateOrEdit.runType,
          onSelectionChanged: (RunType value) {
            setDialogState(() {
              _exerciseToCreateOrEdit =
                  _exerciseToCreateOrEdit.copyWith(runType: value);
            });
          },
          controller1: _controllers['targetDurationHours'],
          controller2: _controllers['targetDurationMinutes'],
          controller3: _controllers['targetDurationSeconds'],
        ),
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('exercise_set_rest'),
                  style: const TextStyle(color: AppColors.frenchGray)),
              Row(
                children: [
                  SmallTextFieldWidget(
                      controller: _controllers['setRestMinutes']!),
                  const SizedBox(
                    width: 20,
                    child: Center(
                      child: Text(':', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  SmallTextFieldWidget(
                      controller: _controllers['setRestSeconds']!),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 20,
              child: Checkbox(
                value: _exerciseToCreateOrEdit.isTargetPaceSelected,
                onChanged: (value) {
                  setDialogState(
                    () {
                      _exerciseToCreateOrEdit = _exerciseToCreateOrEdit
                          .copyWith(isTargetPaceSelected: value);
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('exercise_pace'),
                      style: const TextStyle(color: AppColors.frenchGray)),
                  Row(
                    children: [
                      SmallTextFieldWidget(
                        controller: _controllers['paceMinutes']!,
                        textColor: _exerciseToCreateOrEdit.isTargetPaceSelected
                            ? AppColors.licorice
                            : AppColors.frenchGray,
                      ),
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    _exerciseToCreateOrEdit.isTargetPaceSelected
                                        ? AppColors.licorice
                                        : AppColors.frenchGray,
                              )),
                        ),
                      ),
                      SmallTextFieldWidget(
                        controller: _controllers['paceSeconds']!,
                        textColor: _exerciseToCreateOrEdit.isTargetPaceSelected
                            ? AppColors.licorice
                            : AppColors.frenchGray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Column _buildYogaOrWorkoutFields(
      BuildContext context,
      StateSetter setDialogState,
      Multiset? multiset,
      int? initialBaseExerciseId) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('trainings_page_exercise'),
              style: const TextStyle(color: AppColors.taupeGray),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, 'New exercise');
                GoRouter.of(context)
                    .push('/exercise_detail', extra: 'training_detail');
              },
              child: Row(
                children: [
                  Text(tr('trainings_page_new'),
                      style: const TextStyle(color: AppColors.timberwolf)),
                  const SizedBox(width: 5),
                  const Icon(
                    LucideIcons.moveRight,
                    color: AppColors.timberwolf,
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        CustomDropdown<BaseExercise>.search(
          items: (sl<BaseExerciseManagementBloc>().state
                  as BaseExerciseManagementLoaded)
              .baseExercises,
          hintText: tr('exercise_search'),
          initialItem: initialBaseExerciseId != null
              ? (sl<BaseExerciseManagementBloc>().state
                      as BaseExerciseManagementLoaded)
                  .baseExercises
                  .firstWhereOrNull(
                      (exercise) => exercise.id == initialBaseExerciseId)
              : null,
          decoration: CustomDropdownDecoration(
            listItemStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.timberwolf),
            headerStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.licorice),
            closedSuffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.timberwolf,
            ),
            expandedSuffixIcon: const Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 20,
              color: AppColors.timberwolf,
            ),
            closedBorder: Border.all(color: AppColors.timberwolf),
            expandedBorder: Border.all(color: AppColors.timberwolf),
          ),
          headerBuilder: (context, selectedItem, enabled) {
            return Text(selectedItem.name);
          },
          listItemBuilder: (context, item, isSelected, onItemSelect) {
            return Text(item.name);
          },
          onChanged: (value) {
            _exerciseToCreateOrEdit =
                _exerciseToCreateOrEdit.copyWith(baseExerciseId: value?.id!);
          },
        ),
        const SizedBox(height: 20),
        if (multiset == null)
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('exercise_sets'),
                    style: const TextStyle(color: AppColors.frenchGray)),
                SmallTextFieldWidget(controller: _controllers['sets']!),
              ],
            ),
          ),
        _buildSetsChoiceOption(
          choice: tr('exercise_reps'),
          choiceValue: true,
          currentSelection: _exerciseToCreateOrEdit.isSetsInReps,
          isReps: true,
          onSelectionChanged: (bool newValue) {
            setDialogState(() {
              _exerciseToCreateOrEdit =
                  _exerciseToCreateOrEdit.copyWith(isSetsInReps: newValue);
            });
          },
          controller1: _controllers['minReps'],
          controller2: _controllers['maxReps'],
        ),
        _buildSetsChoiceOption(
          choice: tr('exercise_duration'),
          choiceValue: false,
          currentSelection: _exerciseToCreateOrEdit.isSetsInReps,
          isReps: false,
          onSelectionChanged: (bool newValue) {
            setDialogState(() {
              _exerciseToCreateOrEdit =
                  _exerciseToCreateOrEdit.copyWith(isSetsInReps: newValue);
            });
          },
          controller1: _controllers['durationMinutes'],
          controller2: _controllers['durationSeconds'],
        ),
        if (multiset == null)
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('exercise_set_rest'),
                    style: const TextStyle(color: AppColors.frenchGray)),
                Row(
                  children: [
                    SmallTextFieldWidget(
                        controller: _controllers['setRestMinutes']!),
                    const SizedBox(
                      width: 20,
                      child: Center(
                        child: Text(':', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    SmallTextFieldWidget(
                        controller: _controllers['setRestSeconds']!),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTargetChoiceOption({
    required String choice,
    required RunType choiceValue,
    required RunType currentSelection,
    required ValueChanged<RunType> onSelectionChanged,
    TextEditingController? controller1,
    TextEditingController? controller2,
    TextEditingController? controller3,
  }) {
    return GestureDetector(
      onTap: () => onSelectionChanged(choiceValue),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Radio<RunType>(
              value: choiceValue,
              groupValue: currentSelection,
              onChanged: (value) {
                if (value != null) {
                  onSelectionChanged(value);
                }
              },
              activeColor: AppColors.licorice,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                return currentSelection == choiceValue
                    ? AppColors.licorice
                    : AppColors.frenchGray;
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
                  style: const TextStyle(color: AppColors.frenchGray),
                ),
                Row(
                  children: [
                    if (controller1 != null)
                      SmallTextFieldWidget(
                        controller: controller1,
                        textColor: currentSelection == choiceValue
                            ? AppColors.licorice
                            : AppColors.frenchGray,
                      ),
                    if (controller2 != null)
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSelection == choiceValue
                                    ? AppColors.licorice
                                    : AppColors.frenchGray,
                              )),
                        ),
                      ),
                    if (controller2 != null)
                      SmallTextFieldWidget(
                        controller: controller2,
                        textColor: currentSelection == choiceValue
                            ? AppColors.licorice
                            : AppColors.frenchGray,
                      ),
                    if (controller3 != null)
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSelection == choiceValue
                                    ? AppColors.licorice
                                    : AppColors.frenchGray,
                              )),
                        ),
                      ),
                    if (controller3 != null)
                      SmallTextFieldWidget(
                        controller: controller3,
                        textColor: currentSelection == choiceValue
                            ? AppColors.licorice
                            : AppColors.frenchGray,
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

  Widget _buildSetsChoiceOption({
    required String choice,
    required bool choiceValue,
    required bool currentSelection,
    required bool isReps,
    required ValueChanged<bool> onSelectionChanged,
    TextEditingController? controller1,
    TextEditingController? controller2,
  }) {
    return GestureDetector(
      onTap: () {
        onSelectionChanged(choiceValue);
      },
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Radio<bool>(
              value: choiceValue,
              groupValue: currentSelection,
              onChanged: (value) {
                if (value != null) {
                  onSelectionChanged(value);
                }
              },
              activeColor: AppColors.licorice,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                return currentSelection == choiceValue
                    ? AppColors.licorice
                    : AppColors.frenchGray;
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
                  style: const TextStyle(color: AppColors.frenchGray),
                ),
                Row(
                  children: [
                    if (controller1 != null)
                      SmallTextFieldWidget(
                        controller: controller1,
                        textColor: currentSelection == choiceValue
                            ? AppColors.licorice
                            : AppColors.frenchGray,
                      ),
                    if (controller2 != null && isReps)
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text('-',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSelection == choiceValue
                                    ? AppColors.licorice
                                    : AppColors.frenchGray,
                              )),
                        ),
                      ),
                    if (controller2 != null && !isReps)
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSelection == choiceValue
                                    ? AppColors.licorice
                                    : AppColors.frenchGray,
                              )),
                        ),
                      ),
                    if (controller2 != null)
                      SmallTextFieldWidget(
                        controller: controller2,
                        textColor: currentSelection == choiceValue
                            ? AppColors.licorice
                            : AppColors.frenchGray,
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

  Container _buildTrainingGeneralInfo(BuildContext context) {
    final training = (context.read<TrainingManagementBloc>().state
            as TrainingManagementLoaded)
        .selectedTraining;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.parchment),
          color: AppColors.floralWhite,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _controllers['trainingName']!,
            hintText: tr('global_name'),
            borderColor: AppColors.parchment,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _controllers['trainingObjectives']!,
            hintText: tr('global_objectives'),
            borderColor: AppColors.parchment,
          ),
          const SizedBox(height: 20),
          Text(
            tr('training_detail_page_training_type'),
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          const SizedBox(height: 10),
          CustomDropdown<TrainingType>(
            items:
                TrainingType.values.sublist(0, TrainingType.values.length - 1),
            initialItem: training.trainingType,
            decoration: CustomDropdownDecoration(
              listItemStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.timberwolf),
              headerStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.licorice),
              closedSuffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.timberwolf,
              ),
              expandedSuffixIcon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 20,
                color: AppColors.timberwolf,
              ),
              closedBorder: Border.all(color: AppColors.parchment),
              expandedBorder: Border.all(color: AppColors.parchment),
            ),
            headerBuilder: (context, selectedItem, enabled) {
              return Text(selectedItem.translate(context.locale.languageCode));
            },
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              return Text(item.translate(context.locale.languageCode));
            },
            onChanged: (value) {
              final training = (context.read<TrainingManagementBloc>().state
                      as TrainingManagementLoaded)
                  .selectedTraining;

              sl<TrainingManagementBloc>().add(
                  CreateOrUpdateSelectedTrainingEvent(
                      training.copyWith(trainingType: value)));
            },
          ),
          const SizedBox(height: 20),
          Text(
            tr('training_detail_page_planning'),
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: TrainingDay.values.map((day) {
              bool isSelected = training.trainingDays.contains(day);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      List<TrainingDay> newSelection =
                          List.from(training.trainingDays);
                      if (isSelected) {
                        newSelection.remove(day);
                      } else {
                        newSelection.add(day);
                      }
                      setState(() {
                        final training = (context
                                .read<TrainingManagementBloc>()
                                .state as TrainingManagementLoaded)
                            .selectedTraining;

                        sl<TrainingManagementBloc>().add(
                          CreateOrUpdateSelectedTrainingEvent(
                            training.copyWith(
                              trainingDays: _sortTrainingDays(newSelection),
                            ),
                          ),
                        );
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected ? AppColors.folly : AppColors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.folly
                                  : AppColors.taupeGray,
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                            day
                                .translate(context.locale.languageCode)
                                .substring(0, 3),
                            style: TextStyle(
                                color: isSelected
                                    ? AppColors.licorice
                                    : AppColors.taupeGray))
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  SizedBox _buildHeader(BuildContext context, TrainingManagementLoaded state) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).push('/trainings');
                context
                    .read<TrainingManagementBloc>()
                    .add(ClearSelectedTrainingEvent());
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.licorice,
              ),
            ),
          ),
          Center(
            child: Text(
              (context.read<TrainingManagementBloc>().state
                              as TrainingManagementLoaded)
                          .selectedTraining
                          .id !=
                      null
                  ? context.tr('training_detail_page_title_edit')
                  : context.tr('training_detail_page_title_create'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (state.selectedTraining.id != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  sl<TrainingManagementBloc>()
                      .add(DeleteTrainingEvent(state.selectedTraining.id!));
                  GoRouter.of(context).push('/trainings');
                },
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.licorice,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum ExerciseDifficulty {
  veryEasy,
  easy,
  moderate,
  hard,
  veryHard;

  String translate(String locale) {
    switch (this) {
      case ExerciseDifficulty.veryEasy:
        return locale == 'fr' ? 'Très facile' : 'Very easy';
      case ExerciseDifficulty.easy:
        return locale == 'fr' ? 'Facile' : 'Easy';
      case ExerciseDifficulty.moderate:
        return locale == 'fr' ? 'Modéré' : 'Moderate';
      case ExerciseDifficulty.hard:
        return locale == 'fr' ? 'Difficile' : 'Hard';
      case ExerciseDifficulty.veryHard:
        return locale == 'fr' ? 'Très difficile' : 'Very hard';
    }
  }
}

final Map<int, ExerciseDifficulty> difficultyMap = Map.fromIterables(
  List.generate(ExerciseDifficulty.values.length, (index) => index + 1),
  ExerciseDifficulty.values,
);

final Map<ExerciseDifficulty, int> difficultyLevelMap = Map.fromIterables(
  ExerciseDifficulty.values,
  List.generate(ExerciseDifficulty.values.length, (index) => index + 1),
);
