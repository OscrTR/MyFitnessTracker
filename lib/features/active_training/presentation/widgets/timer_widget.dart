import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import '../../../../injection_container.dart';
import '../../../../notification_service.dart';
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

  int _counter = 0;
  double _distance = 0.0;
  Timer? _timer;

  LocationData? _lastLocation;
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

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
    _startTimer();
    _initLocationStream();
    _listenToTimerStream();
    super.initState();
  }

  int? id;

  Future<void> _initLocationStream() async {
    _location.enableBackgroundMode(enable: true);
    final notifData = await _location.changeNotificationOptions(
        title: 'Run metrics', subtitle: 'Geolocation detection');
    print(notifData?.notificationId);
    id = notifData?.notificationId;
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData currentLocation) {
      _updateLocationAndDistance(currentLocation);
    });
  }

  void _updateLocationAndDistance(LocationData currentLocation) {
    if (_lastLocation != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _lastLocation!.latitude!,
        _lastLocation!.longitude!,
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
      setState(() {
        _distance += distanceInMeters;
      });
    }
    _lastLocation = currentLocation;
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
      timerStreamController.add(_counter);
      _showNotification();
    });
  }

  void _showNotification() async {
    print(id);
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            onlyAlertOnce: true,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await sl<FlutterLocalNotificationsPlugin>().show(
        id!,
        'Timer Update',
        'Timer: $_counter seconds\nDistance : ${_distance.floor()}m',
        platformChannelSpecifics,
        payload: 'item x');
  }

  void _listenToTimerStream() {
    timerStreamController.stream.listen((int counter) {
      // Mettez à jour l'interface utilisateur ou effectuez d'autres actions ici
      print('Timer Stream Event: $counter, distance : ${_distance.floor()}m');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    timerStreamController.close();
    super.dispose();
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
                // sl<FlutterBackgroundService>().invoke('pauseTracking', {
                //   'timerId': (context.read<ActiveTrainingBloc>().state
                //           as ActiveTrainingLoaded)
                //       .lastStartedTimerId
                // });
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
