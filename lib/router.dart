import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';
import 'package:my_fitness_tracker/history_page.dart';
import 'package:my_fitness_tracker/home_page.dart';
import 'package:my_fitness_tracker/settings_page.dart';
import 'package:my_fitness_tracker/trainings_page.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        // TODO : remplacer par splash screen
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
      ],
      builder: (context, state, child) {
        return Scaffold(
            body: SafeArea(child: child),
            bottomNavigationBar: const BottomNavigationBarWidget());
      },
    ),
  ],
);

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current location
    bool isHomePage = GoRouterState.of(context).uri.toString() == '/home';
    bool isTrainingsPage =
        GoRouterState.of(context).uri.toString() == '/trainings';
    bool isHistoryPage = GoRouterState.of(context).uri.toString() == '/history';
    bool isSettingsPage =
        GoRouterState.of(context).uri.toString() == '/settings';

    return Container(
      padding: const EdgeInsets.all(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: () {
                  if (!isHomePage) {
                    GoRouter.of(context).go('/home');
                  }
                },
                child: const Icon(
                  Icons.home,
                  color: AppColors.black,
                )),
            GestureDetector(
                onTap: () {
                  if (!isTrainingsPage) {
                    GoRouter.of(context).go('/trainings');
                  }
                },
                child: Icon(
                  Icons.question_mark,
                  color: AppColors.black,
                )),
            GestureDetector(
                onTap: () {
                  if (!isHistoryPage) {
                    GoRouter.of(context).go('/history');
                  }
                },
                child: Icon(
                  Icons.question_mark,
                  color: AppColors.black,
                )),
            GestureDetector(
                onTap: () {
                  if (!isSettingsPage) {
                    GoRouter.of(context).go('/settings');
                  }
                },
                child: Icon(
                  Icons.question_mark,
                  color: AppColors.black,
                )),
          ],
        ),
      ),
    );
  }
}
