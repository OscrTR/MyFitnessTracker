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
  int createTraining(Training training) {
    for (var tExercise in training.trainingExercises) {
      createTrainingExercise(tExercise);
    }
    for (var multiset in training.multisets) {
      createMultiset(multiset);
    }

    final createdTraining = _trainingBox.put(training);

    // Enregistrer le nouveau [TrainingVersion]
    final newVersion = TrainingVersion.fromTraining(training);
    createTrainingVersion(newVersion);

    return createdTraining;
  }

  int createMultiset(Multiset multiset) {
    for (var tExercise in multiset.trainingExercises) {
      createTrainingExercise(tExercise);
    }
    return _multisetBox.put(multiset);
  }

  int createTrainingExercise(TrainingExercise trainingExercise) {
    return _trainingExerciseBox.put(trainingExercise);
  }

  int createExercise(Exercise exercise) {
    return _exerciseBox.put(exercise);
  }

  int createTrainingVersion(TrainingVersion trainingVersion) {
    return _trainingVersionBox.put(trainingVersion);
  }

  int createHistoryEntry(HistoryEntry historyEntry) {
    return _historyEntryBox.put(historyEntry);
  }

  int createRunLocation(RunLocation runLocation) {
    return _runLocationBox.put(runLocation);
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
    final query = _trainingVersionBox
        .query(TrainingVersion_.linkedTrainingId.equals(id))
        .order(TrainingVersion_.id, flags: Order.descending)
        .build();

    final result = query.findFirst();
    query.close();

    return result;
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

  //* Update operations
  void updateTraining(Training training) {
    _store.runInTransaction(TxMode.write, () {
      // Récupérer le [Training] actuel depuis la base de données
      final currentTraining = getTrainingById(training.id);

      if (currentTraining == null) {
        throw Exception("Le training à mettre à jour n'existe pas.");
      }

      // Identifier les [TrainingExercise]s à supprimer (ceux qui ne sont plus référencés)
      final oldTrainingExercises = currentTraining.trainingExercises.toList();
      final newTrainingExerciseIds =
          training.trainingExercises.map((e) => e.id).toSet();

      final trainingExercisesToDelete = oldTrainingExercises
          .where((exercise) => !newTrainingExerciseIds.contains(exercise.id))
          .toList();

      // Identifier les [Multiset]s à supprimer (ceux qui ne sont plus référencés)
      final oldMultisets = currentTraining.multisets.toList();
      final newMultisetIds = training.multisets.map((e) => e.id).toSet();

      final multisetsToDelete = oldMultisets
          .where((multiset) => !newMultisetIds.contains(multiset.id))
          .toList();

      // Supprimer les [TrainingExercise]s obsolètes
      for (var tExercise in trainingExercisesToDelete) {
        deleteTrainingExercise(tExercise.id);
      }

      // Supprimer les [Multiset]s obsolètes
      for (var multiset in multisetsToDelete) {
        deleteMultiset(multiset);
      }

      // Mettre à jour les [TrainingExercise]s
      for (var tExercise in training.trainingExercises) {
        updateTrainingExercise(tExercise);
      }

      // Mettre à jour les [Multiset]s
      for (var multiset in training.multisets) {
        updateMultiset(multiset);
      }

      // Mettre à jour le [Training]
      _trainingBox.put(training);

      // Enregistrer le nouveau [TrainingVersion]
      final newVersion = TrainingVersion.fromTraining(training);
      createTrainingVersion(newVersion);
    });
  }

  void updateMultiset(Multiset multiset) {
    // Récupérer le [Multiset] actuel depuis la base de données
    final currentMultiset = getMultisetById(multiset.id);

    if (currentMultiset == null) {
      throw Exception("Le training à mettre à jour n'existe pas.");
    }

    // Identifier les [TrainingExercise]s à supprimer (ceux qui ne sont plus référencés)
    final oldTrainingExercises = currentMultiset.trainingExercises.toList();
    final newTrainingExerciseIds =
        multiset.trainingExercises.map((e) => e.id).toSet();

    final trainingExercisesToDelete = oldTrainingExercises
        .where((exercise) => !newTrainingExerciseIds.contains(exercise.id))
        .toList();

    // Supprimer les [TrainingExercise]s obsolètes
    for (var tExercise in trainingExercisesToDelete) {
      deleteTrainingExercise(tExercise.id);
    }

    // Mettre à jour les [TrainingExercise]s
    for (var tExercise in multiset.trainingExercises) {
      updateTrainingExercise(tExercise);
    }

    // Mettre à jour le [Multiset]
    _multisetBox.put(multiset);
  }

  void updateTrainingExercise(TrainingExercise trainingExercise) {
    _trainingExerciseBox.put(trainingExercise);
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
      deleteTrainingExercise(tExercise.id);
    }

    for (var multiset in training.multisets) {
      deleteMultiset(multiset);
    }

    _trainingBox.remove(training.id);
  }

  void deleteMultiset(Multiset multiset) {
    for (var tExercise in multiset.trainingExercises) {
      deleteTrainingExercise(tExercise.id);
    }

    _multisetBox.remove(multiset.id);
  }

  void deleteTrainingExercise(int id) {
    _trainingExerciseBox.remove(id);
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
