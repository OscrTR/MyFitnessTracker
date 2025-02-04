import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class FetchHistoryEntries extends Usecase<List<HistoryEntry>, Params> {
  final HistoryRepository repository;

  FetchHistoryEntries(this.repository);

  @override
  Future<Either<Failure, List<HistoryEntry>>> call(Params params) async {
    try {
      return await repository.fetchHistoryEntries(
          params.startDate, params.endDate);
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }
}

class Params extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const Params(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}
