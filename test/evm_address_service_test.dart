import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/wallet/evm_address_service.dart';

void main() {
  group('EvmAddressService', () {
    final service = EvmAddressService();

    test('derives the standard first Ethereum address', () {
      // Public BIP39 test vector. Never use a real wallet phrase here.
      const phrase =
          'abandon abandon abandon abandon abandon abandon '
          'abandon abandon abandon abandon abandon about';

      final address = service.deriveAddress(phrase);

      expect(
        address,
        '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
      );
    });

    test('normalizes recovery phrase whitespace and case', () {
      const phrase =
          '  ABANDON   abandon abandon abandon abandon abandon '
          'abandon abandon abandon abandon abandon ABOUT  ';

      final address = service.deriveAddress(phrase);

      expect(
        address,
        '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
      );
    });

    test('rejects an invalid recovery phrase', () {
      expect(
        () => service.deriveAddress('not a valid recovery phrase'),
        throwsArgumentError,
      );
    });
  });
}
