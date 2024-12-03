import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/bloc/active_training_bloc.dart';

String _formatTime(int seconds, {bool includeHours = true}) {
  final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');

  return includeHours ? '$hours:$minutes:$secs' : '$minutes:$secs';
}

class DurationTimerWidget extends StatefulWidget {
  final String timerId;
  const DurationTimerWidget({super.key, required this.timerId});

  @override
  State<DurationTimerWidget> createState() => DurationTimerWidgetState();
}

class DurationTimerWidgetState extends State<DurationTimerWidget> {
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
              final timerValue = state.timers[widget.timerId] ?? 0;
              return Text(
                _formatTime(timerValue),
                style: const TextStyle(color: AppColors.lightBlack),
              );
            }
            return const Text(
              '00:00:00',
              style: TextStyle(color: AppColors.lightBlack),
            );
          }),
        ],
      ),
    );
  }
}
