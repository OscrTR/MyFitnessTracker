import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/multiset.dart';

abstract class MultisetRepository {
  Future<Either<Failure, List<Multiset>>> fetchMultisets(int trainingId);

  Future<Either<Failure, Multiset>> createMultiset(Multiset multiset);

  Future<Either<Failure, Multiset>> updateMultiset(Multiset multiset);

  Future<Either<Failure, void>> deleteMultiset(int id);
}
