import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class WalletCrypto {
  WalletCrypto({Random? secureRandom})
      : _random = secureRandom ?? Random.secure();

  final Random _random;

  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _keyLength = 32;

  // PBKDF2-SHA256 with a high work factor to make guessing harder.
  // Benchmark this on the target phone before finalizing the parameters.
  static const int _iterations = 600000;

  final Pbkdf2 _keyDerivation = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: _keyLength * 8,
  );

  final AesGcm _cipher = AesGcm.with256bits();

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  Future<String> encrypt({
    required String plaintext,
    required String password,
  }) async {
    if (plaintext.isEmpty) {
      throw ArgumentError('Plaintext cannot be empty.');
    }
    if (password.length < 12) {
      throw ArgumentError('Use a strong password of at least 12 characters.');
    }

    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);

    final secretKey = await _deriveKey(
      password: password,
      salt: salt,
    );

    final secretBox = await _cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    final payload = <String, dynamic>{
      'version': 1,
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _iterations,
      'cipher': 'AES-256-GCM',
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };

    return jsonEncode(payload);
  }

  Future<String> decrypt({
    required String encryptedPayload,
    required String password,
  }) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty.');
    }

    final decoded = jsonDecode(encryptedPayload);

    if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
      throw const FormatException('Unsupported encrypted wallet format.');
    }

    if (decoded['kdf'] != 'PBKDF2-HMAC-SHA256' ||
        decoded['cipher'] != 'AES-256-GCM' ||
        decoded['iterations'] != _iterations) {
      throw const FormatException('Unsupported encryption parameters.');
    }

    final salt = _decodeBase64(decoded, 'salt');
    final nonce = _decodeBase64(decoded, 'nonce');
    final ciphertext = _decodeBase64(decoded, 'ciphertext');
    final macBytes = _decodeBase64(decoded, 'mac');

    if (salt.length != _saltLength ||
        nonce.length != _nonceLength ||
        macBytes.length != 16) {
      throw const FormatException('Invalid encrypted wallet data.');
    }

    final secretKey = await _deriveKey(
      password: password,
      salt: salt,
    );

    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    try {
      final cleartext = await _cipher.decrypt(
        secretBox,
        secretKey: secretKey,
      );
      return utf8.decode(cleartext);
    } on SecretBoxAuthenticationError {
      throw const WalletDecryptionException(
        'Unable to unlock wallet. Check the password or encrypted data.',
      );
    }
  }

  Future<SecretKey> _deriveKey({
    required String password,
    required List<int> salt,
  }) {
    return _keyDerivation.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  List<int> _decodeBase64(
    Map<String, dynamic> payload,
    String field,
  ) {
    final value = payload[field];

    if (value is! String) {
      throw FormatException('Missing or invalid $field field.');
    }

    try {
      return base64Decode(value);
    } on FormatException {
      throw FormatException('Invalid $field encoding.');
    }
  }
}

class WalletDecryptionException implements Exception {
  const WalletDecryptionException(this.message);

  final String message;

  @override
  String toString() => message;
}
