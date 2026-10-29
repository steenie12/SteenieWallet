import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/wallet/mnemonic_service.dart';

void main() {
  group('MnemonicService', () {
    final service = MnemonicService();

    test('generates a valid 12-word recovery phrase', () {
      final phrase = service.generateMnemonic();
      final words = phrase.split(' ');

      expect(words.length, 12);
      expect(service.validateMnemonic(phrase), isTrue);
    });

    test('normalizes extra whitespace and uppercase letters', () {
      const phrase =
          '  abandon   abandon abandon abandon abandon abandon '
          'abandon abandon abandon abandon abandon about  ';

      final normalized = service.normalizeMnemonic(phrase);

      expect(
        normalized,
        'abandon abandon abandon abandon abandon abandon '
        'abandon abandon abandon abandon abandon about',
      );
      expect(service.validateMnemonic(normalized), isTrue);
    });

    test('rejects an invalid recovery phrase', () {
      expect(
        service.validateMnemonic('this is not a valid recovery phrase'),
        isFalse,
      );
    });

    test('returns the words of a valid phrase in order', () {
      const phrase =
          'abandon abandon abandon abandon abandon abandon '
          'abandon abandon abandon abandon abandon about';

      expect(service.words(phrase).length, 12);
      expect(service.words(phrase).last, 'about');
    });
  });
}
