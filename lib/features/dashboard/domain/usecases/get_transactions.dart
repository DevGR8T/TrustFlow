import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/wallet_repository.dart';

class GetTransactions {
  final WalletRepository repository;
  GetTransactions(this.repository);

  Future<Either<Failure, List<Transaction>>> call() =>
      repository.getTransactions();
}