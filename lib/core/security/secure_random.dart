import 'dart:math';
import 'dart:typed_data';

/// Generates cryptographically secure random bytes.
///
/// Do not replace Random.secure() with Random() for security-sensitive data.
class SecureRandomGenerator {
  SecureRandomGenerator() : _random = Random.secure();

  final Random _random;

  Uint8List bytes(int length) {
    if (length <= 0 || length > 1024 * 1024) {
      throw ArgumentError.value(
        length,
        'length',
        'Length must be between 1 byte and 1 MiB.',
      );
    }

    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }
}
