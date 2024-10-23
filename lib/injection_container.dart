import 'package:get_it/get_it.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/repositories/exercise_repository_impl.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/create_exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Exercise Management
  // Bloc
  sl.registerFactory(() => ExerciseManagementBloc(createExercise: sl()));

  // Usecases
  sl.registerLazySingleton(() => CreateExercise(sl()));

  // Repository
  sl.registerLazySingleton<ExerciseRepository>(
      () => ExerciseRepositoryImpl(localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<ExerciseLocalDataSource>(
      () => SQLiteExerciseLocalDataSource(database: sl()));

  // Core

  // External
  // TODO register SQLite
}
