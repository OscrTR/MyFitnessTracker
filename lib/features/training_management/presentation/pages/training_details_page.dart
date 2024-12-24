import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/training_exercise.dart';
import '../widgets/exercise_widget.dart';
import '../widgets/multiset_widget.dart';
import '../widgets/run_exercise_widget.dart';
import '../../../exercise_management/presentation/widgets/exercise_detail_custom_text_field_widget.dart';
import '../../domain/entities/multiset.dart';
import '../bloc/training_management_bloc.dart';
import '../widgets/page_title_widget.dart';
import '../widgets/save_button_widget.dart';
import '../widgets/training_actions_widget.dart';
import '../widgets/training_type_selection_widget.dart';

class TrainingDetailsPage extends StatefulWidget {
  const TrainingDetailsPage({super.key});

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  late TextEditingController _nameController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Cancel the previous timer if it exists
    _debounceTimer?.cancel();

    // Start a new timer that will trigger after a delay (e.g., 500 milliseconds)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Dispatch an event to update the name in the Bloc after the debounce delay
      context.read<TrainingManagementBloc>().add(
            UpdateSelectedTrainingProperty(name: _nameController.text),
          );
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

          final initialName = state.selectedTraining?.name ?? '';
          _nameController.text = initialName;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const PageTitleWidget(),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _nameController,
                    hintText: tr('global_name'),
                  ),
                  const SizedBox(height: 20),
                  TrainingTypeSelectionWidget(
                    selectedTrainingType: state.selectedTraining!.type,
                    onTypeSelected: (type) {
                      context
                          .read<TrainingManagementBloc>()
                          .add(UpdateSelectedTrainingProperty(type: type));
                    },
                  ),
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
}
