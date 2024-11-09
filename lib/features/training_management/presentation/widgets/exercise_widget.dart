import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';
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
          // TODO : exercise search

          // TODO : exercise display
          const Divider(
            color: AppColors.lightBlack,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sets', style: TextStyle(color: AppColors.lightBlack)),
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
