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
import '../../exercise_management/bloc/exercise_management_bloc.dart';
import '../models/training.dart';

import '../../../app_colors.dart';
import '../../../helper_functions.dart';
import '../../../injection_container.dart';
import '../../../core/widgets/custom_text_field_widget.dart';
import '../../exercise_management/models/exercise.dart';
import '../models/multiset.dart';
import '../models/training_exercise.dart';
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

  final TrainingExercise _defaultTExercise = TrainingExercise.create(
    sets: 1,
    isSetsInReps: true,
    type: TrainingExerciseType.workout,
    isAutoStart: false,
    runType: RunType.distance,
    isTargetPaceSelected: false,
    intensity: 2,
    linkedTrainingId: null,
    linkedMultisetId: null,
    linkedExerciseId: null,
  );

  TrainingExercise _tExerciseToCreateOrEdit = TrainingExercise.create(
    sets: 1,
    isSetsInReps: true,
    type: TrainingExerciseType.workout,
    isAutoStart: false,
    runType: RunType.distance,
    isTargetPaceSelected: false,
    intensity: 2,
    linkedTrainingId: null,
    linkedMultisetId: null,
    linkedExerciseId: null,
  );

  final Multiset _defaultMultiset = Multiset.create(
    linkedTrainingId: null,
    sets: 1,
    setRest: 0,
    multisetRest: 0,
    specialInstructions: '',
    objectives: '',
    position: null,
    trainingExercises: [],
  );

  Multiset _multisetToCreateOrEdit = Multiset.create(
    linkedTrainingId: null,
    sets: 1,
    setRest: 0,
    multisetRest: 0,
    specialInstructions: '',
    objectives: '',
    position: null,
    trainingExercises: [],
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

    _controllers['trainingName']!.text = training?.name ?? '';
    _controllers['trainingObjectives']!.text = training?.objectives ?? '';
  }

  void initializeExerciseControllers(String key) {
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final trainingExercises = [
        ...currentState.selectedTraining?.trainingExercises ?? [],
        ...currentState.selectedTraining?.multisets
                .expand((m) => m.trainingExercises) ??
            []
      ];
      final TrainingExercise exercise =
          trainingExercises.firstWhere((exercise) => exercise.key == key);

      _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
        key: key,
        type: exercise.type,
        runType: exercise.runType,
        isTargetPaceSelected: exercise.isTargetPaceSelected,
        isAutoStart: exercise.isAutoStart,
        isSetsInReps: exercise.isSetsInReps,
        exercise: exercise.exercise.target,
        sets: exercise.sets,
        duration: exercise.duration,
        minReps: exercise.minReps,
        maxReps: exercise.maxReps,
        setRest: exercise.setRest,
        specialInstructions: exercise.specialInstructions,
        objectives: exercise.objectives,
        targetDistance: exercise.targetDistance,
        targetDuration: exercise.targetDuration,
        id: exercise.id,
        linkedTrainingId: exercise.linkedTrainingId,
        linkedMultisetId: exercise.linkedMultisetId,
        linkedExerciseId: exercise.linkedExerciseId,
        targetPace: exercise.targetPace,
        exerciseRest: exercise.exerciseRest,
        position: exercise.position,
        intensity: exercise.intensity,
      );

      _controllers['sets']?.text = exercise.sets.toString();
      _controllers['durationMinutes']?.text = (exercise.duration != null
          ? (exercise.duration! % 3600 ~/ 60).toString()
          : '');
      _controllers['durationSeconds']?.text = (exercise.duration != null
          ? (exercise.duration! % 60).toString()
          : '');
      _controllers['minReps']?.text = exercise.minReps?.toString() ?? '';
      _controllers['maxReps']?.text = exercise.maxReps?.toString() ?? '';
      _controllers['setRestMinutes']?.text = (exercise.setRest != null
          ? (exercise.setRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['setRestSeconds']?.text =
          (exercise.setRest != null ? (exercise.setRest! % 60).toString() : '');
      _controllers['specialInstructions']?.text =
          exercise.specialInstructions?.toString() ?? '';
      _controllers['objectives']?.text = exercise.objectives?.toString() ?? '';
      _controllers['distance']?.text = (exercise.targetDistance != null
          ? (exercise.targetDistance! / 1000).toString()
          : '');
      _controllers['targetDurationHours']?.text =
          (exercise.targetDuration != null
              ? (exercise.targetDuration! ~/ 3600).toString()
              : '');
      _controllers['targetDurationMinutes']?.text =
          (exercise.targetDuration != null
              ? (exercise.targetDuration! % 3600 ~/ 60).toString()
              : '');
      _controllers['targetDurationSeconds']?.text =
          (exercise.targetDuration != null
              ? (exercise.targetDuration! % 60).toString()
              : '');
      _controllers['paceMinutes']?.text = (exercise.targetPace != null
          ? (exercise.targetPace! % 3600 ~/ 60).toString()
          : '');
      _controllers['paceSeconds']?.text = (exercise.targetPace != null
          ? (exercise.targetPace! % 60).toString()
          : '');
      _controllers['exerciseRestMinutes']?.text = (exercise.exerciseRest != null
          ? (exercise.exerciseRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['exerciseRestSeconds']?.text = (exercise.exerciseRest != null
          ? (exercise.exerciseRest! % 60).toString()
          : '');
    }
  }

  void initializeMultisetControllers(String key) {
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final List<Multiset> multisets =
          currentState.selectedTraining?.multisets ?? [];
      final Multiset multiset =
          multisets.firstWhere((multiset) => multiset.key == key);

      _multisetToCreateOrEdit = _multisetToCreateOrEdit.copyWith(
        key: key,
        id: multiset.id,
        linkedTrainingId: multiset.linkedTrainingId,
        trainingExercises: multiset.trainingExercises,
        sets: multiset.sets,
        setRest: multiset.setRest,
        multisetRest: multiset.multisetRest,
        specialInstructions: multiset.specialInstructions,
        objectives: multiset.objectives,
        position: multiset.position,
      );

      _controllers['multisetSets']?.text = multiset.sets.toString();
      _controllers['multisetSetRestMinutes']?.text =
          ((multiset.setRest % 3600 ~/ 60).toString());
      _controllers['multisetSetRestSeconds']?.text =
          ((multiset.setRest % 60).toString());
      _controllers['multisetRestMinutes']?.text =
          (multiset.multisetRest % 3600 ~/ 60).toString();
      _controllers['multisetRestSeconds']?.text =
          (multiset.multisetRest % 60).toString();
      _controllers['multisetInstructions']?.text =
          multiset.specialInstructions?.toString() ?? '';
      _controllers['multisetObjectives']?.text =
          multiset.objectives?.toString() ?? '';
    }
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
              .selectedTraining ??
          Training.create(
            name: '',
            type: TrainingType.workout,
            trainingExercises: [],
            multisets: [],
            objectives: '',
            trainingDays: [],
          );

      final trainingToCreateOrEdit = training.copyWith(
        name: _controllers['trainingName']!.text.trim(),
        objectives: _controllers['trainingObjectives']!.text.trim(),
      );

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
            ? int.tryParse(_controllers['multisetSets']?.text ?? '1')
            : currentValues['sets'] as int?,
        setRest: key == 'multisetSetRestMinutes' ||
                key == 'multisetSetRestSeconds'
            ? ((int.tryParse(_controllers['multisetSetRestMinutes']?.text ??
                            '0') ??
                        0) *
                    60) +
                ((int.tryParse(
                        _controllers['multisetSetRestSeconds']?.text ?? '0') ??
                    0))
            : currentValues['setRest'] as int?,
        multisetRest: key == 'multisetRestMinutes' ||
                key == 'multisetRestSeconds'
            ? ((int.tryParse(
                            _controllers['multisetRestMinutes']?.text ?? '0') ??
                        0) *
                    60) +
                ((int.tryParse(
                        _controllers['multisetRestSeconds']?.text ?? '0') ??
                    0))
            : currentValues['multisetRest'] as int?,
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
        'sets': _tExerciseToCreateOrEdit.sets,
        'minReps': _tExerciseToCreateOrEdit.minReps,
        'maxReps': _tExerciseToCreateOrEdit.maxReps,
        'duration': _tExerciseToCreateOrEdit.duration,
        'setRest': _tExerciseToCreateOrEdit.setRest,
        'exerciseRest': _tExerciseToCreateOrEdit.exerciseRest,
        'specialInstructions': _tExerciseToCreateOrEdit.specialInstructions,
        'objectives': _tExerciseToCreateOrEdit.objectives,
        'distance': _tExerciseToCreateOrEdit.targetDistance,
        'targetDuration': _tExerciseToCreateOrEdit.targetDuration,
        'targetPace': _tExerciseToCreateOrEdit.targetPace,
      };

      _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
        sets: key == 'sets'
            ? int.tryParse(_controllers['sets']?.text ?? '1')
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
                ((int.tryParse(_controllers['durationSeconds']?.text ?? '0') ??
                    0))
            : currentValues['duration'] as int?,
        setRest: key == 'setRestMinutes' || key == 'setRestSeconds'
            ? ((int.tryParse(_controllers['setRestMinutes']?.text ?? '0') ??
                        0) *
                    60) +
                ((int.tryParse(_controllers['setRestSeconds']?.text ?? '0') ??
                    0))
            : currentValues['setRest'] as int?,
        exerciseRest: key == 'exerciseRestMinutes' ||
                key == 'exerciseRestSeconds'
            ? ((int.tryParse(
                            _controllers['exerciseRestMinutes']?.text ?? '0') ??
                        0) *
                    60) +
                ((int.tryParse(
                        _controllers['exerciseRestSeconds']?.text ?? '0') ??
                    0))
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
                ((int.tryParse(
                        _controllers['targetDurationSeconds']?.text ?? '') ??
                    0))
            : currentValues['targetDuration'] as int?,
        targetPace: key == 'paceMinutes' || key == 'paceSeconds'
            ? ((int.tryParse(_controllers['paceMinutes']?.text ?? '') ?? 0) *
                    60) +
                ((int.tryParse(_controllers['paceSeconds']?.text ?? '') ?? 0))
            : currentValues['targetPace'] as int?,
      );
    }
  }

  void _resetData() {
    _tExerciseToCreateOrEdit = _defaultTExercise;
    _multisetToCreateOrEdit = _defaultMultiset;
    _controllers.forEach((key, controller) {
      if (key != 'trainingName' && key != 'trainingObjectives') {
        controller.text = '';
      }
    });
  }

  List<WeekDay> _sortTrainingDays(List<WeekDay> weekdays) {
    return weekdays..sort((a, b) => a.index.compareTo(b.index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
        builder: (context, state) {
          if (state is TrainingManagementLoaded) {
            final training = state.selectedTraining;
            List<Map<String, Object>> exercisesAndMultisetsList = [];

            if (training != null) {
              if (!_isDataInitialized) {
                _initializeTrainingGeneralInfo();
                _isDataInitialized = true;
              }
              exercisesAndMultisetsList = [
                ...state.selectedTraining!.trainingExercises
                    .map((e) => {'type': 'exercise', 'data': e}),
                ...state.selectedTraining!.multisets
                    .map((m) => {'type': 'multiset', 'data': m}),
              ];
              exercisesAndMultisetsList.sort((a, b) {
                final aPosition = (a['data'] as dynamic).position ?? 0;
                final bPosition = (b['data'] as dynamic).position ?? 0;
                return aPosition.compareTo(bPosition);
              });
            }

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
                            exercisesAndMultisetsList, context),
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
                    .selectedTraining ??
                Training.create(
                  name: '',
                  type: TrainingType.workout,
                  trainingExercises: [],
                  multisets: [],
                  objectives: '',
                  trainingDays: [],
                );
            final bloc = context.read<TrainingManagementBloc>();
            bloc.add(CreateOrUpdateTrainingEvent(training));
            GoRouter.of(context).push('/trainings');
          },
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.folly, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                state.selectedTraining == null ||
                        state.selectedTraining!.id == 0
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
      BuildContext context) {
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
          final exercise = item['data'] as TrainingExercise;
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

        // Dispatch the updated training exercises to the bloc
        context.read<TrainingManagementBloc>().add(
              UpdateSelectedTrainingProperty(
                  trainingExercises: updatedExercises,
                  multisets: updatedMultisets),
            );
      },
      children: exercisesAndMultisetsList.asMap().entries.map((entry) {
        var item = entry.value;

        if (item['type'] == 'exercise') {
          var tExercise = item['data'] as TrainingExercise;
          if (tExercise.type == TrainingExerciseType.run) {
            if (exercisesAndMultisetsList.length <= 1) {
              return GestureDetector(
                key: ValueKey(tExercise.key),
                onLongPress: () {},
                child: _buildRunExerciseItem(tExercise, context, null),
              );
            } else {
              return _buildRunExerciseItem(tExercise, context, null);
            }
          }

          final Exercise? exercise = (context
                  .read<ExerciseManagementBloc>()
                  .state as ExerciseManagementLoaded)
              .exercises
              .firstWhereOrNull(
                (el) => el.id == tExercise.linkedExerciseId,
              );

          if (exercisesAndMultisetsList.length <= 1) {
            return GestureDetector(
              key: ValueKey(tExercise.key),
              onLongPress: () {},
              child: _buildExerciseItem(tExercise, exercise, context, null),
            );
          } else {
            return _buildExerciseItem(tExercise, exercise, context, null);
          }
        } else if (item['type'] == 'multiset') {
          var tMultiset = item['data'] as Multiset;

          if (exercisesAndMultisetsList.length <= 1) {
            return GestureDetector(
              key: ValueKey(tMultiset.key),
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

  Container _buildExerciseItem(TrainingExercise tExercise, Exercise? exercise,
      BuildContext context, String? multisetKey) {
    return Container(
      key: ValueKey(tExercise.key),
      margin: EdgeInsets.only(top: multisetKey == null ? 20 : 10),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.timberwolf),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise?.imagePath != null && exercise!.imagePath!.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  width: 130,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(exercise.imagePath!),
                      width: MediaQuery.of(context).size.width - 40,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          if (exercise?.imagePath != null && exercise!.imagePath!.isNotEmpty)
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
                        exercise?.name ?? tr('exercise_unknown'),
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
                              initializeExerciseControllers(tExercise.key!);
                              _buildExerciseDialog(context,
                                  multisetKey: multisetKey);
                            } else if (value == 'delete') {
                              final bloc =
                                  BlocProvider.of<TrainingManagementBloc>(
                                      context);
                              if (multisetKey != null) {
                                bloc.add(RemoveMultisetExerciseEvent(
                                    multisetKey: multisetKey,
                                    exerciseKey: tExercise.key!));
                              } else {
                                bloc.add(RemoveTrainingExerciseEvent(
                                    tExercise.key!));
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
                  '${multisetKey == null ? '${tExercise.sets}x' : ''}${tExercise.isSetsInReps ? '${tExercise.minReps ?? 0}-${tExercise.maxReps ?? 0} reps' : '${tExercise.duration} seconds'}',
                  style: const TextStyle(color: AppColors.taupeGray),
                ),
                Text(
                  '${multisetKey == null ? (tExercise.setRest ?? 0) : tExercise.exerciseRest ?? 0} seconds rest',
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
      TrainingExercise tExercise, BuildContext context, String? multisetKey) {
    return Container(
      key: ValueKey(tExercise.key),
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
                        initializeExerciseControllers(tExercise.key!);
                        _buildExerciseDialog(context, multisetKey: multisetKey);
                      } else if (value == 'delete') {
                        final bloc =
                            BlocProvider.of<TrainingManagementBloc>(context);
                        bloc.add(RemoveTrainingExerciseEvent(tExercise.key!));
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
          _buildRunText(tExercise),
        ],
      ),
    );
  }

  Container _buildMultisetItem(BuildContext context, Multiset tMultiset) {
    return Container(
      key: ValueKey(tMultiset.key!),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
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
                        initializeMultisetControllers(tMultiset.key!);
                        _buildMultisetDialog(context);
                      } else if (value == 'delete') {
                        final bloc =
                            BlocProvider.of<TrainingManagementBloc>(context);
                        bloc.add(RemoveTrainingExerciseEvent(tMultiset.key!));
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
            '${tMultiset.sets} set(s)',
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          Text(
            '${tMultiset.setRest} seconds rest',
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          _buildExercisesList(tMultiset.key!),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _buildExerciseDialog(context, multisetKey: tMultiset.key);
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

  Widget _buildExercisesList(String multisetKey) {
    final multisetExercises = (context.read<TrainingManagementBloc>().state
                as TrainingManagementLoaded)
            .selectedTraining
            ?.multisets
            .firstWhere((multiset) => multiset.key == multisetKey)
            .trainingExercises ??
        [];

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final TrainingExercise tExercise = multisetExercises[index];
          if (tExercise.type == TrainingExerciseType.run) {
            return _buildRunExerciseItem(tExercise, context, multisetKey);
          }

          final Exercise? exercise = (context
                  .read<ExerciseManagementBloc>()
                  .state as ExerciseManagementLoaded)
              .exercises
              .firstWhereOrNull(
                (el) => el.id == tExercise.linkedExerciseId,
              );
          return _buildExerciseItem(tExercise, exercise, context, multisetKey);
        },
        itemCount: multisetExercises.length);
  }

  Column _buildRunText(TrainingExercise tExercise) {
    if (tExercise.sets > 1) {
      final targetDistance =
          tExercise.targetDistance != null && tExercise.targetDistance! > 0
              ? '${(tExercise.targetDistance! / 1000).toStringAsFixed(1)}km'
              : '';
      final targetDuration = tExercise.targetDuration != null
          ? formatDurationToHoursMinutesSeconds(tExercise.targetDuration!)
          : '';
      final targetPace = tExercise.isTargetPaceSelected == true
          ? ' at ${formatPace(tExercise.targetPace ?? 0)}'
          : '';
      final intervals = tExercise.sets;
      if (tExercise.runType == RunType.distance) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${intervals}x$targetDistance$targetPace',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
            Text(
              '${tExercise.setRest ?? 0} seconds rest',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${intervals}x$targetDuration$targetPace',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
            Text(
              '${tExercise.setRest ?? 0} seconds rest',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
          ],
        );
      }
    } else {
      final targetDistance =
          tExercise.targetDistance != null && tExercise.targetDistance! > 0
              ? '${(tExercise.targetDistance! / 1000).toStringAsFixed(1)}km'
              : '';
      final targetDuration = tExercise.targetDuration != null
          ? formatDurationToHoursMinutesSeconds(tExercise.targetDuration!)
          : '';
      final targetPace = tExercise.isTargetPaceSelected == true
          ? ' at ${formatPace(tExercise.targetPace ?? 0)}'
          : '';
      if (tExercise.runType == RunType.distance) {
        return Column(
          children: [
            Text(
              '$targetDistance$targetPace',
              style: const TextStyle(color: AppColors.taupeGray),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Text(
              '$targetDuration$targetPace',
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
            final bool isEdit = _multisetToCreateOrEdit.key != null;
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
                            .selectedTraining ??
                        Training.create(
                          name: '',
                          type: TrainingType.workout,
                          trainingExercises: [],
                          multisets: [],
                          objectives: '',
                          trainingDays: [],
                        );

                    sl<TrainingManagementBloc>().add(
                        CreateOrUpdateMultisetEvent(
                            multiset: _multisetToCreateOrEdit,
                            training: training));

                    _resetData();
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

    _resetData();
  }

  Future<void> _buildExerciseDialog(BuildContext context,
      {String? multisetKey}) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Builder(builder: (context) {
          final bool isEdit = _tExerciseToCreateOrEdit.key != null;
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
                  CustomDropdown<TrainingExerciseType>(
                    items: TrainingExerciseType.values
                        .sublist(0, TrainingExerciseType.values.length - 1),
                    initialItem: _tExerciseToCreateOrEdit.type,
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
                          _tExerciseToCreateOrEdit =
                              _tExerciseToCreateOrEdit.copyWith(type: value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomDropdown<ExerciseDifficulty>(
                    items: ExerciseDifficulty.values,
                    initialItem:
                        difficultyMap[_tExerciseToCreateOrEdit.intensity] ??
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
                      _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit
                          .copyWith(intensity: difficultyLevelMap[value!]);
                    },
                  ),
                  const SizedBox(height: 20),
                  _tExerciseToCreateOrEdit.type != TrainingExerciseType.run
                      ? _buildYogaOrWorkoutFields(context, setDialogState,
                          multisetKey, _tExerciseToCreateOrEdit.exercise.target)
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
                          value: _tExerciseToCreateOrEdit.isAutoStart,
                          onChanged: (bool? value) {
                            setDialogState(
                              () {
                                _tExerciseToCreateOrEdit =
                                    _tExerciseToCreateOrEdit.copyWith(
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
                  if (multisetKey != null) {
                    sl<TrainingManagementBloc>().add(
                        CreateOrUpdateMultisetExerciseEvent(
                            trainingExercise: _tExerciseToCreateOrEdit,
                            multisetKey: multisetKey));
                  } else {
                    final training = (context
                                .read<TrainingManagementBloc>()
                                .state as TrainingManagementLoaded)
                            .selectedTraining ??
                        Training.create(
                          name: '',
                          type: TrainingType.workout,
                          trainingExercises: [],
                          multisets: [],
                          objectives: '',
                          trainingDays: [],
                        );

                    sl<TrainingManagementBloc>().add(
                        CreateOrUpdateTrainingExerciseEvent(
                            trainingExercise: _tExerciseToCreateOrEdit,
                            training: training));
                  }

                  _resetData();
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

    _resetData();
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
          currentSelection: _tExerciseToCreateOrEdit.runType!,
          onSelectionChanged: (RunType value) {
            setDialogState(() {
              _tExerciseToCreateOrEdit =
                  _tExerciseToCreateOrEdit.copyWith(runType: value);
            });
          },
          controller1: _controllers['distance'],
        ),
        _buildTargetChoiceOption(
          choice: tr('exercise_duration'),
          choiceValue: RunType.duration,
          currentSelection: _tExerciseToCreateOrEdit.runType!,
          onSelectionChanged: (RunType value) {
            setDialogState(() {
              _tExerciseToCreateOrEdit =
                  _tExerciseToCreateOrEdit.copyWith(runType: value);
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
                value: _tExerciseToCreateOrEdit.isTargetPaceSelected,
                onChanged: (value) {
                  setDialogState(
                    () {
                      _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit
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
                        textColor:
                            _tExerciseToCreateOrEdit.isTargetPaceSelected!
                                ? AppColors.licorice
                                : AppColors.frenchGray,
                      ),
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: _tExerciseToCreateOrEdit
                                        .isTargetPaceSelected!
                                    ? AppColors.licorice
                                    : AppColors.frenchGray,
                              )),
                        ),
                      ),
                      SmallTextFieldWidget(
                        controller: _controllers['paceSeconds']!,
                        textColor:
                            _tExerciseToCreateOrEdit.isTargetPaceSelected!
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

  Column _buildYogaOrWorkoutFields(BuildContext context,
      StateSetter setDialogState, String? multisetKey, Exercise? exercise) {
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
        CustomDropdown<Exercise>.search(
          items:
              (sl<ExerciseManagementBloc>().state as ExerciseManagementLoaded)
                  .exercises,
          hintText: tr('exercise_search'),
          initialItem: exercise != null
              ? (sl<ExerciseManagementBloc>().state as ExerciseManagementLoaded)
                  .exercises
                  .firstWhereOrNull((exercise) => exercise.id == exercise.id)
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
            _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
                exercise: value, linkedExerciseId: value?.id);
          },
        ),
        const SizedBox(height: 20),
        if (multisetKey == null)
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
          currentSelection: _tExerciseToCreateOrEdit.isSetsInReps,
          isReps: true,
          onSelectionChanged: (bool newValue) {
            setDialogState(() {
              _tExerciseToCreateOrEdit =
                  _tExerciseToCreateOrEdit.copyWith(isSetsInReps: newValue);
            });
          },
          controller1: _controllers['minReps'],
          controller2: _controllers['maxReps'],
        ),
        _buildSetsChoiceOption(
          choice: tr('exercise_duration'),
          choiceValue: false,
          currentSelection: _tExerciseToCreateOrEdit.isSetsInReps,
          isReps: false,
          onSelectionChanged: (bool newValue) {
            setDialogState(() {
              _tExerciseToCreateOrEdit =
                  _tExerciseToCreateOrEdit.copyWith(isSetsInReps: newValue);
            });
          },
          controller1: _controllers['durationMinutes'],
          controller2: _controllers['durationSeconds'],
        ),
        if (multisetKey == null)
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
            .selectedTraining ??
        Training.create(
          name: '',
          type: TrainingType.workout,
          trainingExercises: [],
          multisets: [],
          objectives: '',
          trainingDays: [],
        );

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
            initialItem: training.type,
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
                      .selectedTraining ??
                  Training.create(
                    name: '',
                    type: TrainingType.workout,
                    trainingExercises: [],
                    multisets: [],
                    objectives: '',
                    trainingDays: [],
                  );

              sl<TrainingManagementBloc>().add(
                  CreateOrUpdateSelectedTrainingEvent(
                      training.copyWith(type: value)));
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
            children: WeekDay.values.map((day) {
              bool isSelected = training.trainingDays!.contains(day);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      List<WeekDay> newSelection =
                          List.from(training.trainingDays!);
                      if (isSelected) {
                        newSelection.remove(day);
                      } else {
                        newSelection.add(day);
                      }
                      setState(() {
                        final training = (context
                                    .read<TrainingManagementBloc>()
                                    .state as TrainingManagementLoaded)
                                .selectedTraining ??
                            Training.create(
                              name: '',
                              type: TrainingType.workout,
                              trainingExercises: [],
                              multisets: [],
                              objectives: '',
                              trainingDays: [],
                            );

                        sl<TrainingManagementBloc>().add(
                            CreateOrUpdateSelectedTrainingEvent(
                                training.copyWith(
                                    trainingDays:
                                        _sortTrainingDays(newSelection))));
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
                          ?.id !=
                      null
                  ? context.tr('training_detail_page_title_edit')
                  : context.tr('training_detail_page_title_create'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (state.selectedTraining != null && state.selectedTraining!.id != 0)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  sl<TrainingManagementBloc>()
                      .add(DeleteTrainingEvent(state.selectedTraining!));
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
