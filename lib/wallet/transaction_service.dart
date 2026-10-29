import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/network_constants.dart';
import '../models/wallet_transaction.dart';

class TransactionService {
  TransactionService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<List<WalletTransaction>> fetchTransactions({
    required String address,
    required BitcoinNetwork network,
    String? customApiBase,
  }) async {
    final normalizedAddress = address.trim();

    if (normalizedAddress.isEmpty) {
      throw ArgumentError('A Bitcoin address is required.');
    }

    final base = (customApiBase ?? NetworkConstants.apiFor(network))
        .trim()
        .replaceFirst(RegExp(r'/+$'), '');

    final uri = Uri.parse(
      '$base/address/${Uri.encodeComponent(normalizedAddress)}/txs',
    );

    final response = await _client.get(uri).timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Transaction request failed with HTTP ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException('Unexpected transaction response.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(WalletTransaction.fromJson)
        .toList(growable: false);
  }

  void dispose() {
    _client.close();
  }
}
