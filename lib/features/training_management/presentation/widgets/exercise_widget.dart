import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
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
  final _setsController = TextEditingController();
  final _repsMinController = TextEditingController();
  final _repsMaxController = TextEditingController();
  final _durationController = TextEditingController();
  final _setRestController = TextEditingController();
  final _exerciseRestController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _objectivesController = TextEditingController();
  final List<String> setsChoices = ['Reps', 'Duration'];
  String? selectedSetsChoice = 'Reps';

  @override
  void dispose() {
    _setsController.dispose();
    _repsMinController.dispose();
    _repsMaxController.dispose();
    _durationController.dispose();
    _setRestController.dispose();
    _exerciseRestController.dispose();
    _specialInstructionsController.dispose();
    _objectivesController.dispose();
    super.dispose();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Exercise',
                style: TextStyle(color: AppColors.lightBlack),
              ),
              MoreWidget(widgetId: widget.widgetId)
            ],
          ),
          DropdownSearch<Exercise>(
            items: (f, cs) {
              final currentState = context.read<ExerciseManagementBloc>().state;
              if (currentState is ExerciseManagementLoaded) {
                return currentState.exercises;
              }
              return [];
            },
            compareFn: (Exercise? exercise, Exercise? selectedExercise) =>
                exercise?.id == selectedExercise?.id,
            itemAsString: (Exercise? exercise) => exercise?.name ?? '',
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors
                        .lightBlack, // Set color for the enabled border
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.black, // Set color for the focused border
                    width: 1,
                  ),
                ),
                hintText: 'No exercise selected yet',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.lightBlack),
              ),
            ),
            onChanged: (selectedItem) {
              context
                  .read<ExerciseManagementBloc>()
                  .add(GetExerciseEvent(selectedItem!.id!));
            },
            popupProps: PopupProps.menu(
              menuProps: const MenuProps(
                  elevation: 0, backgroundColor: Colors.transparent),
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
                      color: AppColors
                          .lightBlack, // Search box enabled border color
                      width: 1,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors
                          .lightBlack, // Search box focused border color
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
                  child: popupWidget,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
              builder: (context, state) {
            if (state is ExerciseManagementLoaded) {
              if (state.selectedExercise != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.lightBlack, width: 1.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: state.selectedExercise!.imagePath != ''
                            ? Image.file(
                                File(state.selectedExercise!.imagePath!),
                                width: MediaQuery.of(context).size.width - 40,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.lightGrey,
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.selectedExercise!.description ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: AppColors.lightBlack),
                    ),
                  ],
                );
              }
              return const SizedBox();
            }
            return const Text("Exercises couldn't load");
          }),
          const SizedBox(height: 10),
          const Divider(
            color: AppColors.lightBlack,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sets', style: TextStyle(color: AppColors.lightBlack)),
              SmallTextFieldWidget(
                controller: _setsController,
              )
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSetsChoice = 'Reps';
                  });
                },
                child: Row(
                  children: [
                    ClipRect(
                      child: SizedBox(
                        width: 20,
                        child: Radio(
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                              return selectedSetsChoice == 'Reps'
                                  ? AppColors.black
                                  : AppColors.lightBlack;
                            }),
                            value: 'Reps',
                            groupValue: selectedSetsChoice,
                            onChanged: (value) {
                              setState(() {
                                selectedSetsChoice = value;
                              });
                            }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Reps',
                              style: TextStyle(color: AppColors.lightBlack)),
                          Row(
                            children: [
                              SmallTextFieldWidget(
                                  controller: _repsMinController),
                              const Text(
                                '  -  ',
                                style: TextStyle(fontSize: 20),
                              ),
                              SmallTextFieldWidget(
                                  controller: _repsMaxController),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSetsChoice = 'Duration';
                  });
                },
                child: Row(
                  children: [
                    ClipRect(
                      child: SizedBox(
                        width: 20,
                        child: Radio(
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                              return selectedSetsChoice == 'Duration'
                                  ? AppColors.black
                                  : AppColors.lightBlack;
                            }),
                            value: 'Duration',
                            groupValue: selectedSetsChoice,
                            onChanged: (value) {
                              setState(() {
                                selectedSetsChoice = value;
                              });
                            }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Duration (seconds)',
                            style: TextStyle(color: AppColors.lightBlack),
                          ),
                          SmallTextFieldWidget(controller: _durationController)
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Set rest (seconds)',
                  style: TextStyle(color: AppColors.lightBlack)),
              SmallTextFieldWidget(
                controller: _setRestController,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exercise rest (seconds)',
                  style: TextStyle(color: AppColors.lightBlack)),
              SmallTextFieldWidget(
                controller: _exerciseRestController,
              )
            ],
          ),
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
}
