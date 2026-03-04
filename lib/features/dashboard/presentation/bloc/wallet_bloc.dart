import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/deposit_funds.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_wallet.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWallet getWallet;
  final DepositFunds depositFunds;
  final GetTransactions getTransactions;

  WalletBloc({
    required this.getWallet,
    required this.depositFunds,
    required this.getTransactions,
  }) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<DepositRequested>(_onDepositRequested);
  }

  Future<void> _onLoadWallet(LoadWallet event, Emitter emit) async {
    emit(WalletLoading());
    final walletResult = await getWallet();
    final transactionsResult = await getTransactions();

    walletResult.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => transactionsResult.fold(
        (failure) => emit(WalletError(failure.message)),
        (transactions) => emit(
          WalletLoaded(wallet: wallet, transactions: transactions),
        ),
      ),
    );
  }

  Future<void> _onDepositRequested(
      DepositRequested event, Emitter emit) async {
    final result = await depositFunds(
      amount: event.amount,
      reference: event.reference,
    );
    final transactionsResult = await getTransactions();

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => transactionsResult.fold(
        (failure) => emit(WalletError(failure.message)),
        (transactions) => emit(DepositSuccess(
          wallet: wallet,
          transactions: transactions,
          amount: event.amount,
        )),
      ),
    );
  }
}