import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/core/constants/network_constants.dart';
import 'package:steenie_wallet/wallet/network_service.dart';

void main() {
  group('NetworkService', () {
    late NetworkService service;

    setUp(() {
      service = NetworkService();
    });

    test('starts on testnet', () {
      expect(service.currentNetwork, BitcoinNetwork.testnet);
      expect(service.isMainnet, isFalse);
      expect(service.networkName, 'Bitcoin Testnet');
      expect(
        service.apiBase,
        NetworkConstants.testnetApi,
      );
    });

    test('switching network clears a custom endpoint', () {
      service.setCustomApiBase('https://example.com/api');

      expect(service.apiBase, 'https://example.com/api');

      service.selectNetwork(BitcoinNetwork.mainnet);

      expect(service.currentNetwork, BitcoinNetwork.mainnet);
      expect(service.isMainnet, isTrue);
      expect(service.apiBase, NetworkConstants.mainnetApi);
    });

    test('accepts a valid HTTPS endpoint', () {
      service.setCustomApiBase('https://example.com/api/');

      expect(service.apiBase, 'https://example.com/api');
    });

    test('rejects HTTP endpoints', () {
      expect(
        () => service.setCustomApiBase('http://example.com/api'),
        throwsArgumentError,
      );
    });

    test('rejects endpoints with embedded credentials', () {
      expect(
        () => service.setCustomApiBase(
          'https://username:password@example.com/api',
        ),
        throwsArgumentError,
      );
    });

    test('clearing a custom endpoint restores the default', () {
      service.setCustomApiBase('https://example.com/api');
      service.resetCustomApiBase();

      expect(service.apiBase, NetworkConstants.testnetApi);
    });
  });
}
