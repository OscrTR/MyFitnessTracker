import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../foreground_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../helper_functions.dart';
import '../../training_history/models/history_entry.dart';
import '../../training_history/bloc/training_history_bloc.dart';
import '../bloc/active_training_bloc.dart';
import '../widgets/error_state_widget.dart';
import 'package:uuid/uuid.dart';
import '../../../injection_container.dart';
import '../widgets/active_multiset_widget.dart';
import '../widgets/active_run_widget.dart';
import '../widgets/timer_widget.dart';

import '../../training_management/models/exercise.dart';
import '../../training_management/bloc/training_management_bloc.dart';

import '../../training_management/models/multiset.dart';
import '../widgets/active_exercise_widget.dart';

const uuid = Uuid();

class ActiveTrainingPage extends StatefulWidget {
  const ActiveTrainingPage({super.key});

  @override
  State<ActiveTrainingPage> createState() => _ActiveTrainingPageState();
}

class _ActiveTrainingPageState extends State<ActiveTrainingPage>
    with WidgetsBindingObserver {
  bool isLocationPermissionGrantedAlways = false;
  bool isLocationPermissionGrantedInUse = false;
  bool isLocationPermissionGrantedDeniedForever = false;
  bool isLocationEnabled = false;
  bool isNotificationAuthorized = false;
  String? lastStartedTimerId;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _checkLocationPermission();
    _checkLocationStatus();
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
      _checkLocationStatus();
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('active_training_back_title')),
        content: Text(tr('active_training_back_content')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('global_no')),
          ),
          TextButton(
            onPressed: () {
              context.read<ActiveTrainingBloc>().add(ClearTimers());
              Navigator.of(context).pop(true);
              GoRouter.of(context).go('/home');
            },
            child: Text(tr('global_yes')),
          ),
        ],
      ),
    );
    return true;
  }

  Future<void> _checkNotificationPermission() async {
    final authorized = await sl<FlutterLocalNotificationsPlugin>()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .areNotificationsEnabled();
    setState(() {
      isNotificationAuthorized = authorized ?? false;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final authorized = await sl<FlutterLocalNotificationsPlugin>()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    setState(() {
      isNotificationAuthorized = authorized ?? false;
    });
  }

  Future<void> _checkLocationPermission() async {
    final alwaysStatus = await Permission.locationAlways.status;
    final inUseStatus = await Permission.locationWhenInUse.status;
    setState(() {
      isLocationPermissionGrantedAlways = alwaysStatus.isGranted;
      isLocationPermissionGrantedInUse = inUseStatus.isGranted;
      if (alwaysStatus.isPermanentlyDenied) {
        isLocationPermissionGrantedDeniedForever = true;
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    if (isLocationPermissionGrantedDeniedForever) {
      await openAppSettings();
    } else if (!isLocationPermissionGrantedInUse) {
      final inUseStatus = await Permission.locationWhenInUse.request();
      setState(() {
        isLocationPermissionGrantedInUse = inUseStatus.isGranted;
      });
    } else if (!isLocationPermissionGrantedAlways) {
      final alwaysStatus = await Permission.locationAlways.request();
      setState(() {
        isLocationPermissionGrantedAlways = alwaysStatus.isGranted;
      });
    }
  }

  Future<void> _checkLocationStatus() async {
    bool serviceEnabled = await FlLocation.isLocationServicesEnabled;
    setState(() {
      isLocationEnabled = serviceEnabled;
    });
  }

  Future<void> _requestLocationEnabled() async {
    bool serviceEnabled = await FlLocation.isLocationServicesEnabled;
    if (!serviceEnabled) {
      await sl<ForegroundService>().requestService();
    }

    setState(() {
      isLocationEnabled = serviceEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                      builder: (context, state) {
                    if (state is TrainingManagementLoaded &&
                        state.activeTraining != null) {
                      bool isVerified = false;

                      bool hasRunExercise = state.activeTraining!.exercises
                          .any((e) => e.exerciseType == ExerciseType.run);

                      if (hasRunExercise) {
                        if (isLocationPermissionGrantedAlways &&
                            isLocationEnabled &&
                            isNotificationAuthorized) {
                          isVerified = true;
                        } else {
                          return _buildRunPermissions(context);
                        }
                      } else if (!isNotificationAuthorized) {
                        return _buildNotificationPermission(context);
                      } else {
                        isVerified = true;
                      }

                      if (isVerified) {
                        final exercisesAndMultisetsList = [
                          ...state.activeTraining!.exercises
                              .where((e) => e.multisetId == null)
                              .map((e) => {'type': 'exercise', 'data': e}),
                          ...state.activeTraining!.multisets
                              .map((m) => {'type': 'multiset', 'data': m}),
                        ];
                        exercisesAndMultisetsList.sort((a, b) {
                          final aPosition =
                              (a['data'] as dynamic).position ?? 0;
                          final bPosition =
                              (b['data'] as dynamic).position ?? 0;
                          return aPosition.compareTo(bPosition);
                        });

                        return _buildPageContent(
                            state,
                            context,
                            exercisesAndMultisetsList,
                            exercisesAndMultisetsList);
                      } else {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: const Center(
                                child: CircularProgressIndicator()));
                      }
                    }
                    return const ErrorStateWidget();
                  })
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child:
                  BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                      builder: (context, state) {
                if (state is TrainingManagementLoaded &&
                    state.activeTraining != null) {
                  bool isVerified = false;

                  bool hasRunExercise = state.activeTraining!.exercises
                      .any((e) => e.exerciseType == ExerciseType.run);

                  if (hasRunExercise) {
                    if (isLocationPermissionGrantedAlways &&
                        isLocationEnabled &&
                        isNotificationAuthorized) {
                      isVerified = true;
                    }
                  } else if (isNotificationAuthorized) {
                    isVerified = true;
                  }

                  if (isVerified) {
                    return const TimerWidget();
                  }
                }
                return const SizedBox();
              }),
            )
          ],
        ),
      ),
    );
  }

  Column _buildPageContent(
      TrainingManagementLoaded state,
      BuildContext context,
      List<Map<String, dynamic>> sortedItems,
      List<Map<String, Object>> exercisesAndMultisetsList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(state, context),
              _buildTrainingItemList(
                  sortedItems, context, exercisesAndMultisetsList),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  final activeState =
                      sl<ActiveTrainingBloc>().state as ActiveTrainingLoaded;
                  final currentTimerState = activeState.timersStateList
                      .firstWhere((timer) =>
                          timer.timerId == activeState.lastStartedTimerId);

                  final registeredId =
                      (sl<TrainingHistoryBloc>().state as TrainingHistoryLoaded)
                          .historyEntries
                          .firstWhereOrNull((h) =>
                              h.exerciseId == currentTimerState.exerciseId &&
                              h.setNumber == currentTimerState.setNumber &&
                              h.trainingId == currentTimerState.trainingId)
                          ?.id;

                  int cals = 0;

                  final trainingManagementState = (sl<TrainingManagementBloc>()
                      .state as TrainingManagementLoaded);

                  final listOfTExercises =
                      trainingManagementState.activeTraining!.exercises;

                  final matchingTExercise = listOfTExercises.firstWhere(
                      (exercise) =>
                          exercise.id == currentTimerState.exerciseId);

                  final duration = currentTimerState.isCountDown
                      ? currentTimerState.countDownValue -
                          currentTimerState.timerValue
                      : currentTimerState.timerValue;

                  cals = getCalories(
                      intensity: matchingTExercise.intensity,
                      duration: duration);

                  if (currentTimerState.timerId != 'primaryTimer' &&
                      currentTimerState.isActive &&
                      !currentTimerState.timerId.contains('rest')) {
                    sl<TrainingHistoryBloc>().add(
                      CreateOrUpdateHistoryEntry(
                        historyEntry: HistoryEntry(
                          id: registeredId ?? 0,
                          trainingId: currentTimerState.trainingId,
                          exerciseId: currentTimerState.exerciseId,
                          setNumber: currentTimerState.setNumber,
                          date: DateTime.now(),
                          duration: duration,
                          distance: currentTimerState.distance.toInt(),
                          pace: currentTimerState.pace.toInt(),
                          calories: cals,
                          intervalNumber: currentTimerState.intervalNumber,
                          trainingVersionId:
                              currentTimerState.trainingVersionId,
                          reps: 0,
                          weight: 0,
                        ),
                      ),
                    );
                  }

                  GoRouter.of(context).go('/home');
                  context.read<ActiveTrainingBloc>().add(ClearTimers());
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        color: AppColors.licorice,
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      context.tr('active_training_end'),
                      style: const TextStyle(color: AppColors.white),
                      textAlign: TextAlign.center,
                    )),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ],
    );
  }

  SizedBox _buildNotificationPermission(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tr('active_training_notifications')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _requestNotificationPermission();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: isNotificationAuthorized
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    isNotificationAuthorized
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: isNotificationAuthorized
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _buildRunPermissions(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tr('active_training_notifications')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _requestNotificationPermission();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: isNotificationAuthorized
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    isNotificationAuthorized
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: isNotificationAuthorized
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
            const SizedBox(height: 30),
            Text(tr('active_training_location')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _requestLocationPermission();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: isLocationPermissionGrantedAlways
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    isLocationPermissionGrantedAlways
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: isLocationPermissionGrantedAlways
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
            const SizedBox(height: 30),
            Text(tr('active_training_location_enabled')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _requestLocationEnabled();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: isLocationEnabled
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    isLocationEnabled
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: isLocationEnabled
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TrainingManagementLoaded state, BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(tr('active_training_back_title')),
                  content: Text(tr('active_training_back_content')),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(tr('global_no')),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ActiveTrainingBloc>().add(ClearTimers());
                        Navigator.of(context).pop(true);
                        GoRouter.of(context).go('/home');
                      },
                      child: Text(tr('global_yes')),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(
              LucideIcons.chevronLeft,
              color: AppColors.licorice,
            ),
          ),
        ),
        Center(
          child: Text(
            state.activeTraining!.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingItemList(
      List<Map<String, dynamic>> items,
      BuildContext context,
      List<Map<String, Object>> exercisesAndMultisetsList) {
    final lastTrainingVersionId =
        (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
            .activeTrainingMostRecentVersionId!;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'exercise') {
          final exercise = item['data'] as Exercise;
          final isLast = index == items.length - 1;

          return BlocListener<ActiveTrainingBloc, ActiveTrainingState>(
              listener: (context, state) {
                if (state is ActiveTrainingLoaded) {
                  if (state.lastStartedTimerId != lastStartedTimerId) {
                    lastStartedTimerId = state.lastStartedTimerId;
                    final globalKey = state.timersStateList
                        .firstWhereOrNull(
                            (el) => el.timerId == lastStartedTimerId)
                        ?.exerciseGlobalKey;
                    if (globalKey != null && globalKey.currentContext != null) {
                      Scrollable.ensureVisible(
                        globalKey.currentContext!,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                }
              },
              child: exercise.exerciseType == ExerciseType.run
                  ? ActiveRunWidget(
                      exercise: exercise,
                      isLast: isLast,
                      exerciseIndex: index,
                      key: GlobalKey(),
                      lastTrainingVersionId: lastTrainingVersionId,
                    )
                  : ActiveExerciseWidget(
                      exercise: exercise,
                      isLast: isLast,
                      exerciseIndex: index,
                      key: GlobalKey(),
                      lastTrainingVersionId: lastTrainingVersionId,
                    ));
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          final isLast = index == items.length - 1;
          final List<Exercise> multisetExercises =
              (sl<TrainingManagementBloc>().state as TrainingManagementLoaded)
                  .activeTraining!
                  .exercises
                  .where((e) => e.multisetId == multiset.id)
                  .toList();
          return ActiveMultisetWidget(
            isLast: isLast,
            multiset: multiset,
            multisetIndex: index,
            lastTrainingVersionId: lastTrainingVersionId,
            multisetExercises: multisetExercises,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
