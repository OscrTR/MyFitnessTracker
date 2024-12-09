import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/bloc/active_training_bloc.dart';

class PaceWidget extends StatefulWidget {
  final String activeRunId;
  const PaceWidget({super.key, required this.activeRunId});

  @override
  State<PaceWidget> createState() => PaceWidgetState();
}

class PaceWidgetState extends State<PaceWidget> {
  int paceMinutes = 0;
  int paceSeconds = 0;
  double pace = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
              builder: (context, state) {
            if (state is ActiveTrainingLoaded) {
              if (state.activeRunTimer == widget.activeRunId &&
                  state.timers['secondaryTimer'] != null &&
                  state.timers['secondaryTimer'] != 0 &&
                  state.distance != 0) {
                pace = state.timers['secondaryTimer']! /
                    60 /
                    (state.distance / 1000);
                paceMinutes = pace.floor();
                paceSeconds = ((pace - paceMinutes) * 60).round();
              }
              return Text(
                "$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}",
                style: const TextStyle(color: AppColors.lightBlack),
              );
            }
            return const Text(
              '00:00',
              style: TextStyle(color: AppColors.lightBlack),
            );
          }),
        ],
      ),
    );
  }
}
