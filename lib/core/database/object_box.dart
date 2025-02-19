import '../../features/exercise_management/models/exercise.dart';
import '../../features/training_history/models/history_entry.dart';
import '../../features/training_history/models/history_run_location.dart';
import '../../features/training_history/models/training_version.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../features/training_management/models/multiset.dart';
import '../../features/training_management/models/training.dart';
import '../../features/training_management/models/training_exercise.dart';
import '../../objectbox.g.dart';

class ObjectBox {
  late final Store _store;
  late final Box<Training> _trainingBox;
  late final Box<Multiset> _multisetBox;
  late final Box<TrainingExercise> _trainingExerciseBox;
  late final Box<Exercise> _exerciseBox;
  late final Box<TrainingVersion> _trainingVersionBox;
  late final Box<HistoryEntry> _historyEntryBox;
  late final Box<RunLocation> _runLocationBox;

  ObjectBox._create(this._store) {
    _trainingBox = Box<Training>(_store);
    _multisetBox = Box<Multiset>(_store);
    _trainingExerciseBox = Box<TrainingExercise>(_store);
    _exerciseBox = Box<Exercise>(_store);
    _trainingVersionBox = Box<TrainingVersion>(_store);
    _historyEntryBox = Box<HistoryEntry>(_store);
    _runLocationBox = Box<RunLocation>(_store);
  }

