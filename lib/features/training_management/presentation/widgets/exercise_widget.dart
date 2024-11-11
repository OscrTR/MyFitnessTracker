import 'dart:async';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
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

class ExerciseWidget extends StatefulWidget {
  final int widgetId;

  const ExerciseWidget({super.key, required this.widgetId});

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  Timer? _debounceTimer;
  late TextEditingController _setsController;
  late int? _exerciseId;

  final _repsMinController = TextEditingController();
  final _repsMaxController = TextEditingController();
  final _durationController = TextEditingController();
  final _setRestController = TextEditingController();
  final _exerciseRestController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _objectivesController = TextEditingController();

  Exercise selectedExercise = const Exercise(name: '');
  TrainingExercise trainingExercise = const TrainingExercise();

  String? selectedSetsChoice = 'Reps';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final bloc = context.read<TrainingManagementBloc>();
    final currentState = bloc.state;

    if (currentState is TrainingManagementLoaded) {
      _setsController = TextEditingController(
        text: currentState
                .selectedTraining?.trainingExercises[widget.widgetId].sets
                ?.toString() ??
            '',
      );
      _exerciseId = currentState
          .selectedTraining?.trainingExercises[widget.widgetId].exerciseId;
      print('_exerciseId is $_exerciseId');
    } else {
      _setsController = TextEditingController();
    }
    _setsController.addListener(_onSetsChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _setsController.dispose();
    _repsMinController.dispose();
    _repsMaxController.dispose();
    _durationController.dispose();
    _setRestController.dispose();
    _exerciseRestController.dispose();
    _specialInstructionsController.dispose();
    _objectivesController.dispose();
  }

  void _onSetsChanged() {
    _debounce(_updateSetsInBloc);
  }

