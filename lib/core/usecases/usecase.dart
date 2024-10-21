import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';

abstract class Usecase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
