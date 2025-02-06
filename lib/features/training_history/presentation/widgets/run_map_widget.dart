import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_fitness_tracker/app_colors.dart';

import '../../domain/entities/history_run_location.dart';

class RunMapView extends StatelessWidget {
  final List<RunLocation> locations;

  const RunMapView({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return const Center(child: Text('Aucune donnée de localisation'));
    }

    final points =
        locations.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();

    // Calcul des limites
    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (var location in locations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLng) minLng = location.longitude;
      if (location.longitude > maxLng) maxLng = location.longitude;
    }

    final center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    final bounds = LatLngBounds(
      LatLng(minLat - 0.01, minLng - 0.01),
      LatLng(maxLat + 0.01, maxLng + 0.01),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 200,
        width: MediaQuery.of(context).size.width - 60,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13.0,
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50.0),
            ),
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://cartodb-basemaps-a.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.my_fitness_tracker.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  strokeWidth: 4.0,
                  color: AppColors.folly,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
