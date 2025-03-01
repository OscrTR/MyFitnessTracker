import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'navigation_cubit.dart';

bool backButtonClick(BuildContext context) {
  final navigationCubit = context.read<NavigationCubit>();
  final currentRoutes = navigationCubit.getRoutes();

  /// 1. Si actuellement sur `/home` et aucune autre route disponible, ne rien faire
  if (currentRoutes.isEmpty &&
      GoRouterState.of(context).uri.toString() == '/home') {
    return true; // Empêche toute action sur le bouton "Retour"
  }

  /// 2. S'il y a des routes dans la pile
  if (currentRoutes.isNotEmpty) {
    navigationCubit.removeMostRecentRoute(); // Supprime la route actuelle
    final updatedRoutes = navigationCubit.getRoutes();
    if (updatedRoutes.isNotEmpty) {
      final lastRoute = updatedRoutes.last; // Récupère la route la plus récente
      GoRouter.of(context).go(lastRoute);
      return true; // Intercepte le bouton "Retour"
    } else {
      GoRouter.of(context).go('/home');
    }
  }

  /// 3. S'il n'y a aucune route restante, redirige vers `/home`
  GoRouter.of(context).go('/home');
  return true;
}
