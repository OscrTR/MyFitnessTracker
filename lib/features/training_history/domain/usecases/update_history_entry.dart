import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class UpdateHistoryEntry extends Usecase<HistoryEntry, Params> {
  final HistoryRepository repository;

  UpdateHistoryEntry(this.repository);

  @override
  Future<Either<Failure, HistoryEntry>> call(Params params) async {
    try {
      return await repository.updateHistoryEntry(params.historyEntry);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final HistoryEntry historyEntry;

  const Params(this.historyEntry);

  @override
  List<Object> get props => [historyEntry];
}
