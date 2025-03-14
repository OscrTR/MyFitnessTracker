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

  /// Minutes per km
  final double pace;

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
    required this.pace,
  });

  static int calculateTotalElevation(List<RunLocation> locations) {
    if (locations.isEmpty) return 0;

    List<RunLocation> kalmanFilteredData =
        RunLocation.applyKalmanFilter(locations);

    Map<DateTime, double> aggregateAltitudesByMinute(
        List<RunLocation> locations) {
      if (locations.isEmpty) return {};

      final Map<DateTime, List<double>> groupedAltitudes = {};

      for (final loc in locations) {
        // Convertir le timestamp en DateTime
        final timestamp = DateTime.fromMillisecondsSinceEpoch(loc.date);
        // Conserver uniquement l'année, le mois, le jour, l'heure et la minute
        final key = DateTime(timestamp.year, timestamp.month, timestamp.day,
            timestamp.hour, timestamp.minute);

        groupedAltitudes.putIfAbsent(key, () => []).add(loc.altitude);
      }

      // Calculer la moyenne pour chaque minute et retourner la map
      final Map<DateTime, double> aggregated = {};
      groupedAltitudes.forEach((minute, altitudes) {
        final double avgAltitude =
            altitudes.reduce((a, b) => a + b) / altitudes.length;
        aggregated[minute] = avgAltitude;
      });

      return aggregated;
    }

    final altitudeMap = aggregateAltitudesByMinute(kalmanFilteredData);

    double totalAscent = 0;
    double totalDescent = 0;

    // Parcourir la liste à partir du deuxième point.
    for (int i = 1; i < altitudeMap.length; i++) {
      double previousAltitude = altitudeMap.values.toList()[i - 1];
      double currentAltitude = altitudeMap.values.toList()[i];
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
      pace,
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
      'pace': pace,
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
      pace: map['pace'] as double,
    );
  }

  static List<RunLocation> applyKalmanFilter(List<RunLocation> rawData) {
    List<RunLocation> filteredData = [];
    if (rawData.isEmpty) return filteredData;

    KalmanFilter altitudeFilter = KalmanFilter(
      estimate: rawData.first.altitude,
      error: 1.0,
      processNoise: 0.0001,
      measurementNoise: 0.1,
    );

    KalmanFilter paceFilter = KalmanFilter(
      estimate: rawData.first.pace,
      error: 1.0,
      processNoise: 0.0001,
      measurementNoise: 0.1,
    );

    // Filtrage des données
    for (var loc in rawData) {
      double filteredAltitude = altitudeFilter.update(loc.altitude);
      double filteredPace = paceFilter.update(loc.pace);
      filteredData.add(loc.copyWith(
        altitude: filteredAltitude,
        pace: filteredPace,
      ));
    }

    return filteredData;
  }

  RunLocation copyWith({
    int? id,
    int? trainingId,
    int? exerciseId,
    int? trainingVersionId,
    int? setNumber,
    int? intervalNumber,
    double? latitude,
    double? longitude,
    double? altitude,
    int? date,
    double? accuracy,
    double? pace,
  }) {
    return RunLocation(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      exerciseId: exerciseId ?? this.exerciseId,
      trainingVersionId: trainingVersionId ?? this.trainingVersionId,
      setNumber: setNumber ?? this.setNumber,
      intervalNumber: intervalNumber ?? this.intervalNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      date: date ?? this.date,
      accuracy: accuracy ?? this.accuracy,
      pace: pace ?? this.pace,
    );
  }
}

class KalmanFilter {
  double estimate;
  double error;
  final double processNoise; // q : bruit du processus
  final double measurementNoise; // r : bruit de la mesure

  KalmanFilter({
    required this.estimate,
    required this.error,
    required this.processNoise,
    required this.measurementNoise,
  });

  double update(double measurement) {
    double kalmanGain = error / (error + measurementNoise);
    estimate = estimate + kalmanGain * (measurement - estimate);
    error = (1 - kalmanGain) * error + processNoise;
    return estimate;
  }
}
