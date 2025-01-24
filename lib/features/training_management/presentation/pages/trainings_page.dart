import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app_colors.dart';
import '../../../exercise_management/presentation/bloc/exercise_management_bloc.dart';
import '../bloc/training_management_bloc.dart';
import '../../domain/entities/training.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  Map<TrainingType, bool> _selectedTrainingTypes = {};
  bool _isExercisesSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedTrainingTypes = {};
    _selectedTrainingTypes = Map.fromEntries(
        TrainingType.values.map((type) => MapEntry(type, false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('trainings_page_title'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                GestureDetector(
                  onTap: () {
                    _showNewDialog(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        color: AppColors.folly,
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: [
                        Text(
                          tr('trainings_page_new'),
                          style: const TextStyle(color: AppColors.white),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.add,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 4,
                    children: [
                      ..._selectedTrainingTypes.keys.map(
                        (e) => FilterChip(
                          side: BorderSide(
                              color: _selectedTrainingTypes[e]!
                                  ? AppColors.white
                                  : AppColors.timberwolf),
                          label: Text(
                            e.translate(context.locale.languageCode),
                          ),
                          labelStyle: TextStyle(
                            color: _selectedTrainingTypes[e]!
                                ? AppColors.white
                                : AppColors.licorice,
                          ),
                          showCheckmark: true,
                          selectedColor: AppColors.licorice,
                          checkmarkColor: AppColors.white,
                          backgroundColor: AppColors.white,
                          selected: _selectedTrainingTypes[e]!,
                          onSelected: (bool value) {
                            setState(() {
                              _selectedTrainingTypes[e] = value;
                              _isExercisesSelected = false;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 40,
                          width: 1,
                          color: AppColors.licorice,
                        ),
                      ),
                      FilterChip(
                        side: BorderSide(
                            color: _isExercisesSelected
                                ? AppColors.white
                                : AppColors.timberwolf),
                        label: Text(
                          tr('exercise_page_exercises'),
                        ),
                        labelStyle: TextStyle(
                          color: _isExercisesSelected
                              ? AppColors.white
                              : AppColors.licorice,
                        ),
                        showCheckmark: true,
                        selectedColor: AppColors.licorice,
                        checkmarkColor: AppColors.white,
                        backgroundColor: AppColors.white,
                        selected: _isExercisesSelected,
                        onSelected: (bool value) {
                          setState(() {
                            _isExercisesSelected = value;
                            _selectedTrainingTypes = Map.fromEntries(
                                TrainingType.values
                                    .map((type) => MapEntry(type, false)));
                          });
                        },
                      )
                    ],
                  ),
                  BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                      builder: (context, state) {
                    if (state is TrainingManagementLoaded) {
                      final hasSelectedTypes = _selectedTrainingTypes.values
                          .any((isSelected) => isSelected);
                      final displayedTrainings = hasSelectedTypes
                          ? state.trainings.where((training) =>
                              _selectedTrainingTypes[training.type] ?? false)
                          : state.trainings;

                      if (displayedTrainings.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Aucun entraînement trouvé'),
                          ),
                        );
                      }

                      if (!_isExercisesSelected) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedTrainings.length,
                          itemBuilder: (context, index) {
                            final training =
                                displayedTrainings.elementAt(index);
                            return Container(
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.timberwolf),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(training.name != ''
                                          ? training.name
                                          : 'Unnamed')
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<TrainingManagementBloc>()
                                          .add(GetTrainingEvent(
                                              id: training.id!));
                                      GoRouter.of(context)
                                          .push('/training_detail');
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.timberwolf),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                          child: Text(
                                              tr('training_page_see_details'))),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<TrainingManagementBloc>()
                                          .add(
                                              StartTrainingEvent(training.id!));
                                      GoRouter.of(context)
                                          .push('/active_training');
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: AppColors.licorice,
                                      ),
                                      child: Center(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.play_arrow_rounded,
                                            color: AppColors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            tr('global_start'),
                                            style: const TextStyle(
                                                color: AppColors.white),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return BlocBuilder<ExerciseManagementBloc,
                            ExerciseManagementState>(builder: (context, state) {
                          if (state is ExerciseManagementLoaded) {
                            final displayedExercises = state.exercises;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayedExercises.length,
                              itemBuilder: (context, index) {
                                final exercise =
                                    displayedExercises.elementAt(index);
                                return ListTile(
                                  title: Text(exercise.toString()),
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        });
                      }
                    }
                    return const SizedBox();
                  }),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showNewDialog(BuildContext context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('global_create')),
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              GoRouter.of(context).push(
                '/training_detail',
              );
              Navigator.pop(context, 'New training');
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.taupeGray),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                tr('training_page_create_training'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              GoRouter.of(context).push('/exercise_detail');
              Navigator.pop(context, 'New exercise');
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.taupeGray),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                tr('training_page_create_exercise'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
