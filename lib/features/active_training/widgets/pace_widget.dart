import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/active_training_bloc.dart';

class PaceWidget extends StatelessWidget {
  final String timerId;
  const PaceWidget({super.key, required this.timerId});

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
              final distance = state.timersStateList
                      .firstWhereOrNull((el) => el.timerId == timerId)
                      ?.distance ??
                  0;
              final timerValue = state.timersStateList
                      .firstWhereOrNull((el) => el.timerId == timerId)
                      ?.timerValue ??
                  0;
              double pace = 0;
              int paceMinutes = 0;
              int paceSeconds = 0;
              if (timerValue != 0 && distance != 0) {
                pace = timerValue / 60 / (distance / 1000);
                paceMinutes = pace.floor();
                paceSeconds = ((pace - paceMinutes) * 60).round();
              }
              return Text(
                  "$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}");
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
