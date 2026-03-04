import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class DepositFunds {
  final WalletRepository repository;
  DepositFunds(this.repository);

  Future<Either<Failure, Wallet>> call({
    required double amount,
    required String reference,
  }) =>
      repository.depositFunds(amount: amount, reference: reference);
}