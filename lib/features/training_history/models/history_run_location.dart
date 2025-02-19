import 'package:objectbox/objectbox.dart';

@Entity()
class RunLocation {
  @Id()
  int id = 0;
  @Index()
  int linkedTrainingId;
  int linkedTrainingExerciseId;
  int setNumber;
  double latitude;
  double longitude;
  double altitude;
  int timestamp;
  double accuracy;
  double speed;

  RunLocation({
    required this.id,
    required this.linkedTrainingId,
    required this.linkedTrainingExerciseId,
    required this.setNumber,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
    required this.accuracy,
    required this.speed,
  });

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
