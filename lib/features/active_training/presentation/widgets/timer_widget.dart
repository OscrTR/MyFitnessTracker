import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';
import 'package:pausable_timer/pausable_timer.dart';

class TimerWidget extends StatefulWidget {
  final int? initialSecondaryTimerDuration;

  const TimerWidget({super.key, this.initialSecondaryTimerDuration});

  @override
  State<TimerWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  late final PausableTimer globalTimer;
  late PausableTimer? secondaryTimer;
  int globalTimerValue = 0;
  int secondaryTimerValue = 0;

  @override
  void initState() {
    super.initState();
    globalTimer = PausableTimer.periodic(
      const Duration(seconds: 1),
      () {
        setState(() {
          globalTimerValue++;
        });
      },
    )..start();

    _initializeSecondaryTimer(widget.initialSecondaryTimerDuration ?? 0);
  }

  void _initializeSecondaryTimer(int duration) {
    secondaryTimerValue = duration;
    secondaryTimer = PausableTimer.periodic(
      const Duration(seconds: 1),
      () {
        if (secondaryTimerValue > 0) {
          setState(() {
            secondaryTimerValue--;
          });
        } else {
          secondaryTimer?.cancel();
        }
      },
    );
  }

  void startSecondaryTimer(int duration) {
    if (secondaryTimer != null) {
      secondaryTimer?.cancel();
    }
    _initializeSecondaryTimer(duration);
    globalTimer.start();
    secondaryTimer?.start();
  }

  void resetSecondaryTimer() {
    secondaryTimer?.cancel();
    setState(() {
      secondaryTimerValue = 0;
    });
  }

  @override
  void dispose() {
    globalTimer.cancel();
    secondaryTimer?.cancel();
    super.dispose();
  }

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
            Row(
              children: [
                // Timer Display
                Container(
                  padding: const EdgeInsets.only(top: 3),
                  width: secondaryTimer != null && secondaryTimerValue > 0
                      ? 70
                      : 140,
                  child: Text(
                    _formatTime(globalTimerValue),
                    style: secondaryTimer != null && secondaryTimerValue > 0
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(width: 10),
                if (secondaryTimer != null && secondaryTimerValue > 0)
                  SizedBox(
                    child: Text(
                      _formatTime(secondaryTimerValue, includeHours: false),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () {
                if (globalTimer.isPaused) {
                  globalTimer.start();
                  secondaryTimer?.start();
                } else {
                  globalTimer.pause();
                  secondaryTimer?.pause();
                }
                setState(() {}); // Reflect timer status change
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(999)),
                child: Icon(
                  globalTimer.isPaused ? Icons.play_arrow : Icons.pause,
                  color: AppColors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
