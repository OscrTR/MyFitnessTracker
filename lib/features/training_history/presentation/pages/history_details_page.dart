import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_fitness_tracker/core/widgets/small_text_field_widget.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/bloc/training_history_bloc.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/widgets/altitude_chart_widget.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/widgets/pace_chart_widget.dart';
import 'package:my_fitness_tracker/features/training_history/presentation/widgets/run_map_widget.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:collection/collection.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../exercise_management/domain/entities/exercise.dart';
import '../../../training_management/domain/entities/multiset.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/history_run_location.dart';

class HistoryDetailsPage extends StatelessWidget {
  const HistoryDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
          builder: (context, state) {
        if (state is TrainingHistoryLoaded &&
            state.selectedTrainingEntry != null) {
          final matchingTraining =
              (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
                  .trainings
                  .firstWhereOrNull((training) =>
                      training.id == state.selectedTrainingEntry!.trainingId);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(context, state, matchingTraining),
                  const SizedBox(height: 10),
                  if (matchingTraining != null)
                    _buildMatchingTraining(matchingTraining, state)
                  else
                    _buildNoMatchTraining(context, state)
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget _buildMatchingTraining(
      Training training, TrainingHistoryLoaded state) {
    final sortedItems = [
      ...training.trainingExercises.map((e) => {'type': 'exercise', 'data': e}),
      ...training.multisets.map((m) => {'type': 'multiset', 'data': m}),
    ];
    sortedItems.sort((a, b) {
      final aPos = (a['data'] as dynamic).position ?? 0;
      final bPos = (b['data'] as dynamic).position ?? 0;
      return aPos.compareTo(bPos);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        if (item['type'] == 'exercise') {
          final tExercise = item['data'] as TrainingExercise;
          final matchingExercise =
              (sl<ExerciseManagementBloc>().state as ExerciseManagementLoaded)
                  .exercises
                  .firstWhereOrNull((e) => e.id == tExercise.exerciseId);
          print(state.selectedTrainingEntry!.historyEntries);
          print('id ${tExercise.id} and set ${index}');
          final entry = state.selectedTrainingEntry!.historyEntries.firstWhere(
              (entry) =>
                  entry.trainingExerciseId == tExercise.id &&
                  entry.setNumber == index);
          final locations = state.selectedTrainingEntry!.locations
              .where((location) =>
                  location.trainingExerciseId == tExercise.id &&
                  location.setNumber == index)
              .toList();

          return tExercise.trainingExerciseType == TrainingExerciseType.run
              ? tExercise.sets! > 1
                  ? IntervalExercise(
                      historyState: state,
                      trainingExercise: tExercise,
                      training: training,
                    )
                  : RunExercise(
                      historyEntry: entry,
                      runLocations: locations,
                      trainingExercise: tExercise,
                    )
              : ExerciseSetForm(
                  trainingExercise: tExercise,
                  matchingExercise: matchingExercise,
                  historyState: state,
                  training: training,
                );
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          return Text('MULTISET');
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoMatchTraining(
      BuildContext context, TrainingHistoryLoaded state) {
    Map<int, List<HistoryEntry>> groupedEntries = groupBy(
        state.selectedTrainingEntry!.historyEntries,
        (HistoryEntry entry) => entry.trainingExerciseId);

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groupedEntries.length,
        itemBuilder: (context, index) {
          int trainingExerciseId = groupedEntries.keys.elementAt(index);
          List<HistoryEntry> entries = groupedEntries[trainingExerciseId]!;

          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.timberwolf),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entries[0].exerciseNameAtTime),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sets',
                        style: TextStyle(color: AppColors.taupeGray)),
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: Text(
                              entries[0].weight != null ? 'Kg' : '',
                              style:
                                  const TextStyle(color: AppColors.taupeGray),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (entries[0].reps != null)
                          const SizedBox(
                            width: 50,
                            child: Center(
                              child: Text(
                                'Reps',
                                style: TextStyle(color: AppColors.taupeGray),
                              ),
                            ),
                          )
                        else
                          const SizedBox(
                            width: 70,
                            child: Center(
                              child: Text(
                                'Duration',
                                style: TextStyle(color: AppColors.taupeGray),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                ...entries.map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.trainingExerciseType !=
                          TrainingExerciseType.run)
                        _buildExerciseFields(entry)
                      else
                        _buildRunExerciseFields(entry)
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildExerciseFields(HistoryEntry entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${(entry.setNumber ?? 0) + 1}'),
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '${entry.weight ?? ''}',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            if (entry.reps != null)
              SizedBox(
                width: 50,
                child: Text(
                  '${entry.reps}',
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                width: 70,
                child: Text(
                  formatDurationToHoursMinutesSeconds(entry.duration ?? 0),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRunExerciseFields(HistoryEntry entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${(entry.setNumber ?? 0) + 1}'),
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '${entry.distance ?? 0}',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text(
                formatDurationToHoursMinutesSeconds(entry.duration ?? 0),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                formatPace(entry.pace ?? 0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Stack _buildHeader(
      BuildContext context, TrainingHistoryLoaded state, Training? training) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              GoRouter.of(context).go('/home');
            },
            child: const Icon(
              LucideIcons.chevronLeft,
              color: AppColors.licorice,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(state.selectedTrainingEntry!.date),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              Text(
                training != null
                    ? training.name
                    : '${state.selectedTrainingEntry!.trainingName} (${tr('global_deleted')})',
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              context.read<TrainingHistoryBloc>().add(
                  DeleteHistoryTrainingEvent(
                      historyTraining: state.selectedTrainingEntry!));
              GoRouter.of(context).go('/home');
            },
            child: const Icon(
              LucideIcons.trash,
              color: AppColors.licorice,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class IntervalExercise extends StatelessWidget {
  final TrainingExercise trainingExercise;
  final TrainingHistoryLoaded historyState;
  final Training training;
  const IntervalExercise(
      {super.key,
      required this.trainingExercise,
      required this.historyState,
      required this.training});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: trainingExercise.sets,
      itemBuilder: (context, index) {
        // Find matching history entry
        final entry = historyState.selectedTrainingEntry!.historyEntries
            .firstWhere((entry) =>
                entry.trainingExerciseId == trainingExercise.id &&
                entry.setNumber == index);
        final locations = historyState.selectedTrainingEntry!.locations
            .where((location) =>
                location.trainingExerciseId == trainingExercise.id &&
                location.setNumber == index)
            .toList();
        return RunExercise(
          historyEntry: entry,
          runLocations: locations,
          trainingExercise: trainingExercise,
        );
      },
    );
  }
}

class RunExercise extends StatefulWidget {
  final HistoryEntry historyEntry;
  final List<RunLocation> runLocations;
  final TrainingExercise trainingExercise;

  const RunExercise({
    super.key,
    required this.historyEntry,
    required this.runLocations,
    required this.trainingExercise,
  });

  @override
  State<RunExercise> createState() => _RunExerciseState();
}

class _RunExerciseState extends State<RunExercise> {
  int selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    final drop = RunLocation.calculateTotalDrop(widget.runLocations);
    final name = widget.trainingExercise.sets! > 1
        ? '${widget.historyEntry.exerciseNameAtTime} (${widget.historyEntry.setNumber! + 1})'
        : widget.historyEntry.exerciseNameAtTime;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.timberwolf),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.trainingExercise.specialInstructions != null)
            Text('${widget.trainingExercise.specialInstructions}'),
          const SizedBox(height: 10),
          const Divider(color: AppColors.timberwolf),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_distance')),
              Text('${widget.historyEntry.distance}m')
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_duration')),
              Text(formatDurationToHoursMinutesSeconds(
                  widget.historyEntry.duration ?? 0))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_pace')),
              Text(formatDurationToHoursMinutesSeconds(
                  widget.historyEntry.pace ?? 0))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(tr('history_page_drop')), Text('${drop}m')],
          ),
          const SizedBox(height: 20),
          ToggleSwitch(
            minWidth: (MediaQuery.of(context).size.width - 60) / 3,
            inactiveBgColor: AppColors.whiteSmoke,
            activeBgColor: const [AppColors.licorice],
            activeFgColor: AppColors.white,
            inactiveFgColor: AppColors.licorice,
            cornerRadius: 10,
            radiusStyle: true,
            initialLabelIndex: selectedOption,
            totalSwitches: 3,
            labels: [
              tr('history_page_trace'),
              tr('history_page_pace'),
              tr('history_page_drop')
            ],
            onToggle: (index) {
              setState(() {
                selectedOption = index!;
              });
            },
          ),
          const SizedBox(height: 10),
          if (selectedOption == 0) RunMapView(locations: widget.runLocations),
          if (selectedOption == 1) PaceChart(locations: widget.runLocations),
          if (selectedOption == 2)
            AltitudeChart(locations: widget.runLocations),
        ],
      ),
    );
  }
}

class ExerciseSetForm extends StatefulWidget {
  final TrainingExercise trainingExercise;
  final Exercise? matchingExercise;
  final TrainingHistoryLoaded historyState;
  final Training training;

  const ExerciseSetForm({
    required this.trainingExercise,
    required this.matchingExercise,
    required this.historyState,
    required this.training,
    super.key,
  });

  @override
  State<ExerciseSetForm> createState() => _ExerciseSetFormState();
}

class _ExerciseSetFormState extends State<ExerciseSetForm> {
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;
  late List<TextEditingController> durationMinutesControllers;
  late List<TextEditingController> durationSecondsControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final setsCount = widget.trainingExercise.sets ?? 0;

    weightControllers = List.generate(
      setsCount,
      (index) {
        final matchingEntry = widget
            .historyState.selectedTrainingEntry!.historyEntries
            .firstWhereOrNull((entry) =>
                entry.trainingExerciseId == widget.trainingExercise.id &&
                entry.setNumber == index);
        return TextEditingController(
            text: (matchingEntry?.weight ?? 0).toString());
      },
    );

    repsControllers = List.generate(
      setsCount,
      (index) {
        final matchingEntry = widget
            .historyState.selectedTrainingEntry!.historyEntries
            .firstWhereOrNull((entry) =>
                entry.trainingExerciseId == widget.trainingExercise.id &&
                entry.setNumber == index);
        return TextEditingController(
            text: (matchingEntry?.reps ?? 0).toString());
      },
    );

    durationMinutesControllers = List.generate(
      setsCount,
      (index) {
        final matchingEntry = widget
            .historyState.selectedTrainingEntry!.historyEntries
            .firstWhereOrNull((entry) =>
                entry.trainingExerciseId == widget.trainingExercise.id &&
                entry.setNumber == index);
        return TextEditingController(
          text: (matchingEntry?.duration != null
              ? (matchingEntry!.duration! % 3600 ~/ 60).toString()
              : '0'),
        );
      },
    );

    durationSecondsControllers = List.generate(
      setsCount,
      (index) {
        final matchingEntry = widget
            .historyState.selectedTrainingEntry!.historyEntries
            .firstWhereOrNull((entry) =>
                entry.trainingExerciseId == widget.trainingExercise.id &&
                entry.setNumber == index);
        return TextEditingController(
          text: (matchingEntry?.duration != null
              ? (matchingEntry!.duration! % 60).toString()
              : '0'),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in weightControllers) {
      controller.dispose();
    }
    for (var controller in repsControllers) {
      controller.dispose();
    }
    for (var controller in durationMinutesControllers) {
      controller.dispose();
    }
    for (var controller in durationSecondsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateHistoryEntry(int index, {int? weight, int? reps, int? duration}) {
    final historyEntry = widget
        .historyState.selectedTrainingEntry!.historyEntries
        .firstWhereOrNull((entry) =>
            entry.trainingExerciseId == widget.trainingExercise.id &&
            entry.setNumber == index);

    DateTime entryDate = DateTime.now();

    if (widget.historyState.selectedTrainingEntry!.historyEntries.isNotEmpty) {
      entryDate = widget.historyState.selectedTrainingEntry!.historyEntries
          .map((e) => e.date)
          .reduce((value, element) => value.isAfter(element) ? value : element);
    }
    int? cals = historyEntry?.calories;
    cals = widget.trainingExercise.isSetsInReps!
        ? getCalories(
            intensity: widget.trainingExercise.intensity!,
            reps: reps ?? historyEntry?.reps)
        : getCalories(
            intensity: widget.trainingExercise.intensity!,
            duration: duration ?? historyEntry?.duration);

    context.read<TrainingHistoryBloc>().add(
          CreateOrUpdateHistoryEntry(
            historyEntry: HistoryEntry(
              id: historyEntry?.id,
              trainingId: historyEntry?.trainingId ??
                  widget.trainingExercise.trainingId!,
              trainingType: historyEntry?.trainingType ?? widget.training.type,
              trainingExerciseId: historyEntry?.trainingExerciseId ??
                  widget.trainingExercise.id!,
              trainingExerciseType: historyEntry?.trainingExerciseType ??
                  widget.trainingExercise.trainingExerciseType!,
              date: historyEntry?.date ?? entryDate,
              trainingNameAtTime:
                  historyEntry?.trainingNameAtTime ?? widget.training.name,
              exerciseNameAtTime: historyEntry?.exerciseNameAtTime ??
                  findExerciseName(widget.trainingExercise),
              intensity:
                  historyEntry?.intensity ?? widget.trainingExercise.intensity!,
              weight: weight ?? historyEntry?.weight,
              reps: reps ?? historyEntry?.reps,
              duration: duration ?? historyEntry?.duration,
              setNumber: historyEntry?.setNumber ?? index,
              // TODO : vérifier le multiset
              multisetSetNumber: historyEntry?.multisetSetNumber,
              distance: null,
              pace: null,
              calories: cals,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.timberwolf),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          _buildExerciseHeader(
            widget.matchingExercise,
            widget.trainingExercise,
            context,
            widget.trainingExercise.isSetsInReps!,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.timberwolf),
          const SizedBox(height: 10),
          _buildHeaderRow(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.trainingExercise.sets ?? 0,
            itemBuilder: (context, index) => _buildSetRow(index),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(Exercise? exercise, TrainingExercise tExercise,
      BuildContext context, bool isSetsInReps) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise != null &&
            exercise.imagePath != null &&
            exercise.imagePath!.isNotEmpty)
          Column(
            children: [
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
        if (exercise != null &&
            exercise.imagePath != null &&
            exercise.imagePath!.isNotEmpty)
          const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise != null
                    ? exercise.name
                    : tr('global_exercise_unknown'),
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSetsInReps)
                Text('${tExercise.minReps ?? 0}-${tExercise.maxReps ?? 0} reps')
              else
                Text('${tExercise.duration} ${tr('active_training_seconds')}'),
              if (tExercise.specialInstructions != null)
                Text('${tExercise.specialInstructions}'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSetRow(int index) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${index + 1}',
            style: const TextStyle(color: AppColors.taupeGray),
          ),
          Row(
            children: [
              SizedBox(
                width: 50,
                child:
                    SmallTextFieldWidget(controller: weightControllers[index]),
              ),
              const SizedBox(width: 10),
              if (widget.trainingExercise.isSetsInReps!)
                SizedBox(
                  width: 50,
                  child:
                      SmallTextFieldWidget(controller: repsControllers[index]),
                )
              else
                Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: SmallTextFieldWidget(
                          controller: durationMinutesControllers[index]),
                    ),
                    const SizedBox(
                      width: 10,
                      child: Text(
                        ':',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: SmallTextFieldWidget(
                          controller: durationSecondsControllers[index]),
                    ),
                  ],
                ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  final duration = ((int.tryParse(
                                  durationMinutesControllers[index].text) ??
                              0) *
                          60) +
                      ((int.tryParse(durationSecondsControllers[index].text) ??
                          0));
                  _updateHistoryEntry(
                    index,
                    weight: int.tryParse(weightControllers[index].text),
                    duration: duration,
                    reps: int.tryParse(repsControllers[index].text),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.platinum),
                  child: const Center(
                    child: Icon(
                      LucideIcons.save,
                      size: 20,
                      color: AppColors.frenchGray,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Sets', style: TextStyle(color: AppColors.taupeGray)),
        Row(
          children: [
            const SizedBox(
              width: 50,
              child: Center(
                child: Text(
                  'Kg',
                  style: TextStyle(color: AppColors.taupeGray),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (widget.trainingExercise.isSetsInReps!)
              const SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    'Reps',
                    style: TextStyle(color: AppColors.taupeGray),
                  ),
                ),
              )
            else
              const SizedBox(
                width: 110,
                child: Center(
                  child: Text(
                    'Duration',
                    style: TextStyle(color: AppColors.taupeGray),
                  ),
                ),
              ),
            const SizedBox(width: 46)
          ],
        ),
      ],
    );
  }
}
