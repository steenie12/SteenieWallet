import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:steenie_wallet/core/constants/network_constants.dart';
import 'package:steenie_wallet/wallet/balance_service.dart';

void main() {
  group('BalanceService', () {
    test('calculates confirmed and unconfirmed balances', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/testnet/api/address/tb1qexample');

        return http.Response(
          jsonEncode({
            'chain_stats': {
              'funded_txo_sum': 50000,
              'spent_txo_sum': 10000,
            },
            'mempool_stats': {
              'funded_txo_sum': 5000,
              'spent_txo_sum': 1000,
            },
          }),
          200,
        );
      });

      final service = BalanceService(client: client);

      final balance = await service.fetchBalance(
        address: 'tb1qexample',
        network: BitcoinNetwork.testnet,
        customApiBase: 'https://example.com/testnet/api',
      );

      expect(balance.confirmedSats, 40000);
      expect(balance.unconfirmedSats, 4000);
      expect(balance.totalSats, 44000);
      expect(balance.totalBtc, 0.00044);

      service.dispose();
    });

    test('throws when the API returns an HTTP error', () async {
      final client = MockClient((_) async {
        return http.Response('Not found', 404);
      });

      final service = BalanceService(client: client);

      expect(
        () => service.fetchBalance(
          address: 'tb1qexample',
          network: BitcoinNetwork.testnet,
          customApiBase: 'https://example.com/api',
        ),
        throwsException,
      );

      service.dispose();
    });

    test('rejects an empty address', () async {
      final service = BalanceService(client: MockClient((_) async {
        return http.Response('{}', 200);
      }));

      expect(
        () => service.fetchBalance(
          address: ' ',
          network: BitcoinNetwork.testnet,
        ),
        throwsArgumentError,
      );

      service.dispose();
    });
  });
}
