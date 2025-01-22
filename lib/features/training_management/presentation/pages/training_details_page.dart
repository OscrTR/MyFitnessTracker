import 'dart:async';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';

import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../../core/widgets/custom_text_field_widget.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../domain/entities/multiset.dart';
import '../../domain/entities/training_exercise.dart';
import '../bloc/training_management_bloc.dart';
import '../widgets/big_text_field_widget.dart';
import '../widgets/multiset_widget.dart';
import '../widgets/run_exercise_widget.dart';
import '../widgets/small_text_field_widget.dart';

class TrainingDetailsPage extends StatefulWidget {
  const TrainingDetailsPage({super.key});

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  late TrainingType _selectedTrainingType;
  late final Map<String, TextEditingController> _controllers;
  Timer? _debounceTimer;
  List<WeekDay> _selectedDays = [];

  final TrainingExercise _defaultTExercise = const TrainingExercise(
    isSetsInReps: true,
    trainingExerciseType: TrainingExerciseType.workout,
    autoStart: false,
    runExerciseTarget: RunExerciseTarget.distance,
    isIntervalInDistance: true,
    isTargetPaceSelected: false,
  );

  TrainingExercise _tExerciseToCreateOrEdit = const TrainingExercise(
    isSetsInReps: true,
    trainingExerciseType: TrainingExerciseType.workout,
    autoStart: false,
    runExerciseTarget: RunExerciseTarget.distance,
    isIntervalInDistance: true,
    isTargetPaceSelected: false,
  );

  final Multiset _defaultMultiset = const Multiset(
    trainingId: null,
    trainingExercises: [],
    sets: 1,
    setRest: 0,
    multisetRest: 0,
    specialInstructions: '',
    objectives: '',
    position: null,
  );

