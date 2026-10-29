import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class PinVerifier {
  PinVerifier({Random? secureRandom})
      : _random = secureRandom ?? Random.secure();

  final Random _random;

  static const int _saltLength = 16;
  static const int _keyLength = 32;
  static const int _iterations = 600000;

  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: _keyLength * 8,
  );

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  /// Creates a salted verifier record. Never persist the PIN itself.
  Future<String> createVerifier(String pin) async {
    if (!RegExp(r'^[0-9]{6,12}$').hasMatch(pin)) {
      throw ArgumentError('PIN must contain 6 to 12 digits.');
    }

    final salt = _randomBytes(_saltLength);
    final derivedKey = await _derive(pin, salt);

    return jsonEncode({
      'version': 1,
      'algorithm': 'PBKDF2-HMAC-SHA256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'verifier': base64Encode(await derivedKey.extractBytes()),
    });
  }

  /// Returns false for an invalid PIN or malformed verifier record.
  Future<bool> verify({
    required String pin,
    required String verifierRecord,
  }) async {
    if (!RegExp(r'^[0-9]{6,12}$').hasMatch(pin)) return false;

    try {
      final decoded = jsonDecode(verifierRecord);

      if (decoded is! Map<String, dynamic> ||
          decoded['version'] != 1 ||
          decoded['algorithm'] != 'PBKDF2-HMAC-SHA256' ||
          decoded['iterations'] != _iterations) {
        return false;
      }

      final saltValue = decoded['salt'];
      final verifierValue = decoded['verifier'];

      if (saltValue is! String || verifierValue is! String) {
        return false;
      }

      final salt = base64Decode(saltValue);
      final expected = base64Decode(verifierValue);

      if (salt.length != _saltLength || expected.length != _keyLength) {
        return false;
      }

      final actual = await _derive(pin, salt);
      final actualBytes = await actual.extractBytes();

      // Compare all bytes instead of returning at the first mismatch.
      var difference = 0;
      for (var i = 0; i < expected.length; i++) {
        difference |= expected[i] ^ actualBytes[i];
      }

      return difference == 0;
    } catch (_) {
      return false;
    }
  }

  Future<SecretKey> _derive(String pin, List<int> salt) {
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
  }
}
