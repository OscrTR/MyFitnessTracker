import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/exercise_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/run_exercise_widget.dart';
import '../../../exercise_management/presentation/widgets/exercise_detail_custom_text_field_widget.dart';
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

    final bloc = context.read<TrainingManagementBloc>();
    final initialName = (bloc.state is TrainingManagementLoaded)
        ? (bloc.state as TrainingManagementLoaded).selectedTraining?.name ?? ''
        : '';

    _nameController = TextEditingController(text: initialName);
    // Add a listener with debounce to the controller
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const PageTitleWidget(),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Name',
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
                  OutlinedButton(
                      onPressed: () {
                        print(context.read<TrainingManagementBloc>().state);
                      },
                      child: Text('clic')),
                  if (state.selectedTraining != null &&
                      state.selectedTraining!.trainingExercises.length < 2)
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: state.selectedTraining!.trainingExercises
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        var tExercise = entry.value;
                        if (tExercise.trainingExerciseType ==
                            TrainingExerciseType.run) {
                          return RunExerciseWidget(widgetId: index);
                        }
                        return ExerciseWidget(widgetId: index);
                      }).toList(),
                    ),
                  if (state.selectedTraining!.trainingExercises.length > 1)
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (int oldIndex, int newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex--;
                        }

                        // Create a mutable copy of the list
                        final trainingExercises = List<TrainingExercise>.from(
                          state.selectedTraining!.trainingExercises,
                        );

                        // Remove and reinsert the item
                        final movedExercise =
                            trainingExercises.removeAt(oldIndex);
                        trainingExercises.insert(newIndex, movedExercise);

                        for (int i = 0; i < trainingExercises.length; i++) {
                          trainingExercises[i] =
                              trainingExercises[i].copyWith(position: i);
                        }

                        // Dispatch the updated list to the bloc
                        context.read<TrainingManagementBloc>().add(
                              UpdateSelectedTrainingProperty(
                                trainingExercises: trainingExercises,
                              ),
                            );
                      },
                      children: state.selectedTraining!.trainingExercises
                          .map((exercise) {
                        return exercise.trainingExerciseType ==
                                TrainingExerciseType.run
                            ? RunExerciseWidget(
                                key: ValueKey(
                                    exercise.key), // Use the generated key
                                widgetId: state
                                    .selectedTraining!.trainingExercises
                                    .indexOf(exercise),
                              )
                            : ExerciseWidget(
                                key: ValueKey(
                                    exercise.key), // Use the generated key
                                widgetId: state
                                    .selectedTraining!.trainingExercises
                                    .indexOf(exercise),
                              );
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
                    training: state.selectedTraining,
                    onSave: () {
                      context
                          .read<TrainingManagementBloc>()
                          .add(SaveSelectedTrainingEvent());
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
