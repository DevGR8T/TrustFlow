enum TransactionType { credit, debit }
enum TransactionStatus { success, pending, failed }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime date;
  final String? reference;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    this.reference,
  });
}