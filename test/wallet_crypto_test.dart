import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/core/security/wallet_crypto.dart';

void main() {
  group('WalletCrypto', () {
    late WalletCrypto crypto;

    setUp(() {
      crypto = WalletCrypto();
    });

    test('encrypts and decrypts data with the correct password', () async {
      const original = 'example wallet data for testing only';
      const password = 'test-password-12345';

      final encrypted = await crypto.encrypt(
        plaintext: original,
        password: password,
      );

      expect(encrypted, isNot(original));

      final decrypted = await crypto.decrypt(
        encryptedPayload: encrypted,
        password: password,
      );

      expect(decrypted, original);
    });

    test('uses different salts and nonces for separate encryptions', () async {
      const original = 'test payload';
      const password = 'test-password-12345';

      final first = await crypto.encrypt(
        plaintext: original,
        password: password,
      );
      final second = await crypto.encrypt(
        plaintext: original,
        password: password,
      );

      expect(first, isNot(second));
    });

    test('rejects an incorrect password', () async {
      final encrypted = await crypto.encrypt(
        plaintext: 'private test data',
        password: 'correct-password-123',
      );

      expect(
        () => crypto.decrypt(
          encryptedPayload: encrypted,
          password: 'wrong-password-123',
        ),
        throwsA(isA<WalletDecryptionException>()),
      );
    });

    test('rejects unsupported encrypted-data versions', () async {
      final payload = jsonEncode({
        'version': 999,
      });

      expect(
        () => crypto.decrypt(
          encryptedPayload: payload,
          password: 'test-password-12345',
        ),
        throwsFormatException,
      );
    });

    test('rejects an empty plaintext', () async {
      expect(
        () => crypto.encrypt(
          plaintext: '',
          password: 'test-password-12345',
        ),
        throwsArgumentError,
      );
    });
  });
}
