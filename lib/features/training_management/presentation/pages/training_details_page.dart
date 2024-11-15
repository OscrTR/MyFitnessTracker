import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/exercise_widget.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/keyed_wrapper_widget.dart';
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
                  if (state.selectedTraining != null &&
                      state.selectedTraining!.trainingExercises.isNotEmpty)
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
                  // if (state.selectedTrainingWidgetList.length > 1)
                  //   ReorderableListView(
                  //       physics: const NeverScrollableScrollPhysics(),
                  //       proxyDecorator: (child, index, animation) => child,
                  //       onReorder: (oldIndex, newIndex) {
                  //         if (oldIndex < newIndex) newIndex--;

                  //         // Create a new list with reordered items
                  //         final updatedList = List<KeyedWrapperWidget>.from(
                  //             state.selectedTrainingWidgetList);
                  //         final item = updatedList.removeAt(oldIndex);
                  //         updatedList.insert(newIndex, item);

                  //         // Update the list position in the Bloc
                  //         context.read<TrainingManagementBloc>().add(
                  //             UpdateSelectedTrainingWidgetsEvent(updatedList));
                  //       },
                  //       shrinkWrap: true,
                  //       children: state.selectedTrainingWidgetList),
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
