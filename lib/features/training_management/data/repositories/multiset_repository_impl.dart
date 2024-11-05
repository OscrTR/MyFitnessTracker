import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/data/datasources/multiset_local_data_source.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';

import '../../../../core/error/exceptions.dart';

class MultisetRepositoryImpl implements MultisetRepository {
  final MultisetLocalDataSource localDataSource;

  MultisetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Multiset>> createMultiset(Multiset multiset) async {
    try {
      final createdMultiset = await localDataSource.createMultiset(multiset);
      return Right(createdMultiset);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMultiset(int id) async {
    try {
      await localDataSource.deleteMultiset(id);
      return const Right(null);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Multiset>>> fetchMultisets(int trainingId) async {
    try {
      return Right(await localDataSource.fetchMultisets(trainingId));
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Multiset>> updateMultiset(Multiset multiset) async {
    try {
      final updatedMultiset = await localDataSource.updateMultiset(multiset);
      return Right(updatedMultiset);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure());
    }
  }
}
