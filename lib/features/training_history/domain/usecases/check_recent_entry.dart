import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

class CheckRecentEntry extends Usecase<bool, Params> {
  final HistoryRepository repository;

  CheckRecentEntry(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    try {
      return await repository.checkIfRecentEntry(params.id);
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
