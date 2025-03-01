import 'package:bloc/bloc.dart';

class NavigationCubit extends Cubit<List<String>> {
  NavigationCubit() : super([]);

  // Ajoute une nouvelle route et conserve uniquement les 3 dernières
  void addRoute(String route) {
    if (state.contains(route) || route.isEmpty) {
      return; // Ne rien faire si la route existe déjà
    }

    final updatedRoutes = List<String>.from(state);

    // Limite à 3 routes maximum
    if (updatedRoutes.length == 3) {
      updatedRoutes.removeAt(0); // Supprime la route la plus ancienne
    }
    updatedRoutes.add(route);
    emit(updatedRoutes);
  }

  // Récupère toutes les routes actuelles
  List<String> getRoutes() => List<String>.from(state);

  void removeMostRecentRoute() {
    if (state.isEmpty) {
      return;
    }
    final updatedRoutes = List<String>.from(state);
    updatedRoutes.removeLast(); // Supprime la dernière route (la plus récente)
    emit(updatedRoutes);
  }
}
