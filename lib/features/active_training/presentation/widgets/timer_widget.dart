import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/active_training_bloc.dart';

import '../../../../app_colors.dart';

class TimerWidget extends StatefulWidget {
  final int? initialSecondaryTimerDuration;
  final ValueChanged<int>? onSecondaryTimerTick;

  const TimerWidget(
      {super.key,
      this.initialSecondaryTimerDuration,
      this.onSecondaryTimerTick});

  @override
  State<TimerWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  String _formatTime(int seconds, {bool includeHours = true}) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');

    if (includeHours) {
      return '$hours:$minutes:$secs';
    } else {
      return '$minutes:$secs';
    }
  }

  @override
  void initState() {
    context.read<ActiveTrainingBloc>().add(const CreateTimer(
            timerState: TimerState(
          timerId: 'primaryTimer',
          isActive: true,
          isStarted: true,
          isRunTimer: false,
          timerValue: 0,
          isCountDown: false,
          isAutostart: false,
        )));
    sl<FlutterBackgroundService>()
        .invoke('startTracking', {'timerId': 'primaryTimer'});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
                builder: (context, state) {
              if (state is ActiveTrainingLoaded) {
                final primaryTimerValue = state.timersStateList
                        .firstWhereOrNull((e) => e.timerId == 'primaryTimer')
                        ?.timerValue ??
                    0;
                final secondaryTimerValue = state.timersStateList
                        .firstWhereOrNull((e) =>
                            e.timerId != 'primaryTimer' &&
                            e.timerId == state.lastStartedTimerId)
                        ?.timerValue ??
                    0;
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 3),
                      width: 70,
                      child: Text(_formatTime(primaryTimerValue),
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatTime(secondaryTimerValue),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),
            GestureDetector(
              onTap: () {
                sl<FlutterBackgroundService>().invoke('pauseTracking', {
                  'timerId': (context.read<ActiveTrainingBloc>().state
                          as ActiveTrainingLoaded)
                      .lastStartedTimerId
                });
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(999)),
                child: BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
                    builder: (context, state) {
                  if (state is ActiveTrainingLoaded) {
                    return Icon(
                      state.timersStateList.any((el) => el.isActive)
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: AppColors.white,
                    );
                  } else {
                    return const Icon(
                      Icons.pause,
                      color: AppColors.white,
                    );
                  }
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
