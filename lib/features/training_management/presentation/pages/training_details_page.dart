import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';

import '../../../../app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../core/widgets/custom_text_field_widget.dart';
import '../../domain/entities/multiset.dart';
import '../../domain/entities/training_exercise.dart';
import '../bloc/training_management_bloc.dart';
import '../widgets/exercise_widget.dart';
import '../widgets/multiset_widget.dart';
import '../widgets/run_exercise_widget.dart';
import '../widgets/save_button_widget.dart';
import '../widgets/training_actions_widget.dart';

class TrainingDetailsPage extends StatefulWidget {
  const TrainingDetailsPage({super.key});

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _objectivesController;
  late TrainingType _selectedTrainingType;
  Timer? _nameDebounceTimer;
  Timer? _objectivesDebounceTimer;
  List<WeekDay> _selectedDays = [];

  static const int _debounceMilliseconds = 500;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
    final training =
        (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
            .selectedTraining;
    _selectedTrainingType = training?.type ?? TrainingType.workout;
    _selectedDays = training?.trainingDays ?? [];
  }

  @override
  void dispose() {
    _nameDebounceTimer?.cancel();
    _objectivesDebounceTimer?.cancel();
    _nameController.dispose();
    _objectivesController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: '');
    _objectivesController = TextEditingController(text: '');
  }

  void _setupListeners() {
    _nameController.addListener(() => _onNameChanged());
    _objectivesController.addListener(() => _onObjectivesChanged());
  }

  void _onNameChanged() {
    _debounce(
      timer: _nameDebounceTimer,
      onTimerUpdate: (timer) => _nameDebounceTimer = timer,
      callback: () => _updateName(_nameController.text),
    );
  }

  void _onObjectivesChanged() {
    _debounce(
      timer: _objectivesDebounceTimer,
      onTimerUpdate: (timer) => _objectivesDebounceTimer = timer,
      callback: () => _updateObjectives(_objectivesController.text),
    );
  }

  void _debounce({
    required Timer? timer,
    required void Function(Timer?) onTimerUpdate,
    required VoidCallback callback,
  }) {
    if (timer?.isActive ?? false) timer?.cancel();

    final newTimer = Timer(
      const Duration(milliseconds: _debounceMilliseconds),
      callback,
    );
    onTimerUpdate(newTimer);
  }

  void _updateName(String name) {
    if (!mounted) return;

    context.read<TrainingManagementBloc>().add(
          UpdateSelectedTrainingProperty(
            name: name.trim(),
          ),
        );
  }

  void _updateObjectives(String objectives) {
    if (!mounted) return;

    context.read<TrainingManagementBloc>().add(
          UpdateSelectedTrainingProperty(
            objectives: objectives.trim(),
          ),
        );
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

          final initialName = state.selectedTraining?.name ?? '';
          _nameController.text = initialName;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(context, state),
                  const SizedBox(height: 30),
                  _buildTrainingGeneralInfo(context),
                  const SizedBox(height: 20),
                  if (state.selectedTraining != null &&
                      exercisesAndMultisetsList.length < 2)
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: exercisesAndMultisetsList
                          .asMap()
                          .entries
                          .map((entry) {
                        var item = entry.value;
                        if (item['type'] == 'exercise') {
                          var tExercise = item['data'] as TrainingExercise;
                          if (tExercise.trainingExerciseType ==
                              TrainingExerciseType.run) {
                            return RunExerciseWidget(
                              exerciseKey: tExercise.key!,
                            );
                          }
                          return ExerciseWidget(
                            exerciseKey: tExercise.key!,
                          );
                        } else if (item['type'] == 'multiset') {
                          var tMultiset = item['data'] as Multiset;
                          return MultisetWidget(multisetKey: tMultiset.key!);
                        }
                        return const SizedBox
                            .shrink(); // Fallback for unknown types
                      }).toList(),
                    ),
                  if (exercisesAndMultisetsList.length > 1)
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (int oldIndex, int newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex--;
                        }

                        final combinedList = List<Map<String, dynamic>>.from(
                            exercisesAndMultisetsList);

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
                      children: exercisesAndMultisetsList
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        if (item['type'] == 'exercise') {
                          var tExercise = item['data'] as TrainingExercise;
                          if (tExercise.trainingExerciseType ==
                              TrainingExerciseType.run) {
                            return RunExerciseWidget(
                              key: ValueKey(
                                  tExercise.key), // Unique key for exercises
                              exerciseKey: tExercise.key!,
                            );
                          }
                          return ExerciseWidget(
                            key: ValueKey(
                                tExercise.key), // Unique key for exercises
                            exerciseKey: tExercise.key!,
                          );
                        } else if (item['type'] == 'multiset') {
                          var tMultiset = item['data'] as Multiset;
                          return MultisetWidget(
                            key: ValueKey(index), // Unique key for multisets
                            multisetKey: tMultiset.key!,
                          );
                        }
                        return const SizedBox
                            .shrink(); // Fallback for unknown types
                      }).toList(),
                      proxyDecorator: (child, index, animation) => Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: child,
                      ),
                    ),
                  const SizedBox(height: 20),
                  const TrainingActionsWidget(),
                  const SizedBox(height: 30),
                  SaveButtonWidget(
                    onSave: () {
                      final bloc = context.read<TrainingManagementBloc>();
                      final trainingId =
                          (bloc.state as TrainingManagementLoaded)
                              .selectedTraining
                              ?.id;
                      if (trainingId != null) {
                        bloc.add(UpdateTrainingEvent());
                        GoRouter.of(context).push('/trainings');
                      } else {
                        bloc.add(SaveSelectedTrainingEvent());
                        GoRouter.of(context).push('/trainings');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return Center(child: Text(context.tr('error_state')));
      },
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
            controller: _nameController,
            hintText: tr('global_name'),
            borderColor: AppColors.parchment,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _objectivesController,
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
