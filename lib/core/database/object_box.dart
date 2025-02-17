import 'package:my_fitness_tracker/features/exercise_management/models/exercise.dart';
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

  ObjectBox._create(this._store) {
    _trainingBox = Box<Training>(_store);
    _multisetBox = Box<Multiset>(_store);
    _trainingExerciseBox = Box<TrainingExercise>(_store);
    _exerciseBox = Box<Exercise>(_store);
  }

  /// Méthode statique asynchrone pour créer une instance.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "mft-db"));
    return ObjectBox._create(store);
  }

  //* Create operations
  Future<int> createTraining(Training training) async {
    for (var tExercise in training.trainingExercises) {
      createTrainingExercise(tExercise);
    }
    for (var multiset in training.multisets) {
      createMultiset(multiset);
    }
    return _trainingBox.put(training);
  }

  Future<int> createMultiset(Multiset multiset) async {
    for (var tExercise in multiset.trainingExercises) {
      createTrainingExercise(tExercise);
    }
    return _multisetBox.put(multiset);
  }

  Future<int> createTrainingExercise(TrainingExercise trainingExercise) async {
    return _trainingExerciseBox.put(trainingExercise);
  }

  Future<int> createExercise(Exercise exercise) async {
    return _exerciseBox.put(exercise);
  }

  //* Read operations
  List<Training> getAllTrainings() {
    final allTrainings = _trainingBox.getAll();
    final allExercises = _exerciseBox.getAll();

    for (var training in allTrainings) {
      // Initialize relations between a [Training] and its [Multiset]s
      training.multisets.addAll(_multisetBox
          .getAll()
          .where((multiset) => multiset.trainingId == training.id));

      for (var multiset in training.multisets) {
        // Initialize relations between a [Multiset] and its [TrainingExercise]s
        multiset.trainingExercises.addAll(_trainingExerciseBox
            .getAll()
            .where((exercise) => exercise.multisetId == multiset.id));

        for (var trainingExercise in multiset.trainingExercises) {
          // Initialize a relation between a [TrainingExercise] and its [Exercise]
          trainingExercise.exercise.target = allExercises.firstWhere(
              (tExercise) => tExercise.id == trainingExercise.exerciseId);
        }
      }

      // Initialize relations between a [Training] and its [TrainingExercise]s
      training.trainingExercises.addAll(_trainingExerciseBox.getAll().where(
          (tExercise) =>
              tExercise.trainingId == training.id &&
              tExercise.multisetId == null));

      for (var trainingExercise in training.trainingExercises) {
        // Initialize a relation between a [TrainingExercise] and its [Exercise]
        trainingExercise.exercise.target = allExercises.firstWhere(
            (exercise) => exercise.id == trainingExercise.exerciseId);
      }
    }
    return allTrainings;
  }

  List<Multiset> getAllMultisets() {
    final allMultisets = _multisetBox.getAll();
    final allExercises = _exerciseBox.getAll();

    for (var multiset in allMultisets) {
      // Initialize relations between a [Multiset] and its [TrainingExercise]s
      multiset.trainingExercises.addAll(_trainingExerciseBox
          .getAll()
          .where((tExercise) => tExercise.multisetId == multiset.id));

      for (var trainingExercise in multiset.trainingExercises) {
        // Initialize a relation between a [TrainingExercise] and its [Exercise]
        trainingExercise.exercise.target = allExercises.firstWhere(
            (exercise) => exercise.id == trainingExercise.exerciseId);
      }
    }

    return allMultisets;
  }

  List<TrainingExercise> getAllTrainingExercises() {
    final allExercises = _exerciseBox.getAll();
    final allTrainingExercises = _trainingExerciseBox.getAll();

    for (var trainingExercise in allTrainingExercises) {
      // Initialize a relation between a [TrainingExercise] and its [Exercise]
      trainingExercise.exercise.target = allExercises
          .firstWhere((exercise) => exercise.id == trainingExercise.exerciseId);
    }
    return allTrainingExercises;
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
    // Mettre à jour les trainingExercises
    for (var tExercise in training.trainingExercises) {
      updateTrainingExercise(tExercise);
    }

    // Mettre à jour les multisets
    for (var multiset in training.multisets) {
      updateMultiset(multiset);
    }

    // Effacer les anciens exercices et multisets
    training.trainingExercises.clear();
    training.multisets.clear();

    // Ajouter les nouveaux exercices et multisets
    for (var tExercise in training.trainingExercises) {
      training.trainingExercises.add(tExercise);
    }

    for (var multiset in training.multisets) {
      training.multisets.add(multiset);
    }

    // Mettre à jour le training
    await _trainingBox.putAsync(training);

    // Nettoyer les éléments inutilisés
    final allTrainings = _trainingBox.getAll();
    final usedTExerciseIds = allTrainings
        .expand((t) => t.trainingExercises.map((e) => e.id))
        .toSet();
    final usedMultisetsIds =
        allTrainings.expand((t) => t.multisets.map((e) => e.id)).toSet();

    // Identifier et supprimer les exercices non utilisés
    final allTrainingsTExercises =
        _trainingExerciseBox.getAll().where((e) => e.multisetId == null);
    final unusedTExercises = allTrainingsTExercises
        .where((e) => !usedTExerciseIds.contains(e.id))
        .toList();

    for (var tExercise in unusedTExercises) {
      deleteTrainingExercise(tExercise.id);
    }

    // Identifier et supprimer les multisets non utilisés
    final allMultisets = _multisetBox.getAll();
    final unusedMultisets =
        allMultisets.where((e) => !usedMultisetsIds.contains(e.id)).toList();

    for (var multiset in unusedMultisets) {
      await deleteMultiset(multiset);
    }
  }

  Future<void> updateMultiset(Multiset multiset) async {
    // Mettre à jour les trainingExercises
    for (var tExercise in multiset.trainingExercises) {
      updateTrainingExercise(tExercise);
    }

    // Effacer les anciens exercices
    multiset.trainingExercises.clear();

    // Ajouter les nouveaux exercices
    for (var tExercise in multiset.trainingExercises) {
      multiset.trainingExercises.add(tExercise);
    }

    // Mettre à jour le training
    await _multisetBox.putAsync(multiset);

    // Nettoyer les éléments inutilisés
    final allMultisets = _multisetBox.getAll();
    final usedTExerciseIds = allMultisets
        .expand((m) => m.trainingExercises.map((e) => e.id))
        .toSet();

    // Identifier et supprimer les exercices non utilisés
    final allMultisetsTExercises =
        _trainingExerciseBox.getAll().where((e) => e.multisetId != null);
    final unusedTExercises = allMultisetsTExercises
        .where((e) => !usedTExerciseIds.contains(e.id))
        .toList();

    for (var tExercise in unusedTExercises) {
      deleteTrainingExercise(tExercise.id);
    }
  }

  Future<void> updateTrainingExercise(TrainingExercise trainingExercise) async {
    _trainingExerciseBox.putAsync(trainingExercise);
  }

  Future<void> updateExercise(Exercise exercise) async {
    _exerciseBox.putAsync(exercise);
  }

  //* Delete operations
  Future<void> deleteTraining(Training training) async {
    for (var tExercise in training.trainingExercises) {
      deleteTrainingExercise(tExercise.id);
    }

    for (var multiset in training.multisets) {
      deleteMultiset(multiset);
    }

    _trainingBox.removeAsync(training.id);
  }

  Future<void> deleteMultiset(Multiset multiset) async {
    for (var tExercise in multiset.trainingExercises) {
      deleteTrainingExercise(tExercise.id);
    }

    _multisetBox.removeAsync(multiset.id);
  }

  Future<void> deleteTrainingExercise(int id) async {
    _trainingExerciseBox.removeAsync(id);
  }

  Future<void> deleteExercise(int id) async {
    _exerciseBox.removeAsync(id);
  }
}
