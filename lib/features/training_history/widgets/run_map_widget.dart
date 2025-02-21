import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';

import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app_colors.dart';

import '../models/history_run_location.dart';

class RunMapView extends StatefulWidget {
  final List<RunLocation> locations;

  const RunMapView({super.key, required this.locations});

  @override
  State<RunMapView> createState() => _RunMapViewState();
}

class _RunMapViewState extends State<RunMapView> {
  final Future<CacheStore> _cacheStoreFuture = _getCacheStore();

  static Future<CacheStore> _getCacheStore() async {
    final dir = await getTemporaryDirectory();
    return FileCacheStore('${dir.path}${Platform.pathSeparator}MapTiles');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locations.isEmpty) {
      return const Center(child: Text('Aucune donnée de localisation'));
    }

    final points = widget.locations
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    // Calcul des limites
    double minLat = widget.locations.first.latitude;
    double maxLat = widget.locations.first.latitude;
    double minLng = widget.locations.first.longitude;
    double maxLng = widget.locations.first.longitude;

    for (var location in widget.locations) {
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
        height: 250,
        width: MediaQuery.of(context).size.width - 60,
        child: FutureBuilder(
          future: _cacheStoreFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final cacheStore = snapshot.data!;
              return FlutterMap(
                options: MapOptions(
                  backgroundColor: AppColors.floralWhite,
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
                    userAgentPackageName:
                        'dev.oscarthiebaut.my_fitness_tracker',
                    tileProvider: CachedTileProvider(
                      store: cacheStore,
                    ),
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
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
