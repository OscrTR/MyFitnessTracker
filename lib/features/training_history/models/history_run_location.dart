import 'package:equatable/equatable.dart';

class RunLocation extends Equatable {
  final int? id;
  final int trainingId;
  final int exerciseId;
  final int trainingVersionId;
  final int setNumber;
  final int? intervalNumber;
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
    required this.intervalNumber,
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

    // Parcourir la liste à partir du deuxième point.
    for (int i = 1; i < locations.length; i++) {
      double previousAltitude = locations[i - 1].altitude;
      double currentAltitude = locations[i].altitude;
      double diff = currentAltitude - previousAltitude;

      if (diff > 0) {
        // C'est une montée.
        totalAscent += diff;
      } else if (diff < 0) {
        // C'est une descente.
        totalDescent += -diff; // On prend la valeur absolue.
      }
    }

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
      intervalNumber,
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
      'intervalNumber': intervalNumber,
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
      id: map['id'] as int?,
      trainingId: map['trainingId'] as int,
      exerciseId: map['exerciseId'] as int,
      trainingVersionId: map['trainingVersionId'] as int,
      setNumber: map['setNumber'] as int,
      intervalNumber: map['intervalNumber'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: map['altitude'] as double,
      date: map['date'] as int,
      accuracy: map['accuracy'] as double,
      speed: map['speed'] as double,
    );
  }
}
