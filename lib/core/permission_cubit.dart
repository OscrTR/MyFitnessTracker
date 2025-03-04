import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'enums/enums.dart';
import 'messages/toast.dart';
import '../features/active_training/foreground_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_location/fl_location.dart';

import '../injection_container.dart';

class PermissionState {
  final bool isNotificationAuthorized;
  final bool isLocationPermissionGrantedAlways;
  final bool isLocationPermissionGrantedInUse;
  final bool isLocationEnabled;
  final bool isLocationPermissionDeniedForever;
  final bool isBatteryOptimizationIgnored;

  const PermissionState({
    this.isNotificationAuthorized = false,
    this.isLocationPermissionGrantedAlways = false,
    this.isLocationPermissionGrantedInUse = false,
    this.isLocationEnabled = false,
    this.isLocationPermissionDeniedForever = false,
    this.isBatteryOptimizationIgnored = false,
  });

  PermissionState copyWith({
    bool? isNotificationAuthorized,
    bool? isLocationPermissionGrantedAlways,
    bool? isLocationPermissionGrantedInUse,
    bool? isLocationEnabled,
    bool? isLocationPermissionDeniedForever,
    bool? isBatteryOptimizationIgnored,
  }) {
    return PermissionState(
      isNotificationAuthorized:
          isNotificationAuthorized ?? this.isNotificationAuthorized,
      isLocationPermissionGrantedAlways: isLocationPermissionGrantedAlways ??
          this.isLocationPermissionGrantedAlways,
      isLocationPermissionGrantedInUse: isLocationPermissionGrantedInUse ??
          this.isLocationPermissionGrantedInUse,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      isLocationPermissionDeniedForever: isLocationPermissionDeniedForever ??
          this.isLocationPermissionDeniedForever,
      isBatteryOptimizationIgnored:
          isBatteryOptimizationIgnored ?? this.isBatteryOptimizationIgnored,
    );
  }
}

class PermissionCubit extends Cubit<PermissionState> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  PermissionCubit({
    required this.flutterLocalNotificationsPlugin,
  }) : super(const PermissionState());

  /// Vérifie si les notifications sont autorisées
  Future<void> checkNotificationPermission() async {
    final authorized = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .areNotificationsEnabled();
    emit(state.copyWith(isNotificationAuthorized: authorized ?? false));
  }

  /// Demande l'autorisation pour les notifications
  Future<void> requestNotificationPermission() async {
    final authorized = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    emit(state.copyWith(isNotificationAuthorized: authorized ?? false));
  }

  /// Vérifie les permissions pour la localisation
  Future<void> checkLocationPermission() async {
    final alwaysStatus = await Permission.locationAlways.status;
    final inUseStatus = await Permission.locationWhenInUse.status;
    emit(state.copyWith(
      isLocationPermissionGrantedAlways: alwaysStatus.isGranted,
      isLocationPermissionGrantedInUse: inUseStatus.isGranted,
      isLocationPermissionDeniedForever: alwaysStatus.isPermanentlyDenied,
    ));
  }

  /// Demande les permissions pour la localisation
  Future<void> requestLocationPermission() async {
    if (state.isLocationPermissionDeniedForever) {
      await openAppSettings(); // Envoyer l'utilisateur aux paramètres
    } else if (!state.isLocationPermissionGrantedInUse) {
      // Demander la permission pour l'utilisation de la localisation
      final inUseStatus = await Permission.locationWhenInUse.request();
      emit(state.copyWith(
        isLocationPermissionGrantedInUse: inUseStatus.isGranted,
      ));
    } else if (!state.isLocationPermissionGrantedAlways) {
      // Demander la permission "toujours"
      final alwaysStatus = await Permission.locationAlways.request();
      emit(state.copyWith(
        isLocationPermissionGrantedAlways: alwaysStatus.isGranted,
      ));
    }
  }

  /// Vérifie si le service de localisation est activé
  Future<void> checkLocationStatus() async {
    final serviceEnabled = await FlLocation.isLocationServicesEnabled;
    emit(state.copyWith(isLocationEnabled: serviceEnabled));
  }

  Future<void> requestLocationEnabled() async {
    // Vérifie si la localisation est activée
    final serviceEnabled = await FlLocation.isLocationServicesEnabled;

    // Si la localisation n'est pas activée, demande à l'utilisateur
    if (!serviceEnabled) {
      try {
        // Affiche une demande pour activer la localisation
        await sl<ForegroundService>().requestService();
      } catch (e) {
        // Si l'utilisateur refuse ou s'il y a une erreur
        showToastMessage(
            message: e.toString(),
            isSuccess: false,
            isLog: true,
            logFunction: 'requestLocationEnabled',
            logLevel: LogLevel.error);
      }
    }

    // Vérifie de nouveau si les services sont activés
    final updatedServiceEnabled = await FlLocation.isLocationServicesEnabled;

    // Mettre à jour l'état du cubit
    emit(state.copyWith(isLocationEnabled: updatedServiceEnabled));
  }

  /// Vérifie si l'optimisation de batterie est ignorée
  Future<void> checkBatteryOptimization() async {
    PermissionStatus status =
        await Permission.ignoreBatteryOptimizations.status;
    emit(state.copyWith(isBatteryOptimizationIgnored: status.isGranted));
  }

  /// Demande la permission d'ignorer les optimisations de batterie
  Future<void> requestBatteryOptimizationIgnored() async {
    if (!state.isBatteryOptimizationIgnored) {
      final result = await Permission.ignoreBatteryOptimizations.request();
      if (!result.isGranted) {
        openAppSettings();
      }
    }
  }

  /// Vérifie si l'appareil est Xiaomi/Redmi ou Huawei et demande
  /// à l'utilisateur de désactiver l'optimisation de batterie.
  Future<void> checkAndRequestBatteryOptimization(BuildContext context) async {
    if (!Platform.isAndroid) return;

    // Petit délai pour s'assurer que l'application a terminé son build
    await Future.delayed(const Duration(milliseconds: 500));

    await checkBatteryOptimization();

    // Affichage d'une boîte de dialogue pour informer l'utilisateur.
    if (!state.isBatteryOptimizationIgnored && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(tr('home_page_battery_title')),
            content: Text(tr('home_page_battery_text')),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await requestBatteryOptimizationIgnored();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}