  /// Méthode statique asynchrone pour créer une instance.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "mft-db"));
    return ObjectBox._create(store);
  }

  //* Create operations

  void createTraining(Training training, TrainingVersion trainingVersion) {
    _store.runInTransaction(TxMode.write, () {
      training.trainingVersions.add(trainingVersion);
      _trainingBox.put(training);
    });
  }

  int createExercise(Exercise exercise) {
    return _exerciseBox.put(exercise);
  }

  int createHistoryEntry(HistoryEntry historyEntry) {
    return _historyEntryBox.put(historyEntry);
  }

  int createRunLocation(RunLocation runLocation) {
    return _runLocationBox.put(runLocation);
  }

  int createTrainingVersion(Training training) {
    final newVersion = TrainingVersion.fromTraining(training);
    return _trainingVersionBox.put(newVersion);
  }

  //* Read operations
  List<Training> getAllTrainings() {
    return _trainingBox.getAll();
  }

  List<Multiset> getAllMultisets() {
    return _multisetBox.getAll();
  }

  List<TrainingExercise> getAllTrainingExercises() {
    return _trainingExerciseBox.getAll();
  }

  List<Exercise> getAllExercises() {
    return _exerciseBox.getAll();
  }

  Training? getTrainingById(int id) {
    return _trainingBox.get(id);
  }

  Multiset? getMultisetById(int id) {
    return _multisetBox.get(id);
  }

  TrainingExercise? getTrainingExerciseById(int id) {
    return _trainingExerciseBox.get(id);
  }

  Exercise? getExerciseById(int id) {
    return _exerciseBox.get(id);
  }

  TrainingVersion? getMostRecentTrainingVersionForTrainingId(int id) {
    return _trainingBox.get(id)?.trainingVersions.last;
  }

  TrainingVersion? getTrainingVersionById(int id) {
    return _trainingVersionBox.get(id);
  }

  List<HistoryEntry> getAllHistoryEntries() {
    return _historyEntryBox.getAll();
  }

  List<HistoryEntry> getHistoryEntriesForPeriod(
      DateTime startDate, DateTime endDate) {
    final query = _historyEntryBox
        .query((HistoryEntry_.date.between(
            startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch)))
        .build();

    final results = query.find();

    query.close();

    return results;
  }

  bool checkIfTrainingHasRecentEntry(int trainingExerciseId) {
    final now = DateTime.now();
    final twoHoursAgo = now.subtract(const Duration(hours: 2));

    final query = _historyEntryBox
        .query(HistoryEntry_.date
                .greaterThan(twoHoursAgo.millisecondsSinceEpoch) &
            HistoryEntry_.linkedTrainingExerciseId.equals(trainingExerciseId))
        .build();

    final results = query.find();

    query.close();

    return results.isNotEmpty;
  }

  List<RunLocation> getAllRunLocations() {
    return _runLocationBox.getAll();
  }

  List<RunLocation> getRunLocationsForPeriod(
      DateTime startDate, DateTime endDate) {
    final query = _runLocationBox
        .query((RunLocation_.timestamp.between(
            startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch)))
        .build();

    final results = query.find();

    query.close();

    return results;
  }

  Map<int, int?> getDaysSinceTraining() {
    Map<int, int?> daysSinceTrainings = {};

    final trainings = getAllTrainings();

    for (var training in trainings) {
      final query = _runLocationBox
          .query((RunLocation_.linkedTrainingId.equals(training.id)))
          .order(RunLocation_.timestamp, flags: Order.descending)
          .build();

      final result = query.findFirst();

      query.close();
      if (result != null) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(result.timestamp);
        final now = DateTime.now();
        final differenceInDays = now.difference(timestamp).inDays;

        // Ajouter la valeur à la map
        daysSinceTrainings[training.id] = differenceInDays;
      } else {
        // Si aucun résultat n'existe pour le training, on met `null` dans la map
        daysSinceTrainings[training.id] = null;
      }
    }

    return daysSinceTrainings;
  }

  //* Update operations
  void updateTraining(Training training, TrainingVersion trainingVersion) {
    _store.runInTransaction(TxMode.write, () {
      final currentTraining = getTrainingById(training.id);

      if (currentTraining == null) {
        throw Exception("Le training à mettre à jour n'existe pas.");
      }

      training.trainingVersions.add(trainingVersion);

      // Identifier les [TrainingExercise]s à supprimer (ceux qui ne sont plus référencés)
      final oldTrainingExercises = currentTraining.trainingExercises.toList();
      final newTrainingExerciseIds =
          training.trainingExercises.map((e) => e.id).toSet();

      final trainingExercisesToDelete = oldTrainingExercises
          .where((exercise) => !newTrainingExerciseIds.contains(exercise.id))
          .toList();

      // Supprimer les [TrainingExercise]s obsolètes
      for (var tExercise in trainingExercisesToDelete) {
        _trainingExerciseBox.remove(tExercise.id);
      }

      // Identifier les [Multiset]s à supprimer (ceux qui ne sont plus référencés)
      final oldMultisets = currentTraining.multisets.toList();
      final newMultisetIds = training.multisets.map((e) => e.id).toSet();

      final multisetsToDelete = oldMultisets
          .where((multiset) => !newMultisetIds.contains(multiset.id))
          .toList();

      // Supprimer les [Multiset]s obsolètes
      for (var multiset in multisetsToDelete) {
        for (var tExercise in multiset.trainingExercises) {
          _trainingExerciseBox.remove(tExercise.id);
        }
        _multisetBox.remove(multiset.id);
      }

      // Mettre à jour le [Training]
      _trainingBox.put(training);
    });
  }

  void updateExercise(Exercise exercise) {
    _store.runInTransaction(TxMode.write, () {
      _exerciseBox.put(exercise);
    });
  }

  void updateHistoryEntry(HistoryEntry historyEntry) {
    _store.runInTransaction(TxMode.write, () {
      _historyEntryBox.put(historyEntry);
    });
  }

  //* Delete operations
  void deleteTraining(Training training) {
    for (var tExercise in training.trainingExercises) {
      _trainingExerciseBox.remove(tExercise.id);
    }

    for (var multiset in training.multisets) {
      for (var tExercise in multiset.trainingExercises) {
        _trainingExerciseBox.remove(tExercise.id);
      }
      _multisetBox.remove(multiset.id);
    }

    _trainingBox.remove(training.id);
  }

  void deleteExercise(int id) {
    _exerciseBox.remove(id);
  }

  void deleteHistoryEntry(int id) {
    _historyEntryBox.remove(id);
  }

  void deleteHistoryEntriesForTrainingId(int trainingId) {
    final query = _historyEntryBox
        .query(HistoryEntry_.linkedTrainingId.equals(trainingId))
        .build();

    final entriesToDelete = query.find();

    query.close();

    for (final entry in entriesToDelete) {
      _historyEntryBox.remove(entry.id);
    }
  }
}
