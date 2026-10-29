import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/core/security/pin_verifier.dart';

void main() {
  group('PinVerifier', () {
    late PinVerifier verifier;

    setUp(() {
      verifier = PinVerifier();
    });

    test('creates and verifies a valid PIN', () async {
      const pin = '482691';

      final record = await verifier.createVerifier(pin);

      expect(record, isNot(contains(pin)));
      expect(
        await verifier.verify(
          pin: pin,
          verifierRecord: record,
        ),
        isTrue,
      );
    });

    test('rejects an incorrect PIN', () async {
      final record = await verifier.createVerifier('482691');

      expect(
        await verifier.verify(
          pin: '482692',
          verifierRecord: record,
        ),
        isFalse,
      );
    });

    test('rejects PINs outside the allowed format', () async {
      expect(
        () => verifier.createVerifier('123'),
        throwsArgumentError,
      );
      expect(
        () => verifier.createVerifier('12345a'),
        throwsArgumentError,
      );
      expect(
        () => verifier.createVerifier('1234567890123'),
        throwsArgumentError,
      );
    });

    test('rejects a malformed verifier record', () async {
      expect(
        await verifier.verify(
          pin: '482691',
          verifierRecord: 'not valid JSON',
        ),
        isFalse,
      );
    });
  });
}
