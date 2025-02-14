import 'package:equatable/equatable.dart';

class RunLocation extends Equatable {
  final int? id;
  final int trainingId;
  final int? multisetId;
  final int trainingExerciseId;
  final int setNumber;
  final int? multisetSetNumber;
  final double latitude;
  final double longitude;
  final double altitude;
  final int timestamp;
  final double accuracy;
  final double speed;

  const RunLocation({
    this.id,
    required this.trainingId,
    required this.multisetId,
    required this.trainingExerciseId,
    required this.setNumber,
    required this.multisetSetNumber,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
    required this.accuracy,
    required this.speed,
  });

  factory RunLocation.fromMap(Map<String, dynamic> map) {
    return RunLocation(
      id: map['id'] as int?,
      trainingId: map['training_id'] as int,
      trainingExerciseId: map['training_exercise_id'] as int,
      setNumber: map['set_number'] as int,
      multisetSetNumber: map['multiset_set_number'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: map['altitude'] as double,
      timestamp: map['timestamp'] as int,
      accuracy: map['accuracy'] as double,
      speed: map['speed'] as double,
      multisetId: map['multiset_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'training_id': trainingId,
      'multiset_id': multisetId,
      'training_exercise_id': trainingExerciseId,
      'set_number': setNumber,
      'multiset_set_number': multisetSetNumber,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'timestamp': timestamp,
      'accuracy': accuracy,
      'speed': speed,
    };
  }

  @override
  List<Object?> get props => [
        id,
        trainingId,
        multisetId,
        trainingExerciseId,
        setNumber,
        multisetSetNumber,
        latitude,
        longitude,
        altitude,
        timestamp,
        accuracy,
        speed,
      ];

  static int calculateTotalDrop(List<RunLocation> locations) {
    if (locations.isEmpty) return 0;

    // Trier les locations par timestamp pour assurer l'ordre chronologique
    final sortedLocations = List<RunLocation>.from(locations)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double totalAscent = 0;
    double totalDescent = 0;
    double? previousAltitude;

    for (var location in sortedLocations) {
      if (previousAltitude != null) {
        final altitudeDifference = location.altitude - previousAltitude;

        // Filtrer les petites variations d'altitude (bruit GPS)
        if (altitudeDifference.abs() > 1.0) {
          // Seuil de 1 mètre
          if (altitudeDifference > 0) {
            totalAscent += altitudeDifference;
          } else {
            totalDescent += altitudeDifference.abs();
          }
        }
      }
      previousAltitude = location.altitude;
    }

    // Le dénivelé total est la somme des montées et des descentes
    return (totalAscent + totalDescent).round();
  }

  // Utile pour le filtrage des points GPS erronés
  bool isValidLocation() {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        accuracy <= 20.0; // 20 mètres de précision maximum
  }
}
