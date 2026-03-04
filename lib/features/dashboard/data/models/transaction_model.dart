import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.status,
    required super.date,
    super.reference,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      status: _parseStatus(json['status'] as String),
      date: DateTime.parse(json['date'] as String),
      reference: json['reference'] as String?,
    );
  }

  static TransactionStatus _parseStatus(String status) {
    switch (status) {
      case 'success':
        return TransactionStatus.success;
      case 'pending':
        return TransactionStatus.pending;
      default:
        return TransactionStatus.failed;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'status': status.name,
      'date': date.toIso8601String(),
      'reference': reference,
    };
  }
}