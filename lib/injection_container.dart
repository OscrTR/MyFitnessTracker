import 'package:get_it/get_it.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/bloc/active_training_bloc.dart';
import 'features/training_management/domain/usecases/create_training.dart';
import 'features/training_management/domain/usecases/delete_training.dart';
import 'features/training_management/domain/usecases/get_training.dart';
import 'features/training_management/domain/usecases/update_training.dart';
import 'features/training_management/data/datasources/training_local_data_source.dart';
import 'features/training_management/data/repositories/training_repository_impl.dart';
import 'features/training_management/domain/repositories/training_repository.dart';
import 'features/training_management/domain/usecases/fetch_trainings.dart';
import 'features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:sqflite/sqflite.dart';

import 'core/database/sqlite_database_helper.dart';
import 'core/messages/bloc/message_bloc.dart';
import 'features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'features/exercise_management/data/repositories/exercise_repository_impl.dart';
import 'features/exercise_management/domain/repositories/exercise_repository.dart';
import 'features/exercise_management/domain/usecases/create_exercise.dart';
import 'features/exercise_management/domain/usecases/delete_exercise.dart';
import 'features/exercise_management/domain/usecases/fetch_exercises.dart';
import 'features/exercise_management/domain/usecases/get_exercise.dart';
import 'features/exercise_management/domain/usecases/update_exercise.dart';
import 'features/exercise_management/presentation/bloc/exercise_management_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register the Database (async registration)
  sl.registerLazySingletonAsync<Database>(
      () async => await SQLiteDatabaseHelper.getDatabase());

  // Ensure the Database is ready before registering anything that depends on it
  await sl.isReady<Database>();

  //! Core
  sl.registerLazySingleton(() => MessageBloc());

  //! Features - Exercise Management
  // Bloc
  sl.registerFactory(() => ExerciseManagementBloc(
      createExercise: sl(),
      fetchExercises: sl(),
      updateExercise: sl(),
      deleteExercise: sl(),
      getExercise: sl(),
      messageBloc: sl()));

  // Usecases
  sl.registerLazySingleton(() => CreateExercise(sl()));
  sl.registerLazySingleton(() => GetExercise(sl()));
  sl.registerLazySingleton(() => FetchExercises(sl()));
  sl.registerLazySingleton(() => UpdateExercise(sl()));
  sl.registerLazySingleton(() => DeleteExercise(sl()));

  // Repository
  sl.registerLazySingleton<ExerciseRepository>(
      () => ExerciseRepositoryImpl(localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<ExerciseLocalDataSource>(
      () => SQLiteExerciseLocalDataSource(database: sl()));

  //! Features - Training Management
  // Bloc
  sl.registerFactory(() => TrainingManagementBloc(
        createTraining: sl(),
        fetchTrainings: sl(),
        getTraining: sl(),
        updateTraining: sl(),
        deleteTraining: sl(),
        messageBloc: sl(),
      ));

  // Usecases
  sl.registerLazySingleton(() => CreateTraining(sl()));
  sl.registerLazySingleton(() => FetchTrainings(sl()));
  sl.registerLazySingleton(() => GetTraining(sl()));
  sl.registerLazySingleton(() => UpdateTraining(sl()));
  sl.registerLazySingleton(() => DeleteTraining(sl()));

  // Repository
  sl.registerLazySingleton<TrainingRepository>(
      () => TrainingRepositoryImpl(localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<TrainingLocalDataSource>(
      () => SQLiteTrainingLocalDataSource(database: sl()));

  //! Features - Training Management
  // Bloc
  sl.registerFactory(() => ActiveTrainingBloc());

  // External
}
