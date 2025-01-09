import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/training_history_bloc.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<TrainingHistoryBloc, TrainingHistoryState>(
              builder: (context, state) {
            if (state is TrainingHistoryLoaded) {
              final historyEntries = state.historyEntries;
              if (historyEntries.isNotEmpty) {
                return ListView.builder(
                    itemCount: historyEntries.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Id:${historyEntries[index].id}, trainingId:${historyEntries[index].trainingId}, tExerciseId:${historyEntries[index].trainingExerciseId}'),
                              Text('${historyEntries[index].date}'),
                              Text('Reps ${historyEntries[index].reps}'),
                              Text(
                                  'Duration ${historyEntries[index].duration}'),
                              Text(
                                  'Distance ${historyEntries[index].distance}'),
                              Text('Pace ${historyEntries[index].pace}'),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<TrainingHistoryBloc>().add(
                                  DeleteHistoryEntryEvent(
                                      id: historyEntries[index].id!));
                            },
                            child: Text('Delete'),
                          )
                        ],
                      );
                    });
              } else {
                return Text('No training registered yet');
              }
            }
            return const SizedBox();
          })),
    );
  }
}
