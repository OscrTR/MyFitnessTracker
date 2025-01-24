import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'app_colors.dart';
import 'core/messages/bloc/message_bloc.dart';
import 'features/stats/presentation/pages/stats_page.dart';
import 'features/training_history/presentation/pages/history_page.dart';
import 'features/active_training/presentation/pages/active_training_page.dart';
import 'features/exercise_management/presentation/pages/exercise_detail_page.dart';
import 'features/homepage/presentation/pages/home_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/training_management/presentation/pages/training_details_page.dart';
import 'features/training_management/presentation/pages/trainings_page.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    ShellRoute(
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const HomePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
        GoRoute(
          path: '/trainings',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const TrainingsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const HistoryPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const StatsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const SettingsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
        GoRoute(
          path: '/exercise_detail',
          pageBuilder: (context, state) {
            final fromTrainingCreation =
                (state.extra as String?) == 'training_detail';
            return CustomTransitionPage(
              child: ExerciseDetailPage(
                fromTrainingCreation: fromTrainingCreation,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
        GoRoute(
          path: '/training_detail',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const TrainingDetailsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
        GoRoute(
          path: '/active_training',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const ActiveTrainingPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            );
          },
        ),
      ],
      builder: (context, state, child) {
        bool isExerciseDetailPage =
            GoRouterState.of(context).uri.toString() == '/exercise_detail';
        bool isTrainingDetailPage =
            GoRouterState.of(context).uri.toString() == '/training_detail';
        bool isActiveTrainingPage =
            GoRouterState.of(context).uri.toString() == '/active_training';

        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: GestureDetector(
                  onTap: () {
                    // Unfocus the text field and close the keyboard when tapping outside
                    FocusScope.of(context).unfocus();
                  },
                  child: BlocListener<MessageBloc, MessageState>(
                      listener: (context, state) {
                        if (state is MessageLoaded) {
                          if (!state.isError) {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.success(
                                  icon: const Icon(null),
                                  textStyle: const TextStyle(
                                      fontSize: 16, color: AppColors.black),
                                  backgroundColor: const Color(0xffadebb3),
                                  message: state.message),
                            );
                          }

                          if (state.isError) {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.error(
                                  icon: const Icon(null),
                                  textStyle: const TextStyle(
                                      fontSize: 16, color: AppColors.black),
                                  backgroundColor: const Color(0xffff857a),
                                  message: state.message),
                            );
                          }
                        }
                      },
                      child: child),
                ),
              ),
              if (!isExerciseDetailPage &&
                  !isTrainingDetailPage &&
                  !isActiveTrainingPage)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomNavigationBarWidget(),
                ),
            ],
          ),
        );
      },
    ),
  ],
);

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isHomePage = GoRouterState.of(context).uri.toString() == '/home';
    bool isTrainingsPage =
        GoRouterState.of(context).uri.toString() == '/trainings';
    bool isHistoryPage = GoRouterState.of(context).uri.toString() == '/history';
    bool isSettingsPage =
        GoRouterState.of(context).uri.toString() == '/settings';
    bool isStatsPage = GoRouterState.of(context).uri.toString() == '/stats';

    return Container(
      height: 70,
      color: AppColors.floralWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LottieIconButton(
            url: '/home',
            lottieAsset: 'assets/lottie/home.json',
            pageName: tr('nav_home'),
            iconSize: 30,
            customAction: () {
              if (!isHomePage) {
                GoRouter.of(context).push('/home');
              }
            },
          ),
          LottieIconButton(
            url: '/trainings',
            lottieAsset: 'assets/lottie/trainings.json',
            pageName: tr('nav_trainings'),
            iconSize: 30,
            customAction: () {
              if (!isTrainingsPage) {
                GoRouter.of(context).push('/trainings');
              }
            },
          ),
          LottieIconButton(
            url: '/history',
            lottieAsset: 'assets/lottie/history.json',
            pageName: tr('nav_history'),
            iconSize: 30,
            customAction: () {
              if (!isHistoryPage) {
                GoRouter.of(context).push('/history');
              }
            },
          ),
          LottieIconButton(
            url: '/stats',
            lottieAsset: 'assets/lottie/stats.json',
            pageName: tr('nav_stats'),
            iconSize: 30,
            customAction: () {
              if (!isStatsPage) {
                GoRouter.of(context).push('/stats');
              }
            },
          ),
          LottieIconButton(
            url: '/settings',
            lottieAsset: 'assets/lottie/settings.json',
            pageName: tr('nav_settings'),
            iconSize: 30,
            customAction: () {
              if (!isSettingsPage) {
                GoRouter.of(context).push('/settings');
              }
            },
          ),
        ],
      ),
    );
  }
}

class LottieIconButton extends StatefulWidget {
  final String lottieAsset;
  final String pageName;
  final double iconSize;
  final VoidCallback? customAction;
  final String url;

  const LottieIconButton({
    super.key,
    required this.lottieAsset,
    required this.pageName,
    required this.iconSize,
    this.customAction,
    required this.url,
  });

  @override
  LottieIconButtonState createState() => LottieIconButtonState();
}

class LottieIconButtonState extends State<LottieIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAndAnimate() {
    bool isCurrentPage = GoRouterState.of(context).uri.toString() == widget.url;
    if (isCurrentPage) {
      _controller.forward(from: 0.0); // Start animation when on the target page
    } else {
      _controller.value = 0; // Set to end if not on the target page
    }
  }

  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoaded == true) {
      _checkAndAnimate();
    }
    return GestureDetector(
        onTap: () {
          _controller.forward(from: 0.0);
          if (widget.customAction != null) {
            widget.customAction!();
          }
        },
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                widget.lottieAsset,
                controller: _controller,
                width: widget.iconSize,
                height: widget.iconSize,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _checkAndAnimate();
                  _isLoaded = true;
                },
              ),
              const SizedBox(height: 2),
              Text(widget.pageName,
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        widget.url == GoRouterState.of(context).uri.toString()
                            ? AppColors.licorice
                            : AppColors.taupeGray,
                  )),
            ],
          ),
        ));
  }
}
