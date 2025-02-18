import 'package:my_fitness_tracker/features/exercise_management/models/exercise.dart';
import 'package:my_fitness_tracker/features/training_history/data/models/training_version.dart';
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

  ObjectBox._create(this._store) {
    _trainingBox = Box<Training>(_store);
    _multisetBox = Box<Multiset>(_store);
    _trainingExerciseBox = Box<TrainingExercise>(_store);
    _exerciseBox = Box<Exercise>(_store);
    _trainingVersionBox = Box<TrainingVersion>(_store);
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

  //* Update operations
  Future<void> updateTraining(Training training) async {
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

  Future<void> updateExercise(Exercise exercise) async {
    await _store.runInTransaction(TxMode.write, () async {
      _exerciseBox.put(exercise);
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
}