  void _debounce(Function() action,
      [Duration delay = const Duration(milliseconds: 500)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  void _updateSetsInBloc() {
    final bloc = context.read<TrainingManagementBloc>();
    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      final updatedTrainingExercisesList = List<TrainingExercise>.from(
          currentState.selectedTraining!.trainingExercises);
      updatedTrainingExercisesList[widget.widgetId] =
          updatedTrainingExercisesList[widget.widgetId].copyWith(
        sets: int.tryParse(_setsController.text),
      );
      bloc.add(UpdateSelectedTrainingProperty(
          trainingExercises: updatedTrainingExercisesList));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.lightBlack),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          OutlinedButton(
              onPressed: () {
                print(context.read<TrainingManagementBloc>().state);
              },
              child: const Text('clic')),
          _buildExerciseDropdown(),
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
              controller: _specialInstructionsController,
              hintText: 'Special instructions'),
          const SizedBox(height: 10),
          BigTextFieldWidget(
              controller: _objectivesController, hintText: 'Objectives')
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Exercise', style: TextStyle(color: AppColors.lightBlack)),
        MoreWidget(widgetId: widget.widgetId),
      ],
    );
  }

  Widget _buildExerciseDropdown() {
    final exerciseId = (context.read<TrainingManagementBloc>().state
            as TrainingManagementLoaded)
        .selectedTraining
        ?.trainingExercises[widget.widgetId]
        .exerciseId;

    final exercises = context.select<ExerciseManagementBloc, List<Exercise>>(
      (bloc) => bloc.state is ExerciseManagementLoaded
          ? (bloc.state as ExerciseManagementLoaded).exercises
          : [],
    );

    const ExerciseModel noExercise = ExerciseModel(name: 'no exercise');

    final Exercise initialExercise = (context
            .read<ExerciseManagementBloc>()
            .state as ExerciseManagementLoaded)
        .exercises
        .firstWhere(
          (el) => el.id == exerciseId,
          orElse: () => noExercise,
        );

    return DropdownSearch<Exercise>(
      items: (f, cs) {
        return exercises;
      },
      selectedItem: initialExercise != noExercise ? initialExercise : null,
      compareFn: (Exercise? exercise, Exercise? selectedExercise) =>
          exercise?.id == selectedExercise?.id,
      itemAsString: (Exercise? exercise) => exercise?.name ?? '',
      onChanged: _dropDownOnChanged,
      decoratorProps: _dropDownDecoratorProps(),
      popupProps: _popupMenuProps(),
    );
  }

  void _dropDownOnChanged(selectedItem) {
    trainingExercise = trainingExercise.copyWith(exerciseId: selectedItem.id);
    selectedExercise = selectedExercise.copyWith(
        id: selectedItem.id,
        name: selectedItem.name,
        description: selectedItem.description,
        imagePath: selectedItem.imagePath);

    final bloc = context.read<TrainingManagementBloc>();

    if (bloc.state is TrainingManagementLoaded) {
      final currentState = bloc.state as TrainingManagementLoaded;
      // Check if training exercise exists at specific position in list
      if (currentState.selectedTraining != null) {
        // Copy the list to avoid modifying the original
        final updatedTrainingExercisesList = List<TrainingExercise>.from(
          currentState.selectedTraining!.trainingExercises,
        );

        // Update the specific training exercise at widget.widgetId (index)
        updatedTrainingExercisesList[widget.widgetId] =
            updatedTrainingExercisesList[widget.widgetId]
                .copyWith(exerciseId: selectedExercise.id);

        context.read<TrainingManagementBloc>().add(
            UpdateSelectedTrainingProperty(
                trainingExercises: updatedTrainingExercisesList));
      }
    }
  }

  PopupProps<Exercise> _popupMenuProps() {
    return PopupProps.menu(
      menuProps:
          const MenuProps(elevation: 0, backgroundColor: Colors.transparent),
      showSearchBox: true,
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: AppColors.lightBlack),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.lightBlack,
              width: 1,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.lightBlack,
              width: 1,
            ),
          ),
        ),
      ),
      containerBuilder: (context, popupWidget) {
        return Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.black,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(child: popupWidget),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    context
                        .read<ExerciseManagementBloc>()
                        .add(const ClearSelectedExerciseEvent());
                    GoRouter.of(context)
                        .push('/exercise_detail', extra: 'training_detail');
                  },
                  child: const Text(
                    'Create a new exercise',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  DropDownDecoratorProps _dropDownDecoratorProps() {
    return DropDownDecoratorProps(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.lightBlack,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.black,
            width: 1,
          ),
        ),
        hintText: 'No exercise selected yet',
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: AppColors.lightBlack),
      ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Sets', style: TextStyle(color: AppColors.lightBlack)),
        SmallTextFieldWidget(controller: _setsController),
      ],
    );
  }

  Widget _buildSetsChoiceOptions() {
    return Column(
      children: [
        _buildSetsChoiceOption('Reps', _repsMinController, _repsMaxController),
        _buildSetsChoiceOption('Duration', _durationController),
      ],
    );
  }

  Widget _buildSetsChoiceOption(String choice,
      [TextEditingController? controller1,
      TextEditingController? controller2]) {
    return GestureDetector(
      onTap: () => setState(() => selectedSetsChoice = choice),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Radio<String>(
              value: choice,
              groupValue: selectedSetsChoice,
              onChanged: (value) => setState(() => selectedSetsChoice = value!),
              activeColor: AppColors.black,
              fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                return selectedSetsChoice == choice
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
                Text(choice,
                    style: const TextStyle(color: AppColors.lightBlack)),
                Row(
                  children: [
                    if (controller1 != null)
                      SmallTextFieldWidget(controller: controller1),
                    if (controller2 != null)
                      const Text(' - ', style: TextStyle(fontSize: 20)),
                    if (controller2 != null)
                      SmallTextFieldWidget(controller: controller2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRestRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Set rest (seconds)',
            style: TextStyle(color: AppColors.lightBlack)),
        SmallTextFieldWidget(controller: _setRestController),
      ],
    );
  }

  Widget _buildExerciseRestRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Exercise rest (seconds)',
            style: TextStyle(color: AppColors.lightBlack)),
        SmallTextFieldWidget(controller: _exerciseRestController),
      ],
    );
  }
}