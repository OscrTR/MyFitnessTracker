import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../helper_functions.dart';
import '../bloc/active_training_bloc.dart';

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
                formatDurationToHoursMinutesSeconds(timerValue),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
