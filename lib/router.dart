import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'core/navigation_cubit.dart';

import 'app_colors.dart';
import 'features/active_training/pages/active_training_page.dart';
import 'features/base_exercise_management/pages/base_exercise_detail_page.dart';
import 'features/homepage/pages/home_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/stats/pages/stats_page.dart';
import 'features/training_history/pages/history_details_page.dart';
import 'features/training_history/pages/history_page.dart';
import 'features/training_management/pages/training_details_page.dart';
import 'features/training_management/pages/trainings_page.dart';
import 'injection_container.dart';

final router = GoRouter(
  initialLocation: '/home',
  observers: [BotToastNavigatorObserver()],
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
            sl<NavigationCubit>().addRoute('/home');
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
            sl<NavigationCubit>().addRoute('/trainings');
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
            sl<NavigationCubit>().addRoute('/history');
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
          path: '/history_details',
          pageBuilder: (context, state) {
            sl<NavigationCubit>().addRoute('/history_details');
            return CustomTransitionPage(
              child: const HistoryDetailsPage(),
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
            sl<NavigationCubit>().addRoute('/stats');
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
            sl<NavigationCubit>().addRoute('/settings');
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
            sl<NavigationCubit>().addRoute('/exercise_detail');
            final fromTrainingCreation =
                (state.extra as String?) == 'training_detail';
            return CustomTransitionPage(
              child: BaseExerciseDetailPage(
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
            sl<NavigationCubit>().addRoute('/training_detail');
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
            sl<NavigationCubit>().addRoute('/active_training');
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
        String pageName = GoRouterState.of(context).uri.toString();
        bool isExerciseDetailPage = pageName == '/exercise_detail';
        bool isTrainingDetailPage = pageName == '/training_detail';
        bool isActiveTrainingPage = pageName == '/active_training';
        bool isHistoryDetailPage = pageName == '/history_details';

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            body: Stack(
              children: [
                SafeArea(child: child),
                if (!isExerciseDetailPage &&
                    !isTrainingDetailPage &&
                    !isActiveTrainingPage &&
                    !isHistoryDetailPage)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNavigationBarWidget(),
                  ),
              ],
            ),
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
                GoRouter.of(context).go('/home');
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
                GoRouter.of(context).go('/trainings');
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
                GoRouter.of(context).go('/history');
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
                GoRouter.of(context).go('/stats');
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
                GoRouter.of(context).go('/settings');
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
          FocusScope.of(context).unfocus();
          _controller.forward(from: 0.0);
          if (widget.customAction != null) {
            widget.customAction!();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 5,
          color: AppColors.floralWhite,
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
