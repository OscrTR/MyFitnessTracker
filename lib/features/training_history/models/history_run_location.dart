import 'package:equatable/equatable.dart';

class RunLocation extends Equatable {
  final int? id;
  final int trainingId;
  final int exerciseId;
  final int trainingVersionId;
  final int setNumber;
  final double latitude;
  final double longitude;
  final double altitude;
  final int date;
  final double accuracy;
  final double speed;

  const RunLocation({
    this.id,
    required this.trainingId,
    required this.exerciseId,
    required this.trainingVersionId,
    required this.setNumber,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.date,
    required this.accuracy,
    required this.speed,
  });

  static int calculateTotalElevation(List<RunLocation> locations) {
    if (locations.isEmpty) return 0;

    locations.sort((a, b) => a.date.compareTo(b.date));

    double totalAscent = 0;
    double totalDescent = 0;
    double? previousAltitude;

    for (var location in locations) {
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

  @override
  List<Object?> get props {
    return [
      id,
      exerciseId,
      trainingId,
      trainingVersionId,
      setNumber,
      latitude,
      longitude,
      altitude,
      date,
      accuracy,
      speed,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trainingId': trainingId,
      'exerciseId': exerciseId,
      'trainingVersionId': trainingVersionId,
      'setNumber': setNumber,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'date': date,
      'accuracy': accuracy,
      'speed': speed,
    };
  }

  factory RunLocation.fromMap(Map<String, dynamic> map) {
    return RunLocation(
      id: map['id'] != null ? map['id'] as int : null,
      trainingId: map['trainingId'] as int,
      exerciseId: map['exerciseId'] as int,
      trainingVersionId: map['trainingVersionId'] as int,
      setNumber: map['setNumber'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: map['altitude'] as double,
      date: map['date'] as int,
      accuracy: map['accuracy'] as double,
      speed: map['speed'] as double,
    );
  }
}