  Multiset _multisetToCreateOrEdit = const Multiset(
    trainingId: null,
    trainingExercises: [],
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
    _initializeTrainingGeneralInfo();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeTrainingGeneralInfo() {
    final training =
        (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
            .selectedTraining;
    _selectedTrainingType = training?.type ?? TrainingType.workout;
    _selectedDays = training?.trainingDays ?? [];
    _controllers['trainingName']!.text = training?.name ?? '';
    _controllers['trainingObjectives']!.text = training?.objectives ?? '';
  }

  void initializeExercises() {
    // TODO
  }

  void initializeExerciseControllers(String key) {
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final trainingExercises =
          currentState.selectedTraining?.trainingExercises ?? [];
      final exercise =
          trainingExercises.firstWhere((exercise) => exercise.key == key);

      _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
          key: key, trainingExerciseType: exercise.trainingExerciseType);

      _controllers['sets']?.text = exercise.sets?.toString() ?? '';
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

  void initializeMultisetControllers(String key) {
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      final multisets = currentState.selectedTraining?.multisets ?? [];
      final multiset = multisets.firstWhere((multiset) => multiset.key == key);

      _multisetToCreateOrEdit = _multisetToCreateOrEdit.copyWith(key: key);

      _controllers['multisetSets']?.text = multiset.sets?.toString() ?? '';
      _controllers['multisetSetRestMinutes']?.text = (multiset.setRest != null
          ? (multiset.setRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['multisetSetRestSeconds']?.text =
          (multiset.setRest != null ? (multiset.setRest! % 60).toString() : '');
      _controllers['multisetRestMinutes']?.text = (multiset.multisetRest != null
          ? (multiset.multisetRest! % 3600 ~/ 60).toString()
          : '');
      _controllers['multisetRestSeconds']?.text = (multiset.multisetRest != null
          ? (multiset.multisetRest! % 60).toString()
          : '');
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
      'durationHours': TextEditingController(),
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
      'intervals': TextEditingController(),
      'paceMinutes': TextEditingController(),
      'paceSeconds': TextEditingController(),
      'intervalDistance': TextEditingController(),
      'intervalMinutes': TextEditingController(),
      'intervalSeconds': TextEditingController(),
      'intervalRestMinutes': TextEditingController(),
      'intervalRestSeconds': TextEditingController(),
    };
  }

  void _attachListeners() {
    _controllers.forEach((key, controller) {
      controller.addListener(() => _onControllerChanged(key));
    });
  }

  void _onControllerChanged(String key) {
    _debounce(() => _updateData(key));
  }

  void _debounce(Function() action,
      [Duration delay = const Duration(milliseconds: 500)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  void _updateData(String key) {
    if (!mounted) return;

    final bloc = context.read<TrainingManagementBloc>();

    if (key == 'trainingName') {
      bloc.add(
        UpdateSelectedTrainingProperty(
          name: _controllers['trainingName']!.text.trim(),
        ),
      );
    } else if (key == 'trainingObjectives') {
      bloc.add(
        UpdateSelectedTrainingProperty(
          name: _controllers['trainingObjectives']!.text.trim(),
        ),
      );
    } else if (key.contains('multiset')) {
      _multisetToCreateOrEdit = _multisetToCreateOrEdit.copyWith(
        sets: key == 'multisetSets'
            ? int.tryParse(_controllers['multisetSets']?.text ?? '')
            : null,
        setRest: key == 'multisetSetRestMinutes' ||
                key == 'multisetSetRestSeconds'
            ? ((int.tryParse(_controllers['multisetSetRestMinutes']?.text ??
                            '') ??
                        0) *
                    60) +
                ((int.tryParse(
                        _controllers['multisetSetRestSeconds']?.text ?? '') ??
                    0))
            : null,
        multisetRest: key == 'multisetRestMinutes' ||
                key == 'multisetRestSeconds'
            ? ((int.tryParse(_controllers['multisetRestMinutes']?.text ?? '') ??
                        0) *
                    60) +
                ((int.tryParse(
                        _controllers['multisetRestSeconds']?.text ?? '') ??
                    0))
            : null,
        specialInstructions: key == 'multisetInstructions'
            ? _controllers['multisetInstructions']?.text ?? ''
            : null,
        objectives: key == 'multisetObjectives'
            ? _controllers['multisetObjectives']?.text ?? ''
            : null,
      );
    } else {
      _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
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
            ? ((int.tryParse(_controllers['durationHours']?.text ?? '') ?? 0) *
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
        intervalRest: key == 'intervalRestMinutes' ||
                key == 'intervalRestSeconds'
            ? ((int.tryParse(_controllers['intervalRestMinutes']?.text ?? '') ??
                        0) *
                    60) +
                ((int.tryParse(
                        _controllers['intervalRestSeconds']?.text ?? '') ??
                    0))
            : null,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
        if (state is TrainingManagementLoaded) {
          final exercisesAndMultisetsList = [
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

          // final initialName = state.selectedTraining?.name ?? '';
          // _controllers['trainingName']!.text = initialName;

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
                      if (state.selectedTraining != null &&
                          exercisesAndMultisetsList.length < 2)
                        _buildSimpleListView(
                            exercisesAndMultisetsList, context),
                      if (exercisesAndMultisetsList.length > 1)
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
            final bloc = context.read<TrainingManagementBloc>();
            final trainingId =
                (bloc.state as TrainingManagementLoaded).selectedTraining?.id;
            if (trainingId != null) {
              bloc.add(UpdateTrainingEvent());
              GoRouter.of(context).push('/trainings');
            } else {
              bloc.add(SaveSelectedTrainingEvent());
              GoRouter.of(context).push('/trainings');
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.folly, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                state.selectedTraining!.id == null
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
        int index = entry.key;
        var item = entry.value;

        if (item['type'] == 'exercise') {
          var tExercise = item['data'] as TrainingExercise;
          if (tExercise.trainingExerciseType == TrainingExerciseType.run) {
            return RunExerciseWidget(
              key: ValueKey(tExercise.key), // Unique key for exercises
              exerciseKey: tExercise.key!,
            );
          }
          final Exercise? exercise = (context
                  .read<ExerciseManagementBloc>()
                  .state as ExerciseManagementLoaded)
              .exercises
              .firstWhereOrNull(
                (el) => el.id == tExercise.exerciseId,
              );
          return Container(
            key: ValueKey(tExercise.key),
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.timberwolf),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white),
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise?.imagePath != null &&
                    exercise!.imagePath!.isNotEmpty)
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 160,
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
                                    initializeExerciseControllers(
                                        tExercise.key!);
                                    _buildExerciseDialog(context);
                                  } else if (value == 'delete') {
                                    final bloc =
                                        BlocProvider.of<TrainingManagementBloc>(
                                            context);
                                    bloc.add(
                                        RemoveExerciseFromSelectedTrainingEvent(
                                            tExercise.key!));
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(
                                      tr('global_edit'),
                                      style: const TextStyle(
                                          color: AppColors.taupeGray),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      tr('global_delete'),
                                      style: const TextStyle(
                                          color: AppColors.taupeGray),
                                    ),
                                  ),
                                ],
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: AppColors.lightBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${tExercise.sets}x${tExercise.isSetsInReps! ? '${tExercise.minReps ?? 0}-${tExercise.maxReps ?? 0} reps' : '${tExercise.duration} seconds'}',
                        style: const TextStyle(color: AppColors.taupeGray),
                      ),
                      Text(
                        '${tExercise.setRest ?? 0} seconds rest',
                        style: const TextStyle(color: AppColors.taupeGray),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        } else if (item['type'] == 'multiset') {
          var tMultiset = item['data'] as Multiset;
          return MultisetWidget(
            key: ValueKey(index), // Unique key for multisets
            multisetKey: tMultiset.key!,
          );
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

  ListView _buildSimpleListView(
      List<Map<String, Object>> exercisesAndMultisetsList,
      BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: exercisesAndMultisetsList.asMap().entries.map((entry) {
        var item = entry.value;
        if (item['type'] == 'exercise') {
          var tExercise = item['data'] as TrainingExercise;
          final Exercise? exercise = (context
                  .read<ExerciseManagementBloc>()
                  .state as ExerciseManagementLoaded)
              .exercises
              .firstWhereOrNull(
                (el) => el.id == tExercise.exerciseId,
              );
          if (tExercise.trainingExerciseType == TrainingExerciseType.run) {
            return Container(
              margin: const EdgeInsets.only(top: 10),
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
                                side: const BorderSide(
                                    color: AppColors.timberwolf)),
                            color: AppColors.white,
                            onSelected: (value) {
                              if (value == 'edit') {
                                initializeExerciseControllers(tExercise.key!);
                                _buildExerciseDialog(context);
                              } else if (value == 'delete') {
                                final bloc =
                                    BlocProvider.of<TrainingManagementBloc>(
                                        context);
                                bloc.add(
                                    RemoveExerciseFromSelectedTrainingEvent(
                                        tExercise.key!));
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  tr('global_edit'),
                                  style: const TextStyle(
                                      color: AppColors.taupeGray),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  tr('global_delete'),
                                  style: const TextStyle(
                                      color: AppColors.taupeGray),
                                ),
                              ),
                            ],
                            icon: const Icon(
                              Icons.more_horiz,
                              color: AppColors.lightBlack,
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
          return Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.timberwolf),
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise?.imagePath != null &&
                    exercise!.imagePath!.isNotEmpty)
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 160,
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
                                    initializeExerciseControllers(
                                        tExercise.key!);
                                    _buildExerciseDialog(context);
                                  } else if (value == 'delete') {
                                    final bloc =
                                        BlocProvider.of<TrainingManagementBloc>(
                                            context);
                                    bloc.add(
                                        RemoveExerciseFromSelectedTrainingEvent(
                                            tExercise.key!));
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(
                                      tr('global_edit'),
                                      style: const TextStyle(
                                          color: AppColors.taupeGray),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      tr('global_delete'),
                                      style: const TextStyle(
                                          color: AppColors.taupeGray),
                                    ),
                                  ),
                                ],
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: AppColors.lightBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${tExercise.sets}x${tExercise.isSetsInReps! ? '${tExercise.minReps ?? 0}-${tExercise.maxReps ?? 0} reps' : '${tExercise.duration} seconds'}',
                        style: const TextStyle(color: AppColors.taupeGray),
                      ),
                      Text(
                        '${tExercise.setRest ?? 0} seconds rest',
                        style: const TextStyle(color: AppColors.taupeGray),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        } else if (item['type'] == 'multiset') {
          var tMultiset = item['data'] as Multiset;
          return Container(
            margin: const EdgeInsets.only(top: 10),
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
                              side: const BorderSide(
                                  color: AppColors.timberwolf)),
                          color: AppColors.white,
                          onSelected: (value) {
                            if (value == 'edit') {
                              initializeMultisetControllers(tMultiset.key!);
                              _buildMultisetDialog(context);
                            } else if (value == 'delete') {
                              final bloc =
                                  BlocProvider.of<TrainingManagementBloc>(
                                      context);
                              bloc.add(RemoveExerciseFromSelectedTrainingEvent(
                                  tMultiset.key!));
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
                            color: AppColors.lightBlack,
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
                  '${tMultiset.setRest ?? 0} seconds rest',
                  style: const TextStyle(color: AppColors.taupeGray),
                )
              ],
            ),
          );
        }
        return const SizedBox.shrink(); // Fallback for unknown types
      }).toList(),
    );
  }

  Column _buildRunText(TrainingExercise tExercise) {
    if (tExercise.runExerciseTarget == RunExerciseTarget.intervals) {
      final targetDistance =
          tExercise.intervalDistance != null && tExercise.intervalDistance! > 0
              ? '${(tExercise.intervalDistance! / 1000).toStringAsFixed(1)}km'
              : '';
      final targetDuration = tExercise.intervalDuration != null
          ? formatDurationToHoursMinutesSeconds(tExercise.intervalDuration!)
          : '';
      final targetPace = tExercise.isTargetPaceSelected == true
          ? ' at ${formatPace(tExercise.targetPace ?? 0)}'
          : '';
      final intervals = tExercise.intervals ?? 1;
      if (tExercise.isIntervalInDistance == true) {
        return Column(
          children: [
            Text(
              '${intervals}x $targetDistance$targetPace',
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
          children: [
            Text(
              '${intervals}x $targetDuration$targetPace',
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
      if (tExercise.runExerciseTarget == RunExerciseTarget.distance) {
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
                                  const TextStyle(color: AppColors.lightBlack)),
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
                                  const TextStyle(color: AppColors.lightBlack)),
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
                                  const TextStyle(color: AppColors.lightBlack)),
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
                    sl<TrainingManagementBloc>()
                        .add(AddOrUpdateMultisetEvent(_multisetToCreateOrEdit));
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

  Future<void> _buildExerciseDialog(BuildContext context) async {
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
                    items: TrainingExerciseType.values,
                    initialItem: _tExerciseToCreateOrEdit.trainingExerciseType,
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
                          _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit
                              .copyWith(trainingExerciseType: value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _tExerciseToCreateOrEdit.trainingExerciseType !=
                          TrainingExerciseType.run
                      ? _buildYogaOrWorkoutFields(context, setDialogState)
                      : _buildRunFields(setDialogState),
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('exercise_exercise_rest'),
                            style:
                                const TextStyle(color: AppColors.lightBlack)),
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
                          value: _tExerciseToCreateOrEdit.autoStart!,
                          onChanged: (bool? value) {
                            setDialogState(
                              () {
                                _tExerciseToCreateOrEdit =
                                    _tExerciseToCreateOrEdit.copyWith(
                                        autoStart: value);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tr('training_detail_page_autostart'),
                        style: const TextStyle(color: AppColors.lightBlack),
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
                  sl<TrainingManagementBloc>().add(
                      AddOrUpdateTrainingExerciseEvent(
                          _tExerciseToCreateOrEdit));
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
        _buildTargetChoiceOption(
          choice: tr('exercise_distance'),
          choiceValue: RunExerciseTarget.distance,
          currentSelection: _tExerciseToCreateOrEdit.runExerciseTarget!,
          onSelectionChanged: (RunExerciseTarget value) {
            setDialogState(() {
              _tExerciseToCreateOrEdit =
                  _tExerciseToCreateOrEdit.copyWith(runExerciseTarget: value);
            });
          },
          controller1: _controllers['distance'],
        ),
        _buildTargetChoiceOption(
          choice: tr('exercise_duration'),
          choiceValue: RunExerciseTarget.duration,
          currentSelection: _tExerciseToCreateOrEdit.runExerciseTarget!,
          onSelectionChanged: (RunExerciseTarget value) {
            setDialogState(() {
              _tExerciseToCreateOrEdit =
                  _tExerciseToCreateOrEdit.copyWith(runExerciseTarget: value);
            });
          },
          controller1: _controllers['durationHours'],
          controller2: _controllers['durationMinutes'],
          controller3: _controllers['durationSeconds'],
        ),
        _buildTargetChoiceOption(
          choice: tr('exercise_intervals'),
          choiceValue: RunExerciseTarget.intervals,
          currentSelection: _tExerciseToCreateOrEdit.runExerciseTarget!,
          onSelectionChanged: (RunExerciseTarget value) {
            setDialogState(() {
              _tExerciseToCreateOrEdit =
                  _tExerciseToCreateOrEdit.copyWith(runExerciseTarget: value);
            });
          },
          controller1: _controllers['intervals'],
        ),
        _buildIntervalsChoiceOption(
          choice: tr('exercise_interval_distance'),
          choiceValue: true,
          currentSelection: _tExerciseToCreateOrEdit.isIntervalInDistance!,
          controller1: _controllers['intervalDistance'],
          onSelectionChanged: (bool value) {
            setDialogState(() {
              _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
                  isIntervalInDistance: value);
            });
          },
        ),
        _buildIntervalsChoiceOption(
          choice: tr('exercise_interval_duration'),
          choiceValue: false,
          currentSelection: _tExerciseToCreateOrEdit.isIntervalInDistance!,
          controller1: _controllers['intervalMinutes'],
          controller2: _controllers['intervalSeconds'],
          onSelectionChanged: (bool value) {
            setDialogState(() {
              _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
                  isIntervalInDistance: value);
            });
          },
        ),
        SizedBox(
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
                  const SizedBox(
                    width: 20,
                    child: Center(
                      child: Text(':', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  SmallTextFieldWidget(
                      controller: _controllers['intervalRestSeconds']!),
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
                  _tExerciseToCreateOrEdit = _tExerciseToCreateOrEdit.copyWith(
                      isTargetPaceSelected: value);
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
                        textColor:
                            _tExerciseToCreateOrEdit.isTargetPaceSelected!
                                ? AppColors.black
                                : AppColors.lightBlack,
                      ),
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: _tExerciseToCreateOrEdit
                                        .isTargetPaceSelected!
                                    ? AppColors.black
                                    : AppColors.lightBlack,
                              )),
                        ),
                      ),
                      SmallTextFieldWidget(
                        controller: _controllers['paceSeconds']!,
                        textColor:
                            _tExerciseToCreateOrEdit.isTargetPaceSelected!
                                ? AppColors.black
                                : AppColors.lightBlack,
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

  Widget _buildIntervalsChoiceOption({
    required String choice,
    required bool choiceValue,
    required bool currentSelection,
    required ValueChanged<bool> onSelectionChanged,
    TextEditingController? controller1,
    TextEditingController? controller2,
  }) {
    return GestureDetector(
      onTap: () => onSelectionChanged(choiceValue),
      child: Row(
        children: [
          const SizedBox(width: 30),
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
              activeColor: AppColors.black,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                return _tExerciseToCreateOrEdit.runExerciseTarget ==
                        RunExerciseTarget.intervals
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
                        textColor: _tExerciseToCreateOrEdit.runExerciseTarget ==
                                RunExerciseTarget.intervals
                            ? currentSelection == choiceValue
                                ? AppColors.black
                                : AppColors.lightBlack
                            : AppColors.lightBlack,
                      ),
                    if (controller2 != null)
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: _tExerciseToCreateOrEdit
                                            .runExerciseTarget ==
                                        RunExerciseTarget.intervals
                                    ? currentSelection == choiceValue
                                        ? AppColors.black
                                        : AppColors.lightBlack
                                    : AppColors.lightBlack,
                              )),
                        ),
                      ),
                    if (controller2 != null)
                      SmallTextFieldWidget(
                        controller: controller2,
                        textColor: _tExerciseToCreateOrEdit.runExerciseTarget ==
                                RunExerciseTarget.intervals
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

  Column _buildYogaOrWorkoutFields(
      BuildContext context, StateSetter setDialogState) {
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
                  const Icon(
                    Symbols.arrow_right_alt,
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
            _tExerciseToCreateOrEdit =
                _tExerciseToCreateOrEdit.copyWith(exerciseId: value?.id);
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('exercise_sets'),
                  style: const TextStyle(color: AppColors.lightBlack)),
              SmallTextFieldWidget(controller: _controllers['sets']!),
            ],
          ),
        ),
        _buildSetsChoiceOption(
          choice: tr('exercise_reps'),
          choiceValue: true,
          currentSelection: _tExerciseToCreateOrEdit.isSetsInReps!,
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
          currentSelection: _tExerciseToCreateOrEdit.isSetsInReps!,
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
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('exercise_set_rest'),
                  style: const TextStyle(color: AppColors.lightBlack)),
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
    required RunExerciseTarget choiceValue,
    required RunExerciseTarget currentSelection,
    required ValueChanged<RunExerciseTarget> onSelectionChanged,
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
            child: Radio<RunExerciseTarget>(
              value: choiceValue,
              groupValue: currentSelection,
              onChanged: (value) {
                if (value != null) {
                  onSelectionChanged(value);
                }
              },
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
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSelection == choiceValue
                                    ? AppColors.black
                                    : AppColors.lightBlack,
                              )),
                        ),
                      ),
                    if (controller2 != null)
                      SmallTextFieldWidget(
                        controller: controller2,
                        textColor: currentSelection == choiceValue
                            ? AppColors.black
                            : AppColors.lightBlack,
                      ),
                    if (controller3 != null)
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text(':',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSelection == choiceValue
                                    ? AppColors.black
                                    : AppColors.lightBlack,
                              )),
                        ),
                      ),
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
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Text('-',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSelection == choiceValue
                                    ? AppColors.black
                                    : AppColors.lightBlack,
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
                                    ? AppColors.black
                                    : AppColors.lightBlack,
                              )),
                        ),
                      ),
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

  Container _buildTrainingGeneralInfo(BuildContext context) {
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
            items: TrainingType.values,
            initialItem: _selectedTrainingType,
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
              _selectedTrainingType = value!;
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
              bool isSelected = _selectedDays.contains(day);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      List<WeekDay> newSelection = List.from(_selectedDays);
                      if (isSelected) {
                        newSelection.remove(day);
                      } else {
                        newSelection.add(day);
                      }
                      setState(() {
                        _selectedDays = newSelection;
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
                    .add(const ClearSelectedTrainingEvent());
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.black,
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
          if (state.selectedTraining != null &&
              state.selectedTraining!.id != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  sl<TrainingManagementBloc>()
                      .add(DeleteTrainingEvent(state.selectedTraining!.id!));
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
