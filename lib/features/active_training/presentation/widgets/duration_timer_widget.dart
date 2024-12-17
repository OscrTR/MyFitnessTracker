import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/active_training_bloc.dart';

import '../../../../app_colors.dart';

String _formatTime(int seconds, {bool includeHours = true}) {
  final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');

  return includeHours ? '$hours:$minutes:$secs' : '$minutes:$secs';
}

class DurationTimerWidget extends StatelessWidget {
  final String timerId;
  const DurationTimerWidget({super.key, required this.timerId});

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
              final timerValue = state.timersStateList
                      .firstWhereOrNull((el) => el.timerId == timerId)
                      ?.timerValue ??
                  0;
              return Text(
                _formatTime(timerValue),
                style: const TextStyle(color: AppColors.lightBlack),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
