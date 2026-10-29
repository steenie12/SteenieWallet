import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/network_constants.dart';

class BitcoinBalance {
  final int confirmedSats;
  final int unconfirmedSats;

  const BitcoinBalance({
    required this.confirmedSats,
    required this.unconfirmedSats,
  });

  int get totalSats => confirmedSats + unconfirmedSats;

  double get totalBtc => totalSats / 100000000;
}

class BalanceService {
  BalanceService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<BitcoinBalance> fetchBalance({
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
      '$base/address/${Uri.encodeComponent(normalizedAddress)}',
    );

    final response = await _client.get(uri).timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Balance request failed with HTTP ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected balance response.');
    }

    final chain = data['chain_stats'];
    final mempool = data['mempool_stats'];

    if (chain is! Map<String, dynamic> ||
        mempool is! Map<String, dynamic>) {
      throw const FormatException('Balance response is missing statistics.');
    }

    final chainFunded = _readInt(chain, 'funded_txo_sum');
    final chainSpent = _readInt(chain, 'spent_txo_sum');
    final mempoolFunded = _readInt(mempool, 'funded_txo_sum');
    final mempoolSpent = _readInt(mempool, 'spent_txo_sum');

    return BitcoinBalance(
      confirmedSats: chainFunded - chainSpent,
      unconfirmedSats: mempoolFunded - mempoolSpent,
    );
  }

  int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value is int && value >= 0) return value;

    throw FormatException('Invalid $key value in API response.');
  }

  void dispose() {
    _client.close();
  }
}
