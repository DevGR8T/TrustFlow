class Wallet {
  final String id;
  final double balance;
  final String currency;

  const Wallet({
    required this.id,
    required this.balance,
    this.currency = 'NGN',
  });

  Wallet copyWith({double? balance}) {
    return Wallet(
      id: id,
      balance: balance ?? this.balance,
      currency: currency,
    );
  }
}