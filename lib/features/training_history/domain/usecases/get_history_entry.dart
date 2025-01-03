import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_entry.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

class GetHistoryEntry extends Usecase<HistoryEntry, Params> {
  final HistoryRepository repository;

  GetHistoryEntry(this.repository);

  @override
  Future<Either<Failure, HistoryEntry>> call(Params params) async {
    try {
      return await repository.getHistoryEntry(params.id);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final int id;

  const Params(this.id);

  @override
  List<Object> get props => [id];
}
