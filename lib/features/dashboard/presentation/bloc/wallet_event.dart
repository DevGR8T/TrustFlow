abstract class WalletEvent {}

class LoadWallet extends WalletEvent {}

class DepositRequested extends WalletEvent {
  final double amount;
  final String reference;
  DepositRequested({required this.amount, required this.reference});
}