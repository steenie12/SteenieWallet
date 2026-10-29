enum TransactionDirection {
  incoming,
  outgoing,
}

class WalletTransaction {
  final String txid;
  final int amountSats;
  final int confirmedAtHeight;
  final bool confirmed;
  final int timestamp;
  final TransactionDirection direction;

  const WalletTransaction({
    required this.txid,
    required this.amountSats,
    required this.confirmedAtHeight,
    required this.confirmed,
    required this.timestamp,
    required this.direction,
  });

  double get amountBtc => amountSats.abs() / 100000000;

  DateTime? get date {
    if (timestamp <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>? ?? {};
    final confirmed = status['confirmed'] as bool? ?? false;

    final received = json['received'] as int? ?? 0;
    final sent = json['sent'] as int? ?? 0;
    final netAmount = received - sent;

    return WalletTransaction(
      txid: json['txid'] as String? ?? '',
      amountSats: netAmount,
      confirmed: confirmed,
      confirmedAtHeight: status['block_height'] as int? ?? 0,
      timestamp: status['block_time'] as int? ?? 0,
      direction: netAmount >= 0
          ? TransactionDirection.incoming
          : TransactionDirection.outgoing,
    );
  }
}
