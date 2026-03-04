import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}
class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<Transaction> transactions;
  WalletLoaded({required this.wallet, required this.transactions});
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}

class DepositSuccess extends WalletState {
  final Wallet wallet;
  final List<Transaction> transactions;
  final double amount;
  DepositSuccess({
    required this.wallet,
    required this.transactions,
    required this.amount,
  });
}