import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app_colors.dart';
import '../bloc/active_training_bloc.dart';
import '../widgets/error_state_widget.dart';
import 'package:uuid/uuid.dart';
import '../../../../injection_container.dart';
import '../widgets/active_multiset_widget.dart';
import '../widgets/active_run_widget.dart';
import '../widgets/timer_widget.dart';

import '../../../training_management/domain/entities/training_exercise.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';

import '../../../training_management/domain/entities/multiset.dart';
import '../widgets/active_exercise_widget.dart';

const uuid = Uuid();

class ActiveTrainingPage extends StatefulWidget {
  const ActiveTrainingPage({super.key});

  @override
  State<ActiveTrainingPage> createState() => _ActiveTrainingPageState();
}

class _ActiveTrainingPageState extends State<ActiveTrainingPage> {
  PermissionStatus? isLocationPermissionGranted;
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
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
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
    Location location = Location();
    PermissionStatus permission = await location.hasPermission();
    setState(() {
      isLocationPermissionGranted = permission;
    });
  }

  Future<void> _requestLocationPermission() async {
    Location location = Location();
    PermissionStatus permission = await location.requestPermission();
    if (permission == PermissionStatus.granted) {
      setState(() {
        isLocationPermissionGranted = PermissionStatus.granted;
      });
    }
  }

  Future<void> _checkLocationStatus() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();

    setState(() {
      isLocationEnabled = serviceEnabled;
    });
  }

  Future<void> _requestLocationEnabled() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          isLocationEnabled = false;
        });
        return;
      }
    }

    setState(() {
      isLocationEnabled = serviceEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
                  builder: (context, state) {
                if (state is TrainingManagementLoaded &&
                    state.activeTraining != null) {
                  bool isVerified = false;

                  bool hasRunExercise = state.activeTraining!.trainingExercises
                          .any((el) =>
                              el.trainingExerciseType ==
                              TrainingExerciseType.run) ||
                      state.activeTraining!.multisets.any((multiset) =>
                          multiset.trainingExercises!.any((el) =>
                              el.trainingExerciseType ==
                              TrainingExerciseType.run));

                  if (hasRunExercise) {
                    if (isLocationPermissionGranted ==
                            PermissionStatus.granted &&
                        isLocationEnabled) {
                      isVerified = true;
                    } else {
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: isNotificationAuthorized
                                            ? AppColors.whiteSmoke
                                            : AppColors.licorice,
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: isLocationPermissionGranted ==
                                                PermissionStatus.granted
                                            ? AppColors.whiteSmoke
                                            : AppColors.licorice,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      isLocationPermissionGranted ==
                                              PermissionStatus.granted
                                          ? tr('active_training_granted')
                                          : tr('active_training_ask'),
                                      style: TextStyle(
                                          color: isLocationPermissionGranted ==
                                                  PermissionStatus.granted
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: isLocationEnabled
                                            ? AppColors.whiteSmoke
                                            : AppColors.licorice,
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                  } else if (!isNotificationAuthorized) {
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
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
                  } else {
                    isVerified = true;
                  }

                  if (isVerified) {
                    final sortedItems = _getSortedTrainingItems(state);

                    final exercisesAndMultisetsList = [
                      ...state.activeTraining!.trainingExercises
                          .map((e) => {'type': 'exercise', 'data': e}),
                      ...state.activeTraining!.multisets
                          .map((m) => {'type': 'multiset', 'data': m}),
                    ];
                    exercisesAndMultisetsList.sort((a, b) {
                      final aPosition = (a['data'] as dynamic).position ?? 0;
                      final bPosition = (b['data'] as dynamic).position ?? 0;
                      return aPosition.compareTo(bPosition);
                    });
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildHeader(state, context),
                              _buildTrainingItemList(sortedItems, context,
                                  exercisesAndMultisetsList),
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTap: () {
                                  GoRouter.of(context).go('/home');
                                  context
                                      .read<ActiveTrainingBloc>()
                                      .add(ClearTimers());
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
                                      style: const TextStyle(
                                          color: AppColors.white),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                              const SizedBox(height: 90),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child:
                            const Center(child: CircularProgressIndicator()));
                  }
                }
                return const ErrorStateWidget();
              })
            ],
          ),
        ),
        BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
            builder: (context, state) {
          if (state is TrainingManagementLoaded &&
              state.activeTraining != null) {
            bool isVerified = false;

            if (state.activeTraining!.trainingExercises.any(
                (el) => el.trainingExerciseType == TrainingExerciseType.run)) {
              if (isLocationPermissionGranted == PermissionStatus.granted &&
                  isLocationEnabled) {
                isVerified = true;
              }
            } else {
              isVerified = true;
            }

            if (isVerified) {
              return const Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: TimerWidget(),
              );
            }
          }
          return const SizedBox();
        })
      ],
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

  List<Map<String, dynamic>> _getSortedTrainingItems(
      TrainingManagementLoaded state) {
    final items = [
      ...state.activeTraining!.trainingExercises
          .map((e) => {'type': 'exercise', 'data': e}),
      ...state.activeTraining!.multisets
          .map((m) => {'type': 'multiset', 'data': m}),
    ];
    items.sort((a, b) {
      final aPos = (a['data'] as dynamic).position ?? 0;
      final bPos = (b['data'] as dynamic).position ?? 0;
      return aPos.compareTo(bPos);
    });
    return items;
  }

  Widget _buildTrainingItemList(
      List<Map<String, dynamic>> items,
      BuildContext context,
      List<Map<String, Object>> exercisesAndMultisetsList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'exercise') {
          final exercise = item['data'] as TrainingExercise;
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
              child: exercise.trainingExerciseType == TrainingExerciseType.run
                  ? ActiveRunWidget(
                      tExercise: exercise,
                      isLast: isLast,
                      exerciseIndex: index,
                      key: GlobalKey(),
                    )
                  : ActiveExerciseWidget(
                      tExercise: exercise,
                      isLast: isLast,
                      exerciseIndex: index,
                      key: GlobalKey(),
                    ));
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          final isLast = index == items.length - 1;
          return ActiveMultisetWidget(
            isLast: isLast,
            multiset: multiset,
            multisetIndex: index,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
