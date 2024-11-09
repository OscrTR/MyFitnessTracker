import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/widgets/keyed_wrapper_widget.dart';
import '../../../exercise_management/presentation/widgets/exercise_detail_custom_text_field_widget.dart';
import '../../domain/entities/training.dart';
import '../bloc/training_management_bloc.dart';
import '../widgets/page_title_widget.dart';
import '../widgets/save_button_widget.dart';
import '../widgets/training_actions_widget.dart';
import '../widgets/training_type_selection_widget.dart';

class TrainingDetailsPage extends StatefulWidget {
  final TrainingType trainingType;

  const TrainingDetailsPage({super.key, required this.trainingType});

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<TrainingManagementBloc>()
        .add(LoadInitialSelectedTrainingData(widget.trainingType));
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
                    controller: state.nameController!,
                    hintText: 'Name',
                  ),
                  const SizedBox(height: 20),
                  TrainingTypeSelectionWidget(
                    selectedTrainingType: state.selectedTrainingType,
                    onTypeSelected: (type) {
                      context
                          .read<TrainingManagementBloc>()
                          .add(UpdateTrainingTypeEvent(type));
                    },
                  ),
                  const SizedBox(height: 20),
                  if (state.selectedTrainingWidgetList.length <= 1)
                    ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: state.selectedTrainingWidgetList),
                  if (state.selectedTrainingWidgetList.length > 1)
                    ReorderableListView(
                        physics: const NeverScrollableScrollPhysics(),
                        proxyDecorator: (child, index, animation) => child,
                        onReorder: (oldIndex, newIndex) {
                          if (oldIndex < newIndex) newIndex--;

                          // Create a new list with reordered items
                          final updatedList = List<KeyedWrapperWidget>.from(
                              state.selectedTrainingWidgetList);
                          final item = updatedList.removeAt(oldIndex);
                          updatedList.insert(newIndex, item);

                          // Update the list order in the Bloc
                          context.read<TrainingManagementBloc>().add(
                              UpdateSelectedTrainingWidgetsEvent(updatedList));
                        },
                        shrinkWrap: true,
                        children: state.selectedTrainingWidgetList),
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
