import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/database/object_box.dart';
import '../../../core/widgets/small_text_field_widget.dart';
import '../bloc/training_history_bloc.dart';
import '../widgets/altitude_chart_widget.dart';
import '../widgets/pace_chart_widget.dart';
import '../widgets/run_map_widget.dart';
import '../widgets/save_button_widget.dart';
import '../../training_management/models/training.dart';
import '../../training_management/models/training_exercise.dart';
import 'package:collection/collection.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../helper_functions.dart';
import '../../../injection_container.dart';
import '../../exercise_management/models/exercise.dart';
import '../../training_management/models/multiset.dart';
import '../models/history_entry.dart';
import '../models/history_run_location.dart';

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
          final selectedTrainingEntry = state.selectedTrainingEntry!;

          final trainingVersion = sl<ObjectBox>().getTrainingVersionById(
              selectedTrainingEntry.linkedTrainingVersionId);

          final matchingTraining = trainingVersion!.toTraining();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(context, state, matchingTraining!),
                  const SizedBox(height: 10),
                  _buildMatchingTraining(
                      matchingTraining, state, trainingVersion.id)
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
      Training training, TrainingHistoryLoaded state, int trainingVersionId) {
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

          final exercise = tExercise.exercise.target;

          print(exercise);

          final historyEntries = state.selectedTrainingEntry!.historyEntries
              .where((entry) => entry.linkedTrainingExerciseId == tExercise.id)
              .toList();

          final locations = state.selectedTrainingEntry!.locations
              .where((location) =>
                  location.linkedTrainingExerciseId == tExercise.id)
              .toList();

          return tExercise.type == TrainingExerciseType.run
              ? tExercise.sets > 1
                  ? IntervalExercise(
                      trainingExercise: tExercise,
                      historyEntries: historyEntries,
                      locationsList: locations,
                    )
                  : RunExercise(
                      historyEntries: historyEntries,
                      runLocations: locations,
                      trainingExercise: tExercise,
                    )
              : ExerciseSetForm(
                  trainingExercise: tExercise,
                  exercise: exercise,
                  historyState: state,
                  training: training,
                  multiset: null,
                  historyEntriesList: historyEntries,
                  trainingVersionId: trainingVersionId,
                );
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;

          return multiset.trainingExercises.isNotEmpty
              ? HistoryMultisetWidget(
                  multiset: multiset,
                  historyState: state,
                  training: training,
                  trainingVersionId: trainingVersionId,
                )
              : const SizedBox();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Stack _buildHeader(
      BuildContext context, TrainingHistoryLoaded state, Training training) {
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
                training.name,
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
              context
                  .read<TrainingHistoryBloc>()
                  .add(DeleteHistoryTrainingEvent(
                    trainingId: state.selectedTrainingEntry!.training.id,
                  ));
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
  final List<HistoryEntry> historyEntries;
  final List<RunLocation> locationsList;
  final int? multisetSetIndex;

  const IntervalExercise({
    super.key,
    required this.trainingExercise,
    required this.historyEntries,
    required this.locationsList,
    this.multisetSetIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: trainingExercise.sets,
      itemBuilder: (context, index) {
        final entries = historyEntries
            .where((entry) =>
                entry.linkedTrainingExerciseId == trainingExercise.id &&
                entry.setNumber == index)
            .toList();

        final locations = locationsList
            .where((location) =>
                location.linkedTrainingExerciseId == trainingExercise.id &&
                location.setNumber == index)
            .toList();
        return RunExercise(
          historyEntries: entries,
          runLocations: locations,
          trainingExercise: trainingExercise,
          subtitle:
              '${multisetSetIndex != null ? 'Set ${multisetSetIndex! + 1} - ' : ''} ${tr('history_page_interval')} ${index + 1}',
        );
      },
    );
  }
}

class RunExercise extends StatefulWidget {
  final List<HistoryEntry> historyEntries;
  final List<RunLocation> runLocations;
  final TrainingExercise trainingExercise;
  final String? subtitle;

  const RunExercise({
    super.key,
    required this.historyEntries,
    required this.runLocations,
    required this.trainingExercise,
    this.subtitle,
  });

  @override
  State<RunExercise> createState() => _RunExerciseState();
}

class _RunExerciseState extends State<RunExercise> {
  int selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    final drop = RunLocation.calculateTotalDrop(widget.runLocations);
    final entry = widget.historyEntries[0];
    final name = findExerciseName(widget.trainingExercise);

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
          if (widget.subtitle != null) Text(widget.subtitle!),
          if (widget.trainingExercise.specialInstructions != null)
            Text('${widget.trainingExercise.specialInstructions}'),
          const SizedBox(height: 10),
          const Divider(color: AppColors.timberwolf),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_distance')),
              Text('${entry.distance}m')
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_duration')),
              Text(formatDurationToHoursMinutesSeconds(entry.duration ?? 0))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('history_page_pace')),
              Text(formatDurationToHoursMinutesSeconds(entry.pace ?? 0))
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
  final Multiset? multiset;
  final TrainingExercise trainingExercise;
  final Exercise? exercise;
  final TrainingHistoryLoaded historyState;
  final Training training;
  final int trainingVersionId;
  final List<HistoryEntry> historyEntriesList;

  const ExerciseSetForm({
    required this.multiset,
    required this.trainingExercise,
    required this.exercise,
    required this.historyState,
    required this.training,
    required this.trainingVersionId,
    required this.historyEntriesList,
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

  late final bool isSetInReps = widget.trainingExercise.isSetsInReps;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final setsCount = widget.multiset?.sets ?? widget.trainingExercise.sets;

    List<TextEditingController> createControllers(
      String Function(dynamic entry) textExtractor,
    ) {
      return List.generate(
        setsCount,
        (index) {
          final matchingEntry = widget
              .historyState.selectedTrainingEntry!.historyEntries
              .firstWhereOrNull(
            (entry) =>
                entry.linkedTrainingExerciseId == widget.trainingExercise.id &&
                entry.setNumber == index,
          );

          return TextEditingController(text: textExtractor(matchingEntry));
        },
      );
    }

    weightControllers =
        createControllers((entry) => (entry?.weight ?? 0).toString());

    repsControllers =
        createControllers((entry) => (entry?.reps ?? 0).toString());

    durationMinutesControllers = createControllers((entry) =>
        (entry?.duration != null
            ? (entry!.duration! % 3600 ~/ 60).toString()
            : '0'));

    durationSecondsControllers = createControllers((entry) =>
        (entry?.duration != null ? (entry!.duration! % 60).toString() : '0'));
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

  void _updateHistoryEntry({
    required int setNumber,
    int? weight,
    int? reps,
    int? duration,
  }) {
    final historyEntry = widget
        .historyState.selectedTrainingEntry!.historyEntries
        .firstWhereOrNull((entry) =>
            entry.linkedTrainingExerciseId == widget.trainingExercise.id &&
            entry.setNumber == setNumber);

    DateTime entryDate = DateTime.now();

    if (widget.historyState.selectedTrainingEntry!.historyEntries.isNotEmpty) {
      entryDate = widget.historyState.selectedTrainingEntry!.historyEntries
          .map((e) => e.date)
          .reduce((value, element) => value.isAfter(element) ? value : element);
    }
    int? cals = historyEntry?.calories;
    cals = isSetInReps
        ? getCalories(
            intensity: widget.trainingExercise.intensity,
            reps: reps ?? historyEntry?.reps)
        : getCalories(
            intensity: widget.trainingExercise.intensity,
            duration: duration ?? historyEntry?.duration);

    context.read<TrainingHistoryBloc>().add(
          CreateOrUpdateHistoryEntry(
            historyEntry: HistoryEntry(
              id: historyEntry?.id ?? 0,
              linkedTrainingId: historyEntry?.linkedTrainingId ??
                  widget.trainingExercise.linkedTrainingId!,
              linkedTrainingExerciseId:
                  historyEntry?.linkedTrainingExerciseId ??
                      widget.trainingExercise.id,
              date: historyEntry?.date ?? entryDate,
              weight: weight ?? historyEntry?.weight,
              reps: reps ?? historyEntry?.reps,
              duration: duration ?? historyEntry?.duration,
              setNumber: historyEntry?.setNumber ?? setNumber,
              intervalNumber: null,
              distance: null,
              pace: null,
              calories: cals,
              linkedTrainingVersionId: historyEntry?.linkedTrainingVersionId ??
                  widget.trainingVersionId,
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
            widget.exercise,
            widget.trainingExercise,
            context,
            isSetInReps,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.timberwolf),
          const SizedBox(height: 10),
          _buildHeaderRow(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.multiset?.sets ?? widget.trainingExercise.sets,
            itemBuilder: (context, index) {
              return _buildSetRow(index, widget.multiset != null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(Exercise? exercise, TrainingExercise? tExercise,
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
              if (isSetsInReps && tExercise != null)
                Text('${tExercise.minReps ?? 0}-${tExercise.maxReps ?? 0} reps')
              else if (tExercise != null)
                Text('${tExercise.duration} ${tr('active_training_seconds')}'),
              if (tExercise != null && tExercise.specialInstructions != null)
                Text('${tExercise.specialInstructions}'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSetRow(int index, bool isMultiset) {
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
              if (isSetInReps)
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
              SaveButton(onTapCallback: () {
                final duration = ((int.tryParse(
                                durationMinutesControllers[index].text) ??
                            0) *
                        60) +
                    ((int.tryParse(durationSecondsControllers[index].text) ??
                        0));
                _updateHistoryEntry(
                  setNumber: isMultiset ? 1 : index,
                  weight: int.tryParse(weightControllers[index].text),
                  duration: duration,
                  reps: int.tryParse(repsControllers[index].text),
                );
              }),
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
            if (isSetInReps)
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

class HistoryMultisetWidget extends StatelessWidget {
  final Multiset multiset;
  final TrainingHistoryLoaded historyState;
  final Training training;
  final int trainingVersionId;

  const HistoryMultisetWidget({
    super.key,
    required this.multiset,
    required this.historyState,
    required this.training,
    required this.trainingVersionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.timberwolf),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('global_multiset'),
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text('${multiset.sets} sets'),
          if (multiset.trainingExercises.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: multiset.trainingExercises.length,
              itemBuilder: (context, multisetExerciseindex) {
                final tExercise =
                    multiset.trainingExercises[multisetExerciseindex];

                final exercise = tExercise.exercise.target;

                final tExerciseEntries = historyState
                    .selectedTrainingEntry!.historyEntries
                    .where((h) => h.linkedTrainingExerciseId == tExercise.id)
                    .toList();

                if (tExercise.type != TrainingExerciseType.run) {
                  return ExerciseSetForm(
                    trainingExercise: tExercise,
                    exercise: exercise,
                    historyState: historyState,
                    training: training,
                    multiset: multiset,
                    historyEntriesList: tExerciseEntries,
                    trainingVersionId: trainingVersionId,
                  );
                } else {
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: multiset.sets,
                      itemBuilder: (context, multisetSetindex) {
                        final locations = historyState
                            .selectedTrainingEntry!.locations
                            .where((location) =>
                                location.linkedTrainingExerciseId ==
                                    tExercise.id &&
                                location.setNumber == multisetSetindex)
                            .toList();

                        final intervalEntries = historyState
                            .selectedTrainingEntry!.historyEntries
                            .where((entry) =>
                                entry.linkedTrainingExerciseId ==
                                    tExercise.id &&
                                entry.setNumber == multisetSetindex)
                            .toList();

                        return tExercise.sets > 1
                            ? IntervalExercise(
                                trainingExercise: tExercise,
                                multisetSetIndex: multisetSetindex,
                                historyEntries: intervalEntries,
                                locationsList: locations,
                              )
                            : RunExercise(
                                historyEntries: tExerciseEntries,
                                runLocations: locations,
                                trainingExercise: tExercise,
                                subtitle: '(set ${multisetSetindex + 1})',
                              );
                      });
                }
              },
            )
        ],
      ),
    );
  }
}
