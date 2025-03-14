import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../app_colors.dart';
import '../../../core/back_button_behavior.dart';
import '../../../core/enums/enums.dart';
import '../../../core/permission_cubit.dart';
import '../../../injection_container.dart';
import '../../training_history/bloc/training_history_bloc.dart';
import '../../training_management/models/exercise.dart';
import '../../training_management/models/multiset.dart';
import '../bloc/active_training_bloc.dart';
import '../widgets/active_exercise_widget.dart';
import '../widgets/active_multiset_widget.dart';
import '../widgets/active_run_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/timer_widget.dart';

const uuid = Uuid();

class ActiveTrainingPage extends StatefulWidget {
  const ActiveTrainingPage({super.key});

  @override
  State<ActiveTrainingPage> createState() => _ActiveTrainingPageState();
}

class _ActiveTrainingPageState extends State<ActiveTrainingPage>
    with WidgetsBindingObserver {
  String? lastStartedTimerId;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance.addObserver(this);
    context.read<PermissionCubit>().checkNotificationPermission();
    context.read<PermissionCubit>().checkLocationPermission();
    context.read<PermissionCubit>().checkLocationStatus();
    context.read<PermissionCubit>().checkBatteryOptimization();
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
      context.read<PermissionCubit>().checkNotificationPermission();
      context.read<PermissionCubit>().checkLocationPermission();
      context.read<PermissionCubit>().checkLocationStatus();
      context.read<PermissionCubit>().checkBatteryOptimization();
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
              backButtonClick(context);
            },
            child: Text(tr('global_yes')),
          ),
        ],
      ),
    );
    return true;
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
                  BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
                    buildWhen: (previous, current) {
                      if (previous is ActiveTrainingLoaded &&
                          current is ActiveTrainingLoaded) {
                        return previous.activeTraining !=
                            current.activeTraining;
                      }
                      return true;
                    },
                    builder: (context, state) {
                      // Vérifie d'abord l'état de ActiveTrainingState
                      if (state is ActiveTrainingLoaded &&
                          state.activeTraining != null) {
                        return BlocSelector<PermissionCubit, PermissionState,
                            bool>(
                          // Sélectionne uniquement les changements pertinents
                          selector: (permissionState) {
                            final hasRunExercise =
                                state.activeTraining!.exercises.any((e) =>
                                    e.exerciseType == ExerciseType.running);

                            if (permissionState.requiresAllPermissions) {
                              if (hasRunExercise) {
                                return !permissionState
                                        .isLocationPermissionGrantedAlways ||
                                    !permissionState.isLocationEnabled ||
                                    !permissionState.isNotificationAuthorized ||
                                    !permissionState
                                        .isBatteryOptimizationIgnored;
                              }
                              return !permissionState
                                      .isLocationPermissionGrantedAlways ||
                                  !permissionState.isNotificationAuthorized ||
                                  !permissionState.isBatteryOptimizationIgnored;
                            } else if (hasRunExercise) {
                              return !permissionState
                                      .isLocationPermissionGrantedAlways ||
                                  !permissionState.isLocationEnabled ||
                                  !permissionState.isNotificationAuthorized ||
                                  !permissionState.isBatteryOptimizationIgnored;
                            } else {
                              return !permissionState
                                      .isNotificationAuthorized ||
                                  !permissionState.isBatteryOptimizationIgnored;
                            }
                          },
                          builder: (context, isPermissionMissing) {
                            final isRun = state.activeTraining!.exercises.any(
                                (e) => e.exerciseType == ExerciseType.running);
                            // Si les permissions ne sont pas correctes
                            if (isPermissionMissing) {
                              if (isRun ||
                                  context
                                      .read<PermissionCubit>()
                                      .state
                                      .requiresAllPermissions) {
                                return _buildFullPermissions(context,
                                    isRun: isRun);
                              }
                              return _buildMinimalPermission(context);
                            }

                            // Sinon, construit la liste des exercices et multisets
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
                              exercisesAndMultisetsList,
                            );
                          },
                        );
                      }
                      return const ErrorStateWidget();
                    },
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
                builder: (context, state) {
                  if (state is ActiveTrainingLoaded &&
                      state.activeTraining != null) {
                    final permissionState =
                        context.watch<PermissionCubit>().state;

                    final hasRunExercise = state.activeTraining!.exercises
                        .any((e) => e.exerciseType == ExerciseType.running);

                    final hasAllPermissions =
                        permissionState.isLocationPermissionGrantedAlways &&
                            permissionState.isNotificationAuthorized &&
                            permissionState.isBatteryOptimizationIgnored;

                    final locationEnabled = permissionState.isLocationEnabled;

                    // Case 1: Requires all permissions
                    if (permissionState.requiresAllPermissions) {
                      if (hasAllPermissions &&
                          (!hasRunExercise || locationEnabled)) {
                        return const TimerWidget();
                      }
                    }
                    // Case 2: Does not require all permissions
                    else {
                      if (hasRunExercise) {
                        if (hasAllPermissions && locationEnabled) {
                          return const TimerWidget();
                        }
                      } else if (permissionState.isNotificationAuthorized &&
                          permissionState.isBatteryOptimizationIgnored) {
                        return const TimerWidget();
                      }
                    }
                  }
                  return const SizedBox();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  SizedBox _buildMinimalPermission(BuildContext context) {
    final permissionState =
        context.watch<PermissionCubit>().state; // Accès à l'état du cubit

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
                context
                    .read<PermissionCubit>()
                    .requestNotificationPermission(); // Appel au cubit
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: permissionState.isNotificationAuthorized
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    permissionState.isNotificationAuthorized
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: permissionState.isNotificationAuthorized
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
            const SizedBox(height: 30),
            Text(tr('active_training_battery_optimization_ignored')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                context
                    .read<PermissionCubit>()
                    .requestBatteryOptimizationIgnored();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: permissionState.isBatteryOptimizationIgnored
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    permissionState.isBatteryOptimizationIgnored
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: permissionState.isBatteryOptimizationIgnored
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _buildFullPermissions(BuildContext context, {required bool isRun}) {
    final permissionState =
        context.watch<PermissionCubit>().state; // Accès à l'état du cubit

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
                context.read<PermissionCubit>().requestNotificationPermission();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: permissionState.isNotificationAuthorized
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    permissionState.isNotificationAuthorized
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: permissionState.isNotificationAuthorized
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
            const SizedBox(height: 30),
            Text(tr('active_training_location')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                context.read<PermissionCubit>().requestLocationPermission();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: permissionState.isLocationPermissionGrantedAlways
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    permissionState.isLocationPermissionGrantedAlways
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: permissionState.isLocationPermissionGrantedAlways
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
            const SizedBox(height: 30),
            if (isRun)
              Column(
                children: [
                  Text(tr('active_training_location_enabled')),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      context.read<PermissionCubit>().requestLocationEnabled();
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: permissionState.isLocationEnabled
                                ? AppColors.whiteSmoke
                                : AppColors.licorice,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          permissionState.isLocationEnabled
                              ? tr('active_training_granted')
                              : tr('active_training_ask'),
                          style: TextStyle(
                              color: permissionState.isLocationEnabled
                                  ? AppColors.frenchGray
                                  : AppColors.white),
                        )),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            Text(tr('active_training_battery_optimization_ignored')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                context
                    .read<PermissionCubit>()
                    .requestBatteryOptimizationIgnored();
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: permissionState.isBatteryOptimizationIgnored
                          ? AppColors.whiteSmoke
                          : AppColors.licorice,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    permissionState.isBatteryOptimizationIgnored
                        ? tr('active_training_granted')
                        : tr('active_training_ask'),
                    style: TextStyle(
                        color: permissionState.isBatteryOptimizationIgnored
                            ? AppColors.frenchGray
                            : AppColors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildPageContent(
      ActiveTrainingLoaded state,
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
                  FocusScope.of(context).unfocus();
                  final currentState =
                      (sl<ActiveTrainingBloc>().state as ActiveTrainingLoaded);

                  final currentTimerState = currentState.timersStateList
                      .firstWhere((timer) =>
                          timer.timerId == currentState.lastStartedTimerId);

                  if (currentTimerState.timerId != 'primaryTimer' &&
                      currentTimerState.isActive &&
                      !currentTimerState.timerId.contains('rest')) {
                    sl<TrainingHistoryBloc>().add(
                      CreateOrUpdateHistoryEntry(
                        historyEntry: null,
                        timerState: currentTimerState,
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

  Widget _buildHeader(ActiveTrainingLoaded state, BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
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
    List<Map<String, Object>> exercisesAndMultisetsList,
  ) {
    final state =
        context.read<ActiveTrainingBloc>().state as ActiveTrainingLoaded;
    final lastTrainingVersionId = state.activeTrainingMostRecentVersionId;

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
              child: exercise.exerciseType == ExerciseType.running
                  ? ActiveRunWidget(
                      exercise: exercise,
                      isLast: isLast,
                      exerciseIndex: index,
                      key: GlobalKey(),
                      lastTrainingVersionId: lastTrainingVersionId ?? -1,
                    )
                  : ActiveExerciseWidget(
                      exercise: exercise,
                      isLast: isLast,
                      exerciseIndex: index,
                      key: GlobalKey(),
                      lastTrainingVersionId: lastTrainingVersionId ?? -1,
                    ));
        } else if (item['type'] == 'multiset') {
          final multiset = item['data'] as Multiset;
          final isLast = index == items.length - 1;
          final List<Exercise> multisetExercises = state
              .activeTraining!.exercises
              .where((e) => e.multisetId == multiset.id)
              .toList();
          return ActiveMultisetWidget(
            isLast: isLast,
            multiset: multiset,
            lastTrainingVersionId: lastTrainingVersionId ?? -1,
            multisetExercises: multisetExercises,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
