import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet();
  Future<Either<Failure, Wallet>> depositFunds({
    required double amount,
    required String reference,
  });
  Future<Either<Failure, List<Transaction>>> getTransactions();
}