import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryEntry extends Usecase<void, Params> {
  final HistoryRepository repository;

  DeleteHistoryEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    try {
      return await repository.deleteHistoryEntry(params.id);
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
