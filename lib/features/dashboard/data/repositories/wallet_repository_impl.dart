import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../models/transaction_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  static const _balanceKey = 'wallet_balance';
  static const _transactionsKey = 'wallet_transactions';

  @override
  Future<Either<Failure, Wallet>> getWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final balance = prefs.getDouble(_balanceKey) ?? 0.0;
      return Right(Wallet(id: 'wallet_001', balance: balance));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load wallet.'));
    }
  }

  @override
  Future<Either<Failure, Wallet>> depositFunds({
    required double amount,
    required String reference,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentBalance = prefs.getDouble(_balanceKey) ?? 0.0;
      final newBalance = currentBalance + amount;

      // Save new balance
      await prefs.setDouble(_balanceKey, newBalance);

      // Save transaction
      final transactions = _loadTransactions(prefs);
      final newTransaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Wallet Deposit',
        amount: amount,
        type: TransactionType.credit,
        status: TransactionStatus.success,
        date: DateTime.now(),
        reference: reference,
      );
      transactions.insert(0, newTransaction);
      await prefs.setString(
        _transactionsKey,
        jsonEncode(transactions.map((t) => t.toJson()).toList()),
      );

      return Right(Wallet(id: 'wallet_001', balance: newBalance));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update balance.'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = _loadTransactions(prefs);
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load transactions.'));
    }
  }

  List<TransactionModel> _loadTransactions(SharedPreferences prefs) {
    final raw = prefs.getString(_transactionsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => TransactionModel.fromJson(e)).toList();
  }
}